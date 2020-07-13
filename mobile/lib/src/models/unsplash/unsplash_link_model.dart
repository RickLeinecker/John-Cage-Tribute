class UnsplashLinkModel {
  final String self;
  final String html;
  // final String download;
  // final String downloadLocation;

  UnsplashLinkModel.fromJson(Map<String, dynamic> parsedJson)
      : self = parsedJson['self'],
        html = parsedJson['html'];
  // download = parsedJson['download'],
  // downloadLocation = parsedJson['download_location'];
}
