// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get statisticsTitle => 'Statistiques';

  @override
  String get statisticsEmpty =>
      'Aucune donnée disponible pour les statistiques.';

  @override
  String get statisticsMonthlyDose => 'Dose mensuelle';

  @override
  String get statisticsMonthlyDoseSubtitle =>
      'Unités administrées au cours des 6 derniers mois';

  @override
  String get statisticsSummary => 'Résumé';

  @override
  String get statisticsTotalInfusions => 'Total des perfusions';

  @override
  String get statisticsTotalDose => 'Dose totale';

  @override
  String get statisticsAverageDose => 'Dose moy. / administration';

  @override
  String get statisticsLastWeight => 'Dernier poids';

  @override
  String unitsValue(String value) {
    return '$value unités';
  }

  @override
  String kilogramsValue(String value) {
    return '$value kg';
  }

  @override
  String get timerBannerRunning => 'Minuteur de prémédication en cours';

  @override
  String get timerBannerPaused => 'Minuteur de prémédication en pause';

  @override
  String timerBannerRemaining(String time) {
    return '$time restant • Appuyez pour ouvrir';
  }

  @override
  String get discontinuedTitle => 'Médicaments arrêtés';

  @override
  String get discontinuedEmpty => 'Aucun médicament arrêté.';

  @override
  String discontinuedOn(String date) {
    return 'Arrêté le : $date';
  }

  @override
  String get timerTitle => 'Minuteur de prémédication';

  @override
  String timerSubtitle(int minutes) {
    return 'Bip chaque minute • minuteur de $minutes min';
  }

  @override
  String get timerRemainingLabel => 'restant';

  @override
  String get timerSyringeProgress => 'Progression de la seringue';

  @override
  String get timerVolumePickerTitle => 'Volume de prémédication (ml)';

  @override
  String get backgroundServiceRunning => 'Service actif en arrière-plan';

  @override
  String timerNotificationRemaining(String time) {
    return 'Restant : $time';
  }

  @override
  String get medicationFallbackName => 'Médicament';

  @override
  String get appTitle => 'CIDP Buddy';

  @override
  String startupFailed(String error) {
    return 'Impossible d\'initialiser l\'application :\n$error';
  }

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navDiary => 'Journal';

  @override
  String get navMedication => 'Médication';

  @override
  String get navSettings => 'Réglages';

  @override
  String get diaryEntryTitleNew => 'Constantes et symptômes';

  @override
  String get diaryEntryTitleEdit => 'Modifier l\'entrée';

  @override
  String get diaryEntrySave => 'Enregistrer l\'entrée';

  @override
  String get diaryNotesHint => 'Comment vous sentez-vous aujourd\'hui ?';

  @override
  String get sectionDateTime => 'Date et heure';

  @override
  String get sectionVitals => 'Constantes (facultatif)';

  @override
  String get sectionSymptoms => 'Symptômes CIDP (1-10)';

  @override
  String get sectionNotes => 'Notes complémentaires';

  @override
  String get fieldSystolic => 'Syst. (mmHg)';

  @override
  String get fieldDiastolic => 'Diast. (mmHg)';

  @override
  String get fieldHeartRate => 'Pouls (bpm)';

  @override
  String get fieldTemperature => 'Temp. (°C)';

  @override
  String get fieldWeight => 'Poids (kg)';

  @override
  String get symptomStrength => 'Force musculaire';

  @override
  String get symptomSensory => 'Sensibilité';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomPain => 'Douleur';

  @override
  String get symptomBalance => 'Équilibre';

  @override
  String get addInfusionTitle => 'Enregistrer une perfusion';

  @override
  String get addInfusionDetailsHeading => 'Détails de la perfusion';

  @override
  String get addInfusionPickMedication => 'Choisir un médicament';

  @override
  String get addInfusionWhen => 'Heure de la perfusion';

  @override
  String get addInfusionSaveAndStartTimer =>
      'Enregistrer et démarrer le minuteur';

  @override
  String get addInfusionSaveAndDeductStock =>
      'Enregistrer et décompter du stock';

  @override
  String get fieldBatchNumber => 'Numéro de lot / code-barres';

  @override
  String get fieldBatchNumberHint => 'Scanner ou saisir';

  @override
  String get fieldDosageUnits => 'Dosage / unités';

  @override
  String get fieldBodyWeight => 'Poids corporel (kg)';

  @override
  String get fieldInfusionNotes => 'Notes (ressenti, déroulement)';

  @override
  String get actionScanBarcode => 'Scanner le code-barres';

  @override
  String get actionPhotoOfLabel => 'Photo du lot / de l\'étiquette';

  @override
  String get validationPickOne => 'Veuillez choisir';

  @override
  String get legalBatchDocumentationShort =>
      'La documentation des lots dans cette application est une note personnelle et ne remplace pas la documentation légalement obligatoire tenue par vous ou par votre établissement de soins.';

  @override
  String get scheduleTitleNew => 'Créer un plan de perfusion';

  @override
  String get scheduleTitleEdit => 'Modifier le plan de perfusion';

  @override
  String get scheduleSelectDays => 'Sélectionner les jours :';

  @override
  String get scheduleAddTime => 'Ajouter un autre horaire';

  @override
  String get scheduleActivate => 'Activer le plan';

  @override
  String get sectionMedicationAndDose => 'Médication et dose';

  @override
  String get sectionFrequency => 'Fréquence';

  @override
  String get sectionPeriod => 'Période';

  @override
  String get sectionIntakeTimes => 'Heures de prise';

  @override
  String get fieldUnitsPerInfusion => 'Unités par perfusion';

  @override
  String get fieldNumberOfDays => 'Nombre de jours';

  @override
  String get fieldNumberOfDaysHint => 'P. ex. tous les 5 jours';

  @override
  String get fieldStartDate => 'Date de début';

  @override
  String get frequencyDaily => 'Quotidien';

  @override
  String get frequencyInterval => 'Tous les X jours';

  @override
  String get frequencyWeekly => 'Hebdomadaire';

  @override
  String get frequencyBiweekly => 'Toutes les 2 semaines';

  @override
  String get frequencyWeekdays => 'Jours de la semaine précis';

  @override
  String get actionSaveChanges => 'Enregistrer les modifications';

  @override
  String get diaryTitle => 'Mon journal';

  @override
  String get diaryEmptyTitle => 'Votre journal est encore vide';

  @override
  String get diaryEmptyBody =>
      'Enregistrez votre première perfusion pour suivre votre traitement.';

  @override
  String get diaryVitalsAndSymptomsLabel => 'CONSTANTES ET SYMPTÔMES :';

  @override
  String get diaryDeleteEntryTitle => 'Supprimer l\'entrée ?';

  @override
  String get diaryDeleteEntryBody =>
      'Supprimer cette entrée ? Le stock sera automatiquement recrédité.';

  @override
  String get diaryOrderReceived => 'Commande reçue';

  @override
  String diaryEventDiscontinued(String name) {
    return 'Arrêté : $name';
  }

  @override
  String diaryEventPrescribed(String name) {
    return 'Nouvellement prescrit : $name';
  }

  @override
  String get fieldBatchNumberShort => 'Numéro de lot';

  @override
  String get fieldNotes => 'Notes';

  @override
  String batchValue(String batch) {
    return 'Lot : $batch';
  }

  @override
  String bpmValue(String value) {
    return '$value bpm';
  }

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get planningTitle => 'Rendez-vous et plans';

  @override
  String get planningTabUpcoming => 'À venir';

  @override
  String get planningTabSchedules => 'Plans';

  @override
  String get planningOverdue => 'En retard';

  @override
  String get planningNoUpcoming => 'Aucun rendez-vous à venir';

  @override
  String get planningNoSchedules => 'Aucun plan actif';

  @override
  String planningScheduledFor(String date) {
    return 'Prévu le $date';
  }

  @override
  String get planningDeletePastTitle => 'Supprimer les rendez-vous passés ?';

  @override
  String get planningDeletePastBody =>
      'Supprimer définitivement tous les rendez-vous planifiés passés ?\n\nAucune entrée de journal ne sera créée.';

  @override
  String get planningSkipTitle => 'Ignorer le rendez-vous ?';

  @override
  String get planningSkipBody =>
      'Ignorer ce rendez-vous ? Il sera marqué comme effectué mais ne sera pas consigné dans le journal.';

  @override
  String get planningSkippedNote => '[Ignoré via l\'application]';

  @override
  String get planningDeleteAppointmentTitle => 'Supprimer le rendez-vous ?';

  @override
  String get planningDeleteAppointmentBody =>
      'Retirer ce rendez-vous précis de votre planning ?';

  @override
  String get planningEditAppointmentTitle => 'Modifier le rendez-vous';

  @override
  String get planningDeleteScheduleTitle => 'Supprimer le plan ?';

  @override
  String get planningDeleteScheduleBody =>
      'Tous les rendez-vous futurs (non effectués) de ce plan seront également supprimés.';

  @override
  String get planningOneOffTitle => 'Rendez-vous ponctuel';

  @override
  String get planningOneOffSubtitle => 'Ajouter un rendez-vous unique';

  @override
  String get planningRecurringTitle => 'Plan récurrent';

  @override
  String get planningRecurringSubtitle =>
      'Configurer un rythme de perfusion automatique';

  @override
  String get planningNeedMedicationsFirst =>
      'Ajoutez d\'abord des médicaments à votre inventaire !';

  @override
  String get planningScheduleAppointmentTitle => 'Planifier un rendez-vous';

  @override
  String frequencyEveryNDays(int days) {
    return 'Tous les $days jours';
  }

  @override
  String get frequencyWeekdaysShort => 'Jours de semaine';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldPlannedDose => 'Dose prévue';

  @override
  String fieldDoseWithUnit(String unit) {
    return 'Dose ($unit)';
  }

  @override
  String doseValue(String amount, String unit) {
    return 'Dose : $amount $unit';
  }

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionDeleteAll => 'Tout supprimer';

  @override
  String get actionSkip => 'Ignorer';

  @override
  String get actionDone => 'Effectué';

  @override
  String get dashboardTitle => 'Votre aperçu';

  @override
  String dashboardSectionLater(int count) {
    return 'PLANIFIÉ PLUS TARD ($count)';
  }

  @override
  String dashboardSectionPast(int count) {
    return 'RENDEZ-VOUS PASSÉS ($count)';
  }

  @override
  String get dashboardNoBackupTitle => 'Aucune sauvegarde activée';

  @override
  String get dashboardNoBackupBody =>
      'Configurez la sauvegarde automatique pour éviter de perdre vos données.';

  @override
  String get dashboardOrderRecommended => 'Commande recommandée';

  @override
  String dashboardLowStockNames(String names) {
    return 'Stock faible : $names';
  }

  @override
  String get dashboardOrdersOnTheWay => 'Des commandes sont en route.';

  @override
  String get dashboardPendingDeliveries => 'LIVRAISONS EN ATTENTE';

  @override
  String dashboardDeliveryDate(String date) {
    return 'Date de livraison : $date';
  }

  @override
  String get dashboardNoDeliveryDate => 'Aucune date définie';

  @override
  String get dashboardDeleteOrderTitle => 'Supprimer la commande ?';

  @override
  String get dashboardDeleteOrderBody => 'Retirer cette commande en attente ?';

  @override
  String get dashboardConfirmDeliveryTitle => 'Livraison reçue ?';

  @override
  String get dashboardConfirmDeliveryBody =>
      'Confirmer la réception de cette livraison ? Votre stock sera mis à jour automatiquement.';

  @override
  String get dashboardConfirmDeliveryYes => 'Oui, reçue';

  @override
  String get dashboardStockUpdated => 'Stock mis à jour !';

  @override
  String get dashboardReceived => 'Reçue';

  @override
  String dashboardMissedAt(String time) {
    return 'Manqué (prévu à $time)';
  }

  @override
  String dashboardTodayAt(String time) {
    return 'Aujourd\'hui à $time';
  }

  @override
  String get dashboardMissedInfusion =>
      'Perfusion manquée (prévue aujourd\'hui)';

  @override
  String dashboardPlannedToday(String amount, String unit) {
    return 'Prévu aujourd\'hui ($amount $unit)';
  }

  @override
  String dashboardMarkedDone(String name) {
    return '$name effectué !';
  }

  @override
  String get dashboardLogInfusionNow => 'Enregistrer la perfusion';

  @override
  String get dashboardAllDoneTitle => 'Tout est fait !';

  @override
  String get dashboardAllDoneBody => 'Aucune tâche en attente.';

  @override
  String dashboardTreatmentSubtitle(
    String date,
    String time,
    String amount,
    String unit,
  ) {
    return '$date à $time • $amount $unit';
  }

  @override
  String get dashboardOrphanRemoved => 'Rendez-vous orphelin supprimé';

  @override
  String get dashboardUnknownMedication => 'Médicament inconnu';

  @override
  String dashboardOrphanSubtitle(String date) {
    return 'Prévu $date • médicament introuvable';
  }

  @override
  String quantityValue(String amount, String unit) {
    return 'Quantité : $amount $unit';
  }

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get actionNo => 'Non';

  @override
  String get actionRemove => 'Supprimer';

  @override
  String get inventorySectionMedications => 'MÉDICAMENTS';

  @override
  String get inventorySectionStandaloneSupplies => 'CONSOMMABLES INDÉPENDANTS';

  @override
  String get inventoryNoMedications => 'Aucun médicament ajouté';

  @override
  String inventoryNextTreatment(String date) {
    return 'Prochaine : $date';
  }

  @override
  String inventoryLastsUntil(String date) {
    return 'Suffisant jusqu\'au : $date';
  }

  @override
  String get inventoryLowStock => 'Stock faible !';

  @override
  String get inventoryOrderOnTheWay => 'Commande en route';

  @override
  String inventoryPzn(String pzn) {
    return 'PZN : $pzn';
  }

  @override
  String stockValue(String amount, String unit) {
    return 'Stock : $amount $unit';
  }

  @override
  String get accessoryEditTitle => 'Modifier le consommable';

  @override
  String get accessoryDeleteTitle => 'Supprimer le consommable ?';

  @override
  String confirmDeleteNamed(String name) {
    return 'Voulez-vous vraiment supprimer « $name » ?';
  }

  @override
  String get fieldName => 'Nom';

  @override
  String get fieldUnit => 'Unité';

  @override
  String get fieldCurrentStock => 'Stock actuel';

  @override
  String get fieldPackageSize => 'Taille du conditionnement (pour la commande)';

  @override
  String get fieldMinStock => 'Seuil d\'alerte (stock)';

  @override
  String get addItemTitle => 'Ajouter un nouvel élément';

  @override
  String get fieldCategory => 'Catégorie';

  @override
  String get categoryMedication => 'Médicament';

  @override
  String get categorySupply => 'Consommable';

  @override
  String get fieldDosageForm => 'Forme galénique';

  @override
  String get dosageFormInfusion => 'Perfusion';

  @override
  String get dosageFormPill => 'Comprimé / pilule';

  @override
  String get fieldMedicationName => 'Nom du médicament';

  @override
  String get fieldMedicationNameHint => 'p. ex. Hizentra';

  @override
  String get fieldStrength => 'Dose / concentration';

  @override
  String get fieldStrengthHint => 'p. ex. 20 % ou 10 ml';

  @override
  String get fieldPznOptional => 'PZN (facultatif)';

  @override
  String get fieldPznHint => 'Numéro central pharmaceutique';

  @override
  String get fieldInitialStock => 'Stock initial';

  @override
  String get fieldDefaultReorderAmount =>
      'Quantité de réapprovisionnement par défaut';

  @override
  String get fieldDefaultReorderAmountHint => 'p. ex. 10 flacons';

  @override
  String get fieldMinStockDays => 'Seuil d\'alerte (en jours)';

  @override
  String get fieldMinStockDaysHint =>
      'Alerter quand le stock dure moins de x jours';

  @override
  String get fieldMinStockHint =>
      'Alerter quand le stock passe sous cette valeur';

  @override
  String get unitBottle => 'Flacon';

  @override
  String get unitPieces => 'pcs';

  @override
  String get validationRequired => 'Champ obligatoire';

  @override
  String get shoppingWizardTitle => 'Assistant d\'achat';

  @override
  String get shoppingWizardEditTitle => 'Modifier la commande';

  @override
  String get shoppingWizardIntro =>
      'Calculez vos besoins en consommables à partir de la commande de médicaments que vous préparez.';

  @override
  String get shoppingWizardEditIntro =>
      'Ajustez votre commande et les consommables associés.';

  @override
  String get shoppingWizardSuppliesOnly =>
      'Commander uniquement des consommables (aucun médicament)';

  @override
  String shoppingWizardOrderQuantity(String unit) {
    return 'Quantité commandée ($unit)';
  }

  @override
  String get shoppingWizardDeliveryDate => 'Date de livraison (facultatif)';

  @override
  String get shoppingWizardImmediately => 'Juste après confirmation';

  @override
  String get shoppingWizardSuggestion => 'Consommables suggérés :';

  @override
  String get shoppingWizardRequired => 'Nécessaire pour cette commande :';

  @override
  String get shoppingWizardOptional => 'Autres consommables (facultatif) :';

  @override
  String get shoppingWizardNoSuggestions =>
      'Aucun consommable suggéré automatiquement.';

  @override
  String get shoppingWizardAddOther => 'Ajouter un autre consommable';

  @override
  String get shoppingWizardSaveOrder => 'Enregistrer la commande';

  @override
  String get shoppingWizardPickSupply => 'Sélectionner un consommable';

  @override
  String get shoppingWizardAlreadyInList => 'Déjà dans la liste !';

  @override
  String get shoppingWizardRecommendedAmount => 'Quantité recommandée';

  @override
  String get shoppingWizardAdditionallySelected => 'Ajouté par vous';

  @override
  String get medDetailsDiscontinue => 'Arrêter';

  @override
  String get medDetailsDiscontinueMedication => 'Arrêter le médicament';

  @override
  String get medDetailsReenroll => 'Prescrire à nouveau';

  @override
  String get medDetailsDeleteCompletely => 'Supprimer complètement';

  @override
  String get medDetailsDeleteFromDatabase =>
      'Supprimer entièrement de la base de données';

  @override
  String medDetailsDiscontinuedSince(String date) {
    return 'Ce médicament est arrêté depuis le $date';
  }

  @override
  String get medDetailsSectionStock => 'Stock et alertes';

  @override
  String get medDetailsSectionSupplies => 'Consommables associés';

  @override
  String get medDetailsSuppliesHint =>
      'Ces consommables sont automatiquement déduits du stock à chaque prise.';

  @override
  String get medDetailsNoSuppliesLinked => 'Aucun consommable associé';

  @override
  String get medDetailsLink => 'Associer';

  @override
  String get medDetailsCreateAndLink => 'Nouveau et associer';

  @override
  String get medDetailsSectionWorkflow => 'Flux de saisie';

  @override
  String get medDetailsWorkflowHint =>
      'Choisissez les champs affichés lors de la saisie d\'une prise.';

  @override
  String get medDetailsSchedulesHint =>
      'Définissez le rythme auquel vous prenez ce médicament.';

  @override
  String get medDetailsCreateSchedule => 'Créer un plan';

  @override
  String get medDetailsPlanOneOff => 'Planifier un rendez-vous ponctuel';

  @override
  String get medDetailsSectionSystemActions => 'Actions système';

  @override
  String medDetailsRequirement(String amount, String unit) {
    return 'Besoin : $amount $unit';
  }

  @override
  String get medDetailsMustBeOrdered => 'Doit toujours être commandé';

  @override
  String get medDetailsNeedSuppliesFirst => 'Créez d\'abord des consommables !';

  @override
  String get medDetailsLinkSupplyTitle => 'Associer un consommable';

  @override
  String get medDetailsPickSupply => 'Choisir un consommable';

  @override
  String get medDetailsCreateSupplyTitle => 'Créer un nouveau consommable';

  @override
  String get medDetailsAlwaysOrder => 'Toujours commander avec';

  @override
  String get medDetailsAlwaysOrderHint =>
      'Mis en évidence dans l\'assistant d\'achat';

  @override
  String get medDetailsEditMedication => 'Modifier le médicament';

  @override
  String get medDetailsDeleteTitle => 'Supprimer le médicament ?';

  @override
  String medDetailsDeleteBody(String name) {
    return 'Supprimer définitivement « $name » de l\'application ? Cette action est irréversible et ne devrait servir qu\'à corriger une erreur. Pour mettre fin à un traitement, utilisez plutôt « Arrêter ».';
  }

  @override
  String get medDetailsDiscontinueTitle => 'Arrêter le médicament ?';

  @override
  String medDetailsDiscontinueBody(String name) {
    return 'Arrêter « $name » ? Il quitte la liste active mais reste dans votre historique. Les rendez-vous futurs seront supprimés.';
  }

  @override
  String medDetailsTimes(String times) {
    return 'Horaires : $times';
  }

  @override
  String get medDetailsTrackBatch => 'Enregistrer le numéro de lot';

  @override
  String get medDetailsTrackBatchHint => 'Scanner un code-barres ou le saisir';

  @override
  String get medDetailsTrackWeight => 'Enregistrer le poids corporel';

  @override
  String get medDetailsTrackWeightHint =>
      'Consigner votre poids à chaque prise';

  @override
  String get medDetailsUseTimer => 'Utiliser le minuteur de prise';

  @override
  String get medDetailsUseTimerHint =>
      'Minuteur de prémédication avant la prise';

  @override
  String medDetailsConfigureNamed(String name) {
    return 'Configurer $name';
  }

  @override
  String get medDetailsEditSupplyGlobally =>
      'Modifier le consommable globalement (nom, unité)';

  @override
  String get medDetailsStockUpdated => 'Niveau de stock mis à jour';

  @override
  String get medDetailsSaveStock => 'Enregistrer le stock';

  @override
  String get fieldPerInfusionRequirement => 'Besoin par perfusion';

  @override
  String fieldPerInfusionRequirementWithUnit(String unit) {
    return 'Besoin par perfusion ($unit)';
  }

  @override
  String get fieldSupplyName => 'Nom du consommable';

  @override
  String get fieldUnitWithExample => 'Unité (p. ex. pcs, kit)';

  @override
  String get fieldUnitWithBottleExample => 'Unité (p. ex. flacon)';

  @override
  String get fieldStrengthWithExample => 'Dose / concentration (p. ex. 10 g)';

  @override
  String get fieldPzn => 'PZN';

  @override
  String get fieldCurrentStockShort => 'Stock actuel';

  @override
  String fieldPlannedDoseWithUnit(String unit) {
    return 'Dose prévue ($unit)';
  }

  @override
  String get actionCreate => 'Créer';

  @override
  String get channelBackgroundService => 'Service en arrière-plan';

  @override
  String get channelBackgroundServiceDesc =>
      'Utilisé pour le minuteur et les tâches en arrière-plan';

  @override
  String get channelStockWarnings => 'Alertes de stock';

  @override
  String get channelStockWarningsDesc =>
      'Vous avertit quand les médicaments ou consommables s\'épuisent';

  @override
  String get channelMissedIntakes => 'Prises manquées';

  @override
  String get channelMissedIntakesDesc =>
      'Avis concernant les prises non confirmées ou manquées';

  @override
  String get channelBackupFailures => 'Échecs de sauvegarde';

  @override
  String get channelBackupFailuresDesc =>
      'Notifications en cas de problème avec la sauvegarde automatique';

  @override
  String get channelBackupWarnings => 'Alertes de sauvegarde';

  @override
  String get channelBackupWarningsDesc =>
      'Avis concernant la configuration de la sauvegarde';

  @override
  String get channelMedReminders => 'Rappels de médicaments';

  @override
  String get channelMedRemindersDesc =>
      'Rappels pour les prises et perfusions planifiées';

  @override
  String get channelPremedTimerDesc =>
      'Minuteur en cours pour la prémédication';

  @override
  String get reminderDueTitle => 'Rappel : médicament à prendre';

  @override
  String reminderDueBody(String medication) {
    return 'Il est temps de prendre $medication.';
  }

  @override
  String get reminderGenericMedication => 'votre médicament';

  @override
  String get reminderSnoozeTitle => 'Rappel (répétition)';

  @override
  String get reminderSnoozeBody =>
      'Vous n\'avez pas encore marqué votre prise comme effectuée.';

  @override
  String get reminderHourlyTitle => 'Rappel (horaire)';

  @override
  String get reminderHourlyBody => 'N\'oubliez pas votre prise.';

  @override
  String get notificationCompletedNote => 'Effectué via la notification';

  @override
  String get notificationSkippedNote => '[Ignoré via la notification]';

  @override
  String get timerFinishedTitle => 'Prémédication terminée';

  @override
  String get timerFinishedBody =>
      'Le minuteur est écoulé — la perfusion peut commencer.';

  @override
  String missedIntakesSummary(int count) {
    return '$count prises non confirmées';
  }

  @override
  String missedIntakesOpenCount(int count) {
    return '$count en attente';
  }

  @override
  String get backupReminderTitle => 'Configurer la sauvegarde';

  @override
  String get backupReminderBody =>
      'Vos données ne sont pas encore sauvegardées automatiquement. Appuyez ici pour configurer.';

  @override
  String get backupFailedTitle => 'Échec de la sauvegarde';

  @override
  String backupFailedBody(String error) {
    return 'La sauvegarde automatique n\'a pas pu être créée : $error';
  }

  @override
  String get backupDestinationAppFolder =>
      'Dossier de l\'app (Fichiers → CIDP Buddy → Backups)';

  @override
  String get backupDestinationSafFolder => 'Dossier cloud / SAF';

  @override
  String get backupDestinationPickedFolder => 'Dossier choisi';

  @override
  String backupFolderUnreadable(String path, String error) {
    return 'Dossier illisible : $path\n($error)';
  }

  @override
  String backupFolderMissing(String path) {
    return 'Le dossier n\'existe plus : $path';
  }

  @override
  String backupFolderNotWritable(String path, String error) {
    return 'Accès en écriture refusé : $path\n($error)';
  }

  @override
  String get backupFolderMissingShort => 'Le dossier n\'existe pas.';

  @override
  String get backupFolderEmpty => 'Le dossier est vide.';

  @override
  String get backupSafFolderEmpty => 'Le dossier SAF est vide.';

  @override
  String backupFolderContents(int count, String names) {
    return 'Trouvé ($count) : $names';
  }

  @override
  String backupFolderListFailed(String error) {
    return 'Impossible de lister le dossier : $error';
  }

  @override
  String backupSafListFailed(String error) {
    return 'Impossible de lister le dossier SAF : $error';
  }

  @override
  String get backupSafPermissionLost =>
      'L\'autorisation du dossier cloud a été perdue. Veuillez resélectionner le dossier.';

  @override
  String get backupNoDestination =>
      'Aucune destination de sauvegarde sélectionnée.';

  @override
  String get backupAutoDisabled => 'La sauvegarde automatique est désactivée.';

  @override
  String get backupSkippedRecent =>
      'Ignoré : une sauvegarde récente existe déjà.';

  @override
  String backupWriteError(String error) {
    return 'Erreur d\'écriture : $error';
  }

  @override
  String get settingsSectionAppearance => 'Apparence';

  @override
  String get settingsDarkMode => 'Thème sombre';

  @override
  String get settingsDarkModeHint => 'Basculer entre le mode clair et sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Langue du système';

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
  String get settingsSectionAutoBackup => 'Sauvegarde automatique';

  @override
  String get settingsEnableAutoBackup => 'Activer la sauvegarde automatique';

  @override
  String get settingsEnableAutoBackupHint =>
      'Sauvegarde régulièrement vos données dans le dossier choisi';

  @override
  String get settingsBackupNotPossible => 'Sauvegarde impossible';

  @override
  String get settingsUnknownError => 'Erreur inconnue';

  @override
  String get settingsPickFolderAgain => 'Resélectionner le dossier';

  @override
  String get backupBookmarkAccessLost =>
      'CIDP Buddy ne peut plus accéder au dossier de sauvegarde que vous avez choisi. Veuillez le resélectionner.';

  @override
  String get settingsBackupsInsideAppTitle =>
      'Les sauvegardes sont dans l\'app';

  @override
  String get settingsBackupsInsideAppBody =>
      'Elles sont supprimées avec l\'application. Choisissez un dossier dans l\'app Fichiers pour que les sauvegardes restent en dehors — ou exportez une copie régulièrement.';

  @override
  String get settingsBackupDestination => 'Destination de sauvegarde';

  @override
  String get settingsPickDestination => 'Choisir une destination…';

  @override
  String get settingsRunBackupNow => 'Lancer la sauvegarde maintenant';

  @override
  String get settingsBackupSucceeded => 'Sauvegarde réussie !';

  @override
  String settingsBackupFailed(String error) {
    return 'Échec de la sauvegarde : $error';
  }

  @override
  String get settingsExportBackup => 'Exporter la sauvegarde';

  @override
  String get settingsExportBackupHint =>
      'Enregistrer la dernière sauvegarde dans Fichiers ou iCloud Drive, par exemple';

  @override
  String get settingsNoBackupToExport =>
      'Aucune sauvegarde à exporter. Lancez d\'abord une sauvegarde.';

  @override
  String get settingsLastSuccess => 'Dernier succès';

  @override
  String get settingsLastAttempt => 'Dernière tentative';

  @override
  String get settingsRestoreBackup => 'Restaurer une sauvegarde';

  @override
  String get settingsRestoreBackupHint =>
      'Choisissez une sauvegarde automatique à restaurer';

  @override
  String get settingsIosStorageInfo =>
      'Les sauvegardes peuvent être écrites directement dans un dossier que vous choisissez dans l\'app Fichiers : iCloud Drive, Nextcloud, Dropbox ou un lecteur connecté. CIDP Buddy continue d\'y écrire automatiquement, et ces sauvegardes survivent à la suppression de l\'application.\n\nSans dossier choisi, les sauvegardes restent dans l\'application et sont supprimées avec elle — vous devez alors exporter vous-même une copie.';

  @override
  String get settingsIosPickFolder => 'Choisir un dossier';

  @override
  String get settingsIosUseAppFolder => 'Utiliser le dossier de l\'app';

  @override
  String get settingsDestinationConnectFailed =>
      'Impossible de connecter la destination. Veuillez en choisir une autre.';

  @override
  String get settingsDestinationConnected =>
      'Destination de sauvegarde connectée.';

  @override
  String get settingsSectionReminders => 'Rappels';

  @override
  String get settingsSnooze => 'Rappel différé';

  @override
  String settingsSnoozeHint(int minutes) {
    return 'Rappeler toutes les $minutes minutes (3×)';
  }

  @override
  String get settingsSnoozeInterval => 'Intervalle de rappel';

  @override
  String settingsSnoozeIntervalCurrent(int minutes) {
    return 'Actuellement : toutes les $minutes minutes';
  }

  @override
  String settingsEveryNMinutes(int minutes) {
    return 'Toutes les $minutes minutes';
  }

  @override
  String get settingsHourlyReminder => 'Rappel horaire';

  @override
  String get settingsHourlyReminderHint => 'Rappeler à l\'heure pile';

  @override
  String get settingsQuietHours => 'Heures silencieuses';

  @override
  String get settingsQuietHoursTitle => 'Définir les heures silencieuses';

  @override
  String settingsQuietHoursHint(String start, String end) {
    return 'Aucun rappel de $start à $end';
  }

  @override
  String get settingsQuietHoursStart => 'Début';

  @override
  String get settingsQuietHoursEnd => 'Fin';

  @override
  String get settingsSectionSystem => 'Système et fiabilité';

  @override
  String get settingsSectionHyqviaTimer => 'Minuteur Hyqvia';

  @override
  String get settingsSuggestTimer => 'Proposer le minuteur automatiquement';

  @override
  String get settingsSuggestTimerHint =>
      'Proposer le minuteur de prémédication pour les perfusions Hyqvia';

  @override
  String get settingsPremedDuration => 'Durée de prémédication';

  @override
  String settingsCurrentMinutes(int minutes) {
    return 'Actuellement : $minutes minutes';
  }

  @override
  String get settingsSetDefaultDuration => 'Définir la durée par défaut';

  @override
  String get settingsSectionLegal => 'Mentions légales';

  @override
  String get settingsSectionAbout => 'À propos de CIDP Buddy';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsBuildTimestamp => 'Horodatage du build';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsPrivacyHint =>
      'Toutes les données sont stockées localement sur cet appareil.';

  @override
  String get settingsPickBackup => 'Sélectionner une sauvegarde';

  @override
  String get settingsPickZip => 'Choisir un ZIP';

  @override
  String get restoreNoFolderTitle => 'Aucun dossier de sauvegarde connecté';

  @override
  String get restoreNoFolderBody =>
      'Choisissez le dossier contenant vos sauvegardes — par exemple le dossier cloud d\'une installation précédente.';

  @override
  String get restorePickFolder => 'Choisir le dossier de sauvegarde';

  @override
  String get restorePickOtherFolder => 'Choisir un autre dossier';

  @override
  String restoreCurrentFolder(String label) {
    return 'Dossier actuel :\n$label';
  }

  @override
  String get restoreAccessLostTitle => 'Accès au dossier de sauvegarde perdu';

  @override
  String get restoreAccessLostBody =>
      'Resélectionnez le dossier pour rétablir l\'autorisation. Vos sauvegardes existantes sont préservées.';

  @override
  String get restoreNoBackupsTitle => 'Aucune sauvegarde trouvée';

  @override
  String get restoreNoBackupsBody =>
      'Le dossier connecté ne contient aucune sauvegarde (fichiers nommés « cidpbuddy_backup_…zip » ou « igkeeper_backup_…zip »).';

  @override
  String get restoreNoBackupsHint =>
      'Si vos sauvegardes se trouvent dans un autre dossier, sélectionnez-le ici.';

  @override
  String restoreReadFailed(String error) {
    return 'Impossible de lire les sauvegardes : $error';
  }

  @override
  String get restoreFolderConnectFailed =>
      'Impossible de connecter le dossier.';

  @override
  String get restoreConfirmTitle => 'Restaurer la sauvegarde ?';

  @override
  String restoreConfirmFile(String name) {
    return 'Voulez-vous vraiment restaurer le fichier « $name » ?';
  }

  @override
  String restoreConfirmDated(String date) {
    return 'Voulez-vous vraiment restaurer la sauvegarde du $date ?';
  }

  @override
  String get restoreOverwriteWarning =>
      'ATTENTION : toutes les données actuelles seront écrasées définitivement !';

  @override
  String get restoreFailed => 'Échec de la restauration.';

  @override
  String get restoreSucceeded =>
      'Données restaurées. Redémarrage de l\'application…';

  @override
  String get restoreRestartManually =>
      'Veuillez redémarrer l\'application manuellement.';

  @override
  String get legalLiabilityTitle => 'Clause de non-responsabilité';

  @override
  String get legalLiabilitySubtitle =>
      'Pas un dispositif médical, pas un avis médical';

  @override
  String get legalBatchDocumentationTitle => 'Documentation des lots';

  @override
  String get legalBatchDocumentationSubtitle =>
      'Ne remplace pas la documentation légalement obligatoire';

  @override
  String get legalImprint => 'Mentions légales';

  @override
  String get legalPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get actionOk => 'OK';

  @override
  String get actionUnderstood => 'J\'ai compris';

  @override
  String get actionRestore => 'Restaurer';

  @override
  String genericError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get reliabilityTitle => 'Vérification de fiabilité';

  @override
  String get reliabilitySubtitle =>
      'Vérifier les autorisations et les réglages de batterie';

  @override
  String get reliabilityNotifications => 'Notifications';

  @override
  String get reliabilityNotificationsDesc =>
      'Nécessaire pour les rappels de médicaments et la fin du minuteur.';

  @override
  String get reliabilityExactAlarms => 'Alarmes exactes';

  @override
  String get reliabilityExactAlarmsDesc =>
      'Permet à l\'application de déclencher les rappels à la seconde près.';

  @override
  String get reliabilityBatteryOptimization => 'Optimisation de la batterie';

  @override
  String get reliabilityBatteryOptimizationDesc =>
      'Empêche Android de fermer l\'application en arrière-plan.';

  @override
  String get reliabilityBackupDesc =>
      'Sauvegarde régulièrement vos données, dans le cloud ou localement.';

  @override
  String get reliabilityBackupStatus => 'État de la sauvegarde';

  @override
  String get reliabilityBackupUpToDate =>
      'Votre dernière sauvegarde est à jour.';

  @override
  String get reliabilityBackupStale =>
      'Votre dernière sauvegarde est obsolète ou a échoué.';

  @override
  String get reliabilityAllGood => 'Tout est en ordre !';

  @override
  String get reliabilityAllGoodBody =>
      'Vos réglages sont optimaux pour une fiabilité maximale.';

  @override
  String get reliabilityActionNeeded => 'Action requise';

  @override
  String get reliabilityActionNeededBody =>
      'Certains réglages limitent la fiabilité des rappels.';

  @override
  String get reliabilityFix => 'Corriger ce réglage';

  @override
  String get reliabilityFooterHint =>
      'Remarque : les vérifications se rafraîchissent automatiquement au retour des réglages système.';

  @override
  String get reliabilityRefresh => 'Actualiser l\'état';

  @override
  String get legalBatchDocumentationLong =>
      'CIDP Buddy conserve les numéros de lot, les photos et les notes uniquement comme aide-mémoire personnelle sur votre appareil.\n\nCes enregistrements ne remplacent pas la documentation des lots exigée par la loi allemande sur la transfusion (TFG) ou par les règles nationales qui vous sont applicables. Cette obligation incombe toujours à votre médecin ou à votre établissement de soins.\n\nContinuez donc à tenir la documentation obligatoire à l\'identique — même si vous saisissez également ces informations dans cette application.';

  @override
  String get legalLiabilityBody =>
      'CIDP Buddy est un outil d\'organisation privé et non un dispositif médical. L\'application sert uniquement à faciliter la gestion de vos rendez-vous, de vos stocks et de vos notes.\n\nL\'application ne constitue pas un avis médical et ne remplace ni le diagnostic, ni le traitement, ni les recommandations de professionnels de santé. Ne prenez jamais de décision concernant votre traitement, votre dosage ou vos médicaments sur la seule base de cette application. En cas de problème de santé, adressez-vous à votre médecin ; en cas d\'urgence, appelez les secours.\n\nTous les calculs (autonomie du stock, alertes de stock, rendez-vous planifiés, etc.) reposent sur les données que vous avez saisies et peuvent être erronés. Les rappels et notifications peuvent être retardés, dupliqués ou totalement absents en raison des fonctions d\'économie d\'énergie, des réglages système ou de défauts du système d\'exploitation. Ne vous fiez donc pas uniquement à l\'application.\n\nToutes les données restent uniquement sur votre appareil. Leur sauvegarde relève de votre responsabilité ; aucune responsabilité n\'est assumée en cas de perte de données.\n\nL\'utilisation se fait à vos propres risques. Toute responsabilité pour les dommages résultant de l\'utilisation ou de l\'indisponibilité de l\'application est exclue dans la mesure permise par la loi.';

  @override
  String get shareBackupSubject => 'Sauvegarde CIDP Buddy';

  @override
  String shareBackupText(String date) {
    return 'Sauvegarde de la base de données CIDP Buddy du $date';
  }

  @override
  String get tooltipOpenStatistics => 'Statistiques';

  @override
  String get tooltipEditOrder => 'Modifier la commande';

  @override
  String get tooltipDeleteOrder => 'Supprimer la commande';

  @override
  String get tooltipEditInfusionLog => 'Modifier l\'entrée de perfusion';

  @override
  String get tooltipDeleteInfusionLog => 'Supprimer l\'entrée de perfusion';

  @override
  String get tooltipEditSupply => 'Modifier le consommable';

  @override
  String get tooltipDeleteSupply => 'Supprimer le consommable';

  @override
  String get tooltipShowDetails => 'Afficher les détails';

  @override
  String get tooltipEditMedication => 'Modifier le médicament';

  @override
  String get tooltipLinkSettings => 'Paramètres de liaison';

  @override
  String get tooltipUnlinkSupply => 'Retirer ce consommable de ce médicament';

  @override
  String get tooltipEditSchedule => 'Modifier le plan';

  @override
  String get tooltipDeleteSchedule => 'Supprimer le plan';

  @override
  String get tooltipClearDate => 'Effacer la date';

  @override
  String get tooltipRemoveIntakeTime => 'Retirer l\'heure';

  @override
  String get tooltipRemovePhoto => 'Supprimer la photo';

  @override
  String get tooltipTimerReset => 'Réinitialiser le minuteur';

  @override
  String get tooltipTimerStart => 'Démarrer le minuteur';

  @override
  String get tooltipTimerPause => 'Mettre le minuteur en pause';

  @override
  String get tooltipTimerDuration => 'Définir la durée';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionDiscard => 'Abandonner';

  @override
  String get actionKeepEditing => 'Continuer la modification';

  @override
  String get actionUndo => 'Annuler';

  @override
  String dashboardLogInfusionFor(String name) {
    return 'Enregistrer la perfusion de $name maintenant';
  }

  @override
  String dashboardMarkDoneFor(String name) {
    return 'Marquer $name comme pris';
  }

  @override
  String dashboardRemoveFor(String name) {
    return 'Retirer $name du planning';
  }

  @override
  String symptomScoreLabel(String symptom, int score) {
    return '$symptom : $score sur 10';
  }

  @override
  String get backupDestinationConfigured =>
      'Destination de sauvegarde configurée';

  @override
  String get reliabilityStatusOk => 'OK';

  @override
  String get reliabilityStatusFailed => 'Action requise';

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
  String get savedInfusion => 'Perfusion enregistrée';

  @override
  String get savedDiaryEntry => 'Entrée enregistrée';

  @override
  String get savedSchedule => 'Plan enregistré';

  @override
  String get savedOrder => 'Commande enregistrée';

  @override
  String get savedMedication => 'Médicament enregistré';

  @override
  String get deletedGeneric => 'Supprimé';

  @override
  String saveFailed(String error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String get discardChangesTitle => 'Abandonner les modifications ?';

  @override
  String get discardChangesBody =>
      'Vos saisies n\'ont pas encore été enregistrées.';

  @override
  String get errorLoadingData => 'Les données n\'ont pas pu être chargées.';

  @override
  String get medDetailsNotFound => 'Ce médicament n\'existe plus.';

  @override
  String get confirmUnlinkSupplyTitle => 'Retirer le consommable ?';

  @override
  String confirmUnlinkSupplyBody(String name) {
    return '$name ne sera plus commandé avec ce médicament.';
  }

  @override
  String get confirmReenrollTitle => 'Prescrire à nouveau ce médicament ?';

  @override
  String confirmReenrollBody(String name) {
    return '$name revient dans la liste active ; ses plans et rappels sont recréés.';
  }

  @override
  String get validationEnterNumber => 'Veuillez saisir un nombre.';

  @override
  String get validationPositiveNumber =>
      'Veuillez saisir un nombre supérieur à 0.';

  @override
  String get inventoryAddFirstMedicationHint =>
      'Ajoutez votre premier médicament avec le bouton ci-dessous.';

  @override
  String get savedSupply => 'Consommable enregistré';

  @override
  String reenrolledMedication(String name) {
    return '$name est de nouveau actif';
  }

  @override
  String get restoringPleaseWait =>
      'Restauration de la sauvegarde, veuillez patienter…';

  @override
  String get loading => 'Chargement…';
}
