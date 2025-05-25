import 'package:flutter/material.dart';
import 'package:windchime/services/utils/sound_utils.dart';

//Creates FilterButton Widget

class FilterButton extends StatefulWidget {
  final String filter;
  final Color color;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.filter,
    required this.color,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        widget.onPressed();
        playSound('todo/sounds/click.mp3');
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateColor.resolveWith((
          Set<WidgetState> states,
        ) {
          return widget.isSelected ? widget.color : Colors.white;
        }),
        foregroundColor: WidgetStateColor.resolveWith((
          Set<WidgetState> states,
        ) {
          return widget.isSelected ? Colors.white : widget.color;
        }),
      ),
      child: Text(widget.filter, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
