import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sos_bebe_app/localizations/1_delegate.dart';

import 'package:sos_bebe_app/localizations/ro.dart' as romanian;

class LocalizationsApp {
  LocalizationsApp(this.locale);

  final Locale locale;

  get universalSave => null;

  static LocalizationsApp? of(BuildContext context) {
    return Localizations.of<LocalizationsApp>(context, LocalizationsApp);
  }

  static const LocalizationsDelegate delegate = AppLocalizationsDelegate();

  static final Map<String, Map<String, dynamic>> _localizedValues = {
    'ro': romanian.values,
    /*
    'en': english.values,
    'fr': french.values,
    'it': italian.values
    */
  };

  String get universalInapoi {
    return _localizedValues[locale.languageCode]!['universal']['inapoi'];
  }

  // adauga_metoda_plata

  String get adaugaMetodaPlataIntroducetiDateleCardului {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['introduceti_datele_cardului'];
  }

  String get adaugaMetodaPlataCardHolderTitle {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['card_holder_title'];
  }

  String get adaugaMetodaPlataValidThruTitle {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['valid_thru_title'];
  }

  String get adaugaMetodaPlataExpiryDate {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['expiry_date'];
  }

  String get adaugaMetodaPlataCardHolderHint {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['card_holder_hint'];
  }

  String get adaugaMetodaPlataCardNumberText {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['card_number_text'];
  }

  String get adaugaMetodaPlataAdresaWeb {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['adresa_web'];
  }

  String get adaugaMetodaPlataCVV {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']['cvv'];
  }

  String get adaugaMetodaPlataCardNumberTitle {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['card_number_title'];
  }

  String get adaugaMetodaPlataCardNumberHint {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['card_number_hint'];
  }

  String get adaugaMetodaPlataNecompletat {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['necompletat'];
  }

  String get adaugaMetodaPlataIncorect {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['incorect'];
  }

  String get adaugaMetodaPlataNume {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['nume'];
  }

  String get adaugaMetodaPlataCardHolderNameHint {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['card_holder_name_hint'];
  }

  String get adaugaMetodaPlataCVVTitle {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['cvv_title'];
  }

  String get adaugaMetodaPlataCardCVV {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['card_cvv'];
  }

  String get adaugaMetodaPlataExpiredDate {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['expired_date'];
  }

  String get adaugaMetodaPlataExpiryDateHint {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['expiry_date_hint'];
  }

  String get adaugaMetodaPlataNecompletata {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['necompletata'];
  }

  String get adaugaMetodaPlataIncorecta {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['incorecta'];
  }

  String get adaugaMetodaPlataPlataAdauga {
    return _localizedValues[locale.languageCode]!['adauga_metoda_plata']
        ['plata_adauga'];
  }

  // apel_video_pacient_screen

  String get apelVideoPacientVaRugamAsteptati {
    return _localizedValues[locale.languageCode]!['apel_video_pacient']
        ['va_rugam_asteptati'];
  }

  // confirmare_screen

  String get confirmareTitlu {
    return _localizedValues[locale.languageCode]!['confirmare']
        ['confirmare_titlu'];
  }

  String get confirmareMasterCard {
    return _localizedValues[locale.languageCode]!['confirmare']['master_card'];
  }

  String get confirmareCardNumber {
    return _localizedValues[locale.languageCode]!['confirmare']['card_number'];
  }

  String get confirmareTipPlata {
    return _localizedValues[locale.languageCode]!['confirmare']['tip_plata'];
  }

  String get confirmareUser {
    return _localizedValues[locale.languageCode]!['confirmare']['user'];
  }

  String get confirmareBanca {
    return _localizedValues[locale.languageCode]!['confirmare']['banca'];
  }

  String get confirmareStripe {
    return _localizedValues[locale.languageCode]!['confirmare']['stripe'];
  }

  String get confirmareAdaugaMetodaDePlata {
    return _localizedValues[locale.languageCode]!['confirmare']
        ['adauga_metoda_de_plata'];
  }

  // confirmare_servicii

  String get confirmareServiciiTitlu {
    return _localizedValues[locale.languageCode]!['confirmare_servicii']
        ['confirma_plata'];
  }

  String get confirmareServiciiServiciiPediatrie {
    return _localizedValues[locale.languageCode]!['confirmare_servicii']
        ['servicii_pediatrie'];
  }

  String get confirmareServiciiPrimitiRecomandareReteta {
    return _localizedValues[locale.languageCode]!['confirmare_servicii']
        ['primiti_recomandare_reteta'];
  }

  String get confirmareServiciiRON {
    return _localizedValues[locale.languageCode]!['confirmare_servicii']['ron'];
  }

  String get confirmareServiciiSubtotal {
    return _localizedValues[locale.languageCode]!['confirmare_servicii']
        ['subtotal'];
  }

  String get confirmareServiciiTotal {
    return _localizedValues[locale.languageCode]!['confirmare_servicii']
        ['total'];
  }

  String get confirmareServiciiConfirmaPlataButon {
    return _localizedValues[locale.languageCode]!['confirmare_servicii']
        ['confirma_plata_buton'];
  }

  // doctor_selection

  String get doctorSelectionSearchHint {
    return _localizedValues[locale.languageCode]!['doctor_selection']
        ['search_hint'];
  }

  String get doctorSelectionDoctorTitle {
    return _localizedValues[locale.languageCode]!['doctor_selection']
        ['doctor_title'];
  }

  String get doctorSelectionDoctorSpital {
    return _localizedValues[locale.languageCode]!['doctor_selection']
        ['doctor_spital'];
  }

  String get doctorSelectionDoctorSpecialitateFunctie {
    return _localizedValues[locale.languageCode]!['doctor_selection']
        ['doctor_specialitate_functie'];
  }

  String get doctorSelectionDoctorLocalitate {
    return _localizedValues[locale.languageCode]!['doctor_selection']
        ['doctor_localitate'];
  }

  String get doctorSelectionProcentUseriMultumiti {
    return _localizedValues[locale.languageCode]!['doctor_selection']
        ['procent_useri_multumiti'];
  }

  String get doctorSelectionPerioada {
    return _localizedValues[locale.languageCode]!['doctor_selection']
        ['perioada'];
  }

  // editare_cont

  String get editareContActualizareFinalizataCuSucces {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['actualizare_finalizata_cu_succes'];
  }

  String get editareContApelInvalid {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['apel_invalid'];
  }

  String get editareContDateleNuAuPututFiActualizate {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['datele_nu_au_putut_fi_actualizate'];
  }

  String get editareContInformatiiInsuficiente {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['informatii_insuficiente'];
  }

  String get editareContEroareLaExecutiaMetodei {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['eroare_la_executia_metodei'];
  }

  String get editareContProfilulMeuTitlu {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['profilul_meu_titlu'];
  }

  String get editareContEmailHint {
    return _localizedValues[locale.languageCode]!['editare_cont']['email_hint'];
  }

  String get editareContIntroducetiEmailValid {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['introduceti_email_valid'];
  }

  String get editareContTelefonHint {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['telefon_hint'];
  }

  String get editareContIntroducetiTelefonValid {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['introduceti_telefon_valid'];
  }

  String get editareContUserHint {
    return _localizedValues[locale.languageCode]!['editare_cont']['user_hint'];
  }

  String get editareContIntroducetiUtilizator {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['introduceti_utilizator'];
  }

  String get editareContNumeleCompletHint {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['numele_complet_hint'];
  }

  String get editareContIntroducetiNumeleComplet {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['introduceti_numele_complet'];
  }

  String get editareContResetareParola {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['resetare_parola'];
  }

  String get editareContVaRugamIntroducetiParola {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['va_rugam_introduceti_parola'];
  }

  String get editareContParolaTrebuieSaContina {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['parola_trebuie_sa_contina'];
  }

  String get editareContSalvareDate {
    return _localizedValues[locale.languageCode]!['editare_cont']
        ['salvare_date'];
  }

  // error_pacient

  String get errorPacientOopsText {
    return _localizedValues[locale.languageCode]!['error_pacient']['oops_text'];
  }

  String get errorPacientDetaliiText {
    return _localizedValues[locale.languageCode]!['error_pacient']
        ['detalii_text'];
  }

  String get errorPacientResetareParola {
    return _localizedValues[locale.languageCode]!['error_pacient']
        ['resetare_parola'];
  }

  // factura

  String get facturaDateFormat {
    return _localizedValues[locale.languageCode]!['factura']['date_format'];
  }

  String get facturaLimba {
    return _localizedValues[locale.languageCode]!['factura']['limba'];
  }

  String get facturaFacturaTitlu {
    return _localizedValues[locale.languageCode]!['factura']['factura_titlu'];
  }

  String get facturaNumeFactura {
    return _localizedValues[locale.languageCode]!['factura']['nume_factura'];
  }

  String get facturaEmailEmitent {
    return _localizedValues[locale.languageCode]!['factura']['email_emitent'];
  }

  String get facturaTelefonEmitent {
    return _localizedValues[locale.languageCode]!['factura']['telefon_emitent'];
  }

  String get facturaTitluPentruBeneficiar {
    return _localizedValues[locale.languageCode]!['factura']
        ['titlu_pentru_beneficiar'];
  }

  String get facturaUserId {
    return _localizedValues[locale.languageCode]!['factura']['user_id'];
  }

  String get facturaEmailBeneficiar {
    return _localizedValues[locale.languageCode]!['factura']
        ['email_beneficiar'];
  }

  String get facturaTelefonBeneficiar {
    return _localizedValues[locale.languageCode]!['factura']
        ['telefon_beneficiar'];
  }

  String get facturaDataPlatiiTitlu {
    return _localizedValues[locale.languageCode]!['factura']
        ['data_platii_titlu'];
  }

  String get facturaDataPlatiiNume {
    return _localizedValues[locale.languageCode]!['factura']
        ['data_platii_nume'];
  }

  String get facturaProcesata {
    return _localizedValues[locale.languageCode]!['factura']['procesata'];
  }

  String get facturaDetaliiFactura {
    return _localizedValues[locale.languageCode]!['factura']['detalii_factura'];
  }

  String get facturaServicii {
    return _localizedValues[locale.languageCode]!['factura']['servicii'];
  }

  String get facturaNumar {
    return _localizedValues[locale.languageCode]!['factura']['numar'];
  }

  String get facturaSerie {
    return _localizedValues[locale.languageCode]!['factura']['serie'];
  }

