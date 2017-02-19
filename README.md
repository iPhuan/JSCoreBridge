<!--
# iPhuan Open Source
# JSCoreBridge
# Created by iPhuan on 2017/2/16.
# Copyright © 2017年 iPhuan. All rights reserved.
-->

JSCoreBridge
=============================================================
JSCoreBridge是基于iOS平台[Apache Cordova](http://cordova.apache.org/)修改的开源框架，Cordova的用处在于作为桥梁通过插件的方式实现了Web与Native之间的通信，而JSCoreBridge参考其进行删减修改（移除了开发者在平时用不上的类和方法），改写了其传统的通信机制，在保留了Cordova实用的功能前提下，精简优化了框架占用大小，并且省去了繁琐的工程设置选项，通过的新的实现方式大大提供了通信效率。JSCoreBridge开源框架力在为开发者提供更便捷的Hybird开发体验。  



目录
-------------------------------------------------------------
* [适用范围](#1)
* [通信原理](#2)
    * [Cordova通信原理](#2.1)
    * [JSCoreBridge通信原理](#2.2)
* [如何获取JSCoreBridge](#3)
* [使用说明](#4)
    * [JSCoreBridge Web平台](#4.1)
         * [jsCoreBridge.js存放说明](#4.1.1)
         * [jsCoreBridge.js接口说明](#4.1.2)
    * [JSCoreBridge Native平台](#4.2)
         * [config.xml](#4.2.1)
         * [JSCWebViewController](#JSCWebViewController)
         * [JSCBridgeDelegate](#JSCBridgeDelegate)
         * [JSCPlugin](#JSCPlugin)
         * [JSCPluginResult](#JSCPluginResult)
         * [JSCInvokedPluginCommand](#JSCInvokedPluginCommand)
         * [其他框架类](#4.2.7)
         * [自定义错误信息](#4.2.8)
    * [网页加载回调执行顺序说明](#WebLoadOrder)
    * [Cordova用法兼容性](#4.4)
* [风险声明](#5)
* [开源说明](#6)
* [如何联系我](#ContactInfo)  
* [版本更新记录](#UpdateInfo)  


<br />
<br />

<a name="1">适用范围</a>
-------------------------------------------------------------
* 适用于Hybird开发者，希望通过JSCoreBridge框架实现客户端Web与Native之间的交互与通信。
* 适用于已经在使用Cordova框架并且考虑更换Cordova框架的开发者。  

> JSCoreBridge是在Cordova的基础上进行修改的，它兼容大部分Cordova的用法，熟悉Cordova的开发者极易上手。  

<br />
<a name="2">通信原理</a>
-------------------------------------------------------------
### <a name="2.1">Cordova通信原理：</a>

1. Web创建自定义scheme “`gap://ready`”，并响应链接跳转事件；
2. Cordova通过WebView代理方法`webView:shouldStartLoadWithRequest:navigationType:`截获该gap跳转；
3. Cordova通过WebView`stringByEvaluatingJavaScriptFromString:`方法执行Cordova JS方法`nativeFetchMessages`获取Web当前的命令参数并转化为`CDVInvokedUrlCommand`对象；
4. Cordova根据`CDVInvokedUrlCommand`对象的`className`和`methodName`属性找到对应插件和对应的插件方法，并执行插件方法；
5. Cordova执行完插件方法后如需给Web返回数据结果，则再次通过WebView`stringByEvaluatingJavaScriptFromString:`方法执行Cordova JS方法`nativeCallback`，通过`CDVInvokedUrlCommand`的`callbackId`作为标识将结果发送给Web对应的回调。

<br />
### <a name="2.2">JSCoreBridge通信原理：</a>  

不再使用传统的scheme链接跳转截取和`stringByEvaluatingJavaScriptFromString:`执行JS的方法，通过iOS7新增的**`JavaScriptCore.framework`**来实现JS和Native之间的通信。

1. Web调用`jsCoreBridge.js`的`exec`或者`execSync`方法直接将命令参数传给客户端；
2. JSCoreBridge将命令参数转化为`JSCInvokedPluginCommand`对象；
3. JSCoreBridge根据`JSCInvokedPluginCommand`对象的`className`和`methodName`属性找到对应插件和对应的插件方法，并执行插件方法；
4. JSCoreBridge执行完插件方法后如需给Web返回数据结果，直接调用`jsCoreBridge.js`的`nativeCallback`方法，通过`JSCInvokedPluginCommand`的`callbackId`作为标识将结果发送给Web对应的回调。

<br />
<a name="3">如何获取JSCoreBridge</a>  
-------------------------------------------------------------
1. 直接在GitHub上[获取](https://github.com/iPhuan/JSCoreBridge.git)
2. 通过[CocoaPods](http://guides.cocoapods.org/using/using-cocoapods.html)添加到工程：  

> * 如果你想使用完整版的JSCoreBridge，添加以下命令行到Podfile：  

```ruby
    pod 'JSCoreBridge'
```

> * 如果你想使用Lite版的JSCoreBridge，添加以下命令行到Podfile：  

```ruby
    pod 'JSCoreBridge/JSCoreBridgeLite'
```  

> * 如果你想使用更兼容Cordova用法的JSCoreBridge,可以添加以下命令行到Podfile：  

```ruby
    pod 'JSCCordova'
```  

或者  

```ruby
    pod 'JSCCordova/JSCCordovaLite'
```  


注：Lite版的JSCoreBridge将不使用`config.xml`进行功能选项配置，JSCoreBridgeLite仅仅实现了最基本的通信；如果你准备使用JSCCordova，更多详细说明请参考[Cordova用法兼容性](#4.4)。
  

<br />
<a name="4">使用说明</a>  
=============================================================
JSCoreBridge框架可通过CocoaPods Pod到工程，也可手动下载源码添加，加入JSCoreBridge后，简单配置config.xml和jsCoreBridge.js即可使用，如框架为手动添加，需添加`JavaScriptCore.framework`库。  

`config.xml`和`jsCoreBridge.js`的相关说明下文会做详细介绍。

[JSCoreBridge Demo](https://github.com/iPhuan/JSCoreBridge.git)中有JSCoreBridge的详细使用样例代码，可下载参考。

<br />
<a name="4.1">JSCoreBridge Web平台</a>  
-------------------------------------------------------------
### <a name="4.1.1">jsCoreBridge.js存放说明：</a> 

* jsCoreBridge.js本身在工程当中，如打开的html文件在bundle中，可直接引用，当然如果你的html文件在bundle的子目录下，你希望`jsCoreBridge.js`和你的网页目录在同一级，你也可以将`jsCoreBridge.js`拷贝到该同级目录；
* 如果你的html文件存储在沙盒，请务必把`jsCoreBridge.js`拷贝到沙盒；
* 如果你的网页在远程网站上，那么你同样需要将`jsCoreBridge.js`放到你的远程网站上；  

> jsCoreBridge.js的使用原则在于，保证你的html文件能够引用到。

<br />
### <a name="4.1.2">jsCoreBridge.js接口说明：</a> 

jsCoreBridge.js对应于Cordova的[cordova.js](https://github.com/apache/cordova-ios/blob/master/CordovaLib/cordova.js)，通过`jsCoreBridge`对象来调用，也兼容Cordova用法，可以通过`cordova`对象调用，jsCoreBridge接口如下：  

* **`jsCoreBridge.version`**  

> 获取当前JSCoreBridge Web平台JS版本号。<br />
> 客户端JSCoreBridge框架对`jsCoreBridge.js`有最低版本要求，Pod到工程的`jsCoreBridge.js`相对于当前客户端JSCoreBridge框架都是最新的版本，可放心使用，如果你自行从其他途径下载`jsCoreBridge.js`，请保证该版本能够兼容客户端JSCoreBridge框架。

* **`jsCoreBridge.exec`**  

> 执行客户端对应插件方法。<br />
> 通过该方法可以告诉客户端JSCoreBridge框架通过对应插件的对应方法去执行相应的事情，代码示例如下：

```javascript
    var params = {title: 'JSCoreBridge Demo'};

    jsCoreBridge.exec(function (res) {
    // 成功回调
    }, function (err) {
    // 失败回调
    }, 'JSCTestPlugin', 'changeNavTitle', [params]);
```

   > - 第一个函数为成功回调，第二个函数为失败回调，通过res和err获取结果数据，当然如果你不想收到回调，这两个参数可以传空，如果你不希望接收res和err结果数据，回调函数你也可以不用带参数；
   > - `JSCTestPlugin`为客户端对应的插件Plugin类名；
   > - `changeNavTitle`为`JSCTestPlugin`插件中对应的插件方法；
   > - 最后一个参数则为Web传给客户端的参数，通过数组的方式传递，至于数组里面传递什么样的数据，由开发者自行决定，当然该参数你也可以传空或者不传。

* **`jsCoreBridge.execSync`**  

> 同步执行客户端对应插件方法。<br />
> 与exec接口不同的是该方法为同步操作，没有成功与失败回调函数，其他参数与`exec`用法一致。其代码示例如下：  

```javascript
    var version = jsCoreBridge.execSync('JSCTestPlugin', 'getAppVersionSync', null);
```

* **`deviceready`**  

> JSCoreBridge运行环境已准备就绪监听事件。<br />
> 可通过以下示例代码来监听JSCoreBridge准备完成：  

```javascript
    document.addEventListener('deviceready', onDeviceReady, false)
```
:warning: 注意：  
为了保证客户端插件方法能够正确执行，请在`deviceready`回调中或者回调执行后调用`jsCoreBridge`对象的方法；  
如果你在`deviceready`回调中调用`jsCoreBridge.exec`，不要企望客户端对应插件方法会在`jsCoreBridgeDidReady:`之前调用，`jsCoreBridge.exec`为异步操作，除非你使用`jsCoreBridge.execSync`同步方法。

<br />

* **`pause`**  

> 客户端已经进入后台监听事件。<br />
> 可通过以下示例代码来监听客户端已经进入后台：

```javascript
    document.addEventListener('pause', onPause, false)
```

* **`resume`**  

> 客户端即将进入前台监听事件。<br />
> 可通过以下示例代码来监听客户端即将进入前台：

```js
    document.addEventListener('resume', onResume, false)
```


<br />
<a name="4.2">JSCoreBridge Native平台</a>  
-------------------------------------------------------------
<a name="4.2.1"></a>  
### [config.xml：](http://cordova.apache.org/docs/en/latest/config_ref/index.html)  

在Cordova中config.xml是框架功能选项的配置文件，包含工程的一些信息，插件白名单，Web URL白名单，WebView属性设置等。同样在JSCoreBridge中，我们将`config.xml`移植了过来，并对一些配置选项进行了删减，以便达到一个轻量级的JSCoreBridge框架。  

config.xml文件并不是必须的，当你使用`JSCoreBridgeLite`时，将不再使用`config.xml`文件来配置框架；当然你也可以通过设置[JSCWebViewController](#JSCWebViewController)类的`configEnabled`属性来关闭使用`config.xml`，以使用一个最轻量化的JSCoreBridge。  
JSCoreBridge在未使用`config.xml`的状况下，其仅仅满足Web与Native之间通信的基本功能，不进行插件白名单验证，不进行Web URL白名单验证，并且WebView的相关属性都保持为系统默认状态。

想了解`config.xml`文件如何配置，可进一步点击[这里](http://cordova.apache.org/docs/en/latest/config_ref/index.html)，到Cordova官方网站进行了解。  
当然对于一般的开发者来说，JSCoreBridge当中的[config.xml](https://github.com/iPhuan/JSCoreBridge/blob/master/JSCoreBridge/Optional/config.xml)样例已足够满足需求，你只需配置插件白名单即可，配置示例如下：  

```xml
    <feature name="JSCTestBasePlugin">
    <param name="ios-package" value="JSCTestBasePlugin" />
    <param name="onload" value="true" />
    </feature>
```  
> 一般来说保持`feature`当中`name`的值和`param`当中`value`值一致，当然你也可以不一致，但必须保证`param`当中`value`值和对应的插件类名一致；
> 如果希望插件在JSCoreBridge初始化时就加载，可以通过`<param name="onload" value="true" />`来设置，如果不需要，可以省去该行。  


在JSCoreBridge中，以下配置选项目前暂未实现：  

1. [content](http://cordova.apache.org/docs/en/latest/config_ref/index.html#content)
2. [access](http://cordova.apache.org/docs/en/latest/config_ref/index.html#access)
3. [engine](http://cordova.apache.org/docs/en/latest/config_ref/index.html#engine)
4. [plugin](http://cordova.apache.org/docs/en/latest/config_ref/index.html#plugin)
5. [variable](http://cordova.apache.org/docs/en/latest/config_ref/index.html#variable)
6. [preference](http://cordova.apache.org/docs/en/latest/config_ref/index.html#preference)中 (`BackupWebStorage`， `TopActivityIndicator`，  `ErrorUrl`， `OverrideUserAgent`， `AppendUserAgent`， `target-device`， `deployment-target`， `CordovaWebViewEngine`， `SuppressesLongPressGesture`， `Suppresses3DTouchGesture`)

在JSCoreBridge中，以下配置选项不再需要添加：  

1. [widget](http://cordova.apache.org/docs/en/latest/config_ref/index.html#widget)中 (`id`， `version`，`defaultlocale`，`ios-CFBundleVersion`，`xmlns`，`xmlns:cdv`)
2. [name](http://cordova.apache.org/docs/en/latest/config_ref/index.html#name)
3. [description](http://cordova.apache.org/docs/en/latest/config_ref/index.html#description)
4. [author](http://cordova.apache.org/docs/en/latest/config_ref/index.html#author)  

:warning: 如工程用到`config.xml`，请在`JSCoreBridge/Optional`目录下将`config.xml`复制到其他目录并添加到工程使用；



<br />
### <a name="JSCWebViewController">JSCWebViewController：</a> 
JSCWebViewController是JSCoreBridge框架直接供开发者使用的ViewController，可以直接使用，也可根据自己的需求来继承使用，其部分API说明如下：  

* **`bridgeDelegate`**   

> JSCoreBridge代理。可通过该对象执行相应代理方法，具体可参考[JSCBridgeDelegate](#JSCBridgeDelegate)。  


* **`configFilePath`**   

> config.xml文件路径。默认为`nil`从Bundle根目录获取，如果设置该属性，则从该属性路径获取，不支持网络地址。


* **`configEnabled`**   

> 是否开启config配置功能。默认开启，如需关闭，可设置为NO；当使用JSCoreBridgeLite时`configEnabled`属性设置不可用，始终为关闭状态。


* **`shouldAutoLoadURL`**   

> 是否自动加载URL。默认自动加载通过`initWithUrl:`初始化的URL，设置为NO关闭自动加载。  


* **`- (instancetype)initWithUrl:(NSString *)url`**  

> 通过字符串链接初始化URL。可在`JSCWebViewController`子类中重写该方法。  


* **`- (void)loadURL:(NSURL *)URL`**  
* **`- (void)loadHTMLString:(NSString *)htmlString`**   

> 通过调用以上两方法进行网页手动加载  


* **`- (void)jsCoreBridgeWillReady:(UIWebView *)webView`**  
* **`- (void)jsCoreBridgeDidReady:(UIWebView *)webView`**  

> JSCoreBridge将要准备就绪和已准备就绪回调。分别在`deviceready`通知回调执行之前和之后调用，方便开发者在这两个时刻进行相应操作，可在[JSCWebViewController](#JSCWebViewController)子类中重写该方法使用。  


:warning: **特别提示：**关于客户端Native及Web的相应回调方法的执行顺序请参考[网页加载回调执行顺序说明](#WebLoadOrder)。  


<br />
### <a name="JSCBridgeDelegate">JSCBridgeDelegate：</a>
JSCBridgeDelegate是`JSCoreBridge`类的代理，可通过该代理向Web发送结果数据，执行JS等。该代理作为[JSCWebViewController](#JSCWebViewController)和[JSCPlugin](#JSCPlugin)的属性来使用。

* **`- (void)registerPlugin:(JSCPlugin *)plugin withPluginName:(NSString *)pluginName`**  

> 将已有的插件通过类名注册到插件白名单当中。如果使用`config.xml`，那么JSCoreBridge将只会识别`config.xml`配置好的插件白名单，不在白名单范围内的的插件将不予加载使用，可通过该方法将插件注册到白名单当中去。  


* **`- (nullable __kindof JSCPlugin *)getPluginInstance:(NSString *)pluginName`**  

> 通过插件类名来获取插件对象。可通过该方法获取对应Plugin的实例对象。  


* **`- (void)sendPluginResult:(JSCPluginResult *)result forCallbackId:(NSString *)callbackId`**  

> 向Web发送结果数据。将结果数据以[JSCPluginResult](#JSCPluginResult)对象实例进行封装，并以`callbackId`作为回调标识发送给Web。代码实例如下：  

```objective-c
    NSDictionary *message = @{@"resCode":@"0", @"resMsg":@"OK"};
    // 将要返回给Web的结果以字典形式通过JSCPluginResult初始化
    JSCPluginResult *result = [JSCPluginResult resultWithStatus:JSCCommandStatus_OK messageAsDictionary:message];
    // 发送结果
    [self.bridgeDelegate sendPluginResult:result forCallbackId:command.callbackId];
```  


* **`- (JSValue *)evaluateScript:(NSString *)script`**  
* **`- (JSValue *)callScriptFunction:(NSString *)funcName withArguments:(nullable NSArray *)arguments`**  

> 执行JS和调用JS函数方法。方法一实际通过`JSContext`的`evaluateScript:`方法执行JS；方法二通过`JSContext`的`callWithArguments:`调用JS函数，需要传递函数名称`funcName`，如果该函数直属于Window对象，则直接传递函数名，如果该函数并不直属于Window对象，则可通过键值路径的方式调用，代码示例如下： 

```objective-c
    [self.bridgeDelegate callScriptFunction:@"jsCoreBridge.fireDocumentEvent" withArguments:@[@"deviceready"]];
```  
  
> 其中`jsCoreBridge`必须为Window的属性。


* **`- (void)onMainThreadEvaluateScript:(NSString *)script`**  
* **`- (void)onMainThreadCallScriptFunction:(NSString *)funcName withArguments:(nullable NSArray *)arguments`**  

> 与上两方法作用一致，只是这两个方法确保执行JS和调用JS函数在主线程上。在特定的情况下不在主线程上执行JS将导致程序崩溃，通过这两个方法可以解决该问题。  


* **`- (void)runInBackground:(void (^)())block`**  
* **`- (void)runOnMainThread:(void (^)())block`**  

> 辅助类方法，方便开发者在后台或者主线程上处理对应事情。 



<br />
### <a name="JSCPlugin">JSCPlugin：</a>
JSCPlugin即为我们刚刚一直说的插件，这是一个基类，开发者需根据需求来分类建立多个插件，而这些插件都应当要继承于JSCPlugin来使用。  
JSCPlugin插件方法的声明示例如下：  

```objective-c
    - (void)changeNavTitle:(JSCInvokedPluginCommand *)command;
    - (void)sendEmail:(JSCInvokedPluginCommand *)command;
    - (NSString *)getAppVersionSync:(JSCInvokedPluginCommand *)command; // 同步操作
```   

> 接收一个[JSCInvokedPluginCommand](#JSCInvokedPluginCommand)对象，JSCoreBridge支持同步操作，如果需要使用同步操作，需要对应有一个返回值，而该返回值必须是一个Object对象，否则将给Web返回空的结果数据。


JSCPlugin的部分API说明如下：  

* **`webView`**   
* **`webViewController`**   

> 获取当前`webView`和`webViewController`。  


* **`backupCallbackId`**   

> 用于备份某个插件方法的`callbackId`。当你在某个插件方法中使用了某个对象，而该对象的一些操作需要在代理方法中获取结果时，可通过该属性来保存当前插件方法的回调`callbackId`，以便在代理回调中继续使用该`callbackId`来发送结果数据。具体用法可参考[JSCoreBridge Demo](https://github.com/iPhuan/JSCoreBridge.git)。  
> 当然该用法只适用于当前插件只有一个插件方法需要用到backupCallbackId，如果多个插件方法需要保存callbackId，建议参考cordova官方插件的一些写法，将`callbackId`作为其对应使用对象的属性成员，如[CDVCamera](https://github.com/apache/cordova-plugin-camera/blob/master/src/ios/CDVCamera.h)插件，`CDVCameraPicker`继承`UIImagePickerController`，并拥有`callbackId`属性。  


* **`- (void)pluginDidInitialize`**  

> 插件初始化后回调该方法，可在该方法中进行一些初始化的操作，类似于`UIViewController`的`viewDidLoad`方法。  


* **`- (void)canCallPlugin`**  

> JSCoreBridge调用插件时，先通过该方法进行权限验证，如果返回YES，则可正常调用插件，如返回NO，则无法调用。开发者可通过该方法进行一些权限的条件设置。  


<br />
### <a name="JSCPluginResult">JSCPluginResult：</a>
JSCoreBridge给Web发送的结果数据通过JSCPluginResult对象进行封装，以字符串，数组，Cordova特定的格式等多种数据格式进行发送。  


* **`status`**  

> 结果状态，`JSCCommandStatus_OK`时将结果发送给成功回调，`JSCCommandStatus_ERROR`时将结果发送给失败回调。  


* **`keepCallback`**  

> 是否需要继续回调。默认为NO，同一个`callbackId`只能发送一次结果数据，设为YES，则支持多次回调。比如写一个监听客户端某个按钮点击事件的插件方法，用户点击按钮一次，给Web发送一次结果消息，此种使用场景则需要将`keepCallback`设置为YES才能保证多次回调。 



<br />
### <a name="JSCInvokedPluginCommand">JSCInvokedPluginCommand：</a>
JSCoreBridge通过JSCInvokedPluginCommand对象将Web发送给Native的命令参数进行封装，其属性包含如下成员：   


* **`callbackId`** 
* **`className`**  
* **`methodName`**  
* **`arguments`**  

分别为回调的callbackId标识，插件类名，插件方法名，Web传给客户端的参数，JSCoreBridge正是通过这些属性来完成Web交给Native的任务。  


<br />
### <a name="4.2.7">其他框架类：</a>
对于框架其他的类，默认为私有状态，建议开发者不要随意调用，或者随意修改，在使用框架的过程中如遇任何问题和bug欢迎[联系本人](#ContactInfo)沟通商讨解决。 


<br />
### <a name="4.2.8">自定义错误信息：</a>
JSCoreBridge在以下三种情况下默认会以key `resCode`和`resMsg`给Web返回对应的code码和错误信息：  

* 插件无法找到时返回错误信息字典:   

```objective-c
    @{@"resCode": @"4001", @"resMsg": @"ERROR: Plugin 'PluginName' not found, or is not a JSCPlugin. Check your plugin mapping in config.xml."}
```  

> 出现此种情况原因可能是Web传错了插件名，或者客户端没有对应的插件，或者是使用了`config.xml`但是插件白名单当中并没有添加该插件。  


* 插件无法调用时返回错误信息字典:  

```objective-c
    @{@"resCode": @"4002", @"resMsg": @"ERROR: Plugin 'PluginName' can not be called, it is not allowed."}
```  

> 出现此种情况原因在于插件方法`canCallPlugin`的返回值为NO。  


* 插件方法无法找到时返回错误信息字典:  

```objective-c
    @{@"resCode": @"4003", @"resMsg": @"ERROR: Method 'MethodName' not defined in Plugin 'PluginName'."}
```  

> 出现此种情况原因可能是Web传错了插件方法名，或者客户端并没有对应的插件方法。  

<br />
开发者可以通过定义以下宏来自定义JSCoreBridge给Web返回的错误信息的Key和Value值，代码示例：  


```objective-c
    #define JSC_KEY_RESCODE @"errCode"
    #define JSC_KEY_RESMSG @"errMsg"

    #define JSC_RESCODE_PLUGIN_NOT_FOUND @"401"
    #define JSC_RESCODE_PLUGIN_CANNOT_CALL @"402"
    #define JSC_RESCODE_METHOD_NOT_DEFINED @"403"

    #define JSC_RESMSG_PLUGIN_NOT_FOUND  @"ERROR: Plugin not found, or is not a JSCPlugin. Check your plugin mapping in config.xml."
    #define JSC_RESMSG_PLUGIN_CANNOT_CALL  @"ERROR: Plugin can not be called, it is not allowed."
    #define JSC_RESMSG_METHOD_NOT_DEFINED  @"ERROR: Method not defined in Plugin."  
```    


在返回成功和失败结果数据时建议开发者通过code和message的形式给Web返回结果信息，以便Web开发者能够通过code和message识别当前情况或者问题所在。


<br />
<a name="WebLoadOrder">网页加载回调执行顺序说明</a>
-------------------------------------------------------------
关于JSCoreBridge加载网页时，Web和Native对应回调方法的执行顺序，这里需要特别说明下：  

* **如果`jsCoreBridge.js`在html页面直接引用，如下所示：**  

```js
    <script type="text/javascript" src="jscorebridge.js"></script>
```  
各个回调的执行顺序如下：   

1. `window.onload`  
> 如果你在Web中写了该方法，将在此刻执行。  

2. `load`  
> Web监听`Window` `load`事件通知的回调，如`window.addEventListener("load", jscWindowOnLoad, false)`。如果你在Web中写了该方法，将在此刻执行。  

3. `jsCoreBridgeWebViewDidFinishLoad:`
> [JSCWebViewController](#JSCWebViewController)类中的回调方法，实为`WebView`的`webViewDidFinishLoad:`代理方法。  

4. `jsCoreBridgeWillReady:`
> [JSCWebViewController](#JSCWebViewController)类中JSCoreBridge即将准备就绪时的回调  

5. `deviceready`
> Web监听JSCoreBridge已准备就绪的通知回调

6. `jsCoreBridgeDidReady:`
> [JSCWebViewController](#JSCWebViewController)类中JSCoreBridge准备就绪之后的回调   


<br />
* **如果`jsCoreBridge.js`是在别的JS通过appendChild的方式加入，如下所示：**   

```js
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'jscorebridge/jscorebridge.js';
    var head = document.getElementsByTagName('head')[0];
    head.appendChild(script);
```   

各个回调的执行顺序如下：  

1. `jsCoreBridgeWebViewDidFinishLoad:`
2. `window.onload`  
3. `jscWindowOnLoad`（`load`）  
4. `jsCoreBridgeWillReady:`
5. `deviceready`
6. `jsCoreBridgeDidReady:`  

> 与第一种情况不同的是，当`jsCoreBridge.js`通过代码的方式加入后，`WebView`并不会等待`jsCoreBridge.js`加载完再回调`webViewDidFinishLoad:`。  
> 通过测试可以发现，所有JS在`window.onload`或者`load`监听事件回调中就已经加载完毕，如果是第二种执行顺序，在实现上JSCoreBridge选择在`load`监听事件回调里发送`deviceready`通知。不选择`window.onload`的原因在于，如果客户端向`JSContext`中添加`window.onload`方法，那么对于Web开发人员来说他如果再写了`window.onload`方法，该方法将不再调用。  
> 对于第一种执行顺序，JSCoreBridge是直接在`webViewDidFinishLoad:`代理方法中发送`deviceready`通知，因为此时`load`监听事件回调已完成，在`webViewDidFinishLoad:`中可直接获取到`jsCoreBridge.js`的`jsCoreBridge`对象。


开发者可参考以上两种情况的执行顺序来决定自己在开发中如何在各个回调中处理相应事情。  

<br />
<a name="4.4">Cordova用法兼容性</a>
-------------------------------------------------------------
JSCoreBridge基于Cordova修改，不管是Web平台还是Native平台都保留了其原始的使用方法：  

* 在Web平台，依然可以通过`cordova.exec(successFuction, failFuntion, 'pluginName', 'methodName', [params])`方式调用，同时新增jsCoreBridge对象调用的方式，新增`jsCoreBridge.execSync`同步方法。  
* 在Native平台，`config.xml`配置方式与Cordova的一致，只是删减了部分配置选项；Plugin插件方法的编写也保持与Cordova一致，新增同步插件方法，唯一的区别在于各个相关联的类名都对应修改成JSCoreBridge框架的类，并在实现上可能稍做修改。  
* 如果你想使用更兼容Cordova用法的JSCoreBridge，可以使用0.1.1版本中新增的JSCCordova。JSCCordova并不包含在`JSCoreBridge` Pod库中，需单独Pod `JSCCordova`库。JSCCordova的用意在于最大化的去兼容Cordova的用法，如果开发者已经在使用Cordova，在将Cordova替换为JSCoreBridge时又不想修改太多源代码，JSCCordova此时就发挥了其很大的作用。当然，需要说明的一点是，使用JSCCordova并不一定能保证你的代码完全不用不修改，由于JSCoreBridge在实现上的差异，开发者在使用Cordova API的差异，以及本身JSCCordova也并没有完全兼容Cordova所有接口等这些原因，开发者在引入JSCCordova时，可能会出现相应的报错，但是，开发者解决这些报错也并不是一件难事。


<br />
:warning: <a name="5">风险声明</a>
-------------------------------------------------------------
* JSCoreBridge框架通过KVC的方式`[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"]`，从webView当中获取`JSContext`，有涉嫌使用苹果私有API的嫌疑，虽然该方法在网上被大量应用而没有遭到苹果拒绝，但本人无法保证能够100%通过审核，如果您对该问题有所介意，请评估风险后再使用。  
> JSCoreBridge会一直跟进和更新，之后有更好的实现方法，会第一时间来屏蔽该风险。  

* 本框架虽然已进行过多次自测，但是并未进行大范围的试用，避免不了会有未知的bug产生，如果您使用本框架，由于未知bug所导致的风险需要您自行承担。  
> 欢迎各位使用者给本人反馈在使用中遇到的各种问题和bug。  


<br />
=============================================================  

<a name="6">开源说明</a>
-------------------------------------------------------------
JSCoreBridge框架是本人在深入了解[Apache Cordova](http://cordova.apache.org/)后在它的基础上修改封装的，本着开源的思想，现上传至[GitHub](https://github.com/iPhuan/JSCoreBridge.git)，并提供CocoaPods支持，之后会一直跟进更新，如果您在使用本框架，欢迎及时反馈您在使用过程中遇到的各种问题和bug，也欢迎大家跟本人沟通和分享更多互联网技术。iPhuan更多开源资源将会不定期的更新至 [iPhuanLib](https://github.com/iPhuan/iPhuanLib.git)  


<br />
<a name="ContactInfo">如何联系我</a>
-------------------------------------------------------------  
邮箱：iphuan@qq.com  
QQ：519310392  

> 添加QQ时请备注JSCoreBridge


<br />
<br />
<br />
<a name="UpdateInfo">版本更新记录</a>
=============================================================  

### [V0.1.0](https://github.com/iPhuan/JSCoreBridge/tree/0.1.0)
更新日期：2017年2月18日  
更新说明：  
> * 发布JSCoreBridge第一个版本。  
  
-------------------------------------------------------------  

### [V0.1.1](https://github.com/iPhuan/JSCoreBridge/tree/0.1.1)
更新日期：2017年2月19日  
更新说明：  
> * 新增JSCCordova，JSCCordova能帮助JSCoreBridge更兼容Cordova用法。  

文档相应介绍：[点击查看](#4.4)  
  
------------------------------------------------------------- 









