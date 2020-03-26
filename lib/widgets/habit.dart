import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahta/pages/habit.dart';
import 'package:yahta/styles.dart';
import 'package:yahta/utils.dart';

import '../habit.dart';

class HabitInput extends StatefulWidget {
  @override
  _HabitInputState createState() => _HabitInputState();
}

class _HabitInputState extends State<HabitInput> {
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
                    removeFocus(context);
                  }
                : null,
          ),
          enabledBorder: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(),
        ),
      );
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
              leading: HabitMarkCounter(vm),
              title: Text(vm.habit.title),
              onTap: () {
                var state = Provider.of<HabitState>(context, listen: false);
                state.setHabitToEdit(vm);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HabitPage()),
                );
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

class HabitTypePicker extends StatefulWidget {
  @override
  _HabitTypePickerState createState() => _HabitTypePickerState();
}

class _HabitTypePickerState extends State<HabitTypePicker> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    var state = Provider.of<HabitState>(context, listen: false);
    _selectedIndex = state.habitToEdit.habit.type.index;
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(HabitType.values.length, (index) {
          var habitType = HabitType.values[index];
          HabitTypeTheme theme = HabitTypeThemeMap[habitType];

          var selected = index == _selectedIndex;

          return ChoiceChip(
            label: theme.chipStyle.label,
            selected: selected,
            labelStyle: selected ? theme.chipStyle.textStyle : null,
            selectedColor: theme.chipStyle.background,
            onSelected: (bool selected) async {
              setState(() {
                _selectedIndex = index;
              });

              var state = Provider.of<HabitState>(context, listen: false);
              await state.updateHabitToEdit(habitType: habitType);
            },
          );
        }),
      );
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
