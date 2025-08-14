import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Appをインポートする
import 'src/app/app.dart';

void main() {
  // Appウィジェットを使用する
  runApp(const ProviderScope(child: App()));
}
