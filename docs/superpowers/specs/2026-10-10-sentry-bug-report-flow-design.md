# Sentry Bug Report Flow

## Goal

Use the in-app Sentry feedback form as the only bug-reporting path from the Help page.

## Design

The Help page keeps its existing Sentry feedback action and removes the support-email action. The Sentry action remains conditional on crash reporting being enabled, so debug builds and builds without a DSN do not expose a button that cannot submit feedback. The support copy is updated to describe the in-app report path.

The Sentry SDK configuration is unchanged: the existing feedback form remains responsible for collecting and sending the report, including the current optional name and email fields and Sentry user context.

The English and Brazilian Portuguese email-only localization keys are removed from the ARB sources and generated localization output is regenerated. The existing Help page widget test is updated to assert the Sentry-only support UI.

## Validation

- Run the Help page widget test.
- Run `flutter analyze`.
- Run the full `flutter test` suite.
- Review the final diff to confirm there are no `url_launcher` or email-report references left in the Help page.
