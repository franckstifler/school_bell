import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

class Alarm {
  DateTime time;
  String name;
  bool repeat;
  List<String> days = ['m', 't', 'w', 't', 'f'];

  Alarm({this.name, this.time, this.repeat});
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Alarm> alarms = <Alarm>[
    new Alarm(name: 'adonis', repeat: false, time: DateTime.now()),
    new Alarm(name: 'alex', repeat: false, time: DateTime.now())
  ];

  void _addAlarm() {
    setState(() {
      alarms.add(new Alarm(repeat: true, name: 'test name'));
    });
  }

  Widget _buildRow(Alarm alarm, int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '03:45',
                  style: TextStyle(fontSize: 50.0),
                ),
                Switch(
                  value: alarm.repeat,
                  onChanged: (val) {
                    setState(() {
                      alarms.elementAt(index).repeat = val;
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          child: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildRow(alarms[index], index);
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
