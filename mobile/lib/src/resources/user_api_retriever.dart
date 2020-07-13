import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import '../constants/base_url.dart';
import '../models/user_model.dart';

class UserApiRetriever {
  final storage = FlutterSecureStorage();
  final Client client = Client();

  final Client mockClient = MockClient((request) async {
    if (request.body == 'email') {
      final List<Map<String, dynamic>> mockEmailList = [
        {'email': 'dummytest123@gmail.com'},
        {'email': 'rickleinecker@hotmail.com'},
      ];

      return Response(jsonEncode(mockEmailList), 200);
    }

    final List<Map<String, dynamic>> mockUsernameList = [
      {'username': 'test'},
      {'username': 'rick'},
    ];

    return Response(jsonEncode(mockUsernameList), 200);
  });

  Future<UserModel> get jwtOrEmpty async {
    final String jwt = await storage.read(key: "jwt");
    if (jwt == null) {
      print('No JWT found, fella.');
      return null;
    }

    final response = await client.post(
      '$baseUrl/api/login/existing',
      headers: {'x-auth-token': '$jwt'},
    );

    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      return UserModel.fromJson(parsedJson);
    }

    print('JWT not valid for authorization, fella.');
    return null;
  }

  Future<UserModel> signup(Map<String, dynamic> user) async {
    final response = await client.post('$baseUrl/api/signup',
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(user));

    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      await storage.write(key: 'jwt', value: parsedJson['token']);

      return UserModel.fromJson(parsedJson['user']);
    } else {
      return null;
    }
  }

  Future<UserModel> login(Map<String, dynamic> user) async {
    final response = await client.post('$baseUrl/api/login',
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(user));

    if (response.statusCode == 200) {
      final parsedJson = jsonDecode(response.body);
      await storage.write(key: 'jwt', value: parsedJson['token']);

      return UserModel.fromJson(parsedJson['user']);
    } else {
      return null;
    }
  }

  Future<List<String>> fetchEmailList() async {
    final response = await mockClient.get('emailList');
    final parsedJson = jsonDecode(response.body);
    final List<String> emailList = List();

    for (Map<String, dynamic> json in parsedJson) {
      emailList.add(json['email']);
    }

    return Future.delayed(Duration(seconds: 1), () => emailList);
  }

  Future<List<String>> fetchUsernameList() async {
    final response = await mockClient.get('usernameList');
    final parsedJson = jsonDecode(response.body);
    final List<String> usernameList = List();

    for (Map<String, dynamic> json in parsedJson) {
      usernameList.add(json['username']);
    }

    return Future.delayed(Duration(seconds: 1), () => usernameList);
  }
}
