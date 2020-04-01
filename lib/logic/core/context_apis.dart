import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension T on BuildContext {
  T read<T>() => Provider.of<T>(this, listen: false);

  /// Убирает фокус (обычно с текст-филда)
  /// https://github.com/flutter/flutter/issues/7247
  removeFocus() => FocusScope.of(this).requestFocus(new FocusNode());
}