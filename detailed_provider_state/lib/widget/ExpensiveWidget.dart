import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/ExpensiveObject.dart';
import '../provider/ObjectProvider.dart';

class ExpensiveWidget extends StatelessWidget {
  const ExpensiveWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expensiveObject =
        context.select<ObjectProvider, ExpensiveObject>(
      (provider) => provider.expensiveObject,
    );
    print('ExpensiveWidget');
    return Container(
      height: 100,
      color: Colors.orange,
      child: Column(
        children: [
          const Text('Expensive Widget'),
          const Text('Last updated'),
          Text(expensiveObject.lastUpdated),
        ],
      ),
    );
  }
}
