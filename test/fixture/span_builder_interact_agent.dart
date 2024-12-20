import 'package:flutter/material.dart';

abstract class SpanBuilderInteractAgent {
  void onFocusChanged(int index, FocusNode focusNode);

  TextStyle generateTextSpanStyle(BuildContext context);

  void onTap1();

  void onTap2();

}
