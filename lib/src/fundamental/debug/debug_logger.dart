// このソースファイルは、FlutterKaigi mini#2 @Ishikawa プロジェクト・ライブラリの流用です。
// https://github.com/cch-robo/Flutter_plain_infra_mini_hands-on/blob/main/lib/src/infra/debug_logger.dart

import 'package:flutter/foundation.dart';

import '../error/default_error.dart';

class DebugLog {
  static bool isDebugMode = true;
}

/// デバッグ出力
///
/// アプリがデバックモード([kDebugMode] == true)かつ
/// [DebugLog.isDebugMode]が true または [cause]が null でない
/// ときのみ [message]が出力されます。
///
/// - [message] : 出力メッセージ
/// - [info] : （オプション）パラメータ型を明示して出力元情報補助を行います。<br/>
/// - [cause] : （オプション）エラーまたは例外型を明示して出力元情報補助を行います。<br/>
/// _[Error]型が指定されていた場合は、[StackTrace]出力も伴います。_
void debugLog(String message, {Object? info, Object? cause}) {
  if ((DebugLog.isDebugMode || cause != null) && kDebugMode) {
    debugPrint(createDebugOutText(message, info: info, cause: cause));
  }
}

String createDebugOutText(String message, {Object? info, Object? cause}) {
  if ((DebugLog.isDebugMode || cause != null) && kDebugMode) {
    final StringBuffer sb = StringBuffer();
    // メッセージ表示
    if (info != null) {
      sb.write('${info.runtimeType.toString()}: $message');
    } else {
      sb.write(message);
    }

    // リカーシブル・エラー表示
    bool isLoop = cause != null;
    while (isLoop) {
      isLoop = false;
      if (cause is DefaultAbnormal) {
        sb.write('\n${cause.runtimeType.toString()}: ${cause.message}');
        sb.write('\n${cause.stackTrace?.toString() ?? ""}');
        cause = cause.hasError
            ? cause.error
            : cause.hasException
            ? cause.exception
            : null;
        isLoop = true;
      } else {
        sb.write('\n${cause.runtimeType.toString()}: ${cause.toString()}');
        if (cause is Error) {
          sb.write('\n${cause.stackTrace?.toString() ?? ""}');
        }
      }
    }

    return sb.toString();
  }
  return '';
}
