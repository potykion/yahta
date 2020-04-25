import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahta/list/habit_bloc.dart';
import 'package:yahta/list/widgets.dart';

extension StatusBarHeightComputing on BuildContext {
  get statusBarHeight => MediaQuery.of(this).padding.top;
}

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
  Widget build(BuildContext context) => Scaffold(
        appBar: buildAppBar(context),
        body: buildListView(),
      );

  PreferredSizeWidget buildAppBar(BuildContext context) => buildSizedAppBar(
        context,
        BlocBuilder<HabitBloc, HabitState>(
          builder: (BuildContext context, HabitState state) =>
              DateRelationAppBar(
            dateRelationTitles: state.appBarTitles,
            dateRelationColors: state.appBarColors,
            onDateRelationChange: (dr) => BlocProvider.of<HabitBloc>(context)
                .add(DateRelationChangedEvent(dr)),
          ),
        ),
      );

  buildSizedAppBar(BuildContext context, Widget appBar, {size: 70}) =>
      PreferredSize(
        child: appBar,
        preferredSize: Size.fromHeight(size + context.statusBarHeight),
      );

  Widget buildListView() => BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) => ListView.builder(
          itemBuilder: (context, index) =>
              HabitRow(state.habitViewModels[index]),
          itemCount: state.habitViewModels.length,
        ),
      );
}