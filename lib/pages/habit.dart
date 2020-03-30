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
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    var state = Provider.of<HabitState>(context, listen: false);
    controller.text = state.habitToEdit.habit.title;
    controller.addListener(() {
      state.updateHabitToEdit(title: controller.text);
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
          // todo изолировать
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Название",
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
              ),
            ),
          ),
          HabitTypePicker(),
          Flexible(child: WeeklyHabitMarkChart()),

        ],
      ),
    );
  }
}