  String get facturaValoareCuTVA {
    return _localizedValues[locale.languageCode]!['factura']['valoare_cu_tva'];
  }

  String get facturaValoareTVA {
    return _localizedValues[locale.languageCode]!['factura']['valoare_tva'];
  }

  String get facturaValoareFaraTVA {
    return _localizedValues[locale.languageCode]!['factura']
        ['valoare_fara_tva'];
  }

  String get facturaButonDownloadPdf {
    return _localizedValues[locale.languageCode]!['factura']
        ['buton_download_pdf'];
  }

  String get facturaTrimiteTestimonial {
    return _localizedValues[locale.languageCode]!['factura']
        ['trimite_testimonial'];
  }

  // intro

  String get introGasesteDoctorPediatru {
    return _localizedValues[locale.languageCode]!['intro']
        ['gaseste_doctor_pediatru'];
  }

  String get introGasitiMediciSpecialisti {
    return _localizedValues[locale.languageCode]!['intro']
        ['gasiti_medici_specialisti'];
  }

  String get introContinua {
    return _localizedValues[locale.languageCode]!['intro']['continua'];
  }

  // login

  String get loginLoginCuSucces {
    return _localizedValues[locale.languageCode]!['login']['login_cu_succes'];
  }

  String get loginIntroducetiParola {
    return _localizedValues[locale.languageCode]!['login']
        ['mesaj_introduceti_parola'];
  }

  String get loginEroareReintroducetiUserParola {
    return _localizedValues[locale.languageCode]!['login']
        ['eroare_reintroduceti_user_parola'];
  }

  String get loginTelefonEmailUtilizatorHint {
    return _localizedValues[locale.languageCode]!['login']
        ['telefon_email_utilizator_hint'];
  }

  String get loginMesajIntroducetiUtilizatorEmailTelefon {
    return _localizedValues[locale.languageCode]!['login']
        ['mesaj_introduceti_utilizator_email_telefon'];
  }

  String get loginParola {
    return _localizedValues[locale.languageCode]!['login']['parola'];
  }

  String get loginMesajIntroducetiParolaNoua {
    return _localizedValues[locale.languageCode]!['login']
        ['mesaj_introduceti_parola_noua'];
  }

  String get loginMesajParolaCelPutin {
    return _localizedValues[locale.languageCode]!['login']
        ['mesaj_parola_cel_putin'];
  }

  String get loginAiUitatParola {
    return _localizedValues[locale.languageCode]!['login']['ai_uitat_parola'];
  }

  String get loginConectare {
    return _localizedValues[locale.languageCode]!['login']['conectare'];
  }

  String get loginOr {
    return _localizedValues[locale.languageCode]!['login']['or'];
  }

  String get loginConectareCuFacebook {
    return _localizedValues[locale.languageCode]!['login']
        ['conectare_cu_facebook'];
  }

  String get loginConectareCuGoogle {
    return _localizedValues[locale.languageCode]!['login']
        ['conectare_cu_google'];
  }

  String get loginNuAiCont {
    return _localizedValues[locale.languageCode]!['login']['nu_ai_cont'];
  }

  String get loginInscrieTe {
    return _localizedValues[locale.languageCode]!['login']['inscrie_te'];
  }

  // main

  String get mainTitlu {
    return _localizedValues[locale.languageCode]!['main']['titlu'];
  }

  // parola_noua_pacient

  String get parolaNouaPacientMesajParolaResetataCuSucces {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['mesaj_parola_resetata_cu_succes'];
  }

  String get parolaNouaPacientApelInvalid {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['apel_invalid'];
  }

  String get parolaNouaPacientEroareResetareParola {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['eroare_resetare_parola'];
  }

  String get parolaNouaPacientInformatiiInsuficiente {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['informatii_insuficiente'];
  }

  String get parolaNouaPacientAAparutOEroare {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['a_aparut_o_eroare'];
  }

  String get parolaNouaPacientParolaNoua {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['parola_noua'];
  }

  String get parolaNouaPacientReseteazaParolaText {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['reseteaza_parola_text'];
  }

  String get parolaNouaPacientParolaHint {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['parola_hint'];
  }

  String get parolaNouaPacientIntroducetiParolaNoua {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['introduceti_parola_noua'];
  }

  String get parolaNouaPacientParolaCelPutin {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['parola_cel_putin'];
  }

  String get parolaNouaPacientParolaAceeasi {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['parola_aceeasi'];
  }

  String get parolaNouaPacientRepetaNouaParola {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['repeta_noua_parola'];
  }

  String get parolaNouaPacientSeIncearcaResetareaParolei {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['se_incearca_resetarea_parolei'];
  }

  String get parolaNouaPacientConfirma {
    return _localizedValues[locale.languageCode]!['parola_noua_pacient']
        ['confirma'];
  }

  // plata_esuata

  String get plataEsuataTitlu {
    return _localizedValues[locale.languageCode]!['plata_esuata']
        ['plata_esuata_titlu'];
  }

  String get plataEsuataFonduriInsuficiente {
    return _localizedValues[locale.languageCode]!['plata_esuata']
        ['fonduri_insuficiente'];
  }

  String get plataEsuataContinua {
    return _localizedValues[locale.languageCode]!['plata_esuata']['continua'];
  }

  // plata_succes

  String get plataSuccesTitlu {
    return _localizedValues[locale.languageCode]!['plata_succes']
        ['plata_succes_titlu'];
  }

  String get plataSuccesVaMultumimDetalii {
    return _localizedValues[locale.languageCode]!['plata_succes']
        ['va_multumim_detalii'];
  }

  String get plataSuccesVaMultumimSimplu {
    return _localizedValues[locale.languageCode]!['plata_succes']
        ['va_multumim_simplu'];
  }

  String get plataSuccesVeiFiRedirectionat {
    return _localizedValues[locale.languageCode]!['plata_succes']
        ['vei_fi_redirectionat'];
  }

  // plati

  String get platiDateFormat {
    return _localizedValues[locale.languageCode]!['plati']['date_format'];
  }

  String get platiLimba {
    return _localizedValues[locale.languageCode]!['plati']['limba'];
  }

  String get platiTitlu {
    return _localizedValues[locale.languageCode]!['plati']['titlu'];
  }

  String get platiDataPlatiiTitlu {
    return _localizedValues[locale.languageCode]!['plati']['data_platii_titlu'];
  }

  String get platiSumaPlatiiTitlu {
    return _localizedValues[locale.languageCode]!['plati']['suma_platii_titlu'];
  }

  // profil_doctor_disponibilitate_servicii

  String get profilDoctorDisponibilitateServiciiDateFormat {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['date_format'];
  }

  String get profilDoctorDisponibilitateServiciiLimba {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['limba'];
  }

  String get profilDoctorDisponibilitateServiciiMonedaRon {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['moneda_ron'];
  }

  String get profilDoctorDisponibilitateServiciiMonedaEuro {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['moneda_euro'];
  }

  String get profilDoctorDisponibilitateServiciiScrieIntrebare {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['scrie_intrebare'];
  }

  String get profilDoctorDisponibilitateServiciiSunaAcum {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['suna_acum'];
  }

  String get profilDoctorDisponibilitateServiciiPrimitiRecomandare {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['primiti_recomandare'];
  }

  String get profilDoctorDisponibilitateServiciiSumarTitlu {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['sumar_titlu'];
  }

  String get profilDoctorDisponibilitateServiciiTitluProfestional {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['titlu_profestional'];
  }

  String get profilDoctorDisponibilitateServiciiSpecializare {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['specializare'];
  }

  String get profilDoctorDisponibilitateServiciiExperienta {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['experienta'];
  }

  String get profilDoctorDisponibilitateServiciiLocDeMunca {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['loc_de_munca'];
  }

  String get profilDoctorDisponibilitateServiciiActivitate {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['activitate'];
  }

  String get profilDoctorDisponibilitateServiciiUtilizatoriMultumiti {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['utilizatori_multumiti'];
  }

  String get profilDoctorDisponibilitateServiciiAmAjutat {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['am_ajutat'];
  }

  String get profilDoctorDisponibilitateServiciiPacienti {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['pacienti'];
  }

  String get profilDoctorDisponibilitateServiciiAiAplicatiei {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['ai_aplicatiei'];
  }

  String get profilDoctorDisponibilitateServiciiTestimoniale {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['testimoniale'];
  }

  String get profilDoctorDisponibilitateServiciiRecenzii {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['recenzii'];
  }

  String get profilDoctorDisponibilitateServiciiInConsultatie {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['in_consultatie'];
  }

  String get profilDoctorDisponibilitateServiciiRating {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['rating'];
  }

  String get profilDoctorDisponibilitateServiciiMedicAdaugatCuSucces {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['medic_adaugat_cu_succes'];
  }

  String get profilDoctorDisponibilitateServiciiMedicAdaugatApelInvalid {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['medic_adaugat_apel_invalid'];
  }

  String get profilDoctorDisponibilitateServiciiMedicNeadaugat {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['medic_neadaugat'];
  }

  String
      get profilDoctorDisponibilitateServiciiMedicAdaugatInformatiiInsuficiente {
    return _localizedValues[locale.languageCode]![
            'profil_doctor_disponibilitate_servicii']
        ['medic_adaugat_informatii_insuficiente'];
  }

  String get profilDoctorDisponibilitateServiciiMedicAdaugatAAparutOEroare {
    return _localizedValues[locale.languageCode]![
            'profil_doctor_disponibilitate_servicii']
        ['medic_adaugat_a_aparut_o_eroare'];
  }

  String get profilDoctorDisponibilitateServiciiMedicScosCuSucces {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['medic_scos_cu_succes'];
  }

  String get profilDoctorDisponibilitateServiciiMedicScosApelInvalid {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['medic_scos_apel_invalid'];
  }

  String get profilDoctorDisponibilitateServiciiMedicNescos {
    return _localizedValues[locale.languageCode]![
        'profil_doctor_disponibilitate_servicii']['medic_nescos'];
  }

  String
      get profilDoctorDisponibilitateServiciiMedicScosInformatiiInsuficiente {
    return _localizedValues[locale.languageCode]![
            'profil_doctor_disponibilitate_servicii']
        ['medic_scos_informatii_insuficiente'];
  }

  String get profilDoctorDisponibilitateServiciiMedicScosAAparutOEroare {
    return _localizedValues[locale.languageCode]![
            'profil_doctor_disponibilitate_servicii']
        ['medic_scos_a_aparut_o_eroare'];
  }

