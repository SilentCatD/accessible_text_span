import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accessible_text_span/accessible_text_span.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../fixture/span_builder_interact_agent.dart';
import '../fixture/text_span_fixture.dart';
import 'focusable_text_span_builder_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FocusNode>(),
  MockSpec<BuildContext>(),
  MockSpec<SpanBuilderInteractAgent>()
])
void main() {
  test("initialize", () {
    final List<FocusNode> nodes = List.generate(5, (_) => FocusNode());
    final builder = FocusableTextSpanBuilder(nodes: nodes);

    bool sameInstances = true;

    for (int i = 0; i < nodes.length; i++) {
      sameInstances = sameInstances && nodes[i] == builder.nodes[i];
    }

    expect(sameInstances, true);
    expect(nodes.length, builder.nodes.length);

    addTearDown(() {
      builder.dispose();
    });
  });

  test("dispose", () {
    final MockFocusNode node = MockFocusNode();
    final builder = FocusableTextSpanBuilder(nodes: [node]);
    when(node.dispose()).thenReturn(null);

    builder.dispose();

    verify(node.dispose()).called(1);
  });

  group("generate focusNode", () {
    late FocusableTextSpanBuilder builder;
    late MockSpanBuilderInteractAgent agent;
    setUp(() {
      builder = FocusableTextSpanBuilder();
      agent = MockSpanBuilderInteractAgent();
    });
    tearDown(() {
      builder.dispose();
    });

    test("no focus node generated", () {
      final mockContext = MockBuildContext();
      builder.buildSpan(
        mockContext,
        textSpan: nonInteractSpans1,
        onFocused: agent.onFocusChanged,
        textStyleBuilder: agent.generateTextSpanStyle,
      );

      expect(builder.nodes.length, 0);
    });
    test("1 focus node generated", () {
      final mockContext = MockBuildContext();
      builder.buildSpan(
        mockContext,
        textSpan: interactSpans1(),
        onFocused: agent.onFocusChanged,
        textStyleBuilder: agent.generateTextSpanStyle,
      );

      expect(builder.nodes.length, 1);
    });
    test("0 focus node generated with children", () {
      final mockContext = MockBuildContext();
      builder.buildSpan(
        mockContext,
        textSpan: nonInteractSpans2,
        onFocused: agent.onFocusChanged,
        textStyleBuilder: agent.generateTextSpanStyle,
      );
      expect(builder.nodes.length, 0);
    });

    test("2 focus node generated with children", () {
      final mockContext = MockBuildContext();
      builder.buildSpan(
        mockContext,
        textSpan: interactSpans2(),
        onFocused: agent.onFocusChanged,
        textStyleBuilder: agent.generateTextSpanStyle,
      );
      expect(builder.nodes.length, 2);
    });
  });
}
