// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get statisticsTitle => 'Estadísticas';

  @override
  String get statisticsEmpty => 'Aún no hay datos para las estadísticas.';

  @override
  String get statisticsMonthlyDose => 'Dosis mensual';

  @override
  String get statisticsMonthlyDoseSubtitle =>
      'Unidades administradas en los últimos 6 meses';

  @override
  String get statisticsSummary => 'Resumen';

  @override
  String get statisticsTotalInfusions => 'Infusiones totales';

  @override
  String get statisticsTotalDose => 'Dosis total';

  @override
  String get statisticsAverageDose => 'Dosis media / administración';

  @override
  String get statisticsLastWeight => 'Último peso';

  @override
  String unitsValue(String value) {
    return '$value unidades';
  }

  @override
  String kilogramsValue(String value) {
    return '$value kg';
  }

  @override
  String get timerBannerRunning => 'Temporizador de premedicación en marcha';

  @override
  String get timerBannerPaused => 'Temporizador de premedicación en pausa';

  @override
  String timerBannerRemaining(String time) {
    return '$time restante • Toca para abrir';
  }

  @override
  String get discontinuedTitle => 'Medicamentos suspendidos';

  @override
  String get discontinuedEmpty => 'No hay medicamentos suspendidos.';

  @override
  String discontinuedOn(String date) {
    return 'Suspendido el: $date';
  }

  @override
  String get timerTitle => 'Temporizador de premedicación';

  @override
  String timerSubtitle(int minutes) {
    return 'Señal cada minuto • temporizador de $minutes min';
  }

  @override
  String get timerRemainingLabel => 'restante';

  @override
  String get timerSyringeProgress => 'Progreso de la jeringa';

  @override
  String get timerVolumePickerTitle => 'Volumen de premedicación (ml)';

  @override
  String get backgroundServiceRunning => 'Servicio activo en segundo plano';

  @override
  String timerNotificationRemaining(String time) {
    return 'Restante: $time';
  }

  @override
  String get medicationFallbackName => 'Medicamento';

  @override
  String get appTitle => 'CIDP Buddy';

  @override
  String startupFailed(String error) {
    return 'No se pudo inicializar la aplicación:\n$error';
  }

  @override
  String get navDashboard => 'Panel';

  @override
  String get navDiary => 'Diario';

  @override
  String get navMedication => 'Medicación';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get diaryEntryTitleNew => 'Constantes y síntomas';

  @override
  String get diaryEntryTitleEdit => 'Editar entrada';

  @override
  String get diaryEntrySave => 'Guardar entrada';

  @override
  String get diaryNotesHint => '¿Cómo te sientes hoy?';

  @override
  String get sectionDateTime => 'Fecha y hora';

  @override
  String get sectionVitals => 'Constantes vitales (opcional)';

  @override
  String get sectionSymptoms => 'Síntomas de CIDP (1-10)';

  @override
  String get sectionNotes => 'Notas adicionales';

  @override
  String get fieldSystolic => 'Sist. (mmHg)';

  @override
  String get fieldDiastolic => 'Diast. (mmHg)';

  @override
  String get fieldHeartRate => 'Pulso (lpm)';

  @override
  String get fieldTemperature => 'Temp. (°C)';

  @override
  String get fieldWeight => 'Peso (kg)';

  @override
  String get symptomStrength => 'Fuerza muscular';

  @override
  String get symptomSensory => 'Sensibilidad';

  @override
  String get symptomFatigue => 'Fatiga';

  @override
  String get symptomPain => 'Dolor';

  @override
  String get symptomBalance => 'Equilibrio';

  @override
  String get addInfusionTitle => 'Registrar infusión';

  @override
  String get addInfusionDetailsHeading => 'Detalles de la infusión';

  @override
  String get addInfusionPickMedication => 'Seleccionar medicamento';

  @override
  String get addInfusionWhen => 'Hora de la infusión';

  @override
  String get addInfusionSaveAndStartTimer => 'Guardar e iniciar temporizador';

  @override
  String get addInfusionSaveAndDeductStock =>
      'Guardar y descontar del inventario';

  @override
  String get fieldBatchNumber => 'Número de lote / código de barras';

  @override
  String get fieldBatchNumberHint => 'Escanea o escribe';

  @override
  String get fieldDosageUnits => 'Dosis / unidades';

  @override
  String get fieldBodyWeight => 'Peso corporal (kg)';

  @override
  String get fieldInfusionNotes => 'Notas (cómo te sentiste, evolución)';

  @override
  String get actionScanBarcode => 'Escanear código de barras';

  @override
  String get actionPhotoOfLabel => 'Foto del lote/etiqueta';

  @override
  String get validationPickOne => 'Selecciona una opción';

  @override
  String get legalBatchDocumentationShort =>
      'La documentación de lotes en esta aplicación es una nota personal y no sustituye la documentación legalmente obligatoria que llevan tú o tu centro de tratamiento.';

  @override
  String get scheduleTitleNew => 'Crear plan de infusión';

  @override
  String get scheduleTitleEdit => 'Editar plan de infusión';

  @override
  String get scheduleSelectDays => 'Selecciona los días:';

  @override
  String get scheduleAddTime => 'Añadir otra hora';

  @override
  String get scheduleActivate => 'Activar el plan';

  @override
  String get sectionMedicationAndDose => 'Medicación y dosis';

  @override
  String get sectionFrequency => 'Frecuencia';

  @override
  String get sectionPeriod => 'Periodo';

  @override
  String get sectionIntakeTimes => 'Horas de toma';

  @override
  String get fieldUnitsPerInfusion => 'Unidades por infusión';

  @override
  String get fieldNumberOfDays => 'Número de días';

  @override
  String get fieldNumberOfDaysHint => 'P. ej. cada 5 días';

  @override
  String get fieldStartDate => 'Fecha de inicio';

  @override
  String get frequencyDaily => 'Diario';

  @override
  String get frequencyInterval => 'Cada X días';

  @override
  String get frequencyWeekly => 'Semanal';

  @override
  String get frequencyBiweekly => 'Cada 2 semanas';

  @override
  String get frequencyWeekdays => 'Días concretos de la semana';

  @override
  String get actionSaveChanges => 'Guardar cambios';

  @override
  String get diaryTitle => 'Mi diario';

  @override
  String get diaryEmptyTitle => 'Tu diario aún está vacío';

  @override
  String get diaryEmptyBody =>
      'Registra tu primera infusión para hacer seguimiento de tu tratamiento.';

  @override
  String get diaryVitalsAndSymptomsLabel => 'CONSTANTES Y SÍNTOMAS:';

  @override
  String get diaryDeleteEntryTitle => '¿Eliminar la entrada?';

  @override
  String get diaryDeleteEntryBody =>
      '¿Eliminar esta entrada? El inventario se repondrá automáticamente.';

  @override
  String get diaryOrderReceived => 'Pedido recibido';

  @override
  String diaryEventDiscontinued(String name) {
    return 'Suspendido: $name';
  }

  @override
  String diaryEventPrescribed(String name) {
    return 'Nueva prescripción: $name';
  }

  @override
  String get fieldBatchNumberShort => 'Número de lote';

  @override
  String get fieldNotes => 'Notas';

  @override
  String batchValue(String batch) {
    return 'Lote: $batch';
  }

  @override
  String bpmValue(String value) {
    return '$value lpm';
  }

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get planningTitle => 'Citas y planes';

  @override
  String get planningTabUpcoming => 'Próximas';

  @override
  String get planningTabSchedules => 'Planes';

  @override
  String get planningOverdue => 'Vencidas';

  @override
  String get planningNoUpcoming => 'No hay citas próximas';

  @override
  String get planningNoSchedules => 'No hay planes activos';

  @override
  String planningScheduledFor(String date) {
    return 'Programado para el $date';
  }

  @override
  String get planningDeletePastTitle => '¿Eliminar las citas pasadas?';

  @override
  String get planningDeletePastBody =>
      '¿Eliminar definitivamente todas las citas planificadas pasadas?\n\nEsto no crea ninguna entrada en el diario.';

  @override
  String get planningSkipTitle => '¿Omitir la cita?';

  @override
  String get planningSkipBody =>
      '¿Omitir esta cita? Se marcará como realizada pero no se registrará en el diario.';

  @override
  String get planningSkippedNote => '[Omitida desde la app]';

  @override
  String get planningDeleteAppointmentTitle => '¿Eliminar la cita?';

  @override
  String get planningDeleteAppointmentBody =>
      '¿Quitar esta cita concreta de tu planificación?';

  @override
  String get planningEditAppointmentTitle => 'Editar cita';

  @override
  String get planningDeleteScheduleTitle => '¿Eliminar el plan?';

  @override
  String get planningDeleteScheduleBody =>
      'También se eliminarán todas las citas futuras (no realizadas) de este plan.';

  @override
  String get planningOneOffTitle => 'Cita puntual';

  @override
  String get planningOneOffSubtitle => 'Añadir una sola cita';

  @override
  String get planningRecurringTitle => 'Plan recurrente';

  @override
  String get planningRecurringSubtitle =>
      'Configurar un ritmo de infusión automático';

  @override
  String get planningNeedMedicationsFirst =>
      '¡Añade primero medicamentos a tu inventario!';

  @override
  String get planningScheduleAppointmentTitle => 'Programar cita';

  @override
  String frequencyEveryNDays(int days) {
    return 'Cada $days días';
  }

  @override
  String get frequencyWeekdaysShort => 'Días de la semana';

  @override
  String get fieldDate => 'Fecha';

  @override
  String get fieldPlannedDose => 'Dosis prevista';

  @override
  String fieldDoseWithUnit(String unit) {
    return 'Dosis ($unit)';
  }

  @override
  String doseValue(String amount, String unit) {
    return 'Dosis: $amount $unit';
  }

  @override
  String get actionAdd => 'Añadir';

  @override
  String get actionDeleteAll => 'Eliminar todo';

  @override
  String get actionSkip => 'Omitir';

  @override
  String get actionDone => 'Hecho';

  @override
  String get dashboardTitle => 'Tu resumen';

  @override
  String dashboardSectionLater(int count) {
    return 'PLANIFICADO MÁS ADELANTE ($count)';
  }

  @override
  String dashboardSectionPast(int count) {
    return 'CITAS PASADAS ($count)';
  }

  @override
  String get dashboardNoBackupTitle => 'No hay copia de seguridad activada';

  @override
  String get dashboardNoBackupBody =>
      'Configura la copia de seguridad automática para no perder tus datos.';

  @override
  String get dashboardOrderRecommended => 'Se recomienda pedir';

  @override
  String dashboardLowStockNames(String names) {
    return 'Existencias bajas: $names';
  }

  @override
  String get dashboardOrdersOnTheWay => 'Hay pedidos en camino.';

  @override
  String get dashboardPendingDeliveries => 'ENTREGAS PENDIENTES';

  @override
  String dashboardDeliveryDate(String date) {
    return 'Fecha de entrega: $date';
  }

  @override
  String get dashboardNoDeliveryDate => 'Aún sin fecha';

  @override
  String get dashboardDeleteOrderTitle => '¿Eliminar el pedido?';

  @override
  String get dashboardDeleteOrderBody => '¿Quitar este pedido pendiente?';

  @override
  String get dashboardConfirmDeliveryTitle => '¿Entrega recibida?';

  @override
  String get dashboardConfirmDeliveryBody =>
      '¿Confirmar la recepción de esta entrega? Tu inventario se actualizará automáticamente.';

  @override
  String get dashboardConfirmDeliveryYes => 'Sí, recibida';

  @override
  String get dashboardStockUpdated => '¡Inventario actualizado!';

  @override
  String get dashboardReceived => 'Recibido';

  @override
  String dashboardMissedAt(String time) {
    return 'Omitida (prevista a las $time)';
  }

  @override
  String dashboardTodayAt(String time) {
    return 'Hoy a las $time';
  }

  @override
  String get dashboardMissedInfusion => 'Infusión omitida (prevista para hoy)';

  @override
  String dashboardPlannedToday(String amount, String unit) {
    return 'Previsto hoy ($amount $unit)';
  }

  @override
  String dashboardMarkedDone(String name) {
    return '¡$name hecho!';
  }

  @override
  String get dashboardLogInfusionNow => 'Registrar infusión ahora';

  @override
  String get dashboardAllDoneTitle => '¡Todo hecho!';

  @override
  String get dashboardAllDoneBody => 'No hay tareas pendientes.';

  @override
  String dashboardTreatmentSubtitle(
    String date,
    String time,
    String amount,
    String unit,
  ) {
    return '$date a las $time • $amount $unit';
  }

  @override
  String get dashboardOrphanRemoved => 'Cita huérfana eliminada';

  @override
  String get dashboardUnknownMedication => 'Medicamento desconocido';

  @override
  String dashboardOrphanSubtitle(String date) {
    return 'Previsto $date • medicamento no encontrado';
  }

  @override
  String quantityValue(String amount, String unit) {
    return 'Cantidad: $amount $unit';
  }

  @override
  String get today => 'Hoy';

  @override
  String get actionNo => 'No';

  @override
  String get actionRemove => 'Quitar';

  @override
  String get inventorySectionMedications => 'MEDICAMENTOS';

  @override
  String get inventorySectionStandaloneSupplies => 'MATERIAL INDEPENDIENTE';

  @override
  String get inventoryNoMedications => 'No hay medicamentos añadidos';

  @override
  String inventoryNextTreatment(String date) {
    return 'Próxima: $date';
  }

  @override
  String inventoryLastsUntil(String date) {
    return 'Alcanza hasta: $date';
  }

  @override
  String get inventoryLowStock => '¡Existencias bajas!';

  @override
  String get inventoryOrderOnTheWay => 'Pedido en camino';

  @override
  String inventoryPzn(String pzn) {
    return 'PZN: $pzn';
  }

  @override
  String stockValue(String amount, String unit) {
    return 'Existencias: $amount $unit';
  }

  @override
  String get accessoryEditTitle => 'Editar material fungible';

  @override
  String get accessoryDeleteTitle => '¿Eliminar el material fungible?';

  @override
  String confirmDeleteNamed(String name) {
    return '¿Seguro que quieres eliminar «$name»?';
  }

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldUnit => 'Unidad';

  @override
  String get fieldCurrentStock => 'Existencias actuales';

  @override
  String get fieldPackageSize => 'Tamaño del envase (para pedidos)';

  @override
  String get fieldMinStock => 'Umbral de aviso (existencias)';

  @override
  String get addItemTitle => 'Añadir nuevo elemento';

  @override
  String get fieldCategory => 'Categoría';

  @override
  String get categoryMedication => 'Medicamento';

  @override
  String get categorySupply => 'Material fungible';

  @override
  String get fieldDosageForm => 'Forma farmacéutica';

  @override
  String get dosageFormInfusion => 'Infusión';

  @override
  String get dosageFormPill => 'Comprimido / píldora';

  @override
  String get fieldMedicationName => 'Nombre del medicamento';

  @override
  String get fieldMedicationNameHint => 'p. ej. Hizentra';

  @override
  String get fieldStrength => 'Dosis / concentración';

  @override
  String get fieldStrengthHint => 'p. ej. 20 % o 10 ml';

  @override
  String get fieldPznOptional => 'PZN (opcional)';

  @override
  String get fieldPznHint => 'Número central farmacéutico';

  @override
  String get fieldInitialStock => 'Existencias iniciales';

  @override
  String get fieldDefaultReorderAmount =>
      'Cantidad de reposición predeterminada';

  @override
  String get fieldDefaultReorderAmountHint => 'p. ej. 10 frascos';

  @override
  String get fieldMinStockDays => 'Umbral de aviso (en días)';

  @override
  String get fieldMinStockDaysHint =>
      'Avisar cuando las existencias duren menos de x días';

  @override
  String get fieldMinStockHint =>
      'Avisar cuando las existencias bajen de este valor';

  @override
  String get unitBottle => 'Frasco';

  @override
  String get unitPieces => 'uds';

  @override
  String get validationRequired => 'Campo obligatorio';

  @override
  String get shoppingWizardTitle => 'Asistente de compras';

  @override
  String get shoppingWizardEditTitle => 'Editar pedido';

  @override
  String get shoppingWizardIntro =>
      'Calcula el material fungible que necesitas a partir del pedido de medicamentos que planeas.';

  @override
  String get shoppingWizardEditIntro =>
      'Ajusta tu pedido y el material fungible correspondiente.';

  @override
  String get shoppingWizardSuppliesOnly =>
      'Pedir solo material fungible (sin medicamento)';

  @override
  String shoppingWizardOrderQuantity(String unit) {
    return 'Cantidad del pedido ($unit)';
  }

  @override
  String get shoppingWizardDeliveryDate => 'Fecha de entrega (opcional)';

  @override
  String get shoppingWizardImmediately => 'Justo después de confirmar';

  @override
  String get shoppingWizardSuggestion => 'Material fungible sugerido:';

  @override
  String get shoppingWizardRequired => 'Necesario para este pedido:';

  @override
  String get shoppingWizardOptional => 'Otro material fungible (opcional):';

  @override
  String get shoppingWizardNoSuggestions =>
      'No se ha sugerido material fungible automáticamente.';

  @override
  String get shoppingWizardAddOther => 'Añadir otro material fungible';

  @override
  String get shoppingWizardSaveOrder => 'Guardar pedido';

  @override
  String get shoppingWizardPickSupply => 'Seleccionar material fungible';

  @override
  String get shoppingWizardAlreadyInList => '¡Ya está en la lista!';

  @override
  String get shoppingWizardRecommendedAmount => 'Cantidad recomendada';

  @override
  String get shoppingWizardAdditionallySelected => 'Añadido por ti';

  @override
  String get medDetailsDiscontinue => 'Suspender';

  @override
  String get medDetailsDiscontinueMedication => 'Suspender el medicamento';

  @override
  String get medDetailsReenroll => 'Volver a prescribir';

  @override
  String get medDetailsDeleteCompletely => 'Eliminar por completo';

  @override
  String get medDetailsDeleteFromDatabase =>
      'Eliminar por completo de la base de datos';

  @override
  String medDetailsDiscontinuedSince(String date) {
    return 'Este medicamento está suspendido desde el $date';
  }

  @override
  String get medDetailsSectionStock => 'Existencias y avisos';

  @override
  String get medDetailsSectionSupplies => 'Material fungible vinculado';

  @override
  String get medDetailsSuppliesHint =>
      'Este material se descuenta automáticamente del inventario con cada toma.';

  @override
  String get medDetailsNoSuppliesLinked => 'Aún no hay material vinculado';

  @override
  String get medDetailsLink => 'Vincular';

  @override
  String get medDetailsCreateAndLink => 'Nuevo y vincular';

  @override
  String get medDetailsSectionWorkflow => 'Flujo de registro';

  @override
  String get medDetailsWorkflowHint =>
      'Elige qué campos aparecen al registrar una toma.';

  @override
  String get medDetailsSchedulesHint =>
      'Define el ritmo con el que tomas este medicamento.';

  @override
  String get medDetailsCreateSchedule => 'Crear plan';

  @override
  String get medDetailsPlanOneOff => 'Planificar una cita puntual';

  @override
  String get medDetailsSectionSystemActions => 'Acciones del sistema';

  @override
  String medDetailsRequirement(String amount, String unit) {
    return 'Necesario: $amount $unit';
  }

  @override
  String get medDetailsMustBeOrdered => 'Debe pedirse siempre';

  @override
  String get medDetailsNeedSuppliesFirst => '¡Crea primero material fungible!';

  @override
  String get medDetailsLinkSupplyTitle => 'Vincular material fungible';

  @override
  String get medDetailsPickSupply => 'Elegir material fungible';

  @override
  String get medDetailsCreateSupplyTitle => 'Crear nuevo material fungible';

  @override
  String get medDetailsAlwaysOrder => 'Pedir siempre junto';

  @override
  String get medDetailsAlwaysOrderHint =>
      'Se destaca en el asistente de compras';

  @override
  String get medDetailsEditMedication => 'Editar medicamento';

  @override
  String get medDetailsDeleteTitle => '¿Eliminar el medicamento?';

  @override
  String medDetailsDeleteBody(String name) {
    return '¿Eliminar definitivamente «$name» de la aplicación? Esta acción no se puede deshacer y solo debería usarse para corregir errores. Para finalizar un tratamiento usa «Suspender».';
  }

  @override
  String get medDetailsDiscontinueTitle => '¿Suspender el medicamento?';

  @override
  String medDetailsDiscontinueBody(String name) {
    return '¿Suspender «$name»? Saldrá de la lista activa pero permanecerá en tu historial. Se eliminarán las citas futuras.';
  }

  @override
  String medDetailsTimes(String times) {
    return 'Horas: $times';
  }

  @override
  String get medDetailsTrackBatch => 'Registrar número de lote';

  @override
  String get medDetailsTrackBatchHint =>
      'Escanea un código de barras o escríbelo';

  @override
  String get medDetailsTrackWeight => 'Registrar peso corporal';

  @override
  String get medDetailsTrackWeightHint => 'Registrar tu peso en cada toma';

  @override
  String get medDetailsUseTimer => 'Usar temporizador de toma';

  @override
  String get medDetailsUseTimerHint =>
      'Temporizador de premedicación antes de la toma';

  @override
  String medDetailsConfigureNamed(String name) {
    return 'Configurar $name';
  }

  @override
  String get medDetailsEditSupplyGlobally =>
      'Editar el material de forma global (nombre, unidad)';

  @override
  String get medDetailsStockUpdated => 'Nivel de existencias actualizado';

  @override
  String get medDetailsSaveStock => 'Guardar existencias';

  @override
  String get fieldPerInfusionRequirement => 'Necesario por infusión';

  @override
  String fieldPerInfusionRequirementWithUnit(String unit) {
    return 'Necesario por infusión ($unit)';
  }

  @override
  String get fieldSupplyName => 'Nombre del material fungible';

  @override
  String get fieldUnitWithExample => 'Unidad (p. ej. uds, kit)';

  @override
  String get fieldUnitWithBottleExample => 'Unidad (p. ej. frasco)';

  @override
  String get fieldStrengthWithExample => 'Dosis / concentración (p. ej. 10 g)';

  @override
  String get fieldPzn => 'PZN';

  @override
  String get fieldCurrentStockShort => 'Existencias actuales';

  @override
  String fieldPlannedDoseWithUnit(String unit) {
    return 'Dosis prevista ($unit)';
  }

  @override
  String get actionCreate => 'Crear';

  @override
  String get channelBackgroundService => 'Servicio en segundo plano';

  @override
  String get channelBackgroundServiceDesc =>
      'Se usa para el temporizador y las tareas en segundo plano';

  @override
  String get channelStockWarnings => 'Avisos de existencias';

  @override
  String get channelStockWarningsDesc =>
      'Te avisa cuando los medicamentos o el material se están agotando';

  @override
  String get channelMissedIntakes => 'Tomas omitidas';

  @override
  String get channelMissedIntakesDesc =>
      'Avisos sobre tomas no confirmadas u omitidas';

  @override
  String get channelBackupFailures => 'Errores de copia de seguridad';

  @override
  String get channelBackupFailuresDesc =>
      'Notificaciones sobre problemas con la copia de seguridad automática';

  @override
  String get channelBackupWarnings => 'Avisos de copia de seguridad';

  @override
  String get channelBackupWarningsDesc =>
      'Avisos sobre la configuración de la copia de seguridad';

  @override
  String get channelMedReminders => 'Recordatorios de medicación';

  @override
  String get channelMedRemindersDesc =>
      'Recordatorios de tomas e infusiones planificadas';

  @override
  String get channelPremedTimerDesc =>
      'Temporizador en curso para la premedicación';

  @override
  String get reminderDueTitle => 'Recordatorio: medicamento pendiente';

  @override
  String reminderDueBody(String medication) {
    return 'Es hora de tu toma de $medication.';
  }

  @override
  String get reminderGenericMedication => 'tu medicamento';

  @override
  String get reminderSnoozeTitle => 'Recordatorio (repetición)';

  @override
  String get reminderSnoozeBody => 'Aún no has marcado tu toma como realizada.';

  @override
  String get reminderHourlyTitle => 'Recordatorio (cada hora)';

  @override
  String get reminderHourlyBody => 'No olvides tu toma.';

  @override
  String get notificationCompletedNote => 'Completado desde la notificación';

  @override
  String get notificationSkippedNote => '[Omitida desde la notificación]';

  @override
  String get timerFinishedTitle => 'Premedicación completada';

  @override
  String get timerFinishedBody =>
      'El temporizador ha terminado: la infusión puede comenzar.';

  @override
  String missedIntakesSummary(int count) {
    return '$count tomas sin confirmar';
  }

  @override
  String missedIntakesOpenCount(int count) {
    return '$count pendientes';
  }

  @override
  String get backupReminderTitle => 'Configura la copia de seguridad';

  @override
  String get backupReminderBody =>
      'Tus datos aún no se guardan automáticamente. Toca aquí para configurar la copia de seguridad.';

  @override
  String get backupFailedTitle => 'Copia de seguridad fallida';

  @override
  String backupFailedBody(String error) {
    return 'No se pudo crear la copia de seguridad automática: $error';
  }

  @override
  String get backupDestinationAppFolder =>
      'Carpeta de la app (Archivos → CIDP Buddy → Backups)';

  @override
  String get backupDestinationSafFolder => 'Carpeta en la nube / SAF';

  @override
  String get backupDestinationPickedFolder => 'Carpeta elegida';

  @override
  String backupFolderUnreadable(String path, String error) {
    return 'Carpeta no legible: $path\n($error)';
  }

  @override
  String backupFolderMissing(String path) {
    return 'La carpeta ya no existe: $path';
  }

  @override
  String backupFolderNotWritable(String path, String error) {
    return 'Acceso de escritura denegado: $path\n($error)';
  }

  @override
  String get backupFolderMissingShort => 'La carpeta no existe.';

  @override
  String get backupFolderEmpty => 'La carpeta está vacía.';

  @override
  String get backupSafFolderEmpty => 'La carpeta SAF está vacía.';

  @override
  String backupFolderContents(int count, String names) {
    return 'Encontrados ($count): $names';
  }

  @override
  String backupFolderListFailed(String error) {
    return 'No se pudo listar la carpeta: $error';
  }

  @override
  String backupSafListFailed(String error) {
    return 'No se pudo listar la carpeta SAF: $error';
  }

  @override
  String get backupSafPermissionLost =>
      'Se ha perdido el permiso de la carpeta en la nube. Vuelve a seleccionarla.';

  @override
  String get backupNoDestination =>
      'No se ha seleccionado un destino de copia de seguridad.';

  @override
  String get backupAutoDisabled =>
      'La copia de seguridad automática está desactivada.';

  @override
  String get backupSkippedRecent => 'Omitido: ya existe una copia reciente.';

  @override
  String backupWriteError(String error) {
    return 'Error de escritura: $error';
  }

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsDarkMode => 'Tema oscuro';

  @override
  String get settingsDarkModeHint => 'Alterna entre modo claro y oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Idioma del sistema';

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
  String get settingsSectionAutoBackup => 'Copia de seguridad automática';

  @override
  String get settingsEnableAutoBackup =>
      'Activar la copia de seguridad automática';

  @override
  String get settingsEnableAutoBackupHint =>
      'Guarda tus datos periódicamente en la carpeta elegida';

  @override
  String get settingsBackupNotPossible => 'Copia de seguridad no posible';

  @override
  String get settingsUnknownError => 'Error desconocido';

  @override
  String get settingsPickFolderAgain => 'Elegir la carpeta de nuevo';

  @override
  String get backupBookmarkAccessLost =>
      'CIDP Buddy ya no puede acceder a la carpeta de copias que elegiste. Vuelve a elegirla.';

  @override
  String get settingsBackupsInsideAppTitle =>
      'Las copias están dentro de la app';

  @override
  String get settingsBackupsInsideAppBody =>
      'Se eliminan junto con la aplicación. Elige una carpeta en la app Archivos para que las copias queden fuera de ella, o expórtalas con regularidad.';

  @override
  String get settingsBackupDestination => 'Destino de la copia';

  @override
  String get settingsPickDestination => 'Elegir destino…';

  @override
  String get settingsRunBackupNow => 'Ejecutar copia ahora';

  @override
  String get settingsBackupSucceeded => '¡Copia realizada!';

  @override
  String settingsBackupFailed(String error) {
    return 'Copia fallida: $error';
  }

  @override
  String get settingsExportBackup => 'Exportar copia';

  @override
  String get settingsExportBackupHint =>
      'Guarda la última copia en Archivos o iCloud Drive, por ejemplo';

  @override
  String get settingsNoBackupToExport =>
      'No hay copias para exportar. Ejecuta primero una copia.';

  @override
  String get settingsLastSuccess => 'Último con éxito';

  @override
  String get settingsLastAttempt => 'Último intento';

  @override
  String get settingsRestoreBackup => 'Restaurar copia';

  @override
  String get settingsRestoreBackupHint =>
      'Elige una copia automática para restaurar';

  @override
  String get settingsIosStorageInfo =>
      'Las copias pueden guardarse directamente en una carpeta que elijas en la app Archivos: iCloud Drive, Nextcloud, Dropbox o una unidad conectada. CIDP Buddy sigue escribiendo ahí por su cuenta, y esas copias se conservan aunque elimines la app.\n\nSin una carpeta elegida, las copias se quedan dentro de la app y se eliminan junto con ella, así que tendrás que exportar una copia por tu cuenta.';

  @override
  String get settingsIosPickFolder => 'Elegir carpeta';

  @override
  String get settingsIosUseAppFolder => 'Usar la carpeta de la app';

  @override
  String get settingsDestinationConnectFailed =>
      'No se pudo conectar el destino. Elige otro.';

  @override
  String get settingsDestinationConnected => 'Destino de copia conectado.';

  @override
  String get settingsSectionReminders => 'Recordatorios';

  @override
  String get settingsSnooze => 'Posponer';

  @override
  String settingsSnoozeHint(int minutes) {
    return 'Recordar de nuevo cada $minutes minutos (3×)';
  }

  @override
  String get settingsSnoozeInterval => 'Intervalo de posposición';

  @override
  String settingsSnoozeIntervalCurrent(int minutes) {
    return 'Actualmente: cada $minutes minutos';
  }

  @override
  String settingsEveryNMinutes(int minutes) {
    return 'Cada $minutes minutos';
  }

  @override
  String get settingsHourlyReminder => 'Recordatorio cada hora';

  @override
  String get settingsHourlyReminderHint => 'Recordar en punto';

  @override
  String get settingsQuietHours => 'Horas de silencio';

  @override
  String get settingsQuietHoursTitle => 'Configurar horas de silencio';

  @override
  String settingsQuietHoursHint(String start, String end) {
    return 'Sin recordatorios de $start a $end';
  }

  @override
  String get settingsQuietHoursStart => 'Inicio';

  @override
  String get settingsQuietHoursEnd => 'Fin';

  @override
  String get settingsSectionSystem => 'Sistema y fiabilidad';

  @override
  String get settingsSectionHyqviaTimer => 'Temporizador Hyqvia';

  @override
  String get settingsSuggestTimer => 'Sugerir el temporizador automáticamente';

  @override
  String get settingsSuggestTimerHint =>
      'Ofrecer el temporizador de premedicación en las infusiones de Hyqvia';

  @override
  String get settingsPremedDuration => 'Duración de la premedicación';

  @override
  String settingsCurrentMinutes(int minutes) {
    return 'Actualmente: $minutes minutos';
  }

  @override
  String get settingsSetDefaultDuration =>
      'Establecer la duración predeterminada';

  @override
  String get settingsSectionLegal => 'Aviso legal';

  @override
  String get settingsSectionAbout => 'Acerca de CIDP Buddy';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsBuildTimestamp => 'Marca de tiempo de la compilación';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsPrivacyHint =>
      'Todos los datos se almacenan localmente en este dispositivo.';

  @override
  String get settingsPickBackup => 'Seleccionar copia';

  @override
  String get settingsPickZip => 'Elegir ZIP';

  @override
  String get restoreNoFolderTitle => 'No hay carpeta de copias conectada';

  @override
  String get restoreNoFolderBody =>
      'Elige la carpeta donde están tus copias, por ejemplo la carpeta en la nube de una instalación anterior.';

  @override
  String get restorePickFolder => 'Elegir carpeta de copias';

  @override
  String get restorePickOtherFolder => 'Elegir otra carpeta';

  @override
  String restoreCurrentFolder(String label) {
    return 'Carpeta actual:\n$label';
  }

  @override
  String get restoreAccessLostTitle =>
      'Se perdió el acceso a la carpeta de copias';

  @override
  String get restoreAccessLostBody =>
      'Vuelve a elegir la carpeta para restaurar el permiso. Tus copias existentes no se ven afectadas.';

  @override
  String get restoreNoBackupsTitle => 'No se encontraron copias';

  @override
  String get restoreNoBackupsBody =>
      'La carpeta conectada no contiene copias (archivos llamados «cidpbuddy_backup_…zip» o «igkeeper_backup_…zip»).';

  @override
  String get restoreNoBackupsHint =>
      'Si tus copias están en otra carpeta, selecciónala aquí.';

  @override
  String restoreReadFailed(String error) {
    return 'No se pudieron leer las copias: $error';
  }

  @override
  String get restoreFolderConnectFailed => 'No se pudo conectar la carpeta.';

  @override
  String get restoreConfirmTitle => '¿Restaurar la copia?';

  @override
  String restoreConfirmFile(String name) {
    return '¿Seguro que quieres restaurar el archivo «$name»?';
  }

  @override
  String restoreConfirmDated(String date) {
    return '¿Seguro que quieres restaurar la copia del $date?';
  }

  @override
  String get restoreOverwriteWarning =>
      'ATENCIÓN: todos los datos actuales se sobrescribirán de forma irreversible.';

  @override
  String get restoreFailed => 'Error al restaurar.';

  @override
  String get restoreSucceeded =>
      'Datos restaurados. Reiniciando la aplicación…';

  @override
  String get restoreRestartManually => 'Reinicia la aplicación manualmente.';

  @override
  String get legalLiabilityTitle => 'Aviso de responsabilidad';

  @override
  String get legalLiabilitySubtitle =>
      'No es un producto sanitario ni consejo médico';

  @override
  String get legalBatchDocumentationTitle => 'Documentación de lotes';

  @override
  String get legalBatchDocumentationSubtitle =>
      'No sustituye la documentación legalmente obligatoria';

  @override
  String get legalImprint => 'Aviso legal';

  @override
  String get legalPrivacyPolicy => 'Política de privacidad';

  @override
  String get actionOk => 'OK';

  @override
  String get actionUnderstood => 'Entendido';

  @override
  String get actionRestore => 'Restaurar';

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get reliabilityTitle => 'Comprobación de fiabilidad';

  @override
  String get reliabilitySubtitle => 'Comprueba permisos y ajustes de batería';

  @override
  String get reliabilityNotifications => 'Notificaciones';

  @override
  String get reliabilityNotificationsDesc =>
      'Necesarias para los recordatorios de medicación y el fin del temporizador.';

  @override
  String get reliabilityExactAlarms => 'Alarmas exactas';

  @override
  String get reliabilityExactAlarmsDesc =>
      'Permite que la app lance los recordatorios al segundo.';

  @override
  String get reliabilityBatteryOptimization => 'Optimización de batería';

  @override
  String get reliabilityBatteryOptimizationDesc =>
      'Evita que Android cierre la aplicación en segundo plano.';

  @override
  String get reliabilityBackupDesc =>
      'Guarda tus datos periódicamente, en la nube o localmente.';

  @override
  String get reliabilityBackupStatus => 'Estado de la copia';

  @override
  String get reliabilityBackupUpToDate => 'Tu última copia está al día.';

  @override
  String get reliabilityBackupStale =>
      'Tu última copia está desactualizada o ha fallado.';

  @override
  String get reliabilityAllGood => '¡Todo correcto!';

  @override
  String get reliabilityAllGoodBody =>
      'Tus ajustes son óptimos para la máxima fiabilidad.';

  @override
  String get reliabilityActionNeeded => 'Se requiere acción';

  @override
  String get reliabilityActionNeededBody =>
      'Algunos ajustes limitan la fiabilidad de los recordatorios.';

  @override
  String get reliabilityFix => 'Corregir el ajuste';

  @override
  String get reliabilityFooterHint =>
      'Nota: las comprobaciones se actualizan automáticamente al volver de los ajustes del sistema.';

  @override
  String get reliabilityRefresh => 'Actualizar el estado ahora';

  @override
  String get legalBatchDocumentationLong =>
      'CIDP Buddy guarda números de lote, fotos y notas únicamente como recordatorio personal en tu dispositivo.\n\nEstos registros no sustituyen la documentación de lotes exigida por la ley alemana de transfusiones (TFG) ni por las normas nacionales que te sean aplicables. Esa obligación sigue correspondiendo a tu médico o al centro que te trata.\n\nMantén por tanto la documentación obligatoria igual que antes, aunque registres también los datos en esta aplicación.';

  @override
  String get legalLiabilityBody =>
      'CIDP Buddy es una herramienta de organización privada y no un producto sanitario. La aplicación sirve únicamente para facilitarte la gestión de citas, existencias y notas.\n\nLa aplicación no constituye consejo médico y no sustituye el diagnóstico, el tratamiento ni las recomendaciones del personal sanitario. Nunca tomes decisiones sobre tu tratamiento, dosis o medicación basándote solo en esta aplicación. Si tienes molestias, acude a tu médico; en caso de emergencia, llama a los servicios de urgencia.\n\nTodos los cálculos (duración de existencias, avisos de stock bajo, citas planificadas, etc.) se basan en los datos que has introducido y pueden ser erróneos. Los recordatorios y notificaciones pueden llegar tarde, repetirse o no llegar debido a funciones de ahorro de energía, ajustes del sistema o fallos del sistema operativo. No dependas únicamente de la aplicación.\n\nTodos los datos permanecen solo en tu dispositivo. Su copia de seguridad es responsabilidad tuya; no se asume ninguna responsabilidad por la pérdida de datos.\n\nEl uso es bajo tu propia responsabilidad. Se excluye, en la medida permitida por la ley, toda responsabilidad por daños derivados del uso o la indisponibilidad de la aplicación.';

  @override
  String get shareBackupSubject => 'Copia de seguridad de CIDP Buddy';

  @override
  String shareBackupText(String date) {
    return 'Copia de seguridad de la base de datos de CIDP Buddy del $date';
  }

  @override
  String get tooltipOpenStatistics => 'Estadísticas';

  @override
  String get tooltipEditOrder => 'Editar pedido';

  @override
  String get tooltipDeleteOrder => 'Eliminar pedido';

  @override
  String get tooltipEditInfusionLog => 'Editar entrada de infusión';

  @override
  String get tooltipDeleteInfusionLog => 'Eliminar entrada de infusión';

  @override
  String get tooltipEditSupply => 'Editar material fungible';

  @override
  String get tooltipDeleteSupply => 'Eliminar material fungible';

  @override
  String get tooltipShowDetails => 'Mostrar detalles';

  @override
  String get tooltipEditMedication => 'Editar medicamento';

  @override
  String get tooltipLinkSettings => 'Ajustes del vínculo';

  @override
  String get tooltipUnlinkSupply =>
      'Quitar el material fungible de este medicamento';

  @override
  String get tooltipEditSchedule => 'Editar plan';

  @override
  String get tooltipDeleteSchedule => 'Eliminar plan';

  @override
  String get tooltipClearDate => 'Borrar la fecha';

  @override
  String get tooltipRemoveIntakeTime => 'Quitar la hora';

  @override
  String get tooltipRemovePhoto => 'Quitar la foto';

  @override
  String get tooltipTimerReset => 'Reiniciar el temporizador';

  @override
  String get tooltipTimerStart => 'Iniciar el temporizador';

  @override
  String get tooltipTimerPause => 'Pausar el temporizador';

  @override
  String get tooltipTimerDuration => 'Definir la duración';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String get actionKeepEditing => 'Seguir editando';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String dashboardLogInfusionFor(String name) {
    return 'Registrar ahora la infusión de $name';
  }

  @override
  String dashboardMarkDoneFor(String name) {
    return 'Marcar $name como tomado';
  }

  @override
  String dashboardRemoveFor(String name) {
    return 'Quitar $name del plan';
  }

  @override
  String symptomScoreLabel(String symptom, int score) {
    return '$symptom: $score de 10';
  }

  @override
  String get backupDestinationConfigured =>
      'Destino de la copia de seguridad configurado';

  @override
  String get reliabilityStatusOk => 'OK';

  @override
  String get reliabilityStatusFailed => 'Acción requerida';

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
  String get savedInfusion => 'Infusión registrada';

  @override
  String get savedDiaryEntry => 'Entrada guardada';

  @override
  String get savedSchedule => 'Plan guardado';

  @override
  String get savedOrder => 'Pedido guardado';

  @override
  String get savedMedication => 'Medicamento guardado';

  @override
  String get deletedGeneric => 'Eliminado';

  @override
  String saveFailed(String error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get discardChangesTitle => '¿Descartar los cambios?';

  @override
  String get discardChangesBody => 'Tus cambios aún no se han guardado.';

  @override
  String get errorLoadingData => 'No se pudieron cargar los datos.';

  @override
  String get medDetailsNotFound => 'Este medicamento ya no existe.';

  @override
  String get confirmUnlinkSupplyTitle => '¿Quitar el material fungible?';

  @override
  String confirmUnlinkSupplyBody(String name) {
    return '$name ya no se pedirá junto con este medicamento.';
  }

  @override
  String get confirmReenrollTitle => '¿Volver a prescribir el medicamento?';

  @override
  String confirmReenrollBody(String name) {
    return '$name vuelve a la lista activa; sus planes y recordatorios se vuelven a crear.';
  }

  @override
  String get validationEnterNumber => 'Introduce un número.';

  @override
  String get validationPositiveNumber => 'Introduce un número mayor que 0.';

  @override
  String get inventoryAddFirstMedicationHint =>
      'Añade tu primer medicamento con el botón de abajo.';

  @override
  String get savedSupply => 'Material fungible guardado';

  @override
  String reenrolledMedication(String name) {
    return '$name vuelve a estar activo';
  }

  @override
  String get restoringPleaseWait =>
      'Restaurando la copia de seguridad, espera…';

  @override
  String get loading => 'Cargando…';
}
