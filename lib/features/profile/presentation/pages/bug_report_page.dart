import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pokedex_app/core/theme/app_colors.dart';
import 'package:pokedex_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:pokedex_app/l10n/generated/app_localizations.dart';
import 'package:pokedex_app/shared/widgets/app_button.dart';
import 'package:pokedex_app/shared/widgets/app_text_field.dart';
import 'package:pokedex_app/shared/widgets/safe_page_body.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class const BugReportPage({super.key}) extends ConsumerStatefulWidget {
  @override
  ConsumerState<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends ConsumerState<BugReportPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _picker = ImagePicker();

  Uint8List? _imageBytes;
  String? _imageName;
  String? _imageContentType;
  String? _messageError;
  var _loading = false;
  var _didPrefill = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context);
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }

      final name = file.name.toLowerCase();
      final contentType = name.endsWith('.png')
          ? 'image/png'
          : name.endsWith('.webp')
          ? 'image/webp'
          : 'image/jpeg';

      setState(() {
        _imageBytes = bytes;
        _imageName = file.name.isEmpty ? 'bug-report.jpg' : file.name;
        _imageContentType = contentType;
      });
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.helpBugReportPickImageError)),
      );
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _messageError = l10n.helpBugReportMessageRequired);
      return;
    }

    setState(() {
      _loading = true;
      _messageError = null;
    });

    try {
      Hint? hint;
      final bytes = _imageBytes;
      if (bytes != null) {
        hint = Hint.withScreenshot(
          SentryAttachment.fromUint8List(
            bytes,
            _imageName ?? 'bug-report.jpg',
            contentType: _imageContentType ?? 'image/jpeg',
          ),
        );
      }

      await Sentry.captureFeedback(
        SentryFeedback(
          message: message,
          name: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
          contactEmail: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        ),
        hint: hint,
      );

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.helpBugReportSuccess),
          backgroundColor: AppColorsLight.primary,
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/profile/help');
      }
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.helpBugReportSubmitError)),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authProvider);

    if (!_didPrefill) {
      _didPrefill = true;
      final displayName = auth.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) {
        _nameController.text = displayName;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpBugReportTitle)),
      body: SafePageBody.belowAppBar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l10n.helpBugReportNameLabel,
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.helpBugReportEmailLabel,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.helpBugReportMessageLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                minLines: 4,
                maxLines: 8,
                onChanged: (_) {
                  if (_messageError != null) {
                    setState(() => _messageError = null);
                  }
                },
                decoration: InputDecoration(
                  hintText: l10n.helpBugReportMessageHint,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  errorText: _messageError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.helpBugReportAttachmentLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (_imageBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _loading
                      ? null
                      : () => setState(() {
                          _imageBytes = null;
                          _imageName = null;
                          _imageContentType = null;
                        }),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: Text(l10n.helpBugReportRemoveImage),
                ),
              ] else
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pickImage,
                  icon: const Icon(Icons.photo_library_outlined, size: 20),
                  label: Text(l10n.helpBugReportAttachImage),
                ),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.helpBugReportSubmit,
                onPressed: _loading ? null : _submit,
                isLoading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
