import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'state.dart';
import 'service.dart';
import 'orders.dart';
import 'menu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Hôm nay ăn gì?'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _users;
  List<DropdownMenuItem<String>> _userList;

  @override
  void initState() {
    super.initState();
    registerNotifications();
  }

  registerNotifications() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    var time = new Time(8, 0, 0);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name',
        'repeatDailyAtTime description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.showDailyAtTime(
        0, 'Lunch', 'Đặt cơm chưa các ông ơi?', time, platformChannelSpecifics);
  }

  onDidRecieveLocationLocation() {}

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  void _userSelected(String selectedUser) {
    setState(() {
      LState.currentUser = selectedUser;
    });
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String user in _users) {
      items.add(new DropdownMenuItem(value: user, child: new Text(user)));
    }
    return items;
  }

  fetchData() async {
    List<String> users = await LService.getUsers();
    _users = users;
    _userList = getDropDownMenuItems();
    if (LState.currentUser == null) {
      LState.currentUser = _users[0];
    }

    return _users;
  }

  buildSelection() {
    return new Container(
      child: new FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return new Container(
                  alignment: FractionalOffset.center,
                  padding: const EdgeInsets.only(top: 20.0),
                  child: new CircularProgressIndicator());
            else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            'Who are you?',
                          ),
                        ),
                        new DropdownButton(
                          value: LState.currentUser,
                          items: _userList,
                          onChanged: _userSelected,
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              viewReserveds();
                            },
                            child: Column(
                              // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Icon(Icons.menu),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text("Ordered"),
                                )
                              ],
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              bookNow();
                            },
                            child: Column(
                              // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                Icon(Icons.navigate_next),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  child: Text("Order Now!"),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: buildSelection(),
    );
  }

  openPage(Widget page, String title) {
    Navigator.of(context)
        .push(new MaterialPageRoute<bool>(builder: (BuildContext context) {
      return new Center(
        child: new Scaffold(
            appBar: new AppBar(
              leading: new IconButton(
                  icon: new Icon(
                    Icons.check,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Navigator.maybePop(context);
                  }),
              title: new Text(title,
                  style: new TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
            ),
            body: new Container(
              child: page,
            )),
      );
    }));
  }

  viewReserveds() {
    OrdersPage ordersPage = new OrdersPage();
    openPage(ordersPage, 'Ordered');
  }

  bookNow() {
    BookPage ordersPage = new BookPage();
    openPage(ordersPage, 'Order Now!');
  }
}
