/// A representation of a recorded composition.
///
/// The time associated with the composition is listed in seconds.
/// The composition's url is accessible as a resource in combination with
/// the baseUrl and compositionUrl.
class CompositionModel {
  final String title;
  final String composer;
  final int time;
  final String url;
  final List<String> performers;
  final List<String> tags;
  final String description;

  CompositionModel.fromJson(Map<String, dynamic> parsedJson)
      : title = parsedJson['title'],
        composer = parsedJson['composer'],
        time = parsedJson['time'],
        url = parsedJson['filename'],
        performers = List<String>.from(parsedJson['performers']),
        tags = List<String>.from(parsedJson['tags']),
        description = parsedJson['description'];
}
