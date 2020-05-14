import 'dart:io';
import 'package:xml/xml.dart' as xml;
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
  Future<String> _firstString;
  xml.XmlDocument _document;

  void updateState(String str) {
    setState(() {
      _sharedText = str;
      _parsedPath = str != null ? Uri.decodeFull(str).split(':').last : null;
      print(_parsedPath);

      if (_parsedPath == null) return;

      final extension = _parsedPath.split('.').last;

      if (extension != 'fb2') return;

      final file = File(_parsedPath);

      _firstString = file.readAsString().then((value) {
        setState(() => _document = xml.parse(value));
        final result = value.split('\n').sublist(0, 1).join('\n\n');
        return Future.delayed(Duration(seconds: 5), () => result);
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
                SizedBox(height: 10),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      buildLoader(),
                      buildReader(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  FutureBuilder<String> buildLoader() {
    return FutureBuilder<String>(
      future: _firstString,
      builder: (ctx, snapshot) {
        Widget child;

        if (snapshot.hasData) {
          child = Text(snapshot.data);
        } else if (snapshot.hasError) {
          child = Text('Error: ${snapshot.error}');
        } else {
          child = CircularProgressIndicator();
        }

        return Padding(
          child: child,
          padding: EdgeInsets.all(5.0),
        );
      },
    );
  }

  Widget buildReader() {
    if (_document == null) return Container();

    final info = _document.findAllElements('title-info').first;

    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: info != null ? Text(info.toXmlString()) : Text(''),
        ),
      ),
    );
  }
}
