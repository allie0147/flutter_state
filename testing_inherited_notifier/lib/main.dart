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

/// State manager
/// 변화 감지
class SliderData extends ChangeNotifier {
  double _value = 0.0;

  set value(double newValue) {
    if (newValue != _value) {
      _value = newValue;
      notifyListeners();
    }
  }

  double get value => _value;
}

final sliderData = SliderData();

/// If state changes,[InheritedNotifier] listens to [ChangeNotifier] and actually rebuild its child(`value` of the [ChangeNotifier]).
///
/// Difference between [InheritedNotifier] and [InheritedWidget]
/// [InheritedNotifier] is dependent of [ChangeNotifier] or [ValueNotifier] which implements [Listenable] and holds on to its values.
/// [InheritedWidget] holds on to its own values. No dependent of [Notifiers].
class SliderInheritedNotifier extends InheritedNotifier<SliderData> {
  const SliderInheritedNotifier({
    Key? key,
    required SliderData sliderData,
    required Widget child,
  }) : super(
          key: key,
          notifier: sliderData,
          child: child,
        );

  static double of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<
                SliderInheritedNotifier>()
            ?.notifier
            ?.value ??
        0.0;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // 홈페이지가 빌드될때, buildcontext가 생성되는 시점에는 SliderInheritedNotifier가 없다.
  // 그래서 BuildContext가 생긴 이후에 SliderInheritedNotifier가 만들어져야 함.
  // Builder를 쓰지 않는다면, BuildContext가 생기기 전의 context로 SliderInheritedNotifier를 만듬.
  // Builder를 사용하여 초기 BuildContext가 아닌 그 이후의 BuildContext를 가져와서 SliderInheritedNotifier을 만들어줌.

  // Widget build(BuildContext context) {}  1번 context는 SliderInheritedNotifier가 만들어지기 전에 생성되어 SliderInheritedNotifier가 존재하지 않음.
  //   child: Builder(
  //           builder: (context) {} 2번 context는 body: SliderInheritedNotifier()가 실행된 이후의 context를 가져오기 때문에 SliderInheritedNotifier가 존재함.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: SliderInheritedNotifier(
        sliderData: sliderData,

        /// using [Builder] to include [SliderInheritedNotifier] which must be created after [BuildContext]
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                Slider(
                  // SliderInheritedNotifier.of(`context`)
                  // `context` must use new context of Builder which contains [SliderInheritedNotifier]
                  value: SliderInheritedNotifier.of(context),
                  onChanged: (value) {
                    sliderData.value = value;
                  },
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Opacity(
                      opacity: SliderInheritedNotifier.of(context),
                      child: Container(
                        color: Colors.yellow,
                        width: 100,
                        height: 200,
                      ),
                    ),
                    Opacity(
                      opacity: SliderInheritedNotifier.of(context),
                      child: Container(
                        color: Colors.blue,
                        width: 100,
                        height: 200,
                      ),
                    ),
                  ].expandEqually().toList(),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

extension ExpandEqually on Iterable<Widget> {
  Iterable<Widget> expandEqually() => map(
        (w) => Expanded(
          child: w,
        ),
      );
}
