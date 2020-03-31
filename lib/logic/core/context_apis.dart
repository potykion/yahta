import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension T on BuildContext {
  T read<T>() => Provider.of<T>(this, listen: false);
}