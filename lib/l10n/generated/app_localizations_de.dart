// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get statisticsTitle => 'Statistiken';

  @override
  String get statisticsEmpty => 'Noch keine Daten für Statistiken vorhanden.';

  @override
  String get statisticsMonthlyDose => 'Monatliche Dosis';

  @override
  String get statisticsMonthlyDoseSubtitle =>
      'Übersicht der verabreichten Einheiten der letzten 6 Monate';

  @override
  String get statisticsSummary => 'Zusammenfassung';

  @override
  String get statisticsTotalInfusions => 'Gesamt-Infusionen';

  @override
  String get statisticsTotalDose => 'Gesamt-Dosis';

  @override
  String get statisticsAverageDose => 'Ø Dosis / Gabe';

  @override
  String get statisticsLastWeight => 'Letztes Gewicht';

  @override
  String unitsValue(String value) {
    return '$value Einheiten';
  }

  @override
  String kilogramsValue(String value) {
    return '$value kg';
  }

  @override
  String get timerBannerRunning => 'Vormedikation Timer läuft';

  @override
  String get timerBannerPaused => 'Vormedikation Timer pausiert';

  @override
  String timerBannerRemaining(String time) {
    return '$time verbleibend • Tippen zum Öffnen';
  }

  @override
  String get discontinuedTitle => 'Abgesetzte Medikamente';

  @override
  String get discontinuedEmpty => 'Keine abgesetzten Medikamente vorhanden.';

  @override
  String discontinuedOn(String date) {
    return 'Abgesetzt am: $date';
  }

  @override
  String get timerTitle => 'Vormedikation Timer';

  @override
  String timerSubtitle(int seconds) {
    return 'Pin jede Minute • $seconds Sek. Timer';
  }

  @override
  String get timerRemainingLabel => 'verbleibend';

  @override
  String get timerSyringeProgress => 'Spritzen-Fortschritt';

  @override
  String get timerVolumePickerTitle => 'Vormedikation Menge (ml)';

  @override
  String get backgroundServiceRunning => 'Dienst läuft im Hintergrund';

  @override
  String timerNotificationRemaining(String time) {
    return 'Verbleibend: $time';
  }

  @override
  String get medicationFallbackName => 'Medikament';

  @override
  String get appTitle => 'CIDP Buddy';

  @override
  String startupFailed(String error) {
    return 'App konnte nicht initialisiert werden:\n$error';
  }

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navDiary => 'Tagebuch';

  @override
  String get navMedication => 'Medikation';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get diaryEntryTitleNew => 'Vitalwerte & Symptome';

  @override
  String get diaryEntryTitleEdit => 'Eintrag bearbeiten';

  @override
  String get diaryEntrySave => 'Eintrag speichern';

  @override
  String get diaryNotesHint => 'Wie fühlst du dich heute?';

  @override
  String get sectionDateTime => 'Datum & Uhrzeit';

  @override
  String get sectionVitals => 'Vitalparameter (Optional)';

  @override
  String get sectionSymptoms => 'CIDP-Symptome (1-10)';

  @override
  String get sectionNotes => 'Zusätzliche Notizen';

  @override
  String get fieldSystolic => 'Syst. (mmHg)';

  @override
  String get fieldDiastolic => 'Diast. (mmHg)';

  @override
  String get fieldHeartRate => 'Puls (bpm)';

  @override
  String get fieldTemperature => 'Temp. (°C)';

  @override
  String get fieldWeight => 'Gewicht (kg)';

  @override
  String get symptomStrength => 'Kraft / Stärke';

  @override
  String get symptomSensory => 'Gefühl / Sensorik';

  @override
  String get symptomFatigue => 'Erschöpfung / Fatigue';

  @override
  String get symptomPain => 'Schmerzen';

  @override
  String get symptomBalance => 'Gleichgewicht';

  @override
  String get addInfusionTitle => 'Infusion erfassen';

  @override
  String get addInfusionDetailsHeading => 'Details der Infusion';

  @override
  String get addInfusionPickMedication => 'Medikament wählen';

  @override
  String get addInfusionWhen => 'Zeitpunkt der Infusion';

  @override
  String get addInfusionSaveAndStartTimer => 'Speichern & Timer starten';

  @override
  String get addInfusionSaveAndDeductStock =>
      'Infusion speichern & Bestand abbuchen';

  @override
  String get fieldBatchNumber => 'Chargennummer / Barcode';

  @override
  String get fieldBatchNumberHint => 'Scannen oder tippen';

  @override
  String get fieldDosageUnits => 'Dosierung / Einheiten';

  @override
  String get fieldBodyWeight => 'Körpergewicht (kg)';

  @override
  String get fieldInfusionNotes => 'Notizen (Befinden, Verlauf)';

  @override
  String get actionScanBarcode => 'Barcode scannen';

  @override
  String get actionPhotoOfLabel => 'Foto von Charge/Aufkleber';

  @override
  String get validationPickOne => 'Bitte wählen';

  @override
  String get legalBatchDocumentationShort =>
      'Die Chargendokumentation in dieser App ist eine persönliche Notiz und ersetzt nicht die gesetzlich vorgeschriebene Dokumentation durch dich oder deine behandelnde Einrichtung.';

  @override
  String get scheduleTitleNew => 'Infusionsplan erstellen';

  @override
  String get scheduleTitleEdit => 'Infusionsplan bearbeiten';

  @override
  String get scheduleSelectDays => 'Tage auswählen:';

  @override
  String get scheduleAddTime => 'Weitere Uhrzeit hinzufügen';

  @override
  String get scheduleActivate => 'Zeitplan aktivieren';

  @override
  String get sectionMedicationAndDose => 'Medikation & Dosis';

  @override
  String get sectionFrequency => 'Häufigkeit';

  @override
  String get sectionPeriod => 'Zeitraum';

  @override
  String get sectionIntakeTimes => 'Einnahme-Uhrzeiten';

  @override
  String get fieldUnitsPerInfusion => 'Einheiten pro Infusion';

  @override
  String get fieldNumberOfDays => 'Anzahl der Tage';

  @override
  String get fieldNumberOfDaysHint => 'Z.B. alle 5 Tage';

  @override
  String get fieldStartDate => 'Startdatum';

  @override
  String get frequencyDaily => 'Täglich';

  @override
  String get frequencyInterval => 'Alle X Tage';

  @override
  String get frequencyWeekly => 'Wöchentlich';

  @override
  String get frequencyBiweekly => 'Alle 2 Wochen';

  @override
  String get frequencyWeekdays => 'Bestimmte Wochentage';

  @override
  String get actionSaveChanges => 'Änderungen speichern';

  @override
  String get diaryTitle => 'Mein Tagebuch';

  @override
  String get diaryEmptyTitle => 'Dein Tagebuch ist noch leer';

  @override
  String get diaryEmptyBody =>
      'Erfasse deine erste Infusion, um den Überblick über deine Behandlung zu behalten.';

  @override
  String get diaryVitalsAndSymptomsLabel => 'VITALWERTE & SYMPTOME:';

  @override
  String get diaryDeleteEntryTitle => 'Eintrag löschen?';

  @override
  String get diaryDeleteEntryBody =>
      'Möchtest du diesen Eintrag wirklich löschen? Der Bestand wird automatisch zurückgebucht.';

  @override
  String get diaryOrderReceived => 'Bestellung erhalten';

  @override
  String diaryEventDiscontinued(String name) {
    return 'Abgesetzt: $name';
  }

  @override
  String diaryEventPrescribed(String name) {
    return 'Neu verordnet: $name';
  }

  @override
  String get fieldBatchNumberShort => 'Chargennummer';

  @override
  String get fieldNotes => 'Notizen';

  @override
  String batchValue(String batch) {
    return 'Charge: $batch';
  }

  @override
  String bpmValue(String value) {
    return '$value bpm';
  }

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get planningTitle => 'Termine & Pläne';

  @override
  String get planningTabUpcoming => 'Anstehend';

  @override
  String get planningTabSchedules => 'Zeitpläne';

  @override
  String get planningOverdue => 'Überfällig';

  @override
  String get planningNoUpcoming => 'Keine zukünftigen Termine';

  @override
  String get planningNoSchedules => 'Keine aktiven Zeitpläne';

  @override
  String planningScheduledFor(String date) {
    return 'Geplant für den $date';
  }

  @override
  String get planningDeletePastTitle => 'Vergangene Termine löschen?';

  @override
  String get planningDeletePastBody =>
      'Möchtest du alle geplanten Termine aus der Vergangenheit unwiderruflich löschen?\n\nDies erstellt keine Einträge im Tagebuch.';

  @override
  String get planningSkipTitle => 'Termin überspringen?';

  @override
  String get planningSkipBody =>
      'Möchtest du diesen Termin überspringen? Er wird als erledigt markiert, aber nicht im Tagebuch protokolliert.';

  @override
  String get planningSkippedNote => '[Übersprungen via App]';

  @override
  String get planningDeleteAppointmentTitle => 'Termin löschen?';

  @override
  String get planningDeleteAppointmentBody =>
      'Möchtest du diesen spezifischen Termin aus deiner Planung entfernen?';

  @override
  String get planningEditAppointmentTitle => 'Termin bearbeiten';

  @override
  String get planningDeleteScheduleTitle => 'Zeitplan löschen?';

  @override
  String get planningDeleteScheduleBody =>
      'Alle zukünftigen (nicht erledigten) Termine dieses Plans werden ebenfalls gelöscht.';

  @override
  String get planningOneOffTitle => 'Einmaliger Termin';

  @override
  String get planningOneOffSubtitle => 'Einen einzelnen Termin hinzufügen';

  @override
  String get planningRecurringTitle => 'Wiederkehrender Plan';

  @override
  String get planningRecurringSubtitle =>
      'Einen automatischen Infusions-Rhythmus erstellen';

  @override
  String get planningNeedMedicationsFirst =>
      'Zuerst Medikamente im Inventar anlegen!';

  @override
  String get planningScheduleAppointmentTitle => 'Termin planen';

  @override
  String frequencyEveryNDays(int days) {
    return 'Alle $days Tage';
  }

  @override
  String get frequencyWeekdaysShort => 'Wochentage';

  @override
  String get fieldDate => 'Datum';

  @override
  String get fieldPlannedDose => 'Geplante Dosis';

  @override
  String fieldDoseWithUnit(String unit) {
    return 'Dosis ($unit)';
  }

  @override
  String doseValue(String amount, String unit) {
    return 'Dosis: $amount $unit';
  }

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionDeleteAll => 'Alle löschen';

  @override
  String get actionSkip => 'Überspringen';

  @override
  String get actionDone => 'Erledigt';

  @override
  String get dashboardTitle => 'Deine Übersicht';

  @override
  String dashboardSectionLater(int count) {
    return 'SPÄTER GEPLANT ($count)';
  }

  @override
  String dashboardSectionPast(int count) {
    return 'VERGANGENE TERMINE ($count)';
  }

  @override
  String get dashboardNoBackupTitle => 'Kein Backup aktiviert';

  @override
  String get dashboardNoBackupBody =>
      'Richte die automatische Sicherung ein, um Datenverlust zu vermeiden.';

  @override
  String get dashboardOrderRecommended => 'Bestellung empfohlen';

  @override
  String dashboardLowStockNames(String names) {
    return 'Niedriger Bestand: $names';
  }

  @override
  String get dashboardOrdersOnTheWay => 'Bestellungen sind unterwegs.';

  @override
  String get dashboardPendingDeliveries => 'AUSSTEHENDE LIEFERUNGEN';

  @override
  String dashboardDeliveryDate(String date) {
    return 'Lieferdatum: $date';
  }

  @override
  String get dashboardNoDeliveryDate => 'Noch kein Datum festgelegt';

  @override
  String get dashboardDeleteOrderTitle => 'Bestellung löschen?';

  @override
  String get dashboardDeleteOrderBody =>
      'Möchtest du diese ausstehende Bestellung wirklich entfernen?';

  @override
  String get dashboardConfirmDeliveryTitle => 'Lieferung bestätigt?';

  @override
  String get dashboardConfirmDeliveryBody =>
      'Möchtest du den Empfang dieser Lieferung bestätigen? Der Bestand wird automatisch aktualisiert.';

  @override
  String get dashboardConfirmDeliveryYes => 'Ja, erhalten';

  @override
  String get dashboardStockUpdated => 'Bestand wurde aktualisiert!';

  @override
  String get dashboardReceived => 'Erhalten';

  @override
  String dashboardMissedAt(String time) {
    return 'Verpasst (geplant $time Uhr)';
  }

  @override
  String dashboardTodayAt(String time) {
    return 'Heute um $time Uhr';
  }

  @override
  String get dashboardMissedInfusion =>
      'Verpasste Infusion (geplant für heute)';

  @override
  String dashboardPlannedToday(String amount, String unit) {
    return 'Heute geplant ($amount $unit)';
  }

  @override
  String dashboardMarkedDone(String name) {
    return '$name erledigt!';
  }

  @override
  String get dashboardLogInfusionNow => 'Jetzt Infusion erfassen';

  @override
  String get dashboardAllDoneTitle => 'Alles erledigt!';

  @override
  String get dashboardAllDoneBody => 'Keine anstehenden Aufgaben.';

  @override
  String dashboardTreatmentSubtitle(
    String date,
    String time,
    String amount,
    String unit,
  ) {
    return '$date um $time Uhr • $amount $unit';
  }

  @override
  String get dashboardOrphanRemoved => 'Verwaisten Termin entfernt';

  @override
  String get dashboardUnknownMedication => 'Unbekanntes Medikament';

  @override
  String dashboardOrphanSubtitle(String date) {
    return 'Geplant $date Uhr • Medikament nicht gefunden';
  }

  @override
  String quantityValue(String amount, String unit) {
    return 'Menge: $amount $unit';
  }

  @override
  String get today => 'Heute';

  @override
  String get actionNo => 'Nein';

  @override
  String get actionRemove => 'Entfernen';

  @override
  String get inventorySectionMedications => 'MEDIKAMENTE';

  @override
  String get inventorySectionStandaloneSupplies => 'STANDALONE MATERIAL';

  @override
  String get inventoryNoMedications => 'Keine Medikamente angelegt';

  @override
  String inventoryNextTreatment(String date) {
    return 'Nächste: $date Uhr';
  }

  @override
  String inventoryLastsUntil(String date) {
    return 'Reicht bis: $date';
  }

  @override
  String get inventoryLowStock => 'Niedriger Bestand!';

  @override
  String get inventoryOrderOnTheWay => 'Bestellung unterwegs';

  @override
  String inventoryPzn(String pzn) {
    return 'PZN: $pzn';
  }

  @override
  String stockValue(String amount, String unit) {
    return 'Bestand: $amount $unit';
  }

  @override
  String get accessoryEditTitle => 'Verbrauchsmaterial bearbeiten';

  @override
  String get accessoryDeleteTitle => 'Verbrauchsmaterial löschen?';

  @override
  String confirmDeleteNamed(String name) {
    return 'Möchtest du \"$name\" wirklich löschen?';
  }

  @override
  String get fieldName => 'Name';

  @override
  String get fieldUnit => 'Einheit';

  @override
  String get fieldCurrentStock => 'Momentaner Lagerstand';

  @override
  String get fieldPackageSize => 'Packungsgröße (für Bestellung)';

  @override
  String get fieldMinStock => 'Warnschwelle (Bestand)';

  @override
  String get addItemTitle => 'Neues Element hinzufügen';

  @override
  String get fieldCategory => 'Kategorie';

  @override
  String get categoryMedication => 'Medikament';

  @override
  String get categorySupply => 'Verbrauchsmaterial';

  @override
  String get fieldDosageForm => 'Darreichungsform';

  @override
  String get dosageFormInfusion => 'Infusion';

  @override
  String get dosageFormPill => 'Tablette / Pille';

  @override
  String get fieldMedicationName => 'Medikamentenname';

  @override
  String get fieldMedicationNameHint => 'z.B. Hizentra';

  @override
  String get fieldStrength => 'Dosis / Stärke';

  @override
  String get fieldStrengthHint => 'z.B. 20% oder 10ml';

  @override
  String get fieldPznOptional => 'PZN (Optional)';

  @override
  String get fieldPznHint => 'Pharmazentralnummer';

  @override
  String get fieldInitialStock => 'Anfangsbestand';

  @override
  String get fieldDefaultReorderAmount => 'Standard-Nachbestellmenge';

  @override
  String get fieldDefaultReorderAmountHint => 'z.B. 10 Flaschen';

  @override
  String get fieldMinStockDays => 'Warnschwelle (in Tagen)';

  @override
  String get fieldMinStockDaysHint =>
      'Warnung wenn Vorrat weniger als x Tage reicht';

  @override
  String get fieldMinStockHint =>
      'Warnung wenn Bestand unter diesen Wert fällt';

  @override
  String get unitBottle => 'Flasche';

  @override
  String get unitPieces => 'Stk';

  @override
  String get validationRequired => 'Pflichtfeld';

  @override
  String get shoppingWizardTitle => 'Einkaufs-Assistent';

  @override
  String get shoppingWizardEditTitle => 'Bestellung bearbeiten';

  @override
  String get shoppingWizardIntro =>
      'Berechne den Bedarf an Verbrauchsmaterial basierend auf deiner geplanten Medikamenten-Bestellung.';

  @override
  String get shoppingWizardEditIntro =>
      'Passe deine Bestellung und den Bedarf an Verbrauchsmaterial an.';

  @override
  String get shoppingWizardSuppliesOnly =>
      'Nur Verbrauchsmaterial bestellen (Kein Medikament)';

  @override
  String shoppingWizardOrderQuantity(String unit) {
    return 'Bestellmenge ($unit)';
  }

  @override
  String get shoppingWizardDeliveryDate => 'Lieferdatum (Optional)';

  @override
  String get shoppingWizardImmediately => 'Gleich nach Bestätigung';

  @override
  String get shoppingWizardSuggestion => 'Verbrauchsmaterial-Vorschlag:';

  @override
  String get shoppingWizardRequired => 'Notwendig für diese Bestellung:';

  @override
  String get shoppingWizardOptional =>
      'Weiteres Verbrauchsmaterial (Optional):';

  @override
  String get shoppingWizardNoSuggestions =>
      'Kein Verbrauchsmaterial automatisch vorgeschlagen.';

  @override
  String get shoppingWizardAddOther => 'Anderes Verbrauchsmaterial hinzufügen';

  @override
  String get shoppingWizardSaveOrder => 'Bestellung speichern';

  @override
  String get shoppingWizardPickSupply => 'Verbrauchsmaterial auswählen';

  @override
  String get shoppingWizardAlreadyInList => 'Bereits in der Liste!';

  @override
  String get shoppingWizardRecommendedAmount => 'Empfohlene Menge';

  @override
  String get shoppingWizardAdditionallySelected => 'Zusätzlich ausgewählt';

  @override
  String get medDetailsDiscontinue => 'Absetzen';

  @override
  String get medDetailsDiscontinueMedication => 'Medikament absetzen';

  @override
  String get medDetailsReenroll => 'Wieder verordnen';

  @override
  String get medDetailsDeleteCompletely => 'Vollständig löschen';

  @override
  String get medDetailsDeleteFromDatabase =>
      'Vollständig aus Datenbank löschen';

  @override
  String medDetailsDiscontinuedSince(String date) {
    return 'Dieses Medikament ist abgesetzt seit $date';
  }

  @override
  String get medDetailsSectionStock => 'Lagerstand & Warnungen';

  @override
  String get medDetailsSectionSupplies => 'Verknüpftes Verbrauchsmaterial';

  @override
  String get medDetailsSuppliesHint =>
      'Dieses Verbrauchsmaterial wird bei jeder Einnahme automatisch vom Bestand abgezogen.';

  @override
  String get medDetailsNoSuppliesLinked =>
      'Noch kein Verbrauchsmaterial verknüpft';

  @override
  String get medDetailsLink => 'Verknüpfen';

  @override
  String get medDetailsCreateAndLink => 'Neu & Verknüpfen';

  @override
  String get medDetailsSectionWorkflow => 'Einnahme-Workflow';

  @override
  String get medDetailsWorkflowHint =>
      'Konfiguriere hier, welche Felder beim Erfassen einer Einnahme angezeigt werden.';

  @override
  String get medDetailsSchedulesHint =>
      'Lege hier fest, in welchem Rhythmus du dieses Medikament einnimmst.';

  @override
  String get medDetailsCreateSchedule => 'Zeitplan erstellen';

  @override
  String get medDetailsPlanOneOff => 'Einmaligen Termin planen';

  @override
  String get medDetailsSectionSystemActions => 'System-Aktionen';

  @override
  String medDetailsRequirement(String amount, String unit) {
    return 'Bedarf: $amount $unit';
  }

  @override
  String get medDetailsMustBeOrdered => 'Muss mitbestellt werden';

  @override
  String get medDetailsNeedSuppliesFirst =>
      'Zuerst Verbrauchsmaterial anlegen!';

  @override
  String get medDetailsLinkSupplyTitle => 'Verbrauchsmaterial verknüpfen';

  @override
  String get medDetailsPickSupply => 'Verbrauchsmaterial wählen';

  @override
  String get medDetailsCreateSupplyTitle => 'Neues Verbrauchsmaterial anlegen';

  @override
  String get medDetailsAlwaysOrder => 'Immer mitbestellen';

  @override
  String get medDetailsAlwaysOrderHint =>
      'Wird im Einkaufsassistent hervorgehoben';

  @override
  String get medDetailsEditMedication => 'Medikament bearbeiten';

  @override
  String get medDetailsDeleteTitle => 'Medikament löschen?';

  @override
  String medDetailsDeleteBody(String name) {
    return 'Möchtest du \"$name\" wirklich vollständig aus der App löschen? Dies kann nicht rückgängig gemacht werden und sollte nur bei Fehlern erfolgen. Für Ende einer Therapie bitte \"Absetzen\" nutzen.';
  }

  @override
  String get medDetailsDiscontinueTitle => 'Medikament absetzen?';

  @override
  String medDetailsDiscontinueBody(String name) {
    return 'Möchtest du \"$name\" absetzen? Es wird aus der aktiven Liste entfernt, bleibt aber in der Historie erhalten. Zukünftige Termine werden gelöscht.';
  }

  @override
  String medDetailsTimes(String times) {
    return 'Zeiten: $times';
  }

  @override
  String get medDetailsTrackBatch => 'Chargennummer erfassen';

  @override
  String get medDetailsTrackBatchHint =>
      'Barcode scannen oder manuell eingeben';

  @override
  String get medDetailsTrackWeight => 'Körpergewicht erfassen';

  @override
  String get medDetailsTrackWeightHint =>
      'Gewicht bei der Einnahme protokollieren';

  @override
  String get medDetailsUseTimer => 'Einnahmetimer nutzen';

  @override
  String get medDetailsUseTimerHint => 'Premedikation-Timer vor der Einnahme';

  @override
  String medDetailsConfigureNamed(String name) {
    return '$name konfigurieren';
  }

  @override
  String get medDetailsEditSupplyGlobally =>
      'Zubehör global bearbeiten (Name, Einheit)';

  @override
  String get medDetailsStockUpdated => 'Lagerstand aktualisiert';

  @override
  String get medDetailsSaveStock => 'Lagerstand speichern';

  @override
  String get fieldPerInfusionRequirement => 'Bedarf pro Infusion';

  @override
  String fieldPerInfusionRequirementWithUnit(String unit) {
    return 'Bedarf pro Infusion ($unit)';
  }

  @override
  String get fieldSupplyName => 'Name des Verbrauchsmaterials';

  @override
  String get fieldUnitWithExample => 'Einheit (z.B. Stk, Set)';

  @override
  String get fieldUnitWithBottleExample => 'Einheit (z.B. Flasche)';

  @override
  String get fieldStrengthWithExample => 'Dosis / Stärke (z.B. 10g)';

  @override
  String get fieldPzn => 'PZN';

  @override
  String get fieldCurrentStockShort => 'Aktueller Bestand';

  @override
  String fieldPlannedDoseWithUnit(String unit) {
    return 'Geplante Dosis ($unit)';
  }

  @override
  String get actionCreate => 'Anlegen';

  @override
  String get channelBackgroundService => 'Hintergrunddienst';

  @override
  String get channelBackgroundServiceDesc =>
      'Wird für den Timer und Hintergrund-Tasks verwendet';

  @override
  String get channelStockWarnings => 'Bestands-Warnungen';

  @override
  String get channelStockWarningsDesc =>
      'Benachrichtigt dich, wenn Medikamente oder Zubehör zur Neige gehen';

  @override
  String get channelMissedIntakes => 'Verpasste Einnahmen';

  @override
  String get channelMissedIntakesDesc =>
      'Hinweise auf nicht bestätigte oder verpasste Einnahmen';

  @override
  String get channelBackupFailures => 'Backup-Fehler';

  @override
  String get channelBackupFailuresDesc =>
      'Benachrichtigungen bei Problemen mit der automatischen Datensicherung';

  @override
  String get channelBackupWarnings => 'Backup-Warnungen';

  @override
  String get channelBackupWarningsDesc =>
      'Hinweise zur Einrichtung der Datensicherung';

  @override
  String get channelMedReminders => 'Medikamenten Erinnerungen';

  @override
  String get channelMedRemindersDesc =>
      'Erinnerungen für geplante Einnahmen und Infusionen';

  @override
  String get channelPremedTimerDesc => 'Laufender Timer für die Vormedikation';

  @override
  String get reminderDueTitle => 'Erinnerung: Medikament fällig';

  @override
  String reminderDueBody(String medication) {
    return 'Es ist Zeit für deine Einnahme von $medication.';
  }

  @override
  String get reminderGenericMedication => 'deines Medikaments';

  @override
  String get reminderSnoozeTitle => 'Erinnerung (Wiederholung)';

  @override
  String get reminderSnoozeBody =>
      'Du hast deine Einnahme noch nicht als erledigt markiert.';

  @override
  String get reminderHourlyTitle => 'Erinnerung (Stündlich)';

  @override
  String get reminderHourlyBody => 'Bitte vergiss deine Einnahme nicht.';

  @override
  String get notificationCompletedNote => 'Via Benachrichtigung erledigt';

  @override
  String get notificationSkippedNote => '[Übersprungen via Benachrichtigung]';

  @override
  String get timerFinishedTitle => 'Vormedikation abgeschlossen';

  @override
  String get timerFinishedBody =>
      'Der Timer ist abgelaufen — Infusion kann beginnen.';

  @override
  String missedIntakesSummary(int count) {
    return '$count Einnahmen nicht bestätigt';
  }

  @override
  String missedIntakesOpenCount(int count) {
    return '$count offen';
  }

  @override
  String get backupReminderTitle => 'Datensicherung einrichten';

  @override
  String get backupReminderBody =>
      'Deine Daten sind noch nicht automatisch gesichert. Tippe hier, um das Backup zu konfigurieren.';

  @override
  String get backupFailedTitle => 'Backup fehlgeschlagen';

  @override
  String backupFailedBody(String error) {
    return 'Das automatische Backup konnte nicht erstellt werden: $error';
  }

  @override
  String get backupDestinationAppFolder =>
      'App-Ordner (Dateien-App → CIDP Buddy → Backups)';

  @override
  String get backupDestinationSafFolder => 'Cloud-/SAF-Ordner';

  @override
  String backupFolderUnreadable(String path, String error) {
    return 'Ordner nicht lesbar: $path\n($error)';
  }

  @override
  String backupFolderMissing(String path) {
    return 'Ordner existiert nicht (mehr): $path';
  }

  @override
  String backupFolderNotWritable(String path, String error) {
    return 'Schreibzugriff verweigert: $path\n($error)';
  }

  @override
  String get backupFolderMissingShort => 'Ordner existiert nicht.';

  @override
  String get backupFolderEmpty => 'Ordner ist leer.';

  @override
  String get backupSafFolderEmpty => 'SAF-Ordner ist leer.';

  @override
  String backupFolderContents(int count, String names) {
    return 'Gefunden ($count): $names';
  }

  @override
  String backupFolderListFailed(String error) {
    return 'Ordner konnte nicht gelistet werden: $error';
  }

  @override
  String backupSafListFailed(String error) {
    return 'SAF-Ordner konnte nicht gelistet werden: $error';
  }

  @override
  String get backupSafPermissionLost =>
      'Berechtigung für Cloud-Ordner verloren. Bitte Ordner erneut wählen.';

  @override
  String get backupNoDestination => 'Kein Backup-Ziel ausgewählt.';

  @override
  String get backupAutoDisabled => 'Automatisches Backup ist deaktiviert.';

  @override
  String get backupSkippedRecent => 'Übersprungen: aktuelles Backup vorhanden.';

  @override
  String backupWriteError(String error) {
    return 'Schreibfehler: $error';
  }

  @override
  String get settingsSectionAppearance => 'Erscheinungsbild';

  @override
  String get settingsDarkMode => 'Dunkles Design';

  @override
  String get settingsDarkModeHint =>
      'Wechsle zwischen hellem und dunklem Modus';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Systemsprache';

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
  String get settingsSectionAutoBackup => 'Automatisches Backup';

  @override
  String get settingsEnableAutoBackup => 'Automatisches Backup aktivieren';

  @override
  String get settingsEnableAutoBackupHint =>
      'Sichert deine Daten regelmäßig in den gewählten Ordner';

  @override
  String get settingsBackupNotPossible => 'Backup nicht möglich';

  @override
  String get settingsUnknownError => 'Unbekannter Fehler';

  @override
  String get settingsPickFolderAgain => 'Ordner erneut wählen';

  @override
  String get settingsBackupsInsideAppTitle => 'Backups liegen in der App';

  @override
  String get settingsBackupsInsideAppBody =>
      'Sie werden mit der App gelöscht. Exportiere regelmäßig eine Kopie nach iCloud Drive – über \"Backup exportieren\" oder die Dateien-App.';

  @override
  String get settingsBackupDestination => 'Backup-Ziel';

  @override
  String get settingsPickDestination => 'Ziel wählen...';

  @override
  String get settingsRunBackupNow => 'Backup jetzt ausführen';

  @override
  String get settingsBackupSucceeded => 'Backup erfolgreich!';

  @override
  String settingsBackupFailed(String error) {
    return 'Backup fehlgeschlagen: $error';
  }

  @override
  String get settingsExportBackup => 'Backup exportieren';

  @override
  String get settingsExportBackupHint =>
      'Letzte Sicherung z. B. in Dateien oder iCloud Drive speichern';

  @override
  String get settingsNoBackupToExport =>
      'Kein Backup zum Exportieren gefunden. Führe zuerst ein Backup aus.';

  @override
  String get settingsLastSuccess => 'Zuletzt erfolgreich';

  @override
  String get settingsLastAttempt => 'Letzter Versuch';

  @override
  String get settingsRestoreBackup => 'Sicherung wiederherstellen';

  @override
  String get settingsRestoreBackupHint =>
      'Wähle ein automatisches Backup zum Einspielen';

  @override
  String get settingsIosStorageInfo =>
      'Auf iOS werden automatische Backups app-intern gespeichert, da Apple keinen dauerhaften Schreibzugriff auf frei gewählte Ordner erlaubt.\n\nNutze \"Backup exportieren\", um eine Sicherung z. B. in die Dateien-App, iCloud Drive oder per AirDrop zu speichern.';

  @override
  String get settingsDestinationConnectFailed =>
      'Ziel konnte nicht verbunden werden. Bitte ein anderes wählen.';

  @override
  String get settingsDestinationConnected => 'Backup-Ziel verbunden.';

  @override
  String get settingsSectionReminders => 'Erinnerungen';

  @override
  String get settingsSnooze => 'Schlummer-Funktion';

  @override
  String settingsSnoozeHint(int minutes) {
    return 'Erneut erinnern alle $minutes Minuten (3×)';
  }

  @override
  String get settingsSnoozeInterval => 'Schlummer-Intervall';

  @override
  String settingsSnoozeIntervalCurrent(int minutes) {
    return 'Aktuell: alle $minutes Minuten';
  }

  @override
  String settingsEveryNMinutes(int minutes) {
    return 'Alle $minutes Minuten';
  }

  @override
  String get settingsHourlyReminder => 'Stündliche Erinnerung';

  @override
  String get settingsHourlyReminderHint => 'Erinnern zur vollen Stunde';

  @override
  String get settingsQuietHours => 'Nachtruhe';

  @override
  String get settingsQuietHoursTitle => 'Nachtruhe einstellen';

  @override
  String settingsQuietHoursHint(String start, String end) {
    return 'Keine Erinnerungen von $start bis $end';
  }

  @override
  String get settingsQuietHoursStart => 'Beginn';

  @override
  String get settingsQuietHoursEnd => 'Ende';

  @override
  String get settingsSectionSystem => 'System & Zuverlässigkeit';

  @override
  String get settingsSectionHyqviaTimer => 'Hyqvia Timer';

  @override
  String get settingsSuggestTimer => 'Timer automatisch vorschlagen';

  @override
  String get settingsSuggestTimerHint =>
      'Bei Hyqvia-Infusionen den Premedikation-Timer anbieten';

  @override
  String get settingsPremedDuration => 'Premedikation-Dauer';

  @override
  String settingsCurrentMinutes(int minutes) {
    return 'Aktuell: $minutes Minuten';
  }

  @override
  String get settingsSetDefaultDuration => 'Standard-Dauer festlegen';

  @override
  String get settingsSectionLegal => 'Rechtliches';

  @override
  String get settingsSectionAbout => 'Über CIDP Buddy';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsBuildTimestamp => 'Build-Zeitstempel';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsPrivacyHint =>
      'Alle Daten werden lokal auf diesem Gerät gespeichert.';

  @override
  String get settingsPickBackup => 'Backup auswählen';

  @override
  String get settingsPickZip => 'ZIP wählen';

  @override
  String get restoreNoFolderTitle => 'Kein Backup-Ordner verbunden';

  @override
  String get restoreNoFolderBody =>
      'Wähle den Ordner aus, in dem deine Sicherungen liegen — z. B. den Cloud-Ordner aus einer früheren Installation.';

  @override
  String get restorePickFolder => 'Backup-Ordner wählen';

  @override
  String get restorePickOtherFolder => 'Anderen Ordner wählen';

  @override
  String restoreCurrentFolder(String label) {
    return 'Aktueller Ordner:\n$label';
  }

  @override
  String get restoreAccessLostTitle => 'Zugriff auf Backup-Ordner verloren';

  @override
  String get restoreAccessLostBody =>
      'Wähle den Ordner erneut, um die Berechtigung wiederherzustellen. Deine bestehenden Sicherungen bleiben erhalten.';

  @override
  String get restoreNoBackupsTitle => 'Keine Backups gefunden';

  @override
  String get restoreNoBackupsBody =>
      'Im verbundenen Ordner liegen keine Sicherungen (Dateien mit \"cidpbuddy_backup_…zip\" oder \"igkeeper_backup_…zip\").';

  @override
  String get restoreNoBackupsHint =>
      'Falls deine Backups in einem anderen Ordner liegen, wähle ihn hier aus.';

  @override
  String restoreReadFailed(String error) {
    return 'Backups konnten nicht gelesen werden: $error';
  }

  @override
  String get restoreFolderConnectFailed =>
      'Ordner konnte nicht verbunden werden.';

  @override
  String get restoreConfirmTitle => 'Sicherung einspielen?';

  @override
  String restoreConfirmFile(String name) {
    return 'Möchtest du die Datei \"$name\" wirklich wiederherstellen?';
  }

  @override
  String restoreConfirmDated(String date) {
    return 'Möchtest du das Backup vom $date wirklich wiederherstellen?';
  }

  @override
  String get restoreOverwriteWarning =>
      'ACHTUNG: Alle aktuellen Daten werden unwiderruflich überschrieben!';

  @override
  String get restoreFailed => 'Fehler bei der Wiederherstellung.';

  @override
  String get restoreSucceeded =>
      'Daten erfolgreich wiederhergestellt. App wird neu gestartet…';

  @override
  String get restoreRestartManually => 'Bitte starte die App manuell neu.';

  @override
  String get legalLiabilityTitle => 'Haftungsausschluss';

  @override
  String get legalLiabilitySubtitle =>
      'Kein Medizinprodukt, keine medizinische Beratung';

  @override
  String get legalBatchDocumentationTitle => 'Chargendokumentation';

  @override
  String get legalBatchDocumentationSubtitle =>
      'Ersetzt nicht die gesetzliche Dokumentation';

  @override
  String get legalImprint => 'Impressum';

  @override
  String get legalPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get actionOk => 'OK';

  @override
  String get actionUnderstood => 'Verstanden';

  @override
  String get actionRestore => 'Wiederherstellen';

  @override
  String genericError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get reliabilityTitle => 'Zuverlässigkeits-Check';

  @override
  String get reliabilitySubtitle => 'Prüfe Berechtigungen & Akku-Einstellungen';

  @override
  String get reliabilityNotifications => 'Benachrichtigungen';

  @override
  String get reliabilityNotificationsDesc =>
      'Wichtig für Medikamenten-Erinnerungen und Timer-Abschluss.';

  @override
  String get reliabilityExactAlarms => 'Exakte Alarme';

  @override
  String get reliabilityExactAlarmsDesc =>
      'Erlaubt es der App, Erinnerungen auf die Sekunde genau auszulösen.';

  @override
  String get reliabilityBatteryOptimization => 'Akku-Optimierung';

  @override
  String get reliabilityBatteryOptimizationDesc =>
      'Verhindert, dass Android die App im Hintergrund beendet.';

  @override
  String get reliabilityBackupDesc =>
      'Sichert deine Daten regelmäßig in der Cloud oder lokal.';

  @override
  String get reliabilityBackupStatus => 'Backup-Status';

  @override
  String get reliabilityBackupUpToDate => 'Dein letztes Backup ist aktuell.';

  @override
  String get reliabilityBackupStale =>
      'Dein letztes Backup ist veraltet oder fehlgeschlagen.';

  @override
  String get reliabilityAllGood => 'Alles bestens!';

  @override
  String get reliabilityAllGoodBody =>
      'Deine Einstellungen sind optimal für maximale Zuverlässigkeit.';

  @override
  String get reliabilityActionNeeded => 'Handlungsbedarf';

  @override
  String get reliabilityActionNeededBody =>
      'Einige Einstellungen schränken die Zuverlässigkeit der Erinnerungen ein.';

  @override
  String get reliabilityFix => 'Einstellung korrigieren';

  @override
  String get reliabilityFooterHint =>
      'Hinweis: Die Einstellungen werden automatisch aktualisiert, wenn du von den Systemeinstellungen zurückkehrst.';

  @override
  String get reliabilityRefresh => 'Status jetzt aktualisieren';

  @override
  String get legalBatchDocumentationLong =>
      'CIDP Buddy speichert Chargennummern, Fotos und Notizen ausschließlich als persönliche Gedächtnisstütze auf deinem Gerät.\n\nDiese Aufzeichnungen ersetzen nicht die gesetzlich vorgeschriebene Chargendokumentation nach dem Transfusionsgesetz (TFG) bzw. den für dich geltenden nationalen Regelungen. Diese Pflicht liegt weiterhin bei deiner Ärztin, deinem Arzt oder der behandelnden Einrichtung.\n\nFühre die vorgeschriebene Dokumentation daher unverändert weiter — auch dann, wenn du die Angaben zusätzlich in dieser App erfasst.';

  @override
  String get legalLiabilityBody =>
      'CIDP Buddy ist ein privates Organisationswerkzeug und kein Medizinprodukt. Die App dient ausschließlich dazu, dir das Verwalten deiner Termine, Bestände und Notizen zu erleichtern.\n\nDie App stellt keine medizinische Beratung dar und ersetzt weder die Diagnose noch die Behandlung oder Empfehlung durch medizinisches Fachpersonal. Triff niemals allein aufgrund von Angaben dieser App Entscheidungen über deine Therapie, Dosierung oder Medikation. Bei gesundheitlichen Beschwerden wende dich an deine Ärztin oder deinen Arzt; in Notfällen an den Rettungsdienst.\n\nAlle Berechnungen (z. B. Reichweiten, Bestandswarnungen, geplante Termine) beruhen auf den von dir eingegebenen Daten und können fehlerhaft sein. Erinnerungen und Benachrichtigungen können durch Energiesparfunktionen, Systemeinstellungen oder Fehler des Betriebssystems verspätet, gar nicht oder mehrfach ausgelöst werden. Verlasse dich daher nicht ausschließlich auf die App.\n\nAlle Daten liegen ausschließlich lokal auf deinem Gerät. Für die Sicherung deiner Daten bist du selbst verantwortlich; für Datenverlust wird keine Haftung übernommen.\n\nDie Nutzung erfolgt auf eigene Verantwortung. Eine Haftung für Schäden, die aus der Nutzung oder Nichtverfügbarkeit der App entstehen, ist — soweit gesetzlich zulässig — ausgeschlossen.';

  @override
  String get shareBackupSubject => 'CIDP Buddy Backup';

  @override
  String shareBackupText(String date) {
    return 'Sicherung der CIDP-Buddy-Datenbank vom $date';
  }
}
