import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Material App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String title = 'Tap the screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GestureDetector(
          child: Container(
            color: Colors.white,
          ),
          onTap: () {
            setState(() {
              title = DateTime.now().toIso8601String();
            });
          }),
    );
  }
}

/// how setState(fn) works?
///
/// `final Object? result = fn() as dynamic;`
/// - `setState()` calls my function as [dynamic].
/// - function cannot be [Future].
///
/// `_element!.markNeedsBuild();`
/// - [StatefulElement] needs to be rebuild.
///
