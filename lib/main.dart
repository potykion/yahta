import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahta/providers.dart';

import 'list/list_page.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: providers,
        child: new MaterialApp(
          title: 'yahta',
          theme: ThemeData(
            fontFamily: "Montserrat",
            primaryColor: Color(0xff95E1D3),
            textSelectionColor: Color(0xff95E1D3),
            textSelectionHandleColor: Color(0xff95E1D3),
            cursorColor: Color(0xff95E1D3)
          ),
          home: YAHabitListPage(),
        ),
      );
}
