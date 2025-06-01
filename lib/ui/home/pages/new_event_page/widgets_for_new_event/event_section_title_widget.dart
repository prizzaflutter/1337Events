import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildSectionTitle(BuildContext context, String title, IconData icon) {
  return Row(
    children: [
      Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      const SizedBox(width: 8),
      Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    ],
  );
}
