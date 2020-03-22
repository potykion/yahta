import 'package:flutter/material.dart';

removeFocus(context) {
  /// Убирает фокус (обычно с текст-филда)
  /// https://github.com/flutter/flutter/issues/7247
  FocusScope.of(context).requestFocus(new FocusNode());
}
