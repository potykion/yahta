import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/widgets/core.dart';
import 'package:yahta/widgets/list.dart';

class ListHabitsPage extends StatefulWidget {
  @override
  _ListHabitsPageState createState() => new _ListHabitsPageState();
}

class _ListHabitsPageState extends State<ListHabitsPage> {
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
                child: DaySwiper(
                  builder: (BuildContext context) => state.loading
                      ? Center(child: CircularProgressIndicator())
                      : HabitListView(state.habitVMs),
                  onDaySwipe: (DateTime dateTime) {
                    state.setCurrentDate(dateTime);
                    state.loadDateHabits();
                  },
                ),
              ),
              Container(
                child: CreateHabitInput(),
                margin: EdgeInsets.all(10),
              )
            ],
          ),
        );
      },
    );
  }
}
