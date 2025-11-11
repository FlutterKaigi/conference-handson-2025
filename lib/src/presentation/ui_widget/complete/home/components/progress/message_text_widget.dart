import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// メッセージテキストウィジェット
///
/// ハンズオン学習ポイント:
/// - BoxDecorationによる装飾的なコンテナデザイン
/// - withValuesを使った透明度制御
/// - BorderRadius.circularによる角丸表現
/// - Border.allによる枠線の追加
class MessageTextWidget extends StatelessWidget {
  /// コンストラクタ
  ///
  /// [message] 表示するメッセージテキスト
  /// [primaryColor] メッセージの背景とボーダーの色
  const MessageTextWidget({
    required this.message,
    required this.primaryColor,
    super.key,
  });

  /// メッセージテキスト
  final String message;

  /// プライマリカラー（背景とボーダーの色）
  final Color primaryColor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
    properties.add(ColorProperty('primaryColor', primaryColor));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          message,
          style: TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
