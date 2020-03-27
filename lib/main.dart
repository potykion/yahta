import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:yahta/widgets/core.dart';
import 'package:yahta/widgets/habit.dart';

import 'logic/core/date.dart';
import 'logic/core/db.dart';
import 'logic/habit/db.dart';
import 'logic/habit/state.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Database>(
          create: (_) => Database(openConnection()),
          dispose: (_, db) => db.close(),
        ),
        Provider<HabitRepo>(
          create: (context) =>
              HabitRepo(Provider.of<Database>(context, listen: false)),
        ),
        ChangeNotifierProvider<HabitState>(
          create: (context) =>
              HabitState(Provider.of<HabitRepo>(context, listen: false)),
        )
      ],
      child: new MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var state = Provider.of<HabitState>(context, listen: false);
      await state.loadDateHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitState>(
      builder: (BuildContext context, HabitState state, Widget child) {
        return new Scaffold(
          appBar: AppBar(
            title: Text(DayDateTimeRange(state.currentDate).toString()),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Flexible(
                child: DayDateTimeRangeSwiper(
                  builder: (BuildContext context) {
                    if (state.loading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return HabitListView(state.habitVMs);
                  },
                  onDaySwipe: (DateTime dateTime) {
                    state.setCurrentDate(dateTime);
                    state.loadDateHabits();
                  },
                ),
              ),
              Container(
                child: HabitInput(),
                margin: EdgeInsets.all(10),
              )
            ],
          ),
        );
      },
    );
  }
}
