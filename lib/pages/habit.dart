import 'package:yahta/logic/core/context_apis.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/styles.dart';
import 'package:yahta/widgets/habit.dart';

enum HabitMenuAction { delete }

class EditHabitPage extends StatefulWidget {
  final int habitId;

  EditHabitPage(this.habitId);

  @override
  _EditHabitPageState createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var state = Provider.of<EditHabitState>(context, listen: false);
      await state.loadHabitToEdit(widget.habitId);
      await state.loadWeeklyHabitMarks(WeekDateRange(DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        actions: <Widget>[
          PopupMenuButton<HabitMenuAction>(
            itemBuilder: (context) => [
              PopupMenuItem<HabitMenuAction>(
                value: HabitMenuAction.delete,
                child: Text('Удалить'),
              )
            ],
            onSelected: (HabitMenuAction action) async {
              if (action == HabitMenuAction.delete) {
                await context.read<EditHabitState>().deleteHabitToEdit();
                Navigator.pop(context);
              }
            },
          )
        ],
        title: Text("Инфа о привычке"),
        backgroundColor: HabitTypeThemeMap[
                Provider.of<EditHabitState>(context).habitToEdit.type]
            .primaryColor,
      ),
      body: Column(
        children: <Widget>[
          OutlinedInput(
            context.read<EditHabitState>().habitToEdit.title,
            (text) => context.read<EditHabitState>().updateHabit(title: text),
          ),
          HabitTypePicker(
            initialHabitType: context.read<EditHabitState>().habitToEdit.type,
            onHabitTypeChange: (habitType) => context
                .read<EditHabitState>()
                .updateHabit(habitType: habitType),
          ),
          Flexible(child: WeeklyHabitMarkChart()),
        ],
      ),
    );
  }
}
