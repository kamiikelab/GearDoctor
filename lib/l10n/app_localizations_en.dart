// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GearDoctor';

  @override
  String startupFailed(String error) {
    return 'Couldn\'t start\n$error';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Match device';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get connected => 'Connected';

  @override
  String get notConnected => 'Not connected';

  @override
  String get stravaHint =>
      'Connect to import rides. Steps are on the next screen.';

  @override
  String get stravaConnect => 'Strava connect';

  @override
  String get stravaSync => 'Strava sync';

  @override
  String get gear => 'Bikes';

  @override
  String get gearHint =>
      'The bike whose distance is added, and its replacement records.';

  @override
  String get resetSection => 'Reset';

  @override
  String get resetHint =>
      'Clears Strava, rides, parts, and records, then restores the first-run demo.';

  @override
  String get resetToDemo => 'Reset to demo';

  @override
  String get resetConfirmTitle => 'Reset to the first-run state?';

  @override
  String get resetConfirmBody =>
      'This deletes Strava connection, rides, part settings, and replacement records.\n\nThe app returns to the same demo as first launch.';

  @override
  String get cancel => 'Cancel';

  @override
  String get resetConfirmAction => 'Delete and reset';

  @override
  String get resetDone => 'Reset to the demo state.';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get gearUnselected => 'None selected';

  @override
  String gearLabel(String name) {
    return 'Bike: $name';
  }

  @override
  String get gearNone => 'Bike: none selected';

  @override
  String lastSync(String range) {
    return 'Last sync $range';
  }

  @override
  String get notSynced => 'Not synced';

  @override
  String syncRangeOpen(String from) {
    return '$from–—';
  }

  @override
  String syncRange(String from, String to) {
    return '$from–$to';
  }

  @override
  String get demoBanner =>
      'Sync Strava to leave the demo. The first import replaces demo rides.';

  @override
  String alertCount(int count) {
    return '$count at threshold';
  }

  @override
  String get demoSuffix => ' (demo)';

  @override
  String get selectedSuffix => ' (selected)';

  @override
  String get demoSelectedSuffix => ' (demo, selected)';

  @override
  String get todaySuffix => ' (today)';

  @override
  String get unitKm => 'km';

  @override
  String get unitMonths => 'mo';

  @override
  String get limitModeRecommended => 'Recommended';

  @override
  String get limitModeAuto => 'Auto';

  @override
  String get limitModeCustom => 'Custom';

  @override
  String get limitModeAutoFallback => 'Auto (recommended)';

  @override
  String get statusOk => 'OK';

  @override
  String get statusSoon => 'Soon';

  @override
  String get statusOverdue => 'Replace';

  @override
  String statusLine(String status, int percent) {
    return '$status · $percent%';
  }

  @override
  String statusLineSide(String side, String status, int percent) {
    return '$side: $status · $percent%';
  }

  @override
  String get demoRequiresSyncTitle => 'Sync Strava first';

  @override
  String get demoRequiresSyncMessage =>
      'You can\'t add parts or use CSV while the demo is on.';

  @override
  String get gearDemoCsvHint =>
      'You can\'t add parts or use CSV during the demo. Sync Strava first.';

  @override
  String get gearEmptyHint => 'Sync Strava first and bikes will appear here.';

  @override
  String get gearBikesHelp =>
      'You can only pick bikes imported from Strava. Adding parts, settings, records, and CSV apply to the selected bike. The initial parts are the same.';

  @override
  String get gearSelectHint => 'Select a bike above to add parts and records.';

  @override
  String get addPart => 'Add part';

  @override
  String get editPart => 'Edit part';

  @override
  String get recordsCsv => 'Records CSV';

  @override
  String get settingsCsv => 'Parts CSV';

  @override
  String get displayGroups => 'Group / split display';

  @override
  String get registeredName => 'Registered name';

  @override
  String get registeredNameHint => 'Name (front tire, HR battery, …)';

  @override
  String get registeredNameHelp =>
      'Name shown on Home. Register left and right separately.';

  @override
  String get firstReplacementNoRide =>
      'The first replacement date is this bike\'s oldest ride. If there are no rides yet, it is today.';

  @override
  String firstReplacementWithRide(String date) {
    return 'The first replacement date is this bike\'s oldest ride ($date). You don\'t enter it.';
  }

  @override
  String get cycle => 'Interval';

  @override
  String get cycleHelp => 'Distance or months, not both.';

  @override
  String get cycleDistance => 'Distance';

  @override
  String get cycleMonths => 'Months';

  @override
  String get limit => 'Replacement target';

  @override
  String limitRecommended(String amount, String unit) {
    return 'Recommended  $amount $unit';
  }

  @override
  String get limitRecommendedHelp => 'Set automatically from the name.';

  @override
  String get limitAutoEmpty => 'Auto  —';

  @override
  String limitAuto(String amount, String unit) {
    return 'Auto  $amount $unit';
  }

  @override
  String get limitAutoHelp =>
      'Gap between the last two replacements. Recalculated each time.';

  @override
  String limitCustom(String amount, String unit) {
    return 'Custom  $amount $unit';
  }

  @override
  String get limitCustomHelp => 'You type the number.';

  @override
  String get customValue => 'Custom value';

  @override
  String get threshold => 'Alert threshold';

  @override
  String get nameRequired => 'Enter a registered name';

  @override
  String get customLimitInvalid =>
      'Custom target must be a number of 1 or more';

  @override
  String get thresholdInvalid => 'Threshold must be an integer from 1 to 100';

  @override
  String get selectGearFirstPart => 'Select a bike before adding a part';

  @override
  String get partDetail => 'Part details';

  @override
  String get partNotFound => 'Part not found';

  @override
  String get afterMonths => 'Time since replacement';

  @override
  String get afterDistance => 'Distance since replacement';

  @override
  String thresholdPct(int pct) {
    return 'Threshold $pct%';
  }

  @override
  String get lastReplacementNone => 'Last replacement: none';

  @override
  String lastReplacement(String date) {
    return 'Last replacement $date';
  }

  @override
  String get replaced => 'Replaced';

  @override
  String get edit => 'Edit';

  @override
  String get historyTitle => 'Past replacements';

  @override
  String get historyHint => 'Tap a row to edit date, comment, or delete';

  @override
  String get historyDistanceHeader => 'Bike distance';

  @override
  String get replacedOn => 'Date';

  @override
  String get comment => 'Comment';

  @override
  String get recordReplace => 'Log replacement';

  @override
  String get replaceDateHelp =>
      'Default is today. If you forgot, change it to the real date.';

  @override
  String get memo => 'Memo';

  @override
  String get memoHint => 'Product name, reason, … (optional)';

  @override
  String get logReplacement => 'Save record';

  @override
  String get editRecord => 'Edit record';

  @override
  String get recordNotFound => 'Record not found';

  @override
  String get editRecordHelp =>
      'Changing the date recounts distance for that period';

  @override
  String get cannotDeleteLastRecord => 'The last record can\'t be deleted';

  @override
  String get deleteThisRecord => 'Delete this record';

  @override
  String get connectAgain => 'Reconnect';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get howToConnect => 'How to connect';

  @override
  String get clientIdHint => 'Number from your Strava API app';

  @override
  String get clientSecretHint => 'Value shown with Show on the Strava API page';

  @override
  String get waitingBrowser =>
      'When Chrome shows a page, close that page. Closing it turns the connect button green again. The app will not come to the front.';

  @override
  String get waitingBrowserMobile =>
      'Strava’s approval screen opens. After you approve, you return to this app.';

  @override
  String get waitingBrowserIos =>
      'If iPhone asks to open the web, tap Continue. Safari the app does not open. If you are signed out, Strava’s login appears. If you are already signed in and have approved this app, it may return right away.';

  @override
  String get browserDidNotOpen =>
      'Chrome didn\'t open by itself. Copy the URL below and open it in Chrome.';

  @override
  String get copyAuthorizeUrl => 'Copy authorize URL';

  @override
  String get copiedAuthorizeUrl =>
      'Copied the authorize URL. Paste it in Chrome\'s address bar.';

  @override
  String get connectStep1 => '1. Create an app in Strava API settings';

  @override
  String get callbackDomainHelp =>
      'Authorization Callback Domain is 127.0.0.1. Don\'t add http, a port, or a path. You don\'t need to open this screen\'s return URL yourself.';

  @override
  String get stravaPaidApi =>
      'The Standard Tier API needs a paid Strava subscription.';

  @override
  String get connectStep2 => '2. Enter Client ID and Client Secret above';

  @override
  String get noAccessToken => 'This app does not use the Access Token field.';

  @override
  String get connectStep3 => '3. Tap Connect';

  @override
  String get connectStep3Help =>
      'On a phone, you return to the app after you approve. On a computer, Chrome opens. After you approve, a 127.0.0.1 page appears. You must close that page. If you don\'t, the connect button stays gray. On a computer the app will not come to the front. When this screen shows Connected and the button is green again, it worked. Import rides from Strava sync on Home.';

  @override
  String get connectStep3HelpIos =>
      'Tap Connect, then Continue when iPhone asks to open the web. Safari the app does not open. If you are signed out, Strava’s login appears. If you are already signed in and have approved this app, the screen may close right away. Success is when this screen shows Connected and the button is green again. Import rides from Strava sync on Home.';

  @override
  String get connectStep4 => '4. If Chrome doesn\'t open';

  @override
  String get connectStep4Help =>
      'After Connect, copy the authorize URL and paste it in Chrome. Then close the info page as in step 3; the button turns green.';

  @override
  String get enterClientIdSecret => 'Enter Client ID and Client Secret.';

  @override
  String portBusy(int port) {
    return 'Couldn\'t open port $port. Quit the other process and connect again.';
  }

  @override
  String tokenSaved(String name) {
    return 'Saved the token on this device ($name).';
  }

  @override
  String get disconnected => 'Disconnected and removed the tokens.';

  @override
  String get syncTitle => 'Strava sync';

  @override
  String stravaStartDate(String value) {
    return 'Strava start date  $value';
  }

  @override
  String untilDate(String value) {
    return 'Through  $value';
  }

  @override
  String get untilDateHelp =>
      'Through date is the newest ride on or after the Strava start date.';

  @override
  String get syncManualHelp =>
      'Pick a period and import. Nothing is fetched automatically.';

  @override
  String get sync3months => 'Last 3 months';

  @override
  String get sync6months => 'Last 6 months';

  @override
  String get sync1year => 'Last year';

  @override
  String get changeStartDate => 'Change Strava start date';

  @override
  String get specifyStartDate => 'Set Strava start date';

  @override
  String get startDateHelp =>
      'Changing the start date clears imported rides and resets them. They are fetched again from the new date.';

  @override
  String get needStartDate => 'Set a Strava start date first.';

  @override
  String get needConnect => 'Connect from the Strava connect screen first.';

  @override
  String get changeStartTitle => 'Change Strava start date?';

  @override
  String get changeStartBody =>
      'Changing only the start date later can leave gaps.\n\nAll imported rides will be deleted, then fetched again from the new start date.';

  @override
  String get deleteAndContinue => 'Delete and continue';

  @override
  String get dataRange => 'Data range';

  @override
  String get emDash => '—';

  @override
  String get csvCopyHint => 'Shown in the field so you can copy it.';

  @override
  String get recordsCsvHint => 'Registered name,Date,Memo';

  @override
  String get settingsCsvHint =>
      'Registered name,Interval,Target,Recommended,Custom,Threshold,Group,Position';

  @override
  String get exportCurrentRecords => 'Export current records';

  @override
  String get exportCurrentSettings => 'Export current settings';

  @override
  String get insertExample => 'Insert example';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get confirm => 'Confirm';

  @override
  String get fixThese => 'Fix these';

  @override
  String get recordsCsvScope =>
      'Import and export only this bike\'s replacement records. Other bikes stay as they are.';

  @override
  String get recordsCsvHelp =>
      'Parts are not created. Rows match by registered name (e.g. front tire). Records on this bike for names in the CSV are replaced.';

  @override
  String get settingsCsvScope =>
      'Import and export only this bike\'s part settings. Other bikes stay as they are.';

  @override
  String get settingsCsvHelp =>
      'Rows match by registered name. Missing names add parts. Settings and groups in the CSV replace this bike only. Replacement records don\'t change.';

  @override
  String get noNewRows => 'There are no new rows.';

  @override
  String replaceCount(int count) {
    return 'Replace $count';
  }

  @override
  String partsApplyCount(int count) {
    return '$count parts';
  }

  @override
  String get exportedEmptyRecords =>
      'No replacement records. Exported the header only.';

  @override
  String exportedCount(int count) {
    return '$count rows put in the field and copied.';
  }

  @override
  String get exportedEmptySettings => 'No parts. Exported the header only.';

  @override
  String importedSettings(int updated, int created, String groups) {
    return 'Updated $updated, added $created$groups on this bike.';
  }

  @override
  String importedRecords(int added) {
    return 'Imported $added. Older records on this bike for names in the CSV were replaced.';
  }

  @override
  String skippedDuplicates(int count) {
    return ' Skipped $count duplicates inside the CSV.';
  }

  @override
  String get groupTitle => 'Display groups';

  @override
  String get groupHelp => 'Home shows one row. The parts stay separate.';

  @override
  String get groupTogether => 'Show grouped';

  @override
  String get groupSplit => 'Show split';

  @override
  String get groupNeedTwo =>
      'Not enough parts to group. Add two with registered names first.';

  @override
  String get groupNameHint => 'Tires';

  @override
  String groupPreview(String name) {
    return 'Home shows “$name”. Left is R, right is F';
  }

  @override
  String get groupNamePlaceholder => '(name)';

  @override
  String get noGroups => 'There are no groups.';

  @override
  String get groupToRemove => 'Group to split';

  @override
  String get afterSplit => 'Names after split (registered names)';

  @override
  String get groupSplitHelp =>
      'Registered names don\'t change. Don\'t append F/R.';

  @override
  String get enterGroupName => 'Enter a group name';

  @override
  String get partsNotFound => 'Parts not found';

  @override
  String get sameCycleOnly =>
      'Only parts with the same interval can be grouped';

  @override
  String get selectGroupToSplit => 'Select a group to split';

  @override
  String get clientId => 'Client ID';

  @override
  String get clientSecret => 'Client Secret';

  @override
  String get csvLabel => 'CSV';

  @override
  String get csvNeedGear =>
      'Import bikes from Strava and select one to use this screen.';

  @override
  String skipCsvDuplicatesPreview(int count) {
    return ', skip $count duplicates inside the CSV';
  }

  @override
  String groupsCountPreview(int count) {
    return ', $count groups';
  }

  @override
  String replaceResetHelp(String name, String usage) {
    return 'Logging the replacement date for $name restarts only this position\'s $usage.';
  }

  @override
  String get usageDistance => 'distance';

  @override
  String get usageMonths => 'elapsed months';

  @override
  String statusPercent(int percent, String status) {
    return '$percent% · $status';
  }

  @override
  String syncFetchedEmpty(String from, String to) {
    return 'Fetched $from through $to. There were no bike rides in this period.';
  }

  @override
  String syncFetched(String from, String to, int count, String newest) {
    return 'Fetched $from through $to. $count bike rides. Newest ride is $newest.';
  }

  @override
  String get startDateUnchanged => 'Strava start date is unchanged.';

  @override
  String startDateChanged(String date) {
    return 'Strava start date is now $date. Ride data was cleared. Import again from here.';
  }

  @override
  String changeStartConfirm(String date) {
    return 'Set Strava start date to $date.\n\nRides from the start date through the newest imported ride need to be complete. Changing only the start date later can leave gaps.\n\nAll imported rides will be deleted, then fetched again from the new start date.';
  }

  @override
  String get pickTwoParts => '1. Pick two parts';

  @override
  String get pickFront => '2. Which is F';

  @override
  String get groupedNameStep => '3. Group name';

  @override
  String get pickedSuffix => ' (selected)';

  @override
  String partIsFront(String name) {
    return '$name is F';
  }

  @override
  String stopGrouping(String name) {
    return 'Stop grouping “$name”. Cards will use registered names.';
  }

  @override
  String get pickTwoAndFront => 'Pick two parts and which one is F';

  @override
  String get waitingForChrome => 'Waiting for Strava approval in Chrome…';

  @override
  String get closeChromeSuccess =>
      'When Chrome shows a page, close it. Success is when the connect button turns green again.';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get couldNotOpenBrowser => 'Couldn’t open the browser.';
}
