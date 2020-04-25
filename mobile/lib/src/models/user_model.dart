import 'link_model.dart';

class UserModel {
  final String name;
  final LinkModel links;
  final String portfolioUrl;

  UserModel.fromJson(Map<String, dynamic> parsedJson)
    :
      name = parsedJson['name'],
      links = LinkModel.fromJson(parsedJson['links']),
      portfolioUrl = parsedJson['portfolio_url'];
}