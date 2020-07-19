import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import '../../src/constants/base_url.dart';
import '../../src/constants/filter_option.dart';

class CompositionApiRetriever {
  final Client client = MockClient(
    (request) async {
      // if (request.body == "search") {
      // TODO: Should this have a "url" field? Or perhaps an "MP3 data" field?
      final List<Map<String, dynamic>> mockCompositions = [
        {
          'title': 'A Really Short Song (jk)',
          'composer': 'topdoggo',
          'secs': 400,
        },
        {
          'title': '4\'33',
          'composer': 'John Cage',
          'secs': 273,
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