  // profil_pacient

  String get profilPacientCodTrimisCuSucces {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['cod_trimis_cu_succes'];
  }

  String get profilPacientApelInvalid {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['apel_invalid'];
  }

  String get profilPacientContInexistent {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['cont_inexistent'];
  }

  String get profilPacientContExistentFaraDateContact {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['cont_existent_fara_date_contact'];
  }

  String get profilPacientAAparutOEroare {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['a_aparut_o_eroare'];
  }

  String get profilPacientProfilulMeuTitlu {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['profilul_meu_titlu'];
  }

  String get profilPacientEditareCont {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['editare_cont'];
  }

  String get profilPacientDoctoriSalvati {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['doctori_salvati'];
  }

  String get profilPacientNuExistaFacturiDeAfisat {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['nu_exista_facturi_de_afisat'];
  }

  String get profilPacientVeziPlati {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['vezi_plati'];
  }

  String get profilPacientGDPR {
    return _localizedValues[locale.languageCode]!['profil_pacient']['GDPR'];
  }

  String get profilPacientDezactivareCont {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['dezactivare_cont'];
  }

  String get profilPacientDeconectare {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['deconectare'];
  }

  String get profilPacientTermeniSiConditii {
    return _localizedValues[locale.languageCode]!['profil_pacient']
        ['termeni_si_conditii'];
  }

  // questionare

  String get questionareDateChestionarTrimiseCuSucces {
    return _localizedValues[locale.languageCode]!['questionare']
        ['date_chestionar_trimise_cu_succes'];
  }

  String get questionareApelInvalid {
    return _localizedValues[locale.languageCode]!['questionare']
        ['apel_invalid'];
  }

  String get questionareDateleNuAuPututFiTrimise {
    return _localizedValues[locale.languageCode]!['questionare']
        ['datele_nu_au_putut_fi_trimise'];
  }

  String get questionareInformatiiInsuficiente {
    return _localizedValues[locale.languageCode]!['questionare']
        ['informatii_insuficiente'];
  }

  String get questionareAAparutOEroare {
    return _localizedValues[locale.languageCode]!['questionare']
        ['a_aparut_o_eroare'];
  }

  String get questionareChestionar {
    return _localizedValues[locale.languageCode]!['questionare']['chestionar'];
  }

  String get questionareNumePrenumePacient {
    return _localizedValues[locale.languageCode]!['questionare']
        ['nume_prenume_pacient'];
  }

  String get questionareNumeCopilHint {
    return _localizedValues[locale.languageCode]!['questionare']
        ['nume_copil_hint'];
  }

  String get questionareIntroducetiNumePrenumePacient {
    return _localizedValues[locale.languageCode]!['questionare']
        ['introduceti_nume_prenume_pacient'];
  }

  String get questionareDataNastere {
    return _localizedValues[locale.languageCode]!['questionare']
        ['data_nastere'];
  }

  String get questionareDateFormat {
    return _localizedValues[locale.languageCode]!['questionare']['date_format'];
  }

  String get questionareDataNastereHint {
    return _localizedValues[locale.languageCode]!['questionare']
        ['data_nastere_hint'];
  }

  String get questionareIntroducetiDataNastere {
    return _localizedValues[locale.languageCode]!['questionare']
        ['introduceti_data_nastere'];
  }

  String get questionareGreutate {
    return _localizedValues[locale.languageCode]!['questionare']['greutate'];
  }

  String get questionareNumarKilograme {
    return _localizedValues[locale.languageCode]!['questionare']
        ['numar_kilograme'];
  }

  String get questionareIntroducetiNumarKilograme {
    return _localizedValues[locale.languageCode]!['questionare']
        ['introduceti_numar_kilograme'];
  }

  String get questionareAlergicLaMedicament {
    return _localizedValues[locale.languageCode]!['questionare']
        ['alergic_la_medicament'];
  }

  String get questionareLaCeMedicamentEsteAlergic {
    return _localizedValues[locale.languageCode]!['questionare']
        ['la_ce_medicament_este_alergic'];
  }

  String get questionareAlergicLaParacetamol {
    return _localizedValues[locale.languageCode]!['questionare']
        ['alergic_la_paracetamol'];
  }

  String get questionareSimptomePacient {
    return _localizedValues[locale.languageCode]!['questionare']
        ['simptome_pacient'];
  }

  String get questionareFebra {
    return _localizedValues[locale.languageCode]!['questionare']['febra'];
  }

  String get questionareTuse {
    return _localizedValues[locale.languageCode]!['questionare']['tuse'];
  }

  String get questionareDificultatiRespiratorii {
    return _localizedValues[locale.languageCode]!['questionare']
        ['dificultati_respiratorii'];
  }

  String get questionareAstenie {
    return _localizedValues[locale.languageCode]!['questionare']['astenie'];
  }

  String get questionareCefalee {
    return _localizedValues[locale.languageCode]!['questionare']['cefalee'];
  }

  String get questionareDureriInGat {
    return _localizedValues[locale.languageCode]!['questionare']
        ['dureri_in_gat'];
  }

  String get questionareGreturiVarsaturi {
    return _localizedValues[locale.languageCode]!['questionare']
        ['greturi_varsaturi'];
  }

  String get questionareDiareeConstipatie {
    return _localizedValues[locale.languageCode]!['questionare']
        ['diaree_constipatie'];
  }

  String get questionareRefuzulAlimentatie {
    return _localizedValues[locale.languageCode]!['questionare']
        ['refuzul_alimentatie'];
  }

  String get questionareIritatiiPiele {
    return _localizedValues[locale.languageCode]!['questionare']
        ['iritatii_piele'];
  }

  String get questionareNasInfundat {
    return _localizedValues[locale.languageCode]!['questionare']
        ['nas_infundat'];
  }

  String get questionareRinoree {
    return _localizedValues[locale.languageCode]!['questionare']['rinoree'];
  }

  String get questionareTrimiteChestionarul {
    return _localizedValues[locale.languageCode]!['questionare']
        ['trimite_chestionarul'];
  }

  // raspunde_intrebare_doar_chat

  String get raspundeIntrebareDoarChatApelMesaje {
    return _localizedValues[locale.languageCode]![
        'raspunde_intrebare_doar_chat']['apel_mesaje'];
  }

  String get raspundeIntrebareDoarChatNumePacient {
    return _localizedValues[locale.languageCode]![
        'raspunde_intrebare_doar_chat']['nume_pacient'];
  }

  String get raspundeIntrebareDoarChatTrimiteMedia {
    return _localizedValues[locale.languageCode]![
        'raspunde_intrebare_doar_chat']['trimite_media'];
  }

  String get raspundeIntrebareDoarChatNuAvetiNiciUnMesaj {
    return _localizedValues[locale.languageCode]![
        'raspunde_intrebare_doar_chat']['nu_aveti_nici_un_mesaj'];
  }

  String get raspundeIntrebareDoarChatFisierMesajChat {
    return _localizedValues[locale.languageCode]![
        'raspunde_intrebare_doar_chat']['fisier_mesaj_chat'];
  }

  String get raspundeIntrebareDoarChatScrieMesaj {
    return _localizedValues[locale.languageCode]![
        'raspunde_intrebare_doar_chat']['scrie_mesaj'];
  }

  String get raspundeIntrebareDoarChatTrimite {
    return _localizedValues[locale.languageCode]![
        'raspunde_intrebare_doar_chat']['trimite'];
  }

  String get raspundeIntrebareDoarChatMesajeNecitite {
    return _localizedValues[locale.languageCode]![
        'raspunde_intrebare_doar_chat']['mesaje_necitite'];
  }

  // raspunde_intrebare_medic

  String get raspundeIntrebareMedicImagine {
    return _localizedValues[locale.languageCode]!['raspunde_intrebare_medic']
        ['imagine'];
  }

  String get raspundeIntrebareMedicFisier {
    return _localizedValues[locale.languageCode]!['raspunde_intrebare_medic']
        ['fisier'];
  }

  String get raspundeIntrebareMedicAnuleaza {
    return _localizedValues[locale.languageCode]!['raspunde_intrebare_medic']
        ['anuleaza'];
  }

  String get raspundeIntrebareMedicNumePacient {
    return _localizedValues[locale.languageCode]!['raspunde_intrebare_medic']
        ['nume_pacient'];
  }

  String get raspundeIntrebareMedicTrimiteMedia {
    return _localizedValues[locale.languageCode]!['raspunde_intrebare_medic']
        ['trimite_media'];
  }

  String get raspundeIntrebareMedicNuAvetiNiciUnMesaj {
    return _localizedValues[locale.languageCode]!['raspunde_intrebare_medic']
        ['nu_aveti_nici_un_mesaj'];
  }

  String get raspundeIntrebareMedicFisierMesajChat {
    return _localizedValues[locale.languageCode]!['raspunde_intrebare_medic']
        ['fisier_mesaj_chat'];
  }

  String get raspundeIntrebareMedicScrieMesaj {
    return _localizedValues[locale.languageCode]!['raspunde_intrebare_medic']
        ['scrie_mesaj'];
  }

  String get raspundeIntrebareMedicTrimite {
    return _localizedValues[locale.languageCode]!['raspunde_intrebare_medic']
        ['trimite'];
  }

  String get raspundeIntrebareMedicMarcheazaMesajulCaNecitit {
    return _localizedValues[locale.languageCode]!['raspunde_intrebare_medic']
        ['marcheaza_mesajul_ca_necitit'];
  }

  // register

  String get registerInregistrareCuSucces {
    return _localizedValues[locale.languageCode]!['register']
        ['inregistrare_cu_succes'];
  }

  String get registerApelInvalid {
    return _localizedValues[locale.languageCode]!['register']['apel_invalid'];
  }

  String get registerContDejaExistent {
    return _localizedValues[locale.languageCode]!['register']
        ['cont_deja_existent'];
  }

  String get registerInformatiiInsuficiente {
    return _localizedValues[locale.languageCode]!['register']
        ['informatii_insuficiente'];
  }

  String get registerAAparutEroare {
    return _localizedValues[locale.languageCode]!['register']
        ['a_aparut_eroare'];
  }

  String get registerTelefonEmailUtilizatorHint {
    return _localizedValues[locale.languageCode]!['register']
        ['telefon_email_utilizator_hint'];
  }

