import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/model/my_counter_value_object.dart';
import '../../presentation/model/my_counter_view_model.dart';

const Key detailPageCountKey = Key('detail_count');

class MyDetailPage extends ConsumerWidget {
  const MyDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CountValueObject model = ref.watch(counterProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Count Detail Page'), // AppBar title
      ),
      body: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '${model.count}\n',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium, //DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: 'state type - ${model.stateType}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
          key: detailPageCountKey,
        ),
      ),
    );
  }
}
