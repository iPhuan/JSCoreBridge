/**
 * JSCoreBridge Demo
 * Created by iPhuan on 2017/2/13.
 * Build 20170215
 */

var app = {
    buttonTag: 0,
    message: 'none',
    initialize: function () {
        // 监听客户端JSCoreBridge已准备就绪
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
        // 监听客户端已经进入后台
        document.addEventListener('pause', this.onPause.bind(this), false);
        // 监听客户端即将要进入前台
        document.addEventListener('resume', this.onResume.bind(this), false);
    },

    onDeviceReady: function () {
        this.bindButtonEvent();

        var params = {title: 'JSCoreBridge Demo'};
        // 兼容cordova用法; 成功和失败函数可传空
        // 如果你希望在js加载后立即调用插件，请确保调用插件是在deviceready后执行，不要企望客户端对应插件方法会在jsCoreBridgeDidReady之前调用，jsCoreBridge.exec为异步操作，除非你使用jsCoreBridge.execSync方法
        cordova.exec(null, null, 'JSCTestPlugin', 'changeNavTitle', [params]);
    },

    onPause: function () {
        this.message = 'OK';
    },

    onResume: function () {
        alert('App已从后台恢复\nApp进入后台时将message值设为：' + this.message);
    },

    bindButtonEvent: function () {
        document.querySelector('#changeNavTitle').onclick = (function () {
            var navtitle = 'JSCoreBridge 测试' + (app.buttonTag++).toString();
            var params = {title: navtitle};
            jsCoreBridge.exec(function (res) {
                app.alertMsg('改变标题成功！', res);
            }, function (err) {
                app.alertMsg('改变标题失败！', err);
            }, 'JSCTestPlugin', 'changeNavTitle', [params]);
        });

        document.querySelector('#sendEmail').onclick = (function () {
            var params = {title: 'JSCoreBridge 测试', content: '这是一封有关JSCoreBridge Demo的测试邮件。'};
            jsCoreBridge.exec(function (res) {
                if (res.errCode) {
                    alert('操作成功！')
                } else {
                    switch (res.mailComposeResult) {
                        case 0:
                            app.alertMsg('邮件被取消！', res);
                            break;
                        case 1:
                            app.alertMsg('邮件被保存！', res);
                            break;
                        case 2:
                            app.alertMsg('邮件已发送！', res);
                            break;
                        case 3:
                            app.alertMsg('邮件发送失败！', res);
                            break;
                    }
                }
            }, function (err) {
                app.alertMsg('发送邮件失败！', err);
            }, 'JSCTestPlugin', 'sendEmail', [params]);
        });

        document.querySelector('#getAppVersionSync').onclick = (function () {
            // 同步获取数据
            var version = jsCoreBridge.execSync('JSCTestPlugin', 'getAppVersionSync', null);
            if (typeof version == 'string') {
                alert('version:' + version);
            } else {
                app.alertMsg('获取版本号失败！', version);
            }
        });
    },

    alertMsg: function (title, res) {
        var str = JSON.stringify(res);
        alert(title + '\n' + str);
    }
};

app.initialize();
