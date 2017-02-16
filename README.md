<!--
# iPhuan Open Source
# JSCoreBridge
# Created by iPhuan on 2017/2/16.
# Copyright © 2017年 iPhuan. All rights reserved.
-->

JSCoreBridge
=============================================================
JSCoreBridge是基于iOS平台Apache Cordova修改的开源框架，Cordova的用处在于作为桥梁通过插件的方式实现了Web与Native之间的通信，而JSCoreBridge参考其进行删减修改，移除了在平时用不上的类和方法，改写了其传统的通信机制，在保留了Cordova实用的功能前提下，精简优化了框架占用大小，并且省去了繁琐的工程设置选项，通过的新的实现方式大大提供了通信效率。JSCoreBridge开源框架力在为开发者提供更便捷的Hybird开发体验。


用途
-------------------------------------------------------------
适用于Hybird开发者，希望通过JSCoreBridge框架实现客户端Web与Native之间的交互与通信。


通信原理
-------------------------------------------------------------
### Cordova通信原理：<br />

1. Web创建自定义scheme “`gap://ready`”，并响应链接跳转事件；
2. Cordova通过WebView代理方法`webView:shouldStartLoadWithRequest:navigationType`截获该gap跳转
3. Cordova通过WebView `stringByEvaluatingJavaScriptFromString`方法执行Cordova JS方法`nativeFetchMessages`获取Web当前的命令参数并转化为`CDVInvokedUrlCommand`对象；
4. Cordova根据`CDVInvokedUrlCommand`对象的`className`和`methodName`属性找到对应插件和对应的插件方法，并执行插件方法；
5. Cordova执行完插件方法后如需给Web返回数据结果，则再次通过WebView `stringByEvaluatingJavaScriptFromString`方法执行Cordova JS方法`nativeCallback`，通过`CDVInvokedUrlCommand`的`callbackId`将结果发送给Web对应的回调。

### JSCoreBridge通信原理：<br />

不在使用传统的scheme链接跳转截取和`stringByEvaluatingJavaScriptFromString`执行JS的方法，通过iOS7新增的**`JavaScriptCore.framework`**来实现JS和Native之间的通信。

1. Web调用`jsCoreBridge.js`的`exec`或者`execSync`方法直接将命令参数传给客户端；
2. JSCoreBridge将命令参数转化为`JSCInvokedPluginCommand`对象；
3. JSCoreBridge根据`JSCInvokedPluginCommand`对象的`className`和`methodName`属性找到对应插件和对应的插件方法，并执行插件方法；
4. JSCoreBridge执行完插件方法后如需给Web返回数据结果，直接调用`jsCoreBridge.js`的`nativeCallback`方法，通过`JSCInvokedPluginCommand`的`callbackId`将结果发送给Web对应的回调。


如何获取JSCoreBridge
-------------------------------------------------------------
1. 直接在GitHub上[获取](https://github.com/iPhuan/JSCoreBridge.git)
2. 通过CocoaPods添加到工程：<br />

> * 如果你想使用完整版的JSCoreBridge，添加以下命令行到Podfile：<br />

```ruby
    pod 'JSCoreBridge'
```

> * 如果你想使用Lite版的JSCoreBridge，添加以下命令行到Podfile：<br />

```ruby
    pod 'JSCoreBridge/JSCoreBridgeLite'
```

注：Lite版的JSCoreBridge将不使用`config.xml`进行功能选项配置，JSCoreBridgeLite仅仅实现了最基本的通信功能。
  


使用说明
=============================================================

JSCoreBridge Web平台
-------------------------------------------------------------
### jsCoreBridge.js存放说明：<br />

* jsCoreBridge.js本身在工程当中，如打开的html文件在bundle中，可直接引用，当然如果你的html文件在bundle的子目录下，你希望jsCoreBridge.js和你的网页目录在同一级，你也可以将jsCoreBridge.js拷贝到该同级目录；
* 如果你的html文件存储在沙盒，你务必要把jsCoreBridge.js拷贝到沙盒；
* 如果你的网页在远程网站上，那么你同样的需要将jsCoreBridge.js放到里的远程网站上；
jsCoreBridge.js的使用原则在于，保证你的html文件能够引用到。


### jsCoreBridge.js接口说明：<br />

jsCoreBridge.js对应于Cordova的cordova.js通过`jsCoreBridge`对象来调用，也兼容Cordova用法，可以通过`cordova`对象调用，jsCoreBridge接口如下：

* **`jsCoreBridge.version`** // 获取当前JSCoreBridge Web平台JS版本号<br />
> 客户端JSCoreBridge框架对jsCoreBridge.js有最低版本要求，Pod到工程的jsCoreBridge.js相对于当前客户端jsCoreBridge框架都是最新的版本，可放心使用，如果你自行从其他途径下载jsCoreBridge.js，请保证该版本能够兼容客户端jsCoreBridge框架。

* **`jsCoreBridge.exec`** // 执行客户端对应插件方法<br />
> 通过该方法可以告诉客户端JSCoreBridge框架通过对应插件的对应方法去执行相应的事情，代码示例如下：

```javascript
    var params = {title: 'JSCoreBridge Demo'};

    jsCoreBridge.exec(function (res) {
    // 成功回调
    }, function (err) {
    // 失败回调
    }, 'JSCTestPlugin', 'changeNavTitle', [params]);
```

   > - 第一个函数为成功回调，第二个函数为失败回调，通过res和err获取结果数据，当然如果你不想收到回调，这两个参数你可以传空，如果你不希望接收res和err结果数据，回调函数你也可以不用带参数；
   > - `JSCTestPlugin`为客户端对应的插件Plugin类名；
   > - `changeNavTitle`为JSCTestPlugin插件中对应的插件方法；
   > - 最后一个参数则为Web传给客户端的参数，通过数组的方式传递，至于数组里面传递什么样的数据，由开发者自行决定，当然该参数你也可以传空或者不传。

* **`jsCoreBridge.execSync`** // 同步执行客户端对应插件方法<br />
> 与exec接口不同的是该方法为同步操作，所有没有成功与失败回调函数，其代码示例如下：

```javascript
    var version = jsCoreBridge.execSync('JSCTestPlugin', 'getAppVersionSync', null);
```

* **`deviceready`** // JSCoreBridge已准备好监听事件<br />
> 可通过以下示例代码来监听JSCoreBridge准备完成：<br />

```javascript
    document.addEventListener('deviceready', onDeviceReady, false)
```
:warning: 注意：为了保证客户端插件方法能够正确执行，请保证在deviceready执行后调用jsCoreBridge对象的方法；

* **`pause`** // 客户端已经进入后台监听事件<br />
> 可通过以下示例代码来监听客户端已经进入后台：

```javascript
    document.addEventListener('pause', onPause, false)
```

* **`resume`** // 客户端即将进入前台监听事件<br />
> 可通过以下示例代码来监听客户端即将进入前台：

```javascript
    document.addEventListener('resume', onResume, false)
```



JSCoreBridge Native平台
-------------------------------------------------------------





通过CocoaPods将JSCoreBridge Pod到工程，如需用到config.xml，请在`JSCoreBridge/optional`目录下将config.xml复制到其他目录并添加到工程使用；




