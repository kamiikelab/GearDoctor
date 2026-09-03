import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GearDoctor'**
  String get appTitle;

  /// No description provided for @startupFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start\n{error}'**
  String startupFailed(String error);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Match device'**
  String get languageSystem;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @stravaOptional.
  ///
  /// In en, this message translates to:
  /// **'Strava connection is optional.'**
  String get stravaOptional;

  /// No description provided for @stravaHint.
  ///
  /// In en, this message translates to:
  /// **'Connecting is optional. You can also enter rides by hand.'**
  String get stravaHint;

  /// No description provided for @stravaConnect.
  ///
  /// In en, this message translates to:
  /// **'Strava connect'**
  String get stravaConnect;

  /// No description provided for @stravaSync.
  ///
  /// In en, this message translates to:
  /// **'Add ride'**
  String get stravaSync;

  /// No description provided for @gear.
  ///
  /// In en, this message translates to:
  /// **'Bikes'**
  String get gear;

  /// No description provided for @gearHint.
  ///
  /// In en, this message translates to:
  /// **'The bike whose distance is calculated, and its replacement records.'**
  String get gearHint;

  /// No description provided for @resetSection.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetSection;

  /// No description provided for @resetHint.
  ///
  /// In en, this message translates to:
  /// **'Clears Strava, rides, parts, and records, then restores the first-run demo.'**
  String get resetHint;

  /// No description provided for @resetToDemo.
  ///
  /// In en, this message translates to:
  /// **'Reset to demo'**
  String get resetToDemo;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset to the first-run state?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes Strava connection, rides, part settings, and replacement records.\n\nThe app returns to the same demo as first launch.'**
  String get resetConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @resetConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Delete and reset'**
  String get resetConfirmAction;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Reset to the demo state.'**
  String get resetDone;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @gearUnselected.
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get gearUnselected;

  /// No description provided for @gearLabel.
  ///
  /// In en, this message translates to:
  /// **'Bike: {name}'**
  String gearLabel(String name);

  /// No description provided for @gearNone.
  ///
  /// In en, this message translates to:
  /// **'Bike: none selected'**
  String get gearNone;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Rides {range}'**
  String lastSync(String range);

  /// No description provided for @notSynced.
  ///
  /// In en, this message translates to:
  /// **'No rides'**
  String get notSynced;

  /// No description provided for @syncRangeOpen.
  ///
  /// In en, this message translates to:
  /// **'{from}–—'**
  String syncRangeOpen(String from);

  /// No description provided for @syncRange.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to}'**
  String syncRange(String from, String to);

  /// No description provided for @demoBanner.
  ///
  /// In en, this message translates to:
  /// **'Add a ride to leave the demo.'**
  String get demoBanner;

  /// No description provided for @alertCount.
  ///
  /// In en, this message translates to:
  /// **'{count} at threshold'**
  String alertCount(int count);

  /// No description provided for @demoSuffix.
  ///
  /// In en, this message translates to:
  /// **' (demo)'**
  String get demoSuffix;

  /// No description provided for @selectedSuffix.
  ///
  /// In en, this message translates to:
  /// **' (selected)'**
  String get selectedSuffix;

  /// No description provided for @demoSelectedSuffix.
  ///
  /// In en, this message translates to:
  /// **' (demo, selected)'**
  String get demoSelectedSuffix;

  /// No description provided for @todaySuffix.
  ///
  /// In en, this message translates to:
  /// **' (today)'**
  String get todaySuffix;

  /// No description provided for @unitKm.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get unitKm;

  /// No description provided for @unitMonths.
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get unitMonths;

  /// No description provided for @limitModeRecommended.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get limitModeRecommended;

  /// No description provided for @limitModeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get limitModeAuto;

  /// No description provided for @limitModeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get limitModeCustom;

  /// No description provided for @limitModeAutoFallback.
  ///
  /// In en, this message translates to:
  /// **'Auto (default)'**
  String get limitModeAutoFallback;

  /// No description provided for @statusOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get statusOk;

  /// No description provided for @statusSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get statusSoon;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get statusOverdue;

  /// No description provided for @statusLine.
  ///
  /// In en, this message translates to:
  /// **'{status} · {percent}%'**
  String statusLine(String status, int percent);

  /// No description provided for @statusLineSide.
  ///
  /// In en, this message translates to:
  /// **'{side}: {status} · {percent}%'**
  String statusLineSide(String side, String status, int percent);

  /// No description provided for @demoRequiresSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a ride first'**
  String get demoRequiresSyncTitle;

  /// No description provided for @demoRequiresSyncMessage.
  ///
  /// In en, this message translates to:
  /// **'You can\'t add, delete, or import parts while the demo is on.'**
  String get demoRequiresSyncMessage;

  /// No description provided for @gearDemoCsvHint.
  ///
  /// In en, this message translates to:
  /// **'You can\'t add, delete, or import parts during the demo. Add a ride first.'**
  String get gearDemoCsvHint;

  /// No description provided for @gearEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add a bike, or import from Strava, and they will appear here.'**
  String get gearEmptyHint;

  /// No description provided for @gearBikesHelp.
  ///
  /// In en, this message translates to:
  /// **'You can pick bikes imported from Strava or added by name. Adding parts, settings, records, and CSV apply to the selected bike. The initial parts are the same.'**
  String get gearBikesHelp;

  /// No description provided for @addBike.
  ///
  /// In en, this message translates to:
  /// **'Add bike'**
  String get addBike;

  /// No description provided for @deleteBike.
  ///
  /// In en, this message translates to:
  /// **'Delete bike'**
  String get deleteBike;

  /// No description provided for @deleteBikeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this bike?'**
  String get deleteBikeTitle;

  /// No description provided for @deleteBikeConfirm.
  ///
  /// In en, this message translates to:
  /// **'This also deletes {name}\'s parts, replacement records, and rides.'**
  String deleteBikeConfirm(String name);

  /// No description provided for @cannotDeleteStravaBike.
  ///
  /// In en, this message translates to:
  /// **'Bikes imported from Strava can\'t be deleted here.'**
  String get cannotDeleteStravaBike;

  /// No description provided for @bikeName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get bikeName;

  /// No description provided for @bikeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Road'**
  String get bikeNameHint;

  /// No description provided for @addBikeAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addBikeAction;

  /// No description provided for @bikeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get bikeNameRequired;

  /// No description provided for @gearSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select a bike above to add parts and records.'**
  String get gearSelectHint;

  /// No description provided for @addPart.
  ///
  /// In en, this message translates to:
  /// **'Add part'**
  String get addPart;

  /// No description provided for @editPart.
  ///
  /// In en, this message translates to:
  /// **'Edit part'**
  String get editPart;

  /// No description provided for @recordsCsv.
  ///
  /// In en, this message translates to:
  /// **'Replacement records CSV'**
  String get recordsCsv;

  /// No description provided for @settingsCsv.
  ///
  /// In en, this message translates to:
  /// **'Part registration CSV'**
  String get settingsCsv;

  /// No description provided for @displayGroups.
  ///
  /// In en, this message translates to:
  /// **'Group / split display'**
  String get displayGroups;

  /// No description provided for @registeredName.
  ///
  /// In en, this message translates to:
  /// **'Registered name'**
  String get registeredName;

  /// No description provided for @registeredNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name (front tire, HR battery, …)'**
  String get registeredNameHint;

  /// No description provided for @registeredNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Name shown on Home. Register left and right separately.'**
  String get registeredNameHelp;

  /// No description provided for @firstReplacementNoRide.
  ///
  /// In en, this message translates to:
  /// **'The first replacement date is this bike\'s oldest ride. If there are no rides yet, it is today.'**
  String get firstReplacementNoRide;

  /// No description provided for @firstReplacementWithRide.
  ///
  /// In en, this message translates to:
  /// **'The first replacement date is this bike\'s oldest ride ({date}). You don\'t enter it.'**
  String firstReplacementWithRide(String date);

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get cycle;

  /// No description provided for @cycleHelp.
  ///
  /// In en, this message translates to:
  /// **'Distance or months, not both.'**
  String get cycleHelp;

  /// No description provided for @cycleDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get cycleDistance;

  /// No description provided for @cycleMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get cycleMonths;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Replacement target'**
  String get limit;

  /// No description provided for @limitRecommended.
  ///
  /// In en, this message translates to:
  /// **'Default  {amount} {unit}'**
  String limitRecommended(String amount, String unit);

  /// No description provided for @limitRecommendedHelp.
  ///
  /// In en, this message translates to:
  /// **'Set automatically from the name.'**
  String get limitRecommendedHelp;

  /// No description provided for @limitAutoEmpty.
  ///
  /// In en, this message translates to:
  /// **'Auto  —'**
  String get limitAutoEmpty;

  /// No description provided for @limitAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto  {amount} {unit}'**
  String limitAuto(String amount, String unit);

  /// No description provided for @limitAutoHelp.
  ///
  /// In en, this message translates to:
  /// **'Gap between the last two replacements. Recalculated each time.'**
  String get limitAutoHelp;

  /// No description provided for @limitCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom  {amount} {unit}'**
  String limitCustom(String amount, String unit);

  /// No description provided for @limitCustomHelp.
  ///
  /// In en, this message translates to:
  /// **'You type the number.'**
  String get limitCustomHelp;

  /// No description provided for @customValue.
  ///
  /// In en, this message translates to:
  /// **'Custom value'**
  String get customValue;

  /// No description provided for @threshold.
  ///
  /// In en, this message translates to:
  /// **'Alert threshold'**
  String get threshold;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a registered name'**
  String get nameRequired;

  /// No description provided for @customLimitInvalid.
  ///
  /// In en, this message translates to:
  /// **'Custom target must be a number of 1 or more'**
  String get customLimitInvalid;

  /// No description provided for @thresholdInvalid.
  ///
  /// In en, this message translates to:
  /// **'Threshold must be an integer from 1 to 100'**
  String get thresholdInvalid;

  /// No description provided for @selectGearFirstPart.
  ///
  /// In en, this message translates to:
  /// **'Select a bike before adding a part'**
  String get selectGearFirstPart;

  /// No description provided for @partDetail.
  ///
  /// In en, this message translates to:
  /// **'Part details'**
  String get partDetail;

  /// No description provided for @partNotFound.
  ///
  /// In en, this message translates to:
  /// **'Part not found'**
  String get partNotFound;

  /// No description provided for @afterMonths.
  ///
  /// In en, this message translates to:
  /// **'Time since replacement'**
  String get afterMonths;

  /// No description provided for @afterDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance since replacement'**
  String get afterDistance;

  /// No description provided for @thresholdPct.
  ///
  /// In en, this message translates to:
  /// **'Threshold {pct}%'**
  String thresholdPct(int pct);

  /// No description provided for @lastReplacementNone.
  ///
  /// In en, this message translates to:
  /// **'Last replacement: none'**
  String get lastReplacementNone;

  /// No description provided for @lastReplacement.
  ///
  /// In en, this message translates to:
  /// **'Last replacement {date}'**
  String lastReplacement(String date);

  /// No description provided for @replaced.
  ///
  /// In en, this message translates to:
  /// **'Replaced'**
  String get replaced;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Past replacements'**
  String get historyTitle;

  /// No description provided for @historyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a row to edit date, comment, or delete'**
  String get historyHint;

  /// No description provided for @historyDistanceHeader.
  ///
  /// In en, this message translates to:
  /// **'Bike distance'**
  String get historyDistanceHeader;

  /// No description provided for @replacedOn.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get replacedOn;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @recordReplace.
  ///
  /// In en, this message translates to:
  /// **'Log replacement'**
  String get recordReplace;

  /// No description provided for @replaceDateHelp.
  ///
  /// In en, this message translates to:
  /// **'Default is today. If you forgot, change it to the real date.'**
  String get replaceDateHelp;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @memoHint.
  ///
  /// In en, this message translates to:
  /// **'Product name, reason, … (optional)'**
  String get memoHint;

  /// No description provided for @logReplacement.
  ///
  /// In en, this message translates to:
  /// **'Save record'**
  String get logReplacement;

  /// No description provided for @editRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get editRecord;

  /// No description provided for @recordNotFound.
  ///
  /// In en, this message translates to:
  /// **'Record not found'**
  String get recordNotFound;

  /// No description provided for @editRecordHelp.
  ///
  /// In en, this message translates to:
  /// **'Changing the date recounts distance for that period'**
  String get editRecordHelp;

  /// No description provided for @cannotDeleteLastRecord.
  ///
  /// In en, this message translates to:
  /// **'The last record can\'t be deleted'**
  String get cannotDeleteLastRecord;

  /// No description provided for @deleteThisRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete this record'**
  String get deleteThisRecord;

  /// No description provided for @deleteThisPart.
  ///
  /// In en, this message translates to:
  /// **'Delete this part'**
  String get deleteThisPart;

  /// No description provided for @deletePartTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this part?'**
  String get deletePartTitle;

  /// No description provided for @deletePartConfirm.
  ///
  /// In en, this message translates to:
  /// **'This also deletes replacement records for {name}. Any display group is split.'**
  String deletePartConfirm(String name);

  /// No description provided for @connectAgain.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get connectAgain;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @howToConnect.
  ///
  /// In en, this message translates to:
  /// **'How to connect'**
  String get howToConnect;

  /// No description provided for @clientIdHint.
  ///
  /// In en, this message translates to:
  /// **'Number from your Strava API app'**
  String get clientIdHint;

  /// No description provided for @clientSecretHint.
  ///
  /// In en, this message translates to:
  /// **'Value shown with Show on the Strava API page'**
  String get clientSecretHint;

  /// No description provided for @waitingBrowser.
  ///
  /// In en, this message translates to:
  /// **'When Chrome shows a page, close that page. Closing it turns the connect button green again. The app will not come to the front.'**
  String get waitingBrowser;

  /// No description provided for @waitingBrowserMobile.
  ///
  /// In en, this message translates to:
  /// **'Strava’s approval screen opens. After you approve, you return to this app.'**
  String get waitingBrowserMobile;

  /// No description provided for @waitingBrowserIos.
  ///
  /// In en, this message translates to:
  /// **'If iPhone asks to open the web, tap Continue. If you are signed out, Strava’s login appears. If you are already signed in and have approved this app, it may return right away.'**
  String get waitingBrowserIos;

  /// No description provided for @browserDidNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Chrome didn\'t open by itself. Copy the URL below and open it in Chrome.'**
  String get browserDidNotOpen;

  /// No description provided for @copyAuthorizeUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy authorize URL'**
  String get copyAuthorizeUrl;

  /// No description provided for @copiedAuthorizeUrl.
  ///
  /// In en, this message translates to:
  /// **'Copied the authorize URL. Paste it in Chrome\'s address bar.'**
  String get copiedAuthorizeUrl;

  /// No description provided for @connectStep1.
  ///
  /// In en, this message translates to:
  /// **'1. Create an app in Strava API settings'**
  String get connectStep1;

  /// No description provided for @stravaPaidApi.
  ///
  /// In en, this message translates to:
  /// **'The Strava API needs a paid subscription.'**
  String get stravaPaidApi;

  /// No description provided for @connectStep2.
  ///
  /// In en, this message translates to:
  /// **'2. Enter Client ID and Client Secret above'**
  String get connectStep2;

  /// No description provided for @noAccessToken.
  ///
  /// In en, this message translates to:
  /// **'This app does not use the Access Token field.'**
  String get noAccessToken;

  /// No description provided for @connectStep3.
  ///
  /// In en, this message translates to:
  /// **'3. Tap Connect'**
  String get connectStep3;

  /// No description provided for @connectStep3Help.
  ///
  /// In en, this message translates to:
  /// **'On a phone, you return to the app after you approve. On a computer, Chrome opens. After you approve, a 127.0.0.1 page appears. You must close that page. If you don\'t, the connect button stays gray. On a computer the app will not come to the front. When this screen shows Connected and the button is green again, it worked. Get ride records from Add ride.'**
  String get connectStep3Help;

  /// No description provided for @connectStep3HelpIos.
  ///
  /// In en, this message translates to:
  /// **'Tap Connect, then Continue when iPhone asks to open the web. If you are signed out, Strava’s login appears. If you are already signed in and have approved this app, it may return right away. Success is when this screen shows Connected and the button is green again. Get ride records from Add ride.'**
  String get connectStep3HelpIos;

  /// No description provided for @connectStep4.
  ///
  /// In en, this message translates to:
  /// **'4. If Chrome doesn\'t open'**
  String get connectStep4;

  /// No description provided for @connectStep4Help.
  ///
  /// In en, this message translates to:
  /// **'After Connect, copy the authorize URL and paste it in Chrome. Then close the info page as in step 3; the button turns green.'**
  String get connectStep4Help;

  /// No description provided for @enterClientIdSecret.
  ///
  /// In en, this message translates to:
  /// **'Enter Client ID and Client Secret.'**
  String get enterClientIdSecret;

  /// No description provided for @portBusy.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open port {port}. Quit the other process and connect again.'**
  String portBusy(int port);

  /// No description provided for @tokenSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved the token on this device ({name}).'**
  String tokenSaved(String name);

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected and removed the tokens.'**
  String get disconnected;

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Add ride'**
  String get syncTitle;

  /// No description provided for @selectedGearLine.
  ///
  /// In en, this message translates to:
  /// **'Selected bike: {name}'**
  String selectedGearLine(String name);

  /// No description provided for @manualRideSection.
  ///
  /// In en, this message translates to:
  /// **'Enter by hand'**
  String get manualRideSection;

  /// No description provided for @importFromStrava.
  ///
  /// In en, this message translates to:
  /// **'Import from Strava'**
  String get importFromStrava;

  /// No description provided for @notConnectedImportHint.
  ///
  /// In en, this message translates to:
  /// **'Not connected. Connect Strava in Settings.'**
  String get notConnectedImportHint;

  /// No description provided for @goToStravaConnect.
  ///
  /// In en, this message translates to:
  /// **'Strava connect'**
  String get goToStravaConnect;

  /// No description provided for @rideDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get rideDate;

  /// No description provided for @rideDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get rideDistance;

  /// No description provided for @needGearForRide.
  ///
  /// In en, this message translates to:
  /// **'Select a bike before logging a ride'**
  String get needGearForRide;

  /// No description provided for @invalidRideDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance must be greater than 0'**
  String get invalidRideDistance;

  /// No description provided for @rideRecorded.
  ///
  /// In en, this message translates to:
  /// **'Ride saved.'**
  String get rideRecorded;

  /// No description provided for @stravaStartDate.
  ///
  /// In en, this message translates to:
  /// **'Strava start date  {value}'**
  String stravaStartDate(String value);

  /// No description provided for @untilDate.
  ///
  /// In en, this message translates to:
  /// **'Through  {value}'**
  String untilDate(String value);

  /// No description provided for @untilDateHelp.
  ///
  /// In en, this message translates to:
  /// **'Through date is the newest ride on or after the Strava start date.'**
  String get untilDateHelp;

  /// No description provided for @syncManualHelp.
  ///
  /// In en, this message translates to:
  /// **'Pick a period and import. Nothing is fetched automatically.'**
  String get syncManualHelp;

  /// No description provided for @sync3months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get sync3months;

  /// No description provided for @sync6months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get sync6months;

  /// No description provided for @sync1year.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get sync1year;

  /// No description provided for @changeStartDate.
  ///
  /// In en, this message translates to:
  /// **'Change Strava start date'**
  String get changeStartDate;

  /// No description provided for @specifyStartDate.
  ///
  /// In en, this message translates to:
  /// **'Set Strava start date'**
  String get specifyStartDate;

  /// No description provided for @startDateHelp.
  ///
  /// In en, this message translates to:
  /// **'Changing the start date clears imported rides and resets them. They are fetched again from the new date.'**
  String get startDateHelp;

  /// No description provided for @needStartDate.
  ///
  /// In en, this message translates to:
  /// **'Set a Strava start date first.'**
  String get needStartDate;

  /// No description provided for @needConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect from the Strava connect screen first.'**
  String get needConnect;

  /// No description provided for @changeStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Strava start date?'**
  String get changeStartTitle;

  /// No description provided for @changeStartBody.
  ///
  /// In en, this message translates to:
  /// **'Changing only the start date later can leave gaps.\n\nAll imported rides will be deleted, then fetched again from the new start date.'**
  String get changeStartBody;

  /// No description provided for @deleteAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Delete and continue'**
  String get deleteAndContinue;

  /// No description provided for @dataRange.
  ///
  /// In en, this message translates to:
  /// **'Data range'**
  String get dataRange;

  /// No description provided for @emDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get emDash;

  /// No description provided for @csvCopyHint.
  ///
  /// In en, this message translates to:
  /// **'Shown in the field so you can copy it.'**
  String get csvCopyHint;

  /// No description provided for @recordsCsvHint.
  ///
  /// In en, this message translates to:
  /// **'Registered name,Date,Memo'**
  String get recordsCsvHint;

  /// No description provided for @settingsCsvHint.
  ///
  /// In en, this message translates to:
  /// **'Registered name,Interval,Target,Default,Custom,Threshold,Group,Position'**
  String get settingsCsvHint;

  /// No description provided for @exportCurrentRecords.
  ///
  /// In en, this message translates to:
  /// **'Export current records'**
  String get exportCurrentRecords;

  /// No description provided for @exportCurrentSettings.
  ///
  /// In en, this message translates to:
  /// **'Export current settings'**
  String get exportCurrentSettings;

  /// No description provided for @insertExample.
  ///
  /// In en, this message translates to:
  /// **'Insert example'**
  String get insertExample;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @fixThese.
  ///
  /// In en, this message translates to:
  /// **'Fix these'**
  String get fixThese;

  /// No description provided for @recordsCsvScope.
  ///
  /// In en, this message translates to:
  /// **'Import and export only this bike\'s replacement records. Other bikes stay as they are.'**
  String get recordsCsvScope;

  /// No description provided for @recordsCsvHelp.
  ///
  /// In en, this message translates to:
  /// **'Parts are not created. Rows match by registered name (e.g. front tire). Records on this bike for names in the CSV are replaced.'**
  String get recordsCsvHelp;

  /// No description provided for @settingsCsvScope.
  ///
  /// In en, this message translates to:
  /// **'Import and export only this bike\'s part settings. Other bikes stay as they are.'**
  String get settingsCsvScope;

  /// No description provided for @settingsCsvHelp.
  ///
  /// In en, this message translates to:
  /// **'Rows match by registered name. Missing names add parts. Settings and groups in the CSV replace this bike only. Replacement records don\'t change.'**
  String get settingsCsvHelp;

  /// No description provided for @noNewRows.
  ///
  /// In en, this message translates to:
  /// **'There are no new rows.'**
  String get noNewRows;

  /// No description provided for @replaceCount.
  ///
  /// In en, this message translates to:
  /// **'Replace {count}'**
  String replaceCount(int count);

  /// No description provided for @partsApplyCount.
  ///
  /// In en, this message translates to:
  /// **'{count} parts'**
  String partsApplyCount(int count);

  /// No description provided for @exportedEmptyRecords.
  ///
  /// In en, this message translates to:
  /// **'No replacement records. Exported the header only.'**
  String get exportedEmptyRecords;

  /// No description provided for @exportedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} rows put in the field and copied.'**
  String exportedCount(int count);

  /// No description provided for @exportedEmptySettings.
  ///
  /// In en, this message translates to:
  /// **'No parts. Exported the header only.'**
  String get exportedEmptySettings;

  /// No description provided for @importedSettings.
  ///
  /// In en, this message translates to:
  /// **'Updated {updated}, added {created}{groups} on this bike.'**
  String importedSettings(int updated, int created, String groups);

  /// No description provided for @importedRecords.
  ///
  /// In en, this message translates to:
  /// **'Imported {added}. Older records on this bike for names in the CSV were replaced.'**
  String importedRecords(int added);

  /// No description provided for @skippedDuplicates.
  ///
  /// In en, this message translates to:
  /// **' Skipped {count} duplicates inside the CSV.'**
  String skippedDuplicates(int count);

  /// No description provided for @groupTitle.
  ///
  /// In en, this message translates to:
  /// **'Display groups'**
  String get groupTitle;

  /// No description provided for @groupHelp.
  ///
  /// In en, this message translates to:
  /// **'Home shows one row. The parts stay separate.'**
  String get groupHelp;

  /// No description provided for @groupTogether.
  ///
  /// In en, this message translates to:
  /// **'Show grouped'**
  String get groupTogether;

  /// No description provided for @groupSplit.
  ///
  /// In en, this message translates to:
  /// **'Show split'**
  String get groupSplit;

  /// No description provided for @groupNeedTwo.
  ///
  /// In en, this message translates to:
  /// **'Not enough parts to group. Add two with registered names first.'**
  String get groupNeedTwo;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get groupNameHint;

  /// No description provided for @groupPreview.
  ///
  /// In en, this message translates to:
  /// **'Home shows “{name}”. Left is R, right is F'**
  String groupPreview(String name);

  /// No description provided for @groupNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'(name)'**
  String get groupNamePlaceholder;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'There are no groups.'**
  String get noGroups;

  /// No description provided for @groupToRemove.
  ///
  /// In en, this message translates to:
  /// **'Group to split'**
  String get groupToRemove;

  /// No description provided for @afterSplit.
  ///
  /// In en, this message translates to:
  /// **'Names after split (registered names)'**
  String get afterSplit;

  /// No description provided for @groupSplitHelp.
  ///
  /// In en, this message translates to:
  /// **'Registered names don\'t change. Don\'t append F/R.'**
  String get groupSplitHelp;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter a group name'**
  String get enterGroupName;

  /// No description provided for @partsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Parts not found'**
  String get partsNotFound;

  /// No description provided for @sameCycleOnly.
  ///
  /// In en, this message translates to:
  /// **'Only parts with the same interval can be grouped'**
  String get sameCycleOnly;

  /// No description provided for @selectGroupToSplit.
  ///
  /// In en, this message translates to:
  /// **'Select a group to split'**
  String get selectGroupToSplit;

  /// No description provided for @clientId.
  ///
  /// In en, this message translates to:
  /// **'Client ID'**
  String get clientId;

  /// No description provided for @clientSecret.
  ///
  /// In en, this message translates to:
  /// **'Client Secret'**
  String get clientSecret;

  /// No description provided for @csvLabel.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csvLabel;

  /// No description provided for @csvNeedGear.
  ///
  /// In en, this message translates to:
  /// **'Select a bike to use this screen.'**
  String get csvNeedGear;

  /// No description provided for @skipCsvDuplicatesPreview.
  ///
  /// In en, this message translates to:
  /// **', skip {count} duplicates inside the CSV'**
  String skipCsvDuplicatesPreview(int count);

  /// No description provided for @groupsCountPreview.
  ///
  /// In en, this message translates to:
  /// **', {count} groups'**
  String groupsCountPreview(int count);

  /// No description provided for @replaceResetHelp.
  ///
  /// In en, this message translates to:
  /// **'Logging the replacement date for {name} restarts only this position\'s {usage}.'**
  String replaceResetHelp(String name, String usage);

  /// No description provided for @usageDistance.
  ///
  /// In en, this message translates to:
  /// **'distance'**
  String get usageDistance;

  /// No description provided for @usageMonths.
  ///
  /// In en, this message translates to:
  /// **'elapsed months'**
  String get usageMonths;

  /// No description provided for @statusPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% · {status}'**
  String statusPercent(int percent, String status);

  /// No description provided for @syncFetchedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Fetched {from} through {to}. There were no bike rides in this period.'**
  String syncFetchedEmpty(String from, String to);

  /// No description provided for @syncFetched.
  ///
  /// In en, this message translates to:
  /// **'Fetched {from} through {to}. {count} bike rides. Newest ride is {newest}.'**
  String syncFetched(String from, String to, int count, String newest);

  /// No description provided for @startDateUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Strava start date is unchanged.'**
  String get startDateUnchanged;

  /// No description provided for @startDateChanged.
  ///
  /// In en, this message translates to:
  /// **'Strava start date is now {date}. Ride data was cleared. Import again from here.'**
  String startDateChanged(String date);

  /// No description provided for @changeStartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Set Strava start date to {date}.\n\nRides from the start date through the newest imported ride need to be complete. Changing only the start date later can leave gaps.\n\nAll imported rides will be deleted, then fetched again from the new start date.'**
  String changeStartConfirm(String date);

  /// No description provided for @pickTwoParts.
  ///
  /// In en, this message translates to:
  /// **'1. Pick two parts'**
  String get pickTwoParts;

  /// No description provided for @pickFront.
  ///
  /// In en, this message translates to:
  /// **'2. Which is F'**
  String get pickFront;

  /// No description provided for @groupedNameStep.
  ///
  /// In en, this message translates to:
  /// **'3. Group name'**
  String get groupedNameStep;

  /// No description provided for @pickedSuffix.
  ///
  /// In en, this message translates to:
  /// **' (selected)'**
  String get pickedSuffix;

  /// No description provided for @partIsFront.
  ///
  /// In en, this message translates to:
  /// **'{name} is F'**
  String partIsFront(String name);

  /// No description provided for @stopGrouping.
  ///
  /// In en, this message translates to:
  /// **'Stop grouping “{name}”. Cards will use registered names.'**
  String stopGrouping(String name);

  /// No description provided for @pickTwoAndFront.
  ///
  /// In en, this message translates to:
  /// **'Pick two parts and which one is F'**
  String get pickTwoAndFront;

  /// No description provided for @waitingForChrome.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Strava approval in Chrome…'**
  String get waitingForChrome;

  /// No description provided for @closeChromeSuccess.
  ///
  /// In en, this message translates to:
  /// **'When Chrome shows a page, close it. Success is when the connect button turns green again.'**
  String get closeChromeSuccess;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @couldNotOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the browser.'**
  String get couldNotOpenBrowser;
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
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
