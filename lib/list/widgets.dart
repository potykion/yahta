import 'package:flutter/material.dart';
import 'package:yahta/list/smth.dart';

Map<CompletionStatus, Color> StatusToColorMap = {
  CompletionStatus.positive: Color(0xff95E1D3),
  CompletionStatus.neutral: Color(0xffFCE38A),
  CompletionStatus.negative: Color(0xffF88181),
};

class StrokedCircle extends StatelessWidget {
  final Color innerColor;
  final Color outerColor;

  StrokedCircle({this.innerColor, this.outerColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        CircleAvatar(backgroundColor: this.outerColor, radius: 15),
        CircleAvatar(backgroundColor: this.innerColor, radius: 10),
      ],
    );
  }
}

class PageAppBar extends StatelessWidget {
  final String text;
  final Color color;

  PageAppBar({this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(
            top: 0 + MediaQuery.of(context).padding.top,
            bottom: 0.0,
            left: 30,
            right: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              this.text.toUpperCase(),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      color: this.color,
    );
  }
}
