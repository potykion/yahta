import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yahta/list/view_models.dart';
import 'package:yahta/logic/core/context_apis.dart';
import 'edit_page.dart';
import 'habit_bloc.dart';
import 'models.dart';

class AppBarWithDots extends StatelessWidget {
  final String title;
  final Color appBarColor;
  final Color leftDotColor;
  final Color middleDotColor;
  final Color rightDotColor;
  final double appBarHeight = 120;
  final double dotRadius = 15;

  AppBarWithDots({
    @required this.title,
    @required this.appBarColor,
    middleDotColor,
    this.leftDotColor,
    this.rightDotColor,
  }) : this.middleDotColor = middleDotColor ?? appBarColor;

  @override
  Widget build(BuildContext context) {
    var appBar = Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Align(
          child: Text(
            this.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          alignment: Alignment(-1, 0.5),
        ),
      ),
      color: this.appBarColor,
      height: appBarHeight,
      width: MediaQuery.of(context).size.width,
    );

    List<Widget> dots = [
      leftDotColor != null
          ? Positioned(
              child: StrokedCircle(innerColor: leftDotColor),
              top: appBarHeight - dotRadius,
              left: -dotRadius,
            )
          : null,
      Positioned(
        child: StrokedCircle(innerColor: middleDotColor),
        top: appBarHeight - dotRadius,
        left: dotRadius * 2,
      ),
      rightDotColor != null
          ? Positioned(
              child: StrokedCircle(innerColor: rightDotColor),
              top: appBarHeight - dotRadius,
              right: -dotRadius,
            )
          : null
    ].where((dot) => dot != null).toList();

    return Container(
      child: Stack(children: [appBar].cast<Widget>() + dots),
      height: appBarHeight + dotRadius,
      color: Colors.white,
    );
  }
}

class StrokedCircle extends StatelessWidget {
  final Color innerColor;
  final Color outerColor;

  StrokedCircle({this.innerColor, this.outerColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        CircleAvatar(backgroundColor: this.outerColor, radius: 15),
        CircleAvatar(backgroundColor: this.innerColor, radius: 10),
      ],
    );
  }
}

typedef OnDateRelationChange = void Function(DateRelation dateRelation);

class DateRelationAppBar extends StatefulWidget {
  final DateRelation initialDateRelation;
  final Map<DateRelation, String> dateRelationTitles;
  final Map<DateRelation, Color> dateRelationColors;
  final OnDateRelationChange onDateRelationChange;

  DateRelationAppBar({
    this.dateRelationTitles,
    this.dateRelationColors,
    this.onDateRelationChange,
    this.initialDateRelation = DateRelation.today,
  });

  @override
  _DateRelationAppBarState createState() => _DateRelationAppBarState();
}

class _DateRelationAppBarState extends State<DateRelationAppBar> {
  int selectedIndex;

  get selectedDateRelation => SwiperIndexToDateRelation[selectedIndex];

  @override
  void initState() {
    super.initState();

    selectedIndex = DateRelationToSwiperIndex[widget.initialDateRelation];
  }

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemCount: OrderedDateRelations.length,
      itemBuilder: (context, index) {
        var previousDateRelation = SwiperIndexToDateRelation[index - 1];
        var dateRelation = SwiperIndexToDateRelation[index];
        var nextDateRelation = SwiperIndexToDateRelation[index + 1];

        return AppBarWithDots(
          title: widget.dateRelationTitles[dateRelation].toUpperCase(),
          appBarColor: widget.dateRelationColors[dateRelation],
          middleDotColor: widget.dateRelationColors[dateRelation],
          leftDotColor: widget.dateRelationColors[previousDateRelation],
          rightDotColor: widget.dateRelationColors[nextDateRelation],
        );
      },
      index: selectedIndex,
      loop: false,
      onIndexChanged: (index) {
        setState(() => selectedIndex = index);
        widget.onDateRelationChange(SwiperIndexToDateRelation[index]);
      },
    );
  }
}

class HabitRow extends StatelessWidget {
  final HabitViewModel viewModel;

  HabitRow(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditPage()),
        );
      },
      child: Dismissible(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 35),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: StatusToColorMap[viewModel.completionStatus],
                radius: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Text(
                  viewModel.title,
                  style: TextStyle(
                    fontSize: 18,
                    decoration:
                        viewModel.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
              )
            ],
          ),
        ),
        key: Key(viewModel.id.toString()),
        confirmDismiss: (DismissDirection dismissDirection) async {
          BlocProvider.of<HabitBloc>(context).add(viewModel.completed
              ? HabitIncompletedEvent(viewModel.id)
              : HabitCompletedEvent(viewModel.id));

          return false;
        },
        direction: viewModel.completed
            ? DismissDirection.startToEnd
            : DismissDirection.endToStart,
      ),
    );
  }
}

class AddHabitForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SubmittableInput(
        hint: 'чем хочешь заниматься?',
        onSubmit: (habitText) => BlocProvider.of<HabitBloc>(context)
            .add(HabitCreatedEvent(habitText)),
      );
}

typedef OnInput = void Function(String input);
typedef OnSubmit = void Function(String input);

class SubmittableInput extends StatefulWidget {
  final String hint;
  final OnInput onInput;
  final OnSubmit onSubmit;

  SubmittableInput({this.hint, this.onInput, this.onSubmit});

  @override
  _SubmittableInputState createState() => _SubmittableInputState();
}

class _SubmittableInputState extends State<SubmittableInput> {
  String inputText = "";
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      setState(() => inputText = controller.text);
      if (widget.onInput != null) widget.onInput(inputText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hint,
          suffixIcon: widget.onSubmit != null && inputText.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    widget.onSubmit(inputText);
                    WidgetsBinding.instance.addPostFrameCallback( (_) => controller.clear());
                    context.removeFocus();
                  },
                  icon: Icon(Icons.done),
                )
              : null,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }
}
