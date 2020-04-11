import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewHabitListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      appBar: PreferredSize(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Расписание\nна сегодня".toUpperCase(),
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
          ),
        ),
          preferredSize: Size.fromHeight(124),
      ),
      body: Column(
        children: <Widget>[
        ],
      ),
    );
  }
}
