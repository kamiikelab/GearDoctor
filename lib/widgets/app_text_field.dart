import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void hideAppKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
  SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
}

/// 完了（チェック）で閉じ、欄の外をタップしても閉じる。
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.decoration,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled,
    this.minLines,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool? enabled;
  final int? minLines;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final multiline = (maxLines ?? 1) > 1 || (minLines ?? 1) > 1;
    return TextField(
      controller: controller,
      decoration: decoration,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscureText,
      enabled: enabled,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: onChanged,
      textInputAction: multiline ? TextInputAction.newline : TextInputAction.done,
      onSubmitted: multiline ? null : (_) => hideAppKeyboard(),
      onEditingComplete: multiline ? null : hideAppKeyboard,
      onTapOutside: (_) => hideAppKeyboard(),
    );
  }
}
