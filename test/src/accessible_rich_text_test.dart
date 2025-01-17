import 'dart:ui';

import 'package:accessible_text_span/accessible_text_span.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../fixture/span_builder_interact_agent.dart';
import '../fixture/text_span_fixture.dart';
import 'accessible_rich_text_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SpanBuilderInteractAgent>(),
  MockSpec<FocusableTextSpanBuilder>()
])
void main() {
  late MockSpanBuilderInteractAgent agent;
  late FocusableTextSpanBuilder builder;

  setUp(() {
    agent = MockSpanBuilderInteractAgent();
    builder = FocusableTextSpanBuilder();
  });

  testWidgets("render non interact span depth 1", (tester) async {
    addTearDown(() {
      builder.dispose();
    });
    final mockBuilder = MockFocusableTextSpanBuilder();
    when(
      mockBuilder.buildSpan(
        any,
        textSpan: anyNamed('textSpan'),
        onFocused: anyNamed('onFocused'),
        textStyleBuilder: anyNamed('textStyleBuilder'),
      ),
    ).thenReturn(nonInteractSpans1);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AccessibleRichText(
          nonInteractSpans1,
          focusableTextSpanBuilder: mockBuilder,
          focusedStyle: agent.generateTextSpanStyle,
          onTextSpanFocused: agent.onFocusChanged,
        ),
      ),
    );

    final renderedText = find.text(nonInteractSpans1.toPlainText());
    expect(renderedText, findsOne);

    verify(mockBuilder.buildSpan(
      any,
      textSpan: nonInteractSpans1,
      onFocused: anyNamed('onFocused'),
      textStyleBuilder: anyNamed('textStyleBuilder'),
    )).called(1);
  });
  testWidgets("non dispose called", (tester) async {
    addTearDown(() {
      builder.dispose();
    });
    final mockBuilder = MockFocusableTextSpanBuilder();
    when(
      mockBuilder.buildSpan(
        any,
        textSpan: anyNamed('textSpan'),
        onFocused: anyNamed('onFocused'),
        textStyleBuilder: anyNamed('textStyleBuilder'),
      ),
    ).thenReturn(nonInteractSpans1);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AccessibleRichText(
          nonInteractSpans1,
          focusableTextSpanBuilder: mockBuilder,
          focusedStyle: agent.generateTextSpanStyle,
          onTextSpanFocused: agent.onFocusChanged,
        ),
      ),
    );

    await tester.pumpWidget(Container());

    verifyNever(mockBuilder.dispose());
  });

  testWidgets("dispose called", (tester) async {
    addTearDown(() {
      builder.dispose();
    });
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AccessibleRichText(
          nonInteractSpans1,
          focusedStyle: agent.generateTextSpanStyle,
          onTextSpanFocused: agent.onFocusChanged,
        ),
      ),
    );
  });

  testWidgets("nested span", (tester) async {
    addTearDown(() {
      builder.dispose();
    });
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AccessibleRichText(
          interactSpans2(),
          focusedStyle: agent.generateTextSpanStyle,
          onTextSpanFocused: agent.onFocusChanged,
        ),
      ),
    );

    final renderedContainer =
        tester.widgetList<Container>(find.byType(Container));
    expect(renderedContainer.length, 3);
    expect(renderedContainer.last.color, Colors.red);
  });

  testWidgets("focus changed", (tester) async {
    addTearDown(() {
      builder.dispose();
    });
    when(agent.generateTextSpanStyle(any, any))
        .thenReturn(const TextStyle(color: Colors.blue));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AccessibleRichText(
          interactSpans2(),
          focusableTextSpanBuilder: builder,
          onTextSpanFocused: agent.onFocusChanged,
          focusedStyle: agent.generateTextSpanStyle,
        ),
      ),
    );

    builder.nodes.elementAt(0).requestFocus();
    await tester.pumpAndSettle();

    verify(agent.generateTextSpanStyle(any, any)).called(1);
    verify(agent.onFocusChanged(0, builder.nodes.elementAt(0))).called(1);

    final renderedText = find.textContaining('Hello 2', findRichText: true);
    expect(renderedText, findsOne);
  });

  testWidgets("focused default style", (tester) async {
    addTearDown(() {
      builder.dispose();
    });
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AccessibleRichText(
          interactSpans1(),
          focusableTextSpanBuilder: builder,
          onTextSpanFocused: agent.onFocusChanged,
        ),
      ),
    );

    builder.nodes.elementAt(0).requestFocus();
    await tester.pumpAndSettle();
  });

  testWidgets("Semantic interaction when non focused", (tester) async {
    addTearDown(() {
      builder.dispose();
    });
    final span = interactSpans2();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AccessibleRichText(
          span,
          focusableTextSpanBuilder: builder,
        ),
      ),
    );

    final focusableSemanticFinder = find.semantics.byFlag(SemanticsFlag.isLink);
    expect(focusableSemanticFinder, findsNothing);
  });

  testWidgets("Semantic interaction when primary focused", (tester) async {
    addTearDown(() {
      builder.dispose();
    });
    final span = interactSpans2();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AccessibleRichText(
          span,
          focusableTextSpanBuilder: builder,
        ),
      ),
    );

    builder.nodes[0].requestFocus();
    await tester.pumpAndSettle();
    final focusableSemanticFinder = find.semantics.byFlag(SemanticsFlag.isLink);
    expect(focusableSemanticFinder, findsExactly(1));
    expect(focusableSemanticFinder.found.first.label, "Hello 2 ");
  });

  testWidgets("Semantic interaction tap", (tester) async {
    addTearDown(() {
      builder.dispose();
    });
    final span = interactSpans2();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AccessibleRichText(
          span,
          focusableTextSpanBuilder: builder,
        ),
      ),
    );

    builder.nodes[0].requestFocus();
    await tester.pumpAndSettle();
    final focusableSemanticFinder = find.semantics.byFlag(SemanticsFlag.isLink);
    tester.semantics.tap(focusableSemanticFinder);
  });

  testWidgets("invoke intent interaction", (tester) async {
    final span = interactSpans2(
      agent.onTap1,
      agent.onTap2,
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AccessibleRichText(
          span,
          focusableTextSpanBuilder: builder,
        ),
      ),
    );

    final focusableFinder = find.descendant(
      of: find.byType(FocusableActionDetector),
      matching: find.byType(Container),
    );
    expect(focusableFinder, findsExactly(2));
    final firstAction = tester.element(focusableFinder.first);
    final secondAction = tester.element(focusableFinder.last);

    Actions.invoke<ActivateIntent>(firstAction, const ActivateIntent());
    Actions.invoke<ButtonActivateIntent>(
        firstAction, const ButtonActivateIntent());

    Actions.invoke<ActivateIntent>(secondAction, const ActivateIntent());
    Actions.invoke<ButtonActivateIntent>(
        secondAction, const ButtonActivateIntent());

    verify(agent.onTap1()).called(2);
    verify(agent.onTap2()).called(2);
    verifyNoMoreInteractions(agent);
  });
}
