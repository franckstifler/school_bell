import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'alarm.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Bell',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'SchoolBell'),
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

  void _addAlarm() {
    DatePicker.showTimePicker(context,
        locale: LocaleType.en, showTitleActions: true, onConfirm: (date) async {
      Alarm alarm = Alarm(
        id: 100,
        repeat: true,
        dateTime: date,
        active: false,
      );
      // alarms.add(alarm);
      await AlarmProvider.db.insertAlarm(alarm);
      // AlarmProvider.db.getAlarms();
      setState(() {});
    }, currentTime: DateTime.now());
  }

  Widget _buildRow(Alarm alarm, int index) {
    // get only the time (hour:minutes) with 0 prefix when needed.
    String time = alarm.dateTime.toString().substring(11, 16);
    return ExpansionTile(
      title: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                time,
                style: TextStyle(fontSize: 50.0),
              ),
              Switch(
                value: alarm.active,
                onChanged: (val) {
                  setState(() {
                    // alarms.elementAt(index).active = val;
                  });
                },
              )
            ],
          ),
          Row(
            children: <Widget>[Text('Mon, Tue, Wed, Thu, Fri')],
          )
        ],
      ),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  onChanged: (value) {
                    setState(() {
                      // alarms.elementAt(index).repeat = value;
                    });
                  },
                  value: alarm.repeat,
                ),
                Text('Repeat')
              ],
            ),
            Row(
              children: <Widget>[
                Icon(Icons.delete),
                SizedBox(
                  width: 10,
                ),
                Text('Delete'),
              ],
            )
          ],
        ),
        Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: alarm.days
                .asMap()
                .map((index, day) =>
                    MapEntry(index, _buildDay(day, index, alarm)))
                .values
                .toList()),
      ],
    );
  }

  _toggleDay(int alarmId, int dayIndex, day) {
    setState(() {
      // var index = alarms.indexWhere((alarm) => alarm.id == alarmId);
      // Alarm alarm = alarms.elementAt(index);
      // alarms.elementAt(index).days.elementAt(dayIndex)['active'] =
      //     !alarm.days.elementAt(dayIndex)['active'];
    });
  }

  Widget _buildDay(day, int dayIndex, Alarm alarm) {
    if (day['active']) {
      return RawMaterialButton(
          onPressed: () {
            _toggleDay(alarm.id, dayIndex, day);
          },
          shape: CircleBorder(),
          constraints: BoxConstraints.tightFor(
            height: 35,
            width: 35,
          ),
          fillColor: Colors.orange,
          child: Text(day['day'].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
              )));
    } else {
      return RawMaterialButton(
          onPressed: () {
            _toggleDay(alarm.id, dayIndex, day);
          },
          shape: CircleBorder(),
          constraints: BoxConstraints.tightFor(
            height: 35,
            width: 35,
          ),
          child: Text(day['day'].toUpperCase(),
              style: TextStyle(
                color: Colors.black,
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          initialData: [],
          future: AlarmProvider.db.getAlarms(),
          builder: (context, snapshot) {
            return Container(
                child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildRow(snapshot.data[index], index);
              },
            ));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation
      //     .centerFloat, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
