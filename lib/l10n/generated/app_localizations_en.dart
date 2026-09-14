// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsEmpty => 'No data available for statistics yet.';

  @override
  String get statisticsMonthlyDose => 'Monthly dose';

  @override
  String get statisticsMonthlyDoseSubtitle =>
      'Units administered over the last 6 months';

  @override
  String get statisticsSummary => 'Summary';

  @override
  String get statisticsTotalInfusions => 'Total infusions';

  @override
  String get statisticsTotalDose => 'Total dose';

  @override
  String get statisticsAverageDose => 'Ø dose / administration';

  @override
  String get statisticsLastWeight => 'Last weight';

  @override
  String unitsValue(String value) {
    return '$value units';
  }

  @override
  String kilogramsValue(String value) {
    return '$value kg';
  }

  @override
  String get timerBannerRunning => 'Premedication timer running';

  @override
  String get timerBannerPaused => 'Premedication timer paused';

  @override
  String timerBannerRemaining(String time) {
    return '$time remaining • Tap to open';
  }

  @override
  String get discontinuedTitle => 'Discontinued medications';

  @override
  String get discontinuedEmpty => 'No discontinued medications.';

  @override
  String discontinuedOn(String date) {
    return 'Discontinued on: $date';
  }

  @override
  String get timerTitle => 'Premedication timer';

  @override
  String timerSubtitle(int seconds) {
    return 'Ping every minute • $seconds sec timer';
  }

  @override
  String get timerRemainingLabel => 'remaining';

  @override
  String get timerSyringeProgress => 'Syringe progress';

  @override
  String get timerVolumePickerTitle => 'Premedication volume (ml)';

  @override
  String get backgroundServiceRunning => 'Service running in the background';

  @override
  String timerNotificationRemaining(String time) {
    return 'Remaining: $time';
  }

  @override
  String get medicationFallbackName => 'Medication';

  @override
  String get appTitle => 'CIDP Buddy';

  @override
  String startupFailed(String error) {
    return 'The app could not be initialized:\n$error';
  }

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navDiary => 'Diary';

  @override
  String get navMedication => 'Medication';

  @override
  String get navSettings => 'Settings';

  @override
  String get diaryEntryTitleNew => 'Vitals & symptoms';

  @override
  String get diaryEntryTitleEdit => 'Edit entry';

  @override
  String get diaryEntrySave => 'Save entry';

  @override
  String get diaryNotesHint => 'How are you feeling today?';

  @override
  String get sectionDateTime => 'Date & time';

  @override
  String get sectionVitals => 'Vital signs (optional)';

  @override
  String get sectionSymptoms => 'CIDP symptoms (1-10)';

  @override
  String get sectionNotes => 'Additional notes';

  @override
  String get fieldSystolic => 'Syst. (mmHg)';

  @override
  String get fieldDiastolic => 'Diast. (mmHg)';

  @override
  String get fieldHeartRate => 'Pulse (bpm)';

  @override
  String get fieldTemperature => 'Temp. (°C)';

  @override
  String get fieldWeight => 'Weight (kg)';

  @override
  String get symptomStrength => 'Strength';

  @override
  String get symptomSensory => 'Sensation';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomPain => 'Pain';

  @override
  String get symptomBalance => 'Balance';

  @override
  String get addInfusionTitle => 'Log infusion';

  @override
  String get addInfusionDetailsHeading => 'Infusion details';

  @override
  String get addInfusionPickMedication => 'Select medication';

  @override
  String get addInfusionWhen => 'Time of infusion';

  @override
  String get addInfusionSaveAndStartTimer => 'Save & start timer';

  @override
  String get addInfusionSaveAndDeductStock => 'Save infusion & deduct stock';

  @override
  String get fieldBatchNumber => 'Batch number / barcode';

  @override
  String get fieldBatchNumberHint => 'Scan or type';

  @override
  String get fieldDosageUnits => 'Dosage / units';

  @override
  String get fieldBodyWeight => 'Body weight (kg)';

  @override
  String get fieldInfusionNotes => 'Notes (how you felt, how it went)';

  @override
  String get actionScanBarcode => 'Scan barcode';

  @override
  String get actionPhotoOfLabel => 'Photo of batch/label';

  @override
  String get validationPickOne => 'Please select';

  @override
  String get legalBatchDocumentationShort =>
      'Batch documentation in this app is a personal note and does not replace the legally required documentation kept by you or your treating facility.';

  @override
  String get scheduleTitleNew => 'Create infusion schedule';

  @override
  String get scheduleTitleEdit => 'Edit infusion schedule';

  @override
  String get scheduleSelectDays => 'Select days:';

  @override
  String get scheduleAddTime => 'Add another time';

  @override
  String get scheduleActivate => 'Activate schedule';

  @override
  String get sectionMedicationAndDose => 'Medication & dose';

  @override
  String get sectionFrequency => 'Frequency';

  @override
  String get sectionPeriod => 'Period';

  @override
  String get sectionIntakeTimes => 'Intake times';

  @override
  String get fieldUnitsPerInfusion => 'Units per infusion';

  @override
  String get fieldNumberOfDays => 'Number of days';

  @override
  String get fieldNumberOfDaysHint => 'E.g. every 5 days';

  @override
  String get fieldStartDate => 'Start date';

  @override
  String get frequencyDaily => 'Daily';

  @override
  String get frequencyInterval => 'Every X days';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyBiweekly => 'Every 2 weeks';

  @override
  String get frequencyWeekdays => 'Specific weekdays';

  @override
  String get actionSaveChanges => 'Save changes';

  @override
  String get diaryTitle => 'My diary';

  @override
  String get diaryEmptyTitle => 'Your diary is still empty';

  @override
  String get diaryEmptyBody =>
      'Log your first infusion to keep track of your treatment.';

  @override
  String get diaryVitalsAndSymptomsLabel => 'VITALS & SYMPTOMS:';

  @override
  String get diaryDeleteEntryTitle => 'Delete entry?';

  @override
  String get diaryDeleteEntryBody =>
      'Delete this entry? The stock will be credited back automatically.';

  @override
  String get diaryOrderReceived => 'Order received';

  @override
  String diaryEventDiscontinued(String name) {
    return 'Discontinued: $name';
  }

  @override
  String diaryEventPrescribed(String name) {
    return 'Newly prescribed: $name';
  }

  @override
  String get fieldBatchNumberShort => 'Batch number';

  @override
  String get fieldNotes => 'Notes';

  @override
  String batchValue(String batch) {
    return 'Batch: $batch';
  }

  @override
  String bpmValue(String value) {
    return '$value bpm';
  }

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get planningTitle => 'Appointments & plans';

  @override
  String get planningTabUpcoming => 'Upcoming';

  @override
  String get planningTabSchedules => 'Schedules';

  @override
  String get planningOverdue => 'Overdue';

  @override
  String get planningNoUpcoming => 'No upcoming appointments';

  @override
  String get planningNoSchedules => 'No active schedules';

  @override
  String planningScheduledFor(String date) {
    return 'Scheduled for $date';
  }

  @override
  String get planningDeletePastTitle => 'Delete past appointments?';

  @override
  String get planningDeletePastBody =>
      'Permanently delete all planned appointments in the past?\n\nThis does not create any diary entries.';

  @override
  String get planningSkipTitle => 'Skip appointment?';

  @override
  String get planningSkipBody =>
      'Skip this appointment? It will be marked as done but not recorded in the diary.';

  @override
  String get planningSkippedNote => '[Skipped via app]';

  @override
  String get planningDeleteAppointmentTitle => 'Delete appointment?';

  @override
  String get planningDeleteAppointmentBody =>
      'Remove this specific appointment from your plan?';

  @override
  String get planningEditAppointmentTitle => 'Edit appointment';

  @override
  String get planningDeleteScheduleTitle => 'Delete schedule?';

  @override
  String get planningDeleteScheduleBody =>
      'All future (uncompleted) appointments from this schedule will be deleted too.';

  @override
  String get planningOneOffTitle => 'One-off appointment';

  @override
  String get planningOneOffSubtitle => 'Add a single appointment';

  @override
  String get planningRecurringTitle => 'Recurring schedule';

  @override
  String get planningRecurringSubtitle => 'Set up an automatic infusion rhythm';

  @override
  String get planningNeedMedicationsFirst =>
      'Add medications to your inventory first!';

  @override
  String get planningScheduleAppointmentTitle => 'Schedule appointment';

  @override
  String frequencyEveryNDays(int days) {
    return 'Every $days days';
  }

  @override
  String get frequencyWeekdaysShort => 'Weekdays';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldPlannedDose => 'Planned dose';

  @override
  String fieldDoseWithUnit(String unit) {
    return 'Dose ($unit)';
  }

  @override
  String doseValue(String amount, String unit) {
    return 'Dose: $amount $unit';
  }

  @override
  String get actionAdd => 'Add';

  @override
  String get actionDeleteAll => 'Delete all';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionDone => 'Done';

  @override
  String get dashboardTitle => 'Your overview';

  @override
  String dashboardSectionLater(int count) {
    return 'PLANNED LATER ($count)';
  }

  @override
  String dashboardSectionPast(int count) {
    return 'PAST APPOINTMENTS ($count)';
  }

  @override
  String get dashboardNoBackupTitle => 'No backup enabled';

  @override
  String get dashboardNoBackupBody =>
      'Set up automatic backup to avoid losing your data.';

  @override
  String get dashboardOrderRecommended => 'Order recommended';

  @override
  String dashboardLowStockNames(String names) {
    return 'Low stock: $names';
  }

  @override
  String get dashboardOrdersOnTheWay => 'Orders are on the way.';

  @override
  String get dashboardPendingDeliveries => 'PENDING DELIVERIES';

  @override
  String dashboardDeliveryDate(String date) {
    return 'Delivery date: $date';
  }

  @override
  String get dashboardNoDeliveryDate => 'No date set yet';

  @override
  String get dashboardDeleteOrderTitle => 'Delete order?';

  @override
  String get dashboardDeleteOrderBody => 'Remove this pending order?';

  @override
  String get dashboardConfirmDeliveryTitle => 'Delivery received?';

  @override
  String get dashboardConfirmDeliveryBody =>
      'Confirm receipt of this delivery? Your stock will be updated automatically.';

  @override
  String get dashboardConfirmDeliveryYes => 'Yes, received';

  @override
  String get dashboardStockUpdated => 'Stock updated!';

  @override
  String get dashboardReceived => 'Received';

  @override
  String dashboardMissedAt(String time) {
    return 'Missed (planned for $time)';
  }

  @override
  String dashboardTodayAt(String time) {
    return 'Today at $time';
  }

  @override
  String get dashboardMissedInfusion => 'Missed infusion (planned for today)';

  @override
  String dashboardPlannedToday(String amount, String unit) {
    return 'Planned today ($amount $unit)';
  }

  @override
  String dashboardMarkedDone(String name) {
    return '$name done!';
  }

  @override
  String get dashboardLogInfusionNow => 'Log infusion now';

  @override
  String get dashboardAllDoneTitle => 'All done!';

  @override
  String get dashboardAllDoneBody => 'No pending tasks.';

  @override
  String dashboardTreatmentSubtitle(
    String date,
    String time,
    String amount,
    String unit,
  ) {
    return '$date at $time • $amount $unit';
  }

  @override
  String get dashboardOrphanRemoved => 'Orphaned appointment removed';

  @override
  String get dashboardUnknownMedication => 'Unknown medication';

  @override
  String dashboardOrphanSubtitle(String date) {
    return 'Planned $date • medication not found';
  }

  @override
  String quantityValue(String amount, String unit) {
    return 'Quantity: $amount $unit';
  }

  @override
  String get today => 'Today';

  @override
  String get actionNo => 'No';

  @override
  String get actionRemove => 'Remove';

  @override
  String get inventorySectionMedications => 'MEDICATIONS';

  @override
  String get inventorySectionStandaloneSupplies => 'STANDALONE SUPPLIES';

  @override
  String get inventoryNoMedications => 'No medications added';

  @override
  String inventoryNextTreatment(String date) {
    return 'Next: $date';
  }

  @override
  String inventoryLastsUntil(String date) {
    return 'Lasts until: $date';
  }

  @override
  String get inventoryLowStock => 'Low stock!';

  @override
  String get inventoryOrderOnTheWay => 'Order on the way';

  @override
  String inventoryPzn(String pzn) {
    return 'PZN: $pzn';
  }

  @override
  String stockValue(String amount, String unit) {
    return 'Stock: $amount $unit';
  }

  @override
  String get accessoryEditTitle => 'Edit supply item';

  @override
  String get accessoryDeleteTitle => 'Delete supply item?';

  @override
  String confirmDeleteNamed(String name) {
    return 'Really delete \"$name\"?';
  }

  @override
  String get fieldName => 'Name';

  @override
  String get fieldUnit => 'Unit';

  @override
  String get fieldCurrentStock => 'Current stock';

  @override
  String get fieldPackageSize => 'Package size (for ordering)';

  @override
  String get fieldMinStock => 'Warning threshold (stock)';

  @override
  String get addItemTitle => 'Add new item';

  @override
  String get fieldCategory => 'Category';

  @override
  String get categoryMedication => 'Medication';

  @override
  String get categorySupply => 'Supply item';

  @override
  String get fieldDosageForm => 'Dosage form';

  @override
  String get dosageFormInfusion => 'Infusion';

  @override
  String get dosageFormPill => 'Tablet / pill';

  @override
  String get fieldMedicationName => 'Medication name';

  @override
  String get fieldMedicationNameHint => 'e.g. Hizentra';

  @override
  String get fieldStrength => 'Dose / strength';

  @override
  String get fieldStrengthHint => 'e.g. 20% or 10ml';

  @override
  String get fieldPznOptional => 'PZN (optional)';

  @override
  String get fieldPznHint => 'Pharmaceutical central number';

  @override
  String get fieldInitialStock => 'Initial stock';

  @override
  String get fieldDefaultReorderAmount => 'Default reorder amount';

  @override
  String get fieldDefaultReorderAmountHint => 'e.g. 10 bottles';

  @override
  String get fieldMinStockDays => 'Warning threshold (in days)';

  @override
  String get fieldMinStockDaysHint =>
      'Warn when the supply lasts fewer than x days';

  @override
  String get fieldMinStockHint => 'Warn when stock drops below this value';

  @override
  String get unitBottle => 'Bottle';

  @override
  String get unitPieces => 'pcs';

  @override
  String get validationRequired => 'Required';

  @override
  String get shoppingWizardTitle => 'Shopping assistant';

  @override
  String get shoppingWizardEditTitle => 'Edit order';

  @override
  String get shoppingWizardIntro =>
      'Work out how many supplies you need based on the medication order you are planning.';

  @override
  String get shoppingWizardEditIntro =>
      'Adjust your order and the matching supplies.';

  @override
  String get shoppingWizardSuppliesOnly =>
      'Order supplies only (no medication)';

  @override
  String shoppingWizardOrderQuantity(String unit) {
    return 'Order quantity ($unit)';
  }

  @override
  String get shoppingWizardDeliveryDate => 'Delivery date (optional)';

  @override
  String get shoppingWizardImmediately => 'Right after confirmation';

  @override
  String get shoppingWizardSuggestion => 'Suggested supplies:';

  @override
  String get shoppingWizardRequired => 'Required for this order:';

  @override
  String get shoppingWizardOptional => 'Other supplies (optional):';

  @override
  String get shoppingWizardNoSuggestions =>
      'No supplies suggested automatically.';

  @override
  String get shoppingWizardAddOther => 'Add another supply item';

  @override
  String get shoppingWizardSaveOrder => 'Save order';

  @override
  String get shoppingWizardPickSupply => 'Select supply item';

  @override
  String get shoppingWizardAlreadyInList => 'Already in the list!';

  @override
  String get shoppingWizardRecommendedAmount => 'Recommended amount';

  @override
  String get shoppingWizardAdditionallySelected => 'Added by you';

  @override
  String get medDetailsDiscontinue => 'Discontinue';

  @override
  String get medDetailsDiscontinueMedication => 'Discontinue medication';

  @override
  String get medDetailsReenroll => 'Prescribe again';

  @override
  String get medDetailsDeleteCompletely => 'Delete completely';

  @override
  String get medDetailsDeleteFromDatabase => 'Delete completely from database';

  @override
  String medDetailsDiscontinuedSince(String date) {
    return 'This medication has been discontinued since $date';
  }

  @override
  String get medDetailsSectionStock => 'Stock & warnings';

  @override
  String get medDetailsSectionSupplies => 'Linked supplies';

  @override
  String get medDetailsSuppliesHint =>
      'These supplies are deducted from stock automatically with every dose.';

  @override
  String get medDetailsNoSuppliesLinked => 'No supplies linked yet';

  @override
  String get medDetailsLink => 'Link';

  @override
  String get medDetailsCreateAndLink => 'New & link';

  @override
  String get medDetailsSectionWorkflow => 'Logging workflow';

  @override
  String get medDetailsWorkflowHint =>
      'Choose which fields appear when you log a dose.';

  @override
  String get medDetailsSchedulesHint =>
      'Set the rhythm in which you take this medication.';

  @override
  String get medDetailsCreateSchedule => 'Create schedule';

  @override
  String get medDetailsPlanOneOff => 'Plan one-off appointment';

  @override
  String get medDetailsSectionSystemActions => 'System actions';

  @override
  String medDetailsRequirement(String amount, String unit) {
    return 'Required: $amount $unit';
  }

  @override
  String get medDetailsMustBeOrdered => 'Must always be ordered';

  @override
  String get medDetailsNeedSuppliesFirst => 'Create supply items first!';

  @override
  String get medDetailsLinkSupplyTitle => 'Link supply item';

  @override
  String get medDetailsPickSupply => 'Select supply item';

  @override
  String get medDetailsCreateSupplyTitle => 'Create new supply item';

  @override
  String get medDetailsAlwaysOrder => 'Always order along';

  @override
  String get medDetailsAlwaysOrderHint =>
      'Highlighted in the shopping assistant';

  @override
  String get medDetailsEditMedication => 'Edit medication';

  @override
  String get medDetailsDeleteTitle => 'Delete medication?';

  @override
  String medDetailsDeleteBody(String name) {
    return 'Permanently delete \"$name\" from the app? This cannot be undone and should only be used to correct mistakes. To end a therapy, use \"Discontinue\" instead.';
  }

  @override
  String get medDetailsDiscontinueTitle => 'Discontinue medication?';

  @override
  String medDetailsDiscontinueBody(String name) {
    return 'Discontinue \"$name\"? It leaves the active list but stays in your history. Future appointments will be deleted.';
  }

  @override
  String medDetailsTimes(String times) {
    return 'Times: $times';
  }

  @override
  String get medDetailsTrackBatch => 'Record batch number';

  @override
  String get medDetailsTrackBatchHint => 'Scan a barcode or type it in';

  @override
  String get medDetailsTrackWeight => 'Record body weight';

  @override
  String get medDetailsTrackWeightHint => 'Log your weight with each dose';

  @override
  String get medDetailsUseTimer => 'Use dosing timer';

  @override
  String get medDetailsUseTimerHint => 'Premedication timer before the dose';

  @override
  String medDetailsConfigureNamed(String name) {
    return 'Configure $name';
  }

  @override
  String get medDetailsEditSupplyGlobally =>
      'Edit supply item globally (name, unit)';

  @override
  String get medDetailsStockUpdated => 'Stock level updated';

  @override
  String get medDetailsSaveStock => 'Save stock level';

  @override
  String get fieldPerInfusionRequirement => 'Required per infusion';

  @override
  String fieldPerInfusionRequirementWithUnit(String unit) {
    return 'Required per infusion ($unit)';
  }

  @override
  String get fieldSupplyName => 'Supply item name';

  @override
  String get fieldUnitWithExample => 'Unit (e.g. pcs, set)';

  @override
  String get fieldUnitWithBottleExample => 'Unit (e.g. bottle)';

  @override
  String get fieldStrengthWithExample => 'Dose / strength (e.g. 10g)';

  @override
  String get fieldPzn => 'PZN';

  @override
  String get fieldCurrentStockShort => 'Current stock';

  @override
  String fieldPlannedDoseWithUnit(String unit) {
    return 'Planned dose ($unit)';
  }

  @override
  String get actionCreate => 'Create';

  @override
  String get channelBackgroundService => 'Background service';

  @override
  String get channelBackgroundServiceDesc =>
      'Used for the timer and background tasks';

  @override
  String get channelStockWarnings => 'Stock warnings';

  @override
  String get channelStockWarningsDesc =>
      'Tells you when medications or supplies are running low';

  @override
  String get channelMissedIntakes => 'Missed intakes';

  @override
  String get channelMissedIntakesDesc =>
      'Notices about unconfirmed or missed intakes';

  @override
  String get channelBackupFailures => 'Backup failures';

  @override
  String get channelBackupFailuresDesc =>
      'Notifications about problems with the automatic backup';

  @override
  String get channelBackupWarnings => 'Backup warnings';

  @override
  String get channelBackupWarningsDesc =>
      'Notices about setting up your backup';

  @override
  String get channelMedReminders => 'Medication reminders';

  @override
  String get channelMedRemindersDesc =>
      'Reminders for planned intakes and infusions';

  @override
  String get channelPremedTimerDesc => 'Running timer for premedication';

  @override
  String get reminderDueTitle => 'Reminder: medication due';

  @override
  String reminderDueBody(String medication) {
    return 'It\'s time for your dose of $medication.';
  }

  @override
  String get reminderGenericMedication => 'your medication';

  @override
  String get reminderSnoozeTitle => 'Reminder (repeat)';

  @override
  String get reminderSnoozeBody => 'You haven\'t marked your dose as done yet.';

  @override
  String get reminderHourlyTitle => 'Reminder (hourly)';

  @override
  String get reminderHourlyBody => 'Please don\'t forget your dose.';

  @override
  String get notificationCompletedNote => 'Completed via notification';

  @override
  String get notificationSkippedNote => '[Skipped via notification]';

  @override
  String get timerFinishedTitle => 'Premedication complete';

  @override
  String get timerFinishedBody =>
      'The timer has run out — the infusion can begin.';

  @override
  String missedIntakesSummary(int count) {
    return '$count intakes not confirmed';
  }

  @override
  String missedIntakesOpenCount(int count) {
    return '$count open';
  }

  @override
  String get backupReminderTitle => 'Set up your backup';

  @override
  String get backupReminderBody =>
      'Your data isn\'t backed up automatically yet. Tap here to set it up.';

  @override
  String get backupFailedTitle => 'Backup failed';

  @override
  String backupFailedBody(String error) {
    return 'The automatic backup could not be created: $error';
  }

  @override
  String get backupDestinationAppFolder =>
      'App folder (Files app → CIDP Buddy → Backups)';

  @override
  String get backupDestinationSafFolder => 'Cloud / SAF folder';

  @override
  String backupFolderUnreadable(String path, String error) {
    return 'Folder not readable: $path\n($error)';
  }

  @override
  String backupFolderMissing(String path) {
    return 'Folder no longer exists: $path';
  }

  @override
  String backupFolderNotWritable(String path, String error) {
    return 'Write access denied: $path\n($error)';
  }

  @override
  String get backupFolderMissingShort => 'Folder does not exist.';

  @override
  String get backupFolderEmpty => 'Folder is empty.';

  @override
  String get backupSafFolderEmpty => 'SAF folder is empty.';

  @override
  String backupFolderContents(int count, String names) {
    return 'Found ($count): $names';
  }

  @override
  String backupFolderListFailed(String error) {
    return 'Folder could not be listed: $error';
  }

  @override
  String backupSafListFailed(String error) {
    return 'SAF folder could not be listed: $error';
  }

  @override
  String get backupSafPermissionLost =>
      'Permission for the cloud folder was lost. Please pick the folder again.';

  @override
  String get backupNoDestination => 'No backup destination selected.';

  @override
  String get backupAutoDisabled => 'Automatic backup is disabled.';

  @override
  String get backupSkippedRecent => 'Skipped: a recent backup already exists.';

  @override
  String backupWriteError(String error) {
    return 'Write error: $error';
  }

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark theme';

  @override
  String get settingsDarkModeHint => 'Switch between light and dark mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSpanish => 'Español';

  @override
  String get settingsSectionAutoBackup => 'Automatic backup';

  @override
  String get settingsEnableAutoBackup => 'Enable automatic backup';

  @override
  String get settingsEnableAutoBackupHint =>
      'Backs your data up regularly to the chosen folder';

  @override
  String get settingsBackupNotPossible => 'Backup not possible';

  @override
  String get settingsUnknownError => 'Unknown error';

  @override
  String get settingsPickFolderAgain => 'Pick folder again';

  @override
  String get settingsBackupsInsideAppTitle => 'Backups live inside the app';

  @override
  String get settingsBackupsInsideAppBody =>
      'They are deleted along with the app. Export a copy to iCloud Drive regularly — via \"Export backup\" or the Files app.';

  @override
  String get settingsBackupDestination => 'Backup destination';

  @override
  String get settingsPickDestination => 'Choose destination…';

  @override
  String get settingsRunBackupNow => 'Run backup now';

  @override
  String get settingsBackupSucceeded => 'Backup successful!';

  @override
  String settingsBackupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get settingsExportBackup => 'Export backup';

  @override
  String get settingsExportBackupHint =>
      'Save the latest backup to Files or iCloud Drive, for example';

  @override
  String get settingsNoBackupToExport =>
      'No backup found to export. Run a backup first.';

  @override
  String get settingsLastSuccess => 'Last successful';

  @override
  String get settingsLastAttempt => 'Last attempt';

  @override
  String get settingsRestoreBackup => 'Restore backup';

  @override
  String get settingsRestoreBackupHint => 'Pick an automatic backup to restore';

  @override
  String get settingsIosStorageInfo =>
      'On iOS automatic backups are stored inside the app, because Apple does not allow lasting write access to freely chosen folders.\n\nUse \"Export backup\" to save a copy to the Files app, iCloud Drive or via AirDrop.';

  @override
  String get settingsDestinationConnectFailed =>
      'Could not connect the destination. Please pick a different one.';

  @override
  String get settingsDestinationConnected => 'Backup destination connected.';

  @override
  String get settingsSectionReminders => 'Reminders';

  @override
  String get settingsSnooze => 'Snooze';

  @override
  String settingsSnoozeHint(int minutes) {
    return 'Remind again every $minutes minutes (3×)';
  }

  @override
  String get settingsSnoozeInterval => 'Snooze interval';

  @override
  String settingsSnoozeIntervalCurrent(int minutes) {
    return 'Currently: every $minutes minutes';
  }

  @override
  String settingsEveryNMinutes(int minutes) {
    return 'Every $minutes minutes';
  }

  @override
  String get settingsHourlyReminder => 'Hourly reminder';

  @override
  String get settingsHourlyReminderHint => 'Remind on the hour';

  @override
  String get settingsQuietHours => 'Quiet hours';

  @override
  String get settingsQuietHoursTitle => 'Set quiet hours';

  @override
  String settingsQuietHoursHint(String start, String end) {
    return 'No reminders from $start to $end';
  }

  @override
  String get settingsQuietHoursStart => 'Start';

  @override
  String get settingsQuietHoursEnd => 'End';

  @override
  String get settingsSectionSystem => 'System & reliability';

  @override
  String get settingsSectionHyqviaTimer => 'Hyqvia timer';

  @override
  String get settingsSuggestTimer => 'Suggest timer automatically';

  @override
  String get settingsSuggestTimerHint =>
      'Offer the premedication timer for Hyqvia infusions';

  @override
  String get settingsPremedDuration => 'Premedication duration';

  @override
  String settingsCurrentMinutes(int minutes) {
    return 'Currently: $minutes minutes';
  }

  @override
  String get settingsSetDefaultDuration => 'Set default duration';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsSectionAbout => 'About CIDP Buddy';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsBuildTimestamp => 'Build timestamp';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyHint =>
      'All data is stored locally on this device.';

  @override
  String get settingsPickBackup => 'Select backup';

  @override
  String get settingsPickZip => 'Pick ZIP';

  @override
  String get restoreNoFolderTitle => 'No backup folder connected';

  @override
  String get restoreNoFolderBody =>
      'Pick the folder your backups live in — for example the cloud folder from an earlier install.';

  @override
  String get restorePickFolder => 'Choose backup folder';

  @override
  String get restorePickOtherFolder => 'Choose a different folder';

  @override
  String restoreCurrentFolder(String label) {
    return 'Current folder:\n$label';
  }

  @override
  String get restoreAccessLostTitle => 'Lost access to the backup folder';

  @override
  String get restoreAccessLostBody =>
      'Pick the folder again to restore permission. Your existing backups are untouched.';

  @override
  String get restoreNoBackupsTitle => 'No backups found';

  @override
  String get restoreNoBackupsBody =>
      'The connected folder holds no backups (files named \"cidpbuddy_backup_…zip\" or \"igkeeper_backup_…zip\").';

  @override
  String get restoreNoBackupsHint =>
      'If your backups are in a different folder, choose it here.';

  @override
  String restoreReadFailed(String error) {
    return 'Backups could not be read: $error';
  }

  @override
  String get restoreFolderConnectFailed => 'Folder could not be connected.';

  @override
  String get restoreConfirmTitle => 'Restore backup?';

  @override
  String restoreConfirmFile(String name) {
    return 'Really restore the file \"$name\"?';
  }

  @override
  String restoreConfirmDated(String date) {
    return 'Really restore the backup from $date?';
  }

  @override
  String get restoreOverwriteWarning =>
      'WARNING: all current data will be overwritten irreversibly!';

  @override
  String get restoreFailed => 'Restore failed.';

  @override
  String get restoreSucceeded =>
      'Data restored successfully. Restarting the app…';

  @override
  String get restoreRestartManually => 'Please restart the app manually.';

  @override
  String get legalLiabilityTitle => 'Disclaimer';

  @override
  String get legalLiabilitySubtitle =>
      'Not a medical device, not medical advice';

  @override
  String get legalBatchDocumentationTitle => 'Batch documentation';

  @override
  String get legalBatchDocumentationSubtitle =>
      'Does not replace the legally required documentation';

  @override
  String get legalImprint => 'Legal notice';

  @override
  String get legalPrivacyPolicy => 'Privacy policy';

  @override
  String get actionOk => 'OK';

  @override
  String get actionUnderstood => 'Got it';

  @override
  String get actionRestore => 'Restore';

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get reliabilityTitle => 'Reliability check';

  @override
  String get reliabilitySubtitle => 'Check permissions & battery settings';

  @override
  String get reliabilityNotifications => 'Notifications';

  @override
  String get reliabilityNotificationsDesc =>
      'Needed for medication reminders and timer completion.';

  @override
  String get reliabilityExactAlarms => 'Exact alarms';

  @override
  String get reliabilityExactAlarmsDesc =>
      'Lets the app fire reminders to the second.';

  @override
  String get reliabilityBatteryOptimization => 'Battery optimization';

  @override
  String get reliabilityBatteryOptimizationDesc =>
      'Stops Android from killing the app in the background.';

  @override
  String get reliabilityBackupDesc =>
      'Backs your data up regularly, to the cloud or locally.';

  @override
  String get reliabilityBackupStatus => 'Backup status';

  @override
  String get reliabilityBackupUpToDate => 'Your last backup is up to date.';

  @override
  String get reliabilityBackupStale =>
      'Your last backup is outdated or failed.';

  @override
  String get reliabilityAllGood => 'All good!';

  @override
  String get reliabilityAllGoodBody =>
      'Your settings are ideal for maximum reliability.';

  @override
  String get reliabilityActionNeeded => 'Action needed';

  @override
  String get reliabilityActionNeededBody =>
      'Some settings limit how reliably reminders can fire.';

  @override
  String get reliabilityFix => 'Fix this setting';

  @override
  String get reliabilityFooterHint =>
      'Note: the checks refresh automatically when you come back from the system settings.';

  @override
  String get reliabilityRefresh => 'Refresh status now';

  @override
  String get legalBatchDocumentationLong =>
      'CIDP Buddy stores batch numbers, photos and notes solely as a personal memory aid on your device.\n\nThese records do not replace the batch documentation required by law under the German Transfusion Act (TFG) or the national rules that apply to you. That duty remains with your doctor or your treating facility.\n\nSo keep the required documentation exactly as before — even when you also record the details in this app.';

  @override
  String get legalLiabilityBody =>
      'CIDP Buddy is a private organisational tool and not a medical device. The app exists solely to make managing your appointments, stock and notes easier.\n\nThe app is not medical advice and replaces neither diagnosis nor treatment nor any recommendation from healthcare professionals. Never make decisions about your therapy, dosage or medication based on this app alone. If you have health concerns, contact your doctor; in an emergency, call the emergency services.\n\nAll calculations (stock coverage, low-stock warnings, planned appointments and so on) are based on the data you entered and may be wrong. Reminders and notifications may be delayed, duplicated or missed entirely because of power-saving features, system settings or operating-system bugs. Do not rely on the app alone.\n\nAll data lives only on your device. Backing it up is your responsibility; no liability is accepted for data loss.\n\nUse is at your own risk. Liability for damages arising from use or unavailability of the app is excluded to the extent permitted by law.';

  @override
  String get shareBackupSubject => 'CIDP Buddy backup';

  @override
  String shareBackupText(String date) {
    return 'Backup of the CIDP Buddy database from $date';
  }
}
