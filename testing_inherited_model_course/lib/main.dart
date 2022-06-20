import 'dart:developer' as devtools;
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter demo',
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
  var _color1 = Colors.yellow;
  var _color2 = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: AvailableColorsWidget(
        color1: _color1,
        color2: _color2,
        child: Column(
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(
                        () => _color1 = colors.getRandomElement());
                  },
                  child: const Text('Change color1'),
                ),
                TextButton(
                  onPressed: () {
                    setState(
                        () => _color2 = colors.getRandomElement());
                  },
                  child: const Text('Change color2'),
                ),
              ],
            ),
            // DI
            const ColorWidget(color: AvailableColors.one),
            const ColorWidget(color: AvailableColors.two),
          ],
        ),
      ),
    );
  }
}

final colors = [
  Colors.blue,
  Colors.red,
  Colors.yellow,
  Colors.pink,
  Colors.green,
  Colors.brown,
  Colors.orange,
  Colors.deepPurple,
];

final color = colors.getRandomElement();

extension RandomElement<T> on Iterable<T> {
  T getRandomElement() => elementAt(
        Random().nextInt(length),
      );
}

enum AvailableColors {
  one,
  two,
}

class AvailableColorsWidget extends InheritedModel<AvailableColors> {
  final MaterialColor color1;
  final MaterialColor color2;

  const AvailableColorsWidget({
    Key? key,
    required this.color1,
    required this.color2,
    required Widget child,
  }) : super(
          key: key,
          child: child,
        );

  /// Flutter decides whether any descendant has to be rebuilt
  /// by calling `updateShouldNotify()`
  @override
  bool updateShouldNotify(covariant AvailableColorsWidget oldWidget) {
    /// oldWidget에서 color이 달라졌을 경우에만 update 하도록 정의.
    devtools.log('updateShouldNotify');
    return color1 != oldWidget.color1 || color2 != oldWidget.color2;
  }

  /// If `updateShouldNotify()` return true, Flutter calls `updateShouldNotifyDependent()`.
  @override
  bool updateShouldNotifyDependent(
    covariant AvailableColorsWidget oldWidget,
    Set<AvailableColors> dependencies,
  ) {
    devtools.log('updateShouldNotifyDependent $dependencies');
    if (dependencies.contains(AvailableColors.one) &&
        color1 != oldWidget.color1) {
      return true;
    }
    if (dependencies.contains(AvailableColors.two) &&
        color2 != oldWidget.color2) {
      return true;
    }
    return false;
  }

  /// allow descendants grabbing a copy of [AvailableColorsWidget]
  /// used only by children Widgets
  static AvailableColorsWidget? of(
    BuildContext context,
    AvailableColors aspect,
  ) {
    return InheritedModel.inheritFrom<AvailableColorsWidget>(context,
        aspect: aspect);
  }
}

class ColorWidget extends StatelessWidget {
  final AvailableColors color; // dependency

  const ColorWidget({
    Key? key,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (color) {
      case AvailableColors.one:
        devtools.log('color1 widget got rebuilt');
        break;
      case AvailableColors.two:
        devtools.log('color2 widget got rebuilt');
        break;
    }

    final provider = AvailableColorsWidget.of(context, color);
    if (provider != null) {
      return Container(
        height: 100,
        color: color == AvailableColors.one
            ? provider.color1
            : provider.color2,
      );
    }
    return Container();
  }
}
