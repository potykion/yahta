import 'package:flutter/material.dart';

import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:yahta/direction.dart';
import 'package:yahta/habit.dart';
import 'package:yahta/widgets/habit.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HabitState>(
      create: (context) => HabitState(
        HabitRepo(
          Database(openConnection()),
        ),
      ),
      child: new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(
          primarySwatch: Colors.green,
        ),
        home: new MyHomePage(title: 'Flutter Demo Home Page'),
      ),
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

  Future<List<HabitViewModel>> habitVMsFuture;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    var state = Provider.of<HabitState>(context);
    habitVMsFuture = state.loadDateHabits(currentDate);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(DayDateTimeRange(currentDate).toString()),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: Swiper(
              itemBuilder: (context, index) => FutureBuilder(
                future: habitVMsFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return HabitListView(snapshot.data);
                },
              ),
              onIndexChanged: (int newIndex) {
                var newDate = DateTimeSwipe(
                  currentDate,
                  SwipeDirection(previousIndex, newIndex),
                ).swipedDatetime;

                setState(() {
                  currentDate = newDate;
                  previousIndex = newIndex;
                  habitVMsFuture = Provider.of<HabitState>(context, listen: false)
                      .loadDateHabits(newDate);

                });

              },
              itemCount: 3,
            ),
          ),
          Container(
            child: HabitInput(),
            margin: EdgeInsets.all(10),
          )
        ],
      ),
    );
  }
}
