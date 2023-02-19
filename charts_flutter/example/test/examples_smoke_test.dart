import 'package:charts_flutter/flutter.dart';
import 'package:example/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// after google updated this repository to sound null safety
  /// some examples were broken at runtime. these smoke tests
  /// verify that at least a chart is shown, hence the
  /// rendering should have succeded.
  group("verify every example can be shown", () {
    for (var example in Home.galleryScaffolds) {
      testWidgets('${example.title} ', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: example.childBuilder(),
          ),
        );

        /// a chart should be displayed
        final chart = find.byElementPredicate((a) => a.widget is BaseChart);
        expect(chart, findsOneWidget);
      });
    }
  });
}
