import 'dart:convert';

import 'package:gson/gson.dart';
import 'package:lucky/Constants/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../UserInfo.dart';

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
BasicInfo basicInfo = BasicInfo();
const String _storageKey = "Lucky@2021";
class BasicInfo{

  Future<String> _getUserInfo() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(Constants.userInfo) ?? '';
  }

  Future<bool> _setUserInfo(String userInfo) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.setString(Constants.userInfo,userInfo);
  }

  Future<bool> _clearUserInfo()async{
    final SharedPreferences prefs = await _prefs;
    return prefs.remove(Constants.userInfo);
  }

  getUserInfo() async{
    String userInfo =await  _getUserInfo();
    return userInfo.isNotEmpty ? UserInfo.fromJson(json.decode(userInfo)) : null;
  }

  setUserInfo(UserInfo userInfo) async{
    return await _setUserInfo(gsonEncode(userInfo));
  }

  signOutClearData() async{
    return _clearUserInfo();
  }


  // language preference
  Future<String> _getLanguage() async{
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(_storageKey) ?? '';
  }
  Future<bool> _setLanguage(String value) async{

    final SharedPreferences prefs = await _prefs;
    return prefs.setString(_storageKey, value);
  }


  getLanguage() async{
    return _getLanguage();
  }
  setLanguage(String value) async{
    return _setLanguage(value);
  }

  static final BasicInfo _basicInfo = BasicInfo._internal();
  factory BasicInfo(){
    return _basicInfo;
  }
  BasicInfo._internal();


}