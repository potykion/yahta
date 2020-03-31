import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/core/swipe.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/logic/habit/view_models.dart';
import 'package:yahta/pages/habit.dart';
import 'package:yahta/styles.dart';
import 'package:yahta/utils.dart';
import 'package:yahta/widgets/core.dart';

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
                  MaterialPageRoute(builder: (_) => EditHabitPage()),
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

          // todo onSelected as contructor field
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FrequencyChart(
                        series: series,
                        color: color,
                        onFrequencySelect: (selectedFreq) {
                          var state =
                              Provider.of<HabitState>(context, listen: false);
                          state.setHabitMarkStatsDate(selectedFreq.date);
                        }),
                  ),
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

typedef OnTitleChanged = void Function(String newTitle);

class OutlinedInput extends StatefulWidget {
  final String initialText;
  final OnTitleChanged onTextChanged;

  OutlinedInput(this.initialText, this.onTextChanged);

  @override
  _OutlinedInputState createState() => _OutlinedInputState();
}

class _OutlinedInputState extends State<OutlinedInput> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();


    controller.text = widget.initialText;
    controller.addListener(() {
      widget.onTextChanged(controller.text);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: "Название",
          enabledBorder: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(),
        ),
      ),
    );
  }
}

