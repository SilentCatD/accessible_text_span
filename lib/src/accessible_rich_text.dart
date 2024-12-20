import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'focusable_text_span_builder.dart';
import 'type.dart';

TextStyle defaultFocusedTextStyle(BuildContext context) {
  return DefaultTextStyle.of(context)
      .style
      .copyWith(backgroundColor: Theme.of(context).focusColor);
}

class AccessibleRichText extends StatefulWidget {
  const AccessibleRichText(
    this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    @Deprecated(
      'Use textScaler instead. '
      'Use of textScaleFactor was deprecated in preparation for the upcoming nonlinear text scaling support. '
      'This feature was deprecated after v3.12.0-2.0.pre.',
    )
    this.textScaleFactor,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.onTextSpanFocused,
    this.focusedStyle = defaultFocusedTextStyle,
    this.focusableTextSpanBuilder,
  });

  final TextSpan textSpan;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final TextScaler? textScaler;
  final OnTextSpanFocusChanged? onTextSpanFocused;
  final FocusedStyleBuilder focusedStyle;
  final FocusableTextSpanBuilder? focusableTextSpanBuilder;

  @override
  State<AccessibleRichText> createState() => _AccessibleRichTextState();
}

class _AccessibleRichTextState extends State<AccessibleRichText> {
  late final FocusableTextSpanBuilder _builder;
  bool _shouldDispose = true;

  @override
  void initState() {
    super.initState();
    final specifiedBuilder = widget.focusableTextSpanBuilder;
    if (specifiedBuilder != null) {
      _builder = specifiedBuilder;
      _shouldDispose = false;
    } else {
      _builder = FocusableTextSpanBuilder();
    }
  }

  void _handleUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (_shouldDispose) {
      _builder.dispose();
    }
    super.dispose();
  }

  TextSpan resolveTextSpan(BuildContext context, TextSpan textSpan) {
    final resolvedTextSpan = _builder.buildSpan(
      context,
      textSpan: widget.textSpan,
      onFocused: (index, focusNode) {
        _handleUpdate();
        widget.onTextSpanFocused?.call(index, focusNode);
      },
      textStyleBuilder: widget.focusedStyle,
    );
    return resolvedTextSpan;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTextSpan = resolveTextSpan(
      context,
      widget.textSpan,
    );
    return Text.rich(
      resolvedTextSpan,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaleFactor: widget.textScaleFactor,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
      textScaler: widget.textScaler,
    );
  }
}
