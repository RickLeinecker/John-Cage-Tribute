import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/testing.dart';

import 'package:jct/src/constants/base_url.dart';
import 'package:jct/src/constants/filter_option.dart';

class CompositionApiRetriever {
  final Client client = MockClient(
    (request) async {
      // if (request.body == "search") {
      final List<Map<String, dynamic>> mockCompositions = [
        {
          'title': 'The Zoo',
          'composer': 'jawed',
          'time': 600,
          'filename': '4a5b5e73cced3c0fd3f9f990b1aa112b.mp3',
          'performers': ['mercedes11', 'idkkkBoutThat', 'bonnh4t'],
          'tags': ['funny', 'nonsense', 'asdfghjkl'],
          'description': 'First composition on JCT!',
        },
        {
          'title': '4\'33',
          'composer': 'J.C.',
          'time': 273,
          'filename': '4a5b5e73cced3c0fd3f9f990b1aa112b.mp3',
          'performers': ['TeddyGeiger', 'AlperAydin', 'OneTaco', 'Goku4Smash'],
          'tags': ['no'],
          'description': 'We stayed perfectly quiet.',
        }
      ];

      return Response(jsonEncode(mockCompositions), 200);
      // } else {
      //   return null;
      // }
    },
  );

  // TODO: Verify that this URL standard even works.
  Future<List<Map<String, dynamic>>> fetchCompositions(
      FilterOption filter, String query,
      {String user}) async {
    String url = '$baseUrl/api/compositions';

    switch (filter) {
      case FilterOption.TAGS:
        url = '$url/tag=$query';
        break;
      case FilterOption.COMPOSED_BY:
        url = '$url/composedby=$query';
        break;
      case FilterOption.PERFORMED_BY:
        url = '$url/performedby=$query';
        break;
      default:
        break;
    }

    if (user != null) {
      url = '$url&user=$user';
    }

    final response = await client.get(url);
    final List<dynamic> compositions = jsonDecode(response.body);
    final List<Map<String, dynamic>> mapList = new List();

    for (Map<String, dynamic> map in compositions) {
      mapList.add(map);
    }

    return mapList;
  }
}
