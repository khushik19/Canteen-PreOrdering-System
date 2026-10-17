import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:canteen_crave/src/core/layout/breakpoints.dart';
import 'package:canteen_crave/src/core/layout/centered_content.dart';

void main() {
  testWidgets('screenSizeOf detects mobile, tablet, and desktop', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Mobile width: 500 (<600)
    tester.view.physicalSize = const Size(500, 800);
    late ScreenSize mobileSize;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            mobileSize = screenSizeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(mobileSize, ScreenSize.mobile);

    // 2. Tablet width: 800 (600 to 1023)
    tester.view.physicalSize = const Size(800, 1000);
    late ScreenSize tabletSize;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            tabletSize = screenSizeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(tabletSize, ScreenSize.tablet);

    // 3. Desktop width: 1280 (>=1024)
    tester.view.physicalSize = const Size(1280, 800);
    late ScreenSize desktopSize;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            desktopSize = screenSizeOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(desktopSize, ScreenSize.desktop);
  });

  testWidgets('CenteredContent constrains width to max 1200', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1920, 1080);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CenteredContent(
            child: SizedBox(key: Key('child'), width: double.infinity, height: 100),
          ),
        ),
      ),
    );

    final childBox = tester.renderObject(find.byKey(const Key('child'))) as RenderBox;
    expect(childBox.size.width, Breakpoints.maxContentWidth);
  });
}
