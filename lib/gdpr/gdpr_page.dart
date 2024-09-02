import 'package:flutter/material.dart';

class GDPRPage extends StatelessWidget {
  const GDPRPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'GDPR',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                "CE INFORMAȚII COLECTĂM?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "INFORMAȚIILE OFERITE VOLUNTAR ȘI CONȘTIENT",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'In momentul în care completați un formular de contact. Prelucrăm datele dumneavoastră cu caracter personal pentru a vă putea răspunde la întrebări sau pentru a putea presta serviciile pe care le solicitați sau comandați. Date personale înseamnă orice informație care poate fi legată de o persoană fizică identificată sau identificabilă. Datele personale includ toate tipurile de informații directe sau indirecte, cum ar fi numele complet, adresa de email sau numărul de telefon. Aceste informații vor fi stocate în perioada garanției serviciilor sau ale produselor pentru a vă putea contacta în cazul în care este necesar, dar strict legat de produsele și serviciile comandate. În cazul în care solicitați mai multe informații despre noi printr-un formular sau telefonic, vom utiliza adresa dvs. de email pentru a vă trimite unul sau mai multe mail-uri prin care vă prezentăm serviciile noastre, dar numai în urma unei solicitări concrete și exprese. Adițional dacă specificați numărul de telefon, este posibil să vă sunăm pentru a solicita mai multe informații sau pentru a răspunde la întrebările trimise.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "INFORMAȚII COLECTATE ÎN MOD AUTOMAT",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Adițional aplicatia noastra colectează informații despre paginile vizitate și interacțiunea cu conținutul site-ului. Aceste activități vor fi salvate în istoric și vor fi utilizate pentru a analiza erorile apărute și pentru a îmbunătăți aplicatia. Aplicatia va plasa și un cookie pe dispozitivul de pe care îl accesați, urmând să fie utilizat pentru identificarea indirectă. Aceste informații nu vor fi utilizate decât pentru operarea aplicatieii, măsurarea performanței apicatiei, traficului și rezultatele campaniilor de marketing. Nu vom vinde sau transfera aceste informații terților, indiferent de raporturile în care suntem cu aceștia, și vom păstra o strictă confidențialitate a lor. Aceste informații nu vor fi utilizate pentru a vă contacta (email, sms sau telefonic), ci pentru a îmbunătăți aplicatia noastra, pentru a vă oferi informații relevante, pentru a studia exact ce căutați și a răspunde la întrebări.",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Cum păstrăm datele dvs. cu caracter personal?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Trebuie să știți că datele personale pe care le-am colectat de la dvs. pot fi accesate doar de echipa noastră și în cazuri excepționale, doar în urma unui demers legal, de instituțiile publice din România care aplică legea. Prelucrăm datele cu caracter personal aplicând măsurile tehnice și organizatorice adecvate pentru a le proteja împotriva oricărei prelucrări ilegale, distrugerii sau pierderii accidentale sau intenționate, a alterării, divulgării, transmiterii neautorizate sau accesului neautorizat, inclusiv când respectivele date pot fi transmise prin rețea. Vă rugăm să ne contactați pe adresa de email contact@sosbebe.ro pentru:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- orice neregulă în funcționarea aplicatiei',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- orice suspiciune privind insecuritatea aplicației',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '- orice suspiciune privind insecuritatea aplicației',
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
