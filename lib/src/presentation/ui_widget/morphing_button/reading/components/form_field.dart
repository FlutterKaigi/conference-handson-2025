import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// フォームフィールド用のウィジェット
/// 共通のテキストフィールドUIを生成
class FormField extends StatelessWidget {
  const FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.prefixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final IconData? prefixIcon;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<TextEditingController>('controller', controller),
    );
    properties.add(StringProperty('label', label));
    properties.add(StringProperty('hint', hint));
    properties.add(
      ObjectFlagProperty<String? Function(String?)?>.has(
        'validator',
        validator,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextInputType?>('keyboardType', keyboardType),
    );
    properties.add(
      IterableProperty<TextInputFormatter>('inputFormatters', inputFormatters),
    );
    properties.add(IntProperty('maxLines', maxLines));
    properties.add(DiagnosticsProperty<IconData?>('prefixIcon', prefixIcon));
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
    );
  }
}
