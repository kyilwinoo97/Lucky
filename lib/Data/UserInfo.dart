import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

@JsonSerializable()
class UserInfo{

  late String id;
  late String name;
  late String phone;
  late bool isActive;
  late String pwd;
  late String userType;  //admin or user
  late bool isDeactivate;
  late String email;
  late String url;     //logo url
  late List<String> userIdList;

  UserInfo(this.id, this.name, this.phone,this.email, this.isActive, this.pwd,
      this.userType, this.isDeactivate,this.url,this.userIdList);

  UserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    isActive = json['isActive'];
    pwd = json['pwd'];
    if (json['userIdList'] != null) {
      userIdList = <String>[];
      json['userIdList'].forEach((v) { userIdList.add(v); });
    }
  userType = json['userType'];
    url = json['url'];
  isDeactivate = json['isDeactivate'];
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['id'] = this.id;
  data['name'] = this.name;
  data['phone'] = this.phone;
  data['email'] = this.email;
  data['isActive'] = this.isActive;
  data['pwd'] = this.pwd;
  data['userIdList'] = this.userIdList;
  data['userType'] = this.userType;
  data['url'] = this.url;
  data['isDeactivate'] = this.isDeactivate;
  return data;
  }

}