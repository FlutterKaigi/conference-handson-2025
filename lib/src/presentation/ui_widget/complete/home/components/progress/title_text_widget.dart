import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// タイトルテキストウィジェット
///
/// ハンズオン学習ポイント:
/// - Theme.of(context)によるテーマカラーの活用
/// - TextStyleのcopyWithによるスタイルのカスタマイズ
/// - maxLinesとoverflowによるテキスト制御
class TitleTextWidget extends StatelessWidget {
  /// コンストラクタ
  ///
  /// [title] 表示するタイトルテキスト
  /// [primaryColor] タイトルの色
  const TitleTextWidget({
    required this.title,
    required this.primaryColor,
    super.key,
  });

  /// タイトルテキスト
  final String title;

  /// プライマリカラー（タイトルの色）
  final Color primaryColor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(ColorProperty('primaryColor', primaryColor));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title.isNotEmpty ? title : '読書記録',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: primaryColor,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
