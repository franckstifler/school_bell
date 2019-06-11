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
        repeat: false,
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
                  AlarmProvider.db.updateAlarm(alarm..active = val);
                  setState(() {});
                },
              )
            ],
          ),
          Row(
              // mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(alarm.days
                    .where((a) => a['active'] == true)
                    .map((a) => a['dayLong'])
                    .join(', '))
              ]
              // .toList(),
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
                    AlarmProvider.db.updateAlarm(alarm..repeat = value);
                    setState(() {});
                  },
                  value: alarm.repeat,
                ),
                Text('Repeat')
              ],
            ),
            Row(
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onTap: () {
                    AlarmProvider.db.delete(alarm.id);
                    setState(() {});
                  },
                ),
                SizedBox(
                  width: 10,
                ),
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

  _toggleDay(Alarm alarm, int dayIndex, day) {
    var newAlarm = alarm;
    newAlarm.days[dayIndex]['active'] = !newAlarm.days[dayIndex]['active'];
    AlarmProvider.db.updateAlarm(newAlarm..active = false);
    setState(() {});
  }

  Widget _buildDay(day, int dayIndex, Alarm alarm) {
    return RawMaterialButton(
        onPressed: () {
          _toggleDay(alarm, dayIndex, day);
        },
        shape: CircleBorder(),
        constraints: BoxConstraints.tightFor(
          height: 35,
          width: 35,
        ),
        fillColor: day['active'] ? Colors.orange : Colors.grey,
        child: Text(day['dayLong'][0].toUpperCase(),
            style: TextStyle(
              color: Colors.white,
            )));
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
        tooltip: 'Add alarm',
        child: Icon(Icons.add),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation
      //     .centerFloat, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
