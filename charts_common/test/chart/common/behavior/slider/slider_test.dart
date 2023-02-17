// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:math';

import 'package:charts_common/src/chart/cartesian/axis/axis.dart';
import 'package:charts_common/src/chart/cartesian/cartesian_chart.dart';
import 'package:charts_common/src/chart/common/base_chart.dart';
import 'package:charts_common/src/chart/common/datum_details.dart';
import 'package:charts_common/src/chart/common/processed_series.dart';
import 'package:charts_common/src/chart/common/behavior/slider/slider.dart';
import 'package:charts_common/src/chart/common/behavior/selection/selection_trigger.dart';
import 'package:charts_common/src/common/gesture_listener.dart';
import 'package:charts_common/src/common/math.dart';
import 'package:charts_common/src/data/series.dart';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../../mocks.mocks.dart';

class MockChart extends Mock implements CartesianChart {
  GestureListener? lastGestureListener;

  LifecycleListener? lastLifecycleListener;

  @override
  NumericAxis getMeasureAxis({String? axisId}) {
    return super.noSuchMethod(Invocation.method(#getMeasureAxis, []),
        returnValue: MockNumericAxis());
  }

  @override
  bool pointWithinRenderer(Point<double> chartPosition) {
    return super.noSuchMethod(
        Invocation.method(#pointWithinRenderer, [chartPosition]),
        returnValue: true);
  }

  @override
  List<DatumDetails> getNearestDatumDetailPerSeries(
      Point<double> drawAreaPoint, bool selectAcrossAllDrawAreaComponents) {
    return super.noSuchMethod(
        Invocation.method(#getNearestDatumDetailPerSeries,
            [drawAreaPoint, selectAcrossAllDrawAreaComponents]),
        returnValue: <DatumDetails>[]);
  }

  @override
  bool vertical = true;

  @override
  GestureListener addGestureListener(GestureListener listener) {
    lastGestureListener = listener;
    return listener;
  }

  @override
  void removeGestureListener(GestureListener listener) {
    expect(listener, equals(lastGestureListener));
    lastGestureListener = null;
  }

  @override
  LifecycleListener addLifecycleListener(LifecycleListener listener) =>
      lastLifecycleListener = listener;

  @override
  bool removeLifecycleListener(LifecycleListener listener) {
    expect(listener, equals(lastLifecycleListener));
    lastLifecycleListener = null;
    return true;
  }
}

void main() {
  late MockChart chart;
  late MockNumericAxis domainAxis;
  late MockNumericAxis measureAxis;
  late ImmutableSeries series1;
  late DatumDetails details1;
  late DatumDetails details2;
  late DatumDetails details3;

  late SliderTester tester;

  Slider makeBehavior(SelectionTrigger eventTrigger,
      {Point<double>? handleOffset,
      Rectangle<int>? handleSize,
      double? initialDomainValue,
      SliderListenerCallback? onChangeCallback,
      bool snapToDatum = false,
      SliderHandlePosition handlePosition = SliderHandlePosition.middle}) {
    Slider behavior = Slider(
        eventTrigger: eventTrigger,
        initialDomainValue: initialDomainValue,
        onChangeCallback: onChangeCallback,
        snapToDatum: snapToDatum,
        style: handleOffset != null
            ? SliderStyle(
                handleOffset: handleOffset, handlePosition: handlePosition)
            : SliderStyle(handlePosition: handlePosition));

    behavior.attachTo(chart);

    tester = SliderTester(behavior);

    // Mock out chart layout by assigning bounds to the layout view.
    tester.layout(
        Rectangle<int>(0, 0, 200, 200), Rectangle<int>(0, 0, 200, 200));

    return behavior;
  }

  void setupChart(
      {Point<double>? forPoint,
      bool? isWithinRenderer,
      List<DatumDetails>? respondWithDetails}) {
    when(chart.domainAxis).thenReturn(domainAxis);
    when(chart.getMeasureAxis()).thenReturn(measureAxis);

    if (isWithinRenderer != null && forPoint != null) {
      when(chart.pointWithinRenderer(forPoint)).thenReturn(isWithinRenderer);
    }
    if (respondWithDetails != null && forPoint != null) {
      when(chart.getNearestDatumDetailPerSeries(forPoint, true))
          .thenReturn(respondWithDetails);
    }
  }

  setUp(() {
    chart = MockChart();

    domainAxis = MockNumericAxis();
    when(domainAxis.getDomain(any)).thenAnswer((invocation) {
      return (invocation.positionalArguments.first / 20.0).toDouble();
    });
    when(domainAxis.getLocation(any)).thenAnswer((invocation) {
      return (invocation.positionalArguments.first * 20.0).toDouble();
    });

    measureAxis = MockNumericAxis();
    when(measureAxis.getDomain(any)).thenAnswer((invocation) {
      return (invocation.positionalArguments.first / 20.0).toDouble();
    });
    when(measureAxis.getLocation(any)).thenAnswer((invocation) {
      return (invocation.positionalArguments.first * 20.0).toDouble();
    });

    series1 = MutableSeries(Series(
        id: 'mySeries1',
        data: [],
        domainFn: (_, __) {},
        measureFn: (_, __) => null));

    details1 = DatumDetails(
        chartPosition: NullablePoint(20.0, 80.0),
        datum: 'myDatum1',
        domain: 1.0,
        series: series1,
        domainDistance: 10.0,
        measureDistance: 20.0);
    details2 = DatumDetails(
        chartPosition: NullablePoint(40.0, 80.0),
        datum: 'myDatum2',
        domain: 2.0,
        series: series1,
        domainDistance: 10.0,
        measureDistance: 20.0);
    details3 = DatumDetails(
        chartPosition: NullablePoint(90.0, 80.0),
        datum: 'myDatum3',
        domain: 4.5,
        series: series1,
        domainDistance: 10.0,
        measureDistance: 20.0);
  });

  group('Slider trigger handling', () {
    test('can listen to tap and drag', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.tapAndDrag,
          handleOffset: Point<double>(0.0, 0.0),
          handleSize: Rectangle<int>(0, 0, 10, 20));

      Point<double> startPoint = Point(100.0, 100.0);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1]);

      Point<double> updatePoint1 = Point(50.0, 100.0);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2]);

