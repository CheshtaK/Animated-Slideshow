import 'package:flutter/material.dart';
import 'package:him/slideshow.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final PageController ctrl = PageController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Slideshow(),
    ));
  }
}
