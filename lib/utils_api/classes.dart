import 'package:flutter/material.dart';

class ContClientMobile {
  final int id;
  final String nume;
  final String prenume;
  final String email;
  final String telefon;
  final String user;
  String? linkPozaProfil;
  final int tipPersoana;
  final String codFiscal;
  final String denumireFirma;
  final String nregCom;
  final String seriecAct;
  final String numarAct;
  final String cnp;
  final int idJudet;
  final int idLocalitate;
  final String denumireJudet;
  final String denumireLocalitate;
  final String adresa1;

  ContClientMobile({
    required this.id,
    required this.nume,
    required this.prenume,
    required this.email,
    required this.telefon,
    required this.user,
    linkPozaProfil,
    required this.tipPersoana,
    required this.codFiscal,
    required this.denumireFirma,
    required this.nregCom,
    required this.seriecAct,
    required this.numarAct,
    required this.cnp,
    required this.idJudet,
    required this.idLocalitate,
    required this.denumireJudet,
    required this.denumireLocalitate,
    required this.adresa1,
  });

  factory ContClientMobile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'Id': int id,
        'Nume': String nume,
        'Prenume': String prenume,
        'Email': String email,
        'Telefon': String telefon,
        'User': String user,
        'LinkPozaProfil': String linkPozaProfil,
        'TipPersoana': int tipPersoana,
        'CodFiscal': String codFiscal,
        'DenumireFirma': String denumireFirma,
        'NrRegCom': String nrRegCom,
        'SerieAct': String serieAct,
        'NumarAct': String numarAct,
        'CNP': String cnp,
        'IdJudet': int idJudet,
        'IdLocalitate': int idLocalitate,
        'DenumireJudet': String denumireJudet,
        'DenumireLocalitate': String denumireLocalitate,
        'AdresaLinie1': String adresaLinie1,
      } =>
        ContClientMobile(
            id: id,
            nume: nume,
            prenume: prenume,
            email: email,
            telefon: telefon,
            user: user,
            linkPozaProfil: linkPozaProfil,
            tipPersoana: tipPersoana,
            codFiscal: codFiscal,
            denumireFirma: denumireFirma,
            nregCom: nrRegCom,
            seriecAct: serieAct,
            numarAct: numarAct,
            cnp: cnp,
            idJudet: idJudet,
            idLocalitate: idLocalitate,
            denumireJudet: denumireJudet,
            denumireLocalitate: denumireLocalitate,
            adresa1: adresaLinie1),
      _ => throw ('Utilizatorul nu există')
    };
  }
}

class MedicMobile {
  final int id;
  final String linkPozaProfil;
  final String titulatura;
  final String numeleComplet;
  final String locDeMunca;
  final String functia;
  final String specializarea;
  final double medieReviewuri;
  final int nrLikeuri;
  final int status;
  final bool primesteIntrebari;
  final bool interpreteazaAnalize;
  final bool consultatieVideo;
  final int monedaPreturi;
  final double pretIntrebare;
  final double pretConsultatieVideo;
  final double pretInterpretareAnalize;
  final String experienta;
  final String adresaLocDeMunca;
  final int totalClienti;
  final int totalTestimoniale;
  final double procentRating;
  final bool esteFavorit;
  final String channelName;

  const MedicMobile({
    required this.id,
    required this.linkPozaProfil,
    required this.titulatura,
    required this.numeleComplet,
    required this.locDeMunca,
    required this.functia,
    required this.specializarea,
    required this.medieReviewuri,
    required this.nrLikeuri,
    required this.status,
    required this.primesteIntrebari,
    required this.interpreteazaAnalize,
    required this.consultatieVideo,
    required this.monedaPreturi,
    required this.pretIntrebare,
    required this.pretConsultatieVideo,
    required this.pretInterpretareAnalize,
    required this.experienta,
    required this.adresaLocDeMunca,
    required this.totalClienti,
    required this.totalTestimoniale,
    required this.procentRating,
    required this.esteFavorit,
    required this.channelName,
  });

