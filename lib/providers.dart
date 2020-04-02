import 'package:provider/provider.dart';
import 'package:yahta/logic/core/db.dart';
import 'package:yahta/logic/habit/db.dart';
import 'package:yahta/logic/habit/state.dart';

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
];