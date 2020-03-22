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
    return MultiProvider(
      providers: [
        Provider<HabitRepo>(
          create: (_) => HabitRepo(Database(openConnection())),
        ),
        ChangeNotifierProvider<HabitState>(
          create: (context) =>
              HabitState(Provider.of<HabitRepo>(context, listen: false)),
        )
      ],
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var state = Provider.of<HabitState>(context, listen: false);
      await state.loadDateHabits(currentDate);
    });
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
              itemBuilder: (context, index) => Consumer<HabitState>(
                builder: (context, state, child) {
                  if (state.loading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return HabitListView(state.habitVMs);
                },
              ),
              onIndexChanged: (int newIndex) {
                setState(() {
                  currentDate = DateTimeSwipe(
                    currentDate,
                    SwipeDirection(previousIndex, newIndex),
                  ).swipedDatetime;
                  ;
                  previousIndex = newIndex;
                });

                Provider.of<HabitState>(context, listen: false).loadDateHabits(currentDate);
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
