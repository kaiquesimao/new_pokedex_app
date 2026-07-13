import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_app/core/constants/responsive_layout.dart';
import 'package:pokedex_app/shared/widgets/responsive_content_frame.dart';

void main() {
  testWidgets('keeps child full width on narrow viewports', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));

    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContentFrame(
            expandHeight: true,
            child: SizedBox(
              key: Key('content'),
              width: double.infinity,
              height: 100,
            ),
          ),
        ),
      ),
    );

    final box = tester.getSize(find.byKey(const Key('content')));
    expect(box.width, 360);
  });

  testWidgets('caps child width on wide viewports', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));

    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContentFrame(
            expandHeight: true,
            child: SizedBox(
              key: Key('content'),
              width: double.infinity,
              height: 100,
            ),
          ),
        ),
      ),
    );

    final box = tester.getSize(find.byKey(const Key('content')));
    expect(box.width, ResponsiveLayout.maxContentWidth);
  });

  testWidgets('fills parent height when expandHeight is true', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));

    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContentFrame(
            expandHeight: true,
            child: ColoredBox(
              key: Key('content'),
              color: Colors.red,
            ),
          ),
        ),
      ),
    );

    final box = tester.getSize(find.byKey(const Key('content')));
    expect(box.width, ResponsiveLayout.maxContentWidth);
    expect(box.height, 800);
  });

  testWidgets('keeps compact height for bottom navigation slot', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));

    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: ResponsiveContentFrame(
            child: SizedBox(
              key: Key('nav'),
              height: 72,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );

    final navBar = tester.getSize(find.byKey(const Key('nav')));
    expect(navBar.width, ResponsiveLayout.maxContentWidth);
    expect(navBar.height, 72);

    final scaffold = tester.getSize(find.byType(Scaffold));
    expect(scaffold.height, 800);
  });
}
