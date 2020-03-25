import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahta/habit.dart';
import 'package:yahta/widgets/habit.dart';

enum HabitMenuAction { delete }

class HabitPage extends StatefulWidget {
  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Название",
                enabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
              ),
            ),
            HabitTypePicker(),
          ],
        ),
      ),
    );
  }
}
