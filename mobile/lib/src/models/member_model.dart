import 'package:jct/src/constants/role.dart';

class MemberModel {
  final String username;
  final Role role;
  final bool isActive;
  final bool isGuest;
  final bool isHost;

  MemberModel.fromJson(Map<String, dynamic> parsedJson)
      : username = parsedJson['name'],
        role = Role.values[parsedJson['role']],
        isActive = parsedJson['isActive'],
        isGuest = parsedJson['isGuest'],
        isHost = parsedJson['isHost'];

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'role': role.index,
      'isActive': isActive,
      'isGuest': isGuest,
      'isHost': isHost
    };
  }
}