  String get registerIntroducetiUtilizatorEmailTelefonValid {
    return _localizedValues[locale.languageCode]!['register']
        ['introduceti_utilizator_email_telefon_valid'];
  }

  String get registerNumeCompletHint {
    return _localizedValues[locale.languageCode]!['register']
        ['nume_complet_hint'];
  }

  String get registerIntroducetiNumeleComplet {
    return _localizedValues[locale.languageCode]!['register']
        ['introduceti_numele_complet'];
  }

  String get registerParola {
    return _localizedValues[locale.languageCode]!['register']['parola'];
  }

  String get registerIntroducetiParola {
    return _localizedValues[locale.languageCode]!['register']
        ['introduceti_parola'];
  }

  String get registerParolaCelPutin {
    return _localizedValues[locale.languageCode]!['register']
        ['parola_cel_putin'];
  }

  String get registerSeIncearcaInregistrarea {
    return _localizedValues[locale.languageCode]!['register']
        ['se_incearca_inregistrarea'];
  }

  String get registerInainte {
    return _localizedValues[locale.languageCode]!['register']['inainte'];
  }

  String get registerDacaTeInscrii {
    return _localizedValues[locale.languageCode]!['register']
        ['daca_te_inscrii'];
  }

  String get registerConditiiUtilizare {
    return _localizedValues[locale.languageCode]!['register']
        ['conditii_utilizare'];
  }

  String get registerDin {
    return _localizedValues[locale.languageCode]!['register']['din'];
  }

  String get registerPoliticaDeConfidentialitate {
    return _localizedValues[locale.languageCode]!['register']
        ['politica_de_confidentialitate'];
  }

  String get registerPotiAflaCumColectam {
    return _localizedValues[locale.languageCode]!['register']
        ['poti_afla_cum_colectam'];
  }

  String get registerPoliticaDeUtilizare {
    return _localizedValues[locale.languageCode]!['register']
        ['politica_de_utilizare'];
  }

  String get registerPotiAflaCumUtilizam {
    return _localizedValues[locale.languageCode]!['register']
        ['poti_afla_cum_utilizam'];
  }

  String get registerAiUnCont {
    return _localizedValues[locale.languageCode]!['register']['ai_un_cont'];
  }

  String get registerConecteazaTe {
    return _localizedValues[locale.languageCode]!['register']['conecteaza_te'];
  }

  // reset_password_pacient

  String get resetPasswordPacientReseteazaParolaTitlu {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['reseteaza_parola_titlu'];
  }

  String get resetPasswordPacientReseteazaParolaTextMijloc {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['reseteaza_parola_text_mijloc'];
  }

  String get resetPasswordPacientTelefonEmailUtilizatorHint {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['telefon_email_utilizator_hint'];
  }

  String get resetPasswordPacientIntroducetiUtilizatorEmailTelefon {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['introduceti_utilizator_email_telefon'];
  }

  String get resetPasswordPacientContulDumneavoastra {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['contul_dumneavoastra'];
  }

  String get resetPasswordPacientSendCode {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['send_code'];
  }

  String get resetPasswordPacientCodTrimisCuSucces {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['cod_trimis_cu_succes'];
  }

  String get resetPasswordPacientApelInvalid {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['apel_invalid'];
  }

  String get resetPasswordPacientContInexistent {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['cont_inexistent'];
  }

  String get resetPasswordPacientContExistentFaraDate {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['cont_existent_fara_date'];
  }

  String get resetPasswordPacientAAparutOEroare {
    return _localizedValues[locale.languageCode]!['reset_password_pacient']
        ['a_aparut_o_eroare'];
  }

  // succes_pacient

  String get succesPacientFelicitari {
    return _localizedValues[locale.languageCode]!['succes_pacient']
        ['felicitari'];
  }

  String get succesPacientTextMijloc {
    return _localizedValues[locale.languageCode]!['succes_pacient']
        ['text_mijloc'];
  }

  String get succesPacientLogIn {
    return _localizedValues[locale.languageCode]!['succes_pacient']['log_in'];
  }

  // termeni_si_conditii

  String get termeniSiConditiiTitlu {
    return _localizedValues[locale.languageCode]!['termeni_si_conditii']
        ['termeni_si_conditii_titlu'];
  }

  String get termeniSiConditiiText {
    return _localizedValues[locale.languageCode]!['termeni_si_conditii']
        ['termeni_si_conditii_text'];
  }

  String get termeniSiConditiiGoHome {
    return _localizedValues[locale.languageCode]!['termeni_si_conditii']
        ['go_home'];
  }

  // testimonial

  String get testimonialFeedbackTrimisCuSucces {
    return _localizedValues[locale.languageCode]!['testimonial']
        ['feedback_trimis_cu_succes'];
  }

  String get testimonialApelInvalid {
    return _localizedValues[locale.languageCode]!['testimonial']
        ['apel_invalid'];
  }

  String get testimonialFeedbackNetrimis {
    return _localizedValues[locale.languageCode]!['testimonial']
        ['feedback_netrimis'];
  }

  String get testimonialInformatiiInsuficiente {
    return _localizedValues[locale.languageCode]!['testimonial']
        ['informatii_insuficiente'];
  }

  String get testimonialAAparutOEroare {
    return _localizedValues[locale.languageCode]!['testimonial']
        ['a_aparut_o_eroare'];
  }

  String get testimonialVaMultumim {
    return _localizedValues[locale.languageCode]!['testimonial']['va_multumim'];
  }

  String get testimonialRating {
    return _localizedValues[locale.languageCode]!['testimonial']['rating'];
  }

  String get testimonialTeRugamSaLasiUnTestimonial {
    return _localizedValues[locale.languageCode]!['testimonial']
        ['te_rugam_sa_lasi_un_testimonial'];
  }

  String get testimonialDoctorulARaspunsHint {
    return _localizedValues[locale.languageCode]!['testimonial']
        ['doctorul_a_raspuns_hint'];
  }

  String get testimonialSeIncearcaTrimiterea {
    return _localizedValues[locale.languageCode]!['testimonial']
        ['se_incearca_trimiterea'];
  }

  String get testimonialTrimiteTestimonialul {
    return _localizedValues[locale.languageCode]!['testimonial']
        ['trimite_testimonialul'];
  }

  // verifica_codul_pacient

  String get verificaCodulPacientVerificaCodul {
    return _localizedValues[locale.languageCode]!['verifica_codul_pacient']
        ['verifica_codul'];
  }

  String get verificaCodulPacientTextMijloc {
    return _localizedValues[locale.languageCode]!['verifica_codul_pacient']
        ['text_mijloc'];
  }

  String get verificaCodulPacientTrimiteDinNouCodul {
    return _localizedValues[locale.languageCode]!['verifica_codul_pacient']
        ['trimite_din_nou_codul'];
  }

  String get verificaCodulPacientVerifica {
    return _localizedValues[locale.languageCode]!['verifica_codul_pacient']
        ['verifica'];
  }

  String get verificaCodulPacientCodVerificatCuSucces {
    return _localizedValues[locale.languageCode]!['verifica_codul_pacient']
        ['cod_verificat_cu_succes'];
  }

  String get verificaCodulPacientApelInvalid {
    return _localizedValues[locale.languageCode]!['verifica_codul_pacient']
        ['apel_invalid'];
  }

  String get verificaCodulPacientEroareCodNeverificat {
    return _localizedValues[locale.languageCode]!['verifica_codul_pacient']
        ['eroare_cod_neverificat'];
  }

  String get verificaCodulPacientInformatiiInsuficiente {
    return _localizedValues[locale.languageCode]!['verifica_codul_pacient']
        ['informatii_insuficiente'];
  }

  String get verificaCodulPacientAAparutOEroare {
    return _localizedValues[locale.languageCode]!['verifica_codul_pacient']
        ['a_aparut_o_eroare'];
  }

  // verifica_pin_sterge_cont

  String get verificaPinStergeContVerificaCodulStergeContTitlu {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['verifica_codul_sterge_cont_titlu'];
  }

  String get verificaPinStergeContTextMijloc {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['text_mijloc'];
  }

  String get verificaPinStergeContTrimiteDinNouCodul {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['trimite_din_nou_codul'];
  }

  String get verificaPinStergeContSeVerificaCodulTrimis {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['se_verifica_codul_trimis'];
  }

  String get verificaPinStergeContSeStergeContul {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['se_sterge_contul'];
  }

  String get verificaPinStergeContVerificaPinStergeContButon {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['verifica_pin_sterge_cont_buton'];
  }

  String get verificaPinStergeContCodVerificatCuSucces {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['cod_verificat_cu_succes'];
  }

  String get verificaPinStergeContApelInvalid {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['apel_invalid'];
  }

  String get verificaPinStergeContEroareCodNeverificat {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['eroare_cod_neverificat'];
  }

  String get verificaPinStergeContInformatiiInsuficiente {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['informatii_insuficiente'];
  }

  String get verificaPinStergeContAAparutOEroare {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['a_aparut_o_eroare'];
  }

  String get verificaPinStergeContContStersCuSucces {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['cont_sters_cu_succes'];
  }

  String get verificaPinStergeContApelInvalidStergeCont {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['apel_invalid_sterge_cont'];
  }

  String get verificaPinStergeContEroareContNesters {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['eroare_cont_nesters'];
  }

  String get verificaPinStergeContInformatiiInsuficienteStergeCont {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['informatii_insuficiente_sterge_cont'];
  }

  String get verificaPinStergeContAAparutOEroareStergeCont {
    return _localizedValues[locale.languageCode]!['verifica_pin_sterge_cont']
        ['a_aparut_o_eroare_sterge_cont'];
  }

  // vezi_medici_disponibili_intro

  String get veziMediciDisponibiliIntroVeziMediciDisponibiliTitlu {
    return _localizedValues[locale.languageCode]![
        'vezi_medici_disponibili_intro']['vezi_medici_disponibili_titlu'];
  }

  String get veziMediciDisponibiliIntroAceastaAplicatieText {
    return _localizedValues[locale.languageCode]![
        'vezi_medici_disponibili_intro']['aceasta_aplicatie_text'];
  }

  String get veziMediciDisponibiliIntroMediciiNostriText {
    return _localizedValues[locale.languageCode]![
        'vezi_medici_disponibili_intro']['medicii_nostri_text'];
  }

