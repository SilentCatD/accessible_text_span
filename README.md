<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

[![codecov](https://codecov.io/github/SilentCatD/accessible_text_span/graph/badge.svg?token=wTay7Q3ild)](https://codecov.io/github/SilentCatD/accessible_text_span) [![pub package](https://img.shields.io/pub/v/accessible_text_span?color=green&include_prereleases&style=plastic)](https://pub.dev/packages/accessible_text_span)

<img src="https://github.com/SilentCatD/accessible_text_span/blob/main/assets/focusable.gif?raw=true" width="200px">

## Features

First import the widget

```dart
import 'package:accessible_text_span/accessible_text_span.dart';
```

When implementing accessibility, enabling keyboard navigation for interactive elements is crucial.

However, due to a current
limitation ([Flutter issue #138692](https://github.com/flutter/flutter/issues/138692)),
navigating and interacting with a `TextSpan` is not yet supported.

This package is designed to address this limitation by providing a solution to make `TextSpan`
accessible for both TalkBack and keyboard navigation when the user pressing **TAB** or **ENTER**

## Usage

```dart
AccessibleRichText(
  TextSpan(
    children: [
      TextSpan(
        text: "link 1",
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // on link tap or activated by keyboard
          },
      ),
      const TextSpan(
        text: "and ",
      ),
      TextSpan(
        text: "link 2",
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // on link tap or activated by keyboard
          },
      ),
    ],
  ),
  focusedStyle: (context, spanStyle) {
    return (spanStyle ?? DefaultTextStyle.of(context).style).copyWith(
          decoration: TextDecoration.underline,
          backgroundColor: Colors.grey,
          color: Colors.purple,
        );
  },
),
```

Replace the `Text.rich` or `RichText` widget in your app with the `AccessibleRichText` widget.

To make a specific `TextSpan` focusable, it must include a `TextSpan.recognizer` of type 
`TapGestureRecognizer`.

The visual representation of a focused `TextSpan` can be customized using the 
`AccessibleRichText.focusedStyle` property.

For manual manipulation and management of `FocusNode`, you can create and provide your own instance 
of `FocusableTextSpanBuilder`.

Pressing **TAB** will navigating through created focusable `TextSpan` while **ENTER** will activate
the associated `TapGestureRecognizer.onTap` function.
