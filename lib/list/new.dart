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
        builder: (BuildContext context, HabitState state) => AppBars(
          titles: state.appBarTitles,
          colors: state.appBarColors,
        ),
      ),
    );
  }

  Widget buildListView() => ListView();
}

class AppBars extends StatelessWidget {
  final List<String> titles;
  final List<Color> colors;

  AppBars({this.titles, this.colors});

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(titles[index].toUpperCase(),
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        color: colors[index],
      ),
      index: 2,
      loop: false,
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
