import 'package:flutter/material.dart';

class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tag;

  const AppFloatingActionButton({
    super.key,
    required this.tag,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: tag,
      onPressed: onPressed,
      elevation: 0.5,
      child: const Icon(Icons.add),
    );
  }
}