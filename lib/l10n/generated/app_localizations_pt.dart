// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get navPokedex => 'PokeData';

  @override
  String get navRegions => 'Regiões';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navAccount => 'Conta';

  @override
  String get profileHelpLanguageQuestion => 'Como alterar o idioma?';

  @override
  String get profileHelpLanguageAnswer =>
      'Em Conta → Idioma, toque em \"Idioma do app\" para alternar entre português e inglês.';

  @override
  String get typeNormal => 'Normal';

  @override
  String get typeFire => 'Fogo';

  @override
  String get typeWater => 'Água';

  @override
  String get typeElectric => 'Elétrico';

  @override
  String get typeGrass => 'Grama';

  @override
  String get typeIce => 'Gelo';

  @override
  String get typeFighting => 'Lutador';

  @override
  String get typePoison => 'Veneno';

  @override
  String get typeGround => 'Terra';

  @override
  String get typeFlying => 'Voador';

  @override
  String get typePsychic => 'Psíquico';

  @override
  String get typeBug => 'Inseto';

  @override
  String get typeRock => 'Pedra';

  @override
  String get typeGhost => 'Fantasma';

  @override
  String get typeDragon => 'Dragão';

  @override
  String get typeDark => 'Sombrio';

  @override
  String get typeSteel => 'Aço';

  @override
  String get typeFairy => 'Fada';

  @override
  String get offlineBannerMessage =>
      'Você está offline. Mostrando Pokémon salvos no dispositivo.';

  @override
  String get offlineEmptyTitleConnectivity => 'Sem conexão';

  @override
  String get offlineEmptyTitleError => 'Erro ao carregar';

  @override
  String get offlineRetryButton => 'Tentar novamente';

  @override
  String get searchHint => 'Procurar Pokémon...';

  @override
  String get otpCodeSemanticsPrefix => 'Código de verificação de ';

  @override
  String get otpCodeSemanticsSuffix => ' dígitos';

  @override
  String get otpResendSemantics => 'Reenviar código de verificação';

  @override
  String get otpResendButton => 'Reenviar código';

  @override
  String get authInvalidEmail => 'E-mail inválido';

  @override
  String get authUserDisabled => 'Conta desativada';

  @override
  String get authUserNotFoundSignIn =>
      'Não encontramos uma conta com este e-mail. Crie uma conta para continuar.';

  @override
  String get authUserNotFound => 'Usuário não encontrado';

  @override
  String get authWrongPassword =>
      'Senha incorreta. Tente novamente ou use \"Esqueci minha senha\".';

  @override
  String get authEmailAlreadyInUse => 'Este e-mail já está em uso.';

  @override
  String get authEmailAlreadyInUseGoogle =>
      'Este e-mail já está em uso com Google. Use \"Já tenho uma conta\" e entre com Google.';

  @override
  String get authEmailAlreadyInUseApple =>
      'Este e-mail já está em uso com Apple. Use \"Já tenho uma conta\" e entre com Apple.';

  @override
  String get authWeakPassword => 'Use entre 6 e 4096 caracteres.';

  @override
  String get authTooManyRequests =>
      'Muitas tentativas. Tente novamente mais tarde';

  @override
  String get authNetworkRequestFailed => 'Sem conexão. Verifique sua internet';

  @override
  String get authRequiresRecentLogin => 'Faça login novamente para continuar';

  @override
  String get authInvalidCredentialEmailSignIn =>
      'E-mail ou senha incorretos. Se você ainda não tem conta, toque em \"Criar conta\".';

  @override
  String get authInvalidCredentialOauth =>
      'Falha ao entrar. Se o problema continuar, verifique SHA-1/SHA-256 no Firebase e baixe o google-services.json novamente.';

  @override
  String get authAccountExistsWithDifferentCredential =>
      'Este e-mail já está cadastrado com outro método de login. Use Google, Apple ou o método original.';

  @override
  String get authOperationNotAllowed =>
      'Este método de login não está habilitado no Firebase';

  @override
  String get authGenericError => 'Erro de autenticação';

  @override
  String get authCreateAccountTitle => 'Criar conta';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authPasswordLabel => 'Senha';

  @override
  String get authNameLabel => 'Nome';

  @override
  String get authRegisterHeadlineEmail => 'Qual é o seu e-mail?';

  @override
  String get authRegisterHeadlinePassword => 'Crie uma senha';

  @override
  String get authRegisterHeadlineName => 'Como podemos te chamar?';

  @override
  String get authRegisterSubtitleEmail => 'Use um endereço de e-mail válido.';

  @override
  String get authRegisterSubtitleName =>
      'Este nome aparecerá no seu perfil de treinador.';

  @override
  String get authContinueButton => 'Continuar';

  @override
  String get authLoadingFinalizingRegistration => 'Finalizando cadastro...';

  @override
  String get authLoadingWait => 'Aguarde...';

  @override
  String get authVerifyEmailTitle => 'Confirmar e-mail';

  @override
  String get authVerifyEmailHeadline => 'Confirme seu e-mail';

  @override
  String authVerifyEmailLinkSent(Object email) {
    return 'Enviamos um link de verificação para $email. Abra o e-mail, confirme o link e volte aqui para continuar.';
  }

  @override
  String authVerifyEmailCodeSent(Object email) {
    return 'Enviamos um código de 6 dígitos para $email.';
  }

  @override
  String get authVerifyEmailAlreadyConfirmedButton => 'Já confirmei no e-mail';

  @override
  String get authVerifyEmailResendEmail => 'Reenviar e-mail';

  @override
  String get authVerifyEmailResentEmail => 'Um novo e-mail foi enviado.';

  @override
  String get authVerifyEmailResentCode => 'Um novo código foi enviado.';

  @override
  String get authVerifyEmailCreatingAccount => 'Criando conta...';

  @override
  String get authVerifyEmailVerifying => 'Verificando...';

  @override
  String get authForgotCodeResentSnackbar => 'Código reenviado.';

  @override
  String get authForgotAppBarSuccess => 'Senha redefinida';

  @override
  String get authForgotAppBarEmailSent => 'E-mail enviado';

  @override
  String get authForgotAppBarDefault => 'Recuperar senha';

  @override
  String get authForgotHeadlineEmail => 'Esqueceu sua senha?';

  @override
  String get authForgotHeadlineOtp => 'Confirme o código';

  @override
  String get authForgotHeadlineNewPassword => 'Crie uma nova senha';

  @override
  String get authForgotSubtitleEmail =>
      'Informe seu e-mail para receber um código de verificação.';

  @override
  String authForgotSubtitleOtp(Object email) {
    return 'Digite o código de 6 dígitos enviado para $email.';
  }

  @override
  String get authForgotNewPasswordLabel => 'Nova senha';

  @override
  String get authForgotConfirmNewPasswordLabel => 'Confirmar nova senha';

  @override
  String get authForgotPrimaryButtonEmail => 'Enviar código';

  @override
  String get authForgotPrimaryButtonNewPassword => 'Salvar nova senha';

  @override
  String get authProcessing => 'Processando...';

  @override
  String get authLoginTitle => 'Entrar';

  @override
  String get authLoginHeadline => 'Entre com seu e-mail';

  @override
  String get authLoginInstructions =>
      'Use o e-mail e a senha cadastrados no app. Contas criadas com Google ou Apple devem entrar por esses botões.';

  @override
  String get authForgotPasswordText => 'Esqueci minha senha';

  @override
  String get authLoginButtonLabel => 'Entrar';

  @override
  String get authLoadingSigningIn => 'Entrando...';

  @override
  String get authWelcomeSkipButton => 'Explorar sem conta';

  @override
  String get authWelcomeQuestion => 'Está pronto para essa aventura?';

  @override
  String get authWelcomeSubtitle =>
      'Basta criar uma conta e começar a explorar o mundo dos Pokémon hoje!';

  @override
  String get authWelcomeCreateAccount => 'Criar conta';

  @override
  String get authWelcomeHaveAccount => 'Já tenho uma conta';

  @override
  String get authDefaultTrainerName => 'Treinador';

  @override
  String authLoginSuccessWelcomeBack(Object name) {
    return 'Bem-vindo de volta, $name!';
  }

  @override
  String get authLoginSuccessMessage =>
      'Esperamos que tenha tido uma longa jornada desde a última vez em que nos visitou.';

  @override
  String get authLoginSuccessContinue => 'Continuar';

  @override
  String get authLoginRequiredSemanticsLabel => 'Entre para salvar favoritos';

  @override
  String get authLoginRequiredTitle => 'Entre para salvar favoritos';

  @override
  String get authLoginRequiredDescription =>
      'Crie uma conta ou entre para sincronizar seus Pokémon favoritos.';

  @override
  String get authLoginRequiredSignIn => 'Entrar';

  @override
  String get authLoginRequiredCreateAccount => 'Criar conta';

  @override
  String get authLegalAcceptTerms =>
      'Aceite os Termos de uso e a Política de privacidade para continuar.';

  @override
  String get authSpamReminder =>
      'Se não encontrar, verifique também a pasta de spam ou lixo eletrônico.';

  @override
  String get authUnverifiedFirebase =>
      'E-mail ainda não verificado. Abra o link enviado e tente novamente. Se não encontrar, verifique também a pasta de spam ou lixo eletrônico.';

  @override
  String get authServiceUnavailable =>
      'Serviço indisponível. Tente novamente mais tarde.';

  @override
  String get authInvalidSession => 'Sessão inválida';

  @override
  String get authFillEmailAndPassword => 'Preencha e-mail e senha';

  @override
  String get authFillAllFields => 'Preencha todos os campos';

  @override
  String get authSignInToChangePassword => 'Faça login para alterar a senha';

  @override
  String get authSignInToContinue => 'Faça login para continuar';

  @override
  String get authLoginWithGoogleUnavailable => 'Login com Google indisponível';

  @override
  String get authGoogleSignInNeedsWasmWithoutIsolation =>
      'Login com Google exige Wasm sem isolamento cross-origin. Use --wasm --no-cross-origin-isolation (config Chrome Wasm).';

  @override
  String get authUseGoogleButton => 'Use o botão do Google para entrar';

  @override
  String get authLoginWithAppleUnavailable => 'Login com Apple indisponível';

  @override
  String get authLoginWithAppleOnlyOnIOS =>
      'Login com Apple disponível apenas no iOS';

  @override
  String get authInvalidCodeTryAgain => 'Código inválido. Tente novamente.';

  @override
  String get authPasswordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get authEnterYourCurrentPassword => 'Informe sua senha atual';

  @override
  String get authEnterYourName => 'Informe seu nome';

  @override
  String authDisplayNameTooLong(int maxLength) {
    return 'Nome muito longo (máx. $maxLength caracteres).';
  }

  @override
  String get authCurrentPasswordIncorrect => 'Senha atual incorreta';

  @override
  String get authCreateAccountBeforeVerifying =>
      'Crie a conta antes de verificar o e-mail';

  @override
  String get authUseLinkToResetPassword =>
      'Use o link enviado por e-mail para redefinir a senha';

  @override
  String get authNewEmailDifferentFromCurrent =>
      'O novo e-mail deve ser diferente do atual';

  @override
  String get authForgotVerifyEmailTitle => 'Verifique seu e-mail';

  @override
  String authForgotVerifyEmailSent(Object email) {
    return 'Enviamos um link para redefinir sua senha em $email.';
  }

  @override
  String get authBackToLogin => 'Voltar ao login';

  @override
  String get authForgotSuccessTitle => 'Senha redefinida com sucesso!';

  @override
  String get authForgotSuccessSubtitle =>
      'Use sua nova senha para entrar na PokeData.';

  @override
  String get authRegisterWelcomeHeadline =>
      'Falta pouco para explorar esse mundo!';

  @override
  String get authRegisterSubtitle => 'Como deseja se conectar?';

  @override
  String get profileLogoutButton => 'Sair';

  @override
  String profileLoggedInAs(Object name) {
    return 'Você entrou como $name';
  }

  @override
  String get profileMegaEvolutionsLabel => 'Mega evoluções';

  @override
  String get profileOtherFormsLabel => 'Outras formas';

  @override
  String get profileNotificationsTitle => 'Notificações';

  @override
  String get profileNotifyNewPokemon => 'Novos Pokémon';

  @override
  String get profileNotifyAppUpdates => 'Atualizações do app';

  @override
  String get profileLanguageTitle => 'Idioma';

  @override
  String get profileAppLanguageLabel => 'Idioma do app';

  @override
  String get profileGeneralTitle => 'Geral';

  @override
  String get profileVersionLabel => 'Versão';

  @override
  String get profileTermsLabel => 'Termos de uso';

  @override
  String get profilePrivacyLabel => 'Política de privacidade';

  @override
  String get profileHelpLabel => 'Ajuda';

  @override
  String get profileAboutLabel => 'Sobre';

  @override
  String get profileActionSuccess => 'Ação realizada com sucesso';

  @override
  String evolutionTriggerLevel(Object minLevel) {
    return 'Nível $minLevel';
  }

  @override
  String get evolutionTriggerTrade => 'Troca';

  @override
  String get evolutionTriggerUseItem => 'Usar item';

  @override
  String get evolutionTriggerLevelUp => 'Subir de nível';

  @override
  String get evolutionTriggerOther => 'Outro';

  @override
  String get evolutionTriggerDuringDay => 'Durante o dia';

  @override
  String get evolutionTriggerAtNight => 'À noite';

  @override
  String evolutionTriggerHoldingItem(Object heldItem) {
    return 'Segurando $heldItem';
  }

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'Ataque';

  @override
  String get statDefense => 'Defesa';

  @override
  String get statSpecialAttack => 'Atq. Esp.';

  @override
  String get statSpecialDefense => 'Def. Esp.';

  @override
  String get statSpeed => 'Velocidade';

  @override
  String get abilityHiddenSuffix => ' (oculta)';

  @override
  String get genderNone => 'Sem gênero';

  @override
  String get genderMaleOnly => 'Somente macho';

  @override
  String get genderFemaleOnly => 'Somente fêmea';

  @override
  String genderFemalePercent(String percent) {
    return '$percent% fêmea';
  }

  @override
  String get hatchNever => 'Não choca de ovo';

  @override
  String hatchSteps(String steps) {
    return '$steps passos';
  }

  @override
  String get filterTypeLabel => 'Tipo';

  @override
  String get filterClearButton => 'Limpar';

  @override
  String get filterAllTypes => 'Todos os tipos';

  @override
  String get filterGenerationLabel => 'Geração';

  @override
  String get filterAdvancedLabel => 'Filtros avançados';

  @override
  String get filterTypesTitle => 'Tipos';

  @override
  String get filterTypeSemantics => 'Filtro de tipos de Pokémon';

  @override
  String get filterAdvancedTitle => 'Filtros avançados';

  @override
  String get filterWeaknessTitle => 'Fraqueza';

  @override
  String get filterHeightTitle => 'Altura';

  @override
  String get filterWeightTitle => 'Peso';

  @override
  String get filterSortTitle => 'Ordem';

  @override
  String get filterSortSemantics => 'Ordenação da lista de Pokémon';

  @override
  String get filterNoPokemonFound => 'Nenhum Pokémon encontrado';

  @override
  String get sortNumberAsc => 'Menor número';

  @override
  String get sortNumberDesc => 'Maior número';

  @override
  String get sortNameAsc => 'A-Z';

  @override
  String get sortNameDesc => 'Z-A';

  @override
  String get heightBucketSmall => 'Baixo (< 1 m)';

  @override
  String get heightBucketMedium => 'Médio (1–2 m)';

  @override
  String get heightBucketLarge => 'Alto (> 2 m)';

  @override
  String get weightBucketLight => 'Leve (< 10 kg)';

  @override
  String get weightBucketMedium => 'Médio (10–100 kg)';

  @override
  String get weightBucketHeavy => 'Pesado (> 100 kg)';

  @override
  String generationPicker(Object roman) {
    return 'Geração $roman';
  }

  @override
  String generationFallback(int id) {
    return 'Geração $id';
  }

  @override
  String regionGenerationBadgeEn(Object roman) {
    return 'GEN $roman';
  }

  @override
  String regionGenerationBadgePt(int number) {
    return '$numberª GERAÇÃO';
  }

  @override
  String get favoritesGuestTitle =>
      'Você precisa entrar em uma conta para fazer isso.';

  @override
  String get favoritesGuestSubtitle =>
      'Para acessar essa funcionalidade, é necessário fazer login ou criar uma conta. Faça isso agora!';

  @override
  String get favoritesGuestAction => 'Entre ou Cadastre-se';

  @override
  String get favoritesEmptyTitle => 'Você não favoritou nenhum Pokémon :(';

  @override
  String get favoritesEmptySubtitle =>
      'Clique no ícone de coração dos seus pokémons favoritos e eles aparecerão aqui.';

  @override
  String favoritesRemovedSnackbar(Object name) {
    return '$name removido dos favoritos';
  }

  @override
  String get pokemonDetailEvolutions => 'Evoluções';

  @override
  String get pokemonDetailNoEvolution => 'Este Pokémon não evolui.';

  @override
  String get pokemonDetailStats => 'Estatísticas';

  @override
  String get pokemonDetailWeaknesses => 'Fraquezas';

  @override
  String get detailWeight => 'Peso';

  @override
  String get detailHeight => 'Altura';

  @override
  String get detailCategory => 'Categoria';

  @override
  String get detailAbility => 'Habilidade';

  @override
  String get detailGender => 'Gênero';

  @override
  String get flavorTextTranslating => 'Traduzindo descrição...';

  @override
  String get favoriteAddSemantics => 'Adicionar aos favoritos';

  @override
  String get favoriteRemoveSemantics => 'Remover dos favoritos';

  @override
  String get authContinueWithApple => 'Continuar com a Apple';

  @override
  String get authContinueWithGoogle => 'Continuar com o Google';

  @override
  String get authContinueWithEmail => 'Continuar com um e-mail';

  @override
  String get legalAcceptPrefix => 'Li e aceito os ';

  @override
  String get legalAcceptMiddle => ' e a ';

  @override
  String get legalLoadTermsError =>
      'Não foi possível carregar os termos de uso.';

  @override
  String get legalLoadPrivacyError =>
      'Não foi possível carregar a política de privacidade.';

  @override
  String get helpFaqTitle => 'Perguntas frequentes';

  @override
  String get helpSupportTitle => 'Suporte';

  @override
  String get helpSupportBody =>
      'Não encontrou o que procura? Envie sua dúvida ou relato de problema para nossa equipe.';

  @override
  String get helpEmailOpenError =>
      'Não foi possível abrir o aplicativo de e-mail.';

  @override
  String get helpEmailSubject => 'Suporte PokeData';

  @override
  String get helpExploreGuestQuestion => 'Como explorar sem criar conta?';

  @override
  String get helpExploreGuestAnswer =>
      'Na tela de boas-vindas, toque em \"Explorar sem conta\" para navegar pelo Pokédex, regiões e detalhes dos Pokémon sem precisar fazer login.';

  @override
  String get helpFavoriteQuestion => 'Como favoritar Pokémon?';

  @override
  String get helpFavoriteAnswer =>
      'Toque no ícone de coração na lista ou na página de detalhes. É necessário entrar na sua conta para salvar e sincronizar favoritos entre dispositivos.';

  @override
  String get helpFilterQuestion => 'Como filtrar a lista de Pokémon?';

  @override
  String get helpFilterAnswer =>
      'Na aba Pokédex, use a barra de busca e os filtros por tipo e geração para refinar os resultados exibidos.';

  @override
  String get helpMegaFormsQuestion =>
      'O que são mega evoluções e outras formas?';

  @override
  String get helpMegaFormsAnswer =>
      'Em Conta → PokeData, use os interruptores para exibir ou ocultar mega evoluções e formas alternativas na lista.';

  @override
  String get helpOfflineQuestion => 'O app funciona offline?';

  @override
  String get helpOfflineAnswer =>
      'Dados visitados recentemente podem aparecer a partir do cache local. Para buscar novos Pokémon ou atualizar informações, é necessária conexão com a internet.';

  @override
  String aboutVersion(Object version, Object build) {
    return 'Versão $version ($build)';
  }

  @override
  String get aboutVersionLoading => 'Versão …';

  @override
  String get aboutVersionUnavailable => 'Versão indisponível';

  @override
  String get aboutTagline =>
      'Pokedéx feita por fãs para explorar Pokémon, regiões, favoritos e detalhes com dados atualizados da PokéAPI.';

  @override
  String get aboutDevelopedBy => 'Desenvolvido por';

  @override
  String get aboutAcknowledgments => 'Agradecimentos';

  @override
  String get aboutCredits => 'Créditos';

  @override
  String get aboutKaiqueTitle => 'Kaique Simão';

  @override
  String get aboutKaiqueBody => 'Criador e desenvolvedor do PokeData.';

  @override
  String get aboutJuniorTitle => 'Junior Saraiva';

  @override
  String get aboutJuniorBody =>
      'Criou o design no Figma Community que serviu de referência visual para este projeto.';

  @override
  String get aboutLinkedInProfile => 'Perfil no LinkedIn';

  @override
  String get aboutFigmaProject => 'Projeto no Figma';

  @override
  String get aboutCreditPokeApiTitle => 'PokéAPI';

  @override
  String get aboutCreditPokeApiBody =>
      'Dados de Pokémon, espécies, tipos e evoluções.';

  @override
  String get aboutCreditFlutterTitle => 'Flutter';

  @override
  String get aboutCreditFlutterBody => 'Framework multiplataforma do app.';

  @override
  String get aboutCreditFirebaseTitle => 'Firebase';

  @override
  String get aboutCreditFirebaseBody =>
      'Autenticação, favoritos e sincronização em nuvem.';

  @override
  String get aboutDisclaimer =>
      'O PokeData é um aplicativo de fãs, não oficial. Não é desenvolvido, endossado ou afiliado à Nintendo, Creatures Inc., GAME FREAK ou The Pokémon Company. Pokémon © Nintendo / Creatures Inc. / GAME FREAK.';

  @override
  String get errorNetworkOffline => 'Sem conexão com a internet.';

  @override
  String get errorTooManyRequests =>
      'Muitas requisições. Aguarde um momento e tente novamente.';

  @override
  String get errorServiceUnavailable =>
      'O serviço está temporariamente indisponível. Tente novamente em instantes.';

  @override
  String get errorGenericRetry => 'Algo deu errado. Tente novamente.';

  @override
  String errorLoadDataWithStatus(int statusCode) {
    return 'Não foi possível carregar os dados ($statusCode). Tente novamente.';
  }

  @override
  String get errorLoadPokemonList =>
      'Não foi possível carregar a lista de Pokémon';

  @override
  String get errorLoadPokemon => 'Não foi possível carregar o Pokémon';

  @override
  String get errorLoadRegions => 'Não foi possível carregar as regiões';

  @override
  String get errorLoadRegion => 'Não foi possível carregar a região';

  @override
  String get errorLoadPokedex => 'Não foi possível carregar a PokeData';

  @override
  String get errorLoadGeneration => 'Não foi possível carregar a geração';

  @override
  String get errorLoadType => 'Não foi possível carregar o tipo';

  @override
  String get errorLoadAbility => 'Não foi possível carregar a habilidade';

  @override
  String get errorLoadEggGroup => 'Não foi possível carregar o grupo de ovos';

  @override
  String get errorLoadItem => 'Não foi possível carregar o item';

  @override
  String get errorLoadEvolutionChain =>
      'Não foi possível carregar a cadeia evolutiva';

  @override
  String get errorLoadSpecies => 'Não foi possível carregar a espécie';

  @override
  String get errorLoadForm => 'Não foi possível carregar a forma';

  @override
  String get offlineEmptyCacheDefault =>
      'Sem conexão e nenhum Pokémon salvo no dispositivo.\nConecte-se uma vez para baixar a PokeData.';

  @override
  String get offlinePokemonNotCached =>
      'Este Pokémon não está salvo no dispositivo.';

  @override
  String offlineRegionPokedexNotCached(Object regionName) {
    return 'A PokeData da região de $regionName não está salva no dispositivo.\nAbra esta região online pelo menos uma vez.';
  }

  @override
  String authPasswordTooShort(int minLength) {
    return 'A senha deve ter pelo menos $minLength caracteres.';
  }

  @override
  String authPasswordTooLong(int maxLength) {
    return 'A senha deve ter no máximo $maxLength caracteres.';
  }

  @override
  String get authEmailAlreadyInUseSignIn =>
      'Este e-mail já está em uso. Use \"Já tenho uma conta\" para entrar.';

  @override
  String get authEmailAlreadyInUseTrySocial =>
      'Este e-mail já está em uso. Tente entrar com Google ou use \"Já tenho uma conta\".';

  @override
  String get authInvalidCredentialsGeneric =>
      'Credenciais inválidas. Tente novamente.';

  @override
  String get profileSocialAccountCredentials =>
      'Contas Google ou Apple não permitem alterar senha, e-mail ou nome por aqui.';

  @override
  String get profileLogoutConfirmSemantics => 'Confirmação de saída da conta';

  @override
  String get profileLogoutConfirmTitle => 'Tem certeza que deseja sair?';

  @override
  String get profileLogoutConfirmYes => 'Sim, Sair';

  @override
  String get profileLogoutConfirmYesSemantics => 'Sim, sair da conta';

  @override
  String get profileLogoutConfirmNo => 'Não, Cancelar';

  @override
  String get profileLogoutConfirmNoSemantics => 'Não, cancelar saída';

  @override
  String get onboardingSlide1Title => 'Todos os Pokémon em um só Lugar';

  @override
  String get onboardingSlide1Subtitle =>
      'Acesse uma vasta lista de Pokémon de todas as gerações já feitas pela Nintendo';

  @override
  String get onboardingSlide2Title => 'Mantenha sua PokeData atualizada';

  @override
  String get onboardingSlide2Subtitle =>
      'Cadastre-se e mantenha seu perfil, Pokémon favoritos, configurações e muito mais, salvos no aplicativo, mesmo sem conexão com a internet.';

  @override
  String get onboardingContinueButton => 'Continuar';

  @override
  String get onboardingStartButton => 'Vamos começar!';

  @override
  String get profileCurrentPasswordLabel => 'Senha atual';

  @override
  String get profileSaveButton => 'Salvar';

  @override
  String get profileFinishButton => 'Concluir';

  @override
  String get profileBackToAccount => 'Voltar à conta';

  @override
  String get profileEditNameTitle => 'Editar nome';

  @override
  String get profileEditNameSubtitle =>
      'Este nome aparece no perfil e ao entrar na conta.';

  @override
  String get profileSecurityPasswordSubtitle =>
      'Por segurança, confirme sua senha antes de continuar.';

  @override
  String get changePasswordAppBarTitle => 'Trocar senha';

  @override
  String get changePasswordAppBarSuccess => 'Senha alterada';

  @override
  String get changePasswordHeadlineCurrent => 'Qual é sua senha atual?';

  @override
  String get changePasswordHeadlineConfirm => 'Confirme a nova senha';

  @override
  String get changePasswordSubtitleConfirm =>
      'Digite novamente a nova senha para confirmar.';

  @override
  String get changePasswordSaveButton => 'Salvar senha';

  @override
  String get changePasswordSuccessTitle => 'Senha alterada com sucesso!';

  @override
  String get changePasswordSuccessSubtitle =>
      'Sua nova senha já está ativa. Use-a no próximo login.';

  @override
  String get changeEmailAppBarTitle => 'Trocar e-mail';

  @override
  String get changeEmailAppBarSuccess => 'E-mail atualizado';

  @override
  String get changeEmailNewEmailLabel => 'Novo e-mail';

  @override
  String get changeEmailHeadlineCurrentPassword => 'Qual é sua senha atual?';

  @override
  String get changeEmailHeadlineNewEmail => 'Qual é o novo e-mail?';

  @override
  String get changeEmailHeadlineVerify => 'Confirme o novo e-mail';

  @override
  String get changeEmailSubtitleNewEmailFirebase =>
      'Enviaremos um link de verificação para o novo endereço.';

  @override
  String get changeEmailSubtitleNewEmailMock =>
      'Informe o novo e-mail da sua conta.';

  @override
  String changeEmailSubtitleVerifyFirebase(Object email) {
    return 'Abra o link enviado para $email e toque em \"Já confirmei\".';
  }

  @override
  String get changeEmailSendVerificationButton => 'Enviar verificação';

  @override
  String get changeEmailConfirmCodeButton => 'Confirmar código';

  @override
  String get changeEmailSuccessTitle => 'E-mail atualizado!';

  @override
  String changeEmailSuccessSubtitle(Object email) {
    return 'Sua conta agora usa $email.';
  }

  @override
  String get authRegisterSuccessTitle => 'Sua conta foi criada com Sucesso!';

  @override
  String get authRegisterSuccessSubtitle =>
      'Seja bem-vindo, treinador! Estamos animados para acompanhar sua jornada.';

  @override
  String get trainerAvatarBugCatcherLabel => 'Caçador de Insetos';

  @override
  String get trainerAvatarPokemaniacLabel => 'Pokémaníaco';

  @override
  String get pokemonImageLoadingSemantics => 'Carregando imagem do Pokémon';

  @override
  String get pokemonCryPlaySemantics => 'Reproduzir som do Pokémon';

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
    return '$formLabel, deslize para ver outras formas';
  }

  @override
  String get firebaseConfigErrorTitle => 'Configuração indisponível';

  @override
  String get firebaseConfigErrorBody =>
      'Este build de produção requer Firebase. Configure dart_defines.json e reconstrua o app com --dart-define-from-file=dart_defines.json.';
}
