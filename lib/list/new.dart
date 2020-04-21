import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yahta/list/habit_bloc.dart';
import 'package:yahta/list/widgets.dart';
import 'package:yahta/list/widgets.dart';
import 'package:yahta/list/widgets.dart';

extension StatusBarHeightComputing on BuildContext {
  get statusBarHeight => MediaQuery.of(this).padding.top;
}

buildSizedAppBar(BuildContext context, Widget appBar) => PreferredSize(
      child: appBar,
      preferredSize: Size.fromHeight(84 + context.statusBarHeight),
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
        builder: (BuildContext context, HabitState state) {
          return DateRelationSwiper(

          );
        },
      ),
    );
  }

  Widget buildListView() => ListView();
}

class DateRelationSwiper extends StatefulWidget {
  @override
  _DateRelationSwiperState createState() => _DateRelationSwiperState();
}

class _DateRelationSwiperState extends State<DateRelationSwiper> {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemCount: 3,
      itemBuilder: (context, item) => Container(
        child: Center(child: Text(item.toString())),
        color: Colors.red,
      ),
      index: 2,
      pagination: SwiperPagination(
        alignment: Alignment.bottomLeft,
        builder: SwiperDots()
      ),
    );
  }
}

class SwiperDots extends SwiperPlugin {
  @override
  Widget build(BuildContext context, SwiperPluginConfig config) {
    return Row(children: <Widget>[
      config.activeIndex == 0 ? StrokedCircle(innerColor: Colors.red,) : CircleAvatar(backgroundColor: Colors.blue,radius: 10,),
      Container(width: 5, height: 0,),
      config.activeIndex == 1 ? StrokedCircle(innerColor: Colors.red,) : CircleAvatar(backgroundColor: Colors.blue,radius: 10,),
      Container(width: 5, height: 0,),
      config.activeIndex == 2 ? StrokedCircle(innerColor: Colors.red,) : CircleAvatar(backgroundColor: Colors.blue,radius: 10,),
    ],
    );
  }
}


