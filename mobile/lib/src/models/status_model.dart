class StatusModel {
  int code;
  String message;

  StatusModel.fromJson(Map<String, dynamic> parsedJson)
      : code = parsedJson['code'],
        message = parsedJson['message'];
}
