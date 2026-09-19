// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get statisticsTitle => 'Statistiche';

  @override
  String get statisticsEmpty => 'Nessun dato disponibile per le statistiche.';

  @override
  String get statisticsMonthlyDose => 'Dose mensile';

  @override
  String get statisticsMonthlyDoseSubtitle =>
      'Unità somministrate negli ultimi 6 mesi';

  @override
  String get statisticsSummary => 'Riepilogo';

  @override
  String get statisticsTotalInfusions => 'Infusioni totali';

  @override
  String get statisticsTotalDose => 'Dose totale';

  @override
  String get statisticsAverageDose => 'Dose media / somministrazione';

  @override
  String get statisticsLastWeight => 'Ultimo peso';

  @override
  String unitsValue(String value) {
    return '$value unità';
  }

  @override
  String kilogramsValue(String value) {
    return '$value kg';
  }

  @override
  String get timerBannerRunning => 'Timer di premedicazione in corso';

  @override
  String get timerBannerPaused => 'Timer di premedicazione in pausa';

  @override
  String timerBannerRemaining(String time) {
    return '$time rimanenti • Tocca per aprire';
  }

  @override
  String get discontinuedTitle => 'Farmaci sospesi';

  @override
  String get discontinuedEmpty => 'Nessun farmaco sospeso.';

  @override
  String discontinuedOn(String date) {
    return 'Sospeso il: $date';
  }

  @override
  String get timerTitle => 'Timer di premedicazione';

  @override
  String timerSubtitle(int minutes) {
    return 'Segnale ogni minuto • timer di $minutes min';
  }

  @override
  String get timerRemainingLabel => 'rimanenti';

  @override
  String get timerSyringeProgress => 'Avanzamento siringa';

  @override
  String get timerVolumePickerTitle => 'Volume di premedicazione (ml)';

  @override
  String get backgroundServiceRunning => 'Servizio attivo in background';

  @override
  String timerNotificationRemaining(String time) {
    return 'Rimanenti: $time';
  }

  @override
  String get medicationFallbackName => 'Farmaco';

  @override
  String get appTitle => 'CIDP Buddy';

  @override
  String startupFailed(String error) {
    return 'Impossibile inizializzare l\'app:\n$error';
  }

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navDiary => 'Diario';

  @override
  String get navMedication => 'Farmaci';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get diaryEntryTitleNew => 'Parametri vitali e sintomi';

  @override
  String get diaryEntryTitleEdit => 'Modifica voce';

  @override
  String get diaryEntrySave => 'Salva voce';

  @override
  String get diaryNotesHint => 'Come ti senti oggi?';

  @override
  String get sectionDateTime => 'Data e ora';

  @override
  String get sectionVitals => 'Parametri vitali (facoltativo)';

  @override
  String get sectionSymptoms => 'Sintomi CIDP (1-10)';

  @override
  String get sectionNotes => 'Note aggiuntive';

  @override
  String get fieldSystolic => 'Sist. (mmHg)';

  @override
  String get fieldDiastolic => 'Diast. (mmHg)';

  @override
  String get fieldHeartRate => 'Polso (bpm)';

  @override
  String get fieldTemperature => 'Temp. (°C)';

  @override
  String get fieldWeight => 'Peso (kg)';

  @override
  String get symptomStrength => 'Forza muscolare';

  @override
  String get symptomSensory => 'Sensibilità';

  @override
  String get symptomFatigue => 'Affaticamento';

  @override
  String get symptomPain => 'Dolore';

  @override
  String get symptomBalance => 'Equilibrio';

  @override
  String get addInfusionTitle => 'Registra infusione';

  @override
  String get addInfusionDetailsHeading => 'Dettagli dell\'infusione';

  @override
  String get addInfusionPickMedication => 'Seleziona farmaco';

  @override
  String get addInfusionWhen => 'Orario dell\'infusione';

  @override
  String get addInfusionSaveAndStartTimer => 'Salva e avvia il timer';

  @override
  String get addInfusionSaveAndDeductStock => 'Salva e scala dalla scorta';

  @override
  String get fieldBatchNumber => 'Numero di lotto / codice a barre';

  @override
  String get fieldBatchNumberHint => 'Scansiona o digita';

  @override
  String get fieldDosageUnits => 'Dosaggio / unità';

  @override
  String get fieldBodyWeight => 'Peso corporeo (kg)';

  @override
  String get fieldInfusionNotes => 'Note (come ti sei sentito, decorso)';

  @override
  String get actionScanBarcode => 'Scansiona codice a barre';

  @override
  String get actionPhotoOfLabel => 'Foto del lotto/etichetta';

  @override
  String get validationPickOne => 'Seleziona un\'opzione';

  @override
  String get legalBatchDocumentationShort =>
      'La documentazione dei lotti in questa app è un appunto personale e non sostituisce la documentazione obbligatoria per legge tenuta da te o dalla struttura che ti ha in cura.';

  @override
  String get scheduleTitleNew => 'Crea piano di infusione';

  @override
  String get scheduleTitleEdit => 'Modifica piano di infusione';

  @override
  String get scheduleSelectDays => 'Seleziona i giorni:';

  @override
  String get scheduleAddTime => 'Aggiungi un altro orario';

  @override
  String get scheduleActivate => 'Attiva il piano';

  @override
  String get sectionMedicationAndDose => 'Farmaco e dose';

  @override
  String get sectionFrequency => 'Frequenza';

  @override
  String get sectionPeriod => 'Periodo';

  @override
  String get sectionIntakeTimes => 'Orari di assunzione';

  @override
  String get fieldUnitsPerInfusion => 'Unità per infusione';

  @override
  String get fieldNumberOfDays => 'Numero di giorni';

  @override
  String get fieldNumberOfDaysHint => 'Es. ogni 5 giorni';

  @override
  String get fieldStartDate => 'Data di inizio';

  @override
  String get frequencyDaily => 'Giornaliero';

  @override
  String get frequencyInterval => 'Ogni X giorni';

  @override
  String get frequencyWeekly => 'Settimanale';

  @override
  String get frequencyBiweekly => 'Ogni 2 settimane';

  @override
  String get frequencyWeekdays => 'Giorni specifici della settimana';

  @override
  String get actionSaveChanges => 'Salva modifiche';

  @override
  String get diaryTitle => 'Il mio diario';

  @override
  String get diaryEmptyTitle => 'Il tuo diario è ancora vuoto';

  @override
  String get diaryEmptyBody =>
      'Registra la tua prima infusione per tenere traccia del trattamento.';

  @override
  String get diaryVitalsAndSymptomsLabel => 'PARAMETRI E SINTOMI:';

  @override
  String get diaryDeleteEntryTitle => 'Eliminare la voce?';

  @override
  String get diaryDeleteEntryBody =>
      'Eliminare questa voce? La scorta verrà riaccreditata automaticamente.';

  @override
  String get diaryOrderReceived => 'Ordine ricevuto';

  @override
  String diaryEventDiscontinued(String name) {
    return 'Sospeso: $name';
  }

  @override
  String diaryEventPrescribed(String name) {
    return 'Nuova prescrizione: $name';
  }

  @override
  String get fieldBatchNumberShort => 'Numero di lotto';

  @override
  String get fieldNotes => 'Note';

  @override
  String batchValue(String batch) {
    return 'Lotto: $batch';
  }

  @override
  String bpmValue(String value) {
    return '$value bpm';
  }

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get planningTitle => 'Appuntamenti e piani';

  @override
  String get planningTabUpcoming => 'In arrivo';

  @override
  String get planningTabSchedules => 'Piani';

  @override
  String get planningOverdue => 'In ritardo';

  @override
  String get planningNoUpcoming => 'Nessun appuntamento in arrivo';

  @override
  String get planningNoSchedules => 'Nessun piano attivo';

  @override
  String planningScheduledFor(String date) {
    return 'Previsto per il $date';
  }

  @override
  String get planningDeletePastTitle => 'Eliminare gli appuntamenti passati?';

  @override
  String get planningDeletePastBody =>
      'Eliminare definitivamente tutti gli appuntamenti passati?\n\nNon verrà creata alcuna voce nel diario.';

  @override
  String get planningSkipTitle => 'Saltare l\'appuntamento?';

  @override
  String get planningSkipBody =>
      'Saltare questo appuntamento? Verrà segnato come completato ma non registrato nel diario.';

  @override
  String get planningSkippedNote => '[Saltato dall\'app]';

  @override
  String get planningDeleteAppointmentTitle => 'Eliminare l\'appuntamento?';

  @override
  String get planningDeleteAppointmentBody =>
      'Rimuovere questo specifico appuntamento dalla tua pianificazione?';

  @override
  String get planningEditAppointmentTitle => 'Modifica appuntamento';

  @override
  String get planningDeleteScheduleTitle => 'Eliminare il piano?';

  @override
  String get planningDeleteScheduleBody =>
      'Verranno eliminati anche tutti gli appuntamenti futuri (non completati) di questo piano.';

  @override
  String get planningOneOffTitle => 'Appuntamento singolo';

  @override
  String get planningOneOffSubtitle => 'Aggiungi un singolo appuntamento';

  @override
  String get planningRecurringTitle => 'Piano ricorrente';

  @override
  String get planningRecurringSubtitle =>
      'Imposta un ritmo di infusione automatico';

  @override
  String get planningNeedMedicationsFirst =>
      'Aggiungi prima dei farmaci al tuo inventario!';

  @override
  String get planningScheduleAppointmentTitle => 'Pianifica appuntamento';

  @override
  String frequencyEveryNDays(int days) {
    return 'Ogni $days giorni';
  }

  @override
  String get frequencyWeekdaysShort => 'Giorni feriali';

  @override
  String get fieldDate => 'Data';

  @override
  String get fieldPlannedDose => 'Dose prevista';

  @override
  String fieldDoseWithUnit(String unit) {
    return 'Dose ($unit)';
  }

  @override
  String doseValue(String amount, String unit) {
    return 'Dose: $amount $unit';
  }

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionDeleteAll => 'Elimina tutto';

  @override
  String get actionSkip => 'Salta';

  @override
  String get actionDone => 'Completato';

  @override
  String get dashboardTitle => 'La tua panoramica';

  @override
  String dashboardSectionLater(int count) {
    return 'PIANIFICATI PIÙ AVANTI ($count)';
  }

  @override
  String dashboardSectionPast(int count) {
    return 'APPUNTAMENTI PASSATI ($count)';
  }

  @override
  String get dashboardNoBackupTitle => 'Nessun backup attivo';

  @override
  String get dashboardNoBackupBody =>
      'Configura il backup automatico per non perdere i tuoi dati.';

  @override
  String get dashboardOrderRecommended => 'Ordine consigliato';

  @override
  String dashboardLowStockNames(String names) {
    return 'Scorte basse: $names';
  }

  @override
  String get dashboardOrdersOnTheWay => 'Gli ordini sono in arrivo.';

  @override
  String get dashboardPendingDeliveries => 'CONSEGNE IN SOSPESO';

  @override
  String dashboardDeliveryDate(String date) {
    return 'Data di consegna: $date';
  }

  @override
  String get dashboardNoDeliveryDate => 'Nessuna data impostata';

  @override
  String get dashboardDeleteOrderTitle => 'Eliminare l\'ordine?';

  @override
  String get dashboardDeleteOrderBody => 'Rimuovere questo ordine in sospeso?';

  @override
  String get dashboardConfirmDeliveryTitle => 'Consegna ricevuta?';

  @override
  String get dashboardConfirmDeliveryBody =>
      'Confermare la ricezione di questa consegna? La scorta verrà aggiornata automaticamente.';

  @override
  String get dashboardConfirmDeliveryYes => 'Sì, ricevuta';

  @override
  String get dashboardStockUpdated => 'Scorte aggiornate!';

  @override
  String get dashboardReceived => 'Ricevuto';

  @override
  String dashboardMissedAt(String time) {
    return 'Mancata (prevista alle $time)';
  }

  @override
  String dashboardTodayAt(String time) {
    return 'Oggi alle $time';
  }

  @override
  String get dashboardMissedInfusion => 'Infusione mancata (prevista per oggi)';

  @override
  String dashboardPlannedToday(String amount, String unit) {
    return 'Previsto oggi ($amount $unit)';
  }

  @override
  String dashboardMarkedDone(String name) {
    return '$name completato!';
  }

  @override
  String get dashboardLogInfusionNow => 'Registra l\'infusione ora';

  @override
  String get dashboardAllDoneTitle => 'Tutto fatto!';

  @override
  String get dashboardAllDoneBody => 'Nessuna attività in sospeso.';

  @override
  String dashboardTreatmentSubtitle(
    String date,
    String time,
    String amount,
    String unit,
  ) {
    return '$date alle $time • $amount $unit';
  }

  @override
  String get dashboardOrphanRemoved => 'Appuntamento orfano rimosso';

  @override
  String get dashboardUnknownMedication => 'Farmaco sconosciuto';

  @override
  String dashboardOrphanSubtitle(String date) {
    return 'Previsto $date • farmaco non trovato';
  }

  @override
  String quantityValue(String amount, String unit) {
    return 'Quantità: $amount $unit';
  }

  @override
  String get today => 'Oggi';

  @override
  String get actionNo => 'No';

  @override
  String get actionRemove => 'Rimuovi';

  @override
  String get inventorySectionMedications => 'FARMACI';

  @override
  String get inventorySectionStandaloneSupplies => 'MATERIALE INDIPENDENTE';

  @override
  String get inventoryNoMedications => 'Nessun farmaco aggiunto';

  @override
  String inventoryNextTreatment(String date) {
    return 'Prossima: $date';
  }

  @override
  String inventoryLastsUntil(String date) {
    return 'Sufficiente fino al: $date';
  }

  @override
  String get inventoryLowStock => 'Scorte basse!';

  @override
  String get inventoryOrderOnTheWay => 'Ordine in arrivo';

  @override
  String inventoryPzn(String pzn) {
    return 'PZN: $pzn';
  }

  @override
  String stockValue(String amount, String unit) {
    return 'Scorta: $amount $unit';
  }

  @override
  String get accessoryEditTitle => 'Modifica materiale di consumo';

  @override
  String get accessoryDeleteTitle => 'Eliminare il materiale di consumo?';

  @override
  String confirmDeleteNamed(String name) {
    return 'Vuoi davvero eliminare \"$name\"?';
  }

  @override
  String get fieldName => 'Nome';

  @override
  String get fieldUnit => 'Unità';

  @override
  String get fieldCurrentStock => 'Scorta attuale';

  @override
  String get fieldPackageSize => 'Dimensione della confezione (per l\'ordine)';

  @override
  String get fieldMinStock => 'Soglia di avviso (scorta)';

  @override
  String get addItemTitle => 'Aggiungi nuovo elemento';

  @override
  String get fieldCategory => 'Categoria';

  @override
  String get categoryMedication => 'Farmaco';

  @override
  String get categorySupply => 'Materiale di consumo';

  @override
  String get fieldDosageForm => 'Forma farmaceutica';

  @override
  String get dosageFormInfusion => 'Infusione';

  @override
  String get dosageFormPill => 'Compressa / pillola';

  @override
  String get fieldMedicationName => 'Nome del farmaco';

  @override
  String get fieldMedicationNameHint => 'es. Hizentra';

  @override
  String get fieldStrength => 'Dose / concentrazione';

  @override
  String get fieldStrengthHint => 'es. 20% o 10 ml';

  @override
  String get fieldPznOptional => 'PZN (facoltativo)';

  @override
  String get fieldPznHint => 'Numero centrale farmaceutico';

  @override
  String get fieldInitialStock => 'Scorta iniziale';

  @override
  String get fieldDefaultReorderAmount => 'Quantità di riordino predefinita';

  @override
  String get fieldDefaultReorderAmountHint => 'es. 10 flaconi';

  @override
  String get fieldMinStockDays => 'Soglia di avviso (in giorni)';

  @override
  String get fieldMinStockDaysHint =>
      'Avvisa quando la scorta dura meno di x giorni';

  @override
  String get fieldMinStockHint =>
      'Avvisa quando la scorta scende sotto questo valore';

  @override
  String get unitBottle => 'Flacone';

  @override
  String get unitPieces => 'pz';

  @override
  String get validationRequired => 'Campo obbligatorio';

  @override
  String get shoppingWizardTitle => 'Assistente agli acquisti';

  @override
  String get shoppingWizardEditTitle => 'Modifica ordine';

  @override
  String get shoppingWizardIntro =>
      'Calcola il fabbisogno di materiale di consumo in base all\'ordine di farmaci che stai pianificando.';

  @override
  String get shoppingWizardEditIntro =>
      'Modifica il tuo ordine e il materiale di consumo corrispondente.';

  @override
  String get shoppingWizardSuppliesOnly =>
      'Ordina solo materiale di consumo (nessun farmaco)';

  @override
  String shoppingWizardOrderQuantity(String unit) {
    return 'Quantità da ordinare ($unit)';
  }

  @override
  String get shoppingWizardDeliveryDate => 'Data di consegna (facoltativa)';

  @override
  String get shoppingWizardImmediately => 'Subito dopo la conferma';

  @override
  String get shoppingWizardSuggestion => 'Materiale di consumo suggerito:';

  @override
  String get shoppingWizardRequired => 'Necessario per questo ordine:';

  @override
  String get shoppingWizardOptional =>
      'Altro materiale di consumo (facoltativo):';

  @override
  String get shoppingWizardNoSuggestions =>
      'Nessun materiale di consumo suggerito automaticamente.';

  @override
  String get shoppingWizardAddOther => 'Aggiungi altro materiale di consumo';

  @override
  String get shoppingWizardSaveOrder => 'Salva ordine';

  @override
  String get shoppingWizardPickSupply => 'Seleziona materiale di consumo';

  @override
  String get shoppingWizardAlreadyInList => 'Già presente nell\'elenco!';

  @override
  String get shoppingWizardRecommendedAmount => 'Quantità consigliata';

  @override
  String get shoppingWizardAdditionallySelected => 'Aggiunto da te';

  @override
  String get medDetailsDiscontinue => 'Sospendi';

  @override
  String get medDetailsDiscontinueMedication => 'Sospendi il farmaco';

  @override
  String get medDetailsReenroll => 'Prescrivi di nuovo';

  @override
  String get medDetailsDeleteCompletely => 'Elimina completamente';

  @override
  String get medDetailsDeleteFromDatabase =>
      'Elimina completamente dal database';

  @override
  String medDetailsDiscontinuedSince(String date) {
    return 'Questo farmaco è sospeso dal $date';
  }

  @override
  String get medDetailsSectionStock => 'Scorte e avvisi';

  @override
  String get medDetailsSectionSupplies => 'Materiale di consumo collegato';

  @override
  String get medDetailsSuppliesHint =>
      'Questo materiale viene scalato automaticamente dalla scorta a ogni somministrazione.';

  @override
  String get medDetailsNoSuppliesLinked =>
      'Nessun materiale di consumo collegato';

  @override
  String get medDetailsLink => 'Collega';

  @override
  String get medDetailsCreateAndLink => 'Nuovo e collega';

  @override
  String get medDetailsSectionWorkflow => 'Flusso di registrazione';

  @override
  String get medDetailsWorkflowHint =>
      'Scegli quali campi vengono mostrati quando registri una somministrazione.';

  @override
  String get medDetailsSchedulesHint =>
      'Imposta il ritmo con cui assumi questo farmaco.';

  @override
  String get medDetailsCreateSchedule => 'Crea piano';

  @override
  String get medDetailsPlanOneOff => 'Pianifica un appuntamento singolo';

  @override
  String get medDetailsSectionSystemActions => 'Azioni di sistema';

  @override
  String medDetailsRequirement(String amount, String unit) {
    return 'Fabbisogno: $amount $unit';
  }

  @override
  String get medDetailsMustBeOrdered => 'Deve essere sempre ordinato';

  @override
  String get medDetailsNeedSuppliesFirst =>
      'Crea prima del materiale di consumo!';

  @override
  String get medDetailsLinkSupplyTitle => 'Collega materiale di consumo';

  @override
  String get medDetailsPickSupply => 'Scegli il materiale di consumo';

  @override
  String get medDetailsCreateSupplyTitle => 'Crea nuovo materiale di consumo';

  @override
  String get medDetailsAlwaysOrder => 'Ordina sempre insieme';

  @override
  String get medDetailsAlwaysOrderHint =>
      'Evidenziato nell\'assistente agli acquisti';

  @override
  String get medDetailsEditMedication => 'Modifica farmaco';

  @override
  String get medDetailsDeleteTitle => 'Eliminare il farmaco?';

  @override
  String medDetailsDeleteBody(String name) {
    return 'Eliminare definitivamente \"$name\" dall\'app? L\'operazione è irreversibile e dovrebbe servire solo a correggere errori. Per concludere una terapia usa invece \"Sospendi\".';
  }

  @override
  String get medDetailsDiscontinueTitle => 'Sospendere il farmaco?';

  @override
  String medDetailsDiscontinueBody(String name) {
    return 'Sospendere \"$name\"? Uscirà dall\'elenco attivo ma resterà nello storico. Gli appuntamenti futuri verranno eliminati.';
  }

  @override
  String medDetailsTimes(String times) {
    return 'Orari: $times';
  }

  @override
  String get medDetailsTrackBatch => 'Registra il numero di lotto';

  @override
  String get medDetailsTrackBatchHint =>
      'Scansiona un codice a barre o digitalo';

  @override
  String get medDetailsTrackWeight => 'Registra il peso corporeo';

  @override
  String get medDetailsTrackWeightHint =>
      'Registra il peso a ogni somministrazione';

  @override
  String get medDetailsUseTimer => 'Usa il timer di somministrazione';

  @override
  String get medDetailsUseTimerHint =>
      'Timer di premedicazione prima della somministrazione';

  @override
  String medDetailsConfigureNamed(String name) {
    return 'Configura $name';
  }

  @override
  String get medDetailsEditSupplyGlobally =>
      'Modifica il materiale a livello globale (nome, unità)';

  @override
  String get medDetailsStockUpdated => 'Livello di scorta aggiornato';

  @override
  String get medDetailsSaveStock => 'Salva la scorta';

  @override
  String get fieldPerInfusionRequirement => 'Fabbisogno per infusione';

  @override
  String fieldPerInfusionRequirementWithUnit(String unit) {
    return 'Fabbisogno per infusione ($unit)';
  }

  @override
  String get fieldSupplyName => 'Nome del materiale di consumo';

  @override
  String get fieldUnitWithExample => 'Unità (es. pz, set)';

  @override
  String get fieldUnitWithBottleExample => 'Unità (es. flacone)';

  @override
  String get fieldStrengthWithExample => 'Dose / concentrazione (es. 10 g)';

  @override
  String get fieldPzn => 'PZN';

  @override
  String get fieldCurrentStockShort => 'Scorta attuale';

  @override
  String fieldPlannedDoseWithUnit(String unit) {
    return 'Dose prevista ($unit)';
  }

  @override
  String get actionCreate => 'Crea';

  @override
  String get channelBackgroundService => 'Servizio in background';

  @override
  String get channelBackgroundServiceDesc =>
      'Usato per il timer e le attività in background';

  @override
  String get channelStockWarnings => 'Avvisi sulle scorte';

  @override
  String get channelStockWarningsDesc =>
      'Ti avvisa quando farmaci o materiali stanno per finire';

  @override
  String get channelMissedIntakes => 'Assunzioni mancate';

  @override
  String get channelMissedIntakesDesc =>
      'Avvisi su assunzioni non confermate o mancate';

  @override
  String get channelBackupFailures => 'Errori di backup';

  @override
  String get channelBackupFailuresDesc =>
      'Notifiche sui problemi con il backup automatico';

  @override
  String get channelBackupWarnings => 'Avvisi di backup';

  @override
  String get channelBackupWarningsDesc =>
      'Avvisi sulla configurazione del backup';

  @override
  String get channelMedReminders => 'Promemoria farmaci';

  @override
  String get channelMedRemindersDesc =>
      'Promemoria per assunzioni e infusioni pianificate';

  @override
  String get channelPremedTimerDesc => 'Timer in corso per la premedicazione';

  @override
  String get reminderDueTitle => 'Promemoria: farmaco da assumere';

  @override
  String reminderDueBody(String medication) {
    return 'È ora di assumere $medication.';
  }

  @override
  String get reminderGenericMedication => 'il tuo farmaco';

  @override
  String get reminderSnoozeTitle => 'Promemoria (ripetizione)';

  @override
  String get reminderSnoozeBody =>
      'Non hai ancora segnato l\'assunzione come completata.';

  @override
  String get reminderHourlyTitle => 'Promemoria (ogni ora)';

  @override
  String get reminderHourlyBody => 'Non dimenticare la tua assunzione.';

  @override
  String get notificationCompletedNote => 'Completato tramite notifica';

  @override
  String get notificationSkippedNote => '[Saltato tramite notifica]';

  @override
  String get timerFinishedTitle => 'Premedicazione completata';

  @override
  String get timerFinishedBody =>
      'Il timer è scaduto — l\'infusione può iniziare.';

  @override
  String missedIntakesSummary(int count) {
    return '$count assunzioni non confermate';
  }

  @override
  String missedIntakesOpenCount(int count) {
    return '$count in sospeso';
  }

  @override
  String get backupReminderTitle => 'Configura il backup';

  @override
  String get backupReminderBody =>
      'I tuoi dati non vengono ancora salvati automaticamente. Tocca qui per configurare il backup.';

  @override
  String get backupFailedTitle => 'Backup non riuscito';

  @override
  String backupFailedBody(String error) {
    return 'Non è stato possibile creare il backup automatico: $error';
  }

  @override
  String get backupDestinationAppFolder =>
      'Cartella dell\'app (File → CIDP Buddy → Backups)';

  @override
  String get backupDestinationSafFolder => 'Cartella cloud / SAF';

  @override
  String get backupDestinationPickedFolder => 'Cartella scelta';

  @override
  String backupFolderUnreadable(String path, String error) {
    return 'Cartella non leggibile: $path\n($error)';
  }

  @override
  String backupFolderMissing(String path) {
    return 'La cartella non esiste più: $path';
  }

  @override
  String backupFolderNotWritable(String path, String error) {
    return 'Accesso in scrittura negato: $path\n($error)';
  }

  @override
  String get backupFolderMissingShort => 'La cartella non esiste.';

  @override
  String get backupFolderEmpty => 'La cartella è vuota.';

  @override
  String get backupSafFolderEmpty => 'La cartella SAF è vuota.';

  @override
  String backupFolderContents(int count, String names) {
    return 'Trovati ($count): $names';
  }

  @override
  String backupFolderListFailed(String error) {
    return 'Impossibile elencare la cartella: $error';
  }

  @override
  String backupSafListFailed(String error) {
    return 'Impossibile elencare la cartella SAF: $error';
  }

  @override
  String get backupSafPermissionLost =>
      'L\'autorizzazione per la cartella cloud è stata persa. Seleziona di nuovo la cartella.';

  @override
  String get backupNoDestination =>
      'Nessuna destinazione di backup selezionata.';

  @override
  String get backupAutoDisabled => 'Il backup automatico è disattivato.';

  @override
  String get backupSkippedRecent => 'Saltato: esiste già un backup recente.';

  @override
  String backupWriteError(String error) {
    return 'Errore di scrittura: $error';
  }

  @override
  String get settingsSectionAppearance => 'Aspetto';

  @override
  String get settingsDarkMode => 'Tema scuro';

  @override
  String get settingsDarkModeHint => 'Passa tra modalità chiara e scura';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSystem => 'Lingua di sistema';

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
  String get settingsSectionAutoBackup => 'Backup automatico';

  @override
  String get settingsEnableAutoBackup => 'Attiva il backup automatico';

  @override
  String get settingsEnableAutoBackupHint =>
      'Salva regolarmente i tuoi dati nella cartella scelta';

  @override
  String get settingsBackupNotPossible => 'Backup non possibile';

  @override
  String get settingsUnknownError => 'Errore sconosciuto';

  @override
  String get settingsPickFolderAgain => 'Seleziona di nuovo la cartella';

  @override
  String get backupBookmarkAccessLost =>
      'CIDP Buddy non riesce più ad accedere alla cartella di backup che hai scelto. Selezionala di nuovo.';

  @override
  String get settingsBackupsInsideAppTitle =>
      'I backup sono all\'interno dell\'app';

  @override
  String get settingsBackupsInsideAppBody =>
      'Vengono eliminati insieme all\'app. Scegli una cartella nell\'app File in modo che i backup restino fuori da essa — oppure esporta regolarmente una copia.';

  @override
  String get settingsBackupDestination => 'Destinazione del backup';

  @override
  String get settingsPickDestination => 'Scegli una destinazione…';

  @override
  String get settingsRunBackupNow => 'Esegui il backup ora';

  @override
  String get settingsBackupSucceeded => 'Backup riuscito!';

  @override
  String settingsBackupFailed(String error) {
    return 'Backup non riuscito: $error';
  }

  @override
  String get settingsExportBackup => 'Esporta backup';

  @override
  String get settingsExportBackupHint =>
      'Salva l\'ultimo backup ad esempio in File o iCloud Drive';

  @override
  String get settingsNoBackupToExport =>
      'Nessun backup da esportare. Esegui prima un backup.';

  @override
  String get settingsLastSuccess => 'Ultimo riuscito';

  @override
  String get settingsLastAttempt => 'Ultimo tentativo';

  @override
  String get settingsRestoreBackup => 'Ripristina un backup';

  @override
  String get settingsRestoreBackupHint =>
      'Scegli un backup automatico da ripristinare';

  @override
  String get settingsIosStorageInfo =>
      'I backup possono essere scritti direttamente in una cartella che scegli nell\'app File: iCloud Drive, Nextcloud, Dropbox o un\'unità collegata. CIDP Buddy continua a scrivere lì da solo, e questi backup restano anche dopo aver eliminato l\'app.\n\nSenza una cartella scelta, i backup restano all\'interno dell\'app e vengono eliminati insieme ad essa — dovrai quindi esportare una copia personalmente.';

  @override
  String get settingsIosPickFolder => 'Scegli una cartella';

  @override
  String get settingsIosUseAppFolder => 'Usa la cartella dell\'app';

  @override
  String get settingsDestinationConnectFailed =>
      'Impossibile connettere la destinazione. Scegline un\'altra.';

  @override
  String get settingsDestinationConnected => 'Destinazione di backup connessa.';

  @override
  String get settingsSectionReminders => 'Promemoria';

  @override
  String get settingsSnooze => 'Posticipa';

  @override
  String settingsSnoozeHint(int minutes) {
    return 'Ricorda di nuovo ogni $minutes minuti (3×)';
  }

  @override
  String get settingsSnoozeInterval => 'Intervallo di posticipo';

  @override
  String settingsSnoozeIntervalCurrent(int minutes) {
    return 'Attualmente: ogni $minutes minuti';
  }

  @override
  String settingsEveryNMinutes(int minutes) {
    return 'Ogni $minutes minuti';
  }

  @override
  String get settingsHourlyReminder => 'Promemoria ogni ora';

  @override
  String get settingsHourlyReminderHint => 'Ricorda allo scoccare dell\'ora';

  @override
  String get settingsQuietHours => 'Ore di silenzio';

  @override
  String get settingsQuietHoursTitle => 'Imposta le ore di silenzio';

  @override
  String settingsQuietHoursHint(String start, String end) {
    return 'Nessun promemoria dalle $start alle $end';
  }

  @override
  String get settingsQuietHoursStart => 'Inizio';

  @override
  String get settingsQuietHoursEnd => 'Fine';

  @override
  String get settingsSectionSystem => 'Sistema e affidabilità';

  @override
  String get settingsSectionHyqviaTimer => 'Timer Hyqvia';

  @override
  String get settingsSuggestTimer => 'Suggerisci il timer automaticamente';

  @override
  String get settingsSuggestTimerHint =>
      'Proponi il timer di premedicazione per le infusioni Hyqvia';

  @override
  String get settingsPremedDuration => 'Durata della premedicazione';

  @override
  String settingsCurrentMinutes(int minutes) {
    return 'Attualmente: $minutes minuti';
  }

  @override
  String get settingsSetDefaultDuration => 'Imposta la durata predefinita';

  @override
  String get settingsSectionLegal => 'Note legali';

  @override
  String get settingsSectionAbout => 'Informazioni su CIDP Buddy';

  @override
  String get settingsVersion => 'Versione';

  @override
  String get settingsBuildTimestamp => 'Data e ora della build';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyHint =>
      'Tutti i dati sono archiviati localmente su questo dispositivo.';

  @override
  String get settingsPickBackup => 'Seleziona un backup';

  @override
  String get settingsPickZip => 'Scegli ZIP';

  @override
  String get restoreNoFolderTitle => 'Nessuna cartella di backup collegata';

  @override
  String get restoreNoFolderBody =>
      'Scegli la cartella in cui si trovano i tuoi backup — ad esempio la cartella cloud di un\'installazione precedente.';

  @override
  String get restorePickFolder => 'Scegli la cartella di backup';

  @override
  String get restorePickOtherFolder => 'Scegli un\'altra cartella';

  @override
  String restoreCurrentFolder(String label) {
    return 'Cartella attuale:\n$label';
  }

  @override
  String get restoreAccessLostTitle => 'Accesso alla cartella di backup perso';

  @override
  String get restoreAccessLostBody =>
      'Seleziona di nuovo la cartella per ripristinare l\'autorizzazione. I backup esistenti restano intatti.';

  @override
  String get restoreNoBackupsTitle => 'Nessun backup trovato';

  @override
  String get restoreNoBackupsBody =>
      'La cartella collegata non contiene backup (file con nome \"cidpbuddy_backup_…zip\" o \"igkeeper_backup_…zip\").';

  @override
  String get restoreNoBackupsHint =>
      'Se i tuoi backup si trovano in un\'altra cartella, selezionala qui.';

  @override
  String restoreReadFailed(String error) {
    return 'Impossibile leggere i backup: $error';
  }

  @override
  String get restoreFolderConnectFailed =>
      'Impossibile connettere la cartella.';

  @override
  String get restoreConfirmTitle => 'Ripristinare il backup?';

  @override
  String restoreConfirmFile(String name) {
    return 'Vuoi davvero ripristinare il file \"$name\"?';
  }

  @override
  String restoreConfirmDated(String date) {
    return 'Vuoi davvero ripristinare il backup del $date?';
  }

  @override
  String get restoreOverwriteWarning =>
      'ATTENZIONE: tutti i dati attuali verranno sovrascritti in modo irreversibile!';

  @override
  String get restoreFailed => 'Ripristino non riuscito.';

  @override
  String get restoreSucceeded => 'Dati ripristinati. Riavvio dell\'app…';

  @override
  String get restoreRestartManually => 'Riavvia l\'app manualmente.';

  @override
  String get legalLiabilityTitle => 'Esclusione di responsabilità';

  @override
  String get legalLiabilitySubtitle =>
      'Non è un dispositivo medico, non è un consiglio medico';

  @override
  String get legalBatchDocumentationTitle => 'Documentazione dei lotti';

  @override
  String get legalBatchDocumentationSubtitle =>
      'Non sostituisce la documentazione obbligatoria per legge';

  @override
  String get legalImprint => 'Note legali';

  @override
  String get legalPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get actionOk => 'OK';

  @override
  String get actionUnderstood => 'Ho capito';

  @override
  String get actionRestore => 'Ripristina';

  @override
  String genericError(String error) {
    return 'Errore: $error';
  }

  @override
  String get reliabilityTitle => 'Verifica di affidabilità';

  @override
  String get reliabilitySubtitle =>
      'Controlla autorizzazioni e impostazioni della batteria';

  @override
  String get reliabilityNotifications => 'Notifiche';

  @override
  String get reliabilityNotificationsDesc =>
      'Necessarie per i promemoria dei farmaci e la fine del timer.';

  @override
  String get reliabilityExactAlarms => 'Sveglie esatte';

  @override
  String get reliabilityExactAlarmsDesc =>
      'Consente all\'app di attivare i promemoria al secondo.';

  @override
  String get reliabilityBatteryOptimization => 'Ottimizzazione della batteria';

  @override
  String get reliabilityBatteryOptimizationDesc =>
      'Impedisce ad Android di chiudere l\'app in background.';

  @override
  String get reliabilityBackupDesc =>
      'Salva regolarmente i tuoi dati, nel cloud o localmente.';

  @override
  String get reliabilityBackupStatus => 'Stato del backup';

  @override
  String get reliabilityBackupUpToDate => 'L\'ultimo backup è aggiornato.';

  @override
  String get reliabilityBackupStale =>
      'L\'ultimo backup è obsoleto o non è riuscito.';

  @override
  String get reliabilityAllGood => 'Tutto a posto!';

  @override
  String get reliabilityAllGoodBody =>
      'Le tue impostazioni sono ottimali per la massima affidabilità.';

  @override
  String get reliabilityActionNeeded => 'Serve un intervento';

  @override
  String get reliabilityActionNeededBody =>
      'Alcune impostazioni limitano l\'affidabilità dei promemoria.';

  @override
  String get reliabilityFix => 'Correggi l\'impostazione';

  @override
  String get reliabilityFooterHint =>
      'Nota: i controlli si aggiornano automaticamente al ritorno dalle impostazioni di sistema.';

  @override
  String get reliabilityRefresh => 'Aggiorna lo stato ora';

  @override
  String get legalBatchDocumentationLong =>
      'CIDP Buddy conserva numeri di lotto, foto e note esclusivamente come promemoria personale sul tuo dispositivo.\n\nQueste registrazioni non sostituiscono la documentazione dei lotti prevista per legge dalla legge tedesca sulle trasfusioni (TFG) o dalle norme nazionali applicabili a te. Tale obbligo resta in capo al tuo medico o alla struttura che ti ha in cura.\n\nContinua quindi a tenere la documentazione obbligatoria come prima, anche se registri gli stessi dati in questa app.';

  @override
  String get legalLiabilityBody =>
      'CIDP Buddy è uno strumento organizzativo privato e non un dispositivo medico. L\'app serve esclusivamente a semplificarti la gestione di appuntamenti, scorte e note.\n\nL\'app non costituisce un consiglio medico e non sostituisce la diagnosi, il trattamento o le raccomandazioni del personale sanitario. Non prendere mai decisioni sulla tua terapia, sul dosaggio o sui farmaci basandoti solo su questa app. In caso di disturbi, rivolgiti al tuo medico; in caso di emergenza, chiama i soccorsi.\n\nTutti i calcoli (autonomia delle scorte, avvisi di scorta bassa, appuntamenti pianificati e simili) si basano sui dati che hai inserito e possono essere errati. Promemoria e notifiche possono arrivare in ritardo, duplicati o non arrivare affatto a causa del risparmio energetico, delle impostazioni di sistema o di errori del sistema operativo. Non affidarti quindi esclusivamente all\'app.\n\nTutti i dati restano soltanto sul tuo dispositivo. Il loro backup è una tua responsabilità; non viene assunta alcuna responsabilità per la perdita di dati.\n\nL\'uso avviene a tuo rischio. La responsabilità per danni derivanti dall\'uso o dall\'indisponibilità dell\'app è esclusa nei limiti consentiti dalla legge.';

  @override
  String get shareBackupSubject => 'Backup di CIDP Buddy';

  @override
  String shareBackupText(String date) {
    return 'Backup del database di CIDP Buddy del $date';
  }

  @override
  String get tooltipOpenStatistics => 'Statistiche';

  @override
  String get tooltipEditOrder => 'Modifica ordine';

  @override
  String get tooltipDeleteOrder => 'Elimina ordine';

  @override
  String get tooltipEditInfusionLog => 'Modifica voce infusione';

  @override
  String get tooltipDeleteInfusionLog => 'Elimina voce infusione';

  @override
  String get tooltipEditSupply => 'Modifica materiale di consumo';

  @override
  String get tooltipDeleteSupply => 'Elimina materiale di consumo';

  @override
  String get tooltipShowDetails => 'Mostra dettagli';

  @override
  String get tooltipEditMedication => 'Modifica farmaco';

  @override
  String get tooltipLinkSettings => 'Impostazioni del collegamento';

  @override
  String get tooltipUnlinkSupply =>
      'Rimuovi il materiale di consumo da questo farmaco';

  @override
  String get tooltipEditSchedule => 'Modifica piano';

  @override
  String get tooltipDeleteSchedule => 'Elimina piano';

  @override
  String get tooltipClearDate => 'Cancella la data';

  @override
  String get tooltipRemoveIntakeTime => 'Rimuovi l\'orario';

  @override
  String get tooltipRemovePhoto => 'Rimuovi la foto';

  @override
  String get tooltipTimerReset => 'Reimposta il timer';

  @override
  String get tooltipTimerStart => 'Avvia il timer';

  @override
  String get tooltipTimerPause => 'Metti in pausa il timer';

  @override
  String get tooltipTimerDuration => 'Imposta la durata';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionBack => 'Indietro';

  @override
  String get actionDiscard => 'Scarta';

  @override
  String get actionKeepEditing => 'Continua a modificare';

  @override
  String get actionUndo => 'Annulla';

  @override
  String dashboardLogInfusionFor(String name) {
    return 'Registra ora l\'infusione di $name';
  }

  @override
  String dashboardMarkDoneFor(String name) {
    return 'Segna $name come assunto';
  }

  @override
  String dashboardRemoveFor(String name) {
    return 'Rimuovi $name dal piano';
  }

  @override
  String symptomScoreLabel(String symptom, int score) {
    return '$symptom: $score su 10';
  }

  @override
  String get backupDestinationConfigured =>
      'Destinazione di backup configurata';

  @override
  String get reliabilityStatusOk => 'OK';

  @override
  String get reliabilityStatusFailed => 'Azione richiesta';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String millilitersShort(String value) {
    return '$value ml';
  }

  @override
  String millilitersProgress(String remaining, String total) {
    return '$remaining / $total ml';
  }

  @override
  String get kilogramsShort => 'kg';

  @override
  String megabytes(String value) {
    return '$value MB';
  }

  @override
  String deliveredItem(String quantity, String unit, String name) {
    return '$quantity $unit $name';
  }

  @override
  String get savedInfusion => 'Infusione registrata';

  @override
  String get savedDiaryEntry => 'Voce salvata';

  @override
  String get savedSchedule => 'Piano salvato';

  @override
  String get savedOrder => 'Ordine salvato';

  @override
  String get savedMedication => 'Farmaco salvato';

  @override
  String get deletedGeneric => 'Eliminato';

  @override
  String saveFailed(String error) {
    return 'Salvataggio non riuscito: $error';
  }

  @override
  String get discardChangesTitle => 'Scartare le modifiche?';

  @override
  String get discardChangesBody =>
      'Le tue modifiche non sono ancora state salvate.';

  @override
  String get errorLoadingData => 'Non è stato possibile caricare i dati.';

  @override
  String get medDetailsNotFound => 'Questo farmaco non esiste più.';

  @override
  String get confirmUnlinkSupplyTitle => 'Rimuovere il materiale di consumo?';

  @override
  String confirmUnlinkSupplyBody(String name) {
    return '$name non verrà più ordinato insieme a questo farmaco.';
  }

  @override
  String get confirmReenrollTitle => 'Prescrivere di nuovo il farmaco?';

  @override
  String confirmReenrollBody(String name) {
    return '$name torna nell\'elenco attivo; i suoi piani e promemoria vengono ricreati.';
  }

  @override
  String get validationEnterNumber => 'Inserisci un numero.';

  @override
  String get validationPositiveNumber => 'Inserisci un numero maggiore di 0.';

  @override
  String get inventoryAddFirstMedicationHint =>
      'Aggiungi il tuo primo farmaco con il pulsante qui sotto.';

  @override
  String get savedSupply => 'Materiale di consumo salvato';

  @override
  String reenrolledMedication(String name) {
    return '$name è di nuovo attivo';
  }

  @override
  String get restoringPleaseWait =>
      'Ripristino del backup in corso, attendere…';

  @override
  String get loading => 'Caricamento…';
}
