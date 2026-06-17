import 'package:flutter/material.dart';

class BottomSheetHeader extends StatelessWidget {
  const BottomSheetHeader({required this.title, super.key, this.onClear});

  final String title;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (onClear != null)
            TextButton(onPressed: onClear, child: const Text('Limpar')),
        ],
      ),
    );
  }
}
