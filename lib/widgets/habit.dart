import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../habit.dart';

class HabitInput extends StatefulWidget {
  @override
  _HabitInputState createState() => _HabitInputState();
}

class _HabitInputState extends State<HabitInput> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: "Заведи привычку",
        suffixIcon: IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              var db = Provider.of<HabitRepo>(context, listen: false);
              await db.insertHabit(controller.text);
            }),
        enabledBorder: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(),
      ),
    );
  }
}

class HabitListView extends StatelessWidget {
  final List<Habit> habits;

  HabitListView(this.habits);

  @override
  Widget build(BuildContext context) => ListView(
        children: habits
            .map(
              (habit) => ListTile(
                title: Text(habit.title),
                onLongPress: () async {
                  var db = Provider.of<HabitRepo>(context, listen: false);
                  await db.insertHabitMark(habit.id);
                },
              ),
            )
            .toList(),
      );
}
