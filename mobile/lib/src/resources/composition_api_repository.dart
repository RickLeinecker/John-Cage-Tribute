import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart';

import 'package:jct/src/constants/base_url.dart';
import 'package:jct/src/constants/filter_option.dart';
import 'package:jct/src/constants/screen_type.dart';
import 'package:jct/src/models/status_model.dart';

class CompositionApiRepository {
  final storage = FlutterSecureStorage();
  final client = Client();

  Future<String> createComposition(Map<String, dynamic> composition) async {
    final String jwt = await storage.read(key: 'jwt');

    if (jwt == null) {
      print('Uh oh, can\'t authenticate you and create this composition!');

      return null;
    }

    Response response = await client.post(
      '$baseUrl/$compUrl/new',
      headers: {'x-auth-token': '$jwt', 'Content-Type': 'application/json'},
      body: jsonEncode(composition),
    );

    if (response.statusCode != 200) {
      print('Create composition failed. Status code: ${response.statusCode}.');
      return null;
    }

    return jsonDecode(response.body)['id'];
  }

  Future<StatusModel> editComposition(
      Map<String, dynamic> compositionInfo) async {
    final String jwt = await storage.read(key: 'jwt');

    if (jwt == null) {
      print('Uh oh, can\'t authenticate you and create this composition!');

      return StatusModel.fromJson(<String, dynamic>{
        'code': 404,
        'message': 'We can\'t seem to verify you. Please restart the app.'
      });
    }

    Response response = await client.post(
      '$baseUrl/$compUrl/edit/${compositionInfo['id']}',
      headers: {'x-auth-token': '$jwt', 'Content-Type': 'application/json'},
      body: jsonEncode(compositionInfo),
    );

    if (response.statusCode == 200) {
      print('Composition editing successful!');
    } else {
      print('Oh no! Status code: ${response.statusCode}.');
    }

    return StatusModel.fromJson(<String, dynamic>{
      'code': response.statusCode,
      'message': jsonDecode(response.body)['msg'],
    });
  }

  // TODO: Complete deleteComposition()
  Future<StatusModel> deleteComposition(String compositionId) async {
    return await Future.delayed(
      Duration(seconds: 1),
      () => StatusModel.fromJson(
          <String, dynamic>{'code': 200, 'message': 'Success!'}),
    );
  }

  /// Retrieves a list of compositions based on a user's search, filter, and
  /// screen.
  Future<List<Map<String, dynamic>>> fetchCompositions(
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

    print('url: $url');

    if (screen == ScreenType.LIBRARY) {
      final String jwt = await storage.read(key: 'jwt');

      if (jwt == null) {
        print('JWT not found. Library search unsuccessful.');
        return null;
      }

      response = await client.post(
        url,
        headers: {'x-auth-token': '$jwt', 'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{'query': query}),
      );
    } else if (screen == ScreenType.SEARCH) {
      print('Passing query: $query');
      response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{'query': query}),
      );
    }
    // No behavior implemented yet for other screen types.
    else {
      return null;
    }

    if (response.statusCode != 200) {
      print('Composition search failed. Error code: ${response.statusCode}.');
      return null;
    }

    final List<dynamic> compositions =
        List<Map<String, dynamic>>.from(jsonDecode(response.body));

    return compositions;
  }
}