  factory MedicMobile.fromJson(Map<String, dynamic> json) {
    print('MedicMobile.fromJson $json');

    if (json.isNotEmpty) {
      return MedicMobile(
        id: json['Id'] as int,
        linkPozaProfil: json['LinkPozaProfil'] as String,
        titulatura: json['Titulatura'] as String,
        numeleComplet: json['NumeleComplet'] as String,
        locDeMunca: json['LocDeMunca'] as String,
        functia: json['Functia'] as String,
        specializarea: json['Specializarea'] as String,
        medieReviewuri: json['MedieReviewuri'] as double,
        nrLikeuri: json['NrLikeuri'] as int,
        status: json['Status'] as int,
        primesteIntrebari: json['PrimesteIntrebari'] as bool,
        interpreteazaAnalize: json['InterpreteazaAnalize'] as bool,
        consultatieVideo: json['ConsultatieVideo'] as bool,
        monedaPreturi: json['MonedaPreturi'] as int,
        pretIntrebare: json['PretIntrebare'] as double,
        pretConsultatieVideo: json['PretConsultatieVideo'] as double,
        pretInterpretareAnalize: json['PretInterpretareAnalize'] as double,
        experienta: json['Experienta'] ?? '',
        adresaLocDeMunca: json['AdresaLocDeMunca'] ?? '',
        totalClienti: json['TotalClienti'] as int,
        totalTestimoniale: json['TotalTestimoniale'] as int,
        procentRating: json['ProcentRating'] as double,
        esteFavorit: json['EsteFavorit'] as bool,
        channelName: json['ChannelName'] as String,
      );
    } else {
      return const MedicMobile(
          id: -1,
          linkPozaProfil: '',
          titulatura: '',
          numeleComplet: '',
          locDeMunca: '',
          functia: '',
          specializarea: '',
          medieReviewuri: -1.0,
          nrLikeuri: -1,
          status: -1,
          primesteIntrebari: false,
          interpreteazaAnalize: false,
          consultatieVideo: false,
          monedaPreturi: -1,
          pretIntrebare: -1.0,
          pretConsultatieVideo: -1.0,
          pretInterpretareAnalize: -1.0,
          experienta: '',
          adresaLocDeMunca: '',
          totalClienti: 0,
          totalTestimoniale: 0,
          procentRating: 0.0,
          esteFavorit: false,
          channelName: '');
    }
  }
}

class DateFirma {
  final String codFiscal;
  final String denumireFirma;
  final String nrRegCom;
  final int idJudet;
  final String denumireJudet;
  final int idLocalitate;
  final String denumireLocalitate;
  final String adresaLinie1;

  const DateFirma({
    required this.adresaLinie1,
    required this.codFiscal,
    required this.denumireFirma,
    required this.denumireJudet,
    required this.denumireLocalitate,
    required this.idJudet,
    required this.idLocalitate,
    required this.nrRegCom,
  });

  factory DateFirma.fromJson(Map<String, dynamic> json) {
    return DateFirma(
      codFiscal: json['CodFiscal'] as String,
      denumireFirma: json['DenumireFirma'] as String,
      nrRegCom: json['NrRegCom'] as String,
      idJudet: json['IdJudet'] as int,
      denumireJudet: json['DenumireJudet'] as String,
      idLocalitate: json['IdLocalitate'] as int,
      denumireLocalitate: json['DenumireLocalitate'] as String,
      adresaLinie1: json['AdresaLinie1'] as String,
    );
  }
}

class RecenzieMobile {
  final int id;
  final double rating;
  final String identitateClient;
  final DateTime dataRecenzie;
  final String comentariu;
  final String linkPozaProfil;
  final String raspuns;

  const RecenzieMobile({
    required this.id,
    required this.rating,
    required this.identitateClient,
    required this.dataRecenzie,
    required this.comentariu,
    required this.linkPozaProfil,
    required this.raspuns,
  });

  factory RecenzieMobile.fromJson(Map<String, dynamic> json) {
    print('RecenzieMobile.fromJson $json');

    return RecenzieMobile(
      id: json['ID'] as int,
      rating: json['Rating'] as double,
      identitateClient: json['IdentitateClient'] as String,
      //dataRecenzie: json['DataRecenzie'] as DateTime,
      dataRecenzie: DateTime.parse(json['DataRecenzie'].toString()),
      comentariu: json['Comentariu'] as String,
      linkPozaProfil: json['LinkPozaProfil'] as String,
      raspuns: json['Raspuns'] as String,
    );
  }
}

class ConversatieMobile {
  final int id;
  final String identitateDestinatar;
  final int idDestinatar;
  final int idExpeditor;
  final String titulaturaDestinatar;
  final String linkPozaProfil;
  final String locDeMunca;
  final String functia;
  final String specializarea;

  const ConversatieMobile({
    required this.id,
    required this.identitateDestinatar,
    required this.idDestinatar,
    required this.idExpeditor,
    required this.titulaturaDestinatar,
    required this.linkPozaProfil,
    required this.locDeMunca,
    required this.functia,
    required this.specializarea,
  });

