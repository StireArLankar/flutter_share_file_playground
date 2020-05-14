import 'package:flutter/material.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription _subscription;
  String _sharedText;
  String _parsedPath;

  void updateState(String str) {
    setState(() {
      _sharedText = str;
      _parsedPath = str != null ? Uri.decodeFull(str).split(':').last : null;
      print(_parsedPath);
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

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textStyleBold = const TextStyle(fontWeight: FontWeight.bold);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text("Shared urls/text:", style: textStyleBold),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5.0),
                  child: Text(_sharedText ?? ""),
                  color: Colors.red[100],
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(5.0),
                  child: Text(_parsedPath ?? ""),
                  color: Colors.red[100],
                ),
                Expanded(
                  child: ListView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
