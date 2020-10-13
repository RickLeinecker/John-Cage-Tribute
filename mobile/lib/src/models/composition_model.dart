/// A representation of a recorded composition.
///
/// The length of the composition is measured in seconds.
/// The composition's filename is accessible as a resource in combination with
/// the baseUrl and compositionUrl.
class CompositionModel {
  final String id;
  final String title;
  final String composer;
  final int time;
  final String filename;
  final List<String> performers;
  final List<String> tags;
  final String description;
  final bool isPrivate;

  const CompositionModel.emptyModel({
    this.id,
    this.title,
    this.composer,
    this.time,
    this.filename,
    this.performers,
    this.tags,
    this.description,
    this.isPrivate,
  });

  CompositionModel.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['_id'],
        title = parsedJson['title'],
        composer = parsedJson['composer'],
        time = parsedJson['runtime'],
        filename = parsedJson['filename'],
        performers = List<String>.from(parsedJson['performers']) ?? List(),
        tags = List<String>.from(parsedJson['tags']) ?? List(),
        description = parsedJson['description'] ?? '',
        isPrivate = parsedJson['private'];
}
