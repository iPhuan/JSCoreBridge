/**
 * JSCoreBridge JS V0.1.0
 * Created by iPhuan on 16/12/9.
 * Build 20170215
 */


(function () {
    var JSCOREBRIDGE_BUILD_VERSION = '0.1.0';

    var callbackId = Math.floor(Math.random() * 2000000000);
    var callbacks = {};

    var jsCoreBridge = {
        version: JSCOREBRIDGE_BUILD_VERSION,
        exec: function (successCallback, failCallback, pluginName, methodName, args) {
            function jscExec() {
                if (utils.typeName(pluginName) != 'String' || utils.typeName(methodName) != 'String') {
                    throw new Error('pluginName or methodName is not a string');
                }

                if ((successCallback && typeof successCallback != 'function') || (failCallback && typeof failCallback != 'function')) {
                    throw new Error('successCallback or successCallback is not a function');
                }

                if (args) {
                    args = messageConvert.massageArgsJsToNative(args);
                } else {
                    args = [];
                }

                var pluginCallbackId = 'INVALID';
                if (successCallback || failCallback) {
                    pluginCallbackId = pluginName + callbackId++;
                    callbacks[pluginCallbackId] = {success: successCallback, fail: failCallback};
                }

                var command = [pluginCallbackId, pluginName, methodName, args];
                if (typeof jscExecuteCommand != 'undefined') {
                    jscExecuteCommand(command);
                } else {
                    if (failCallback) {
                        failCallback(utils.errorMessage());
                    }
                }
            }

            setTimeout(jscExec, 0);
        },
        execSync: function (pluginName, methodName, args) {
            if (utils.typeName(pluginName) != 'String' || utils.typeName(methodName) != 'String') {
                throw new Error('pluginName or methodName is not a string');
            }

            if (args) {
                args = messageConvert.massageArgsJsToNative(args);
            } else {
                args = [];
            }

            var command = ['EXECSYNC', pluginName, methodName, args];
            if (typeof jscExecuteCommand != 'undefined') {
                var result = jscExecuteCommand(command);
                var args = messageConvert.convertMessageToArgsNativeToJs(result);

                function syncResult(res) {
                    return res;
                }

                return syncResult.apply(null, args);
            } else {
                return utils.errorMessage();
            }
        },
        nativeCallback: function (callbackId, status, args, keepCallback) {
            function jscNativeCallback() {
                try {
                    args = messageConvert.convertMessageToArgsNativeToJs(args);
                    var callback = callbacks[callbackId];
                    if (callback) {
                        if (status == 0) {
                            callback.success && callback.success.apply(null, args);
                        } else {
                            callback.fail && callback.fail.apply(null, args);
                        }
                        if (!keepCallback) {
                            delete callbacks[callbackId];
                        }
                    }
                }
                catch (err) {
                    var errorMsg = "Error in " + " callbackId: " + callbackId + " : " + err;
                    console && console.log && console.log(errorMsg);
                    throw err;
                }
            }

            setTimeout(jscNativeCallback, 0);
        },
        fireDocumentEvent: function (eventName) {
            function jscFireDocumentEvent() {
                if (eventName == 'deviceready' && typeof jscBridgeWillReady != 'undefined') {
                    jscBridgeWillReady();
                }

                var event = document.createEvent('Events');
                event.initEvent(eventName, false, false);
                document.dispatchEvent(event);

                if (eventName == 'deviceready' && typeof jscBridgeDidReady != 'undefined') {
                    jscBridgeDidReady();
                }
            }

            setTimeout(jscFireDocumentEvent, 0);
        }
    };


    var utils = {
        b64_6bit: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
        b64_12bit: [],
        b64_12bitTable: function () {
            this.b64_12bit = [];
            for (var i = 0; i < 64; i++) {
                for (var j = 0; j < 64; j++) {
                    this.b64_12bit[i * 64 + j] = b64_6bit[i] + b64_6bit[j];
                }
            }
            b64_12bitTable = function () {
                return this.b64_12bit;
            };
            return this.b64_12bit;
        },
        uint8ToBase64: function (rawData) {
            var numBytes = rawData.byteLength;
            var output = "";
            var segment;
            var table = this.b64_12bitTable();
            for (var i = 0; i < numBytes - 2; i += 3) {
                segment = (rawData[i] << 16) + (rawData[i + 1] << 8) + rawData[i + 2];
                output += table[segment >> 12];
                output += table[segment & 0xfff];
            }
            if (numBytes - i == 2) {
                segment = (rawData[i] << 16) + (rawData[i + 1] << 8);
                output += table[segment >> 12];
                output += b64_6bit[(segment & 0xfff) >> 6];
                output += '=';
            } else if (numBytes - i == 1) {
                segment = (rawData[i] << 16);
                output += table[segment >> 12];
                output += '==';
            }
            return output;
        },
        fromArrayBuffer: function (arrayBuffer) {
            var array = new Uint8Array(arrayBuffer);
            return this.uint8ToBase64(array);
        },
        typeName: function (val) {
            return Object.prototype.toString.call(val).slice(8, -1);
        },
        errorMessage: function () {
            var errorMsg = 'ERROR: Plugin can not be called. because JSCoreBridge have no running environment';
            console && console.log && console.log(errorMsg);
            return {resCode: '4000', resMsg: errorMsg};
        }
    };


    var messageConvert = {
        massageArgsJsToNative: function (args) {
            if (!args || utils.typeName(args) != 'Array') {
                return args;
            }
            var ret = [];
            args.forEach(function (arg, i) {
                if (utils.typeName(arg) == 'ArrayBuffer') {
                    ret.push({
                        'CDVType': 'ArrayBuffer',
                        'data': utils.fromArrayBuffer(arg)
                    });
                } else {
                    ret.push(arg);
                }
            });
            return ret;
        },
        massageMessageNativeToJs: function (message) {
            if (message.CDVType == 'ArrayBuffer') {
                var stringToArrayBuffer = function (str) {
                    var ret = new Uint8Array(str.length);
                    for (var i = 0; i < str.length; i++) {
                        ret[i] = str.charCodeAt(i);
                    }
                    return ret.buffer;
                };
                var base64ToArrayBuffer = function (b64) {
                    return stringToArrayBuffer(atob(b64));
                };
                message = base64ToArrayBuffer(message.data);
            }
            return message;
        },
        convertMessageToArgsNativeToJs: function (message) {
            var args = [];
            if (!message || !message.hasOwnProperty('CDVType')) {
                args.push(message);
            } else if (message.CDVType == 'MultiPart') {
                message.messages.forEach(function (e) {
                    args.push(this.massageMessageNativeToJs(e));
                });
            } else {
                args.push(this.massageMessageNativeToJs(message));
            }
            return args;
        }
    };

    window.cordova = jsCoreBridge;
    window.jsCoreBridge = jsCoreBridge;
})();