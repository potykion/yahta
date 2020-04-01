import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/logic/habit/view_models.dart';
import 'package:yahta/pages/edit.dart';
import 'package:yahta/styles.dart';
import 'package:yahta/logic/core/context_apis.dart';

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
              leading: HabitMarkCounter(vm),
              title: Text(vm.habit.title),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditHabitPage(vm.habit.id)),
                );

                var state = Provider.of<HabitState>(context, listen: false);
                await state.loadDateHabits();
              },
              onLongPress: () async {
                var state = Provider.of<HabitState>(context, listen: false);
                await state.createHabitMark(vm.habit.id);
              },
            ),
          )
          .toList(),
    );
  }
}

class HabitMarkCounter extends StatelessWidget {
  final HabitViewModel vm;

  HabitMarkCounter(this.vm);

  @override
  Widget build(BuildContext context) {
    var theme = HabitTypeThemeMap[vm.habit.type];
    return CircleAvatar(
      child: Text(
        vm.habitMarks.length.toString(),
        style: theme.counterStyle.textStyle,
      ),
      backgroundColor: vm.habitMarks.length == 0
          ? theme.counterStyle.zeroBackgroundColor
          : theme.counterStyle.nonZeroBackgroundColor,
    );
  }
}

class CreateHabitInput extends StatefulWidget {
  @override
  _CreateHabitInputState createState() => _CreateHabitInputState();
}

class _CreateHabitInputState extends State<CreateHabitInput> {
  TextEditingController controller = TextEditingController();
  bool canAdd = false;

  @override
  void initState() {
    super.initState();
    controller
        .addListener(() => setState(() => canAdd = controller.text.length > 0));
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Заведи привычку",
          suffixIcon: IconButton(
            icon: Icon(Icons.add),
            onPressed: canAdd
                ? () async {
                    var state = Provider.of<HabitState>(context, listen: false);
                    await state.createHabit(controller.text);

                    controller.text = "";
                    context.removeFocus();
                  }
                : null,
          ),
          enabledBorder: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(),
        ),
      );
}