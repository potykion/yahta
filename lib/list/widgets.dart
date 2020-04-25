import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import 'habit_bloc.dart';

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
      itemBuilder: (context, index) => Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                widget.dateRelationTitles[selectedDateRelation].toUpperCase(),
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        color: widget.dateRelationColors[selectedDateRelation],
      ),
      index: selectedIndex,
      loop: false,
      onIndexChanged: (index) {
        setState(() {
          selectedIndex = index;
        });
        widget.onDateRelationChange(selectedDateRelation);
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
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
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
                  fontSize: 24,
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
