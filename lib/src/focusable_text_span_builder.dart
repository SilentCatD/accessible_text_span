import 'package:accessible_text_span/src/type.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Manage the creation of [FocusNode]s to build focusable [TextSpan]
class FocusableTextSpanBuilder {
  /// List of [FocusNode] used to build focusable [TextSpan]
  final List<FocusNode> nodes;

  /// Create the object that manage focusable [TextSpan] [FocusNode]s, building
  /// nested tree of input [TextSpan]
  /// Custom list of available [FocusNode] can be specified to have more fined
  /// grained control
  FocusableTextSpanBuilder({List<FocusNode> nodes = const []})
      : nodes = List.of(nodes, growable: true);

  /// Call this to dispose all of the current [FocusNode] managed by this object
  void dispose() {
    for (var e in nodes) {
      e.dispose();
    }
  }

  /// Recursively transforming input [TextSpan] into a similar structure of
  /// focusable [TextSpan]
  TextSpan buildSpan(
    BuildContext context, {
    required TextSpan textSpan,
    required OnTextSpanFocusChanged onFocused,
    required FocusedStyleBuilder textStyleBuilder,
  }) {
    int nodeIdx = 0;
    TextSpan performBuildSpans(TextSpan textSpan) {
      final List<InlineSpan> results = [];
      FocusNode? node;
      if (textSpan.recognizer != null &&
          textSpan.recognizer is TapGestureRecognizer) {
        node = nodes.elementAtOrNull(nodeIdx);
        int thisNodeIdx = nodeIdx;
        if (node == null) {
          final newNode = FocusNode();
          nodes.add(newNode);
          newNode.addListener(() => onFocused.call(thisNodeIdx, newNode));
          node = newNode;
        }
        nodeIdx++;
        final gestureRecognizer = textSpan.recognizer as TapGestureRecognizer;
        results.add(
          WidgetSpan(
            child: FocusableActionDetector(
              focusNode: node,
              includeFocusSemantics: node.hasPrimaryFocus,
              actions: {
                ActivateIntent:
                    CallbackAction<ActivateIntent>(onInvoke: (intent) {
                  gestureRecognizer.onTap?.call();
                  return null;
                }),
                ButtonActivateIntent:
                    CallbackAction<ButtonActivateIntent>(onInvoke: (intent) {
                  gestureRecognizer.onTap?.call();
                  return null;
                }),
              },
              child: ExcludeSemantics(
                excluding: !node.hasPrimaryFocus,
                child: Semantics(
                  label: textSpan.semanticsLabel ?? textSpan.text,
                  link: true,
                  onTap: () {
                    gestureRecognizer.onTap?.call();
                  },
                  child: Container(
                    width: 0.5,
                    height: 0.5,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      final List<InlineSpan> children = textSpan.children ?? [];
      for (var child in children) {
        if (child is TextSpan) {
          results.add(performBuildSpans(child));
        } else {
          results.add(child);
        }
      }
      return TextSpan(
        text: textSpan.text,
        children: results,
        style: (node?.hasPrimaryFocus ?? false)
            ? textStyleBuilder.call(context)
            : textSpan.style,
        recognizer: textSpan.recognizer,
        mouseCursor: textSpan.mouseCursor,
        onEnter: textSpan.onEnter,
        onExit: textSpan.onExit,
        semanticsLabel: textSpan.semanticsLabel,
        locale: textSpan.locale,
        spellOut: textSpan.spellOut,
      );
    }

    return performBuildSpans(textSpan);
  }
}
