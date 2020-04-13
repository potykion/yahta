import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HabitViewModel {
  int id;
  String title;
  bool completed;

  HabitViewModel({this.id, this.title, this.completed = false});
}

class NewHabitListPage extends StatefulWidget {
  @override
  _NewHabitListPageState createState() => _NewHabitListPageState();
}

class _NewHabitListPageState extends State<NewHabitListPage> {
  List<HabitViewModel> habits = [
    HabitViewModel(id: 1, title: "Рисовать"),
    HabitViewModel(id: 2, title: "Читать"),
    HabitViewModel(id: 3, title: "Пилить трекер"),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      appBar: PreferredSize(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Расписание\nна сегодня".toUpperCase(),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
            ),
          ),
          color: habits.every((h) => h.completed) ? Color(0xff95E1D3) : Color(0xffF88181),
        ),
        preferredSize: Size.fromHeight(124),
      ),
      body: ListView.separated(
        itemCount: habits.length,
        separatorBuilder: (BuildContext context, int index) => SizedBox(
          height: 20,
        ),
        itemBuilder: (BuildContext context, int index) =>
            HabitRow(habits[index]),
      ),
    );
  }
}

class HabitRow extends StatefulWidget {
  final HabitViewModel habit;

  HabitRow(this.habit);

  @override
  _HabitRowState createState() => _HabitRowState();
}

class _HabitRowState extends State<HabitRow> {
  HabitViewModel habit;

  @override
  void initState() {
    super.initState();
    habit = widget.habit;
  }

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
                  decoration: habit.completed ? TextDecoration.lineThrough : null),
            ),
          )
        ],
      ),
      key: Key(habit.id.toString()),
      confirmDismiss: (dir) async {
        setState(() {
          habit.completed = !habit.completed;
        });

        return false;
      },
      direction: habit.completed
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart,
    );
  }
}
