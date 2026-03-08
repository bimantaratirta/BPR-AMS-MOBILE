// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  String? accessToken;
  String? refreshToken;

  LoginResponseModel({this.accessToken, this.refreshToken});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(accessToken: json["access_token"], refreshToken: json["refresh_token"]);

  Map<String, dynamic> toJson() => {"access_token": accessToken, "refresh_token": refreshToken};
}
