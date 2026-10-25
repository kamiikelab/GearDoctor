// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'GearDoctor';

  @override
  String startupFailed(String error) {
    return 'Démarrage impossible\n$error';
  }

  @override
  String get settings => 'Réglages';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Selon l\'appareil';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get userHelp => 'Aide';

  @override
  String get userHelpOn => 'Afficher';

  @override
  String get userHelpOff => 'Masquer';

  @override
  String get connected => 'Connecté';

  @override
  String get notConnected => 'Non connecté';

  @override
  String get stravaOptional => 'La connexion Strava est facultative.';

  @override
  String get stravaHint =>
      'La connexion est facultative. Vous pouvez aussi saisir les sorties à la main.';

  @override
  String get stravaConnect => 'Connexion Strava';

  @override
  String get stravaSync => 'Ajouter une sortie';

  @override
  String get gear => 'Vélos';

  @override
  String get gearHint =>
      'Le vélo dont la distance est calculée, et ses relevés de remplacement.';

  @override
  String get resetSection => 'Réinitialiser';

  @override
  String get resetHint =>
      'Efface Strava, les sorties, les pièces et les relevés, puis rétablit la démo du premier lancement.';

  @override
  String get resetToDemo => 'Revenir à la démo';

  @override
  String get resetConfirmTitle => 'Revenir à l\'état du premier lancement ?';

  @override
  String get resetConfirmBody =>
      'Cela supprime la connexion Strava, les sorties, les réglages des pièces et les relevés de remplacement.\n\nL\'application revient à la même démo qu\'au premier lancement.';

  @override
  String get cancel => 'Annuler';

  @override
  String get resetConfirmAction => 'Effacer et réinitialiser';

  @override
  String get resetDone => 'Retour à l\'état de démo.';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Enregistrer';

  @override
  String get gearUnselected => 'Aucun sélectionné';

  @override
  String gearLabel(String name) {
    return 'Vélo : $name';
  }

  @override
  String get gearNone => 'Vélo : aucun sélectionné';

  @override
  String lastSync(String range) {
    return 'Sorties $range';
  }

  @override
  String get notSynced => 'Aucune sortie';

  @override
  String syncRangeOpen(String from) {
    return '$from–—';
  }

  @override
  String syncRange(String from, String to) {
    return '$from–$to';
  }

  @override
  String get demoBanner => 'Ajoutez une sortie pour quitter la démo.';

  @override
  String alertCount(int count) {
    return '$count au seuil';
  }

  @override
  String get demoSuffix => ' (démo)';

  @override
  String get selectedSuffix => ' (sélectionné)';

  @override
  String get demoSelectedSuffix => ' (démo, sélectionné)';

  @override
  String get todaySuffix => ' (aujourd\'hui)';

  @override
  String get unitKm => 'km';

  @override
  String get unitMonths => 'mois';

  @override
  String get limitModeRecommended => 'Défaut';

  @override
  String get limitModeAuto => 'Auto';

  @override
  String get limitModeCustom => 'Personnalisé';

  @override
  String get limitModeAutoFallback => 'Auto (défaut)';

  @override
  String get statusOk => 'OK';

  @override
  String get statusSoon => 'Bientôt';

  @override
  String get statusOverdue => 'Remplacer';

  @override
  String statusLine(String status, int percent) {
    return '$status · $percent%';
  }

  @override
  String statusLineSide(String side, String status, int percent) {
    return '$side : $status · $percent%';
  }

  @override
  String get demoRequiresSyncTitle => 'Ajoutez d\'abord une sortie';

  @override
  String get demoRequiresSyncMessage =>
      'Pendant la démo, vous ne pouvez pas ajouter, supprimer ou importer des pièces.';

  @override
  String get gearDemoCsvHint =>
      'Pendant la démo, vous ne pouvez pas ajouter, supprimer ou importer des pièces. Ajoutez d\'abord une sortie.';

  @override
  String get gearEmptyHint =>
      'Ajoutez un vélo, ou importez-le depuis Strava, et il apparaîtra ici.';

  @override
  String get gearBikesHelp =>
      'Vous pouvez choisir les vélos importés de Strava ou ajoutés par leur nom. L\'ajout de pièces, les réglages, les relevés et le CSV s\'appliquent au vélo sélectionné. Les pièces initiales sont les mêmes.';

  @override
  String get addBike => 'Ajouter un vélo';

  @override
  String get deleteBike => 'Supprimer le vélo';

  @override
  String get deleteBikeTitle => 'Supprimer ce vélo ?';

  @override
  String deleteBikeConfirm(String name) {
    return 'Cela supprime aussi les pièces, les relevés et les sorties de $name.';
  }

  @override
  String get cannotDeleteStravaBike =>
      'Les vélos importés de Strava ne peuvent pas être supprimés ici.';

  @override
  String get bikeName => 'Nom';

  @override
  String get bikeNameHint => 'Route';

  @override
  String get addBikeAction => 'Ajouter';

  @override
  String get bikeNameRequired => 'Saisissez un nom';

  @override
  String get gearSelectHint =>
      'Sélectionnez un vélo ci-dessus pour ajouter des pièces et des relevés.';

  @override
  String get addPart => 'Ajouter une pièce';

  @override
  String get editPart => 'Modifier la pièce';

  @override
  String get recordsCsv => 'CSV des relevés de remplacement';

  @override
  String get settingsCsv => 'CSV d\'enregistrement des pièces';

  @override
  String get displayGroups => 'Grouper / séparer l\'affichage des pièces';

  @override
  String get registeredName => 'Nom enregistré';

  @override
  String get registeredNameHint => 'Nom (pneu avant, pile cardio, …)';

  @override
  String get registeredNameHelp =>
      'Nom affiché sur l\'accueil. Enregistrez l\'avant et l\'arrière séparément.';

  @override
  String get firstReplacementNoRide =>
      'La première date de remplacement est la sortie la plus ancienne de ce vélo. S\'il n\'y a pas encore de sortie, c\'est aujourd\'hui.';

  @override
  String firstReplacementWithRide(String date) {
    return 'La première date de remplacement est la sortie la plus ancienne de ce vélo ($date). Vous ne la saisissez pas.';
  }

  @override
  String get cycle => 'Intervalle';

  @override
  String get cycleHelp => 'Distance ou mois, pas les deux.';

  @override
  String get cycleDistance => 'Distance';

  @override
  String get cycleMonths => 'Mois';

  @override
  String get limit => 'Objectif de remplacement';

  @override
  String limitRecommended(String amount, String unit) {
    return 'Défaut  $amount $unit';
  }

  @override
  String get limitRecommendedHelp =>
      'Déterminé automatiquement d\'après le nom.';

  @override
  String get limitAutoEmpty => 'Auto  —';

  @override
  String limitAuto(String amount, String unit) {
    return 'Auto  $amount $unit';
  }

  @override
  String get limitAutoHelp =>
      'Écart entre les deux derniers remplacements. Recalculé à chaque fois.';

  @override
  String limitCustom(String amount, String unit) {
    return 'Personnalisé  $amount $unit';
  }

  @override
  String get limitCustomHelp => 'Vous saisissez le nombre.';

  @override
  String get customValue => 'Valeur personnalisée';

  @override
  String get threshold => 'Seuil d\'alerte';

  @override
  String get nameRequired => 'Saisissez un nom enregistré';

  @override
  String get customLimitInvalid =>
      'L\'objectif personnalisé doit être un nombre supérieur ou égal à 1';

  @override
  String get thresholdInvalid => 'Le seuil doit être un entier de 1 à 100';

  @override
  String get selectGearFirstPart =>
      'Sélectionnez un vélo avant d\'ajouter une pièce';

  @override
  String get partDetail => 'Détail de la pièce';

  @override
  String get partNotFound => 'Pièce introuvable';

  @override
  String get afterMonths => 'Temps depuis le remplacement';

  @override
  String get afterDistance => 'Distance depuis le remplacement';

  @override
  String thresholdPct(int pct) {
    return 'Seuil $pct %';
  }

  @override
  String get lastReplacementNone => 'Dernier remplacement : aucun';

  @override
  String lastReplacement(String date) {
    return 'Dernier remplacement $date';
  }

  @override
  String get replaced => 'Remplacé';

  @override
  String get edit => 'Modifier';

  @override
  String get historyTitle => 'Remplacements passés';

  @override
  String get historyHint =>
      'Touchez une ligne pour modifier la date, le commentaire ou supprimer';

  @override
  String get historyDistanceHeader => 'Distance du vélo';

  @override
  String get replacedOn => 'Date';

  @override
  String get comment => 'Commentaire';

  @override
  String get recordReplace => 'Noter un remplacement';

  @override
  String get replaceDateHelp =>
      'La valeur initiale est aujourd\'hui. Si vous avez oublié, mettez la date réelle.';

  @override
  String get memo => 'Mémo';

  @override
  String get memoHint => 'Nom du produit, motif, … (facultatif)';

  @override
  String get logReplacement => 'Enregistrer';

  @override
  String get editRecord => 'Modifier le relevé';

  @override
  String get editRide => 'Modifier la sortie';

  @override
  String get recordNotFound => 'Relevé introuvable';

  @override
  String get rideNotFound => 'Sortie introuvable';

  @override
  String get editRecordHelp =>
      'Changer la date recompte la distance de cette période';

  @override
  String get cannotDeleteLastRecord =>
      'Le dernier relevé ne peut pas être supprimé';

  @override
  String get deleteThisRecord => 'Supprimer ce relevé';

  @override
  String get deleteThisPart => 'Supprimer cette pièce';

  @override
  String get deletePartTitle => 'Supprimer cette pièce ?';

  @override
  String deletePartConfirm(String name) {
    return 'Cela supprime aussi les relevés de remplacement de $name. Un groupe d\'affichage est séparé.';
  }

  @override
  String get connectAgain => 'Reconnecter';

  @override
  String get connect => 'Connecter';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String get howToConnect => 'Comment se connecter';

  @override
  String get clientIdHint => 'Numéro de votre application API Strava';

  @override
  String get clientSecretHint =>
      'Valeur affichée avec Afficher sur la page API Strava';

  @override
  String get waitingBrowser =>
      'Quand Chrome affiche une page, fermez cette page. La fermer remet le bouton de connexion au vert. L\'application ne passera pas au premier plan.';

  @override
  String get waitingBrowserMobile =>
      'L\'écran d\'autorisation Strava s\'ouvre. Après votre accord, vous revenez dans cette application.';

  @override
  String get waitingBrowserIos =>
      'Si l\'iPhone demande d\'ouvrir le Web, touchez Continuer. Si vous êtes déconnecté, la connexion Strava s\'affiche. Si vous êtes déjà connecté et avez autorisé cette application, le retour peut être immédiat.';

  @override
  String get browserDidNotOpen =>
      'Chrome ne s\'est pas ouvert tout seul. Copiez l\'URL ci-dessous et ouvrez-la dans Chrome.';

  @override
  String get copyAuthorizeUrl => 'Copier l\'URL d\'autorisation';

  @override
  String get copiedAuthorizeUrl =>
      'URL d\'autorisation copiée. Collez-la dans la barre d\'adresse de Chrome.';

  @override
  String get connectStep1 =>
      '1. Créez une application dans les réglages API Strava';

  @override
  String get stravaPaidApi => 'L\'API Strava nécessite un abonnement payant.';

  @override
  String get connectStep2 =>
      '2. Saisissez le Client ID et le Client Secret ci-dessus';

  @override
  String get noAccessToken =>
      'Cette application n\'utilise pas le champ Access Token.';

  @override
  String get connectStep3 => '3. Touchez Connecter';

  @override
  String get connectStep3Help =>
      'Sur un téléphone, vous revenez dans l\'application après avoir autorisé. Sur un ordinateur, Chrome s\'ouvre. Après l\'autorisation, une page 127.0.0.1 apparaît. Vous devez fermer cette page. Sinon, le bouton de connexion reste gris. Sur un ordinateur, l\'application ne passe pas au premier plan. C\'est réussi quand cet écran indique Connecté et que le bouton est de nouveau vert. Récupérez les sorties depuis Ajouter une sortie.';

  @override
  String get connectStep3HelpIos =>
      'Touchez Connecter, puis Continuer quand l\'iPhone demande d\'ouvrir le Web. Si vous êtes déconnecté, la connexion Strava s\'affiche. Si vous êtes déjà connecté et avez autorisé cette application, le retour peut être immédiat. C\'est réussi quand cet écran indique Connecté et que le bouton est de nouveau vert. Récupérez les sorties depuis Ajouter une sortie.';

  @override
  String get connectStep4 => '4. Si Chrome ne s\'ouvre pas';

  @override
  String get connectStep4Help =>
      'Après Connecter, copiez l\'URL d\'autorisation et collez-la dans Chrome. Fermez ensuite la page d\'information comme à l\'étape 3 ; le bouton redevient vert.';

  @override
  String get enterClientIdSecret =>
      'Saisissez le Client ID et le Client Secret.';

  @override
  String portBusy(int port) {
    return 'Impossible d\'ouvrir le port $port. Quittez l\'autre processus et reconnectez-vous.';
  }

  @override
  String tokenSaved(String name) {
    return 'Jeton enregistré sur cet appareil ($name).';
  }

  @override
  String get disconnected => 'Déconnecté et jetons supprimés.';

  @override
  String get syncTitle => 'Ajouter une sortie';

  @override
  String get manualRideSection => 'Saisie manuelle';

  @override
  String get importFromStrava => 'Importer depuis Strava';

  @override
  String get notConnectedImportHint =>
      'Non connecté. Connectez Strava dans Réglages.';

  @override
  String get goToStravaConnect => 'Connexion Strava';

  @override
  String get rideDate => 'Date';

  @override
  String get rideDistance => 'Distance';

  @override
  String get needGearForRide =>
      'Sélectionnez un vélo avant d\'enregistrer une sortie';

  @override
  String get invalidRideDistance => 'La distance doit être supérieure à 0';

  @override
  String get rideRecorded => 'Sortie enregistrée.';

  @override
  String get rideUpdated => 'Sortie mise à jour.';

  @override
  String get rideDeleted => 'Sortie supprimée.';

  @override
  String get viewRides => 'Voir les sorties';

  @override
  String get rideHistoryHint =>
      'Touchez une ligne saisie à la main pour modifier la date, la distance ou supprimer';

  @override
  String get rideKind => 'Type';

  @override
  String get rideKindManual => 'Manuel';

  @override
  String get rideKindStrava => 'Strava';

  @override
  String get rideKindDemo => 'Démo';

  @override
  String get deleteThisRide => 'Supprimer cette sortie';

  @override
  String get gearRidesSection => 'Sorties de ce vélo';

  @override
  String get gearRidesReadOnly => 'Sorties de ce vélo (consultation seule)';

  @override
  String get noGearRides => 'Pas encore de sortie sur ce vélo.';

  @override
  String get stravaHintManual =>
      'Les sorties saisies à la main sont supprimées lors de l\'import.';

  @override
  String get stravaHintStrava =>
      'Les sorties Strava sont en consultation seule. Vous ne pouvez pas saisir de sortie à la main.';

  @override
  String get switchToStravaTitle => 'Passer à Strava ?';

  @override
  String get switchToStravaConfirm =>
      'Toutes les sorties saisies à la main seront supprimées, puis importées. Cela concerne tous les vélos.';

  @override
  String get switchToManual => 'Passer à la saisie manuelle';

  @override
  String get switchToManualTitle => 'Passer à la saisie manuelle ?';

  @override
  String get switchToManualConfirm =>
      'Toutes les sorties importées de Strava seront supprimées. La connexion Strava reste.';

  @override
  String get deleteRideTitle => 'Supprimer cette sortie ?';

  @override
  String deleteRideConfirm(String date, String km) {
    return 'Supprimer $km km le $date.';
  }

  @override
  String get cancelEditRide => 'Annuler la modification';

  @override
  String stravaStartDate(String value) {
    return 'Date de début Strava  $value';
  }

  @override
  String untilDate(String value) {
    return 'Jusqu\'au  $value';
  }

  @override
  String get untilDateHelp =>
      'La date de fin est la sortie la plus récente à partir de la date de début Strava.';

  @override
  String get syncManualHelp =>
      'Choisissez une période et importez. Rien n\'est récupéré automatiquement.';

  @override
  String get sync3months => '3 derniers mois';

  @override
  String get sync6months => '6 derniers mois';

  @override
  String get sync1year => 'Importer la dernière année';

  @override
  String get changeStartDate => 'Modifier la date de début Strava';

  @override
  String get specifyStartDate => 'Définir la date de début Strava';

  @override
  String get startDateHelp =>
      'Modifier la date de début Strava supprime les sorties importées. Les sorties saisies à la main restent. Utilisez Importer la dernière année pour réimporter depuis la nouvelle date.';

  @override
  String get needStartDate => 'Définissez d\'abord une date de début Strava.';

  @override
  String get needConnect =>
      'Connectez-vous d\'abord depuis l\'écran de connexion Strava.';

  @override
  String get changeStartTitle => 'Modifier la date de début Strava ?';

  @override
  String get changeStartBody =>
      'Les sorties Strava importées seront supprimées. Les sorties saisies à la main restent.\n\nRien n\'est récupéré maintenant. Utilisez Importer la dernière année pour réimporter depuis la nouvelle date de début Strava.';

  @override
  String get deleteAndContinue => 'Supprimer et continuer';

  @override
  String get dataRange => 'Plage Strava récupérée';

  @override
  String get emDash => '—';

  @override
  String get csvCopyHint =>
      'Affiché dans le champ pour que vous puissiez le copier.';

  @override
  String get recordsCsvHint => 'Nom enregistré,Date,Mémo';

  @override
  String get settingsCsvHint =>
      'Nom enregistré,Intervalle,Objectif,Défaut,Personnalisé,Seuil,Groupe,Position';

  @override
  String get exportCurrentRecords => 'Exporter les relevés actuels';

  @override
  String get exportCurrentSettings => 'Exporter les réglages actuels';

  @override
  String get insertExample => 'Insérer un exemple';

  @override
  String get importCsv => 'Importer le CSV';

  @override
  String get confirm => 'Confirmer';

  @override
  String get fixThese => 'À corriger';

  @override
  String get recordsCsvScope =>
      'L\'import et l\'export ne concernent que les relevés de ce vélo. Les autres vélos restent inchangés.';

  @override
  String get recordsCsvHelp =>
      'Les pièces ne sont pas créées. Les lignes correspondent par le nom enregistré (par ex. pneu avant). Les relevés de ce vélo pour les noms présents dans le CSV sont remplacés.';

  @override
  String get settingsCsvScope =>
      'L\'import et l\'export ne concernent que les réglages des pièces de ce vélo. Les autres vélos restent inchangés.';

  @override
  String get settingsCsvHelp =>
      'Les lignes correspondent par le nom enregistré. Les noms absents ajoutent des pièces. Les réglages et groupes du CSV remplacent ceux de ce vélo seulement. Les relevés ne changent pas.';

  @override
  String get noNewRows => 'Il n\'y a pas de nouvelle ligne.';

  @override
  String replaceCount(int count) {
    return 'Remplacer $count';
  }

  @override
  String partsApplyCount(int count) {
    return '$count pièces';
  }

  @override
  String get exportedEmptyRecords =>
      'Aucun relevé de remplacement. Seul l\'en-tête a été exporté.';

  @override
  String exportedCount(int count) {
    return '$count lignes placées dans le champ et copiées.';
  }

  @override
  String get exportedEmptySettings =>
      'Aucune pièce. Seul l\'en-tête a été exporté.';

  @override
  String importedSettings(int updated, int created, String groups) {
    return '$updated mis à jour, $created ajoutés$groups sur ce vélo.';
  }

  @override
  String importedRecords(int added) {
    return '$added importés. Les relevés plus anciens de ce vélo pour les noms du CSV ont été remplacés.';
  }

  @override
  String skippedDuplicates(int count) {
    return ' $count doublons dans le CSV ont été ignorés.';
  }

  @override
  String get groupTitle => 'Groupes d\'affichage';

  @override
  String get groupHelp =>
      'L\'accueil affiche une ligne. Les pièces restent séparées.';

  @override
  String get groupTogether => 'Afficher groupé';

  @override
  String get groupSplit => 'Afficher séparé';

  @override
  String get groupNeedTwo =>
      'Pas assez de pièces à grouper. Ajoutez-en d\'abord deux avec un nom enregistré.';

  @override
  String get groupNameHint => 'Pneus';

  @override
  String groupPreview(String name) {
    return 'L\'accueil affiche « $name ». La gauche est R, la droite est F';
  }

  @override
  String get groupNamePlaceholder => '(nom)';

  @override
  String get noGroups => 'Il n\'y a pas de groupe.';

  @override
  String get groupToRemove => 'Groupe à séparer';

  @override
  String get afterSplit => 'Noms après séparation (noms enregistrés)';

  @override
  String get groupSplitHelp =>
      'Les noms enregistrés ne changent pas. N\'ajoutez pas F/R à la fin.';

  @override
  String get enterGroupName => 'Saisissez un nom de groupe';

  @override
  String get partsNotFound => 'Pièces introuvables';

  @override
  String get sameCycleOnly =>
      'Seules les pièces avec le même intervalle peuvent être groupées';

  @override
  String get selectGroupToSplit => 'Sélectionnez un groupe à séparer';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client Secret';

  @override
  String get csvLabel => 'CSV';

  @override
  String get csvNeedGear => 'Sélectionnez un vélo pour utiliser cet écran.';

  @override
  String skipCsvDuplicatesPreview(int count) {
    return ', ignorer $count doublons dans le CSV';
  }

  @override
  String groupsCountPreview(int count) {
    return ', $count groupes';
  }

  @override
  String replaceResetHelp(String name, String usage) {
    return 'Noter la date de remplacement de $name ne remet à zéro que la $usage de cette position.';
  }

  @override
  String get usageDistance => 'distance';

  @override
  String get usageMonths => 'mois écoulés';

  @override
  String statusPercent(int percent, String status) {
    return '$percent% · $status';
  }

  @override
  String syncFetchedEmpty(String from, String to) {
    return 'Récupéré du $from au $to. Aucune sortie à vélo sur cette période.';
  }

  @override
  String syncFetched(String from, String to, int count, String newest) {
    return 'Récupéré du $from au $to. $count sorties à vélo. La plus récente est le $newest.';
  }

  @override
  String get startDateUnchanged => 'La date de début Strava est inchangée.';

  @override
  String startDateChanged(String date) {
    return 'La date de début Strava est maintenant le $date. Les sorties importées ont été effacées. Utilisez Importer la dernière année pour réimporter.';
  }

  @override
  String changeStartConfirm(String date) {
    return 'Définir la date de début Strava au $date.\n\nLes sorties Strava importées seront supprimées. Les sorties saisies à la main restent.\n\nRien n\'est récupéré maintenant. Utilisez Importer la dernière année pour réimporter depuis la nouvelle date de début Strava.';
  }

  @override
  String get pickTwoParts => '1. Choisir deux pièces';

  @override
  String get pickFront => '2. Laquelle est F';

  @override
  String get groupedNameStep => '3. Nom du groupe';

  @override
  String get pickedSuffix => ' (sélectionné)';

  @override
  String partIsFront(String name) {
    return '$name est F';
  }

  @override
  String stopGrouping(String name) {
    return 'Arrêter de grouper « $name ». Les cartes utiliseront les noms enregistrés.';
  }

  @override
  String get pickTwoAndFront => 'Choisissez deux pièces et laquelle est F';

  @override
  String get waitingForChrome =>
      'En attente de l\'autorisation Strava dans Chrome…';

  @override
  String get closeChromeSuccess =>
      'Quand Chrome affiche une page, fermez-la. C\'est réussi quand le bouton de connexion redevient vert.';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get couldNotOpenBrowser => 'Impossible d\'ouvrir le navigateur.';

  @override
  String get languageFrench => 'Français';

  @override
  String get selectGearFirstRecord =>
      'Sélectionnez un vélo avant de noter un remplacement';

  @override
  String get selectGearFirstCsv =>
      'Sélectionnez un vélo avant d\'importer un CSV';

  @override
  String get selectGearFirstGroup =>
      'Sélectionnez un vélo avant de grouper l\'affichage';

  @override
  String get rideNotOnThisBike => 'Ce n\'est pas une sortie de ce vélo';

  @override
  String get cannotEditStravaRide => 'Les sorties Strava ne se modifient pas';

  @override
  String get cannotDeleteStravaRide =>
      'Les sorties Strava ne se suppriment pas';

  @override
  String get databaseNotOpen => 'La base de données n\'est pas encore ouverte';

  @override
  String csvRecordsHeaderError(String ja, String en, String fr) {
    return 'La 1re ligne doit être $ja, $en ou $fr.';
  }

  @override
  String csvSettingsHeaderError(String ja, String en, String fr) {
    return 'La 1re ligne doit être $ja, $en ou $fr.';
  }

  @override
  String csvNeedNameAndDate(int line) {
    return 'Ligne $line : le nom enregistré et la date sont requis.';
  }

  @override
  String csvEmptyName(int line) {
    return 'Ligne $line : le nom enregistré est vide.';
  }

  @override
  String csvEmptyDate(int line) {
    return 'Ligne $line : la date est vide. Indiquez YYYY/MM/DD, ou laissez vide pour la première sortie de ce vélo.';
  }

  @override
  String csvBadDate(int line) {
    return 'Ligne $line : la date doit être YYYY/MM/DD.';
  }

  @override
  String get csvEmpty => 'Le CSV est vide.';

  @override
  String get csvNoRows => 'Il n\'y a pas de ligne de données.';

  @override
  String csvPartMissing(int line, String name) {
    return 'Ligne $line : aucune pièce nommée « $name ». Ajoutez d\'abord la pièce.';
  }

  @override
  String csvDuplicateName(int line, String name) {
    return 'Ligne $line : le nom enregistré « $name » existe en plusieurs exemplaires.';
  }

  @override
  String csvSettingsNeedFields(int line) {
    return 'Ligne $line : le nom enregistré, l\'intervalle, l\'objectif, la valeur par défaut, la valeur personnalisée et le seuil sont requis.';
  }

  @override
  String csvBadCycle(int line) {
    return 'Ligne $line : l\'intervalle doit être Distance ou Mois.';
  }

  @override
  String csvBadLimitMode(int line) {
    return 'Ligne $line : l\'objectif doit être Défaut, Auto ou Personnalisé.';
  }

  @override
  String csvBadRecommended(int line) {
    return 'Ligne $line : la valeur par défaut doit être un entier supérieur ou égal à 1.';
  }

  @override
  String csvBadCustom(int line) {
    return 'Ligne $line : la valeur personnalisée doit être un entier supérieur ou égal à 1.';
  }

  @override
  String csvBadThreshold(int line) {
    return 'Ligne $line : le seuil doit être un entier de 1 à 100.';
  }

  @override
  String csvBadSide(int line) {
    return 'Ligne $line : la position doit être F ou R.';
  }

  @override
  String csvSideNeedsGroup(int line) {
    return 'Ligne $line : un nom de groupe est requis quand une position est indiquée.';
  }

  @override
  String csvGroupNeedsSide(int line) {
    return 'Ligne $line : la position doit être F ou R quand un groupe est indiqué.';
  }

  @override
  String csvDuplicateInFile(int line, String name) {
    return 'Ligne $line : le nom enregistré « $name » est en double dans le CSV.';
  }

  @override
  String csvNameAmbiguous(int line, String name) {
    return 'Ligne $line : il y a plusieurs pièces nommées « $name ».';
  }

  @override
  String csvGroupNeedsBothSides(String name) {
    return 'Le groupe « $name » doit avoir un F et un R.';
  }

  @override
  String csvGroupOverlap(String name) {
    return 'Les pièces du groupe « $name » chevauchent un autre groupe.';
  }

  @override
  String get authCancelled => 'Autorisation annulée';

  @override
  String authFailed(String error) {
    return 'L\'autorisation a échoué ($error)';
  }

  @override
  String get authStateMismatch =>
      'La réponse d\'autorisation ne correspond pas. Reconnectez-vous.';

  @override
  String get authCodeMissing =>
      'Il n\'y a pas de code d\'autorisation. Vérifiez code= dans la barre d\'adresse.';

  @override
  String get pasteCode => 'Collez le code';

  @override
  String get pasteCodeUnreadable =>
      'Impossible de lire un code dans le texte collé';

  @override
  String tokenFailed(int code) {
    return 'Impossible d\'obtenir le jeton ($code)';
  }

  @override
  String get tokenIncomplete => 'La réponse du jeton est incomplète';

  @override
  String get stravaUserFallback => 'Utilisateur Strava';

  @override
  String get listenNotStarted => 'L\'écoute n\'a pas commencé';

  @override
  String get listenTimedOut =>
      'Délai dépassé en attendant le navigateur. Reconnectez-vous.';

  @override
  String get authAborted => 'Connexion annulée';

  @override
  String get rateLimited =>
      'Limite de requêtes Strava atteinte. Réessayez plus tard.';

  @override
  String get authInvalid =>
      'L\'autorisation Strava n\'est plus valable. Reconnectez-vous depuis l\'écran Strava.';

  @override
  String stravaFetchFailed(int code) {
    return 'Échec de la récupération depuis Strava ($code)';
  }

  @override
  String get tokenRefreshNeedsSecret =>
      'Le renouvellement du jeton exige le Client ID et le Secret. Vérifiez l\'écran de connexion Strava.';

  @override
  String get activitiesUnreadable =>
      'Impossible de lire la réponse de la liste des sorties';

  @override
  String get tooManyActivities =>
      'Le volume dépasse ce qui peut être récupéré d\'un coup. Raccourcissez la période et réessayez.';

  @override
  String browserAuthFailed(String code) {
    return 'L\'autorisation dans le navigateur a échoué ($code)';
  }

  @override
  String get loopbackSuccess =>
      'Connecté à GearDoctor. Fermez cet onglet. L\'application ne passera pas au premier plan. C\'est réussi quand le bouton de connexion redevient vert.';
}