  String get veziMediciDisponibiliIntroAtentieText {
    return _localizedValues[locale.languageCode]![
        'vezi_medici_disponibili_intro']['atentie_text'];
  }

  // vezi_medici_salvati

  String get veziMediciSalvatiProfilulMeu {
    return _localizedValues[locale.languageCode]!['vezi_medici_salvati']
        ['profilul_meu'];
  }

  String get veziMediciSalvatiMediciOnline {
    return _localizedValues[locale.languageCode]!['vezi_medici_salvati']
        ['medici_online'];
  }

  String get veziMediciSalvatiTotiMedicii {
    return _localizedValues[locale.languageCode]!['vezi_medici_salvati']
        ['toti_medicii'];
  }

  String get veziMediciSalvatiScrieOIntrebare {
    return _localizedValues[locale.languageCode]!['vezi_medici_salvati']
        ['scrie_o_intrebare'];
  }

  String get veziMediciSalvatiConsultatieVideo {
    return _localizedValues[locale.languageCode]!['vezi_medici_salvati']
        ['consultatie_video'];
  }

  String get veziMediciSalvatiInterpretareAnalize {
    return _localizedValues[locale.languageCode]!['vezi_medici_salvati']
        ['interpretare_analize'];
  }

  String get veziMediciSalvatiInConsultatie {
    return _localizedValues[locale.languageCode]!['vezi_medici_salvati']
        ['in_consultatie'];
  }

  // vezi_toti_medicii

  String get veziTotiMediciiProfilulMeu {
    return _localizedValues[locale.languageCode]!['vezi_toti_medicii']
        ['profilul_meu'];
  }

  String get veziTotiMediciiMediciOnline {
    return _localizedValues[locale.languageCode]!['vezi_toti_medicii']
        ['medici_online'];
  }

  String get veziTotiMediciiTotiMedicii {
    return _localizedValues[locale.languageCode]!['vezi_toti_medicii']
        ['toti_medicii'];
  }

  String get veziTotiMediciiScrieOIntrebare {
    return _localizedValues[locale.languageCode]!['vezi_toti_medicii']
        ['scrie_o_intrebare'];
  }

  String get veziTotiMediciiConsultatieVideo {
    return _localizedValues[locale.languageCode]!['vezi_toti_medicii']
        ['consultatie_video'];
  }

  String get veziTotiMediciiInterpretareAnalize {
    return _localizedValues[locale.languageCode]!['vezi_toti_medicii']
        ['interpretare_analize'];
  }

  String get veziTotiMediciiInConsultatie {
    return _localizedValues[locale.languageCode]!['vezi_toti_medicii']
        ['in_consultatie'];
  }

/*
  String get questionareAlergicLaParacetamol {
    return _localizedValues[locale.languageCode]!['questionare']['alergic_la_paracetamol'];
  }
*/

  //old Adrian Murgu

  //////////////
  ///UNIVERSAL
  ///

  String get universalTitluSelectLanguage {
    return _localizedValues[locale.languageCode]!['universal']['languageTitle'];
  }

  String get ListaServiciu {
    return _localizedValues[locale.languageCode]!['universal']['lss'];
  }

  String get Valoare {
    return _localizedValues[locale.languageCode]!['universal']['v'];
  }

  String get Platit {
    return _localizedValues[locale.languageCode]!['universal']['p'];
  }

  String get universalValidarePin {
    return _localizedValues[locale.languageCode]!['universal']['pinVal'];
  }

  String get universalConsultatii {
    return _localizedValues[locale.languageCode]!['universal']['cons'];
  }

  String get contulMeuModificatiCont {
    return _localizedValues[locale.languageCode]!['universal']['mc'];
  }

  String get contulMeuModificatiJudet {
    return _localizedValues[locale.languageCode]!['universal']['judet'];
  }

  String get contulMeuStergeCont {
    return _localizedValues[locale.languageCode]!['universal']['stergecont'];
  }

  String get universalEroare {
    return _localizedValues[locale.languageCode]!['universal']['eroareServer'];
  }

  String get universalCampInvalid {
    return _localizedValues[locale.languageCode]!['universal']['campInvalid'];
  }

  String get universalTelInvalid {
    return _localizedValues[locale.languageCode]!['universal']
        ['telefonInvalid'];
  }

  String get universalEmailInvalid {
    return _localizedValues[locale.languageCode]!['universal']['emailInvalid'];
  }

  String get universalTelefon {
    return _localizedValues[locale.languageCode]!['universal']['telefon'];
  }

  String get universalJudet {
    return _localizedValues[locale.languageCode]!['universal']['judet'];
  }

  String get universalModifLocal {
    return _localizedValues[locale.languageCode]!['universal']['ml'];
  }

  String get universalModifNumeleFamilie {
    return _localizedValues[locale.languageCode]!['universal']['nmx'];
  }

  String get universalModifPrenume {
    return _localizedValues[locale.languageCode]!['universal']['pn'];
  }

  String get universalModifmail {
    return _localizedValues[locale.languageCode]!['universal']['malll'];
  }

  String get universalModifJud {
    return _localizedValues[locale.languageCode]!['universal']['jd'];
  }

  String get universalModifTelefon {
    return _localizedValues[locale.languageCode]!['universal']['tff'];
  }

  String get universaldetMedic {
    return _localizedValues[locale.languageCode]!['universal']['dmd'];
  }

  String get universaldesc {
    return _localizedValues[locale.languageCode]!['universal']['ds'];
  }

  String get universalarii {
    return _localizedValues[locale.languageCode]!['universal']['ai'];
  }

  String get universalSalvare {
    return _localizedValues[locale.languageCode]!['universal']['sal'];
  }

  String get universalLocalitate {
    return _localizedValues[locale.languageCode]!['universal']['localitate'];
  }

  String get universalEmail {
    return _localizedValues[locale.languageCode]!['universal']['email'];
  }

  String get universalNume {
    return _localizedValues[locale.languageCode]!['universal']['nume'];
  }

  String get universalPrenume {
    return _localizedValues[locale.languageCode]!['universal']['prenume'];
  }

  String get universalCopii {
    return _localizedValues[locale.languageCode]!['universal']['cpi'];
  }

  String get universalDDN {
    return _localizedValues[locale.languageCode]!['universal']['ddn'];
  }

  String get universalPass {
    return _localizedValues[locale.languageCode]!['universal']['password'];
  }

  String get universalPassConfirm {
    return _localizedValues[locale.languageCode]!['universal']
        ['passwordConfirm'];
  }

  String get universalBack {
    return _localizedValues[locale.languageCode]!['universal']['back'];
  }

  String get universalContinue {
    return _localizedValues[locale.languageCode]!['universal']['continue'];
  }

  String get universalNoInternet {
    return _localizedValues[locale.languageCode]!['noInternet']['noInternet'];
  }

  String get universalNo {
    return _localizedValues[locale.languageCode]!['universal']['no'];
  }

  String get universalYes {
    return _localizedValues[locale.languageCode]!['universal']['yes'];
  }

  String get universalRegister {
    return _localizedValues[locale.languageCode]!['universal']['register'];
  }

  String get creazaCont {
    return _localizedValues[locale.languageCode]!['universal']['cc'];
  }

  String get universalLogin {
    return _localizedValues[locale.languageCode]!['universal']['login'];
  }

  String get selLimba {
    return _localizedValues[locale.languageCode]!['universal']['limba'];
  }

  String get universalTextLogare {
    return _localizedValues[locale.languageCode]!['universal']['textlogare'];
  }

  String get universalTextCont {
    return _localizedValues[locale.languageCode]!['universal']['textCont'];
  }

  String get scrisoare {
    return _localizedValues[locale.languageCode]!['universal']['1'];
  }

  String get reteta {
    return _localizedValues[locale.languageCode]!['universal']['2'];
  }

  String get adeverinta {
    return _localizedValues[locale.languageCode]!['universal']['3'];
  }

  String get universalSend {
    return _localizedValues[locale.languageCode]!['universal']['send'];
  }

  String get universalOk {
    return _localizedValues[locale.languageCode]!['universal']['ok'];
  }

  String get universalMandatoryField {
    return _localizedValues[locale.languageCode]!['universal']
        ['mandatoryField'];
  }

  String get universalPassMismatch {
    return _localizedValues[locale.languageCode]!['universal']['passMismatch'];
  }

  String get universalInvalidCredentials {
    return _localizedValues[locale.languageCode]!['universal']
        ['invalidCredentials'];
  }

  String get universalForgotPass {
    return _localizedValues[locale.languageCode]!['universal']['forgotPass'];
  }

  String get universalChangePass {
    return _localizedValues[locale.languageCode]!['universal']['changePass'];
  }

  String get universalNewPass {
    return _localizedValues[locale.languageCode]!['universal']['newPassword'];
  }

  String get universalPinEmailAlert {
    return _localizedValues[locale.languageCode]!['universal']['pinEmailAlert'];
  }

  String get universalValidationCode {
    return _localizedValues[locale.languageCode]!['universal']
        ['validationCode'];
  }

  String get universalValidationCodeError {
    return _localizedValues[locale.languageCode]!['universal']
        ['validationCodeError'];
  }

  String get universalAppUnavailable {
    return _localizedValues[locale.languageCode]!['universal']
        ['appUnavailable'];
  }

  String get noInternetMsg {
    return _localizedValues[locale.languageCode]!['noInternet']['noInternet'];
  }

  String get noInternetRefresh {
    return _localizedValues[locale.languageCode]!['noInternet']['refresh'];
  }

  String get errorRegister132 {
    return _localizedValues[locale.languageCode]!['universal']
        ['errorRegister132'];
  }

  String get loginDateGresite {
    return _localizedValues[locale.languageCode]!['universal']
        ['loginDateGresite'];
  }

  String get reseteazaParolaDateGresite {
    return _localizedValues[locale.languageCode]!['universal']
        ['reseteazaParolaDateGresite'];
  }

  String get reseteazaParolaValideazaPin {
    return _localizedValues[locale.languageCode]!['universal']
        ['reseteazaParolaValideazaPin'];
  }

  String get universalPinInvalid {
    return _localizedValues[locale.languageCode]!['universal']['pinInvalid'];
  }

  String get universalMesajUserNeasociat {
    return _localizedValues[locale.languageCode]!['universal']
        ['mesajUserNeasociat'];
  }

  String get universalDDNpeste18Ani {
    return _localizedValues[locale.languageCode]!['universal']
        ['ddn_peste_18ani'];
  }