  factory ConversatieMobile.fromJson(Map<String, dynamic> json) {
    print('ConversatieMobile.fromJson $json');

    return ConversatieMobile(
      id: json['ID'] as int,
      identitateDestinatar: json['IdentitateDestinatar'] as String,
      idDestinatar: json['IdDestinatar'] as int,
      idExpeditor: json['IdExpeditor'] as int,
      titulaturaDestinatar: json['TitulaturaDestinatar'] as String,
      linkPozaProfil: json['LinkPozaProfil'] as String,
      locDeMunca: json['LocDeMunca'] as String,
      functia: json['Functia'] as String,
      specializarea: json['Specializarea'] as String,
    );
  }
}

class MesajConversatieMobile {
  final int id;
  final DateTime dataMesaj;
  final String comentariu;
  final int idDestinatar;
  final int idExpeditor;
  final bool esteUltimulMesaj;
  final String linkFisier;

  const MesajConversatieMobile(
      {required this.id,
      required this.dataMesaj,
      required this.comentariu,
      required this.idDestinatar,
      required this.idExpeditor,
      required this.esteUltimulMesaj,
      required this.linkFisier});

  factory MesajConversatieMobile.fromJson(Map<String, dynamic> json) {
    return MesajConversatieMobile(
      id: json['ID'] as int,
      dataMesaj: DateTime.parse(json['DataMesaj'].toString()),
      comentariu: json['Comentariu'] as String,
      idDestinatar: json['IdDestinatar'] as int,
      idExpeditor: json['IdExpeditor'] as int,
      esteUltimulMesaj: json['EsteUltimulMesaj'] as bool,
      linkFisier: json['LinkFisier'] as String,
    );
  }
}

class ConsultatiiMobile {
  final int id;
  final String numeCompletClient;
  final String linkPozaProfil;
  final String adresa;
  final String dataInceput;
  final String dataSfarsit;
  final String etichetaDurata;
  final int tipConsultatie;
  final int idMedic;

  const ConsultatiiMobile({
    required this.id,
    required this.numeCompletClient,
    required this.linkPozaProfil,
    required this.adresa,
    required this.dataInceput,
    required this.dataSfarsit,
    required this.etichetaDurata,
    required this.tipConsultatie,
    required this.idMedic,
  });

  factory ConsultatiiMobile.fromJson(Map<String, dynamic> json) {
    print('FacturaClientMobile.fromJson $json');

    return ConsultatiiMobile(
      id: json['Id'] as int,
      numeCompletClient: json['NumeCompletClient'] ?? "",
      linkPozaProfil: json['LinkPozaProfil'] ?? "",
      adresa: json['Adresa'] ?? "",
      dataInceput: json['DataInceput'] as String,
      dataSfarsit: json['DataSfarsit'] as String,
      etichetaDurata: json['EtichetaDurata'] ?? "",
      tipConsultatie: json['TipConsultatie'] as int,
      idMedic: json['IdMedic'] as int,
    );
  }
}

class FacturaClientMobile {
  final int id;
  final String numar;
  final String serie;
  final DateTime dataEmitere;
  final DateTime dataPlata;
  final String denumireBeneficiar;
  final String telefonBeneficiar;
  final String emailBeneficiar;
  final double valoareCuTVA;
  final double valoareTVA;
  final double valoareFaraTVA;
  final int moneda;
  final String denumireMedic;
  final String serviciiFactura;
  final String telefonEmitent;
  final String emailEmitent;
  final int idFeedbackClient;
  final int notaFeedbackClient;
  final String textFeedbackClient;
  final int idMedic;

  const FacturaClientMobile(
      {required this.id,
      required this.idMedic,
      required this.numar,
      required this.serie,
      required this.dataEmitere,
      required this.dataPlata,
      required this.denumireBeneficiar,
      required this.telefonBeneficiar,
      required this.emailBeneficiar,
      required this.valoareCuTVA,
      required this.valoareTVA,
      required this.valoareFaraTVA,
      required this.moneda,
      required this.denumireMedic,
      required this.serviciiFactura,
      required this.telefonEmitent,
      required this.emailEmitent,
      required this.idFeedbackClient,
      required this.notaFeedbackClient,
      required this.textFeedbackClient});

