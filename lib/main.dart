import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// MyApppをインポートする
import 'src/app/my_app.dart';

void main() {
  // MyAppウィジェットを使用する
  runApp(const ProviderScope(child: MyApp()));
}
