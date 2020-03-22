import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahta/utils.dart';

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
              var state = Provider.of<HabitState>(context, listen: false);
              await state.createHabit(controller.text);

              controller.text = "";
              removeFocus(context);
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
              leading: CircleAvatar(
                child: Text(vm.habitMarks.length.toString()),
              ),
              title: Text(vm.habit.title),
              onLongPress: () async {
                var state = Provider.of<HabitState>(context, listen: false);
                // todo пихать дату
                await state.createHabitMark(vm.habit.id);
              },
            ),
          )
          .toList(),
    );
  }
}