  String get universalParolaMinimCaractere {
    return _localizedValues[locale.languageCode]!['universal']
        ['minim_caractere'];
  }

  String get universalAnulare {
    return _localizedValues[locale.languageCode]!['universal']['anulare'];
  }

  String get universalDeschideSetari {
    return _localizedValues[locale.languageCode]!['universal']
        ['deschide_setari'];
  }

  String get universalInchide {
    return _localizedValues[locale.languageCode]!['universal']['inchide'];
  }

  String get universalSelectatiSediul {
    return _localizedValues[locale.languageCode]!['universal']
        ['selectati_sediul'];
  }

  String get universalToateSediile {
    return _localizedValues[locale.languageCode]!['universal']['toate_sediile'];
  }

  /////////////////////
  ///ACCEPTA TERMENII

  String get acceptaTermeniiWelcom {
    return _localizedValues[locale.languageCode]!['accepta_termenii']
        ['welcome'];
  }

  String get acceptaTermeniiPatient {
    return _localizedValues[locale.languageCode]!['accepta_termenii']
        ['patient'];
  }

  String get acceptaTermenii1 {
    return _localizedValues[locale.languageCode]!['accepta_termenii']['text1'];
  }

  String get acceptaTermeniiHealthcare {
    return _localizedValues[locale.languageCode]!['accepta_termenii']
        ['healthcare'];
  }

  String get termeni {
    return _localizedValues[locale.languageCode]!['accepta_termenii']
        ['termeni'];
  }

  String get acceptaTermeniiMsg {
    return _localizedValues[locale.languageCode]!['accepta_termenii']['msg'];
  }

  String get acceptaTermeniiMsgTerms {
    return _localizedValues[locale.languageCode]!['accepta_termenii']
        ['msg_terms'];
  }

  String get acceptaTermeniiMsgAnd {
    return _localizedValues[locale.languageCode]!['accepta_termenii']
        ['msg_and'];
  }

  String get acceptaTermeniiMsgConditions {
    return _localizedValues[locale.languageCode]!['accepta_termenii']
        ['msg_conditions'];
  }

  String get acceptaTermenii {
    return _localizedValues[locale.languageCode]!['accepta_termenii']
        ['accepta_termenii'];
  }

//////////////
  ///TERMENI SI CONDITII

  String get termeniiConditiiTitle {
    return _localizedValues[locale.languageCode]!['termeni_conditii']['title'];
  }

  String get politicaTitlu {
    return _localizedValues[locale.languageCode]!['politica_conf']['title'];
  }

  //HOME

  String get homeWelcome {
    return _localizedValues[locale.languageCode]!['home']['welcome'];
  }

  String get homeSus {
    return _localizedValues[locale.languageCode]!['home']['sus'];
  }

  String get homeTapToPay {
    return _localizedValues[locale.languageCode]!['home']['tap_to_pay'];
  }

  String get homeProgramarileMele {
    return _localizedValues[locale.languageCode]!['home']['programarileMele'];
  }

  String get homeContulMeu {
    return _localizedValues[locale.languageCode]!['home']['contul_meu'];
  }

  String get homeInterventii {
    return _localizedValues[locale.languageCode]!['home']['interventii'];
  }

  String get homeProgramari {
    return _localizedValues[locale.languageCode]!['home']['programari'];
  }

  String get homePlati {
    return _localizedValues[locale.languageCode]!['home']['hp'];
  }

/*
  
  String get platiTitlu {
    return _localizedValues[locale.languageCode]!['plati']['title'];
  }

*/

  String get platiNeplatite {
    return _localizedValues[locale.languageCode]!['plati']['neplatite'];
  }

  String get platiToate {
    return _localizedValues[locale.languageCode]!['plati']['toate'];
  }

  String get home11 {
    return _localizedValues[locale.languageCode]!['home']['h11'];
  }

  String get home22 {
    return _localizedValues[locale.languageCode]!['home']['h22'];
  }

  String get alegeCopil {
    return _localizedValues[locale.languageCode]!['home']['alc'];
  }

  String get politicadeconf {
    return _localizedValues[locale.languageCode]!['home']['confident '];
  }

  String get homeContact {
    return _localizedValues[locale.languageCode]!['home']['contact'];
  }

  String get homeProgramariFamilie {
    return _localizedValues[locale.languageCode]!['home']['programariFamilie'];
  }

  String get homeProgramareNoua {
    return _localizedValues[locale.languageCode]!['home']['programareNoua'];
  }

  String get homeListaPreturi {
    return _localizedValues[locale.languageCode]!['home']['listaPreturi'];
  }

  String get homeEchipaDoctori {
    return _localizedValues[locale.languageCode]!['home']['echipaDoctori'];
  }

  String get searchDoc {
    return _localizedValues[locale.languageCode]!['home']['sd'];
  }

  String get homeSedii {
    return _localizedValues[locale.languageCode]!['home']['sedii'];
  }

  String get homeTratamenteleMele {
    return _localizedValues[locale.languageCode]!['home']['tratamenteleMele'];
  }

  String get homeRadiografii {
    return _localizedValues[locale.languageCode]!['home']['radiografii'];
  }

  String get homePrescriptiileMele {
    return _localizedValues[locale.languageCode]!['home']['prescriptiileMele'];
  }

  String get homeSold {
    return _localizedValues[locale.languageCode]!['home']['sold'];
  }

  String get homeLogOut {
    return _localizedValues[locale.languageCode]!['home']['logout'];
  }

  String get homeSchimbaLimba {
    return _localizedValues[locale.languageCode]!['home']['schimbaLimba'];
  }

  String get homeProgramariViitoare {
    return _localizedValues[locale.languageCode]!['home']
        ['programari_viitoare'];
  }

  String get homeProgramariTrecute {
    return _localizedValues[locale.languageCode]!['home']['programari_trecute'];
  }

  String get homeUrmatoareaProgramare {
    return _localizedValues[locale.languageCode]!['home']
        ['urmatoarea_programare'];
  }

  String get homeConfirma {
    return _localizedValues[locale.languageCode]!['home']['confirma'];
  }

  String get homeAnuleaza {
    return _localizedValues[locale.languageCode]!['home']['anuleaza'];
  }

  String get homeFeedback {
    return _localizedValues[locale.languageCode]!['home']['feedback'];
  }

  String get card {
    return _localizedValues[locale.languageCode]!['home']['card'];
  }

  String get homeDeFacut {
    return _localizedValues[locale.languageCode]!['home']['de_facut'];
  }

  String get homeRealizate {
    return _localizedValues[locale.languageCode]!['home']['realizate'];
  }

  String get homeNicioProgramare {
    return _localizedValues[locale.languageCode]!['home']['nicio_programare'];
  }

  String get homeNicioConsultatie {
    return _localizedValues[locale.languageCode]!['home']['nicio_consultatie'];
  }

  String get homeNicioInterventie {
    return _localizedValues[locale.languageCode]!['home']['nicio_interventie'];
  }

  String get homeAnuleazaProgramarea {
    return _localizedValues[locale.languageCode]!['home']
        ['anuleaza_programarea'];
  }

  String get homeConfirmaProgramarea {
    return _localizedValues[locale.languageCode]!['home']
        ['confirma_programarea'];
  }

  String get homeDa {
    return _localizedValues[locale.languageCode]!['home']['yes'];
  }

  String get homeNu {
    return _localizedValues[locale.languageCode]!['home']['no'];
  }

  String get homeSolicitaProgramare {
    return _localizedValues[locale.languageCode]!['home']['solicitaProgramare'];
  }

  String get homeVeziIstoric {
    return _localizedValues[locale.languageCode]!['home']['veziIstoric'];
  }

  String get homeIstoricProgramari {
    return _localizedValues[locale.languageCode]!['home']['istoricProgramari'];
  }

  String get homeOProgramare1 {
    return _localizedValues[locale.languageCode]!['home']['oProgramare1'];
  }

  String get home1 {
    return _localizedValues[locale.languageCode]!['home']['h1'];
  }

  String get home2 {
    return _localizedValues[locale.languageCode]!['home']['h2'];
  }

  String get homeOProgramare2 {
    return _localizedValues[locale.languageCode]!['home']['oProgramare2'];
  }

  String get homeOProgramare3 {
    return _localizedValues[locale.languageCode]!['home']['oProgramare3'];
  }

  String get homeMaiMulteProgramari {
    return _localizedValues[locale.languageCode]!['home']['maiMulteProgramari'];
  }

  String get homeMaiMulteProgramariLa {
    return _localizedValues[locale.languageCode]!['home']
        ['maiMulteProgramariLa'];
  }

  String get homeAreProgramare {
    return _localizedValues[locale.languageCode]!['home']['areProgramare'];
  }

  //IGV
  String get homeArhivaMedicala {
    return _localizedValues[locale.languageCode]!['home']['radiografii'];
  }

  //CHOOSE USER

  String get chooseUserPentru {
    return _localizedValues[locale.languageCode]!['chooseUser']['pentru'];
  }

  String get chooseUserMine {
    return _localizedValues[locale.languageCode]!['chooseUser']['mine'];
  }

  //CONTUL MEU

  String get reprog {
    return _localizedValues[locale.languageCode]!['home']['rpg'];
  }

  String get detcons {
    return _localizedValues[locale.languageCode]!['home']['ds'];
  }

  String get contulMeuTitlu {
    return _localizedValues[locale.languageCode]!['contul_meu']['titlu'];
  }

  String get contulMeumodSalvate {
    return _localizedValues[locale.languageCode]!['home']['modS'];
  }

  String get contuintra {
    return _localizedValues[locale.languageCode]!['home']['irt'];
  }

  String get modCont {
    return _localizedValues[locale.languageCode]!['home']['mkc'];
  }

  String get pedgen {
    return _localizedValues[locale.languageCode]!['home']['pg'];
  }

  String get vd {
    return _localizedValues[locale.languageCode]!['home']['vd'];
  }

  String get contulMeuVaPutemContacta {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['va_putem_contacta'];
  }

  String get contulMeuNePermiteti {
    return _localizedValues[locale.languageCode]!['contul_meu']['ne_permiteti'];
  }

  String get contulMeuSMSreamintire {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['sms_reamintire'];
  }

  String get contulMeuSMSrecall {
    return _localizedValues[locale.languageCode]!['contul_meu']['sms_recall'];
  }

  String get contulMeuSMSaniversare {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['sms_aniversare'];
  }

