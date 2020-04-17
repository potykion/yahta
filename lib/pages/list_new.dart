import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yahta/logic/habit_bloc.dart';

class NewHabitListPage extends StatefulWidget {
  @override
  _NewHabitListPageState createState() => _NewHabitListPageState();
}

class _NewHabitListPageState extends State<NewHabitListPage> {
  int swiperIndex = 2;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<HabitBloc>(context).add(HabitsLoadedEvent());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(appBar: buildListAppBar(), body: buildHabitList());
  }

  PreferredSize buildListAppBar() {
    return PreferredSize(
      child: BlocBuilder<HabitBloc, HabitState>(
        builder: (BuildContext context, state) {
          return Swiper(
            itemBuilder: (context, int index) => Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      state.dateRelationToStr,
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              color:
                  state.habitsCompleted ? Color(0xff95E1D3) : Color(0xffF88181),
            ),
            index: swiperIndex,
            itemCount: 3,
            loop: false,
            onIndexChanged: (index) {
              setState(() {
                swiperIndex = index;
              });
              BlocProvider.of<HabitBloc>(context).add(
                DateRelationChangedEvent(SwiperIndexToDateRelation[index]),
              );

              // todo load habits on-index-change
            },
          );
        },
      ),
      preferredSize: Size.fromHeight(124),
    );
  }

  BlocBuilder<HabitBloc, HabitState> buildHabitList() {
    return BlocBuilder<HabitBloc, HabitState>(
      builder: (BuildContext context, HabitState state) => ListView.separated(
        itemCount: state.habitsSorted.length,
        separatorBuilder: (BuildContext context, int index) => SizedBox(
          height: 20,
        ),
        itemBuilder: (BuildContext context, int index) =>
            HabitRow(state.habitsSorted[index]),
      ),
    );
  }
}

class HabitRow extends StatelessWidget {
  HabitViewModel habit;

  HabitRow(this.habit);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: CircleAvatar(
              backgroundColor:
                  habit.completed ? Color(0xff95E1D3) : Color(0xffF88181),
              radius: 10,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
            child: Text(
              habit.title.toUpperCase(),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  decoration:
                      habit.completed ? TextDecoration.lineThrough : null),
            ),
          )
        ],
      ),
      key: Key(habit.id.toString()),
      confirmDismiss: (dir) async {
        BlocProvider.of<HabitBloc>(context).add(habit.completed
            ? HabitIncompletedEvent(habit.id)
            : HabitCompletedEvent(habit.id));

        return false;
      },
      direction: habit.completed
          ? DismissDirection.startToEnd
          : DismissDirection.endToStart,
    );
  }
}
