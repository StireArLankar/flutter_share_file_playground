# flutter_share_file_playground

## Flutter project for recieving android intents for file opening.

Added permisions for reading / writing storage  
Changed launch mode from `singleTop` to `singleInstance` for single instance of app

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.flutter_share_file_playground">
    /// permissions ///
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

    <application
        android:name="io.flutter.app.FlutterApplication"
        android:label="Share File Playground"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            --- singleTop - singleInstance ---
            android:theme="@style/LaunchTheme"
            android:launchMode="singleInstance"
            android:theme="@style/LaunchTheme"
            android:configChanges="..."
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>

            /// intent for file opening ///
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="*/*" />
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

In flutter code import [receive_sharing_intent](https://flutter.dev/docs/get-started/codelab) package  
Base message looks like `content://com.android.providers.downloads.documents/document/raw%3A%2Fstorage%2Femulated%2F0%2FDownload%2Fgardar.fb2`  
To get correct path (`/storage/emulated/0/Download/gardar.fb2`) for future file opening use `Uri.decodeFull(text).split(':').last`

```dart
...
  void updateState(String str) {
    setState(() {
      _sharedText = str;
      _parsedPath = str != null ? Uri.decodeFull(str).split(':').last : null;
      print(_parsedPath);

      if (_parsedPath == null) return;

      final file = File(_parsedPath);

      Future<String> _result_ = file.readAsString().then((value) {
        return value.split('\n')[0]
      }).catchError(print);
    });
  }

  @override
  void initState() {
    super.initState();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _subscription = ReceiveSharingIntent.getTextStream().listen((value) {
      updateState(value);
      print("Mounted: $_sharedText");
    }, onError: (err) => print("getLinkStream error: $err"));

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((value) {
      updateState(value);
      print("Initial: $_sharedText");
    });
  }
...
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
