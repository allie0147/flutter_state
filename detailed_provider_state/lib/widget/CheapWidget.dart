import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/CheapObject.dart';
import '../provider/ObjectProvider.dart';

class CheapWidget extends StatelessWidget {
  const CheapWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cheapObject = context.select<ObjectProvider, CheapObject>(
      (provider) => provider.cheapObject,
    );
    print('CheapWidget');
    return Container(
      height: 100,
      color: Colors.blue,
      child: Column(
        children: [
          const Text('Cheap Widget'),
          const Text('Last updated'),
          Text(cheapObject.lastUpdated),
        ],
      ),
    );
  }
}
