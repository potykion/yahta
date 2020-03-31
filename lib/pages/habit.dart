import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/styles.dart';
import 'package:yahta/widgets/habit.dart';

enum HabitMenuAction { delete }

class EditHabitPage extends StatefulWidget {
  @override
  _EditHabitPageState createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
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
            onSelected: (HabitMenuAction action) {
              if (action == HabitMenuAction.delete) {
                Provider.of<HabitState>(context, listen: false)
                    .deleteHabitToEdit();
                Navigator.pop(context);
              }
            },
          )
        ],
        title: Text("Инфа о привычке"),
        backgroundColor: HabitTypeThemeMap[
                Provider.of<HabitState>(context).habitToEdit.habit.type]
            .primaryColor,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: HabitTitleInput(
              Provider.of<HabitState>(context, listen: false)
                  .habitToEdit
                  .habit
                  .title,
              (String newTitle) =>
                  Provider.of<HabitState>(context, listen: false)
                      .updateHabitToEdit(title: newTitle),
            ),
          ),
          HabitTypePicker(),
          Flexible(child: WeeklyHabitMarkChart()),
        ],
      ),
    );
  }
}
