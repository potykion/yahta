import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahta/logic/habit_bloc.dart';

class NewHabitListPage extends StatefulWidget {
  @override
  _NewHabitListPageState createState() => _NewHabitListPageState();
}

class _NewHabitListPageState extends State<NewHabitListPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<HabitBloc>(context).add(HabitsLoadedEvent());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      appBar: PreferredSize(
        child: BlocBuilder<HabitBloc, HabitState>(
          builder: (BuildContext context, state) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Расписание\nна сегодня".toUpperCase(),
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
                ),
              ),
              color:
                  state.habitsCompleted ? Color(0xff95E1D3) : Color(0xffF88181),
            );
          },
        ),
        preferredSize: Size.fromHeight(124),
      ),
      body: BlocBuilder<HabitBloc, HabitState>(
        builder: (BuildContext context, HabitState state) => ListView.separated(
          itemCount: state.habitsSorted.length,
          separatorBuilder: (BuildContext context, int index) => SizedBox(
            height: 20,
          ),
          itemBuilder: (BuildContext context, int index) =>
              HabitRow(state.habitsSorted[index]),
        ),
      ),
    );
  }
}

class HabitRow extends StatelessWidget {
  HabitViewModel habit;

  HabitRow(this.habit);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: CircleAvatar(
              backgroundColor:
                  habit.completed ? Color(0xff95E1D3) : Color(0xffF88181),
              radius: 10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
            child: Text(
              habit.title.toUpperCase(),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  decoration:
                      habit.completed ? TextDecoration.lineThrough : null),
            ),
          )
        ],
      ),
      key: Key(habit.id.toString()),
      confirmDismiss: (dir) async {
        BlocProvider.of<HabitBloc>(context).add(habit.completed
            ? HabitIncompletedEvent(habit.id)
            : HabitCompletedEvent(habit.id));

        return false;
      },
      direction: habit.completed
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart,
    );
  }
}
