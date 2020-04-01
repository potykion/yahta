import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yahta/logic/core/date.dart';
import 'package:yahta/logic/core/swipe.dart';
import 'package:yahta/logic/habit/view_models.dart';

typedef Builder = Widget Function(BuildContext context);
typedef OnDaySwipe = void Function(DateTime dateTime);
typedef OnWeekChange = void Function(WeekDateRange weekDateRange);

class DaySwiper extends StatefulWidget {
  final Builder builder;
  final OnDaySwipe onDaySwipe;
  final DateTime currentDate;

  DaySwiper({@required this.builder, @required this.onDaySwipe, currentDate})
      : currentDate = currentDate ?? DateTime.now();

  @override
  _DaySwiperState createState() => _DaySwiperState();
}

class _DaySwiperState extends State<DaySwiper> {
  DateTime currentDate;
  var previousIndex = 0;

  @override
  void initState() {
    super.initState();
    currentDate = widget.currentDate;
  }

  @override
  Widget build(BuildContext context) => Swiper(
        itemBuilder: (context, _) => widget.builder(context),
        onIndexChanged: (int newIndex) {
          setState(() {
            currentDate = DateTimeSwipe(
              currentDate,
              SwipeDirection(previousIndex, newIndex),
            ).swipedDatetime;
            previousIndex = newIndex;
          });

          widget.onDaySwipe(currentDate);
        },
        itemCount: 3,
      );
}

class WeekSwiper extends StatefulWidget {
  final WeekDateRange weekDateRange;
  final Builder builder;
  final OnWeekChange onWeekChange;

  WeekSwiper({
    @required this.builder,
    @required this.onWeekChange,
    weekDateRange,
  }) : weekDateRange = weekDateRange ?? WeekDateRange(DateTime.now());

  @override
  _WeekSwiperState createState() => _WeekSwiperState();
}

class _WeekSwiperState extends State<WeekSwiper> {
  int previousIndex = 0;
  WeekDateRange currentWeekDateRange;

  @override
  void initState() {
    super.initState();
    currentWeekDateRange = widget.weekDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemBuilder: (context, __) => widget.builder(context),
      itemCount: 3,
      onIndexChanged: (int newIndex) async {
        var swipeDirection = SwipeDirection(previousIndex, newIndex);

        setState(() {
          currentWeekDateRange = swipeDirection.type == SwipeDirection.LEFT_TYPE
              ? currentWeekDateRange.nextWeekDateRange
              : currentWeekDateRange.previousWeekDateRange;
          previousIndex = newIndex;
        });

        widget.onWeekChange(currentWeekDateRange);
      },
    );
  }
}

typedef OnFrequencySelect = void Function(HabitMarkFrequency selectedFreq);

class FrequencyChart extends StatelessWidget {
  final HabitMarkSeries series;
  final Color color;
  final OnFrequencySelect onFrequencySelect;

  FrequencyChart({this.series, this.color, this.onFrequencySelect});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      [
        charts.Series<HabitMarkFrequency, DateTime>(
          id: "Freqs",
          data: series.series,
          domainFn: (HabitMarkFrequency mark, _) => mark.date,
          measureFn: (HabitMarkFrequency mark, _) => mark.freq,
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(color),
        ),
      ],
      // todo надо чтоб линия строилась при нажатии
      //  наверн оно не робит из-за того часто стейт обновляется
      // Событие нажатия на точку графика
      selectionModels: [
        charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: (selected) {
              var selectedFreq =
                  selected.selectedDatum.first.datum as HabitMarkFrequency;
              onFrequencySelect(selectedFreq);
            }),
      ],
      // Точечки
      defaultRenderer: charts.LineRendererConfig(includePoints: true),
      // Отключение анимации (бесит, когда отрабатывает анимация при смене типа привычки или свайпе)
      animate: false,
      // По оси Y откладывается на 1 деление больше (если макс значение в series - 1, то график будет рисоваться для 2)
      primaryMeasureAxis: new charts.NumericAxisSpec(
        tickProviderSpec: new charts.BasicNumericTickProviderSpec(
          dataIsInWholeNumbers: true,
          desiredTickCount: series.maxFreq + 2,
        ),
        showAxisLine: true,
      ),
      // todo по оси x отступы сделать от 0 и конца графика
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
