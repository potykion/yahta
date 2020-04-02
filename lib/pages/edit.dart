import 'package:tuple/tuple.dart';
import 'package:yahta/logic/core/context_apis.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/logic/habit/view_models.dart';
import 'package:yahta/styles.dart';
import 'package:yahta/widgets/core.dart';
import 'package:yahta/widgets/edit.dart';

enum HabitMenuAction { delete }

class EditHabitPage extends StatefulWidget {
  final int habitId;

  EditHabitPage(this.habitId);

  @override
  _EditHabitPageState createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  @override
  void initState() {
    super.initState();

    context.read<EditHabitState>().habitToEdit = null;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<EditHabitState>().loadHabitToEdit(widget.habitId);
      await context
          .read<EditHabitState>()
          .loadWeeklyHabitMarks(WeekDateRange(DateTime.now()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
        actions: <Widget>[
          PopupMenuButton<HabitMenuAction>(
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
          )
        ],
        title: Text("Инфа о привычке"),
        backgroundColor: HabitTypeThemeMap[
                Provider.of<EditHabitState>(context).habitToEdit?.type ??
                    HabitType.positive]
            .primaryColor,
      ),
      body: context.read<EditHabitState>().habitToEdit == null
          ? Center(child: Text("Ща"))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OutlinedInput(
                  context.read<EditHabitState>().habitToEdit.title,
                  (text) =>
                      context.read<EditHabitState>().updateHabit(title: text),
                ),
                HabitTypePicker(
                  initialHabitType:
                      context.read<EditHabitState>().habitToEdit.type,
                  onHabitTypeChange: (habitType) => context
                      .read<EditHabitState>()
                      .updateHabit(habitType: habitType),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    context
                        .read<EditHabitState>()
                        .selectedDateWeekRange
                        .toString(),
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                Flexible(
                    child: WeekSwiper(
                  builder: (context) => Selector<
                      EditHabitState,
                      Tuple3<HabitMarkSeries, HabitTypeTheme,
                          OnFrequencySelect>>(
                    selector: (_, EditHabitState state) => Tuple3(
                      state.frequencyChartSeries,
                      state.typeTheme,
                      (freq) => state.setSelectedDate(freq.date),
                    ),
                    // todo FrequencyChart ререндерится оч часто
                    //  мб из-за context.read<EditHabitState>().habitToEdit == null - нет
                    //  хз поч все перерисовывается - опускаю руки пока
                    builder: (context, tuple, __) {
                      print("rerendered");

                      return FrequencyChart(
                        series: tuple.item1,
                        color: tuple.item2.primaryColor,
                        onFrequencySelect: tuple.item3,
                      );
                    },
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
                        : DayHabitMarkListView(
                            marks: context.read<EditHabitState>().dateMarks,
                          ),
                  ),
                )
              ],
            ),
    );
  }
}