  factory FacturaClientMobile.fromJson(Map<String, dynamic> json) {
    print('FacturaClientMobile.fromJson $json');

    return FacturaClientMobile(
        id: json['ID'] as int,
        numar: json['Numar'] ?? '',
        serie: json['Serie'] ?? '',
        dataEmitere: DateTime.parse(json['DataEmitere'].toString()),
        dataPlata: DateTime.parse(json['DataPlata'].toString()),
        denumireBeneficiar: json['DenumireBeneficiar'] ?? '',
        telefonBeneficiar: json['TelefonBeneficiar'] ?? '',
        emailBeneficiar: json['EmailBeneficiar'] ?? '',
        valoareCuTVA: json['ValoareCuTVA'] as double,
        valoareTVA: json['ValoareTVA'] as double,
        valoareFaraTVA: json['ValoareFaraTVA'] as double,
        moneda: json['Moneda'] as int,
        denumireMedic: json['DenumireMedic'] ?? '',
        serviciiFactura: json['ServiciiFactura'] ?? '',
        telefonEmitent: json['TelefonEmitent'] ?? '',
        emailEmitent: json['EmailEmitent'] ?? '',
        idFeedbackClient: json['IdFeedbackClient'] ?? '',
        notaFeedbackClient: json['NotaFeedbackClient'] ?? '',
        textFeedbackClient: json['TextFeedbackClient'] ?? '',
        idMedic: json['IdMedic'] ?? "");
  }
}

class ChestionarClientMobile {
  final String numeCompletat;
  final String prenumeCompletat;
  final DateTime dataNastereCompletata;
  final String greutateCompletata;
  final List<RaspunsIntrebareChestionarClientMobile> listaRaspunsuri;

  const ChestionarClientMobile({
    required this.numeCompletat,
    required this.prenumeCompletat,
    required this.dataNastereCompletata,
    required this.greutateCompletata,
    required this.listaRaspunsuri,
  });

  factory ChestionarClientMobile.fromJson(Map<String, dynamic> json) {
    print('ChestionarClientMobile.fromJson $json');

    return ChestionarClientMobile(
      numeCompletat: json['NumeCompletat'] ?? '',
      prenumeCompletat: json['PrenumeCompletat'] ?? '',
      dataNastereCompletata:
          DateTime.parse(json['DataNastereCompletata'].toString()),
      greutateCompletata: json['GreutateCompletata'] ?? '',
      listaRaspunsuri: List<dynamic>.from(json['ListaRaspunsuri'])
          .map((i) => RaspunsIntrebareChestionarClientMobile.fromJson(i))
          .toList(),
    );
  }
}

class RaspunsIntrebareChestionarClientMobile {
  final int idIntrebare;
  final String raspunsIntrebare;
  final String informatiiComplementare;

  const RaspunsIntrebareChestionarClientMobile({
    required this.idIntrebare,
    required this.raspunsIntrebare,
    required this.informatiiComplementare,
  });

  factory RaspunsIntrebareChestionarClientMobile.fromJson(
      Map<String, dynamic> json) {
    print('MesajConversatieMobile.fromJson $json');

    return RaspunsIntrebareChestionarClientMobile(
      idIntrebare: json['IdIntrebare'] as int,
      raspunsIntrebare: json['RaspunsIntrebare'] as String,
      informatiiComplementare: json['InformatiiComplementare'] as String,
    );
  }
}

class Agora {
  String? appID;
  String? appCertificate;

  Agora({
    this.appID,
    this.appCertificate,
  });

  factory Agora.fromJson(Map<String, dynamic> json) {
    print('Agora.fromJson $json');

    return Agora(
      appID: json['AppID'] as String,
      appCertificate: json['AppCertificate'] as String,
    );
  }
}

enum EnumTipPersoana {
  nedefinit(0),
  persoanaFizica(1),
  persoanaJuridica(2);

  const EnumTipPersoana(this.value);
  final int value;
}

enum EnumStatusMedicMobile {
  nedefinit(0),
  activ(1),
  indisponibil(2),
  inConsultatie(3);

  const EnumStatusMedicMobile(this.value);
  final int value;
}

enum EnumTipMoneda {
  nedefinit(0),
  lei(1),
  euro(2);

  const EnumTipMoneda(this.value);
  final int value;
}

enum EnumTipDispozitiv {
  nedefinit(0),
  android(1),
  iOS(2);

  const EnumTipDispozitiv(this.value);
  final int value;
}

enum EnumTipConsultatie {
  nedefinit(0),
  consultVideo(1),
  interpretareAnalize(2),
  intrebare(3);

  const EnumTipConsultatie(this.value);
  final int value;
}

enum EnumTipNotificare {
  nedefinit(0),
  analizeDeInterpretat(1),
  consultatieVideo(2),
  intrebare(3),
  mesajChat(4);

  const EnumTipNotificare(this.value);
  final int value;
}

////////////////////////////////////////////////// old Andrei Bădescu

class DosarulMeu {
  final String titlu;
  final Widget widgetRoute;

  DosarulMeu({
    required this.titlu,
    required this.widgetRoute,
  });
}

