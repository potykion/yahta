import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/logic/habit/view_models.dart';
import 'package:yahta/styles.dart';
import 'package:yahta/widgets/core.dart';

typedef OnHabitTypeChange = void Function(HabitType habitType);

class HabitTypePicker extends StatefulWidget {
  final HabitType initialHabitType;
  final OnHabitTypeChange onHabitTypeChange;

  HabitTypePicker({
    @required this.initialHabitType,
    @required this.onHabitTypeChange,
  });

  @override
  _HabitTypePickerState createState() => _HabitTypePickerState();
}

class _HabitTypePickerState extends State<HabitTypePicker> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.initialHabitType.index;
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

              widget.onHabitTypeChange(habitType);
            },
          );
        }),
      );
}

class DayHabitMarkListView extends StatelessWidget {
  final List<HabitMark> marks;

  DayHabitMarkListView({@required this.marks});

  @override
  Widget build(BuildContext context) {
    var markListTiles = marks
        .map(
          (mark) => Dismissible(
            child: ListTile(
              title: Text(DateFormat.Hms().format(mark.datetime)),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => DatePicker.showTimePicker(
                  context,
                  onConfirm: (DateTime newDateTime) async {
                    await Provider.of<HabitState>(context, listen: false)
                        .updateHabitMark(mark, datetime: newDateTime);
                  },
                  currentTime: mark.datetime,
                ),
              ),
            ),
            key: Key(mark.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              child: ListTile(
                trailing: Icon(Icons.delete, color: Colors.red.shade100),
              ),
              color: Colors.red.shade500,
            ),
            onDismissed: (_) async {
              await Provider.of<HabitState>(context, listen: false)
                  .deleteHabitMark(mark);
            },
          ),
        )
        .toList();

    return ListView(children: markListTiles);
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

    currentDateWeekRange = WeekDateRange(DateTime.now());
  }

  // todo rewrite this
  @override
  Widget build(BuildContext context) {
    return Consumer<HabitState>(
      builder: (BuildContext context, HabitState state, Widget child) {
        HabitViewModel vm = state.habitToEdit;
        HabitMarkSeries series = HabitMarkSeries(
          vm.habitMarks,
          currentDateWeekRange,
          vm.minChartDateTime,
          vm.maxChartDateTime,
        );
        var color = HabitTypeThemeMap[vm.habit.type].primaryColor;

        List<Widget> widgets = [
          Flexible(
              child: WeekSwiper(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    currentDateWeekRange.toString(),
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                Flexible(
                  child: FrequencyChart(
                      series: series,
                      color: color,
                      onFrequencySelect: (selectedFreq) {
                        var state =
                            Provider.of<HabitState>(context, listen: false);
                        state.setHabitMarkStatsDate(selectedFreq.date);
                      }),
                ),
              ],
            ),
            onWeekChange: (WeekDateRange weekDateRange) async {
              setState(() {
                currentDateWeekRange = weekDateRange;
              });

              var state = Provider.of<HabitState>(context, listen: false);
              await state.loadWeeklyHabits(currentDateWeekRange);
              state.setHabitMarkStatsDate(null);
            },
          )),
        ];

        if (state.habitMarkStatsDate != null) {
          var dateMarks = state.habitToEdit.habitMarks
              .where(
                (mark) => DayDateTimeRange(state.habitMarkStatsDate)
                    .matchDatetime(mark.datetime),
              )
              .toList();

          widgets.add(
            Flexible(
              child: dateMarks.length > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 8, left: 16),
                            child: Text(
                              DateFormat.MMMMEEEEd()
                                  .format(state.habitMarkStatsDate),
                              style: Theme.of(context).textTheme.title,
                            ),
                          ),
                          Flexible(
                              child: DayHabitMarkListView(marks: dateMarks))
                        ])
                  : Text(
                      "Нет привычек за ${DayDateTimeRange(state.habitMarkStatsDate).toString()}"),
            ),
          );
        } else {
          widgets.add(Flexible(
            child: Container(),
          ));
        }

        return Column(children: widgets);
      },
    );
  }
}
