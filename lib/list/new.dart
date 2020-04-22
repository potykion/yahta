import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yahta/list/habit_bloc.dart';
import 'package:yahta/list/widgets.dart';

extension StatusBarHeightComputing on BuildContext {
  get statusBarHeight => MediaQuery.of(this).padding.top;
}

buildSizedAppBar(BuildContext context, Widget appBar) => PreferredSize(
      child: appBar,
      preferredSize: Size.fromHeight(80 + context.statusBarHeight),
    );

class YAHabitListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildListView(),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return buildSizedAppBar(
      context,
      BlocBuilder<HabitBloc, HabitState>(
        builder: (BuildContext context, HabitState state) => DateRelationAppBar(
          dateRelationTitles: state.appBarTitles,
          dateRelationColors: state.appBarColors,
          onDateRelationChange: (dr) => BlocProvider.of<HabitBloc>(context).add(
            DateRelationChangedEvent(dr),
          ),
        ),
      ),
    );
  }

  Widget buildListView() => BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) => ListView(
          children: <Widget>[Text(state.selectedDateRelation.toString())],
        ),
      );
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
                widget.dateRelationTitles[selectedDateRelation]
                    .toUpperCase(),
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

class SwiperDots extends SwiperPlugin {
  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    return Row(
      children: <Widget>[
        config.activeIndex == 0
            ? StrokedCircle(
                innerColor: Colors.red,
              )
            : CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 10,
              ),
        Container(
          width: 5,
          height: 0,
        ),
        config.activeIndex == 1
            ? StrokedCircle(
                innerColor: Colors.red,
              )
            : CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 10,
              ),
        Container(
          width: 5,
          height: 0,
        ),
        config.activeIndex == 2
            ? StrokedCircle(
                innerColor: Colors.red,
              )
            : CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 10,
              ),
      ],
    );
  }
}
