import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 統計アイテム用のウィジェット
class StatItem extends StatelessWidget {
  const StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    super.key,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('value', value));
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ColorProperty('color', color));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
