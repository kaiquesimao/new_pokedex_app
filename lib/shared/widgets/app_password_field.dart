import 'package:flutter/material.dart';
import 'package:pokedex_app/core/constants/app_assets.dart';

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.label,
    this.controller,
    this.errorText,
  });

  final String label;
  final TextEditingController? controller;
  final String? errorText;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            errorText: widget.errorText,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            suffixIcon: IconButton(
              icon: Image.asset(
                _obscure
                    ? AppAssets.passwordEyeClosed
                    : AppAssets.passwordEyeOpen,
                width: 24,
                height: 24,
                errorBuilder: (_, _, _) =>
                    Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
