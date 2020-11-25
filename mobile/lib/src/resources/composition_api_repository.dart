import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart';

import 'package:jct/src/constants/base_url.dart';
import 'package:jct/src/constants/filter_option.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/status_model.dart';
import 'package:jct/src/models/user_model.dart';

class CompositionApiRepository {
  final storage = FlutterSecureStorage();
  final client = Client();

  Future<StatusModel> editComposition(Map<String, dynamic> data) async {
    Response response = await client.put(
      '$baseUrl/$compUrl/edit/${data['id']}',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Composition editing successful!');
    } else {
      print('Comp. editing failed. Status code: ${response.statusCode}.');
    }

    return StatusModel.fromJson(<String, dynamic>{
      'code': response.statusCode,
      'message': jsonDecode(response.body)['msg'],
    });
  }

  Future<StatusModel> deleteComposition(String compositionId) async {
    final String jwt = await storage.read(key: 'jwt');

    if (jwt == null) {
      print('No JWT found, fella.');
      return null;
    }

    Response response = await client.delete(
        '$baseUrl/$compUrl/remove/$compositionId',
        headers: {'x-auth-token': '$jwt', 'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      print('Composition deletion successful!');
    } else {
      print('Comp. deletion failed. Status code: ${response.statusCode}.');
    }

    return StatusModel.fromJson(<String, dynamic>{
      'code': response.statusCode,
      'message': jsonDecode(response.body)['msg'],
    });
  }

  /// Retrieves a list of compositions based on a user's search, filter, and
  /// screen.
  Future<List<Map<String, dynamic>>> fetchCompositions(UserModel user,
      FilterOption filter, String query, ScreenType screen) async {
    Response response;
    String url = '$baseUrl/$compUrl';

    switch (filter) {
      case FilterOption.TITLE:
        url += '/title';
        break;
      case FilterOption.TAGS:
        url += '/tags';
        break;
      case FilterOption.COMPOSED_BY:
        url += '/composer';
        break;
      case FilterOption.PERFORMED_BY:
        url += '/performer';
        break;
      default:
        break;
    }

    if (screen == ScreenType.LIBRARY) {
      response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{'user': user.id, 'query': query}),
      );
    } else if (screen == ScreenType.SEARCH) {
      print('Passing query: $query');
      response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{'query': query}),
      );
    } else {
      return null; // Other screens unsupported.
    }

    if (response.statusCode != 200) {
      print('Composition search failed. Error code: ${response.statusCode}.');
      return null;
    }

    final List<dynamic> compositions =
        List<Map<String, dynamic>>.from(jsonDecode(response.body));

    return compositions;
  }

  Future<List<Map<String, dynamic>>> fetchRecentCompositions(ScreenType screen,
      {UserModel user}) async {
    Response response;
    String url = '$baseUrl/$compUrl';

    if (screen == ScreenType.SEARCH) {
      response = await client.get(url);
    }

    // Retrieves the users' own compositions.
    else if (screen == ScreenType.LIBRARY) {
      final String jwt = await storage.read(key: 'jwt');

      response = await client.get(
        '$url/usercompositions/',
        headers: {'x-auth-token': '$jwt'},
      );
    }

    if (response.statusCode != 200) {
      print('Error fetching recent compositions.');
      return null;
    }

    final List<dynamic> compositions =
        List<Map<String, dynamic>>.from(jsonDecode(response.body));

    return compositions;
  }

  Future<String> generateCompositionID(String userId) async {
    final response = await client.get('$baseUrl/$compUrl/generate/$userId');

    if (response.statusCode != 200) {
      print('Composition ID generation unsuccessful.');
      return null;
    } else {
      print('Generated composition ID: ${response.body}');
      return jsonDecode(response.body)['id'];
    }
  }
}
