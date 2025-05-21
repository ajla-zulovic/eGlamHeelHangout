class CurrentUser {
  static int? userId;
  static String? username;

  static void set(int id, String uname) {
    userId = id;
    username = uname;
  }

  static void clear() {
    userId = null;
    username = null;
  }
}
