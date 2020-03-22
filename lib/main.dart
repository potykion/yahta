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
                child: Swiper(
                  itemBuilder: (context, index) {
                    if (state.loading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return HabitListView(state.habitVMs);
                  },
                  onIndexChanged: (int newIndex) {
                    state.swipeDate(SwipeDirection(previousIndex, newIndex));
                    setState(() {
                      previousIndex = newIndex;
                    });

                    state.loadDateHabits();
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
      },
    );
  }
}
