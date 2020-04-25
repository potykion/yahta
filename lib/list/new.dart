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
      preferredSize: Size.fromHeight(70 + context.statusBarHeight),
    );

class YAHabitListPage extends StatefulWidget {
  @override
  _YAHabitListPageState createState() => _YAHabitListPageState();
}

class _YAHabitListPageState extends State<YAHabitListPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<HabitBloc>(context).add(HabitsLoadedEvent());
  }

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
        builder: (context, state) => ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            var viewModel = state.habitViewModels[index];

            return Dismissible(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor:
                          StatusToColorMap[viewModel.completionStatus],
                      radius: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: Text(
                        viewModel.title,
                        style: TextStyle(
                          fontSize: 24,
                          decoration: viewModel.completed
                              ? TextDecoration.lineThrough
                              : null,
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
          },
          itemCount: state.habitViewModels.length,
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