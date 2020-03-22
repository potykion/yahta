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
  final List<HabitViewModel> habits;

  HabitListView(this.habits);

  @override
  Widget build(BuildContext context) {
    if (habits.length == 0) {
      return Center(child: Text("Привычек пока нет"));
    }

    return ListView(
      children: habits
          .map(
            (vm) => ListTile(
              title: Text(vm.habit.title),
              onLongPress: () async {
                var db = Provider.of<HabitRepo>(context, listen: false);
                await db.insertHabitMark(vm.habit.id);
              },
            ),
          )
          .toList(),
    );
  }
}