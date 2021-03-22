import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensors/sensors.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool first_run = true;  //indicating first run
  int weight = 70; //user's weight in kilograms
  int threshold = 40; //threshold acceleration

  int jumps = 0; // jump count
  int jumps_before = 0; //jumps 3 seconds before
  double calories = 0; // calories burnt

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
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text('Settings',
                    style: TextStyle(fontSize: 25),),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: TextFormField(
                    initialValue: weight.toString(),
                    onChanged: (input){
                      setState(() => weight = int.parse(input));
                      print(weight);
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter weight (kg):',
                    ),
                  )
                ),
                ListTile(
                  title: TextFormField(
                    initialValue: threshold.toString(),
                    onChanged: (input){
                      setState(() => threshold = int.parse(input));
                      print(threshold);
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter threshold (m/s^2):',
                    ),
                  )
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
                    if (vals[1] > threshold && vals[1] > vals[0] && vals[1] > vals[2]){
                      setState(() => jumps++);  //update jump count display

                      if (s.elapsedMilliseconds  >= 3000) {
                        int recent_jumps = jumps - jumps_before; // jumps in 3 seconds
                        double MET;

                        if (recent_jumps > 6){
                          MET = .615;
                        } else if (recent_jumps == 6){
                          MET = .59;
                        } else {
                          MET = .44;
                        }

                        setState(() => calories += (MET * weight * 3.5) / 200);
                        s.reset();
                        jumps_before = jumps;

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