  String get contulMeuNewsletterSMS {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['newsletter_sms'];
  }

  String get contulMeuNewsletterEmail {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['newsletter_email'];
  }

  String get contulMeuModificati {
    return _localizedValues[locale.languageCode]!['contul_meu']['modificati'];
  }

  String get contulMeuLipsaTelefon {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['lipsa_telefon'];
  }

  String get contulMeuLipsaNume {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['Nume Personal'];
  }

  String get contulMeuLipsaPrenume {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['Prenume Personal'];
  }

  String get contulMeuLipsaEmail {
    return _localizedValues[locale.languageCode]!['contul_meu']['lipsa_email'];
  }

  String get contulMeuSigurDoriti {
    return _localizedValues[locale.languageCode]!['contul_meu']['sigur_doriti'];
  }

  String get contulMeuDa {
    return _localizedValues[locale.languageCode]!['contul_meu']['da'];
  }

  String get contulMeuNu {
    return _localizedValues[locale.languageCode]!['contul_meu']['nu'];
  }

  String get contulMeuLipsaSMSreamintire {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['lipsa_sms_reamintire'];
  }

  String get contulMeuLipsaSMSrecall {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['lipsa_sms_recall'];
  }

  String get contulMeuPreferinte {
    return _localizedValues[locale.languageCode]!['contul_meu']['preferinte'];
  }

  String get contulMeuDateContact {
    return _localizedValues[locale.languageCode]!['contul_meu']['date_contact'];
  }

  String get contulMeuSave {
    return _localizedValues[locale.languageCode]!['contul_meu']['save'];
  }

  String get contulMeuCancel {
    return _localizedValues[locale.languageCode]!['contul_meu']['cancel'];
  }

  String get contulMeuSchimbaLimba {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['schimba_limba'];
  }

  String get contulMeuSchimbaParola {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['schimba_parola'];
  }

  String get contulMeuEmailDejaFolosit {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['email_deja_folosit'];
  }

  String get contulMeuCodDeBare {
    return _localizedValues[locale.languageCode]!['contul_meu']['cod_de_bare'];
  }

  String get contulMeuAlege {
    return _localizedValues[locale.languageCode]!['contul_meu']['alege'];
  }

  String get contulMeuPacient {
    return _localizedValues[locale.languageCode]!['contul_meu']['pacient'];
  }

  String get contulMeuMsgSigurDoritiStergerea {
    return _localizedValues[locale.languageCode]!['contul_meu']
        ['msgSigurDoritiStergerea'];
  }

  //SCHIMBA PAROLA

  String get schimbaParolaCurrentPass {
    return _localizedValues[locale.languageCode]!['schimba_parola']
        ['current_pass'];
  }

  String get schimbaParolaIncorectPass {
    return _localizedValues[locale.languageCode]!['schimba_parola']
        ['incorect_pass'];
  }

  //POZA PROFIL

  String get pozaProfilTitlu {
    return _localizedValues[locale.languageCode]!['poza_profil']['titlu'];
  }

  String get pozaProfilSchimbaPoza {
    return _localizedValues[locale.languageCode]!['poza_profil']
        ['schimba_poza'];
  }

  String get pozaProfilCamera {
    return _localizedValues[locale.languageCode]!['poza_profil']['camera'];
  }

  String get pozaProfilGalerie {
    return _localizedValues[locale.languageCode]!['poza_profil']['galerie'];
  }

  String get pozaProfilAlwaysFinishActivitiesMsg {
    return _localizedValues[locale.languageCode]!['poza_profil']
        ['always_finish_activities_msg'];
  }

  String get pozaProfilCerePermisiuneCamera {
    return _localizedValues[locale.languageCode]!['poza_profil']
        ['cere_permisiune_camera'];
  }

  String get pozaProfilCerePermisiuneGalerie {
    return _localizedValues[locale.languageCode]!['poza_profil']
        ['cere_permisiune_galerie'];
  }

  //PROGRAMARE NOUA

  String get progNouaPentruMine {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['pentruMine'];
  }

  String get progNouaAlegetiData {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegetiData'];
  }

  String get progNouaAlegetiAltaData {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegetiAltaData'];
  }

  String get progNouaCompletatiObservatii {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['completatiObservatii'];
  }

  String get progNouaProgAdaugata {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['progAdaugata'];
  }

  String get progNouaProgAdaugataReala {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['progAdaugataReala'];
  }

  String get progNouaCategorie {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['categorie'];
  }

  String get progNouaMedic {
    return _localizedValues[locale.languageCode]!['programareNoua']['medic'];
  }

  String get progNouaData {
    return _localizedValues[locale.languageCode]!['programareNoua']['data'];
  }

  String get progNouaSelecteazaData {
    return _localizedValues[locale.languageCode]!['programareNoua']['aleDat'];
  }

  String get progNouaObservatii {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['observatii'];
  }

  String get progNouaScriene {
    return _localizedValues[locale.languageCode]!['programareNoua']['scrn'];
  }

  String get progNouaAlegeti {
    return _localizedValues[locale.languageCode]!['programareNoua']['alegeti'];
  }

  String get progNouaAlegetiCategoria {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegetiCategoria'];
  }

  String get progNouaAlegetiInterventia {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegetiServiciul'];
  }

  String get progNouaAlegetiMotiv {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegetiMotiv'];
  }

  String get progNouaAlegetiMedicul {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegetiMedicul'];
  }

  String get progNouaOk {
    return _localizedValues[locale.languageCode]!['programareNoua']['ok'];
  }

  String get progNouaTrimite {
    return _localizedValues[locale.languageCode]!['programareNoua']['trimite'];
  }

  String get progNouaAlegetiOra {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegetiOra'];
  }

  String get progNouaFaraIntervaleLibere {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['faraIntervaleLibere'];
  }

  String get progNouaFaraIntervaleLibereLaMedic {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['faraIntervaleLibereLaMedic'];
  }

  String get progNouaUrmatorulInterval {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['urmatorulInterval'];
  }

  String get progNouaIntervaleDisponibile {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['intervaleDisponibile'];
  }

  String get progNouaAlegeListaServicii {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegeListaDeServicii'];
  }

  String get progNouaAlegeServiciul {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegeServiciul'];
  }

  String get progNouaUrmatorulPas {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['urmatorulpas'];
  }

  String get progNouaMsgNuSuntServiciiAlocateSpecializarii {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['nuSuntServiciiAlocateSpecializarii'];
  }

  String get progNouaMsgEroare {
    return _localizedValues[locale.languageCode]!['programareNoua']['eroare'];
  }

  String get progNouaMsgSelectatiUnServiciu {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['selectatiUnServiciu'];
  }

  String get progNouaNuAtiSelectatMedic {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['nuAtiSelectatUnMedic'];
  }

  String get progNouaNuAtiSelectatOCategorie {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['nuAtiSelectatOCategorie'];
  }

  String get progNouaAlegetiListaServicii {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegetiListaServicii'];
  }

  String get progNouaAlegetiOData {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['alegetiOData'];
  }

  String get progNouaSelectatiIntervalMedic {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['selectatiIntervalMedic'];
  }

  String get progNouaRezumatProgramare {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['rezumatProgramare'];
  }

  String get progNouaRezumatProgramareMedic {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['rezumatProgramareMedic'];
  }

  String get progNouaRezumatProgramareCategorie {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['rezumatProgramareCategorie'];
  }

  String get progNouaRezumatProgramareServiciuSelectat {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['rezumatProgramareServiciuSelectat'];
  }

  String get progNouaRezumatProgramareData {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['rezumatProgramareData'];
  }

  String get progNouaRezumatProgramareOra {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['rezumatProgramareOra'];
  }

  String get progNouaRezumatProgramarePret {
    return _localizedValues[locale.languageCode]!['programareNoua']
        ['rezumatProgramarePretul'];
  }

//PROGRAMARILE LUI

  String get progLuiViitoare {
    return _localizedValues[locale.languageCode]!['programarileLui']
        ['viitoare'];
  }

  String get progLuiTrecute {
    return _localizedValues[locale.languageCode]!['programarileLui']['trecute'];
  }

  String get progLuiNicioProgViitoare {
    return _localizedValues[locale.languageCode]!['programarileLui']
        ['nicioProgViitoare'];
  }

  String get progLuiNicioProg {
    return _localizedValues[locale.languageCode]!['programarileLui']
        ['nicioProg'];
  }

  String get progLuiNicioSolicitare {
    return _localizedValues[locale.languageCode]!['programarileLui']
        ['nicioSolicitare'];
  }

  String get progLuiAnulata {
    return _localizedValues[locale.languageCode]!['programarileLui']['anulata'];
  }

  String get progLuiSolicitari {
    return _localizedValues[locale.languageCode]!['programarileLui']
        ['solicitari'];
  }

  String get progLuiNuExistaDocumente {
    return _localizedValues[locale.languageCode]!['programarileLui']
        ['nuSuntDocumente'];
  }

  //TRATAMENTELE LUI

  String get tratamenteleLuiRealizate {
    return _localizedValues[locale.languageCode]!['tratamenteleLui']
        ['realizate'];
  }

  String get tratamenteleLuiDeFacut {
    return _localizedValues[locale.languageCode]!['tratamenteleLui']['deFacut'];
  }

  String get tratamenteleLuiNiciunTratamentDeFacut {
    return _localizedValues[locale.languageCode]!['tratamenteleLui']
        ['niciunTratamentDeFacut'];
  }

  String get tratamenteleLuiNiciunTratamentRealizat {
    return _localizedValues[locale.languageCode]!['tratamenteleLui']
        ['niciunTratamentRealizat'];
  }

  //PRESCRIPTII

  String get prescriptiiNiciuna {
    return _localizedValues[locale.languageCode]!['prescriptii']['niciuna'];
  }

  String get prescriptii {
    return _localizedValues[locale.languageCode]!['prescriptii']['prs'];
  }

  String get investigatii {
    return _localizedValues[locale.languageCode]!['prescriptii']['iv'];
  }

  String get prescriptiiDescarca {
    return _localizedValues[locale.languageCode]!['prescriptii']['descarca'];
  }

  String get prescriptiiMomentanNuAuFostGasitePrescriptii {
    return _localizedValues[locale.languageCode]!['prescriptii']
        ['momentanNuAuFostGasitePrescriptii'];
  }

  //LISTA PRETURI

