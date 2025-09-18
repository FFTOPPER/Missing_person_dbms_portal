import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  static Future<String> getServerIP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Default IP if nothing is set
    return prefs.getString('server_ip') ?? '192.168.0.101';
  }

  static Future<String> getFullUrl(String endpoint) async {
    String ip = await getServerIP();
    return 'http://$ip/missing_person_api/$endpoint';
  }
}
