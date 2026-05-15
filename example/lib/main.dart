import 'package:atrust_flutter/atrust_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                AtrustFlutter.initSDK();
              },
              child: const Text('初始化SDK'),
            ),
            ElevatedButton(
              onPressed: () {
                AtrustFlutter.authenticate(
                  'https://221.11.50.211:10987',
                  'zhangke ',
                  'Hxtx@123',
                );
              },
              child: const Text('认证'),
            ),
            ElevatedButton(
              onPressed: () {
                AtrustFlutter.logout();
              },
              child: const Text('注销'),
            )
          ],
        ),
      ),
    );
  }
}
