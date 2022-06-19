import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Material App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      // DI
      home: ApiProvider(
        api: Api(),
        child: const HomePage(),
      ),
    ),
  );
}

// InheritedWidget is immutable
class ApiProvider extends InheritedWidget {
  final Api api;
  final String uuid;

  ApiProvider({
    Key? key,
    required this.api,
    required Widget child,
  })  : uuid = const Uuid().v4(),
        super(
          key: key,
          child: child,
        );

  // Add dependency
  static ApiProvider of(BuildContext context) {
    final ApiProvider? result =
        context.dependOnInheritedWidgetOfExactType<ApiProvider>();
    assert(result != null, 'No ApiProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant ApiProvider oldWidget) {
    return uuid != oldWidget.uuid;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueKey _textKey = const ValueKey<String?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ApiProvider.of(context).api.dateAndTime ?? ''),
      ),
      body: GestureDetector(
          child: SizedBox.expand(
            child: Container(
              color: Colors.white,
              child: DateTimeWidget(
                key: _textKey,
              ),
            ),
          ),
          onTap: () async {
            final api = ApiProvider.of(context).api;
            final dateAndTime = await api.getDateAndTime();
            setState(() {
              _textKey = ValueKey(dateAndTime);
            });
          }),
    );
  }
}

/// how setState(fn) works?
///
/// `final Object? result = fn() as dynamic;`
/// - [setState();] calls my function as [dynamic].;
/// - function cannot be [Future].
///
/// `_element!.markNeedsBuild();`
/// - [StatefulElement] needs to be rebuild.
///

class DateTimeWidget extends StatelessWidget {
  const DateTimeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get access to Api
    final api = ApiProvider.of(context).api;
    return Text(
      api.dateAndTime ?? 'Tap on screen to fetch date and time.',
    );
  }
}

class Api {
  String? dateAndTime;

  Future<String> getDateAndTime() {
    return Future.delayed(
      const Duration(seconds: 1),
      () => DateTime.now().toIso8601String(),
    ).then((value) {
      dateAndTime = value;
      return value;
    });
  }
}
