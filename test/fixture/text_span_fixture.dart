import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const nonInteractSpans1 = TextSpan(text: "Hello");

TextSpan interactSpans1([VoidCallback? onTap]) =>
    TextSpan(text: "Hello", recognizer: TapGestureRecognizer()..onTap = onTap);
final nonInteractSpans2 = TextSpan(
  text: "Hello",
  children: [
    const TextSpan(
      text: "Hello 2",
    ),
    TextSpan(
      text: "Hello 3",
      children: [
        WidgetSpan(
          child: Container(
            width: 10,
            height: 10,
            color: Colors.red,
          ),
        ),
      ],
    ),
  ],
);
TextSpan interactSpans2([VoidCallback? onTap1, VoidCallback? onTap2]) => TextSpan(
  text: "Hello ",
  children: [
    TextSpan(
      text: "Hello 2 ",
      recognizer: TapGestureRecognizer()..onTap = onTap1,
    ),
    TextSpan(
      text: "Hello 3 ",
      recognizer: TapGestureRecognizer()..onTap = onTap2,
      children: [
        WidgetSpan(
          child: Container(
            width: 10,
            height: 10,
            color: Colors.red,
          ),
        ),
      ],
    ),
  ],
);
