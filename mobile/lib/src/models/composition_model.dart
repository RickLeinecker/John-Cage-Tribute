import 'package:equatable/equatable.dart';

/// A representation of a recorded composition.
///
/// The length of the composition is measured in seconds.
/// The composition's filename is accessible as a resource in combination with
/// the baseUrl and compositionUrl.
class CompositionModel extends Equatable {
  final String id;
  final String title;
  final String composer;
  final double time;
  final String filename;
  final List<String> performers;
  final List<String> tags;
  final String description;
  final bool isPrivate;

  const CompositionModel.empty({
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
        time = parsedJson['runtime'] * 1.0,
        filename = parsedJson['filename'] ?? null,
        performers = List<String>.from(parsedJson['performers']) ?? List(),
        tags = List<String>.from(parsedJson['tags']) ?? List(),
        description = parsedJson['description'] ?? '',
        isPrivate = parsedJson['private'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'composer': composer,
      'time': time,
      'filename': filename,
      'performers': performers,
      'tags': tags,
      'description': description,
      'isPrivate': isPrivate,
    };
  }

  /// Returns a boolean indicating whether or not the composition is still
  /// being uploaded to the server. Upon completion, this composition should
  /// have a proper filename.
  bool isProcessing() {
    return this.filename == null;
  }

  void printComposition() {
    print('===== COMPOSITION =====');
    print('ID: $id');
    print('Title: $title');
    print('Composed by: $composer');
    print('Duration: $time');
    print('Filename: $filename');
    print('Performed by: $performers');
    print('Tags: $tags');
    print('Description: $description');
    print('isPrivate: $isPrivate');
    print('');
  }

  @override
  List<Object> get props => [id];
}
