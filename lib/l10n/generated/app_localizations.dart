import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// Title of the statistics page
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// Shown when no infusions have been logged yet
  ///
  /// In en, this message translates to:
  /// **'No data available for statistics yet.'**
  String get statisticsEmpty;

  /// Heading of the monthly dose bar chart
  ///
  /// In en, this message translates to:
  /// **'Monthly dose'**
  String get statisticsMonthlyDose;

  /// Subtitle under the monthly dose chart heading
  ///
  /// In en, this message translates to:
  /// **'Units administered over the last 6 months'**
  String get statisticsMonthlyDoseSubtitle;

  /// Heading of the summary card on the statistics page
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get statisticsSummary;

  /// Summary row label: number of infusions recorded
  ///
  /// In en, this message translates to:
  /// **'Total infusions'**
  String get statisticsTotalInfusions;

  /// Summary row label: sum of all doses
  ///
  /// In en, this message translates to:
  /// **'Total dose'**
  String get statisticsTotalDose;

  /// Summary row label: average dose per administration
  ///
  /// In en, this message translates to:
  /// **'Ø dose / administration'**
  String get statisticsAverageDose;

  /// Summary row label: most recently recorded body weight
  ///
  /// In en, this message translates to:
  /// **'Last weight'**
  String get statisticsLastWeight;

  /// A dose expressed in units
  ///
  /// In en, this message translates to:
  /// **'{value} units'**
  String unitsValue(String value);

  /// A body weight in kilograms
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String kilogramsValue(String value);

  /// Dashboard banner title while the premedication timer counts down
  ///
  /// In en, this message translates to:
  /// **'Premedication timer running'**
  String get timerBannerRunning;

  /// Dashboard banner title while the premedication timer is paused
  ///
  /// In en, this message translates to:
  /// **'Premedication timer paused'**
  String get timerBannerPaused;

  /// Dashboard banner subtitle; time is a mm:ss countdown
  ///
  /// In en, this message translates to:
  /// **'{time} remaining • Tap to open'**
  String timerBannerRemaining(String time);

  /// Title of the discontinued medications page
  ///
  /// In en, this message translates to:
  /// **'Discontinued medications'**
  String get discontinuedTitle;

  /// Shown when nothing has been discontinued
  ///
  /// In en, this message translates to:
  /// **'No discontinued medications.'**
  String get discontinuedEmpty;

  /// Subtitle showing when a medication was discontinued
  ///
  /// In en, this message translates to:
  /// **'Discontinued on: {date}'**
  String discontinuedOn(String date);

  /// Title of the premedication timer sheet
  ///
  /// In en, this message translates to:
  /// **'Premedication timer'**
  String get timerTitle;

  /// Timer sheet subtitle; seconds is the configured total duration
  ///
  /// In en, this message translates to:
  /// **'Ping every minute • {seconds} sec timer'**
  String timerSubtitle(int seconds);

  /// Label under the countdown digits
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get timerRemainingLabel;

  /// Label of the syringe progress bar
  ///
  /// In en, this message translates to:
  /// **'Syringe progress'**
  String get timerSyringeProgress;

  /// Title of the sheet for picking the premedication volume
  ///
  /// In en, this message translates to:
  /// **'Premedication volume (ml)'**
  String get timerVolumePickerTitle;

  /// Content of the silent Android foreground-service notification
  ///
  /// In en, this message translates to:
  /// **'Service running in the background'**
  String get backgroundServiceRunning;

  /// Notification content showing the premedication countdown
  ///
  /// In en, this message translates to:
  /// **'Remaining: {time}'**
  String timerNotificationRemaining(String time);

  /// Stand-in name when a medication record can no longer be resolved
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medicationFallbackName;

  /// The app name shown in the OS task switcher
  ///
  /// In en, this message translates to:
  /// **'CIDP Buddy'**
  String get appTitle;

  /// Shown when initialization crashed before the UI could load
  ///
  /// In en, this message translates to:
  /// **'The app could not be initialized:\n{error}'**
  String startupFailed(String error);

  /// Bottom navigation label for the dashboard tab
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Bottom navigation label for the diary tab
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get navDiary;

  /// Bottom navigation label for the medication/inventory tab
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get navMedication;

  /// Bottom navigation label for the settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// App bar title when adding a new vitals/symptoms entry
  ///
  /// In en, this message translates to:
  /// **'Vitals & symptoms'**
  String get diaryEntryTitleNew;

  /// App bar title when editing an existing diary entry
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get diaryEntryTitleEdit;

  /// Button that saves the diary entry
  ///
  /// In en, this message translates to:
  /// **'Save entry'**
  String get diaryEntrySave;

  /// Placeholder in the free-text notes field
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get diaryNotesHint;

  /// Form section header for the date and time picker
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get sectionDateTime;

  /// Form section header for the optional vital signs
  ///
  /// In en, this message translates to:
  /// **'Vital signs (optional)'**
  String get sectionVitals;

  /// Form section header for the CIDP symptom sliders, rated 1 to 10
  ///
  /// In en, this message translates to:
  /// **'CIDP symptoms (1-10)'**
  String get sectionSymptoms;

  /// Form section header for free-text notes
  ///
  /// In en, this message translates to:
  /// **'Additional notes'**
  String get sectionNotes;

  /// Input label: systolic blood pressure in mmHg
  ///
  /// In en, this message translates to:
  /// **'Syst. (mmHg)'**
  String get fieldSystolic;

  /// Input label: diastolic blood pressure in mmHg
  ///
  /// In en, this message translates to:
  /// **'Diast. (mmHg)'**
  String get fieldDiastolic;

  /// Input label: heart rate in beats per minute
  ///
  /// In en, this message translates to:
  /// **'Pulse (bpm)'**
  String get fieldHeartRate;

  /// Input label: body temperature in degrees Celsius
  ///
  /// In en, this message translates to:
  /// **'Temp. (°C)'**
  String get fieldTemperature;

  /// Input label: body weight in kilograms
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get fieldWeight;

  /// Symptom slider label: muscle strength
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get symptomStrength;

  /// Symptom slider label: sensation / sensory function
  ///
  /// In en, this message translates to:
  /// **'Sensation'**
  String get symptomSensory;

  /// Symptom slider label: fatigue / exhaustion
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// Symptom slider label: pain
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get symptomPain;

  /// Symptom slider label: balance
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get symptomBalance;

  /// App bar title of the page for logging an infusion
  ///
  /// In en, this message translates to:
  /// **'Log infusion'**
  String get addInfusionTitle;

  /// Heading above the infusion form fields
  ///
  /// In en, this message translates to:
  /// **'Infusion details'**
  String get addInfusionDetailsHeading;

  /// Dropdown label for choosing which medication was infused
  ///
  /// In en, this message translates to:
  /// **'Select medication'**
  String get addInfusionPickMedication;

  /// Label above the infusion date and time
  ///
  /// In en, this message translates to:
  /// **'Time of infusion'**
  String get addInfusionWhen;

  /// Save button when the medication has a premedication timer
  ///
  /// In en, this message translates to:
  /// **'Save & start timer'**
  String get addInfusionSaveAndStartTimer;

  /// Save button; saving also deducts the dose from inventory
  ///
  /// In en, this message translates to:
  /// **'Save infusion & deduct stock'**
  String get addInfusionSaveAndDeductStock;

  /// Input label for the medication's batch/lot number
  ///
  /// In en, this message translates to:
  /// **'Batch number / barcode'**
  String get fieldBatchNumber;

  /// Placeholder for the batch number field
  ///
  /// In en, this message translates to:
  /// **'Scan or type'**
  String get fieldBatchNumberHint;

  /// Input label for the administered dose
  ///
  /// In en, this message translates to:
  /// **'Dosage / units'**
  String get fieldDosageUnits;

  /// Input label for the patient's body weight at infusion time
  ///
  /// In en, this message translates to:
  /// **'Body weight (kg)'**
  String get fieldBodyWeight;

  /// Input label for notes about how the infusion went
  ///
  /// In en, this message translates to:
  /// **'Notes (how you felt, how it went)'**
  String get fieldInfusionNotes;

  /// Button and sheet title for scanning a barcode with the camera
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get actionScanBarcode;

  /// Tooltip for taking a photo of the batch label, which is then read via OCR
  ///
  /// In en, this message translates to:
  /// **'Photo of batch/label'**
  String get actionPhotoOfLabel;

  /// Validation error shown when a required dropdown is left empty
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get validationPickOne;

  /// Short legal notice shown next to the batch-number field
  ///
  /// In en, this message translates to:
  /// **'Batch documentation in this app is a personal note and does not replace the legally required documentation kept by you or your treating facility.'**
  String get legalBatchDocumentationShort;

  /// App bar title when creating a treatment schedule
  ///
  /// In en, this message translates to:
  /// **'Create infusion schedule'**
  String get scheduleTitleNew;

  /// App bar title when editing a treatment schedule
  ///
  /// In en, this message translates to:
  /// **'Edit infusion schedule'**
  String get scheduleTitleEdit;

  /// Label above the weekday chips
  ///
  /// In en, this message translates to:
  /// **'Select days:'**
  String get scheduleSelectDays;

  /// Button that adds another intake time to the schedule
  ///
  /// In en, this message translates to:
  /// **'Add another time'**
  String get scheduleAddTime;

  /// Button that saves and activates a new schedule
  ///
  /// In en, this message translates to:
  /// **'Activate schedule'**
  String get scheduleActivate;

  /// Form section header for medication and dose
  ///
  /// In en, this message translates to:
  /// **'Medication & dose'**
  String get sectionMedicationAndDose;

  /// Form section header for how often the treatment repeats
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get sectionFrequency;

  /// Form section header for the schedule's start date
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get sectionPeriod;

  /// Form section header for the times of day a dose is taken
  ///
  /// In en, this message translates to:
  /// **'Intake times'**
  String get sectionIntakeTimes;

  /// Input label for the dose of a single scheduled infusion
  ///
  /// In en, this message translates to:
  /// **'Units per infusion'**
  String get fieldUnitsPerInfusion;

  /// Input label for the interval length in days
  ///
  /// In en, this message translates to:
  /// **'Number of days'**
  String get fieldNumberOfDays;

  /// Placeholder example for the interval field
  ///
  /// In en, this message translates to:
  /// **'E.g. every 5 days'**
  String get fieldNumberOfDaysHint;

  /// Label above the schedule's start date
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get fieldStartDate;

  /// Frequency option: every day
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get frequencyDaily;

  /// Frequency option: every N days, where N is entered separately
  ///
  /// In en, this message translates to:
  /// **'Every X days'**
  String get frequencyInterval;

  /// Frequency option: once a week
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get frequencyWeekly;

  /// Frequency option: every two weeks
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get frequencyBiweekly;

  /// Frequency option: on specific weekdays picked by the user
  ///
  /// In en, this message translates to:
  /// **'Specific weekdays'**
  String get frequencyWeekdays;

  /// Generic button that saves edits to an existing record
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get actionSaveChanges;

  /// Large app bar title of the diary tab
  ///
  /// In en, this message translates to:
  /// **'My diary'**
  String get diaryTitle;

  /// Headline of the diary empty state
  ///
  /// In en, this message translates to:
  /// **'Your diary is still empty'**
  String get diaryEmptyTitle;

  /// Explanatory text of the diary empty state
  ///
  /// In en, this message translates to:
  /// **'Log your first infusion to keep track of your treatment.'**
  String get diaryEmptyBody;

  /// All-caps label above the symptom mini bars on a diary card
  ///
  /// In en, this message translates to:
  /// **'VITALS & SYMPTOMS:'**
  String get diaryVitalsAndSymptomsLabel;

  /// Title of the confirmation dialog for deleting an infusion log
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get diaryDeleteEntryTitle;

  /// Body of the delete-entry dialog; deleting returns the dose to inventory
  ///
  /// In en, this message translates to:
  /// **'Delete this entry? The stock will be credited back automatically.'**
  String get diaryDeleteEntryBody;

  /// Diary timeline title for a delivered order
  ///
  /// In en, this message translates to:
  /// **'Order received'**
  String get diaryOrderReceived;

  /// Diary timeline title when a medication was discontinued
  ///
  /// In en, this message translates to:
  /// **'Discontinued: {name}'**
  String diaryEventDiscontinued(String name);

  /// Diary timeline title when a medication was newly prescribed
  ///
  /// In en, this message translates to:
  /// **'Newly prescribed: {name}'**
  String diaryEventPrescribed(String name);

  /// Short input label for the batch number, used where space is tight
  ///
  /// In en, this message translates to:
  /// **'Batch number'**
  String get fieldBatchNumberShort;

  /// Generic input label for a free-text notes field
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// Shows a recorded batch number on a diary card
  ///
  /// In en, this message translates to:
  /// **'Batch: {batch}'**
  String batchValue(String batch);

  /// A heart rate in beats per minute
  ///
  /// In en, this message translates to:
  /// **'{value} bpm'**
  String bpmValue(String value);

  /// Generic dialog button that dismisses without saving
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Generic button that saves the current form
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Generic button that deletes a record
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Large app bar title of the planning page
  ///
  /// In en, this message translates to:
  /// **'Appointments & plans'**
  String get planningTitle;

  /// Tab label and section heading for future appointments
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get planningTabUpcoming;

  /// Tab label for the list of recurring schedules
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get planningTabSchedules;

  /// Section heading for appointments whose date has passed
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get planningOverdue;

  /// Empty state on the upcoming appointments tab
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get planningNoUpcoming;

  /// Empty state on the schedules tab
  ///
  /// In en, this message translates to:
  /// **'No active schedules'**
  String get planningNoSchedules;

  /// Subtitle of an appointment card
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {date}'**
  String planningScheduledFor(String date);

  /// Title of the dialog for bulk-deleting past appointments
  ///
  /// In en, this message translates to:
  /// **'Delete past appointments?'**
  String get planningDeletePastTitle;

  /// Body of the bulk-delete dialog
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all planned appointments in the past?\n\nThis does not create any diary entries.'**
  String get planningDeletePastBody;

  /// Title of the dialog confirming that an appointment is skipped
  ///
  /// In en, this message translates to:
  /// **'Skip appointment?'**
  String get planningSkipTitle;

  /// Body of the skip-appointment dialog
  ///
  /// In en, this message translates to:
  /// **'Skip this appointment? It will be marked as done but not recorded in the diary.'**
  String get planningSkipBody;

  /// Marker appended to an appointment's notes when it is skipped from the app
  ///
  /// In en, this message translates to:
  /// **'[Skipped via app]'**
  String get planningSkippedNote;

  /// Title of the dialog for deleting a single appointment
  ///
  /// In en, this message translates to:
  /// **'Delete appointment?'**
  String get planningDeleteAppointmentTitle;

  /// Body of the delete-appointment dialog
  ///
  /// In en, this message translates to:
  /// **'Remove this specific appointment from your plan?'**
  String get planningDeleteAppointmentBody;

  /// Title of the edit-appointment dialog
  ///
  /// In en, this message translates to:
  /// **'Edit appointment'**
  String get planningEditAppointmentTitle;

  /// Title of the dialog for deleting a recurring schedule
  ///
  /// In en, this message translates to:
  /// **'Delete schedule?'**
  String get planningDeleteScheduleTitle;

  /// Body of the delete-schedule dialog
  ///
  /// In en, this message translates to:
  /// **'All future (uncompleted) appointments from this schedule will be deleted too.'**
  String get planningDeleteScheduleBody;

  /// Option title: add a single, non-recurring appointment
  ///
  /// In en, this message translates to:
  /// **'One-off appointment'**
  String get planningOneOffTitle;

  /// Option subtitle for the one-off appointment choice
  ///
  /// In en, this message translates to:
  /// **'Add a single appointment'**
  String get planningOneOffSubtitle;

  /// Option title: create a recurring treatment schedule
  ///
  /// In en, this message translates to:
  /// **'Recurring schedule'**
  String get planningRecurringTitle;

  /// Option subtitle for the recurring schedule choice
  ///
  /// In en, this message translates to:
  /// **'Set up an automatic infusion rhythm'**
  String get planningRecurringSubtitle;

  /// Snackbar shown when scheduling is attempted with an empty inventory
  ///
  /// In en, this message translates to:
  /// **'Add medications to your inventory first!'**
  String get planningNeedMedicationsFirst;

  /// Title of the dialog for planning a one-off appointment
  ///
  /// In en, this message translates to:
  /// **'Schedule appointment'**
  String get planningScheduleAppointmentTitle;

  /// Frequency summary on a schedule card
  ///
  /// In en, this message translates to:
  /// **'Every {days} days'**
  String frequencyEveryNDays(int days);

  /// Short frequency summary for schedules bound to specific weekdays
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get frequencyWeekdaysShort;

  /// Generic input label for a date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldDate;

  /// Input label for the dose planned for an appointment
  ///
  /// In en, this message translates to:
  /// **'Planned dose'**
  String get fieldPlannedDose;

  /// Input label for a dose, with the medication's unit in brackets
  ///
  /// In en, this message translates to:
  /// **'Dose ({unit})'**
  String fieldDoseWithUnit(String unit);

  /// Displays a dose with its amount and unit
  ///
  /// In en, this message translates to:
  /// **'Dose: {amount} {unit}'**
  String doseValue(String amount, String unit);

  /// Generic button that opens an add flow
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// Button that deletes every item in a list
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get actionDeleteAll;

  /// Button that skips a planned appointment
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// Button that marks a planned appointment as completed
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// App bar title of the dashboard tab
  ///
  /// In en, this message translates to:
  /// **'Your overview'**
  String get dashboardTitle;

  /// Collapsible section header for treatments planned further out; all caps
  ///
  /// In en, this message translates to:
  /// **'PLANNED LATER ({count})'**
  String dashboardSectionLater(int count);

  /// Collapsible section header for past appointments; all caps
  ///
  /// In en, this message translates to:
  /// **'PAST APPOINTMENTS ({count})'**
  String dashboardSectionPast(int count);

  /// Warning card title shown when automatic backup is off
  ///
  /// In en, this message translates to:
  /// **'No backup enabled'**
  String get dashboardNoBackupTitle;

  /// Warning card body prompting the user to set up automatic backup
  ///
  /// In en, this message translates to:
  /// **'Set up automatic backup to avoid losing your data.'**
  String get dashboardNoBackupBody;

  /// Notification card title suggesting the user place an order
  ///
  /// In en, this message translates to:
  /// **'Order recommended'**
  String get dashboardOrderRecommended;

  /// Lists the items that are running low; names is a comma-separated list
  ///
  /// In en, this message translates to:
  /// **'Low stock: {names}'**
  String dashboardLowStockNames(String names);

  /// Notification shown when orders have been placed but not yet delivered
  ///
  /// In en, this message translates to:
  /// **'Orders are on the way.'**
  String get dashboardOrdersOnTheWay;

  /// Section header above open orders; all caps
  ///
  /// In en, this message translates to:
  /// **'PENDING DELIVERIES'**
  String get dashboardPendingDeliveries;

  /// Shows an order's expected delivery date
  ///
  /// In en, this message translates to:
  /// **'Delivery date: {date}'**
  String dashboardDeliveryDate(String date);

  /// Shown for an order that has no delivery date yet
  ///
  /// In en, this message translates to:
  /// **'No date set yet'**
  String get dashboardNoDeliveryDate;

  /// Title of the dialog for deleting a pending order
  ///
  /// In en, this message translates to:
  /// **'Delete order?'**
  String get dashboardDeleteOrderTitle;

  /// Body of the delete-order dialog
  ///
  /// In en, this message translates to:
  /// **'Remove this pending order?'**
  String get dashboardDeleteOrderBody;

  /// Title of the dialog confirming that an order arrived
  ///
  /// In en, this message translates to:
  /// **'Delivery received?'**
  String get dashboardConfirmDeliveryTitle;

  /// Body of the confirm-delivery dialog
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt of this delivery? Your stock will be updated automatically.'**
  String get dashboardConfirmDeliveryBody;

  /// Affirmative button in the confirm-delivery dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, received'**
  String get dashboardConfirmDeliveryYes;

  /// Snackbar confirming inventory was updated after a delivery
  ///
  /// In en, this message translates to:
  /// **'Stock updated!'**
  String get dashboardStockUpdated;

  /// Button on an order card that marks it as delivered
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get dashboardReceived;

  /// Status of a pill dose whose time has passed
  ///
  /// In en, this message translates to:
  /// **'Missed (planned for {time})'**
  String dashboardMissedAt(String time);

  /// Status of a pill dose due later today
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String dashboardTodayAt(String time);

  /// Status of an infusion that was planned for today but not logged
  ///
  /// In en, this message translates to:
  /// **'Missed infusion (planned for today)'**
  String get dashboardMissedInfusion;

  /// Status of an infusion planned for today
  ///
  /// In en, this message translates to:
  /// **'Planned today ({amount} {unit})'**
  String dashboardPlannedToday(String amount, String unit);

  /// Snackbar after confirming a dose
  ///
  /// In en, this message translates to:
  /// **'{name} done!'**
  String dashboardMarkedDone(String name);

  /// Button that opens the log-infusion form for a due treatment
  ///
  /// In en, this message translates to:
  /// **'Log infusion now'**
  String get dashboardLogInfusionNow;

  /// Headline of the dashboard empty state
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get dashboardAllDoneTitle;

  /// Body of the dashboard empty state
  ///
  /// In en, this message translates to:
  /// **'No pending tasks.'**
  String get dashboardAllDoneBody;

  /// Subtitle of an upcoming treatment card, combining date, time, dose and unit
  ///
  /// In en, this message translates to:
  /// **'{date} at {time} • {amount} {unit}'**
  String dashboardTreatmentSubtitle(
    String date,
    String time,
    String amount,
    String unit,
  );

  /// Snackbar after deleting an appointment whose medication no longer exists
  ///
  /// In en, this message translates to:
  /// **'Orphaned appointment removed'**
  String get dashboardOrphanRemoved;

  /// Title of the card for an appointment whose medication is missing
  ///
  /// In en, this message translates to:
  /// **'Unknown medication'**
  String get dashboardUnknownMedication;

  /// Subtitle explaining that the appointment's medication was not found
  ///
  /// In en, this message translates to:
  /// **'Planned {date} • medication not found'**
  String dashboardOrphanSubtitle(String date);

  /// Displays a quantity with its unit
  ///
  /// In en, this message translates to:
  /// **'Quantity: {amount} {unit}'**
  String quantityValue(String amount, String unit);

  /// The word for the current day, used in place of a date
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Negative dialog button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get actionNo;

  /// Button that removes a stray or invalid entry
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// Section header above the medication list; all caps
  ///
  /// In en, this message translates to:
  /// **'MEDICATIONS'**
  String get inventorySectionMedications;

  /// Section header for supplies that are not linked to any medication; all caps
  ///
  /// In en, this message translates to:
  /// **'STANDALONE SUPPLIES'**
  String get inventorySectionStandaloneSupplies;

  /// Empty state when no medications have been added
  ///
  /// In en, this message translates to:
  /// **'No medications added'**
  String get inventoryNoMedications;

  /// Shows when the next treatment for this medication is due
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String inventoryNextTreatment(String date);

  /// Shows how long the current stock will last
  ///
  /// In en, this message translates to:
  /// **'Lasts until: {date}'**
  String inventoryLastsUntil(String date);

  /// Warning shown on a medication whose stock is below the threshold
  ///
  /// In en, this message translates to:
  /// **'Low stock!'**
  String get inventoryLowStock;

  /// Shown instead of a low-stock warning when an order is already placed
  ///
  /// In en, this message translates to:
  /// **'Order on the way'**
  String get inventoryOrderOnTheWay;

  /// Shows the German pharmaceutical central number (PZN) of a medication
  ///
  /// In en, this message translates to:
  /// **'PZN: {pzn}'**
  String inventoryPzn(String pzn);

  /// Displays the current stock with its unit
  ///
  /// In en, this message translates to:
  /// **'Stock: {amount} {unit}'**
  String stockValue(String amount, String unit);

  /// Title of the dialog for editing a consumable supply item
  ///
  /// In en, this message translates to:
  /// **'Edit supply item'**
  String get accessoryEditTitle;

  /// Title of the dialog for deleting a consumable supply item
  ///
  /// In en, this message translates to:
  /// **'Delete supply item?'**
  String get accessoryDeleteTitle;

  /// Generic delete confirmation naming the item
  ///
  /// In en, this message translates to:
  /// **'Really delete \"{name}\"?'**
  String confirmDeleteNamed(String name);

  /// Generic input label for an item's name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// Input label for the unit an item is measured in (ml, pieces, …)
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get fieldUnit;

  /// Input label for how much of an item is currently on hand
  ///
  /// In en, this message translates to:
  /// **'Current stock'**
  String get fieldCurrentStock;

  /// Input label for how many units one package contains, used when ordering
  ///
  /// In en, this message translates to:
  /// **'Package size (for ordering)'**
  String get fieldPackageSize;

  /// Input label for the stock level below which a warning is shown
  ///
  /// In en, this message translates to:
  /// **'Warning threshold (stock)'**
  String get fieldMinStock;

  /// App bar title of the page for adding a medication or supply
  ///
  /// In en, this message translates to:
  /// **'Add new item'**
  String get addItemTitle;

  /// Dropdown label for choosing between medication and supply
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fieldCategory;

  /// Category option: the item is a medication
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get categoryMedication;

  /// Category option: the item is a consumable supply (needles, wipes, …)
  ///
  /// In en, this message translates to:
  /// **'Supply item'**
  String get categorySupply;

  /// Dropdown label for the medication's form
  ///
  /// In en, this message translates to:
  /// **'Dosage form'**
  String get fieldDosageForm;

  /// Dosage form option: an infusion
  ///
  /// In en, this message translates to:
  /// **'Infusion'**
  String get dosageFormInfusion;

  /// Dosage form option: a tablet or pill
  ///
  /// In en, this message translates to:
  /// **'Tablet / pill'**
  String get dosageFormPill;

  /// Input label for the item's name
  ///
  /// In en, this message translates to:
  /// **'Medication name'**
  String get fieldMedicationName;

  /// Placeholder showing an example medication name
  ///
  /// In en, this message translates to:
  /// **'e.g. Hizentra'**
  String get fieldMedicationNameHint;

  /// Input label for the medication's dose or concentration
  ///
  /// In en, this message translates to:
  /// **'Dose / strength'**
  String get fieldStrength;

  /// Placeholder showing example strengths
  ///
  /// In en, this message translates to:
  /// **'e.g. 20% or 10ml'**
  String get fieldStrengthHint;

  /// Input label for the optional German pharmaceutical number
  ///
  /// In en, this message translates to:
  /// **'PZN (optional)'**
  String get fieldPznOptional;

  /// Placeholder spelling out what a PZN is
  ///
  /// In en, this message translates to:
  /// **'Pharmaceutical central number'**
  String get fieldPznHint;

  /// Input label for how much is on hand when the item is created
  ///
  /// In en, this message translates to:
  /// **'Initial stock'**
  String get fieldInitialStock;

  /// Input label for the amount suggested when reordering
  ///
  /// In en, this message translates to:
  /// **'Default reorder amount'**
  String get fieldDefaultReorderAmount;

  /// Placeholder showing an example reorder amount
  ///
  /// In en, this message translates to:
  /// **'e.g. 10 bottles'**
  String get fieldDefaultReorderAmountHint;

  /// Input label: warn when the supply lasts fewer than this many days
  ///
  /// In en, this message translates to:
  /// **'Warning threshold (in days)'**
  String get fieldMinStockDays;

  /// Explains the day-based warning threshold
  ///
  /// In en, this message translates to:
  /// **'Warn when the supply lasts fewer than x days'**
  String get fieldMinStockDaysHint;

  /// Explains the quantity-based warning threshold
  ///
  /// In en, this message translates to:
  /// **'Warn when stock drops below this value'**
  String get fieldMinStockHint;

  /// Default unit for an infusion medication: one bottle/vial
  ///
  /// In en, this message translates to:
  /// **'Bottle'**
  String get unitBottle;

  /// Default unit for pills and supplies: pieces; keep it short, it sits in tight rows
  ///
  /// In en, this message translates to:
  /// **'pcs'**
  String get unitPieces;

  /// Validation error for an empty required text field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// Title of the shopping wizard dialog
  ///
  /// In en, this message translates to:
  /// **'Shopping assistant'**
  String get shoppingWizardTitle;

  /// Title of the shopping wizard when editing an existing order
  ///
  /// In en, this message translates to:
  /// **'Edit order'**
  String get shoppingWizardEditTitle;

  /// Explains what the shopping wizard does
  ///
  /// In en, this message translates to:
  /// **'Work out how many supplies you need based on the medication order you are planning.'**
  String get shoppingWizardIntro;

  /// Intro text when editing an existing order
  ///
  /// In en, this message translates to:
  /// **'Adjust your order and the matching supplies.'**
  String get shoppingWizardEditIntro;

  /// Dropdown option for ordering supplies without any medication
  ///
  /// In en, this message translates to:
  /// **'Order supplies only (no medication)'**
  String get shoppingWizardSuppliesOnly;

  /// Input label for how much of the medication to order
  ///
  /// In en, this message translates to:
  /// **'Order quantity ({unit})'**
  String shoppingWizardOrderQuantity(String unit);

  /// Label for the optional expected delivery date
  ///
  /// In en, this message translates to:
  /// **'Delivery date (optional)'**
  String get shoppingWizardDeliveryDate;

  /// Shown when no delivery date is set, meaning stock is added on confirmation
  ///
  /// In en, this message translates to:
  /// **'Right after confirmation'**
  String get shoppingWizardImmediately;

  /// Heading above the suggested supplies list
  ///
  /// In en, this message translates to:
  /// **'Suggested supplies:'**
  String get shoppingWizardSuggestion;

  /// Sub-heading for supplies the app considers necessary for this order
  ///
  /// In en, this message translates to:
  /// **'Required for this order:'**
  String get shoppingWizardRequired;

  /// Sub-heading for supplies the user may add optionally
  ///
  /// In en, this message translates to:
  /// **'Other supplies (optional):'**
  String get shoppingWizardOptional;

  /// Shown when the wizard could not derive any supply suggestions
  ///
  /// In en, this message translates to:
  /// **'No supplies suggested automatically.'**
  String get shoppingWizardNoSuggestions;

  /// Button that opens a picker to add another supply item manually
  ///
  /// In en, this message translates to:
  /// **'Add another supply item'**
  String get shoppingWizardAddOther;

  /// Button that saves the assembled order
  ///
  /// In en, this message translates to:
  /// **'Save order'**
  String get shoppingWizardSaveOrder;

  /// Title of the dialog listing supplies to pick from
  ///
  /// In en, this message translates to:
  /// **'Select supply item'**
  String get shoppingWizardPickSupply;

  /// Snackbar shown when the picked supply is already on the order
  ///
  /// In en, this message translates to:
  /// **'Already in the list!'**
  String get shoppingWizardAlreadyInList;

  /// Badge on a supply row the app calculated the amount for
  ///
  /// In en, this message translates to:
  /// **'Recommended amount'**
  String get shoppingWizardRecommendedAmount;

  /// Badge on a supply row the user added themselves
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get shoppingWizardAdditionallySelected;

  /// Action that stops an active medication without deleting its history
  ///
  /// In en, this message translates to:
  /// **'Discontinue'**
  String get medDetailsDiscontinue;

  /// Button that discontinues the medication
  ///
  /// In en, this message translates to:
  /// **'Discontinue medication'**
  String get medDetailsDiscontinueMedication;

  /// Action that puts a discontinued medication back into active use
  ///
  /// In en, this message translates to:
  /// **'Prescribe again'**
  String get medDetailsReenroll;

  /// Tooltip for permanently deleting the medication
  ///
  /// In en, this message translates to:
  /// **'Delete completely'**
  String get medDetailsDeleteCompletely;

  /// Button that permanently removes the medication and its data
  ///
  /// In en, this message translates to:
  /// **'Delete completely from database'**
  String get medDetailsDeleteFromDatabase;

  /// Banner shown on a discontinued medication
  ///
  /// In en, this message translates to:
  /// **'This medication has been discontinued since {date}'**
  String medDetailsDiscontinuedSince(String date);

  /// Section header for stock level and warning threshold
  ///
  /// In en, this message translates to:
  /// **'Stock & warnings'**
  String get medDetailsSectionStock;

  /// Section header for supplies linked to this medication
  ///
  /// In en, this message translates to:
  /// **'Linked supplies'**
  String get medDetailsSectionSupplies;

  /// Explains that linked supplies are deducted automatically
  ///
  /// In en, this message translates to:
  /// **'These supplies are deducted from stock automatically with every dose.'**
  String get medDetailsSuppliesHint;

  /// Empty state when no supplies are linked yet
  ///
  /// In en, this message translates to:
  /// **'No supplies linked yet'**
  String get medDetailsNoSuppliesLinked;

  /// Button that links an existing supply item to this medication
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get medDetailsLink;

  /// Button that creates a new supply item and links it right away
  ///
  /// In en, this message translates to:
  /// **'New & link'**
  String get medDetailsCreateAndLink;

  /// Section header for what is asked when logging a dose
  ///
  /// In en, this message translates to:
  /// **'Logging workflow'**
  String get medDetailsSectionWorkflow;

  /// Explains the workflow toggles below it
  ///
  /// In en, this message translates to:
  /// **'Choose which fields appear when you log a dose.'**
  String get medDetailsWorkflowHint;

  /// Explains the schedules section
  ///
  /// In en, this message translates to:
  /// **'Set the rhythm in which you take this medication.'**
  String get medDetailsSchedulesHint;

  /// Button that opens the form for a recurring schedule
  ///
  /// In en, this message translates to:
  /// **'Create schedule'**
  String get medDetailsCreateSchedule;

  /// Button that opens the dialog for a single appointment
  ///
  /// In en, this message translates to:
  /// **'Plan one-off appointment'**
  String get medDetailsPlanOneOff;

  /// Section header for destructive/administrative actions
  ///
  /// In en, this message translates to:
  /// **'System actions'**
  String get medDetailsSectionSystemActions;

  /// How much of a supply one dose consumes
  ///
  /// In en, this message translates to:
  /// **'Required: {amount} {unit}'**
  String medDetailsRequirement(String amount, String unit);

  /// Tooltip on the star marking a supply that must always be ordered along
  ///
  /// In en, this message translates to:
  /// **'Must always be ordered'**
  String get medDetailsMustBeOrdered;

  /// Snackbar shown when linking is attempted with no supplies defined
  ///
  /// In en, this message translates to:
  /// **'Create supply items first!'**
  String get medDetailsNeedSuppliesFirst;

  /// Title of the dialog for linking an existing supply item
  ///
  /// In en, this message translates to:
  /// **'Link supply item'**
  String get medDetailsLinkSupplyTitle;

  /// Dropdown label for choosing which supply item to link
  ///
  /// In en, this message translates to:
  /// **'Select supply item'**
  String get medDetailsPickSupply;

  /// Title of the dialog for creating a new supply item
  ///
  /// In en, this message translates to:
  /// **'Create new supply item'**
  String get medDetailsCreateSupplyTitle;

  /// Toggle: always include this supply when ordering
  ///
  /// In en, this message translates to:
  /// **'Always order along'**
  String get medDetailsAlwaysOrder;

  /// Explains what the always-order toggle does
  ///
  /// In en, this message translates to:
  /// **'Highlighted in the shopping assistant'**
  String get medDetailsAlwaysOrderHint;

  /// Title of the dialog for editing the medication's master data
  ///
  /// In en, this message translates to:
  /// **'Edit medication'**
  String get medDetailsEditMedication;

  /// Title of the permanent-delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete medication?'**
  String get medDetailsDeleteTitle;

  /// Warns that deletion is irreversible and points to discontinuing instead
  ///
  /// In en, this message translates to:
  /// **'Permanently delete \"{name}\" from the app? This cannot be undone and should only be used to correct mistakes. To end a therapy, use \"Discontinue\" instead.'**
  String medDetailsDeleteBody(String name);

  /// Title of the discontinue confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Discontinue medication?'**
  String get medDetailsDiscontinueTitle;

  /// Explains what discontinuing does: hidden from the active list, history kept
  ///
  /// In en, this message translates to:
  /// **'Discontinue \"{name}\"? It leaves the active list but stays in your history. Future appointments will be deleted.'**
  String medDetailsDiscontinueBody(String name);

  /// Shows a schedule's intake times
  ///
  /// In en, this message translates to:
  /// **'Times: {times}'**
  String medDetailsTimes(String times);

  /// Toggle: ask for a batch number when logging a dose
  ///
  /// In en, this message translates to:
  /// **'Record batch number'**
  String get medDetailsTrackBatch;

  /// Explains the batch-number toggle
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode or type it in'**
  String get medDetailsTrackBatchHint;

  /// Toggle: ask for body weight when logging a dose
  ///
  /// In en, this message translates to:
  /// **'Record body weight'**
  String get medDetailsTrackWeight;

  /// Explains the body-weight toggle
  ///
  /// In en, this message translates to:
  /// **'Log your weight with each dose'**
  String get medDetailsTrackWeightHint;

  /// Toggle: show the premedication timer when logging a dose
  ///
  /// In en, this message translates to:
  /// **'Use dosing timer'**
  String get medDetailsUseTimer;

  /// Explains the dosing-timer toggle
  ///
  /// In en, this message translates to:
  /// **'Premedication timer before the dose'**
  String get medDetailsUseTimerHint;

  /// Title of the dialog configuring one linked supply item
  ///
  /// In en, this message translates to:
  /// **'Configure {name}'**
  String medDetailsConfigureNamed(String name);

  /// Link that opens the supply item's global settings
  ///
  /// In en, this message translates to:
  /// **'Edit supply item globally (name, unit)'**
  String get medDetailsEditSupplyGlobally;

  /// Snackbar confirming the stock level was saved
  ///
  /// In en, this message translates to:
  /// **'Stock level updated'**
  String get medDetailsStockUpdated;

  /// Button that saves the stock level and threshold
  ///
  /// In en, this message translates to:
  /// **'Save stock level'**
  String get medDetailsSaveStock;

  /// Input label: how much of a supply one infusion needs
  ///
  /// In en, this message translates to:
  /// **'Required per infusion'**
  String get fieldPerInfusionRequirement;

  /// Same as fieldPerInfusionRequirement with the unit appended
  ///
  /// In en, this message translates to:
  /// **'Required per infusion ({unit})'**
  String fieldPerInfusionRequirementWithUnit(String unit);

  /// Input label for a new supply item's name
  ///
  /// In en, this message translates to:
  /// **'Supply item name'**
  String get fieldSupplyName;

  /// Input label for the unit, with examples for supplies
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g. pcs, set)'**
  String get fieldUnitWithExample;

  /// Input label for the unit, with a medication example
  ///
  /// In en, this message translates to:
  /// **'Unit (e.g. bottle)'**
  String get fieldUnitWithBottleExample;

  /// Input label for the medication's strength, with an example
  ///
  /// In en, this message translates to:
  /// **'Dose / strength (e.g. 10g)'**
  String get fieldStrengthWithExample;

  /// Input label for the German pharmaceutical central number
  ///
  /// In en, this message translates to:
  /// **'PZN'**
  String get fieldPzn;

  /// Short input label for the current stock level
  ///
  /// In en, this message translates to:
  /// **'Current stock'**
  String get fieldCurrentStockShort;

  /// Input label for a planned dose, with the unit appended
  ///
  /// In en, this message translates to:
  /// **'Planned dose ({unit})'**
  String fieldPlannedDoseWithUnit(String unit);

  /// Button that creates a new record
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// Android notification channel name for the silent background service
  ///
  /// In en, this message translates to:
  /// **'Background service'**
  String get channelBackgroundService;

  /// Description of the background service channel
  ///
  /// In en, this message translates to:
  /// **'Used for the timer and background tasks'**
  String get channelBackgroundServiceDesc;

  /// Android notification channel name for low-stock warnings
  ///
  /// In en, this message translates to:
  /// **'Stock warnings'**
  String get channelStockWarnings;

  /// Description of the stock warning channel
  ///
  /// In en, this message translates to:
  /// **'Tells you when medications or supplies are running low'**
  String get channelStockWarningsDesc;

  /// Android channel name and notification title for missed intakes
  ///
  /// In en, this message translates to:
  /// **'Missed intakes'**
  String get channelMissedIntakes;

  /// Description of the missed-intakes channel
  ///
  /// In en, this message translates to:
  /// **'Notices about unconfirmed or missed intakes'**
  String get channelMissedIntakesDesc;

  /// Android notification channel name for backup errors
  ///
  /// In en, this message translates to:
  /// **'Backup failures'**
  String get channelBackupFailures;

  /// Description of the backup failure channel
  ///
  /// In en, this message translates to:
  /// **'Notifications about problems with the automatic backup'**
  String get channelBackupFailuresDesc;

  /// Android notification channel name for backup setup reminders
  ///
  /// In en, this message translates to:
  /// **'Backup warnings'**
  String get channelBackupWarnings;

  /// Description of the backup warning channel
  ///
  /// In en, this message translates to:
  /// **'Notices about setting up your backup'**
  String get channelBackupWarningsDesc;

  /// Android notification channel name for treatment reminders
  ///
  /// In en, this message translates to:
  /// **'Medication reminders'**
  String get channelMedReminders;

  /// Description of the medication reminder channel
  ///
  /// In en, this message translates to:
  /// **'Reminders for planned intakes and infusions'**
  String get channelMedRemindersDesc;

  /// Description of the premedication timer channel
  ///
  /// In en, this message translates to:
  /// **'Running timer for premedication'**
  String get channelPremedTimerDesc;

  /// Notification title when a dose becomes due
  ///
  /// In en, this message translates to:
  /// **'Reminder: medication due'**
  String get reminderDueTitle;

  /// Notification body naming the medication that is due
  ///
  /// In en, this message translates to:
  /// **'It\'s time for your dose of {medication}.'**
  String reminderDueBody(String medication);

  /// Stand-in used in reminderDueBody when the medication name is not available; must fit the sentence grammatically
  ///
  /// In en, this message translates to:
  /// **'your medication'**
  String get reminderGenericMedication;

  /// Title of the repeated reminder shown a few minutes later
  ///
  /// In en, this message translates to:
  /// **'Reminder (repeat)'**
  String get reminderSnoozeTitle;

  /// Body of the repeated reminder
  ///
  /// In en, this message translates to:
  /// **'You haven\'t marked your dose as done yet.'**
  String get reminderSnoozeBody;

  /// Title of the hourly follow-up reminder
  ///
  /// In en, this message translates to:
  /// **'Reminder (hourly)'**
  String get reminderHourlyTitle;

  /// Body of the hourly follow-up reminder
  ///
  /// In en, this message translates to:
  /// **'Please don\'t forget your dose.'**
  String get reminderHourlyBody;

  /// Note stored on a dose confirmed from a notification action
  ///
  /// In en, this message translates to:
  /// **'Completed via notification'**
  String get notificationCompletedNote;

  /// Note appended when an appointment is skipped from a notification action
  ///
  /// In en, this message translates to:
  /// **'[Skipped via notification]'**
  String get notificationSkippedNote;

  /// Notification title when the premedication countdown ends
  ///
  /// In en, this message translates to:
  /// **'Premedication complete'**
  String get timerFinishedTitle;

  /// Notification body when the premedication countdown ends
  ///
  /// In en, this message translates to:
  /// **'The timer has run out — the infusion can begin.'**
  String get timerFinishedBody;

  /// Summary line when several intakes are unconfirmed
  ///
  /// In en, this message translates to:
  /// **'{count} intakes not confirmed'**
  String missedIntakesSummary(int count);

  /// Android summary text showing how many intakes are still open
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String missedIntakesOpenCount(int count);

  /// Daily notification title nudging the user to set up backups
  ///
  /// In en, this message translates to:
  /// **'Set up your backup'**
  String get backupReminderTitle;

  /// Body of the backup setup reminder
  ///
  /// In en, this message translates to:
  /// **'Your data isn\'t backed up automatically yet. Tap here to set it up.'**
  String get backupReminderBody;

  /// Notification title when an automatic backup failed
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailedTitle;

  /// Notification body with the backup error message
  ///
  /// In en, this message translates to:
  /// **'The automatic backup could not be created: {error}'**
  String backupFailedBody(String error);

  /// Name of the app-internal backup folder; the arrows describe where to find it in the iOS Files app
  ///
  /// In en, this message translates to:
  /// **'App folder (Files app → CIDP Buddy → Backups)'**
  String get backupDestinationAppFolder;

  /// Fallback name for an Android SAF folder with no display name
  ///
  /// In en, this message translates to:
  /// **'Cloud / SAF folder'**
  String get backupDestinationSafFolder;

  /// Error when the backup folder cannot be read
  ///
  /// In en, this message translates to:
  /// **'Folder not readable: {path}\n({error})'**
  String backupFolderUnreadable(String path, String error);

  /// Error when the backup folder no longer exists
  ///
  /// In en, this message translates to:
  /// **'Folder no longer exists: {path}'**
  String backupFolderMissing(String path);

  /// Error when the backup folder cannot be written to
  ///
  /// In en, this message translates to:
  /// **'Write access denied: {path}\n({error})'**
  String backupFolderNotWritable(String path, String error);

  /// Diagnostic line: the folder does not exist
  ///
  /// In en, this message translates to:
  /// **'Folder does not exist.'**
  String get backupFolderMissingShort;

  /// Diagnostic line: the folder contains nothing
  ///
  /// In en, this message translates to:
  /// **'Folder is empty.'**
  String get backupFolderEmpty;

  /// Diagnostic line: the Android SAF folder contains nothing
  ///
  /// In en, this message translates to:
  /// **'SAF folder is empty.'**
  String get backupSafFolderEmpty;

  /// Diagnostic line listing what the folder actually holds
  ///
  /// In en, this message translates to:
  /// **'Found ({count}): {names}'**
  String backupFolderContents(int count, String names);

  /// Diagnostic line when the folder could not be listed
  ///
  /// In en, this message translates to:
  /// **'Folder could not be listed: {error}'**
  String backupFolderListFailed(String error);

  /// Diagnostic line when the SAF folder could not be listed
  ///
  /// In en, this message translates to:
  /// **'SAF folder could not be listed: {error}'**
  String backupSafListFailed(String error);

  /// Error when Android revoked the persisted folder permission
  ///
  /// In en, this message translates to:
  /// **'Permission for the cloud folder was lost. Please pick the folder again.'**
  String get backupSafPermissionLost;

  /// Error when no backup destination has been chosen
  ///
  /// In en, this message translates to:
  /// **'No backup destination selected.'**
  String get backupNoDestination;

  /// Reason a scheduled backup did not run: the feature is off
  ///
  /// In en, this message translates to:
  /// **'Automatic backup is disabled.'**
  String get backupAutoDisabled;

  /// Reason a scheduled backup did not run: a recent one already exists
  ///
  /// In en, this message translates to:
  /// **'Skipped: a recent backup already exists.'**
  String get backupSkippedRecent;

  /// Error when writing the backup archive failed
  ///
  /// In en, this message translates to:
  /// **'Write error: {error}'**
  String backupWriteError(String error);

  /// Settings section header for theme and language
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// Toggle for the dark colour scheme
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get settingsDarkMode;

  /// Explains the dark theme toggle
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark mode'**
  String get settingsDarkModeHint;

  /// Settings row and picker title for the app language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language option that follows the device setting
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get settingsLanguageSystem;

  /// Name of the English language, shown in its own language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Name of the German language, shown in its own language
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// Name of the French language, shown in its own language
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// Name of the Italian language, shown in its own language
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// Name of the Spanish language, shown in its own language
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Settings section header for the automatic backup
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get settingsSectionAutoBackup;

  /// Toggle that turns automatic backups on
  ///
  /// In en, this message translates to:
  /// **'Enable automatic backup'**
  String get settingsEnableAutoBackup;

  /// Explains the automatic backup toggle
  ///
  /// In en, this message translates to:
  /// **'Backs your data up regularly to the chosen folder'**
  String get settingsEnableAutoBackupHint;

  /// Error card title when backups cannot run
  ///
  /// In en, this message translates to:
  /// **'Backup not possible'**
  String get settingsBackupNotPossible;

  /// Placeholder when no specific error message is available
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get settingsUnknownError;

  /// Button that re-opens the folder picker to restore access
  ///
  /// In en, this message translates to:
  /// **'Pick folder again'**
  String get settingsPickFolderAgain;

  /// Warning title: backups live inside the app sandbox
  ///
  /// In en, this message translates to:
  /// **'Backups live inside the app'**
  String get settingsBackupsInsideAppTitle;

  /// Warns that app-internal backups are erased with the app and points to the export action
  ///
  /// In en, this message translates to:
  /// **'They are deleted along with the app. Export a copy to iCloud Drive regularly — via \"Export backup\" or the Files app.'**
  String get settingsBackupsInsideAppBody;

  /// Row and dialog title for where backups are written
  ///
  /// In en, this message translates to:
  /// **'Backup destination'**
  String get settingsBackupDestination;

  /// Placeholder when no backup destination is chosen yet
  ///
  /// In en, this message translates to:
  /// **'Choose destination…'**
  String get settingsPickDestination;

  /// Row that triggers a backup immediately
  ///
  /// In en, this message translates to:
  /// **'Run backup now'**
  String get settingsRunBackupNow;

  /// Snackbar after a successful manual backup
  ///
  /// In en, this message translates to:
  /// **'Backup successful!'**
  String get settingsBackupSucceeded;

  /// Snackbar after a failed manual backup
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String settingsBackupFailed(String error);

  /// Row that shares the latest backup out of the app
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExportBackup;

  /// Explains where an exported backup can go
  ///
  /// In en, this message translates to:
  /// **'Save the latest backup to Files or iCloud Drive, for example'**
  String get settingsExportBackupHint;

  /// Snackbar when export is tapped but no backup exists
  ///
  /// In en, this message translates to:
  /// **'No backup found to export. Run a backup first.'**
  String get settingsNoBackupToExport;

  /// Row showing when the last backup succeeded
  ///
  /// In en, this message translates to:
  /// **'Last successful'**
  String get settingsLastSuccess;

  /// Row showing when a backup was last attempted
  ///
  /// In en, this message translates to:
  /// **'Last attempt'**
  String get settingsLastAttempt;

  /// Row that opens the restore flow
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get settingsRestoreBackup;

  /// Explains the restore row
  ///
  /// In en, this message translates to:
  /// **'Pick an automatic backup to restore'**
  String get settingsRestoreBackupHint;

  /// Explains why iOS backups are stored inside the app instead of a user-picked folder
  ///
  /// In en, this message translates to:
  /// **'On iOS automatic backups are stored inside the app, because Apple does not allow lasting write access to freely chosen folders.\n\nUse \"Export backup\" to save a copy to the Files app, iCloud Drive or via AirDrop.'**
  String get settingsIosStorageInfo;

  /// Snackbar when the chosen folder could not be connected
  ///
  /// In en, this message translates to:
  /// **'Could not connect the destination. Please pick a different one.'**
  String get settingsDestinationConnectFailed;

  /// Snackbar after successfully connecting a backup folder
  ///
  /// In en, this message translates to:
  /// **'Backup destination connected.'**
  String get settingsDestinationConnected;

  /// Settings section header for reminder behaviour
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsSectionReminders;

  /// Toggle for repeating a reminder after a delay
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get settingsSnooze;

  /// Explains the snooze toggle; repeats three times
  ///
  /// In en, this message translates to:
  /// **'Remind again every {minutes} minutes (3×)'**
  String settingsSnoozeHint(int minutes);

  /// Row and picker title for the snooze interval
  ///
  /// In en, this message translates to:
  /// **'Snooze interval'**
  String get settingsSnoozeInterval;

  /// Shows the configured snooze interval
  ///
  /// In en, this message translates to:
  /// **'Currently: every {minutes} minutes'**
  String settingsSnoozeIntervalCurrent(int minutes);

  /// Snooze interval option
  ///
  /// In en, this message translates to:
  /// **'Every {minutes} minutes'**
  String settingsEveryNMinutes(int minutes);

  /// Toggle for hourly follow-up reminders
  ///
  /// In en, this message translates to:
  /// **'Hourly reminder'**
  String get settingsHourlyReminder;

  /// Explains the hourly reminder toggle
  ///
  /// In en, this message translates to:
  /// **'Remind on the hour'**
  String get settingsHourlyReminderHint;

  /// Row for the time window in which no reminders fire
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get settingsQuietHours;

  /// Title of the quiet hours picker
  ///
  /// In en, this message translates to:
  /// **'Set quiet hours'**
  String get settingsQuietHoursTitle;

  /// Shows the configured quiet window
  ///
  /// In en, this message translates to:
  /// **'No reminders from {start} to {end}'**
  String settingsQuietHoursHint(String start, String end);

  /// Label for when the quiet window begins
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get settingsQuietHoursStart;

  /// Label for when the quiet window ends
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get settingsQuietHoursEnd;

  /// Settings section header for system and reliability checks
  ///
  /// In en, this message translates to:
  /// **'System & reliability'**
  String get settingsSectionSystem;

  /// Settings section header for the Hyqvia premedication timer; Hyqvia is a product name and stays untranslated
  ///
  /// In en, this message translates to:
  /// **'Hyqvia timer'**
  String get settingsSectionHyqviaTimer;

  /// Toggle that offers the timer automatically
  ///
  /// In en, this message translates to:
  /// **'Suggest timer automatically'**
  String get settingsSuggestTimer;

  /// Explains when the timer is offered
  ///
  /// In en, this message translates to:
  /// **'Offer the premedication timer for Hyqvia infusions'**
  String get settingsSuggestTimerHint;

  /// Row for the default premedication duration
  ///
  /// In en, this message translates to:
  /// **'Premedication duration'**
  String get settingsPremedDuration;

  /// Shows a currently configured duration
  ///
  /// In en, this message translates to:
  /// **'Currently: {minutes} minutes'**
  String settingsCurrentMinutes(int minutes);

  /// Title of the default duration picker
  ///
  /// In en, this message translates to:
  /// **'Set default duration'**
  String get settingsSetDefaultDuration;

  /// Settings section header for legal notices
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsSectionLegal;

  /// Settings section header for version info; CIDP Buddy is the app name
  ///
  /// In en, this message translates to:
  /// **'About CIDP Buddy'**
  String get settingsSectionAbout;

  /// Label for the app version number
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// Label for when this build was produced
  ///
  /// In en, this message translates to:
  /// **'Build timestamp'**
  String get settingsBuildTimestamp;

  /// Row title stating where data is stored
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// States that all data stays on the device
  ///
  /// In en, this message translates to:
  /// **'All data is stored locally on this device.'**
  String get settingsPrivacyHint;

  /// Title of the sheet listing available backups
  ///
  /// In en, this message translates to:
  /// **'Select backup'**
  String get settingsPickBackup;

  /// Button that lets the user pick a backup ZIP file directly
  ///
  /// In en, this message translates to:
  /// **'Pick ZIP'**
  String get settingsPickZip;

  /// Empty state title: no backup folder is connected
  ///
  /// In en, this message translates to:
  /// **'No backup folder connected'**
  String get restoreNoFolderTitle;

  /// Empty state body asking the user to pick the folder holding their backups
  ///
  /// In en, this message translates to:
  /// **'Pick the folder your backups live in — for example the cloud folder from an earlier install.'**
  String get restoreNoFolderBody;

  /// Button that opens the folder picker for restoring
  ///
  /// In en, this message translates to:
  /// **'Choose backup folder'**
  String get restorePickFolder;

  /// Button that opens the folder picker to try a different folder
  ///
  /// In en, this message translates to:
  /// **'Choose a different folder'**
  String get restorePickOtherFolder;

  /// Shows which folder is currently connected
  ///
  /// In en, this message translates to:
  /// **'Current folder:\n{label}'**
  String restoreCurrentFolder(String label);

  /// Empty state title: the app lost access to the backup folder
  ///
  /// In en, this message translates to:
  /// **'Lost access to the backup folder'**
  String get restoreAccessLostTitle;

  /// Tells the user re-picking the folder restores permission without data loss
  ///
  /// In en, this message translates to:
  /// **'Pick the folder again to restore permission. Your existing backups are untouched.'**
  String get restoreAccessLostBody;

  /// Empty state title: the connected folder holds no backups
  ///
  /// In en, this message translates to:
  /// **'No backups found'**
  String get restoreNoBackupsTitle;

  /// Explains which filenames the app looks for; the two patterns are literal filename prefixes
  ///
  /// In en, this message translates to:
  /// **'The connected folder holds no backups (files named \"cidpbuddy_backup_…zip\" or \"igkeeper_backup_…zip\").'**
  String get restoreNoBackupsBody;

  /// Suggests picking another folder if the backups live elsewhere
  ///
  /// In en, this message translates to:
  /// **'If your backups are in a different folder, choose it here.'**
  String get restoreNoBackupsHint;

  /// Error when the backup list could not be read
  ///
  /// In en, this message translates to:
  /// **'Backups could not be read: {error}'**
  String restoreReadFailed(String error);

  /// Snackbar when the picked restore folder could not be connected
  ///
  /// In en, this message translates to:
  /// **'Folder could not be connected.'**
  String get restoreFolderConnectFailed;

  /// Title of the restore confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get restoreConfirmTitle;

  /// Asks the user to confirm restoring a specific file
  ///
  /// In en, this message translates to:
  /// **'Really restore the file \"{name}\"?'**
  String restoreConfirmFile(String name);

  /// Asks the user to confirm restoring the backup from a given date
  ///
  /// In en, this message translates to:
  /// **'Really restore the backup from {date}?'**
  String restoreConfirmDated(String date);

  /// All-caps warning that restoring destroys current data
  ///
  /// In en, this message translates to:
  /// **'WARNING: all current data will be overwritten irreversibly!'**
  String get restoreOverwriteWarning;

  /// Snackbar when a restore did not complete
  ///
  /// In en, this message translates to:
  /// **'Restore failed.'**
  String get restoreFailed;

  /// Snackbar after a successful restore; the app restarts right after
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully. Restarting the app…'**
  String get restoreSucceeded;

  /// Fallback when the app could not restart itself
  ///
  /// In en, this message translates to:
  /// **'Please restart the app manually.'**
  String get restoreRestartManually;

  /// Title of the liability disclaimer
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get legalLiabilityTitle;

  /// One-line summary of the disclaimer
  ///
  /// In en, this message translates to:
  /// **'Not a medical device, not medical advice'**
  String get legalLiabilitySubtitle;

  /// Title of the batch documentation notice
  ///
  /// In en, this message translates to:
  /// **'Batch documentation'**
  String get legalBatchDocumentationTitle;

  /// One-line summary of the batch documentation notice
  ///
  /// In en, this message translates to:
  /// **'Does not replace the legally required documentation'**
  String get legalBatchDocumentationSubtitle;

  /// Link to the legal notice / imprint page
  ///
  /// In en, this message translates to:
  /// **'Legal notice'**
  String get legalImprint;

  /// Link to the privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get legalPrivacyPolicy;

  /// Neutral dialog dismiss button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// Button acknowledging an informational dialog
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get actionUnderstood;

  /// Button that starts restoring a backup
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// Generic inline error message
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String genericError(String error);

  /// Title of the reliability check page
  ///
  /// In en, this message translates to:
  /// **'Reliability check'**
  String get reliabilityTitle;

  /// Settings row subtitle describing the reliability check
  ///
  /// In en, this message translates to:
  /// **'Check permissions & battery settings'**
  String get reliabilitySubtitle;

  /// Check item: notification permission
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get reliabilityNotifications;

  /// Why the notification permission matters
  ///
  /// In en, this message translates to:
  /// **'Needed for medication reminders and timer completion.'**
  String get reliabilityNotificationsDesc;

  /// Check item: Android exact alarm permission
  ///
  /// In en, this message translates to:
  /// **'Exact alarms'**
  String get reliabilityExactAlarms;

  /// Why the exact alarm permission matters
  ///
  /// In en, this message translates to:
  /// **'Lets the app fire reminders to the second.'**
  String get reliabilityExactAlarmsDesc;

  /// Check item: Android battery optimization exemption
  ///
  /// In en, this message translates to:
  /// **'Battery optimization'**
  String get reliabilityBatteryOptimization;

  /// Why the battery optimization exemption matters
  ///
  /// In en, this message translates to:
  /// **'Stops Android from killing the app in the background.'**
  String get reliabilityBatteryOptimizationDesc;

  /// Why automatic backup matters
  ///
  /// In en, this message translates to:
  /// **'Backs your data up regularly, to the cloud or locally.'**
  String get reliabilityBackupDesc;

  /// Check item: state of the most recent backup
  ///
  /// In en, this message translates to:
  /// **'Backup status'**
  String get reliabilityBackupStatus;

  /// Shown when the last backup is recent
  ///
  /// In en, this message translates to:
  /// **'Your last backup is up to date.'**
  String get reliabilityBackupUpToDate;

  /// Shown when the last backup is old or failed
  ///
  /// In en, this message translates to:
  /// **'Your last backup is outdated or failed.'**
  String get reliabilityBackupStale;

  /// Headline when every reliability check passes
  ///
  /// In en, this message translates to:
  /// **'All good!'**
  String get reliabilityAllGood;

  /// Body when every reliability check passes
  ///
  /// In en, this message translates to:
  /// **'Your settings are ideal for maximum reliability.'**
  String get reliabilityAllGoodBody;

  /// Headline when at least one reliability check fails
  ///
  /// In en, this message translates to:
  /// **'Action needed'**
  String get reliabilityActionNeeded;

  /// Body when at least one reliability check fails
  ///
  /// In en, this message translates to:
  /// **'Some settings limit how reliably reminders can fire.'**
  String get reliabilityActionNeededBody;

  /// Button that opens the system setting for a failing check
  ///
  /// In en, this message translates to:
  /// **'Fix this setting'**
  String get reliabilityFix;

  /// Explains that the page refreshes itself on return from system settings
  ///
  /// In en, this message translates to:
  /// **'Note: the checks refresh automatically when you come back from the system settings.'**
  String get reliabilityFooterHint;

  /// Button that re-runs all reliability checks
  ///
  /// In en, this message translates to:
  /// **'Refresh status now'**
  String get reliabilityRefresh;

  /// Full batch documentation notice; TFG is the German Transfusion Act and stays untranslated as a named law
  ///
  /// In en, this message translates to:
  /// **'CIDP Buddy stores batch numbers, photos and notes solely as a personal memory aid on your device.\n\nThese records do not replace the batch documentation required by law under the German Transfusion Act (TFG) or the national rules that apply to you. That duty remains with your doctor or your treating facility.\n\nSo keep the required documentation exactly as before — even when you also record the details in this app.'**
  String get legalBatchDocumentationLong;

  /// Full liability disclaimer shown in the legal section
  ///
  /// In en, this message translates to:
  /// **'CIDP Buddy is a private organisational tool and not a medical device. The app exists solely to make managing your appointments, stock and notes easier.\n\nThe app is not medical advice and replaces neither diagnosis nor treatment nor any recommendation from healthcare professionals. Never make decisions about your therapy, dosage or medication based on this app alone. If you have health concerns, contact your doctor; in an emergency, call the emergency services.\n\nAll calculations (stock coverage, low-stock warnings, planned appointments and so on) are based on the data you entered and may be wrong. Reminders and notifications may be delayed, duplicated or missed entirely because of power-saving features, system settings or operating-system bugs. Do not rely on the app alone.\n\nAll data lives only on your device. Backing it up is your responsibility; no liability is accepted for data loss.\n\nUse is at your own risk. Liability for damages arising from use or unavailability of the app is excluded to the extent permitted by law.'**
  String get legalLiabilityBody;

  /// Subject line when sharing the database file out of the app
  ///
  /// In en, this message translates to:
  /// **'CIDP Buddy backup'**
  String get shareBackupSubject;

  /// Message body when sharing the database file
  ///
  /// In en, this message translates to:
  /// **'Backup of the CIDP Buddy database from {date}'**
  String shareBackupText(String date);
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
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
