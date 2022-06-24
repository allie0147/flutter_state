import 'dart:collection';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

/// Providers are usually [ChangeNotifier] instances in the [Provider] package
/// Very similar to how Flutter itself manages state

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        title: 'Material App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
        routes: {
          '/new': (context) => const NewBreadCrumbWidget(),
        },
      ),
    ),
  );
}

class BreadCrumb {
  bool _isActive;
  final String name;
  final String uuid;

  BreadCrumb({
    required bool isActive,
    required this.name,
  })  : _isActive = isActive,
        uuid = const Uuid().v4();

  void activate() {
    _isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;
  // _isActive == other._isActive && name == other.name;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (_isActive ? '>' : '');

  bool get isActive => _isActive;
}

class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];

  /// read-only
  UnmodifiableListView<BreadCrumb> get items =>
      UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

typedef OnBreadCrumbTapped = void Function(BreadCrumb);

class BreadCrumbsWidget extends StatelessWidget {
  final OnBreadCrumbTapped onBreadCrumbTapped;
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbsWidget(
      {Key? key,
      required this.breadCrumbs,
      required this.onBreadCrumbTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map(
        (breadCrumb) {
          return GestureDetector(
            onTap: () {
              onBreadCrumbTapped(breadCrumb);
            },
            child: Text(
              breadCrumb.title,
              style: TextStyle(
                  color: breadCrumb.isActive
                      ? Colors.blue
                      : Colors.black),
            ),
          );
        },
      ).toList(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final selectedValue = context.select<ValueClass, ValueType>((ValueClass value) => value.specificValue) : select() 사용 시점
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Consumer<BreadCrumbProvider>(
            builder: (context, provider, child) {
              return BreadCrumbsWidget(
                breadCrumbs: provider.items,
                onBreadCrumbTapped: (breadCrumb) {
                  dev.log('bread crumb on tapped');
                },
              );
            },
          ),
          TextButton(
            onPressed: () => {
              Navigator.of(context).pushNamed(
                '/new',
              ),
            },
            child: const Text('Add new bread crumb'),
          ),
          TextButton(
            onPressed: () {
              // get provider
              final provider = context.read<BreadCrumbProvider>();
              provider.reset();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({Key? key}) : super(key: key);

  @override
  State<NewBreadCrumbWidget> createState() =>
      _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new bread crumb'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter a new bread crumb here...',
            ),
          ),
          TextButton(
            onPressed: () {
              final text = _controller.text;
              if (text.isNotEmpty) {
                final breadCrumb = BreadCrumb(
                  isActive: false,
                  name: text,
                );
                context.read<BreadCrumbProvider>().add(breadCrumb);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// [Provider]
///
/// 1. `select()`
/// - 지정한 aspect of Provider 가져와 aspect가 변할때 재빌드 되도록 함.
/// - build method 안에서만 쓰여야 함. (callback event 안에서는 쓰면 안된다고 함.)
/// - Provider가 update event를 방출할때, ** 모든 'selector'를 동기적으로 부름. **
/// - 만약, 이전값과 새로운값이 다르다면 (update가 되었다면) rebuild하도록 mark함.
/// - used to watch a specific aspect of a [Provider]
/// - marks a specific Widget as needing to be rebuilt
/// - ** must be used only inside the `build` method of a Widget. **
///
/// - When a provider emits an update, it will call synchronously all `selector`.
/// - Then, if they return a value different from the previously returned value,
///   the dependent will be marked as needing to rebuild.
///
/// - behave like InheritedModel
/// - '=='
///
/// 2. `read()`
/// - same as `Provider.of<T>(this, listen: false);`
/// - get snapshot of provider
/// - Not make widget rebuild when the value changes
/// - Cannot be called inside [StatelessWidget]/[State.build()].
/// - freely called _outside_ of these methods.
/// - **DON'T** call [read] inside build if the value is used only for events.: anti-pattern
/// - **DON'T** use [read] for creating widgets with a value that never changes.
/// - This method can be freely passed to objects, so that they can read providers
/// - without having a reference on a [BuildContext]. : use [Locator] which is a typedef to make it easier to pass [read] to objects.
///
/// 3. `watch()`
/// - build method 안에서만 쓰여야 함. (callback event 안에서는 쓰면 안된다고 함.) => use [read]
/// - same as `Provider.of<T>(this);`
/// - marks the widget as needing to be rebuilt if the [Provider] changes.
/// - allows `optional` [Provider]
/// - accessible only inside [StatelessWidget.build()]/[State.build()].
/// - If you need to use it outside of these methods, consider using [Provider.of()].
/// - similar to [read] but
///
/// 4. `Provider.of<T>`
/// - use it outside of `build()`
///
/// 5. `Consumer`
/// - 하나의 `build()`에서 Provider를 생성하고, 소비해야 하는 상황에서 사용.
/// - type of [Provider], has a `build()`
/// - It just calls [Provider.of] in a new widget, and delegates its `build` implementation to [builder].
/// - has a child [Widget] that ** doesn't get rebuilt when the [Provider] changes. **
/// - [builder] must not be null and may be called multiple times (such as when the provided value change).
///
/// ** two main purpose **
/// 1. It allows obtaining a value from a provider when we don't have a
///   [BuildContext] that is a descendant of said provider, and therefore
///   cannot use [Provider.of]. => BuildContext에 Provider가 만들어지지 않았을 경우(error [ProviderNotFoundException]이 발생)에 사용:
/// 2. It helps with performance optimization by providing more granular rebuilds. => Rebuild specific Widget, not All Widgets
