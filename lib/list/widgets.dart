import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yahta/list/view_models.dart';
import 'package:yahta/logic/core/context_apis.dart';
import 'habit_bloc.dart';
import 'models.dart';

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

  /// Swiper(
  //              itemCount: 3,
  //              itemBuilder: (context, index) {
  //                return Stack(
  //                  children: <Widget>[
  //                    Positioned(child: Container(height: appBarHeight, color: Colors.red, width: MediaQuery.of(context).size.width,), top: 0),
  //                    Positioned(child: CircleAvatar(radius: 10, backgroundColor: Colors.blue), top: appBarHeight - 10.0,),
  //                  ],
  //                );
  //              },
  //            )

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemCount: OrderedDateRelations.length,
      itemBuilder: (context, index) {
        var previousDateRelation = SwiperIndexToDateRelation[index - 1];
        var dateRelation = SwiperIndexToDateRelation[index];
        var nextDateRelation = SwiperIndexToDateRelation[index + 1];

        var appBar = Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Align(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.dateRelationTitles[dateRelation].toUpperCase(),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              alignment: Alignment(0, 0.5),
            ),
          ),
          color: widget.dateRelationColors[dateRelation],
          height: 120,
          width: MediaQuery.of(context).size.width,
        );

        var bottom = -15.0;
        List<Widget> statusCircles = [];
        if (previousDateRelation != null) {
          statusCircles.add(Positioned(
            child: StrokedCircle(
              innerColor: widget.dateRelationColors[previousDateRelation],
            ),
            top: 120.0 -15,
            left: -15,
          ));
        }
        statusCircles.add(Positioned(
          child: StrokedCircle(
            innerColor: widget.dateRelationColors[dateRelation],
          ),
          top: 120.0 -15,
          left: 30,
        ));
        if (nextDateRelation != null) {
          statusCircles.add(Positioned(
            child: StrokedCircle(
              innerColor: widget.dateRelationColors[nextDateRelation],
            ),
            top: 120.0 -15,
            right: -15,
          ));
        }

        return Stack(
          overflow: Overflow.visible,
          children: [appBar].cast<Widget>() + statusCircles,
        );
      },
      index: selectedIndex,
      loop: false,
      onIndexChanged: (index) {
        setState(() {
          selectedIndex = index;
        });
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
    return Dismissible(
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
    );
  }
}

class AddHabitForm extends StatefulWidget {
  @override
  _AddHabitFormState createState() => _AddHabitFormState();
}

class _AddHabitFormState extends State<AddHabitForm> {
  String habitText = "";
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() => setState(() => habitText = controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: TextFormField(
        controller: controller,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'чем хочешь заниматься?',
          suffixIcon: habitText.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    BlocProvider.of<HabitBloc>(context)
                        .add(HabitCreatedEvent(habitText));
                    controller.text = "";
                    context.removeFocus();
                  },
                  icon: Icon(Icons.done),
                )
              : null,
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
    );
  }
}
