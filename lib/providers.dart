import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:yahta/logic/core/db.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/state.dart';
import 'package:yahta/list/habit_bloc.dart';

var providers = [
  Provider<Database>(
    create: (_) => Database(openConnection()),
    dispose: (_, db) => db.close(),
  ),
  Provider<HabitRepo>(
    create: (context) =>
        HabitRepo(Provider.of<Database>(context, listen: false)),
  ),
  ChangeNotifierProvider<ListHabitState>(
    create: (context) =>
        ListHabitState(Provider.of<HabitRepo>(context, listen: false)),
  ),
  ChangeNotifierProvider<EditHabitState>(
    create: (context) =>
        EditHabitState(Provider.of<HabitRepo>(context, listen: false)),
  ),
  BlocProvider(
    create: (context) => HabitBloc(Provider.of<HabitRepo>(context, listen: false)),
  )
];
