import 'package:flutter/material.dart';

import '../debug/debug_logger.dart';

/// アプリ全体のエラーダイアログ表示サービス
class AppErrorHandlerDialog {
  Future<void> showErrorAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    required bool isExitApp,
  }) async {
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // バックボタンでのダイアログ表示クローズを抑止します。
          return PopScope(
            canPop: false,
            // PosScopeの用途がバックボタンのキャセルのみなら onPopInvoke は不要です。
            onPopInvokedWithResult: (bool didPop, _) {
              debugLog('debug - onPopInvokedWithResult - didPop=$didPop');
            },
            child: AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(child: Text(message)),
              // Apple human interface よりアプリを終了させるのはユーザです。
              // Androidアプリの SystemNavigator.pop() はプロセス終了でないため
              // Recent App List に残ったタスクの消去はユーザ操作となります。
              // このためiOS/Android でのアプリ終了は、ユーザに依頼するのでボタンはありません。
              actions: <Widget>[
                if (!isExitApp)
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
              ],
            ),
          );
        },
      );
    }
  }
}
