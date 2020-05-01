import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yahta/list/habit_bloc.dart';
import 'package:yahta/list/view_models.dart';
import 'package:yahta/list/widgets.dart';
import 'package:yahta/logic/core/context_apis.dart';

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
    final appBarHeight = 120.0;
    final inputHeight = 60.0;
    var listViewHeight = MediaQuery.of(context).size.height - appBarHeight - inputHeight;

    return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          overflow: Overflow.visible,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 120, bottom: 60),
              child: Container(child: buildListView(), color: Colors.white,),
            ),

          Positioned(
            child: Container(
              child: BlocBuilder<HabitBloc, HabitState>(
                builder: (BuildContext context, HabitState state) =>
                  DateRelationAppBar(
                  dateRelationTitles: AppBarTitles,
                  dateRelationColors: state.appBarColors,
                  onDateRelationChange: (dr) => BlocProvider.of<HabitBloc>(context)
                      .add(DateRelationChangedEvent(dr)),
                 ),
              ),
              height: appBarHeight + 20,
              width: MediaQuery.of(context).size.width,
            ),
            top: 0,
          ),

            Positioned(child: Container(child: AddHabitForm(), width: MediaQuery.of(context).size.width, height: inputHeight, color: Colors.white,), bottom: 0,),

          ],
        ),
      );
  }


  buildSizedAppBar(BuildContext context, Widget appBar, {size: 50}) =>
      PreferredSize(
        child: appBar,
        preferredSize: Size.fromHeight(size + context.statusBarHeight),
      );

  Widget buildListView() => BlocBuilder<HabitBloc, HabitState>(
        builder: (context, state) => ListView.builder(
          itemBuilder: (context, index) =>
              HabitRow(state.dateRelationHabitViewModels[index]),
          itemCount: state.dateRelationHabitViewModels.length,
        ),
      );
}
