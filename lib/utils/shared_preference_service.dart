import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService{
  SharedPreferenceService._();
  final SharedPreferenceService _instance = SharedPreferenceService._();
  SharedPreferenceService get getInstance => _instance;

  loadPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

  }

  setUser(Map<String, dynamic> user){

  }
}