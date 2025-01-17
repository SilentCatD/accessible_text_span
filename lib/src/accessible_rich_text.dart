import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'focusable_text_span_builder.dart';
import 'type.dart';

/// Default focused style for interactive [TextSpan] when focused by keyboard
TextStyle defaultFocusedTextStyle(BuildContext context, TextStyle? spanStyle) {
  return (spanStyle ?? DefaultTextStyle.of(context).style)
      .copyWith(backgroundColor: Theme.of(context).focusColor);
}

/// Alternative of [RichText] or [Text.rich] widget that allow [TextSpan] with
/// [TapGestureRecognizer] to be focused and activated using keyboard
/// Support accessibility use cases for keyboard navigation user following
/// https://github.com/flutter/flutter/issues/138692
/// Talkback is also supported when the interactive [TextSpan] is focused
class AccessibleRichText extends StatefulWidget {
  /// Creates a text widget with [TextSpan]s that are focusable when
  /// [TextSpan.recognizer] is [TapGestureRecognizer].
  ///
  /// The following subclasses of [InlineSpan] may be used to build rich text:
  ///
  /// * [TextSpan]s define text and children [InlineSpan]s.
  /// * [WidgetSpan]s define embedded inline widgets.
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

  /// The text to display as a [InlineSpan].
  final TextSpan textSpan;

  /// If non-null, the style to use for this text.
  ///
  /// If the style's "inherit" property is true, the style will be merged with
  /// the closest enclosing [DefaultTextStyle]. Otherwise, the style will
  /// replace the closest enclosing [DefaultTextStyle].
  final TextStyle? style;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [data] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was unlimited horizontal space.
  final bool? softWrap;

  /// How visual overflow should be handled.
  ///
  /// If this is null [TextStyle.overflow] will be used, otherwise the value
  /// from the nearest [DefaultTextStyle] ancestor will be used.
  final TextOverflow? overflow;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  ///
  /// If this is null, but there is an ambient [DefaultTextStyle] that specifies
  /// an explicit number for its [DefaultTextStyle.maxLines], then the
  /// [DefaultTextStyle] value will take precedence. You can use a [RichText]
  /// widget directly to entirely override the [DefaultTextStyle].
  final int? maxLines;

  /// {@macro flutter.widgets.Text.semanticsLabel}
  final String? semanticsLabel;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// {@macro dart.ui.textHeightBehavior}
  final ui.TextHeightBehavior? textHeightBehavior;

  /// The color to use when painting the selection.
  ///
  /// This is ignored if [SelectionContainer.maybeOf] returns null
  /// in the [BuildContext] of the [Text] widget.
  ///
  /// If null, the ambient [DefaultSelectionStyle] is used (if any); failing
  /// that, the selection color defaults to [DefaultSelectionStyle.defaultColor]
  /// (semi-transparent grey).
  final Color? selectionColor;

  /// {@macro flutter.painting.textPainter.textScaler}
  final TextScaler? textScaler;

  /// Fire when a interactive [TextSpan] with [TapGestureRecognizer] is focused
  /// using keyboard navigation, with its index and [FocusNode] in the [TextSpan]
  /// tree
  final OnTextSpanFocusChanged? onTextSpanFocused;

  /// [TextStyle] that will be chosen for displayed focused interactive
  /// [TextSpan], default to [defaultFocusedTextStyle], which will render a
  /// [Theme.of(context).focusedColor] color
  final FocusedStyleBuilder focusedStyle;

  /// Object that manage the creation and dispose of [FocusNode] of interactive
  /// [TextSpan]s
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
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
      textScaler: widget.textScaler,
    );
  }
}
