# SpatialConnect iOS, Android and Mobile Web sample apps

## Android

To debug and deploy the example Android application, we recommend that
you use [Android
Studio](http://developer.android.com/tools/debugging/debugging-studio.html) but you may use any JDWP-compliant debugger.  For debugging the spatialconnect-android-sdk or the Android example app code, you must have an AVD (Android Virtual Device) or an actual device running Android.  For more info, see [the official docs](http://developer.android.com/tools/debugging/index.html).

To debug the WebView, including code from the [spatialconnect-js](https://github.com/boundlessgeo/spatialconnect-js) library, you must put the device in developer mode and enable USB debugging.  From there, you can use Chrome DevTools to debug like you normally would for a web page.  For specific instructions, see [the official docs](https://developers.google.com/web/tools/chrome-devtools/debug/remote-debugging/remote-debugging).

## Javascript

While you can only debug code using the Javascript bridge on a device, sometimes
it is useful to run example code locally.  For that, you can use
webpack's dev server:

```
cd web/
webpack-dev-server --progress --colors --watch
``` 

Then you can visit http://localhost:8080/webpack-dev-server/ 

## iOS

To debug and deploy the example Android application, we recommend that
you use XCode. Adding the iOS SpatialConnect library as a local resource in your Podfile will load it into XCode as a development Pod and let you develop your app and debug/extend SpatialConnect.

For Development Pods use `:path`
```
pod 'spatialconnect', :path => '~/Documents/SpatialConnect'
```

To debug the WebView, including code from the [spatialconnect-js](https://github.com/boundlessgeo/spatialconnect-js) library, you must select the webview from the `Develop` menu in Safari.app. The page must already be loaded before you can attach the debugger. You can refresh the page in the debugger to test the bridge loading phase. 
