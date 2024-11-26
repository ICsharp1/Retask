import 'package:flutter/material.dart';

class StepRadioButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onSelect;
  final Color activeColor;

  const StepRadioButton({
    super.key,
    required this.isSelected,
    required this.onSelect,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: activeColor,
      ),
      onPressed: onSelect,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 20,
    );
  }
}
