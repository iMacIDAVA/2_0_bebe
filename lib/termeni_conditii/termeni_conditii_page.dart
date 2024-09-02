import 'package:flutter/material.dart';
import 'package:sos_bebe_app/localizations/1_localizations.dart';

class TermeniSiConditii extends StatelessWidget {
  const TermeniSiConditii({super.key});

  @override
  Widget build(BuildContext context) {
    LocalizationsApp l = LocalizationsApp.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          l.profilPacientTermeniSiConditii,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1. Aspecte Generale",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Prezentele Termeni și Condiții („Termeni și Condiții”) guvernează raporturile dintre SOS BEBE SRL, societatea care dezvoltă și întreține aplicatia SOS Bebe, cu sediul lucrativ în România, Ilfov, Strada Stejarului, Nr 109A, Bl 1, Sc 2, Et Parter, Sat Fundeni („Societatea” sau „Noi”) și persoanele care utilizează („Utilizatorul”) aplicatia SOS Bebe și/sau serviciile oferite de Societate prin intermediul aplicatiei („Serviciile”). Accesarea și utilizarea aplicatiei, inclusiv a oricărei pagini sau secțiuni componente ale acestora, sau a oricărui Serviciu furnizat prin intermediul aplicatiei se poate face numai în conformitate cu prezentele Termeni și Condiții, care includ Politica de Confidențialitate și Politica privind Cookie-urile.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Pentru a asigura respectarea condițiilor de acces și utilizare a Serviciilor, Utilizatorii trebuie să verifice, la momentul fiecărei accesări a aplicației, Termenii și Condițiile de utilizare. Trebuie știut că omiterea analizării Termenilor și Condițiilor, dar utilizarea de către dumneavoastră a aplicatiei SOS Bebe presupune acceptarea acestui set de Termeni și Condiții (inclusiv orice actualizare a acestora). Acceptarea acestor Termeni și Condiții presupune că dumneavoastră înțelegeți să respectați politica noastră, astfel că aveți obligația de a nu posta informații ce conținut un limbaj nepotrivit sau care au un conținut discriminatoriu. Dacă nu sunteți de acord cu prevederile din acest set de Termeni și Condiții (inclusiv orice actualizare a acestuia), vă rugăm să nu utilizați, sau după caz, să încetați utilizarea aplicatiei a Serviciilor oferite de Noi, după caz.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "2. Serviciile SOS BEBE",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Aplicatia SOS Bebe oferă servicii către:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- Utilizatori Clienti;',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- Utilizatori Medici;',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "2.1. Crearea contului de Client/Medic, parole și responsabilități",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Pentru a folosi Serviciile oferite de aplicatia SOS Bebe, este necesar ca datele furnizate să fie adevărate, exacte și complete. Prin bifarea căsuței: 'Confirm că datele introduse mai sus sunt reale' Utlizatorul Vizitator confirmă, în mod liber și neechivoc, că datele sunt conforme cu realitatea. Trebuie să ştiţi că datele personale pe care le-am colectat de la dumneavoastră pot fi accesate doar de echipa noastră şi, în cazuri excepţionale, doar în urma unui demers legal, de instituţiile publice din România care aplică legea. Prin bifarea căsuței: 'Accept să fiu contactat/ă' Utlizatorul Vizitator confirmă, în mod liber și neechivoc, că este de acord ca un membru al echipei să ia legătura cu el.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "3. Protecția Contului de Utilizator",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Veți fi răspunzători de utilizarea înregistrării dumneavoastră, indiferent dacă utilizarea se face cu sau fără voia dumneavoastră. Sunteți de acord să sesizați aplicatia SOS Bebe în legătură cu orice utilizare neautorizată a datelor dumneavoastră de înregistrare în aplicatia SOS Bebe. Aplicatia nu va fi răspunzătoare pentru nicio pagubă morală sau materială provocată prin nerespectarea de către dumneavoastră a măsurilor de securitate a datelor utilizate pentru accesarea ei.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "4. Protecția datelor cu caracter personal",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Aplicatia SOS Bebe tratează cu seriozitate confidențialitatea datelor cu caracter personal ale Utilizatorilor. Politica de confidențialitate și aspectele privind modul în care Societatea prelucrează datele cu caracter personal ale Utilizatorilor sunt descrise în secțiunea Politica de Confidențialitate.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "5. Plata online cu cardul",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Plata online se poate efectua cu cardul personal în conditii de siguranță deplină. Cardurile acceptate la plată sunt cele emise sub siglele VISA si MASTERCARD. Pentru asigurarea securității tranzacțiilor, aplicatia SOS Bebe folosește platforma Stripe. Accesul în vederea efectuării unei plăți online pentru achitarea serviciilor folosite îi este permis oricărui Utilizator. Pentru motive justificate, aplicatia SOS Bebe își rezervă dreptul de a restricționa accesul Utilizatorului în vederea efectuării unei plăți online cu cardul, în cazul în care consideră că în baza conduitei sau a activității Utilizatorului din aplicatie, acțiunile acestuia ar putea prejudicia în vreun fel aplicatia SOS Bebe. La alegerea unei luni de probă pentru folosirea serviciilor din aplicatia SOS Bebe, tariful este exprimat în lei (RON) și include T.V.A. În cazul plăților online aplicatia SOS BEBE nu este/nu poate fi făcută responsabilă pentru niciun alt cost suplimentar suportat de Utilizator, incluzand dar nelimitându se la comisioane de conversie valutară aplicate de către banca emitentă a cardului acestuia, în cazul în care moneda de emitere a acestuia diferă de RON. Responsabilitatea pentru această acțiune o poartă numai Utilizatorul care efectuează plata online.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "6. Politica de livrare a serviciilor",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Utilizatorul va beneficia de avantajele oferite de serviciile din aplicatia SOS Bebe imediat după ce tranzacția a fost acceptată. Factura aferentă tranzacției va fi trimisă pe adresa de e-mail.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "6.1. Durata de intrare în posesia serviciilor",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Factura fiscală corespunzătoare plății efectuate va fi emisă în termen de 2 zile lucrătoare de către departamentul financiar-contabil.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "7. Politica de retur",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Sumele plătite sunt nereturnabile. Nu se percepe niciun comision suplimentar pentru tranzacții. În cazul în care cardul este asociat unui cont în altă monedă decât RON, tranzacțiile se efectuează în lei, la cursul de schimb al băncii emitente pentru cardul respectiv. Procesarea datelor de card se face în mod exclusiv prin intermediul platformei de plată Stripe. Aplicatia SOS Bebe nu solicită și nu stochează niciun fel de detalii referitoare la cardul dvs. Prin finalizarea procesului de achiziționare al serviciului Utilizatorul consimte că poate fi contactat de către aplicatia SOS Bebe, în orice situație în care este necesară contactarea Utilizatorului. Aplicatia SOS Bebe poate anula plata efectuată de către Utilizator, în urma unei notificări prealabile adresate Utilizatorului, fără nicio obligație ulterioara a vreunei părți față de cealalta sau fără ca vreo parte să poată sa pretindă celeilalte daune-interese în următoarele cazuri:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- neacceptarea de către banca emitentă a cardului Utilizatorului, a tranzacției;',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- invalidarea tranzacției de către procesatorul de carduri agreat de aplicatia SOS Bebe;',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- datele furnizate de catre Utilizator sunt incomplete și/sau incorecte;',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "9. Răspunderea și forța majoră",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Aplicatia SOS Bebe încearcă asigurarea calității și corectitudinii datelor publicate de către Utilizatori. Cu toate acestea, în măsura în care dispozițiile legale permit, SOS Bebe nu va răspunde pentru nicio daună suferită, direct sau indirect, ca urmare a utilizării informațiilor prevăzute în informațiile din profilul Utilizatorilor, motiv pentru care, prin acceptarea acestui set de Termeni și Condiții, sunteți de acord să exonerați de răspundere SOS Bebe conform celor precizate mai sus. De asemenea, aplicatia SOS Bebe nu va fi trasă la răspundere pentru niciun fel de întârziere sau eroare în conținutul furnizat de publicațiile noastre, rezultând direct sau indirect din cauze care nu depind de voința aplicatiei SOS Bebe. Această exonerare include, dar nu se limitează la: erorile de funcționare ale echipamentului tehnic de la aplicatia SOS Bebe, lipsa funcționării conexiunii la internet, lipsa funcționării conexiunilor de telefon, virușii informatici, accesul neautorizat în sistemele SOS Bebe, erorile de operare, greva, etc. Fiind în imposibilitate de a garanta pentru surse, nu ne asumăm nici or esponsabilitate și nu vom fi răspunzători pentru nici o daună sau viruși ce ar putea să vă infecteze computerul sau alte bunuri în urma accesării sau utilizării aplicatiei noastre, sau descărcării oricărui material, informații, text, imagini video sau audio de pe aceasta. În ciuda măsurilor luate pentru a proteja datele dumneavoastră cu caracter personal, vă atragem atenţia că transmiterea informaţiilor prin Internet, în general, sau prin intermediul altor reţele publice, nu este complet sigură, existând riscul ca datele să fie văzute şi utilizate de către terţe părţi neautorizate. Utilizarea aplicatiei noastre este în totalitate pe contul dumneavoastră. Nu suntem răspunzători pentru daune directe sau indirecte, de orice natură, ce ar rezulta din sau în legătură cu utilizarea aplicatiei noastre sau a conținutului său. Aplicatia noastră nu este responsabilă pentru orice pagubă sau pierdere cauzată sau presupusă a fi cauzată de informațiile furnizate de site-urile sau sursele spre care se face trimitere.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "10. Schimbarea termenilor prezentului acord",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Pentru a fi în conformitate cu schimbările survenite la nivel legislativ, aplicatia SOS Bebe va actualiza periodic acest set de termeni și condiții, moment în care utilizatorii vor fi notificați cu privire la noile modificări și, cu această ocazie, li se va solicita să-și exprime acordul cu privire la schimbările termenilor prezentului acord. Datele dumneavoastră personale vor fi folosite de aplicatia SOS Bebe exclusiv în scopul declarat al aplicatiei noastre, respectiv:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- pentru a îmbunătăţi aplicatia noastra;',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- pentru a vă oferi informaţii relevante;',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- pentru a studia exact ce căutaţi şi a vă răspunde la întrebări inclusiv, a vă transmite oferte raportate la criteriile furnizate de dumneavoastră.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "În acest sens, potrivit Regulamentului UE nr. 679/2016 și oricărei legislații aplicate pe teritoriul României este necesară exprimarea expresă a consimțământului dumneavoastră în ceea ce privește aplicatia noastra SOS BEBE. Din când în când, este posibil să revizuim această politică de confidențialitate. Dacă facem revizuiri în ceea ce privește modul în care colectăm sau folosim datele personale vom publica online versiunea revizuită a acestei Politici de confidențialitate sens, în care ar trebui să verificați frecvent serviciile noastre pentru actualizări.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
