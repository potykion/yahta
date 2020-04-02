import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/logic/habit/view_models.dart';
import 'package:yahta/styles.dart';
import 'package:yahta/logic/core/context_apis.dart';
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
                  onConfirm: (DateTime newDateTime) async => await context
                      .read<EditHabitState>()
                      .updateHabitMark(mark, datetime: newDateTime),
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
              await context.read<EditHabitState>().deleteHabitMark(mark);
            },
          ),
        )
        .toList();

    return ListView(children: markListTiles);
  }
}

enum HabitMenuAction { delete }

class HabitPopupMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HabitMenuAction>(
      itemBuilder: (context) => [
        PopupMenuItem<HabitMenuAction>(
          value: HabitMenuAction.delete,
          child: Text('Удалить'),
        )
      ],
      onSelected: (HabitMenuAction action) async {
        if (action == HabitMenuAction.delete) {
          await context.read<EditHabitState>().deleteHabitToEdit();
          Navigator.pop(context);
        }
      },
    );
  }
}

class HabitFreqChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TitleText(
            context.read<EditHabitState>().selectedDateWeekRange.toString()),
        Flexible(
            child: WeekSwiper(
          builder: (context) => Selector<EditHabitState,
              Tuple3<HabitMarkSeries, HabitTypeTheme, OnFrequencySelect>>(
            selector: (_, EditHabitState state) => Tuple3(
              state.frequencyChartSeries,
              state.typeTheme,
              (freq) => state.setSelectedDate(freq.date),
            ),
            // todo FrequencyChart ререндерится оч часто
            //  мб из-за context.read<EditHabitState>().habitToEdit == null - нет
            //  хз поч все перерисовывается - опускаю руки пока
            builder: (context, tuple, __) => FrequencyChart(
              series: tuple.item1,
              color: tuple.item2.primaryColor,
              onFrequencySelect: tuple.item3,
            ),
          ),
          onWeekChange: (WeekDateRange weekDateRange) async {
            var state = context.read<EditHabitState>();

            state.setSelectedWeekRange(weekDateRange);
            state.setSelectedDate(null);
            await state.loadWeeklyHabitMarks();
          },
        )),
        Flexible(
          child: Selector<EditHabitState, DateTime>(
            selector: (_, state) => state.selectedDate,
            builder: (_, date, __) => date == null
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TitleText(DateFormat.MMMMEEEEd()
                          .format(context.read<EditHabitState>().selectedDate)),
                      Flexible(
                        child: DayHabitMarkListView(
                          marks: context.read<EditHabitState>().dateMarks,
                        ),
                      ),
                    ],
                  ),
          ),
        )
      ],
    );
  }
}
