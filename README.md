# WatchWitch iOS Companion

Swift companion app for the WatchWitch tweak, allowing export of Apple Watch keys and rerouting of WiFi communication.

## Usage

Make sure the [WatchWitch iOS tweak](https://github.com/rec0de/watchwitch-ios) is installed on your iPhone.

Make sure [Theos](https://theos.dev/docs/) is installed on your computer. Dependencies and version incompatibilities can be tricky on linux, macOS might work more smoothly.

You will also need [Cephei](https://hbang.github.io/libcephei/) installed on your iPhone. To use Cephei with Swift, you may have to copy the [module maps](modulemaps) to your `$THEOS/vendor/lib` folder, e.g. `cp modulemaps/Cephei/* $THEOS/vendor/lib/Cephei.framework/Modules`.

Install the app:
```
make package install
```

Open the app, you should see the tweak start time being displayed indicating that communication between the tweak and the app is working as intended.

Enter the WiFi IP address of your Android phone running [WatchWitch Android](https://github.com/rec0de/watchwitch-android), then tap 'Set Target IP' to confirm.

With the Android app running, tap "Send Keys". A 'got keys!' message should appear on your Android phone.

Enable the WiFi address override, and force an address update if you like. When losing Bluetooth connection, your watch will now connect to your Android phone instead of your iPhone.
