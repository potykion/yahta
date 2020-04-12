import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NewHabitListPage extends StatefulWidget {
  @override
  _NewHabitListPageState createState() => _NewHabitListPageState();
}

class _NewHabitListPageState extends State<NewHabitListPage> {
  List<String> habits = ["Рисовать", "Читать", "Пилить трекер"];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      appBar: PreferredSize(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Расписание\nна сегодня".toUpperCase(),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
            ),
          ),
          color: Color(0xffF88181),
        ),
        preferredSize: Size.fromHeight(124),
      ),
      body: ListView.separated(
        itemCount: habits.length,
        separatorBuilder: (BuildContext context, int index) => SizedBox(
          height: 20,
        ),
        itemBuilder: (BuildContext context, int index) =>
            HabitRow(habitTitle: habits[index]),
      ),
    );
  }
}

class HabitRow extends StatefulWidget {
  const HabitRow({
    Key key,
    @required this.habitTitle,
  }) : super(key: key);

  final String habitTitle;

  @override
  _HabitRowState createState() => _HabitRowState();
}

class _HabitRowState extends State<HabitRow> {
  String habitTitle;
  double opacity = 1;
  SlidableController controller;

  @override
  void initState() {
    super.initState();
    habitTitle = widget.habitTitle;

    controller = SlidableController(
        onSlideAnimationChanged: (Animation<double> anim) {
          print(anim.value);
          setState(() {
            opacity = anim.value;
          });
        } ,
        onSlideIsOpenChanged: (open) {

        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableBehindActionPane(),
//      actionPane: SlidableScrollActionPane(),
//    actionPane: SlidableDrawerActionPane(),
//      actionPane: SlidableStrechActionPane(),
      child: Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 60,
            color: habitTitle == "Рисовать" ? null : Color(0xff95E1D3),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              habitTitle.toUpperCase(),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  decoration: habitTitle == "Рисовать"
                      ? null
                      : TextDecoration.lineThrough),
            ),
          ),
          Spacer(),
          Container(
            width: 8,
            height: 60,
            color: habitTitle != "Рисовать" ? null : Color(0xffF88181),
          )
        ],
      ),
      actions: <Widget>[],
      secondaryActions: <Widget>[
        Container(color: Color(0xffF88181).withOpacity(opacity),)

//        Container(
//          decoration: BoxDecoration(
//            gradient: LinearGradient(
//              begin: Alignment.centerRight,
//              end: Alignment.centerLeft,
//              colors: [Color(0xff95E1D3), Color(0xffF88181)],
//            ),
//          ),
//        )
      ],
      controller: controller,
    );
  }
}
