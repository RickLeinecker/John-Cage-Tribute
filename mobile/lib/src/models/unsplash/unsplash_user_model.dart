import 'unsplash_link_model.dart';

class UnsplashUserModel {
  final String name;
  final UnsplashLinkModel links;
  final String portfolioUrl;

  UnsplashUserModel.fromJson(Map<String, dynamic> parsedJson)
      : name = parsedJson['name'],
        links = UnsplashLinkModel.fromJson(parsedJson['links']),
        portfolioUrl = parsedJson['portfolio_url'];
}
