import '../models/user.dart';

class CurrentUser {
  static int? userId;
  static String? username;
  static User? user; 

  static void set(int id, String uname, {User? fullUser}) {
    userId = id;
    username = uname;
    user = fullUser; 
  }

  static void clear() {
    userId = null;
    username = null;
    user = null;
  }
}
