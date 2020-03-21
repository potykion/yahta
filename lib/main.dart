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
    return Provider<Database>(
      create: (context) {
        return Database(openConnection());
      },
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
              itemBuilder: (BuildContext context, int index) => StreamBuilder(
                stream: Provider.of<Database>(context, listen: false).listHabitsStream(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Habit>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      return Center(child: Text("Пока привычек нет", textAlign: TextAlign.center, ));
                    }

                    return ListView(
                        children: snapshot.data
                            .map(
                              (habit) => ListTile(
                                title: Text(habit.title),
                                onTap: () {},
                              ),
                            )
                            .toList());
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              onIndexChanged: (int newIndex) {
                setState(() {
                  currentDate = DateTimeSwipe(
                    currentDate,
                    SwipeDirection(previousIndex, newIndex),
                  ).swipedDatetime;
                  previousIndex = newIndex;
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
