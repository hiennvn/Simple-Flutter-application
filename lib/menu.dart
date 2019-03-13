import "package:flutter/material.dart";
import 'state.dart';
import 'service.dart';
import 'orders.dart';
import 'utils.dart';

class Menu extends StatelessWidget {
  String _date = '';
  List<String> _foods = new List();
  String _selected;

  Menu(this._date, this._foods, this._selected) {
    LState.selectFood(_date, _selected);
  }

  addFood(String food) {
    _foods.add(food);
  }

  @override
  Widget build(BuildContext context) {
    return buildWidget();
  }

  buildWidget() {
    String day = Util.getWeekDay(_date);

    return Container(
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.circular(0),
        color: Colors.white,
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
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: (_foods.length != 1)
                      ? new DropdownButtonBug(_date, _foods, _selected)
                      : new Text('No food today!'),
                )
              ],
            ),
            //Divider(),
          ],
        ),
      ),
    );
  }
}

class BookPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildWidget(context),
    );
  }

  fetchData(BuildContext context) async {
    Map<String, List<String>> menus = await LService.getMenu();
    List<Order> orders = await LService.getOrdersOfCurrentUser();

    List<Widget> items = new List();
    for (String key in menus.keys) {
      String selected = '';
      for (Order order in orders) {
        if (order.date == key) {
          selected = order.food;
        }
      }
      var menu = new Menu(key, menus[key], selected);
      items.add(menu);
    }

    items.add(new Divider());

    items.add(new FlatButton(
      child: Container(
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(10),
          color: Colors.lightBlue,
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: new Text(
            'I am done!',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      onPressed: () {
        saveData(context);
      },
    ));
    return items;
  }

  buildWidget(BuildContext context) {
    return new Container(
      child: new FutureBuilder(
          future: fetchData(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return new Container(
                  alignment: FractionalOffset.center,
                  padding: const EdgeInsets.only(top: 30.0),
                  child: new CircularProgressIndicator());
            else {
              return new ListView(
                padding: EdgeInsets.only(top: 10),
                children: snapshot.data,
              );
            }
          }),
    );
  }

  saveData(BuildContext context) {
    LService.saveOrder().then((_) {
      showDone(context);
    });
  }

  showDone(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("All Set!"),
          content: new Text("Foods will be in your hand soon!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Get me out!"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class DropdownButtonBug extends StatefulWidget {
  final String date;
  final List<String> foods;
  final String selection;
  DropdownButtonBug(this.date, this.foods, this.selection, {Key key})
      : super(key: key);

  @override
  _DropdownButtonBugState createState() => new _DropdownButtonBugState();
}

class _DropdownButtonBugState extends State<DropdownButtonBug> {
  String _date;
  List<String> _foods;
  String _selection;

  @override
  void initState() {
    _selection = widget.selection;
    _foods = widget.foods;
    _date = widget.date;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownMenuOptions = _foods
        .map((String item) => new DropdownMenuItem<String>(
              value: item,
              child: new Container(
                width: 200,
                child: Text(item),
              ),
            ))
        .toList();

    return DropdownButton(
      value: _selection,
      items: dropdownMenuOptions,
      hint: Text("Select"),
      onChanged: (_) {
        setState(() {
          _selection = _;
          LState.selectFood(_date, _selection);
        });
      },
    );
  }
}
