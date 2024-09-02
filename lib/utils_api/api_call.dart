// import 'dart:convert';
// import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_responses.dart' as api_response;
import 'api_config.dart' as api_config;
import 'package:xml/xml.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pUser = prefs.getString('userTelefon');
    String? pParolaMD5 = prefs.getString('userPassMD5');

    if (pUser == null || pParolaMD5 == null) {
      return null;
    }

    //url = '${api_config.apiUrl}$pNumeMetoda';

    //  urlRoot =
    //   'http://192.168.1.56/iStomaMobileView'; //////////////////////////////////////////////////////////////////////////

    pParametrii ??= <String, String>{};

    //String parametrii = '{pCheie:$key';

    Map<String, dynamic> parametriiJson = {'pCheie': api_config.pCheie};

    pParametrii.forEach((key, value) {
      parametriiJson.addAll({key: value});
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

    var fullUrl = '${api_config.apiUrl}/GetContClient?pCheie=${api_config.pCheie}&pUser=$pUser&pParolaMD5=$pParolaMD5';

    var response = await http.get(Uri.parse(fullUrl)).timeout(const Duration(seconds: 20), onTimeout: () {
      return http.Response('', 408);
    });

    if (response.statusCode == 408) {
      // print(pNumeMetoda + ' TIMEOUT');
      return 'Timeout';
    }

    String data = '';

    // var l = LocalizationsApp.of(Shared.navigatorKey.currentContext!)!;

    try {
      data = XmlDocument.parse(response.body).findAllElements('${pNumeMetoda}Result').first.firstChild.toString();
    } catch (e) {
      // print('EROARE XML - ' + pNumeMetoda);
      // print(response.body);
      // showSnackbar(l.universalEroare);
      return 'Error parsing';
    }

    switch (data) {
      case 'null':
        return 'null';

      case api_response.succes:
        // ignore: avoid_print
        print('SUCCESS - $pNumeMetoda');
        return '13';

      case api_response.eroare:
        // print('EROARE - ' + pNumeMetoda);
        // print(envelope);
        // showSnackbar(l.universalEroare);
        return 'Eroare';

      case api_response.dateGresite:
        return "66";
      // showSnackbar(l.universalMesajUserNeasociat);

      case api_response.cheieGresita:
        // print('CHEIE GRESITA - ' + pNumeMetoda);
        // print(envelope);
        // showSnackbar(l.universalEroare);

        return 'cheie gresita';

      default:
        return data;
    }
  }
}
