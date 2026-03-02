// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  Token? token;

  LoginResponseModel({this.token});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(token: json["token"] == null ? null : Token.fromJson(json["token"]));

  Map<String, dynamic> toJson() => {"token": token?.toJson()};
}

class Token {
  String? accessToken;
  String? refreshToken;

  Token({this.accessToken, this.refreshToken});

  factory Token.fromJson(Map<String, dynamic> json) =>
      Token(accessToken: json["access_token"], refreshToken: json["refresh_token"]);

  Map<String, dynamic> toJson() => {"access_token": accessToken, "refresh_token": refreshToken};
}
