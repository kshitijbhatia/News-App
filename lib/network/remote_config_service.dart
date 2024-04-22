import 'dart:developer';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigService{
  FirebaseRemoteConfigService._();
  static final FirebaseRemoteConfigService _instance = FirebaseRemoteConfigService._();
  static FirebaseRemoteConfigService get getInstance => _instance;

  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  static const String _countryKey = "Country";

  String get getCountry => _remoteConfig.getString(_countryKey);

  Future<void> _setConfigSettings() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(seconds: 1),
        )
    );
  }

  Future<void> fetchAndActivate() async {
    bool updated = await _remoteConfig.fetchAndActivate();
    if(updated){
      log('Country has been updated');
    }else{
      log('Country has not been updated');
    }
  }

  Future<void> initialize() async {
    await _setConfigSettings();
    await fetchAndActivate();
  }
}

