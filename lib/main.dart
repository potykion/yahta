import 'package:flutter/material.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yahta/direction.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var previousIndex = 0;
  var currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Swiper(
        itemBuilder: (BuildContext context, int index) => Center(
          child: Text(
            currentDate.toString(),
          ),
        ),
        onIndexChanged: (int newIndex) {
          setState(() {
            currentDate = DateTimeSwipe(
              currentDate,
              SwipeDirection(previousIndex, newIndex),
            ).swipedDatetime;

            previousIndex = newIndex;
          });

          print(currentDate);
        },
        itemCount: 3,
        control: new SwiperControl(),
      ),
    );
  }
}
