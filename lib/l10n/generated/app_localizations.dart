import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// Bottom nav: Pokédex tab
  ///
  /// In en, this message translates to:
  /// **'PokeData'**
  String get navPokedex;

  /// No description provided for @navRegions.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get navRegions;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// Help FAQ: changing app language
  ///
  /// In en, this message translates to:
  /// **'How do I change the language?'**
  String get profileHelpLanguageQuestion;

  /// Help FAQ: single app language toggle in profile
  ///
  /// In en, this message translates to:
  /// **'In Account → Language, tap \"App language\" to switch between Portuguese and English.'**
  String get profileHelpLanguageAnswer;

  /// No description provided for @typeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get typeNormal;

  /// No description provided for @typeFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get typeFire;

  /// No description provided for @typeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get typeWater;

  /// No description provided for @typeElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get typeElectric;

  /// No description provided for @typeGrass.
  ///
  /// In en, this message translates to:
  /// **'Grass'**
  String get typeGrass;

  /// No description provided for @typeIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get typeIce;

  /// No description provided for @typeFighting.
  ///
  /// In en, this message translates to:
  /// **'Fighting'**
  String get typeFighting;

  /// No description provided for @typePoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get typePoison;

  /// No description provided for @typeGround.
  ///
  /// In en, this message translates to:
  /// **'Ground'**
  String get typeGround;

  /// No description provided for @typeFlying.
  ///
  /// In en, this message translates to:
  /// **'Flying'**
  String get typeFlying;

  /// No description provided for @typePsychic.
  ///
  /// In en, this message translates to:
  /// **'Psychic'**
  String get typePsychic;

  /// No description provided for @typeBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get typeBug;

  /// No description provided for @typeRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get typeRock;

  /// No description provided for @typeGhost.
  ///
  /// In en, this message translates to:
  /// **'Ghost'**
  String get typeGhost;

  /// No description provided for @typeDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon'**
  String get typeDragon;

  /// No description provided for @typeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get typeDark;

  /// No description provided for @typeSteel.
  ///
  /// In en, this message translates to:
  /// **'Steel'**
  String get typeSteel;

  /// No description provided for @typeFairy.
  ///
  /// In en, this message translates to:
  /// **'Fairy'**
  String get typeFairy;

  /// No description provided for @offlineBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Showing Pokémon saved on this device.'**
  String get offlineBannerMessage;

  /// No description provided for @offlineEmptyTitleConnectivity.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get offlineEmptyTitleConnectivity;

  /// No description provided for @offlineEmptyTitleError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get offlineEmptyTitleError;

  /// No description provided for @offlineRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get offlineRetryButton;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Pokémon...'**
  String get searchHint;

  /// No description provided for @otpCodeSemanticsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Verification code of '**
  String get otpCodeSemanticsPrefix;

  /// No description provided for @otpCodeSemanticsSuffix.
  ///
  /// In en, this message translates to:
  /// **' digits'**
  String get otpCodeSemanticsSuffix;

  /// No description provided for @otpResendSemantics.
  ///
  /// In en, this message translates to:
  /// **'Resend verification code'**
  String get otpResendSemantics;

  /// No description provided for @otpResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResendButton;

  /// Auth error: invalid email
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get authInvalidEmail;

  /// Auth error: user disabled
  ///
  /// In en, this message translates to:
  /// **'Account disabled'**
  String get authUserDisabled;

  /// Auth error: user not found during sign in
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find an account with this email. Create one to continue.'**
  String get authUserNotFoundSignIn;

  /// Auth error: generic user not found
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get authUserNotFound;

  /// Auth error: wrong password hint
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Try again or use \"Forgot password\".'**
  String get authWrongPassword;

  /// Auth error: email already in use (generic)
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get authEmailAlreadyInUse;

  /// Auth error: email already in use with google hint
  ///
  /// In en, this message translates to:
  /// **'This email is already in use with Google. Use \"I already have an account\" and sign in with Google.'**
  String get authEmailAlreadyInUseGoogle;

  /// Auth error: email already in use with apple hint
  ///
  /// In en, this message translates to:
  /// **'This email is already in use with Apple. Use \"I already have an account\" and sign in with Apple.'**
  String get authEmailAlreadyInUseApple;

  /// Auth error: weak password hint
  ///
  /// In en, this message translates to:
  /// **'Use between 6 and 4096 characters.'**
  String get authWeakPassword;

  /// Auth error: too many requests
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later'**
  String get authTooManyRequests;

  /// Auth error: network request failed
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet'**
  String get authNetworkRequestFailed;

  /// Auth error: requires recent login
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue'**
  String get authRequiresRecentLogin;

  /// Auth error: invalid credential email sign-in
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. If you don\'t have an account yet, tap \"Create account\".'**
  String get authInvalidCredentialEmailSignIn;

  /// Auth error: invalid credential oauth hint
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. If the problem continues, check SHA-1/SHA-256 in Firebase and download google-services.json again.'**
  String get authInvalidCredentialOauth;

  /// Auth error: account exists with different credential
  ///
  /// In en, this message translates to:
  /// **'This email is already registered with another sign-in method. Use Google, Apple or the original method.'**
  String get authAccountExistsWithDifferentCredential;

  /// Auth error: operation not allowed
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not enabled in Firebase'**
  String get authOperationNotAllowed;

  /// Auth error: generic fallback
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authGenericError;

  /// App bar title: create account
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountTitle;

  /// Form field label: email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Form field label: password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Form field label: name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authNameLabel;

  /// Register step headline: email
  ///
  /// In en, this message translates to:
  /// **'What\'s your email?'**
  String get authRegisterHeadlineEmail;

  /// Register step headline: password
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get authRegisterHeadlinePassword;

  /// Register step headline: name
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get authRegisterHeadlineName;

  /// Register subtitle: email
  ///
  /// In en, this message translates to:
  /// **'Use a valid email address.'**
  String get authRegisterSubtitleEmail;

  /// Register subtitle: name
  ///
  /// In en, this message translates to:
  /// **'This name will appear in your trainer profile.'**
  String get authRegisterSubtitleName;

  /// Primary button: continue
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinueButton;

  /// Loading: finalizing registration
  ///
  /// In en, this message translates to:
  /// **'Finalizing registration...'**
  String get authLoadingFinalizingRegistration;

  /// Loading: generic wait
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get authLoadingWait;

  /// Verify email app bar title
  ///
  /// In en, this message translates to:
  /// **'Confirm email'**
  String get authVerifyEmailTitle;

  /// Verify email headline
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get authVerifyEmailHeadline;

  /// Verify email message when link sent
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to {email}. Open the email, confirm the link and come back to continue.'**
  String authVerifyEmailLinkSent(Object email);

  /// Verify email message when code sent
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}.'**
  String authVerifyEmailCodeSent(Object email);

  /// Button: already confirmed in email
  ///
  /// In en, this message translates to:
  /// **'I already confirmed in my email'**
  String get authVerifyEmailAlreadyConfirmedButton;

  /// Button: resend email
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get authVerifyEmailResendEmail;

  /// Notice: verification email re-sent
  ///
  /// In en, this message translates to:
  /// **'A new email was sent.'**
  String get authVerifyEmailResentEmail;

  /// Notice: verification code re-sent
  ///
  /// In en, this message translates to:
  /// **'A new code was sent.'**
  String get authVerifyEmailResentCode;

  /// Loading: creating account
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get authVerifyEmailCreatingAccount;

  /// Loading: verifying
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get authVerifyEmailVerifying;

  /// Snack bar: code resent
  ///
  /// In en, this message translates to:
  /// **'Code resent.'**
  String get authForgotCodeResentSnackbar;

  /// App bar title: password reset success
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get authForgotAppBarSuccess;

  /// App bar title: email sent
  ///
  /// In en, this message translates to:
  /// **'Email sent'**
  String get authForgotAppBarEmailSent;

  /// App bar title: recover password
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get authForgotAppBarDefault;

  /// Forgot password headline: email
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotHeadlineEmail;

  /// Forgot password headline: otp
  ///
  /// In en, this message translates to:
  /// **'Confirm the code'**
  String get authForgotHeadlineOtp;

  /// Forgot password headline: new password
  ///
  /// In en, this message translates to:
  /// **'Create a new password'**
  String get authForgotHeadlineNewPassword;

  /// Forgot password subtitle: email
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a verification code.'**
  String get authForgotSubtitleEmail;

  /// Forgot password subtitle: otp
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {email}.'**
  String authForgotSubtitleOtp(Object email);

  /// Label: new password
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authForgotNewPasswordLabel;

  /// Label: confirm new password
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authForgotConfirmNewPasswordLabel;

  /// Primary button: send code
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authForgotPrimaryButtonEmail;

  /// Primary button: save new password
  ///
  /// In en, this message translates to:
  /// **'Save new password'**
  String get authForgotPrimaryButtonNewPassword;

  /// Generic processing label
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get authProcessing;

  /// App bar title: sign in
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginTitle;

  /// Login headline
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email'**
  String get authLoginHeadline;

  /// Login instructions paragraph
  ///
  /// In en, this message translates to:
  /// **'Use the email and password registered in the app. Accounts created with Google or Apple must sign in via those buttons.'**
  String get authLoginInstructions;

  /// Short text: forgot password
  ///
  /// In en, this message translates to:
  /// **'Forgot my password'**
  String get authForgotPasswordText;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginButtonLabel;

  /// Loading: signing in
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get authLoadingSigningIn;

  /// Welcome page: skip explore button
  ///
  /// In en, this message translates to:
  /// **'Explore without account'**
  String get authWelcomeSkipButton;

  /// Welcome headline question
  ///
  /// In en, this message translates to:
  /// **'Ready for this adventure?'**
  String get authWelcomeQuestion;

  /// Welcome subtitle
  ///
  /// In en, this message translates to:
  /// **'Just create an account and start exploring the world of Pokémon today!'**
  String get authWelcomeSubtitle;

  /// Welcome create account button
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authWelcomeCreateAccount;

  /// Welcome have account link
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get authWelcomeHaveAccount;

  /// Fallback trainer display name
  ///
  /// In en, this message translates to:
  /// **'Trainer'**
  String get authDefaultTrainerName;

  /// Welcome back message
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String authLoginSuccessWelcomeBack(Object name);

  /// Login success subtext
  ///
  /// In en, this message translates to:
  /// **'We hope you had a long journey since the last time you visited us.'**
  String get authLoginSuccessMessage;

  /// Button: continue after login success
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authLoginSuccessContinue;

  /// Semantics: sign in to save favorites
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favorites'**
  String get authLoginRequiredSemanticsLabel;

  /// Title: sign in to save favorites
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favorites'**
  String get authLoginRequiredTitle;

  /// Description: login required to save favorites
  ///
  /// In en, this message translates to:
  /// **'Create an account or sign in to sync your favorite Pokémon.'**
  String get authLoginRequiredDescription;

  /// Login required: sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginRequiredSignIn;

  /// Login required: create account button
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authLoginRequiredCreateAccount;

  /// Legal acceptance required message
  ///
  /// In en, this message translates to:
  /// **'Accept Terms of Use and Privacy Policy to continue.'**
  String get authLegalAcceptTerms;

  /// Spam reminder appended to verification messages
  ///
  /// In en, this message translates to:
  /// **'If you don\'t find it, check your spam or junk folder as well.'**
  String get authSpamReminder;

  /// Unverified email message
  ///
  /// In en, this message translates to:
  /// **'Email not yet verified. Open the sent link and try again. If you don\'t find it, check your spam or junk folder as well.'**
  String get authUnverifiedFirebase;

  /// Service unavailable message
  ///
  /// In en, this message translates to:
  /// **'Service unavailable. Try again later.'**
  String get authServiceUnavailable;

  /// Invalid session message
  ///
  /// In en, this message translates to:
  /// **'Invalid session'**
  String get authInvalidSession;

  /// Validation: fill email and password
  ///
  /// In en, this message translates to:
  /// **'Fill email and password'**
  String get authFillEmailAndPassword;

  /// Validation: fill all fields
  ///
  /// In en, this message translates to:
  /// **'Fill all fields'**
  String get authFillAllFields;

  /// Requires sign in to change password
  ///
  /// In en, this message translates to:
  /// **'Sign in to change the password'**
  String get authSignInToChangePassword;

  /// Requires sign in to continue
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authSignInToContinue;

  /// Google sign-in unavailable message
  ///
  /// In en, this message translates to:
  /// **'Google sign-in unavailable'**
  String get authLoginWithGoogleUnavailable;

  /// Prompt to use Google button
  ///
  /// In en, this message translates to:
  /// **'Use the Google button to sign in'**
  String get authUseGoogleButton;

  /// Apple sign-in unavailable message
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in unavailable'**
  String get authLoginWithAppleUnavailable;

  /// Apple sign-in iOS only message
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in available on iOS only'**
  String get authLoginWithAppleOnlyOnIOS;

  /// Invalid code message
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Try again.'**
  String get authInvalidCodeTryAgain;

  /// Passwords do not match error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsDoNotMatch;

  /// Prompt to enter current password
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get authEnterYourCurrentPassword;

  /// Prompt to enter your name
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get authEnterYourName;

  /// No description provided for @authDisplayNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name too long (max. {maxLength} characters).'**
  String authDisplayNameTooLong(int maxLength);

  /// Current password incorrect error
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get authCurrentPasswordIncorrect;

  /// Instruction to create account before verifying email
  ///
  /// In en, this message translates to:
  /// **'Create an account before verifying the email'**
  String get authCreateAccountBeforeVerifying;

  /// Instruction to use email link to reset password
  ///
  /// In en, this message translates to:
  /// **'Use the link sent by email to reset your password'**
  String get authUseLinkToResetPassword;

  /// Validation: new email must differ
  ///
  /// In en, this message translates to:
  /// **'The new email must be different from the current one'**
  String get authNewEmailDifferentFromCurrent;

  /// Verify email screen title for password reset
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get authForgotVerifyEmailTitle;

  /// Message: verification link sent for password reset
  ///
  /// In en, this message translates to:
  /// **'We sent a link to reset your password to {email}.'**
  String authForgotVerifyEmailSent(Object email);

  /// Button: back to login
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get authBackToLogin;

  /// Forgot password success title
  ///
  /// In en, this message translates to:
  /// **'Password reset successful!'**
  String get authForgotSuccessTitle;

  /// Forgot password success subtitle
  ///
  /// In en, this message translates to:
  /// **'Use your new password to sign in to PokeData.'**
  String get authForgotSuccessSubtitle;

  /// Register page headline
  ///
  /// In en, this message translates to:
  /// **'Almost ready to explore this world!'**
  String get authRegisterWelcomeHeadline;

  /// Register page subtitle
  ///
  /// In en, this message translates to:
  /// **'How would you like to connect?'**
  String get authRegisterSubtitle;

  /// No description provided for @profileLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileLogoutButton;

  /// Profile: logged in as
  ///
  /// In en, this message translates to:
  /// **'You are signed in as {name}.'**
  String profileLoggedInAs(Object name);

  /// No description provided for @profileMegaEvolutionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Mega evolutions'**
  String get profileMegaEvolutionsLabel;

  /// No description provided for @profileOtherFormsLabel.
  ///
  /// In en, this message translates to:
  /// **'Other forms'**
  String get profileOtherFormsLabel;

  /// No description provided for @profileNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsTitle;

  /// No description provided for @profileNotifyNewPokemon.
  ///
  /// In en, this message translates to:
  /// **'New Pokémon'**
  String get profileNotifyNewPokemon;

  /// No description provided for @profileNotifyAppUpdates.
  ///
  /// In en, this message translates to:
  /// **'App updates'**
  String get profileNotifyAppUpdates;

  /// No description provided for @profileLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageTitle;

  /// No description provided for @profileAppLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get profileAppLanguageLabel;

  /// No description provided for @profileGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get profileGeneralTitle;

  /// No description provided for @profileVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get profileVersionLabel;

  /// No description provided for @profileTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get profileTermsLabel;

  /// No description provided for @profilePrivacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacyLabel;

  /// No description provided for @profileHelpLabel.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get profileHelpLabel;

  /// No description provided for @profileAboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profileAboutLabel;

  /// No description provided for @profileActionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Action completed'**
  String get profileActionSuccess;

  /// Evolution trigger: level
  ///
  /// In en, this message translates to:
  /// **'Level {minLevel}'**
  String evolutionTriggerLevel(Object minLevel);

  /// No description provided for @evolutionTriggerTrade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get evolutionTriggerTrade;

  /// No description provided for @evolutionTriggerUseItem.
  ///
  /// In en, this message translates to:
  /// **'Use item'**
  String get evolutionTriggerUseItem;

  /// No description provided for @evolutionTriggerLevelUp.
  ///
  /// In en, this message translates to:
  /// **'Level up'**
  String get evolutionTriggerLevelUp;

  /// No description provided for @evolutionTriggerOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get evolutionTriggerOther;

  /// No description provided for @evolutionTriggerDuringDay.
  ///
  /// In en, this message translates to:
  /// **'During the day'**
  String get evolutionTriggerDuringDay;

  /// No description provided for @evolutionTriggerAtNight.
  ///
  /// In en, this message translates to:
  /// **'At night'**
  String get evolutionTriggerAtNight;

  /// Evolution trigger: holding item
  ///
  /// In en, this message translates to:
  /// **'Holding {heldItem}'**
  String evolutionTriggerHoldingItem(Object heldItem);

  /// No description provided for @statHp.
  ///
  /// In en, this message translates to:
  /// **'HP'**
  String get statHp;

  /// No description provided for @statAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get statAttack;

  /// No description provided for @statDefense.
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get statDefense;

  /// No description provided for @statSpecialAttack.
  ///
  /// In en, this message translates to:
  /// **'Sp. Atk'**
  String get statSpecialAttack;

  /// No description provided for @statSpecialDefense.
  ///
  /// In en, this message translates to:
  /// **'Sp. Def'**
  String get statSpecialDefense;

  /// No description provided for @statSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get statSpeed;

  /// No description provided for @abilityHiddenSuffix.
  ///
  /// In en, this message translates to:
  /// **' (hidden)'**
  String get abilityHiddenSuffix;

  /// No description provided for @genderNone.
  ///
  /// In en, this message translates to:
  /// **'Genderless'**
  String get genderNone;

  /// No description provided for @genderMaleOnly.
  ///
  /// In en, this message translates to:
  /// **'Male only'**
  String get genderMaleOnly;

  /// No description provided for @genderFemaleOnly.
  ///
  /// In en, this message translates to:
  /// **'Female only'**
  String get genderFemaleOnly;

  /// Gender ratio female percent
  ///
  /// In en, this message translates to:
  /// **'{percent}% female'**
  String genderFemalePercent(String percent);

  /// No description provided for @hatchNever.
  ///
  /// In en, this message translates to:
  /// **'Does not hatch from egg'**
  String get hatchNever;

  /// Egg hatch steps
  ///
  /// In en, this message translates to:
  /// **'{steps} steps'**
  String hatchSteps(String steps);

  /// No description provided for @filterTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterTypeLabel;

  /// No description provided for @filterClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filterClearButton;

  /// No description provided for @filterAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get filterAllTypes;

  /// No description provided for @filterGenerationLabel.
  ///
  /// In en, this message translates to:
  /// **'Generation'**
  String get filterGenerationLabel;

  /// No description provided for @filterAdvancedLabel.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get filterAdvancedLabel;

  /// No description provided for @filterTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Types'**
  String get filterTypesTitle;

  /// No description provided for @filterTypeSemantics.
  ///
  /// In en, this message translates to:
  /// **'Pokémon type filter'**
  String get filterTypeSemantics;

  /// No description provided for @filterAdvancedTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get filterAdvancedTitle;

  /// No description provided for @filterWeaknessTitle.
  ///
  /// In en, this message translates to:
  /// **'Weakness'**
  String get filterWeaknessTitle;

  /// No description provided for @filterHeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get filterHeightTitle;

  /// No description provided for @filterWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get filterWeightTitle;

  /// No description provided for @filterSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get filterSortTitle;

  /// No description provided for @filterSortSemantics.
  ///
  /// In en, this message translates to:
  /// **'Pokémon list sort order'**
  String get filterSortSemantics;

  /// No description provided for @filterNoPokemonFound.
  ///
  /// In en, this message translates to:
  /// **'No Pokémon found'**
  String get filterNoPokemonFound;

  /// No description provided for @sortNumberAsc.
  ///
  /// In en, this message translates to:
  /// **'Lowest number'**
  String get sortNumberAsc;

  /// No description provided for @sortNumberDesc.
  ///
  /// In en, this message translates to:
  /// **'Highest number'**
  String get sortNumberDesc;

  /// No description provided for @sortNameAsc.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortNameAsc;

  /// No description provided for @sortNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get sortNameDesc;

  /// No description provided for @heightBucketSmall.
  ///
  /// In en, this message translates to:
  /// **'Short (< 1 m)'**
  String get heightBucketSmall;

  /// No description provided for @heightBucketMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium (1–2 m)'**
  String get heightBucketMedium;

  /// No description provided for @heightBucketLarge.
  ///
  /// In en, this message translates to:
  /// **'Tall (> 2 m)'**
  String get heightBucketLarge;

  /// No description provided for @weightBucketLight.
  ///
  /// In en, this message translates to:
  /// **'Light (< 10 kg)'**
  String get weightBucketLight;

  /// No description provided for @weightBucketMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium (10–100 kg)'**
  String get weightBucketMedium;

  /// No description provided for @weightBucketHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy (> 100 kg)'**
  String get weightBucketHeavy;

  /// No description provided for @generationPicker.
  ///
  /// In en, this message translates to:
  /// **'Generation {roman}'**
  String generationPicker(Object roman);

  /// No description provided for @generationFallback.
  ///
  /// In en, this message translates to:
  /// **'Generation {id}'**
  String generationFallback(int id);

  /// No description provided for @regionGenerationBadgeEn.
  ///
  /// In en, this message translates to:
  /// **'GEN {roman}'**
  String regionGenerationBadgeEn(Object roman);

  /// No description provided for @regionGenerationBadgePt.
  ///
  /// In en, this message translates to:
  /// **'{number}ª GENERATION'**
  String regionGenerationBadgePt(int number);

  /// No description provided for @favoritesGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'You need to sign in to do this.'**
  String get favoritesGuestTitle;

  /// No description provided for @favoritesGuestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'To access this feature, sign in or create an account. Do it now!'**
  String get favoritesGuestSubtitle;

  /// No description provided for @favoritesGuestAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in or register'**
  String get favoritesGuestAction;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You have not favorited any Pokémon :('**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on your favorite Pokémon and they will appear here.'**
  String get favoritesEmptySubtitle;

  /// No description provided for @favoritesRemovedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from favorites'**
  String favoritesRemovedSnackbar(Object name);

  /// No description provided for @pokemonDetailEvolutions.
  ///
  /// In en, this message translates to:
  /// **'Evolutions'**
  String get pokemonDetailEvolutions;

  /// No description provided for @pokemonDetailNoEvolution.
  ///
  /// In en, this message translates to:
  /// **'This Pokémon does not evolve.'**
  String get pokemonDetailNoEvolution;

  /// No description provided for @pokemonDetailStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get pokemonDetailStats;

  /// No description provided for @pokemonDetailWeaknesses.
  ///
  /// In en, this message translates to:
  /// **'Weaknesses'**
  String get pokemonDetailWeaknesses;

  /// No description provided for @detailWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get detailWeight;

  /// No description provided for @detailHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get detailHeight;

  /// No description provided for @detailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get detailCategory;

  /// No description provided for @detailAbility.
  ///
  /// In en, this message translates to:
  /// **'Ability'**
  String get detailAbility;

  /// No description provided for @detailGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get detailGender;

  /// Semantics: flavor text MT in progress
  ///
  /// In en, this message translates to:
  /// **'Translating description...'**
  String get flavorTextTranslating;

  /// No description provided for @favoriteAddSemantics.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favoriteAddSemantics;

  /// No description provided for @favoriteRemoveSemantics.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoriteRemoveSemantics;

  /// No description provided for @authContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get authContinueWithEmail;

  /// No description provided for @legalAcceptPrefix.
  ///
  /// In en, this message translates to:
  /// **'I have read and accept the '**
  String get legalAcceptPrefix;

  /// No description provided for @legalAcceptMiddle.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get legalAcceptMiddle;

  /// No description provided for @legalLoadTermsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the terms of use.'**
  String get legalLoadTermsError;

  /// No description provided for @legalLoadPrivacyError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the privacy policy.'**
  String get legalLoadPrivacyError;

  /// No description provided for @helpFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get helpFaqTitle;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportBody.
  ///
  /// In en, this message translates to:
  /// **'Did not find what you need? Send your question or issue report to our team.'**
  String get helpSupportBody;

  /// No description provided for @helpEmailOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the email app.'**
  String get helpEmailOpenError;

  /// No description provided for @helpEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'PokeData Support'**
  String get helpEmailSubject;

  /// No description provided for @helpExploreGuestQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I explore without an account?'**
  String get helpExploreGuestQuestion;

  /// No description provided for @helpExploreGuestAnswer.
  ///
  /// In en, this message translates to:
  /// **'On the welcome screen, tap \"Explore without account\" to browse the Pokédex, regions, and Pokémon details without signing in.'**
  String get helpExploreGuestAnswer;

  /// No description provided for @helpFavoriteQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I favorite Pokémon?'**
  String get helpFavoriteQuestion;

  /// No description provided for @helpFavoriteAnswer.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon in the list or on the detail page. You must sign in to save and sync favorites across devices.'**
  String get helpFavoriteAnswer;

  /// No description provided for @helpFilterQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I filter the Pokémon list?'**
  String get helpFilterQuestion;

  /// No description provided for @helpFilterAnswer.
  ///
  /// In en, this message translates to:
  /// **'On the Pokédex tab, use the search bar and filters by type and generation to refine the results.'**
  String get helpFilterAnswer;

  /// No description provided for @helpMegaFormsQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are mega evolutions and other forms?'**
  String get helpMegaFormsQuestion;

  /// No description provided for @helpMegaFormsAnswer.
  ///
  /// In en, this message translates to:
  /// **'In Account → PokeData, use the toggles to show or hide mega evolutions and alternate forms in the list.'**
  String get helpMegaFormsAnswer;

  /// No description provided for @helpOfflineQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does the app work offline?'**
  String get helpOfflineQuestion;

  /// No description provided for @helpOfflineAnswer.
  ///
  /// In en, this message translates to:
  /// **'Recently visited data may appear from local cache. An internet connection is required to search new Pokémon or refresh information.'**
  String get helpOfflineAnswer;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String aboutVersion(Object version, Object build);

  /// No description provided for @aboutVersionLoading.
  ///
  /// In en, this message translates to:
  /// **'Version …'**
  String get aboutVersionLoading;

  /// No description provided for @aboutVersionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Version unavailable'**
  String get aboutVersionUnavailable;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'A fan-made Pokédex to explore Pokémon, regions, favorites, and details with up-to-date PokéAPI data.'**
  String get aboutTagline;

  /// No description provided for @aboutDevelopedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get aboutDevelopedBy;

  /// No description provided for @aboutAcknowledgments.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgments'**
  String get aboutAcknowledgments;

  /// No description provided for @aboutCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get aboutCredits;

  /// No description provided for @aboutKaiqueTitle.
  ///
  /// In en, this message translates to:
  /// **'Kaique Simão'**
  String get aboutKaiqueTitle;

  /// No description provided for @aboutKaiqueBody.
  ///
  /// In en, this message translates to:
  /// **'Creator and developer of PokeData.'**
  String get aboutKaiqueBody;

  /// No description provided for @aboutJuniorTitle.
  ///
  /// In en, this message translates to:
  /// **'Junior Saraiva'**
  String get aboutJuniorTitle;

  /// No description provided for @aboutJuniorBody.
  ///
  /// In en, this message translates to:
  /// **'Created the Figma Community design that served as the visual reference for this project.'**
  String get aboutJuniorBody;

  /// No description provided for @aboutLinkedInProfile.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn profile'**
  String get aboutLinkedInProfile;

  /// No description provided for @aboutFigmaProject.
  ///
  /// In en, this message translates to:
  /// **'Figma project'**
  String get aboutFigmaProject;

  /// No description provided for @aboutCreditPokeApiTitle.
  ///
  /// In en, this message translates to:
  /// **'PokéAPI'**
  String get aboutCreditPokeApiTitle;

  /// No description provided for @aboutCreditPokeApiBody.
  ///
  /// In en, this message translates to:
  /// **'Pokémon, species, type, and evolution data.'**
  String get aboutCreditPokeApiBody;

  /// No description provided for @aboutCreditFlutterTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter'**
  String get aboutCreditFlutterTitle;

  /// No description provided for @aboutCreditFlutterBody.
  ///
  /// In en, this message translates to:
  /// **'Cross-platform app framework.'**
  String get aboutCreditFlutterBody;

  /// No description provided for @aboutCreditFirebaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase'**
  String get aboutCreditFirebaseTitle;

  /// No description provided for @aboutCreditFirebaseBody.
  ///
  /// In en, this message translates to:
  /// **'Authentication, favorites, and cloud sync.'**
  String get aboutCreditFirebaseBody;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'PokeData is an unofficial fan app. It is not developed, endorsed, or affiliated with Nintendo, Creatures Inc., GAME FREAK, or The Pokémon Company. Pokémon © Nintendo / Creatures Inc. / GAME FREAK.'**
  String get aboutDisclaimer;

  /// No description provided for @errorNetworkOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNetworkOffline;

  /// No description provided for @errorGenericRetry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGenericRetry;

  /// No description provided for @errorLoadDataWithStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not load data ({statusCode}). Try again.'**
  String errorLoadDataWithStatus(int statusCode);

  /// No description provided for @errorLoadPokemonList.
  ///
  /// In en, this message translates to:
  /// **'Could not load the Pokémon list'**
  String get errorLoadPokemonList;

  /// No description provided for @errorLoadPokemon.
  ///
  /// In en, this message translates to:
  /// **'Could not load the Pokémon'**
  String get errorLoadPokemon;

  /// No description provided for @errorLoadRegions.
  ///
  /// In en, this message translates to:
  /// **'Could not load the regions'**
  String get errorLoadRegions;

  /// No description provided for @errorLoadRegion.
  ///
  /// In en, this message translates to:
  /// **'Could not load the region'**
  String get errorLoadRegion;

  /// No description provided for @errorLoadPokedex.
  ///
  /// In en, this message translates to:
  /// **'Could not load the Pokédex'**
  String get errorLoadPokedex;

  /// No description provided for @errorLoadGeneration.
  ///
  /// In en, this message translates to:
  /// **'Could not load the generation'**
  String get errorLoadGeneration;

  /// No description provided for @errorLoadType.
  ///
  /// In en, this message translates to:
  /// **'Could not load the type'**
  String get errorLoadType;

  /// No description provided for @errorLoadAbility.
  ///
  /// In en, this message translates to:
  /// **'Could not load the ability'**
  String get errorLoadAbility;

  /// No description provided for @errorLoadEggGroup.
  ///
  /// In en, this message translates to:
  /// **'Could not load the egg group'**
  String get errorLoadEggGroup;

  /// No description provided for @errorLoadItem.
  ///
  /// In en, this message translates to:
  /// **'Could not load the item'**
  String get errorLoadItem;

  /// No description provided for @errorLoadEvolutionChain.
  ///
  /// In en, this message translates to:
  /// **'Could not load the evolution chain'**
  String get errorLoadEvolutionChain;

  /// No description provided for @errorLoadSpecies.
  ///
  /// In en, this message translates to:
  /// **'Could not load the species'**
  String get errorLoadSpecies;

  /// No description provided for @errorLoadForm.
  ///
  /// In en, this message translates to:
  /// **'Could not load the form'**
  String get errorLoadForm;

  /// No description provided for @offlineEmptyCacheDefault.
  ///
  /// In en, this message translates to:
  /// **'No connection and no Pokémon saved on this device.\nConnect once to download the Pokédex.'**
  String get offlineEmptyCacheDefault;

  /// No description provided for @offlinePokemonNotCached.
  ///
  /// In en, this message translates to:
  /// **'This Pokémon is not saved on this device.'**
  String get offlinePokemonNotCached;

  /// No description provided for @offlineRegionPokedexNotCached.
  ///
  /// In en, this message translates to:
  /// **'The {regionName} regional Pokédex is not saved on this device.\nOpen this region online at least once.'**
  String offlineRegionPokedexNotCached(Object regionName);

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {minLength} characters.'**
  String authPasswordTooShort(int minLength);

  /// No description provided for @authPasswordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Password must be at most {maxLength} characters.'**
  String authPasswordTooLong(int maxLength);

  /// No description provided for @authEmailAlreadyInUseSignIn.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use. Use \"I already have an account\" to sign in.'**
  String get authEmailAlreadyInUseSignIn;

  /// No description provided for @authEmailAlreadyInUseTrySocial.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use. Try signing in with Google or use \"I already have an account\".'**
  String get authEmailAlreadyInUseTrySocial;

  /// No description provided for @authInvalidCredentialsGeneric.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Try again.'**
  String get authInvalidCredentialsGeneric;

  /// No description provided for @profileSocialAccountCredentials.
  ///
  /// In en, this message translates to:
  /// **'Google or Apple accounts cannot change password, email, or name here.'**
  String get profileSocialAccountCredentials;

  /// No description provided for @profileLogoutConfirmSemantics.
  ///
  /// In en, this message translates to:
  /// **'Confirm account sign out'**
  String get profileLogoutConfirmSemantics;

  /// No description provided for @profileLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get profileLogoutConfirmTitle;

  /// No description provided for @profileLogoutConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, sign out'**
  String get profileLogoutConfirmYes;

  /// No description provided for @profileLogoutConfirmYesSemantics.
  ///
  /// In en, this message translates to:
  /// **'Yes, sign out of account'**
  String get profileLogoutConfirmYesSemantics;

  /// No description provided for @profileLogoutConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'No, cancel'**
  String get profileLogoutConfirmNo;

  /// No description provided for @profileLogoutConfirmNoSemantics.
  ///
  /// In en, this message translates to:
  /// **'No, cancel sign out'**
  String get profileLogoutConfirmNoSemantics;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'All Pokémon in one place'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse a vast list of Pokémon from every generation by Nintendo'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Keep your Pokédex up to date'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up and keep your profile, favorite Pokémon, settings, and more saved in the app, even without an internet connection.'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinueButton;

  /// No description provided for @onboardingStartButton.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started!'**
  String get onboardingStartButton;

  /// No description provided for @profileCurrentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileCurrentPasswordLabel;

  /// No description provided for @profileSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSaveButton;

  /// No description provided for @profileFinishButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get profileFinishButton;

  /// No description provided for @profileBackToAccount.
  ///
  /// In en, this message translates to:
  /// **'Back to account'**
  String get profileBackToAccount;

  /// No description provided for @profileEditNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get profileEditNameTitle;

  /// No description provided for @profileEditNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This name appears on your profile and when you sign in.'**
  String get profileEditNameSubtitle;

  /// No description provided for @profileSecurityPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For security, confirm your password before continuing.'**
  String get profileSecurityPasswordSubtitle;

  /// No description provided for @changePasswordAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordAppBarTitle;

  /// No description provided for @changePasswordAppBarSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get changePasswordAppBarSuccess;

  /// No description provided for @changePasswordHeadlineCurrent.
  ///
  /// In en, this message translates to:
  /// **'What is your current password?'**
  String get changePasswordHeadlineCurrent;

  /// No description provided for @changePasswordHeadlineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm the new password'**
  String get changePasswordHeadlineConfirm;

  /// No description provided for @changePasswordSubtitleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password again to confirm.'**
  String get changePasswordSubtitleConfirm;

  /// No description provided for @changePasswordSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get changePasswordSaveButton;

  /// No description provided for @changePasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get changePasswordSuccessTitle;

  /// No description provided for @changePasswordSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your new password is active. Use it on your next sign-in.'**
  String get changePasswordSuccessSubtitle;

  /// No description provided for @changeEmailAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmailAppBarTitle;

  /// No description provided for @changeEmailAppBarSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email updated'**
  String get changeEmailAppBarSuccess;

  /// No description provided for @changeEmailNewEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get changeEmailNewEmailLabel;

  /// No description provided for @changeEmailHeadlineCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'What is your current password?'**
  String get changeEmailHeadlineCurrentPassword;

  /// No description provided for @changeEmailHeadlineNewEmail.
  ///
  /// In en, this message translates to:
  /// **'What is the new email?'**
  String get changeEmailHeadlineNewEmail;

  /// No description provided for @changeEmailHeadlineVerify.
  ///
  /// In en, this message translates to:
  /// **'Confirm the new email'**
  String get changeEmailHeadlineVerify;

  /// No description provided for @changeEmailSubtitleNewEmailFirebase.
  ///
  /// In en, this message translates to:
  /// **'We will send a verification link to the new address.'**
  String get changeEmailSubtitleNewEmailFirebase;

  /// No description provided for @changeEmailSubtitleNewEmailMock.
  ///
  /// In en, this message translates to:
  /// **'Enter the new email for your account.'**
  String get changeEmailSubtitleNewEmailMock;

  /// No description provided for @changeEmailSubtitleVerifyFirebase.
  ///
  /// In en, this message translates to:
  /// **'Open the link sent to {email} and tap \"I already confirmed\".'**
  String changeEmailSubtitleVerifyFirebase(Object email);

  /// No description provided for @changeEmailSendVerificationButton.
  ///
  /// In en, this message translates to:
  /// **'Send verification'**
  String get changeEmailSendVerificationButton;

  /// No description provided for @changeEmailConfirmCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm code'**
  String get changeEmailConfirmCodeButton;

  /// No description provided for @changeEmailSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Email updated!'**
  String get changeEmailSuccessTitle;

  /// No description provided for @changeEmailSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your account now uses {email}.'**
  String changeEmailSuccessSubtitle(Object email);

  /// No description provided for @authRegisterSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account was created successfully!'**
  String get authRegisterSuccessTitle;

  /// No description provided for @authRegisterSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome, trainer! We\'re excited to follow your journey.'**
  String get authRegisterSuccessSubtitle;

  /// No description provided for @trainerAvatarBugCatcherLabel.
  ///
  /// In en, this message translates to:
  /// **'Bug Catcher'**
  String get trainerAvatarBugCatcherLabel;

  /// No description provided for @trainerAvatarPokemaniacLabel.
  ///
  /// In en, this message translates to:
  /// **'Poké Maniac'**
  String get trainerAvatarPokemaniacLabel;

  /// No description provided for @pokemonImageLoadingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading Pokémon image'**
  String get pokemonImageLoadingSemantics;

  /// No description provided for @firebaseConfigErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Configuration unavailable'**
  String get firebaseConfigErrorTitle;

  /// No description provided for @firebaseConfigErrorBody.
  ///
  /// In en, this message translates to:
  /// **'This production build requires Firebase. Configure dart_defines.json and rebuild the app with --dart-define-from-file=dart_defines.json.'**
  String get firebaseConfigErrorBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
