import 'package:shared_preferences/shared_preferences.dart';

class LState {
  static final USERNAME_KEY = 'username';
  static String currentUser;
  static Map<String, String> orders = new Map();
  static Map<String, int> dateToColumn = new Map();
  static int userRow = 0;

  Future<String> readUserFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString(USERNAME_KEY);
    return username;
  }

  setCurrentUser(String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(USERNAME_KEY, user);
  }

  static selectFood(String date, String food) {
    orders.remove(date);
    orders.putIfAbsent(date, () => food);
    print(orders);
  }

  static String getSelectedFood(String date) {
    return (orders[date] == null) ? '' : orders[date];
  }

  static setDateToColumn(String date, int column) {
    dateToColumn.putIfAbsent(date, () => column);
  }

  static setUserRow(int row) {
    userRow = row;
  }

  static reset() {
    userRow = 0;
    dateToColumn.clear();
    orders.clear();
  }
}
