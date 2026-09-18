import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:secure_document_manager/core/constants/app_colors.dart';

class VerificationCodeField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const VerificationCodeField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<VerificationCodeField> createState() =>
      _VerificationCodeFieldState();
}

class _VerificationCodeFieldState extends State<VerificationCodeField> {
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);

    for (final node in _focusNodes) {
      node.dispose();
    }

    super.dispose();
  }

  void _onChanged(String value, int index) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      _updateCode(index, '');
      return;
    }

    final digit = digits[0];

    final currentCode = widget.controller.text.padRight(6).split('');
    currentCode[index] = digit;

    final newCode = currentCode.join().trim();

    widget.controller.value = TextEditingValue(
      text: newCode,
      selection: TextSelection.collapsed(
        offset: newCode.length,
      ),
    );

    widget.onChanged?.call(newCode);

    if (index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else {
      _focusNodes[index].unfocus();
    }
  }

  void _updateCode(int index, String value) {
    final currentCode = widget.controller.text.padRight(6).split('');
    currentCode[index] = value;

    final newCode = currentCode.join().trim();

    widget.controller.value = TextEditingValue(
      text: newCode,
      selection: TextSelection.collapsed(
        offset: newCode.length,
      ),
    );

    widget.onChanged?.call(newCode);
  }

  void _onKeyPressed(
    RawKeyEvent event,
    int index,
  ) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        index > 0 &&
        _getDigit(index).isEmpty) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getDigit(int index) {
    final code = widget.controller.text;

    if (index >= code.length) {
      return '';
    }

    return code[index];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index == 5 ? 0 : 8,
            ),
            child: SizedBox(
              width: 45,
              height: 58,
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (event) {
                  _onKeyPressed(event, index);
                },
                child: TextField(
                  controller: TextEditingController(
                    text: _getDigit(index),
                  ),
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.purple,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _onChanged(value, index);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}