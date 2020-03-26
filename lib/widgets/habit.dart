import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:yahta/logic/core/view_models.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/logic/habit/view_models.dart';
import 'package:yahta/pages/habit.dart';
import 'package:yahta/styles.dart';
import 'package:yahta/utils.dart';

class HabitInput extends StatefulWidget {
  @override
  _HabitInputState createState() => _HabitInputState();
}

class _HabitInputState extends State<HabitInput> {
  TextEditingController controller = TextEditingController();
  bool canAdd = false;

  @override
  void initState() {
    super.initState();
    controller
        .addListener(() => setState(() => canAdd = controller.text.length > 0));
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Заведи привычку",
          suffixIcon: IconButton(
            icon: Icon(Icons.add),
            onPressed: canAdd
                ? () async {
                    var state = Provider.of<HabitState>(context, listen: false);
                    await state.createHabit(controller.text);

                    controller.text = "";
                    removeFocus(context);
                  }
                : null,
          ),
          enabledBorder: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(),
        ),
      );
}

class HabitListView extends StatelessWidget {
  final List<HabitViewModel> habits;

  HabitListView(this.habits);

  @override
  Widget build(BuildContext context) {
    if (habits.length == 0) {
      return Center(child: Text("Привычек пока нет"));
    }

    return ListView(
      children: habits
          .map(
            (vm) => ListTile(
              leading: HabitMarkCounter(vm),
              title: Text(vm.habit.title),
              onTap: () async {
                var state = Provider.of<HabitState>(context, listen: false);
                await state.setHabitToEdit(vm);

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HabitPage()),
                );
                await state.loadDateHabits();
              },
              onLongPress: () async {
                var state = Provider.of<HabitState>(context, listen: false);
                await state.createHabitMark(vm.habit.id);
              },
            ),
          )
          .toList(),
    );
  }
}

class HabitTypePicker extends StatefulWidget {
  @override
  _HabitTypePickerState createState() => _HabitTypePickerState();
}

class _HabitTypePickerState extends State<HabitTypePicker> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    var state = Provider.of<HabitState>(context, listen: false);
    _selectedIndex = state.habitToEdit.habit.type.index;
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(HabitType.values.length, (index) {
          var habitType = HabitType.values[index];
          HabitTypeTheme theme = HabitTypeThemeMap[habitType];

          var selected = index == _selectedIndex;

          return ChoiceChip(
            label: theme.chipStyle.label,
            selected: selected,
            labelStyle:
                selected ? TextStyle(color: theme.chipStyle.textColor) : null,
            selectedColor: theme.chipStyle.background,
            onSelected: (bool selected) async {
              setState(() {
                _selectedIndex = index;
              });

              var state = Provider.of<HabitState>(context, listen: false);
              await state.updateHabitToEdit(habitType: habitType);
            },
          );
        }),
      );
}

class HabitMarkCounter extends StatelessWidget {
  final HabitViewModel vm;

  HabitMarkCounter(this.vm);

  @override
  Widget build(BuildContext context) {
    var theme = HabitTypeThemeMap[vm.habit.type];
    return CircleAvatar(
      child: Text(
        vm.habitMarks.length.toString(),
        style: theme.counterStyle.textStyle,
      ),
      backgroundColor: vm.habitMarks.length == 0
          ? theme.counterStyle.zeroBackgroundColor
          : theme.counterStyle.nonZeroBackgroundColor,
    );
  }
}

class WeeklyHabitMarkChart extends StatefulWidget {
  @override
  _WeeklyHabitMarkChartState createState() => _WeeklyHabitMarkChartState();
}

class _WeeklyHabitMarkChartState extends State<WeeklyHabitMarkChart> {
  var previousIndex = 0;
  WeekDateRange currentDateWeekRange;

  @override
  void initState() {
    super.initState();

    currentDateWeekRange = WeekDateRange(
        Provider.of<HabitState>(context, listen: false).currentDate);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitState>(
      builder: (BuildContext context, HabitState state, Widget child) {
        var vm = state.habitToEdit;
        var series = HabitMarkSeries(vm.habitMarks, currentDateWeekRange);
        var color = HabitTypeThemeMap[vm.habit.type].chartPrimaryColor;

        return Column(
          children: <Widget>[
            Text(
              "${currentDateWeekRange.toString()}",
            ),
            Flexible(
              child: Swiper(
                itemBuilder: (_, __) => charts.TimeSeriesChart(
                  [
                    charts.Series<HabitMarkFrequency, DateTime>(
                      id: "Habit marks",
                      data: series.series,
                      domainFn: (HabitMarkFrequency mark, _) => mark.date,
                      measureFn: (HabitMarkFrequency mark, _) => mark.freq,
                      colorFn: (_, __) => color,
                    ),
                  ],
                  defaultRenderer: charts.LineRendererConfig(includePoints: true),
                  animate: false,
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                    tickProviderSpec: new charts.BasicNumericTickProviderSpec(
                      dataIsInWholeNumbers: true,
                      desiredTickCount: series.maxFreq + 2,
                    ),
                  ),
                ),
                itemCount: 3,
                onIndexChanged: (int newIndex) async {
                  var swipeDirection = SwipeDirection(previousIndex, newIndex);

                  setState(() {
                    currentDateWeekRange =
                        swipeDirection.type == SwipeDirection.LEFT_TYPE
                            ? currentDateWeekRange.nextWeekDateRange
                            : currentDateWeekRange.previousWeekDateRange;
                    previousIndex = newIndex;
                  });

                  await Provider.of<HabitState>(context, listen: false)
                      .loadWeeklyHabits(currentDateWeekRange);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
