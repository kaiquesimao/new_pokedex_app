// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navPokedex => 'PokeData';

  @override
  String get navRegions => 'Regions';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navAccount => 'Account';

  @override
  String get profileHelpLanguageQuestion => 'How do I change the language?';

  @override
  String get profileHelpLanguageAnswer =>
      'In Account → Language, tap \"App language\" to switch between Portuguese and English.';

  @override
  String get typeNormal => 'Normal';

  @override
  String get typeFire => 'Fire';

  @override
  String get typeWater => 'Water';

  @override
  String get typeElectric => 'Electric';

  @override
  String get typeGrass => 'Grass';

  @override
  String get typeIce => 'Ice';

  @override
  String get typeFighting => 'Fighting';

  @override
  String get typePoison => 'Poison';

  @override
  String get typeGround => 'Ground';

  @override
  String get typeFlying => 'Flying';

  @override
  String get typePsychic => 'Psychic';

  @override
  String get typeBug => 'Bug';

  @override
  String get typeRock => 'Rock';

  @override
  String get typeGhost => 'Ghost';

  @override
  String get typeDragon => 'Dragon';

  @override
  String get typeDark => 'Dark';

  @override
  String get typeSteel => 'Steel';

  @override
  String get typeFairy => 'Fairy';

  @override
  String get offlineBannerMessage =>
      'You are offline. Showing Pokémon saved on this device.';

  @override
  String get offlineEmptyTitleConnectivity => 'No connection';

  @override
  String get offlineEmptyTitleError => 'Failed to load';

  @override
  String get offlineRetryButton => 'Try again';

  @override
  String get searchHint => 'Search Pokémon...';

  @override
  String get otpCodeSemanticsPrefix => 'Verification code of ';

  @override
  String get otpCodeSemanticsSuffix => ' digits';

  @override
  String get otpResendSemantics => 'Resend verification code';

  @override
  String get otpResendButton => 'Resend code';

  @override
  String get authInvalidEmail => 'Invalid email';

  @override
  String get authUserDisabled => 'Account disabled';

  @override
  String get authUserNotFoundSignIn =>
      'We couldn\'t find an account with this email. Create one to continue.';

  @override
  String get authUserNotFound => 'User not found';

  @override
  String get authWrongPassword =>
      'Incorrect password. Try again or use \"Forgot password\".';

  @override
  String get authEmailAlreadyInUse => 'This email is already in use.';

  @override
  String get authEmailAlreadyInUseGoogle =>
      'This email is already in use with Google. Use \"I already have an account\" and sign in with Google.';

  @override
  String get authEmailAlreadyInUseApple =>
      'This email is already in use with Apple. Use \"I already have an account\" and sign in with Apple.';

  @override
  String get authWeakPassword => 'Use between 6 and 4096 characters.';

  @override
  String get authTooManyRequests => 'Too many attempts. Try again later';

  @override
  String get authNetworkRequestFailed => 'No connection. Check your internet';

  @override
  String get authRequiresRecentLogin => 'Please sign in again to continue';

  @override
  String get authInvalidCredentialEmailSignIn =>
      'Incorrect email or password. If you don\'t have an account yet, tap \"Create account\".';

  @override
  String get authInvalidCredentialOauth =>
      'Sign-in failed. If the problem continues, check SHA-1/SHA-256 in Firebase and download google-services.json again.';

  @override
  String get authAccountExistsWithDifferentCredential =>
      'This email is already registered with another sign-in method. Use Google, Apple or the original method.';

  @override
  String get authOperationNotAllowed =>
      'This sign-in method is not enabled in Firebase';

  @override
  String get authGenericError => 'Authentication error';

  @override
  String get authCreateAccountTitle => 'Create account';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authNameLabel => 'Name';

  @override
  String get authRegisterHeadlineEmail => 'What\'s your email?';

  @override
  String get authRegisterHeadlinePassword => 'Create a password';

  @override
  String get authRegisterHeadlineName => 'What should we call you?';

  @override
  String get authRegisterSubtitleEmail => 'Use a valid email address.';

  @override
  String get authRegisterSubtitleName =>
      'This name will appear in your trainer profile.';

  @override
  String get authContinueButton => 'Continue';

  @override
  String get authLoadingFinalizingRegistration => 'Finalizing registration...';

  @override
  String get authLoadingWait => 'Please wait...';

  @override
  String get authVerifyEmailTitle => 'Confirm email';

  @override
  String get authVerifyEmailHeadline => 'Confirm your email';

  @override
  String authVerifyEmailLinkSent(Object email) {
    return 'We sent a verification link to $email. Open the email, confirm the link and come back to continue.';
  }

  @override
  String authVerifyEmailCodeSent(Object email) {
    return 'We sent a 6-digit code to $email.';
  }

  @override
  String get authVerifyEmailAlreadyConfirmedButton =>
      'I already confirmed in my email';

  @override
  String get authVerifyEmailResendEmail => 'Resend email';

  @override
  String get authVerifyEmailResentEmail => 'A new email was sent.';

  @override
  String get authVerifyEmailResentCode => 'A new code was sent.';

  @override
  String get authVerifyEmailCreatingAccount => 'Creating account...';

  @override
  String get authVerifyEmailVerifying => 'Verifying...';

  @override
  String get authForgotCodeResentSnackbar => 'Code resent.';

  @override
  String get authForgotAppBarSuccess => 'Password reset';

  @override
  String get authForgotAppBarEmailSent => 'Email sent';

  @override
  String get authForgotAppBarDefault => 'Recover password';

  @override
  String get authForgotHeadlineEmail => 'Forgot your password?';

  @override
  String get authForgotHeadlineOtp => 'Confirm the code';

  @override
  String get authForgotHeadlineNewPassword => 'Create a new password';

  @override
  String get authForgotSubtitleEmail =>
      'Enter your email to receive a verification code.';

  @override
  String authForgotSubtitleOtp(Object email) {
    return 'Enter the 6-digit code sent to $email.';
  }

  @override
  String get authForgotNewPasswordLabel => 'New password';

  @override
  String get authForgotConfirmNewPasswordLabel => 'Confirm new password';

  @override
  String get authForgotPrimaryButtonEmail => 'Send code';

  @override
  String get authForgotPrimaryButtonNewPassword => 'Save new password';

  @override
  String get authProcessing => 'Processing...';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authLoginHeadline => 'Sign in with your email';

  @override
  String get authLoginInstructions =>
      'Use the email and password registered in the app. Accounts created with Google or Apple must sign in via those buttons.';

  @override
  String get authForgotPasswordText => 'Forgot my password';

  @override
  String get authLoginButtonLabel => 'Sign in';

  @override
  String get authLoadingSigningIn => 'Signing in...';

  @override
  String get authWelcomeSkipButton => 'Explore without account';

  @override
  String get authWelcomeQuestion => 'Ready for this adventure?';

  @override
  String get authWelcomeSubtitle =>
      'Just create an account and start exploring the world of Pokémon today!';

  @override
  String get authWelcomeCreateAccount => 'Create account';

  @override
  String get authWelcomeHaveAccount => 'I already have an account';

  @override
  String get authDefaultTrainerName => 'Trainer';

  @override
  String authLoginSuccessWelcomeBack(Object name) {
    return 'Welcome back, $name!';
  }

  @override
  String get authLoginSuccessMessage =>
      'We hope you had a long journey since the last time you visited us.';

  @override
  String get authLoginSuccessContinue => 'Continue';

  @override
  String get authLoginRequiredSemanticsLabel => 'Sign in to save favorites';

  @override
  String get authLoginRequiredTitle => 'Sign in to save favorites';

  @override
  String get authLoginRequiredDescription =>
      'Create an account or sign in to sync your favorite Pokémon.';

  @override
  String get authLoginRequiredSignIn => 'Sign in';

  @override
  String get authLoginRequiredCreateAccount => 'Create account';

  @override
  String get authLegalAcceptTerms =>
      'Accept Terms of Use and Privacy Policy to continue.';

  @override
  String get authSpamReminder =>
      'If you don\'t find it, check your spam or junk folder as well.';

  @override
  String get authUnverifiedFirebase =>
      'Email not yet verified. Open the sent link and try again. If you don\'t find it, check your spam or junk folder as well.';

  @override
  String get authServiceUnavailable => 'Service unavailable. Try again later.';

  @override
  String get authInvalidSession => 'Invalid session';

  @override
  String get authFillEmailAndPassword => 'Fill email and password';

  @override
  String get authFillAllFields => 'Fill all fields';

  @override
  String get authSignInToChangePassword => 'Sign in to change the password';

  @override
  String get authSignInToContinue => 'Sign in to continue';

  @override
  String get authLoginWithGoogleUnavailable => 'Google sign-in unavailable';

  @override
  String get authGoogleSignInNeedsWasmWithoutIsolation =>
      'Google Sign-In needs Wasm without cross-origin isolation. Use --wasm --no-cross-origin-isolation (see launch config Chrome Wasm).';

  @override
  String get authUseGoogleButton => 'Use the Google button to sign in';

  @override
  String get authLoginWithAppleUnavailable => 'Apple sign-in unavailable';

  @override
  String get authLoginWithAppleOnlyOnIOS =>
      'Apple sign-in available on iOS only';

  @override
  String get authInvalidCodeTryAgain => 'Invalid code. Try again.';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authEnterYourCurrentPassword => 'Enter your current password';

  @override
  String get authEnterYourName => 'Enter your name';

  @override
  String authDisplayNameTooLong(int maxLength) {
    return 'Name too long (max. $maxLength characters).';
  }

  @override
  String get authCurrentPasswordIncorrect => 'Current password is incorrect';

  @override
  String get authCreateAccountBeforeVerifying =>
      'Create an account before verifying the email';

  @override
  String get authUseLinkToResetPassword =>
      'Use the link sent by email to reset your password';

  @override
  String get authNewEmailDifferentFromCurrent =>
      'The new email must be different from the current one';

  @override
  String get authForgotVerifyEmailTitle => 'Check your email';

  @override
  String authForgotVerifyEmailSent(Object email) {
    return 'We sent a link to reset your password to $email.';
  }

  @override
  String get authBackToLogin => 'Back to login';

  @override
  String get authForgotSuccessTitle => 'Password reset successful!';

  @override
  String get authForgotSuccessSubtitle =>
      'Use your new password to sign in to PokeData.';

  @override
  String get authRegisterWelcomeHeadline =>
      'Almost ready to explore this world!';

  @override
  String get authRegisterSubtitle => 'How would you like to connect?';

  @override
  String get profileLogoutButton => 'Sign out';

  @override
  String profileLoggedInAs(Object name) {
    return 'You are signed in as $name.';
  }

  @override
  String get profileMegaEvolutionsLabel => 'Mega evolutions';

  @override
  String get profileOtherFormsLabel => 'Other forms';

  @override
  String get profileNotificationsTitle => 'Notifications';

  @override
  String get profileNotifyNewPokemon => 'New Pokémon';

  @override
  String get profileNotifyAppUpdates => 'App updates';

  @override
  String get profileLanguageTitle => 'Language';

  @override
  String get profileAppLanguageLabel => 'App language';

  @override
  String get profileGeneralTitle => 'General';

  @override
  String get profileVersionLabel => 'Version';

  @override
  String get profileTermsLabel => 'Terms of use';

  @override
  String get profilePrivacyLabel => 'Privacy policy';

  @override
  String get profileHelpLabel => 'Help';

  @override
  String get profileAboutLabel => 'About';

  @override
  String get profileActionSuccess => 'Action completed';

  @override
  String evolutionTriggerLevel(Object minLevel) {
    return 'Level $minLevel';
  }

  @override
  String get evolutionTriggerTrade => 'Trade';

  @override
  String get evolutionTriggerUseItem => 'Use item';

  @override
  String get evolutionTriggerLevelUp => 'Level up';

  @override
  String get evolutionTriggerOther => 'Other';

  @override
  String get evolutionTriggerDuringDay => 'During the day';

  @override
  String get evolutionTriggerAtNight => 'At night';

  @override
  String evolutionTriggerHoldingItem(Object heldItem) {
    return 'Holding $heldItem';
  }

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'Attack';

  @override
  String get statDefense => 'Defense';

  @override
  String get statSpecialAttack => 'Sp. Atk';

  @override
  String get statSpecialDefense => 'Sp. Def';

  @override
  String get statSpeed => 'Speed';

  @override
  String get abilityHiddenSuffix => ' (hidden)';

  @override
  String get genderNone => 'Genderless';

  @override
  String get genderMaleOnly => 'Male only';

  @override
  String get genderFemaleOnly => 'Female only';

  @override
  String genderFemalePercent(String percent) {
    return '$percent% female';
  }

  @override
  String get hatchNever => 'Does not hatch from egg';

  @override
  String hatchSteps(String steps) {
    return '$steps steps';
  }

  @override
  String get filterTypeLabel => 'Type';

  @override
  String get filterClearButton => 'Clear';

  @override
  String get filterAllTypes => 'All types';

  @override
  String get filterGenerationLabel => 'Generation';

  @override
  String get filterAdvancedLabel => 'Advanced filters';

  @override
  String get filterTypesTitle => 'Types';

  @override
  String get filterTypeSemantics => 'Pokémon type filter';

  @override
  String get filterAdvancedTitle => 'Advanced filters';

  @override
  String get filterWeaknessTitle => 'Weakness';

  @override
  String get filterHeightTitle => 'Height';

  @override
  String get filterWeightTitle => 'Weight';

  @override
  String get filterSortTitle => 'Sort';

  @override
  String get filterSortSemantics => 'Pokémon list sort order';

  @override
  String get filterNoPokemonFound => 'No Pokémon found';

  @override
  String get sortNumberAsc => 'Lowest number';

  @override
  String get sortNumberDesc => 'Highest number';

  @override
  String get sortNameAsc => 'A-Z';

  @override
  String get sortNameDesc => 'Z-A';

  @override
  String get heightBucketSmall => 'Short (< 1 m)';

  @override
  String get heightBucketMedium => 'Medium (1–2 m)';

  @override
  String get heightBucketLarge => 'Tall (> 2 m)';

  @override
  String get weightBucketLight => 'Light (< 10 kg)';

  @override
  String get weightBucketMedium => 'Medium (10–100 kg)';

  @override
  String get weightBucketHeavy => 'Heavy (> 100 kg)';

  @override
  String generationPicker(Object roman) {
    return 'Generation $roman';
  }

  @override
  String generationFallback(int id) {
    return 'Generation $id';
  }

  @override
  String regionGenerationBadgeEn(Object roman) {
    return 'GEN $roman';
  }

  @override
  String regionGenerationBadgePt(int number) {
    return '$numberª GENERATION';
  }

  @override
  String get favoritesGuestTitle => 'You need to sign in to do this.';

  @override
  String get favoritesGuestSubtitle =>
      'To access this feature, sign in or create an account. Do it now!';

  @override
  String get favoritesGuestAction => 'Sign in or register';

  @override
  String get favoritesEmptyTitle => 'You have not favorited any Pokémon :(';

  @override
  String get favoritesEmptySubtitle =>
      'Tap the heart icon on your favorite Pokémon and they will appear here.';

  @override
  String favoritesRemovedSnackbar(Object name) {
    return '$name removed from favorites';
  }

  @override
  String get pokemonDetailEvolutions => 'Evolutions';

  @override
  String get pokemonDetailNoEvolution => 'This Pokémon does not evolve.';

  @override
  String get pokemonDetailStats => 'Stats';

  @override
  String get pokemonDetailWeaknesses => 'Weaknesses';

  @override
  String get detailWeight => 'Weight';

  @override
  String get detailHeight => 'Height';

  @override
  String get detailCategory => 'Category';

  @override
  String get detailAbility => 'Ability';

  @override
  String get detailGender => 'Gender';

  @override
  String get flavorTextTranslating => 'Translating description...';

  @override
  String get favoriteAddSemantics => 'Add to favorites';

  @override
  String get favoriteRemoveSemantics => 'Remove from favorites';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithEmail => 'Continue with email';

  @override
  String get legalAcceptPrefix => 'I have read and accept the ';

  @override
  String get legalAcceptMiddle => ' and the ';

  @override
  String get legalLoadTermsError => 'Could not load the terms of use.';

  @override
  String get legalLoadPrivacyError => 'Could not load the privacy policy.';

  @override
  String get helpFaqTitle => 'Frequently asked questions';

  @override
  String get helpSupportTitle => 'Support';

  @override
  String get helpSupportBody =>
      'Did not find what you need? Send your question or issue report to our team.';

  @override
  String get helpEmailOpenError => 'Could not open the email app.';

  @override
  String get helpEmailSubject => 'PokeData Support';

  @override
  String get helpExploreGuestQuestion => 'How do I explore without an account?';

  @override
  String get helpExploreGuestAnswer =>
      'On the welcome screen, tap \"Explore without account\" to browse the Pokédex, regions, and Pokémon details without signing in.';

  @override
  String get helpFavoriteQuestion => 'How do I favorite Pokémon?';

  @override
  String get helpFavoriteAnswer =>
      'Tap the heart icon in the list or on the detail page. You must sign in to save and sync favorites across devices.';

  @override
  String get helpFilterQuestion => 'How do I filter the Pokémon list?';

  @override
  String get helpFilterAnswer =>
      'On the Pokédex tab, use the search bar and filters by type and generation to refine the results.';

  @override
  String get helpMegaFormsQuestion =>
      'What are mega evolutions and other forms?';

  @override
  String get helpMegaFormsAnswer =>
      'In Account → PokeData, use the toggles to show or hide mega evolutions and alternate forms in the list.';

  @override
  String get helpOfflineQuestion => 'Does the app work offline?';

  @override
  String get helpOfflineAnswer =>
      'Recently visited data may appear from local cache. An internet connection is required to search new Pokémon or refresh information.';

  @override
  String aboutVersion(Object version, Object build) {
    return 'Version $version ($build)';
  }

  @override
  String get aboutVersionLoading => 'Version …';

  @override
  String get aboutVersionUnavailable => 'Version unavailable';

  @override
  String get aboutTagline =>
      'A fan-made Pokédex to explore Pokémon, regions, favorites, and details with up-to-date PokéAPI data.';

  @override
  String get aboutDevelopedBy => 'Developed by';

  @override
  String get aboutAcknowledgments => 'Acknowledgments';

  @override
  String get aboutCredits => 'Credits';

  @override
  String get aboutKaiqueTitle => 'Kaique Simão';

  @override
  String get aboutKaiqueBody => 'Creator and developer of PokeData.';

  @override
  String get aboutJuniorTitle => 'Junior Saraiva';

  @override
  String get aboutJuniorBody =>
      'Created the Figma Community design that served as the visual reference for this project.';

  @override
  String get aboutLinkedInProfile => 'LinkedIn profile';

  @override
  String get aboutFigmaProject => 'Figma project';

  @override
  String get aboutCreditPokeApiTitle => 'PokéAPI';

  @override
  String get aboutCreditPokeApiBody =>
      'Pokémon, species, type, and evolution data.';

  @override
  String get aboutCreditFlutterTitle => 'Flutter';

  @override
  String get aboutCreditFlutterBody => 'Cross-platform app framework.';

  @override
  String get aboutCreditFirebaseTitle => 'Firebase';

  @override
  String get aboutCreditFirebaseBody =>
      'Authentication, favorites, and cloud sync.';

  @override
  String get aboutDisclaimer =>
      'PokeData is an unofficial fan app. It is not developed, endorsed, or affiliated with Nintendo, Creatures Inc., GAME FREAK, or The Pokémon Company. Pokémon © Nintendo / Creatures Inc. / GAME FREAK.';

  @override
  String get errorNetworkOffline => 'No internet connection.';

  @override
  String get errorTooManyRequests =>
      'Too many requests. Wait a moment and try again.';

  @override
  String get errorServiceUnavailable =>
      'The service is temporarily unavailable. Try again in a moment.';

  @override
  String get errorGenericRetry => 'Something went wrong. Try again.';

  @override
  String errorLoadDataWithStatus(int statusCode) {
    return 'Could not load data ($statusCode). Try again.';
  }

  @override
  String get errorLoadPokemonList => 'Could not load the Pokémon list';

  @override
  String get errorLoadPokemon => 'Could not load the Pokémon';

  @override
  String get errorLoadRegions => 'Could not load the regions';

  @override
  String get errorLoadRegion => 'Could not load the region';

  @override
  String get errorLoadPokedex => 'Could not load the Pokédex';

  @override
  String get errorLoadGeneration => 'Could not load the generation';

  @override
  String get errorLoadType => 'Could not load the type';

  @override
  String get errorLoadAbility => 'Could not load the ability';

  @override
  String get errorLoadEggGroup => 'Could not load the egg group';

  @override
  String get errorLoadItem => 'Could not load the item';

  @override
  String get errorLoadEvolutionChain => 'Could not load the evolution chain';

  @override
  String get errorLoadSpecies => 'Could not load the species';

  @override
  String get errorLoadForm => 'Could not load the form';

  @override
  String get offlineEmptyCacheDefault =>
      'No connection and no Pokémon saved on this device.\nConnect once to download the Pokédex.';

  @override
  String get offlinePokemonNotCached =>
      'This Pokémon is not saved on this device.';

  @override
  String offlineRegionPokedexNotCached(Object regionName) {
    return 'The $regionName regional Pokédex is not saved on this device.\nOpen this region online at least once.';
  }

  @override
  String authPasswordTooShort(int minLength) {
    return 'Password must be at least $minLength characters.';
  }

  @override
  String authPasswordTooLong(int maxLength) {
    return 'Password must be at most $maxLength characters.';
  }

  @override
  String get authEmailAlreadyInUseSignIn =>
      'This email is already in use. Use \"I already have an account\" to sign in.';

  @override
  String get authEmailAlreadyInUseTrySocial =>
      'This email is already in use. Try signing in with Google or use \"I already have an account\".';

  @override
  String get authInvalidCredentialsGeneric => 'Invalid credentials. Try again.';

  @override
  String get profileSocialAccountCredentials =>
      'Google or Apple accounts cannot change password, email, or name here.';

  @override
  String get profileLogoutConfirmSemantics => 'Confirm account sign out';

  @override
  String get profileLogoutConfirmTitle => 'Are you sure you want to sign out?';

  @override
  String get profileLogoutConfirmYes => 'Yes, sign out';

  @override
  String get profileLogoutConfirmYesSemantics => 'Yes, sign out of account';

  @override
  String get profileLogoutConfirmNo => 'No, cancel';

  @override
  String get profileLogoutConfirmNoSemantics => 'No, cancel sign out';

  @override
  String get onboardingSlide1Title => 'All Pokémon in one place';

  @override
  String get onboardingSlide1Subtitle =>
      'Browse a vast list of Pokémon from every generation by Nintendo';

  @override
  String get onboardingSlide2Title => 'Keep your Pokédex up to date';

  @override
  String get onboardingSlide2Subtitle =>
      'Sign up and keep your profile, favorite Pokémon, settings, and more saved in the app, even without an internet connection.';

  @override
  String get onboardingContinueButton => 'Continue';

  @override
  String get onboardingStartButton => 'Let\'s get started!';

  @override
  String get profileCurrentPasswordLabel => 'Current password';

  @override
  String get profileSaveButton => 'Save';

  @override
  String get profileFinishButton => 'Done';

  @override
  String get profileBackToAccount => 'Back to account';

  @override
  String get profileEditNameTitle => 'Edit name';

  @override
  String get profileEditNameSubtitle =>
      'This name appears on your profile and when you sign in.';

  @override
  String get profileSecurityPasswordSubtitle =>
      'For security, confirm your password before continuing.';

  @override
  String get changePasswordAppBarTitle => 'Change password';

  @override
  String get changePasswordAppBarSuccess => 'Password changed';

  @override
  String get changePasswordHeadlineCurrent => 'What is your current password?';

  @override
  String get changePasswordHeadlineConfirm => 'Confirm the new password';

  @override
  String get changePasswordSubtitleConfirm =>
      'Enter the new password again to confirm.';

  @override
  String get changePasswordSaveButton => 'Save password';

  @override
  String get changePasswordSuccessTitle => 'Password changed successfully!';

  @override
  String get changePasswordSuccessSubtitle =>
      'Your new password is active. Use it on your next sign-in.';

  @override
  String get changeEmailAppBarTitle => 'Change email';

  @override
  String get changeEmailAppBarSuccess => 'Email updated';

  @override
  String get changeEmailNewEmailLabel => 'New email';

  @override
  String get changeEmailHeadlineCurrentPassword =>
      'What is your current password?';

  @override
  String get changeEmailHeadlineNewEmail => 'What is the new email?';

  @override
  String get changeEmailHeadlineVerify => 'Confirm the new email';

  @override
  String get changeEmailSubtitleNewEmailFirebase =>
      'We will send a verification link to the new address.';

  @override
  String get changeEmailSubtitleNewEmailMock =>
      'Enter the new email for your account.';

  @override
  String changeEmailSubtitleVerifyFirebase(Object email) {
    return 'Open the link sent to $email and tap \"I already confirmed\".';
  }

  @override
  String get changeEmailSendVerificationButton => 'Send verification';

  @override
  String get changeEmailConfirmCodeButton => 'Confirm code';

  @override
  String get changeEmailSuccessTitle => 'Email updated!';

  @override
  String changeEmailSuccessSubtitle(Object email) {
    return 'Your account now uses $email.';
  }

  @override
  String get authRegisterSuccessTitle =>
      'Your account was created successfully!';

  @override
  String get authRegisterSuccessSubtitle =>
      'Welcome, trainer! We\'re excited to follow your journey.';

  @override
  String get trainerAvatarBugCatcherLabel => 'Bug Catcher';

  @override
  String get trainerAvatarPokemaniacLabel => 'Poké Maniac';

  @override
  String get pokemonImageLoadingSemantics => 'Loading Pokémon image';

  @override
  String get pokemonCryPlaySemantics => 'Play Pokémon cry';

  @override
  String get pokemonFormLabelNormal => 'Normal';

  @override
  String get pokemonFormLabelShiny => 'Shiny';

  @override
  String get pokemonFormLabelMega => 'Mega';

  @override
  String get pokemonFormLabelMegaX => 'Mega X';

  @override
  String get pokemonFormLabelMegaY => 'Mega Y';

  @override
  String get pokemonFormLabelAlola => 'Alola';

  @override
  String get pokemonFormLabelGalar => 'Galar';

  @override
  String get pokemonFormLabelHisui => 'Hisui';

  @override
  String get pokemonFormLabelPaldea => 'Paldea';

  @override
  String get pokemonFormLabelGigantamax => 'Gigantamax';

  @override
  String pokemonFormCarouselSemantics(String formLabel) {
    return '$formLabel, swipe to see other forms';
  }

  @override
  String get firebaseConfigErrorTitle => 'Configuration unavailable';

  @override
  String get firebaseConfigErrorBody =>
      'This production build requires Firebase. Configure dart_defines.json and rebuild the app with --dart-define-from-file=dart_defines.json.';
}
