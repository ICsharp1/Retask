import 'package:flutter/material.dart';

class StepRadioButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onSelect;

  const StepRadioButton({
    super.key,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: Colors.orange,
      ),
      onPressed: onSelect,
    );
  }
}
