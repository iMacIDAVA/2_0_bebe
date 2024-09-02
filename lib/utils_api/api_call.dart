// import 'dart:convert';
// import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'api_responses.dart' as api_response;
import 'api_config.dart' as api_config;
import 'package:xml/xml.dart';
import 'dart:convert';
// import 'package:istoma_pacienti/localizations/1_localizations.dart';
// import 'package:istoma_pacienti/utils/utile_clase.dart';
// import 'package:istoma_pacienti/utils/utile_servicii.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:istoma_pacienti/utils/shared_pref_keys.dart' as prefKeys;
// import 'app_config.dart' as appConfig;

class ApiCall {
  Future<String?> apeleazaMetodaGetString({
    required String pNumeMetoda,
    Map<String, String>? pParametrii,
  }) async {
    String url, key;
    key = api_config.keyAppPacienti;
    //url = '${api_config.apiUrl}$pNumeMetoda';

    url = '${api_config.apiUrl}$pNumeMetoda';

    //  urlRoot =
    //   'http://192.168.1.56/iStomaMobileView'; //////////////////////////////////////////////////////////////////////////

    pParametrii ??= <String, String>{};


    //String parametrii = '{pCheie:$key';

    Map<String, dynamic> parametriiJson = { 
          'pCheie': key} ;
        
    pParametrii.forEach((key, value) {
      parametriiJson.addAll({key:value});
    });

    

    /*
    pParametrii.forEach((key, value) {
      parametrii = '$parametrii, $key:$value';
    });
    parametrii = '$parametrii}';
    */

    // SharedPreferences prefs = await SharedPreferences.getInstance();

    // String user = prefs.getString(prefKeys.userEmail) ?? '';
    // String pass = prefs.getString(prefKeys.userPassMD5) ?? '';

    // String paramMail = user.isEmpty ? '' : '<pAdresaMail>$user</pAdresaMail>';
    // String paramPass = pass.isEmpty ? '' : '<pParola>$pass</pParola>';
    // String paramPassMD5 = pass.isEmpty ? '' : '<pParolaMD5>$pass</pParolaMD5>';


    print('api_call body parametrii: $parametriiJson pNumeMetoda: $pNumeMetoda url: $url');

    var response = await http
        .get(Uri.parse('https://sosbebe.crmonline.ro/api/OnlineShopAPI/GetContClient?pCheie=6nDjtwV4kPUsIuBtgLhV4bTZNerrxzThPGImSsFa&pUser=0737862090&pParolaMD5=e10adc3949ba59abbe56e057f20f883e'),
        //jsonEncode({
        //    parametriiJson
        //})
        )
        .timeout(const Duration(seconds: 20), onTimeout: () {
      return http.Response('', 408);
    });

    print('api_call== response: ${response.statusCode}');

    if (response.statusCode == 408) {
      // print(pNumeMetoda + ' TIMEOUT');
      return 'Timeout';
    }

    String data = '';

    // var l = LocalizationsApp.of(Shared.navigatorKey.currentContext!)!;

    try {
      data = XmlDocument.parse(response.body).findAllElements('${pNumeMetoda}Result').first.firstChild.toString();
      print(data);
    } catch (e) {
      // print('EROARE XML - ' + pNumeMetoda);
      // print(response.body);
      // showSnackbar(l.universalEroare);
      return 'Error parsing';
    }

    switch (data) {
      case 'null':
        print('EROARE XML - ' + pNumeMetoda);
        print(response.body);
        return 'null';

      case api_response.succes:
        // ignore: avoid_print
        print('SUCCESS - $pNumeMetoda');
        print(response.body);
        return '13';

      case api_response.eroare:
        print(response.body);
        print("eroare");
        // print('EROARE - ' + pNumeMetoda);
        // print(envelope);
        // showSnackbar(l.universalEroare);
        return 'Eroare';

      case api_response.dateGresite:
        print('DATE GRESITE - ' + pNumeMetoda);
        return "66";
      // showSnackbar(l.universalMesajUserNeasociat);

      case api_response.cheieGresita:
        // print('CHEIE GRESITA - ' + pNumeMetoda);
        // print(envelope);
        // showSnackbar(l.universalEroare);

        print('cheie gresita');
        print(response.body);
        return 'cheie gresita';

      default:
        return data;
    }
  }
}
