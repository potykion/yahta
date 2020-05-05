import 'package:flutter/material.dart';
import 'package:yahta/list/models.dart';
import 'package:yahta/list/view_models.dart';
import 'package:yahta/list/widgets.dart';

class EditPage extends StatefulWidget {
  HabitViewModel viewModel;

  EditPage(this.viewModel);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Dismissible(
            child: AppBarWithDots(
              title: "Редактирование\nпривычки",
              appBarColor: StatusToColorMap[CompletionStatus.positive],
            ),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (_) async {
              Navigator.pop(context);
              return false;
            },
            key: Key("app-bar"),
          ),
          Flexible(
            child: Container(
              child: Column(
                children: <Widget>[
                  SubmittableInput(
                    initialText: widget.viewModel.title,
                    hint: "У привычки должно быть имя",
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "перестать отслеживать",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        onPressed: () {},
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        color: Colors.white,
                        elevation: 10,
                      ),
                    ),
                  )
                ],
              ),
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
