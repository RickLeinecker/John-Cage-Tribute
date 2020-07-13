class UnsplashUrlModel {
  final String raw;
  final String full;
  final String regular;

  UnsplashUrlModel.fromJson(Map<String, dynamic> parsedJson)
      : raw = parsedJson['raw'],
        full = parsedJson['full'],
        regular = parsedJson['regular'];
}
