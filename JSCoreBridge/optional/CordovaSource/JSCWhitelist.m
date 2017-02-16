/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "JSCWhitelist.h"
#import "JSCDebug.h"

NSString* const kJSCDefaultWhitelistRejectionString = @"ERROR whitelist rejection: url='%@'";
NSString* const kJSCDefaultSchemeName = @"jsc-default-scheme";


@interface JSCWhitelistPattern : NSObject {
    NSRegularExpression *_scheme;
    NSRegularExpression *_host;
    NSNumber *_port;
    NSRegularExpression *_path;
}

+ (NSString *)regexFromPattern:(NSString *)pattern allowWildcards:(bool)allowWildcards;
- (id)initWithScheme:(NSString *)scheme host:(NSString *)host port:(NSString *)port path:(NSString *)path;
- (bool)matches:(NSURL *)url;

@end

@implementation JSCWhitelistPattern

+ (NSString*)regexFromPattern:(NSString *)pattern allowWildcards:(bool)allowWildcards{
    NSString* regex = [NSRegularExpression escapedPatternForString:pattern];
    
    if (allowWildcards) {
        regex = [regex stringByReplacingOccurrencesOfString:@"\\*" withString:@".*"];
        
        /* [NSURL path] has the peculiarity that a trailing slash at the end of a path
         * will be omitted. This regex tweak compensates for that.
         */
        if ([regex hasSuffix:@"\\/.*"]) {
            regex = [NSString stringWithFormat:@"%@(\\/.*)?", [regex substringToIndex:([regex length] - 4)]];
        }
    }
    return [NSString stringWithFormat:@"%@$", regex];
}

- (id)initWithScheme:(NSString *)scheme host:(NSString *)host port:(NSString *)port path:(NSString *)path{
    self = [super init];  // Potentially change "self"
    if (self) {
        if (scheme == nil || [@"*" isEqualToString:scheme]) {
            _scheme = nil;
        } else {
            _scheme = [NSRegularExpression regularExpressionWithPattern:[JSCWhitelistPattern regexFromPattern:scheme allowWildcards:NO] options:NSRegularExpressionCaseInsensitive error:nil];
        }
        
        if (host == nil || [@"*" isEqualToString:host]) {
            _host = nil;
        } else if ([host hasPrefix:@"*."]) {
            _host = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"([a-z0-9.-]*\\.)?%@", [JSCWhitelistPattern regexFromPattern:[host substringFromIndex:2] allowWildcards:false]] options:NSRegularExpressionCaseInsensitive error:nil];
        } else {
            _host = [NSRegularExpression regularExpressionWithPattern:[JSCWhitelistPattern regexFromPattern:host allowWildcards:NO] options:NSRegularExpressionCaseInsensitive error:nil];
        }
        
        if (port == nil || [@"*" isEqualToString:port]) {
            _port = nil;
        } else {
            _port = [[NSNumber alloc] initWithInteger:[port integerValue]];
        }
        
        if (path == nil || [@"/*" isEqualToString:path]) {
            _path = nil;
        } else {
            _path = [NSRegularExpression regularExpressionWithPattern:[JSCWhitelistPattern regexFromPattern:path allowWildcards:YES] options:0 error:nil];
        }
    }
    return self;
}

- (bool)matches:(NSURL *)url{
    return (_scheme == nil || [_scheme numberOfMatchesInString:url.scheme options:NSMatchingAnchored range:NSMakeRange(0, url.scheme.length)]) &&
    (_host == nil || (url.host && [_host numberOfMatchesInString:url.host options:NSMatchingAnchored range:NSMakeRange(0, url.host.length)])) &&
    (_port == nil || [url.port isEqualToNumber:_port]) &&
    (_path == nil || [_path numberOfMatchesInString:url.path options:NSMatchingAnchored range:NSMakeRange(0, url.path.length)]);
}

@end


@interface JSCWhitelist ()

@property (nonatomic, strong) NSMutableArray *whitelist;
@property (nonatomic, strong) NSMutableSet *permittedSchemes;


@end

@implementation JSCWhitelist


- (id)initWithArray:(NSArray *)array{
    self = [super init];
    if (self) {
        _whitelist = [[NSMutableArray alloc] init];
        _permittedSchemes = [[NSMutableSet alloc] init];
        _whitelistRejectionFormatString = [kJSCDefaultWhitelistRejectionString copy];

        for (NSString* pattern in array) {
            [self p_addWhiteListEntry:pattern];
        }
    }
    return self;
}

