import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'service.dart';
import 'utils.dart';

class Order extends StatelessWidget {
  String _date = '';
  String _food = '';

  String get date => _date;
  String get food => _food;

  Order(this._date, this._food);

  @override
  Widget build(BuildContext context) {
    return buildWidget();
  }

  buildWidget() {
    var now = new DateTime.now();
    var formatter = new DateFormat('MM-dd-yyyy');
    String formatted = formatter.format(now);

    String day = Util.getWeekDay(_date);
    Color color = (formatted == _date) ? Colors.lightBlue : Colors.white;

    return Container(
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(0),
        color: color,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            day,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          _date,
                          style: const TextStyle(),
                        ),
                      ],
                    )),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _food,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ]),
              ],
            ),
            //Divider(),
          ],
        ),
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildWidget(),
    );
  }

  fetchData() async {
    List<Order> orders = await LService.getOrdersOfCurrentUser();

    List<Widget> items = new List();
    for (Order order in orders) {
      items.add(order);
    }
    return items;
  }

  buildWidget() {
    return new Container(
      child: new FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return new Container(
                  alignment: FractionalOffset.center,
                  padding: const EdgeInsets.only(top: 30.0),
                  child: new CircularProgressIndicator());
            else {
              return new ListView(
                  padding: EdgeInsets.only(top: 10), children: snapshot.data);
            }
          }),
    );
  }
}
