import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yahta/providers.dart';
import 'package:yahta/pages/list.dart';
import 'package:yahta/styles.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: providers,
        child: new MaterialApp(
          title: 'yahta',
          theme: AppTheme,
          home: ListHabitsPage(),
        ),
      );
}
