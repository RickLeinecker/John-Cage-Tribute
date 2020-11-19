import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String date;

  @override
  List<Object> get props => [email, username];

  const UserModel({this.id, this.email, this.username, this.date});

  UserModel.fromJson(Map<String, dynamic> parsedJson)
      : id = parsedJson['_id'],
        email = parsedJson['email'],
        username = parsedJson['name'],
        date = parsedJson['date'];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'name': username,
      'date': date
    };
  }

  void printUser() {
    print('===== USER =====');
    print('username: $username');
    print('email: $email');
  }

  // Returns the date a user joined the John Cage Tribute.
  // Parses date field, provided in the form of: YYYY-MM-DDThh:mm:ss.lllZ.
  // The 'T' separates the date from the time. The 'l' represents milliseconds.
  // The 'Z' specifies the time zone.
  String dateJoined() {
    int month = int.parse(date.substring(5, 7));
    String dateStr = '';

    switch (month) {
      case 1:
        dateStr += 'January ';
        break;
      case 2:
        dateStr += 'February ';
        break;
      case 3:
        dateStr += 'March ';
        break;
      case 4:
        dateStr += 'April ';
        break;
      case 5:
        dateStr += 'May ';
        break;
      case 6:
        dateStr += 'June ';
        break;
      case 7:
        dateStr += 'July ';
        break;
      case 8:
        dateStr += 'August ';
        break;
      case 9:
        dateStr += 'September ';
        break;
      case 10:
        dateStr += 'October ';
        break;
      case 11:
        dateStr += 'November ';
        break;
      case 12:
        dateStr += 'December ';
        break;
      default:
        dateStr += 'UnknownMonth ';
    }

    dateStr += '${int.parse(date.substring(8, 10))}, ${date.substring(0, 4)}';
    return dateStr;
  }
}
