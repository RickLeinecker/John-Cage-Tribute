import 'link_model.dart';
import 'url_model.dart';
import 'user_model.dart';

class ImageModel {
  final String id;
  final UrlModel urls;
  final LinkModel links;
  final UserModel user;

  ImageModel.fromJson(Map<String, dynamic> parsedJson)
    : id = parsedJson['id'],
      urls = UrlModel.fromJson(parsedJson['urls']),
      links = LinkModel.fromJson(parsedJson['links']),
      user = UserModel.fromJson(parsedJson['user']);
}