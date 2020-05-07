import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yahta/list/habit_bloc.dart';
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
          BlocBuilder<HabitBloc, HabitState>(
            builder: (BuildContext context, state) => Container(
              child: Swiper(
                itemCount: 2,
                loop: false,
                index: 1,
                itemBuilder: (context, index) {
                  if (index == 1) {
                    return AppBarWithDots(
                      title: "Редактирование\nпривычки".toUpperCase(),
                      appBarColor: StatusToColorMap[CompletionStatus.positive],
                      leftDotColor: state.selectedDateRelationColor,
                    );
                  }

                  if (index == 0) {
                    return AppBarWithDots(
                      title: "",
                      appBarColor: state.selectedDateRelationColor,
                      rightDotColor: state.selectedDateRelationColor,
                    );
                  }

                  throw Exception("Invalid index: $index");
                },
                onIndexChanged: (_) => Navigator.pop(context),
              ),
              height: AppBarWithDots.appBarHeight + AppBarWithDots.dotRadius,
            ),
          ),
          Flexible(
            child: Container(
              child: Column(
                children: <Widget>[
                  SubmittableInput(
                    initialText: widget.viewModel.title,
                    hint: "У привычки должно быть имя",
                    onInput: (title) => BlocProvider.of<HabitBloc>(context).add(
                        HabitUpdatedEvent(widget.viewModel.id, title: title)),
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
