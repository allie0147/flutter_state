import 'dart:collection';

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
          '/new': (context) => const Material(),
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
  UnmodifiableListView<BreadCrumb> get item =>
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

class BreadCrumbsWidget extends StatelessWidget {
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbsWidget({Key? key, required this.breadCrumbs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map(
        (breadCrumb) {
          return Text(
            breadCrumb.title,
            style: TextStyle(
                color:
                    breadCrumb.isActive ? Colors.blue : Colors.black),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () => {
              Navigator.of(context).pushNamed('/new'),
            },
            child: const Text('Add new bread crumb'),
          ),
          TextButton(
            onPressed: () => {},
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