- (BOOL)p_isIPv4Address:(NSString *)externalHost{
    // an IPv4 address has 4 octets b.b.b.b where b is a number between 0 and 255.
    // for our purposes, b can also be the wildcard character '*'

    // we could use a regex to solve this problem but then I would have two problems
    // anyways, this is much clearer and maintainable
    NSArray *octets = [externalHost componentsSeparatedByString:@"."];
    NSUInteger num_octets = [octets count];

    // quick check
    if (num_octets != 4) {
        return NO;
    }

    // restrict number parsing to 0-255
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setMinimum:[NSNumber numberWithUnsignedInteger:0]];
    [numberFormatter setMaximum:[NSNumber numberWithUnsignedInteger:255]];

    // iterate through each octet, and test for a number between 0-255 or if it equals '*'
    for (NSUInteger i = 0; i < num_octets; ++i) {
        NSString* octet = octets[i];

        if ([octet isEqualToString:@"*"]) { // passes - check next octet
            continue;
        } else if ([numberFormatter numberFromString:octet] == nil) { // fails - not a number and not within our range, return
            return NO;
        }
    }

    return YES;
}

- (void)p_addWhiteListEntry:(NSString *)origin{
    if (_whitelist == nil) {
        return;
    }

    if ([origin isEqualToString:@"*"]) {
        JSCLog(@"Unlimited access to network resources");
        self.whitelist = nil;
        self.permittedSchemes = nil;
    } else { // specific access
        NSRegularExpression *parts = [NSRegularExpression regularExpressionWithPattern:@"^((\\*|[A-Za-z-]+):/?/?)?(((\\*\\.)?[^*/:]+)|\\*)?(:(\\d+))?(/.*)?" options:0 error:nil];
        NSTextCheckingResult *m = [parts firstMatchInString:origin options:NSMatchingAnchored range:NSMakeRange(0, origin.length)];
        if (m != nil) {
            NSRange r;
            NSString *scheme = nil;
            r = [m rangeAtIndex:2];
            if (r.location != NSNotFound) {
                scheme = [origin substringWithRange:r];
            }

            NSString *host = nil;
            r = [m rangeAtIndex:3];
            if (r.location != NSNotFound) {
                host = [origin substringWithRange:r];
            }

            // Special case for two urls which are allowed to have empty hosts
            if (([scheme isEqualToString:@"file"] || [scheme isEqualToString:@"content"]) && (host == nil)) {
                host = @"*";
            }

            NSString *port = nil;
            r = [m rangeAtIndex:7];
            if (r.location != NSNotFound) {
                port = [origin substringWithRange:r];
            }

            NSString *path = nil;
            r = [m rangeAtIndex:8];
            if (r.location != NSNotFound) {
                path = [origin substringWithRange:r];
            }

            if (scheme == nil) {
                // XXX making it stupid friendly for people who forget to include protocol/SSL
                [_whitelist addObject:[[JSCWhitelistPattern alloc] initWithScheme:@"http" host:host port:port path:path]];
                [_whitelist addObject:[[JSCWhitelistPattern alloc] initWithScheme:@"https" host:host port:port path:path]];
            } else {
                [_whitelist addObject:[[JSCWhitelistPattern alloc] initWithScheme:scheme host:host port:port path:path]];
            }

            if (_permittedSchemes) {
                if ([scheme isEqualToString:@"*"]) {
                    self.permittedSchemes = nil;
                } else if (scheme) {
                    [_permittedSchemes addObject:scheme];
                }
            }
        }
    }
}

- (BOOL)schemeIsAllowed:(NSString *)scheme{
    if ([scheme isEqualToString:@"http"] ||
        [scheme isEqualToString:@"https"] ||
        [scheme isEqualToString:@"ftp"] ||
        [scheme isEqualToString:@"ftps"]) {
        return YES;
    }

    return (self.permittedSchemes == nil) || [self.permittedSchemes containsObject:scheme];
}

- (BOOL)URLIsAllowed:(NSURL *)url{
    return [self URLIsAllowed:url logFailure:YES];
}

- (BOOL)URLIsAllowed:(NSURL *)url logFailure:(BOOL)logFailure{
    // Shortcut acceptance: Are all urls whitelisted ("*" in whitelist)?
    if (_whitelist == nil) {
        return YES;
    }

    // Shortcut rejection: Check that the scheme is supported
    NSString *scheme = [url.scheme lowercaseString];
    if (![self schemeIsAllowed:scheme]) {
        if (logFailure) {
            NSLog(@"%@", [self errorStringForURL:url]);
        }
        return NO;
    }

    // http[s] and ftp[s] should also validate against the common set in the kCDVDefaultSchemeName list
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] || [scheme isEqualToString:@"ftp"] || [scheme isEqualToString:@"ftps"]) {
        NSURL* newUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@", kJSCDefaultSchemeName, url.host, [url.path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]]];
        // If it is allowed, we are done.  If not, continue to check for the actual scheme-specific list
        if ([self URLIsAllowed:newUrl logFailure:NO]) {
            return YES;
        }
    }

    // Check the url against patterns in the whitelist
    for (JSCWhitelistPattern *p in _whitelist) {
        if ([p matches:url]) {
            return YES;
        }
    }

    if (logFailure) {
        NSLog(@"%@", [self errorStringForURL:url]);
    }
    // if we got here, the url host is not in the white-list, do nothing
    return NO;
}

- (NSString*)errorStringForURL:(NSURL*)url{
    return [NSString stringWithFormat:self.whitelistRejectionFormatString, [url absoluteString]];
}

@end
