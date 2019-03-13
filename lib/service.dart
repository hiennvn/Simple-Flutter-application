import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'state.dart';
import 'orders.dart';

class LService {
  static final _CREDENTIALS = new ServiceAccountCredentials.fromJson(r'''
  {
  "type": "service_account",
  "project_id": "paaaaaaaa-lunch",
  "private_key_id": "fd0000000000aaaaaaaaaa0000000000aaaaaaaaa",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA+szo=\n-----END PRIVATE KEY-----\n",
  "client_email": "aaa-111@ppaaaaaaaa-lunch.iam.gserviceaccount.com",
  "client_id": "10000000000000000001",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/aaa-111%40paaaaaaaa-lunch.iam.gserviceaccount.com"
}

''');

  static final _SCOPES = const ['https://www.googleapis.com/auth/spreadsheets'];

  static final SPREADSHEET_ID = '1AaAaAaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaA1';
  static final RANGE_USERNAME = 'username!A1:A30';
  static final RANGE_ORDER = 'orders!A1:Q30';
  static final RANGE_MENU = 'menu!A1:Q30';

  static Future<List<String>> getUsers() async {
    List<String> userList = new List();

    sheets.ValueRange result;
    var api;
    await clientViaServiceAccount(_CREDENTIALS, _SCOPES).then((http_client) {
      api = new sheets.SheetsApi(http_client);
    });

    await api.spreadsheets.values.get(SPREADSHEET_ID, RANGE_USERNAME).then((_) {
      result = _;
    }).whenComplete(() {
      for (List<Object> o in result.values) {
        userList.add(o[0]);
      }
    });
    print(userList);
    return userList;
  }

  static Future<List<Order>> getOrdersOfCurrentUser() async {
    List<Order> orders = new List();
    String currentUser = LState.currentUser;

    sheets.ValueRange result;
    var api;
    await clientViaServiceAccount(_CREDENTIALS, _SCOPES).then((http_client) {
      api = new sheets.SheetsApi(http_client);
    });

    await api.spreadsheets.values.get(SPREADSHEET_ID, RANGE_ORDER).then((_) {
      result = _;
    }).whenComplete(() {
      for (int j = 0; j < result.values.length; j++) {
        List<Object> row = result.values[j];
        if (row[0] == currentUser) {
          LState.setUserRow(j + 1);
          for (int i = 1; i < row.length; i++) {
            orders.add(new Order(result.values[0][i], row[i]));
            LState.setDateToColumn(result.values[0][i], i);
          }
        }
      }
    });

    return orders;
  }

  static Future<Map<String, List<String>>> getMenu() async {
    sheets.ValueRange result;
    Map<String, List<String>> orders = new Map();
    var api;
    await clientViaServiceAccount(_CREDENTIALS, _SCOPES).then((http_client) {
      api = new sheets.SheetsApi(http_client);
    });

    await api.spreadsheets.values.get(SPREADSHEET_ID, RANGE_MENU).then((_) {
      result = _;
    }).whenComplete(() {
      for (String date in result.values[0]) {
        orders.putIfAbsent(date, () => new List());
      }

      for (int i = 2; i < result.values.length; i++) {
        for (int j = 0; j < result.values[i].length; j++) {
          if (result.values[i][j] != '') {
            orders[result.values[0][j]].add(result.values[i][j]);
          }
        }
      }

      for (String key in orders.keys) {
        orders[key].add('');
      }
    });
    //print(orders);
    return orders;
  }

  static saveOrder() async {
    var api;
    await clientViaServiceAccount(_CREDENTIALS, _SCOPES).then((http_client) {
      api = new sheets.SheetsApi(http_client);
    });

    sheets.ValueRange range = new sheets.ValueRange();
    range.range = 'orders!B' +
        LState.userRow.toString() +
        ':' +
        String.fromCharCode(LState.orders.keys.length + 65) +
        LState.userRow.toString();
    print(range.range);
    List<String> order = new List();
    for (int i = 1; i <= LState.orders.keys.length; i++) {
      for (String key in LState.dateToColumn.keys) {
        if (LState.dateToColumn[key] == i) {
          order.add(LState.orders[key]);
        }
      }
    }
    List<List<String>> valueRange = new List();
    valueRange.add(order);
    range.values = valueRange;
    //print(valueRange);
    //print(range);
    api.spreadsheets.values.update(range, SPREADSHEET_ID, range.range,
        valueInputOption: 'USER_ENTERED');

    LState.reset();
  }
}
