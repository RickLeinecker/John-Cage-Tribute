import 'package:jct/src/models/unsplash/unsplash_link_model.dart';
import 'package:jct/src/models/unsplash/unsplash_url_model.dart';
import 'package:jct/src/models/unsplash/unsplash_user_model.dart';

class UnsplashImageModel {
  final String id;
  final UnsplashUrlModel urls;
  final UnsplashLinkModel links;
  final UnsplashUserModel user;

  UnsplashImageModel.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['id'],
        urls = UnsplashUrlModel.fromJson(parsedJson['urls']),
        links = UnsplashLinkModel.fromJson(parsedJson['links']),
        user = UnsplashUserModel.fromJson(parsedJson['user']);
}
