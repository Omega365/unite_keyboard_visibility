import 'package:flutter/material.dart';
import 'package:unite_keyboard_visibility/unite_keyboard_visibility.dart';

class CurrentVisibilityText extends StatelessWidget {
  const CurrentVisibilityText({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, status, child) {
        return Text(
          status.name,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        );
      },
    );
  }
}
