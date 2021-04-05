import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensors/sensors.dart';
import 'dart:math';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool first_run = true;  //indicating first run
  int weight = 71; //user's weight in kilograms
  int threshold = 40;

  int jumps = 0; // jump count
  int jumps_before = 0; //jumps 3 seconds before
  int recent_jumps; //jumps in 3 seconds
  double calories = 0; // calories burnt
  double MET; //MET value

  var button_label = 'Start';  //button label

  StreamSubscription accel_stream;  //accelerometer stream
  double acceleration;  //total acceleration of phone
  // accelerometer values (initialize to high decreasing)
  List<double> vals = [0, 0, 0];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text('Jump Counter')
          ),
        ),

        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Settings',
                  style: TextStyle(fontSize: 50),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: TextFormField(
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter weight (kg):'
                  ),
                  initialValue: '${weight}',
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                  onChanged: (new_weight) {
                    setState(() {
                      weight = int.parse(new_weight);
                    });
                  },
                ),
              ),
              ListTile(
                title: TextFormField(
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter threshold (m/s^2):'
                  ),
                  initialValue: '${threshold}',
                  style: TextStyle(
                    fontSize: 30.0,
                  ),
                  onChanged: (new_threshold) {
                    setState(() {
                      threshold = int.parse(new_threshold);
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('${jumps}',
                style: TextStyle(fontSize: 100),
              ),
              Text(
                'Jumps',
                style: TextStyle(fontSize: 50),
              ),
              Text('${calories.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 100),
              ),
              Text(
                'Calories',
                style: TextStyle(fontSize: 50),
              ),
              Divider(
                height: 120,
                thickness: 0,
                color: Colors.white,
              ),
              ElevatedButton(
                child: new Text(button_label,
                  style: TextStyle(fontSize: 100),
                ),
                onPressed: (){    //first run
                  if (first_run){
                    first_run = false;
                    setState(() => button_label = 'Reset');
                  } else {    //not the first run anymore
                    setState(() {   //reset jump count & calories to zero
                      calories = 0;
                      jumps = 0;
                    });
                    jumps_before = 0;

                    accel_stream.cancel();  //cancel accelerometer stream
                  }

                  //create new stopwatch object
                  Stopwatch s = new Stopwatch();
                  s.start();

                  //create new accelerometer stream
                  accel_stream = accelerometerEvents.listen((AccelerometerEvent a) {
                    acceleration = sqrt(a.x*a.x + a.y*a.y + a.z*a.z);
                    vals.add(acceleration);
                    vals.removeAt(0);

                    //detect jump
                    if (vals[1] > threshold && vals[1] > vals[0] && vals[1] > vals[2]){
                      setState(() => jumps++);  //update jump count display

                      //count calories after every 3 seconds
                      if (s.elapsedMilliseconds  >= 3000) {
                          recent_jumps = jumps - jumps_before;

                        if (recent_jumps > 6){
                          MET = .615;
                        } else if (recent_jumps == 6){
                          MET = .59;
                        } else {
                          MET = .44;
                        }

                        setState(() => calories += (MET * weight * 3.5) / 200);
                        jumps_before = jumps;
                        s.reset();
                      }
                    }


                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}