      Point<double> updatePoint2 = Point(100.0, 100.0);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      Point<double> endPoint = Point(120.0, 100.0);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      // Act
      chart.lastLifecycleListener!.onAxisConfigured!();

      chart.lastGestureListener!.onTapTest(startPoint);
      chart.lastGestureListener!.onTap!(startPoint);

      // Start the drag.
      chart.lastGestureListener!.onDragStart!(startPoint);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener!.onDragUpdate!(updatePoint1, 1.0);
      expect(tester.domainCenterPoint, equals(updatePoint1));
      expect(tester.domainValue, equals(2.5));
      expect(tester.handleBounds, equals(Rectangle<int>(45, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener!.onDragUpdate!(updatePoint2, 1.0);
      expect(tester.domainCenterPoint, equals(updatePoint2));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener!.onDragUpdate!(endPoint, 1.0);
      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(Rectangle<int>(115, 90, 10, 20)));

      // Simulate onDragEnd.
      chart.lastGestureListener!.onDragEnd!(endPoint, 1.0, 1.0);

      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(Rectangle<int>(115, 90, 10, 20)));
    });

    test('slider handle can render at top', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.tapAndDrag,
          handleOffset: Point<double>(0.0, 0.0),
          handleSize: Rectangle<int>(0, 0, 10, 20),
          handlePosition: SliderHandlePosition.top);

      Point<double> startPoint = Point(100.0, 0.0);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1]);

      Point<double> updatePoint1 = Point(50.0, 0.0);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2]);

      Point<double> updatePoint2 = Point(100.0, 0.0);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      Point<double> endPoint = Point(120.0, 0.0);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      // Act
      chart.lastLifecycleListener!.onAxisConfigured!();

      chart.lastGestureListener!.onTapTest(startPoint);
      chart.lastGestureListener!.onTap!(startPoint);

      // Start the drag.
      chart.lastGestureListener!.onDragStart!(startPoint);
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, -10, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener!.onDragUpdate!(updatePoint1, 1.0);
      expect(tester.domainValue, equals(2.5));
      expect(tester.handleBounds, equals(Rectangle<int>(45, -10, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener!.onDragUpdate!(updatePoint2, 1.0);
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, -10, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener!.onDragUpdate!(endPoint, 1.0);
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(Rectangle<int>(115, -10, 10, 20)));

      // Simulate onDragEnd.
      chart.lastGestureListener!.onDragEnd!(endPoint, 1.0, 1.0);

      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(Rectangle<int>(115, -10, 10, 20)));
    });

    test('can listen to press hold', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.pressHold,
          handleOffset: Point<double>(0.0, 0.0),
          handleSize: Rectangle<int>(0, 0, 10, 20));

      Point<double> startPoint = Point(100.0, 100.0);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1]);

      Point<double> updatePoint1 = Point(50.0, 100.0);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2]);

      Point<double> updatePoint2 = Point(100.0, 100.0);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      Point<double> endPoint = Point(120.0, 100.0);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      // Act
      chart.lastLifecycleListener!.onAxisConfigured!();

      chart.lastGestureListener!.onTapTest(startPoint);
      chart.lastGestureListener!.onLongPress!(startPoint);

      // Start the drag.
      chart.lastGestureListener!.onDragStart!(startPoint);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener!.onDragUpdate!(updatePoint1, 1.0);
      expect(tester.domainCenterPoint, equals(updatePoint1));
      expect(tester.domainValue, equals(2.5));
      expect(tester.handleBounds, equals(Rectangle<int>(45, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener!.onDragUpdate!(updatePoint2, 1.0);
      expect(tester.domainCenterPoint, equals(updatePoint2));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener!.onDragUpdate!(endPoint, 1.0);
      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(Rectangle<int>(115, 90, 10, 20)));

      // Simulate onDragEnd.
      chart.lastGestureListener!.onDragEnd!(endPoint, 1.0, 1.0);

      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(Rectangle<int>(115, 90, 10, 20)));
    });

    test('can listen to long press hold', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.longPressHold,
          handleOffset: Point<double>(0.0, 0.0),
          handleSize: Rectangle<int>(0, 0, 10, 20));

      Point<double> startPoint = Point(100.0, 100.0);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1]);

      Point<double> updatePoint1 = Point(50.0, 100.0);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2]);

      Point<double> updatePoint2 = Point(100.0, 100.0);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      Point<double> endPoint = Point(120.0, 100.0);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      // Act
      chart.lastLifecycleListener!.onAxisConfigured!();

      chart.lastGestureListener!.onTapTest(startPoint);
      chart.lastGestureListener!.onLongPress!(startPoint);

      // Start the drag.
      chart.lastGestureListener!.onDragStart!(startPoint);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener!.onDragUpdate!(updatePoint1, 1.0);
      expect(tester.domainCenterPoint, equals(updatePoint1));
      expect(tester.domainValue, equals(2.5));
      expect(tester.handleBounds, equals(Rectangle<int>(45, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener!.onDragUpdate!(updatePoint2, 1.0);
      expect(tester.domainCenterPoint, equals(updatePoint2));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener!.onDragUpdate!(endPoint, 1.0);
      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(Rectangle<int>(115, 90, 10, 20)));

      // Simulate onDragEnd.
      chart.lastGestureListener!.onDragEnd!(endPoint, 1.0, 1.0);

      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(Rectangle<int>(115, 90, 10, 20)));
    });

    test('no position update before long press', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.longPressHold,
          handleOffset: Point<double>(0.0, 0.0),
          handleSize: Rectangle<int>(0, 0, 10, 20));

      Point<double> startPoint = Point(100.0, 100.0);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1]);

      Point<double> updatePoint1 = Point(50.0, 100.0);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2]);

      Point<double> updatePoint2 = Point(100.0, 100.0);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      Point<double> endPoint = Point(120.0, 100.0);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      // Act
      chart.lastLifecycleListener!.onAxisConfigured!();

      chart.lastGestureListener!.onTapTest(startPoint);

      // Start the drag.
      chart.lastGestureListener!.onDragStart!(startPoint);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener!.onDragUpdate!(endPoint, 1.0);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Simulate onDragEnd.
      chart.lastGestureListener!.onDragEnd!(endPoint, 1.0, 1.0);

      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));
    });

    test('can snap to datum', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionTrigger.tapAndDrag,
          handleOffset: Point<double>(0.0, 0.0),
          handleSize: Rectangle<int>(0, 0, 10, 20),
          snapToDatum: true);

      Point<double> startPoint = Point(100.0, 100.0);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details1]);

      Point<double> updatePoint1 = Point(50.0, 100.0);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details2]);

      Point<double> updatePoint2 = Point(100.0, 100.0);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      Point<double> endPoint = Point(120.0, 100.0);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3]);

      // Act
      chart.lastLifecycleListener!.onAxisConfigured!();

      chart.lastGestureListener!.onTapTest(startPoint);
      chart.lastGestureListener!.onTap!(startPoint);

      // Start the drag.
      chart.lastGestureListener!.onDragStart!(startPoint);
      expect(tester.domainCenterPoint, equals(startPoint));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Drag to first update point. The slider should follow the mouse during
      // each drag update.
      chart.lastGestureListener!.onDragUpdate!(updatePoint1, 1.0);
      expect(tester.domainCenterPoint, equals(updatePoint1));
      expect(tester.domainValue, equals(2.5));
      expect(tester.handleBounds, equals(Rectangle<int>(45, 90, 10, 20)));

      // Drag to first update point.
      chart.lastGestureListener!.onDragUpdate!(updatePoint2, 1.0);
      expect(tester.domainCenterPoint, equals(updatePoint2));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Drag the point to the end point.
      chart.lastGestureListener!.onDragUpdate!(endPoint, 1.0);
      expect(tester.domainCenterPoint, equals(endPoint));
      expect(tester.domainValue, equals(6.0));
      expect(tester.handleBounds, equals(Rectangle<int>(115, 90, 10, 20)));

      // Simulate onDragEnd. This is where we expect the snap to occur.
      chart.lastGestureListener!.onDragEnd!(endPoint, 1.0, 1.0);

      expect(tester.domainCenterPoint, equals(Point<int>(90, 100)));
      expect(tester.domainValue, equals(4.5));
      expect(tester.handleBounds, equals(Rectangle<int>(85, 90, 10, 20)));
    });
  });

  group('Slider manual control', () {
    test('can set domain position', () {
      // Setup chart matches point with single domain single series.
      final slider = makeBehavior(SelectionTrigger.tapAndDrag,
          handleOffset: Point<double>(0.0, 0.0),
          handleSize: Rectangle<int>(0, 0, 10, 20),
          initialDomainValue: 1.0);

      setupChart();

      // Act
      chart.lastLifecycleListener!.onAxisConfigured!();

      // Verify initial position.
      expect(tester.domainCenterPoint, equals(Point(20.0, 100.0)));
      expect(tester.domainValue, equals(1.0));
      expect(tester.handleBounds, equals(Rectangle<int>(15, 90, 10, 20)));

      // Move to first domain value.
      slider.moveSliderToDomain(2);
      expect(tester.domainCenterPoint, equals(Point(40.0, 100.0)));
      expect(tester.domainValue, equals(2.0));
      expect(tester.handleBounds, equals(Rectangle<int>(35, 90, 10, 20)));

      // Move to second domain value.
      slider.moveSliderToDomain(5);
      expect(tester.domainCenterPoint, equals(Point(100.0, 100.0)));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 90, 10, 20)));

      // Move to second domain value.
      slider.moveSliderToDomain(7.5);
      expect(tester.domainCenterPoint, equals(Point(150.0, 100.0)));
      expect(tester.domainValue, equals(7.5));
      expect(tester.handleBounds, equals(Rectangle<int>(145, 90, 10, 20)));
    });

    test('can set domain and measure position when handle position is manual',
        () {
      // Setup chart matches point with single domain single series.
      final slider = makeBehavior(SelectionTrigger.tapAndDrag,
          handleOffset: Point<double>(0.0, 0.0),
          handleSize: Rectangle<int>(0, 0, 10, 20),
          initialDomainValue: 1.0,
          handlePosition: SliderHandlePosition.manual);

      setupChart();

      // Act
      chart.lastLifecycleListener!.onAxisConfigured!();

      // Verify initial position.
      expect(tester.domainCenterPoint, equals(Point(20.0, 100.0)));
      expect(tester.domainValue, equals(1.0));
      expect(tester.handleBounds, equals(Rectangle<int>(15, 190, 10, 20)));

      // Move to first domain value.
      slider.moveSliderToDomain(2, measure: 5);
      expect(tester.domainCenterPoint, equals(Point(40.0, 100.0)));
      expect(tester.domainValue, equals(2.0));
      expect(tester.handleBounds, equals(Rectangle<int>(35, 90, 10, 20)));

      // Move to second domain value.
      slider.moveSliderToDomain(5, measure: 7);
      expect(tester.domainCenterPoint, equals(Point(100.0, 100.0)));
      expect(tester.domainValue, equals(5.0));
      expect(tester.handleBounds, equals(Rectangle<int>(95, 130, 10, 20)));

      // Move to second domain value.
      slider.moveSliderToDomain(7.5, measure: 3);
      expect(tester.domainCenterPoint, equals(Point(150.0, 100.0)));
      expect(tester.domainValue, equals(7.5));
      expect(tester.handleBounds, equals(Rectangle<int>(145, 50, 10, 20)));
    });
  });

  group('Cleanup', () {
    test('detach removes listener', () {
      // Setup
      Slider behavior = makeBehavior(SelectionTrigger.tapAndDrag);

      Point<double> point = Point(100.0, 100.0);
      setupChart(
          forPoint: point,
          isWithinRenderer: true,
          respondWithDetails: [details1]);
      expect(chart.lastGestureListener, isNotNull);

      // Act
      behavior.removeFrom(chart);

      // Validate
      expect(chart.lastGestureListener, isNull);
    });
  });
}