class Sediu {
  final String id, denumire, adresa, telefon;

  Sediu(
      {required this.id,
      required this.denumire,
      required this.adresa,
      required this.telefon});
}

class DetaliiProgramare {
  final String dataInceput;
  final String oraFinal;
  final String numeMedic;
  final String idCategorie;
  final String statusProgramare;
  final String esteAnulat;
  final String numeLocatie;
  final List<String> listaInterventii;

  DetaliiProgramare({
    required this.dataInceput,
    required this.oraFinal,
    required this.numeMedic,
    required this.idCategorie,
    required this.statusProgramare,
    required this.esteAnulat,
    required this.numeLocatie,
    required this.listaInterventii,
  });

  double GetTotal() {
    // print(listaInterventii.map((e) => e.split("*\$*")[6]).toList()[0]);
    // return listaInterventii
    //     .map((e) => e.split("*\$*"))
    //     .where((element) => element.length >= 7)
    //     .map((e) => e[6])
    //     .map((e) => e.replaceAll(RegExp(r'([A-Z\s,])'), ""))
    //     .map((e) => double.parse(e))
    //     .reduce((value, element) => value + element);
    double total = 0;
    print(listaInterventii);
    for (var interv in listaInterventii) {
      if (interv.isEmpty) continue;
      String pretstr = interv.split("*\$*")[6];
      pretstr = pretstr.replaceAll(RegExp(r'([A-Z\s,])'), "");
      print(pretstr);
      double pret = double.parse(pretstr);
      total += pret;
    }
    return total;
  }
}

class Programare {
  final String locatie;
  final String idMedic;
  String hasFeedback;
  final String id;
  final DateTime inceput, sfarsit;
  final String medic, categorie;
  String status, anulata;
  final String idPacient, nume, prenume;

  static const String statusConfirmat = "Confirmat";
  static const String statusAnulat = "Anulat";

  Programare({
    required this.id,
    required this.medic,
    required this.anulata,
    required this.categorie,
    required this.inceput,
    required this.sfarsit,
    required this.status,
    required this.idPacient,
    required this.nume,
    required this.prenume,
    required this.locatie,
    required this.idMedic,
    required this.hasFeedback,
  });
}

class LinieFisaTratament {
  final String tipObiect;
  final String idObiect;
  final String numeMedic;
  final String denumireInterventie;
  final String dinti;
  final String observatii;
  final DateTime dataDateTime;
  final String dataString;
  final String pret;
  final Color culoare;
  final DateTime? dataCreareDateTime;
  final String? dataCreareString;
  final String valoareInitiala;

  LinieFisaTratament(
      {required this.tipObiect,
      required this.pret,
      required this.idObiect,
      required this.numeMedic,
      required this.denumireInterventie,
      required this.dinti,
      required this.observatii,
      required this.dataDateTime,
      required this.dataString,
      required this.culoare,
      this.dataCreareDateTime,
      this.dataCreareString,
      required this.valoareInitiala});
}

class Programari {
  List<Programare> viitoare;
  List<Programare> trecute;

  Programari({required this.viitoare, required this.trecute});
}

class MembruFamilie {
  final String id, nume, prenume;

  MembruFamilie({required this.id, required this.nume, required this.prenume});
}

class Shared {
  static GlobalKey<NavigatorState> sharedNavigatorKey =
      GlobalKey<NavigatorState>();
  // static String flavor = '';
  static String FCMtoken = '';
  static String idMembruFamilieConectat = '_';
  static String sediuPacient = '';
  //static List<Medic> medici = <Medic>[];
  //static List<MedicSlotLiber> mediciFiltrati = <MedicSlotLiber>[];
  //static List<CategorieProgramare> categorii = <CategorieProgramare>[];
  static List<MembruFamilie> familie = <MembruFamilie>[];
  static List<Sediu> sedii = <Sediu>[];
  static String idPacientAsociat = '0';

  static List<Judet> judete = <Judet>[];
  static List<Localitate> localitati = <Localitate>[];

  //static GenericLanguage limba = LanguageEN();
}

class Judet {
  final String id, denumire;

  Judet({
    required this.id,
    required this.denumire,
  });

  factory Judet.fromJson(Map<String, dynamic> json) {
    return Judet(id: json['ID'].toString(), denumire: json['Denumire'] ?? "");
  }
}

class Localitate {
  final String id, denumire;

  Localitate({
    required this.id,
    required this.denumire,
  });

  factory Localitate.fromJson(Map<String, dynamic> json) {
    return Localitate(
        id: json['ID'].toString(), denumire: json['Denumire'] ?? "");
  }
}
