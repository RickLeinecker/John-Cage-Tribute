import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart';

import 'package:jct/src/constants/base_url.dart';

class UserApiRetriever {
  final storage = FlutterSecureStorage();
  final Client client = Client();

  Future<Map<String, dynamic>> get jwtOrEmpty async {
    final String jwt = await storage.read(key: "jwt");
    if (jwt == null) {
      print('No JWT found, fella.');
      return null;
    }

    final response = await client.get(
      '$baseUrl/api/auth',
      headers: {'x-auth-token': '$jwt'},
    );

    if (response.statusCode == 200) {
      print('Valid JWT received!');

      final parsedJson = jsonDecode(response.body);
      return parsedJson;
    }

    print('JWT not valid for authorization, fella.');
    return null;
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> user) async {
    final response = await client.post('$baseUrl/api/users',
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(user));

    final parsedJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await storage.write(key: 'jwt', value: parsedJson['token']);
      return <String, dynamic>{
        'statusCode': response.statusCode,
        ...parsedJson['user']
      };
    } else {
      return <String, dynamic>{
        'statusCode': response.statusCode,
        'error': parsedJson['errors'][0]['msg'],
      };
    }
  }

  Future<Map<String, dynamic>> login(Map<String, dynamic> user) async {
    final response = await client.post('$baseUrl/api/auth',
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(user));

    final parsedJson = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await storage.write(key: 'jwt', value: parsedJson['token']);

      return <String, dynamic>{
        'statusCode': response.statusCode,
        ...parsedJson['user'],
      };
    } else {
      return <String, dynamic>{
        'statusCode': response.statusCode,
        'error': parsedJson['errors'][0]['msg'],
      };
    }
  }
}