  String get pricesTitle {
    return _localizedValues[locale.languageCode]!['prices']['appBarTitle'];
  }

  String get pricesSearch {
    return _localizedValues[locale.languageCode]!['prices']['search'];
  }

  String get pricesCancel {
    return _localizedValues[locale.languageCode]!['prices']['cancel'];
  }

  String get pricesCategory {
    return _localizedValues[locale.languageCode]!['prices']['category'];
  }

  String get pricesCode {
    return _localizedValues[locale.languageCode]!['prices']['code'];
  }

  String get pricesName {
    return _localizedValues[locale.languageCode]!['prices']['name'];
  }

  String get pricesPrice {
    return _localizedValues[locale.languageCode]!['prices']['price'];
  }

  String get pricesAll {
    return _localizedValues[locale.languageCode]!['prices']['all'];
  }

  String get pricesRON {
    return _localizedValues[locale.languageCode]!['prices']['RON'];
  }

  //SOLD
  String get soldSold {
    return _localizedValues[locale.languageCode]!['sold']['sold'];
  }

  String get soldIban {
    return _localizedValues[locale.languageCode]!['sold']['iban'];
  }

  String get soldSoldCopy {
    return _localizedValues[locale.languageCode]!['sold']['soldCopied'];
  }

  String get soldIbanCopy {
    return _localizedValues[locale.languageCode]!['sold']['ibanCopied'];
  }

  String get soldInfoDetalii {
    return _localizedValues[locale.languageCode]!['sold']['infoDetalii'];
  }

  String get soldDetailsCopied {
    return _localizedValues[locale.languageCode]!['sold']['detailsCopied'];
  }

  String get soldPlataProforma {
    return _localizedValues[locale.languageCode]!['sold']['plataProforma'];
  }

  String get soldPlataFactura {
    return _localizedValues[locale.languageCode]!['sold']['plataFactura'];
  }

  String get soldPlata {
    return _localizedValues[locale.languageCode]!['sold']['plata'];
  }

  String get soldVeziDetalii {
    return _localizedValues[locale.languageCode]!['sold']['veziDetalii'];
  }

  //DETALII SOLD

  String get soldDetaliiTitle {
    return _localizedValues[locale.languageCode]!['soldDetalii']['title'];
  }

  String get soldDetaliiData {
    return _localizedValues[locale.languageCode]!['soldDetalii']['data'];
  }

  String get soldDetaliiDoctor {
    return _localizedValues[locale.languageCode]!['soldDetalii']['doctor'];
  }

  String get soldDetaliiInterventie {
    return _localizedValues[locale.languageCode]!['soldDetalii']['interventie'];
  }

  String get soldDetaliiPret {
    return _localizedValues[locale.languageCode]!['soldDetalii']['pret'];
  }

  String get soldDetaliiAchitat {
    return _localizedValues[locale.languageCode]!['soldDetalii']['achitat'];
  }

  String get soldDetaliiDeAchitat {
    return _localizedValues[locale.languageCode]!['soldDetalii']['deAchitat'];
  }

  String get soldDetaliiDinti {
    return _localizedValues[locale.languageCode]!['soldDetalii']['dinti'];
  }

  String get soldDetaliiTotal {
    return _localizedValues[locale.languageCode]!['soldDetalii']['total'];
  }

  String get soldDetaliiSubtotal {
    return _localizedValues[locale.languageCode]!['soldDetalii']['subtotal'];
  }

  //FEEDBACK
  String get feedbackIntrebare {
    return _localizedValues[locale.languageCode]!['feedback']['intrebare'];
  }

  String get feedbackObservatii {
    return _localizedValues[locale.languageCode]!['feedback']['observatii'];
  }

  String get feedbackButon {
    return _localizedValues[locale.languageCode]!['feedback']['buton'];
  }

  String get feedbackCompletatiObs {
    return _localizedValues[locale.languageCode]!['feedback']['completatiObs'];
  }

  String get feedbackAcordaRating {
    return _localizedValues[locale.languageCode]!['feedback']['acordaRating'];
  }

//SEDII
  String get sediiHarta {
    return _localizedValues[locale.languageCode]!['sedii']['harta'];
  }

  String get sediiHint {
    return _localizedValues[locale.languageCode]!['sedii']['hint'];
  }

  String get sediiBtn {
    return _localizedValues[locale.languageCode]!['sedii']['btn'];
  }

  String get sediiTrimiteEmpty {
    return _localizedValues[locale.languageCode]!['sedii']['trimite_empty'];
  }

  String get sediiTrimiteSuccess {
    return _localizedValues[locale.languageCode]!['sedii']['trimite_success'];
  }

  String get alegesediu {
    return _localizedValues[locale.languageCode]!['sedii']['as'];
  }

  //RADIOGRAFII
  String get radiografiiNicioRadiografie {
    return _localizedValues[locale.languageCode]!['radiografii']
        ['nicio_radiografie'];
  }

  String get t1 {
    return _localizedValues[locale.languageCode]!['radiografii']['1.1'];
  }

  String get clinicaPediatrica {
    return _localizedValues[locale.languageCode]!['radiografii']['c1'];
  }

  String get t2 {
    return _localizedValues[locale.languageCode]!['radiografii']['1.2'];
  }

  String get t3 {
    return _localizedValues[locale.languageCode]!['radiografii']['2.1'];
  }

  String get t4 {
    return _localizedValues[locale.languageCode]!['radiografii']['2.2'];
  }

  String get t5 {
    return _localizedValues[locale.languageCode]!['radiografii']['3.0'];
  }

  String get t6 {
    return _localizedValues[locale.languageCode]!['radiografii']['3.1'];
  }

  String get t7 {
    return _localizedValues[locale.languageCode]!['radiografii']['4.0'];
  }

  String get t8 {
    return _localizedValues[locale.languageCode]!['radiografii']['4.1'];
  }

  String get radiografiiMomentanFaraDocumente {
    return _localizedValues[locale.languageCode]!['radiografii']
        ['momentanFaraDocumente'];
  }

  //Radiografie dimensiune reala
  String get radiografieDimensiuneRealaImagineNedisponibila {
    return _localizedValues[locale.languageCode]!['radiografieDimensiuneReala']
        ['imagineNedisponibila'];
  }

  String get radiografieDimensiuneRealaDescarca {
    return _localizedValues[locale.languageCode]!['radiografieDimensiuneReala']
        ['descarca'];
  }

  String get radiografieDimensiuneRealaSalut {
    return _localizedValues[locale.languageCode]!['radiografieDimensiuneReala']
        ['salut'];
  }

  //Completare date facturare

  String get completareDateFacturareTitlu {
    return _localizedValues[locale.languageCode]!['completareDateFacturare']
        ['titlu'];
  }

  String get completareDateFacturareCnpParinte {
    return _localizedValues[locale.languageCode]!['completareDateFacturare']
        ['cnpParinte'];
  }

  String get completareDateFacturareCnpCopil {
    return _localizedValues[locale.languageCode]!['completareDateFacturare']
        ['cnpCopil'];
  }

  String get completareDateFacturareCompletatiToateCampurile {
    return _localizedValues[locale.languageCode]!['completareDateFacturare']
        ['completatiToateCampurile'];
  }

  String get completareDateFacturareCompletatiCnpParinte {
    return _localizedValues[locale.languageCode]!['completareDateFacturare']
        ['completatiCnpParinte'];
  }

  String get completareDateFacturareCompletatiCnpCopil {
    return _localizedValues[locale.languageCode]!['completareDateFacturare']
        ['completatiCnpCopil'];
  }

  String get completareDateFacturareCompletatiJudetul {
    return _localizedValues[locale.languageCode]!['completareDateFacturare']
        ['completatiJudetul'];
  }

  String get completareDateFacturareCompletatiLocalitatea {
    return _localizedValues[locale.languageCode]!['completareDateFacturare']
        ['completatiLocalitatea'];
  }

  //NETOPIA

  String get textPaginaNetopia {
    return _localizedValues[locale.languageCode]!['textPaginaNetopia']
        ['textCentrat'];
  }

  //VOUCHER

  String get voucherTitlu {
    return _localizedValues[locale.languageCode]!['voucher']['title'];
  }

  String get voucherMsgNuAufostGasite {
    return _localizedValues[locale.languageCode]!['voucher']
        ['nuAuFostGasiteVouchere'];
  }

  String get voucherNuUitaMaiBineSaTratezi {
    return _localizedValues[locale.languageCode]!['voucher']
        ['nuUitaMaiBineSaTratezi'];
  }

  String get voucherPerioadaValabilitate {
    return _localizedValues[locale.languageCode]!['voucher']
        ['perioadaValabilitate'];
  }

  String get voucherValoare {
    return _localizedValues[locale.languageCode]!['voucher']['valoare'];
  }

  String get alegeListaSpecializareListaGoala {
    return _localizedValues[locale.languageCode]!['alegeListaSpecializare']
        ['listaGoala'];
  }

  //CNP Copil / Părinte

  String get cnpCopilHint {
    return _localizedValues[locale.languageCode]!['completareDateFacturare']
        ['cnpCopil'];
  }

  String get cnpValidare {
    return _localizedValues[locale.languageCode]!['completareDateFacturare']
        ['validareCNP'];
  }

  //Dosarul Meu

  String get dosarulMeuMomentanFaraDocumente {
    return _localizedValues[locale.languageCode]!['dosarulMeu']
        ['msgMomentanNuAuFostGasiteDocumente'];
  }

  //Edit Judet

  String get editJudetAlegeJudetul {
    return _localizedValues[locale.languageCode]!['editJudet']['alegeJudetul'];
  }

  String get editJudetSelecteazaJudetul {
    return _localizedValues[locale.languageCode]!['editJudet']
        ['selecteazaJudetul'];
  }

  String get editJudetCautaJudetul {
    return _localizedValues[locale.languageCode]!['editJudet']['cautaJudetul'];
  }

  //Edit Localitate

  String get editLocalitateAlegeLocalitatea {
    return _localizedValues[locale.languageCode]!['editLocalitate']
        ['alegeLocalitatea'];
  }

  String get editLocalitateSelecteazaLocalitatea {
    return _localizedValues[locale.languageCode]!['editLocalitate']
        ['selecteazaLocalitatea'];
  }

  String get editLocalitateCautaLocalitatea {
    return _localizedValues[locale.languageCode]!['editLocalitate']
        ['cautaLocalitatea'];
  }
}
