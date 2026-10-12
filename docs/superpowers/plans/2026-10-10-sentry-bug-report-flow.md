# Sentry Bug Report Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the Sentry feedback form the only bug-reporting path on the Help page.

**Architecture:** Keep Sentry initialization and feedback configuration unchanged. Remove the Help page's `url_launcher` dependency and email action, update localized support copy and generated output, and preserve the existing runtime guard around `SentryFeedbackForm.show`.

**Tech Stack:** Flutter, Dart, `sentry_flutter`, Flutter localization ARB generation, `flutter_test`.

## Global Constraints

- Code and user-facing copy must remain in the repository's supported English and Brazilian Portuguese locales.
- Do not expose the bug-report action when crash reporting is disabled.
- Do not change Sentry event collection, privacy, or feedback-form configuration beyond the Help page entry point.

---

### Task 1: Replace the Help page support action

**Files:**
- Modify: `lib/features/profile/presentation/pages/help_page.dart`
- Modify: `test/features/profile/presentation/pages/help_page_test.dart`
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_pt.arb`
- Regenerate: `lib/l10n/generated/app_localizations.dart`
- Regenerate: `lib/l10n/generated/app_localizations_en.dart`
- Regenerate: `lib/l10n/generated/app_localizations_pt.dart`

- [ ] Remove the `url_launcher` import, support-email constant, email button, and `_openSupportEmail` helper from `help_page.dart`.
- [ ] Keep the guarded `SentryFeedbackForm.show(context)` button as the sole support action.
- [ ] Update `helpSupportBody` in both ARB files to describe reporting a problem through the in-app form.
- [ ] Remove only the email-specific localization keys and regenerate localization output.
- [ ] Update the Help page widget test to assert the Sentry report label and absence of the support email.
- [ ] Run `flutter test test/features/profile/presentation/pages/help_page_test.dart`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Review the diff and commit the implementation with an English message.
