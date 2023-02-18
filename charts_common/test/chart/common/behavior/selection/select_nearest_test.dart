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

import 'package:charts_common/src/chart/common/behavior/selection/select_nearest.dart';
import 'package:charts_common/src/chart/common/behavior/selection/selection_trigger.dart';
import 'package:charts_common/src/chart/common/datum_details.dart';
import 'package:charts_common/src/chart/common/processed_series.dart';
import 'package:charts_common/src/chart/common/series_datum.dart';
import 'package:charts_common/src/chart/common/selection_model/selection_model.dart';
import 'package:charts_common/src/common/gesture_listener.dart';
import 'package:charts_common/src/data/series.dart';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockStringBaseChart chart;
  late MockStringMutableSelectionModel hoverSelectionModel;
  late MockStringMutableSelectionModel clickSelectionModel;
  late List<String> series1Data;
  late List<String> series2Data;
  late MutableSeries<String> series1;
  late MutableSeries<String> series2;
  late DatumDetails<String> details10;
  late DatumDetails<String> details1Series2;
  late DatumDetails<String> details20;
  late DatumDetails<String> details3;
  GestureListener? lastListener;

  SelectNearest<String> makeBehavior(
      SelectionModelType selectionModelType, SelectionTrigger eventTrigger,
      {required bool selectClosestSeries,
      SelectionMode selectionMode = SelectionMode.expandToDomain,
      int? maximumDomainDistancePx}) {
    SelectNearest<String> behavior = SelectNearest<String>(
        selectionModelType: selectionModelType,
        selectionMode: selectionMode,
        selectClosestSeries: selectClosestSeries,
        eventTrigger: eventTrigger,
        maximumDomainDistancePx: maximumDomainDistancePx);

    behavior.attachTo(chart);

    return behavior;
  }

  void setupChart(
      {required Point<double> forPoint,
      required bool isWithinRenderer,
      required List<DatumDetails<String>> respondWithDetails,
      required List<MutableSeries<String>> seriesList}) {
    when(chart.pointWithinRenderer(forPoint)).thenReturn(isWithinRenderer);
    when(chart.getNearestDatumDetailPerSeries(forPoint, true))
        .thenReturn(respondWithDetails);
    when(chart.currentSeriesList).thenReturn(seriesList);
  }

  setUp(() {
    hoverSelectionModel = MockStringMutableSelectionModel();
    clickSelectionModel = MockStringMutableSelectionModel();

    chart = MockStringBaseChart();
    when(chart.addGestureListener(any)).thenAnswer((invocation) {
      lastListener = invocation.positionalArguments[0];
      return lastListener!;
    });

    when(chart.removeGestureListener(any)).thenAnswer((invocation) {
      expect(invocation.positionalArguments[0], equals(lastListener));
      lastListener = null;
    });

    when(chart.getSelectionModel(SelectionModelType.info))
        .thenReturn(hoverSelectionModel);
    when(chart.getSelectionModel(SelectionModelType.action))
        .thenReturn(clickSelectionModel);

    series1Data = ['myDomain1', 'myDomain2', 'myDomain3'];

    series1 = MutableSeries<String>(Series(
        id: 'mySeries1',
        data: ['myDatum1', 'myDatum2', 'myDatum3'],
        domainFn: (_, int? i) => series1Data[i ?? 0],
        measureFn: (_, __) => null));

    details10 = DatumDetails(
        datum: 'myDatum1',
        domain: 'myDomain1',
        series: series1,
        domainDistance: 10.0,
        measureDistance: 20.0);
    details20 = DatumDetails(
        datum: 'myDatum2',
        domain: 'myDomain2',
        series: series1,
        domainDistance: 10.0,
        measureDistance: 20.0);
    details3 = DatumDetails(
        datum: 'myDatum3',
        domain: 'myDomain3',
        series: series1,
        domainDistance: 10.0,
        measureDistance: 20.0);

    series2Data = ['myDomain1'];

    series2 = MutableSeries<String>(Series(
        id: 'mySeries2',
        data: ['myDatum1s2'],
        domainFn: (_, int? i) => series2Data[i ?? 0],
        measureFn: (_, __) => null));

    details1Series2 = DatumDetails(
        datum: 'myDatum1s2',
        domain: 'myDomain1',
        series: series2,
        domainDistance: 10.0,
        measureDistance: 20.0);
  });

  tearDown(resetMockitoState);

  group('SelectNearest trigger handling', () {
    test('single series selects detail', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: true);
      Point<double> point = Point(100.0, 100.0);
      setupChart(
          forPoint: point,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1]);

      // Act
      lastListener!.onHover!(point);

      // Validate
      verify(hoverSelectionModel
          .updateSelection([SeriesDatum(series1, details10.datum)], [series1]));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
      // Shouldn't be listening to anything else.
      expect(lastListener!.onTap, isNull);
      expect(lastListener!.onDragStart, isNull);
    });

    test('can listen to tap', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.action, SelectionTrigger.tap,
          selectClosestSeries: true);
      Point<double> point = Point(100.0, 100.0);
      setupChart(
          forPoint: point,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1]);

      // Act
      lastListener!.onTapTest(point);
      lastListener!.onTap!(point);

      // Validate
      verify(clickSelectionModel
          .updateSelection([SeriesDatum(series1, details10.datum)], [series1]));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('can listen to drag', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.pressHold,
          selectClosestSeries: true);

      Point<double> startPoint = Point(100.0, 100.0);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1]);

      Point<double> updatePoint1 = Point(200.0, 100.0);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1]);

      Point<double> updatePoint2 = Point(300.0, 100.0);
      setupChart(
          forPoint: updatePoint2,
          isWithinRenderer: true,
          respondWithDetails: [details20],
          seriesList: [series1]);

      Point<double> endPoint = Point(400.0, 100.0);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],
          seriesList: [series1]);

      // Act
      lastListener!.onTapTest(startPoint);
      lastListener!.onDragStart!(startPoint);
      lastListener!.onDragUpdate!(updatePoint1, 1.0);
      lastListener!.onDragUpdate!(updatePoint2, 1.0);
      lastListener!.onDragEnd!(endPoint, 1.0, 0.0);

      // Validate
      // details1 was tripped 2 times (startPoint & updatePoint1)
      verify(hoverSelectionModel.updateSelection(
          [SeriesDatum(series1, details10.datum)], [series1])).called(2);
      // details2 was tripped for updatePoint2
      verify(hoverSelectionModel
          .updateSelection([SeriesDatum(series1, details20.datum)], [series1]));
      // dragEnd deselects even though we are over details3.
      verify(hoverSelectionModel.updateSelection([], []));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('can listen to drag after long press', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.longPressHold,
          selectClosestSeries: true);

      Point<double> startPoint = Point(100.0, 100.0);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1]);

      Point<double> updatePoint1 = Point(200.0, 100.0);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details20],
          seriesList: [series1]);

      Point<double> endPoint = Point(400.0, 100.0);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],
          seriesList: [series1]);

      // Act 1
      lastListener!.onTapTest(startPoint);
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);

      // Act 2
      // verify no interaction yet.
      lastListener!.onLongPress!(startPoint);
      lastListener!.onDragStart!(startPoint);
      lastListener!.onDragUpdate!(updatePoint1, 1.0);
      lastListener!.onDragEnd!(endPoint, 1.0, 0.0);

      // Validate
      // details1 was tripped 2 times (longPress & dragStart)
      verify(hoverSelectionModel.updateSelection(
          [SeriesDatum(series1, details10.datum)], [series1])).called(2);
      verify(hoverSelectionModel
          .updateSelection([SeriesDatum(series1, details20.datum)], [series1]));
      // dragEnd deselects even though we are over details3.
      verify(hoverSelectionModel.updateSelection([], []));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('no trigger before long press', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.longPressHold,
          selectClosestSeries: true);

      Point<double> startPoint = Point(100.0, 100.0);
      setupChart(
          forPoint: startPoint,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1]);

      Point<double> updatePoint1 = Point(200.0, 100.0);
      setupChart(
          forPoint: updatePoint1,
          isWithinRenderer: true,
          respondWithDetails: [details20],
          seriesList: [series1]);

      Point<double> endPoint = Point(400.0, 100.0);
      setupChart(
          forPoint: endPoint,
          isWithinRenderer: true,
          respondWithDetails: [details3],
          seriesList: [series1]);

      // Act
      lastListener!.onTapTest(startPoint);
      lastListener!.onDragStart!(startPoint);
      lastListener!.onDragUpdate!(updatePoint1, 1.0);
      lastListener!.onDragEnd!(endPoint, 1.0, 0.0);

      // Validate
      // No interaction, didn't long press first.
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });
  });

  group('Details', () {
    test('expands to domain and includes closest series', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: true);
      Point<double> point = Point(100.0, 100.0);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details10,
        details1Series2,
      ], seriesList: [
        series1,
        series2
      ]);

      // Act
      lastListener!.onHover!(point);

      // Validate
      verify(hoverSelectionModel.updateSelection([
        SeriesDatum(series1, details10.datum),
        SeriesDatum(series2, details1Series2.datum)
      ], [
        series1
      ]));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('does not expand to domain', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectionMode: SelectionMode.single, selectClosestSeries: true);
      Point<double> point = Point(100.0, 100.0);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details10,
        details1Series2,
      ], seriesList: [
        series1,
        series2
      ]);

      // Act
      lastListener!.onHover!(point);

      // Validate
      verify(hoverSelectionModel
          .updateSelection([SeriesDatum(series1, details10.datum)], [series1]));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('does not include closest series', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: false);
      Point<double> point = Point(100.0, 100.0);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details10,
        details1Series2,
      ], seriesList: [
        series1,
        series2
      ]);

      // Act
      lastListener!.onHover!(point);

      // Validate
      verify(hoverSelectionModel.updateSelection([
        SeriesDatum(series1, details10.datum),
        SeriesDatum(series2, details1Series2.datum)
      ], []));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('does not include overlay series', () {
      // Setup chart with an overlay series.
      series2.overlaySeries = true;

      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: true);
      Point<double> point = Point(100.0, 100.0);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details10,
        details1Series2,
      ], seriesList: [
        series1,
        series2
      ]);

      // Act
      lastListener!.onHover!(point);

      // Validate
      verify(hoverSelectionModel.updateSelection([
        SeriesDatum(series1, details10.datum),
      ], [
        series1
      ]));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('selection does not exceed maximumDomainDistancePx', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: true, maximumDomainDistancePx: 1);
      Point<double> point = Point(100.0, 100.0);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details10,
        details1Series2,
      ], seriesList: [
        series1,
        series2
      ]);

      // Act
      lastListener!.onHover!(point);

      // Validate
      verify(hoverSelectionModel.updateSelection([], []));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('adds overlapping points from same series if there are any', () {
      // Setup chart matches point with single domain single series.
      makeBehavior(SelectionModelType.info, SelectionTrigger.hover,
          selectionMode: SelectionMode.selectOverlapping,
          selectClosestSeries: true);
      Point<double> point = Point(100.0, 100.0);
      final series = MutableSeries<String>(Series(
          id: 'overlappingSeries',
          data: ['datum1', 'datum2'],
          domainFn: (_, int? i) => series1Data[i ?? 0],
          measureFn: (_, __) => null));
      // Two points covering the mouse position.
      final details1 = DatumDetails(
          datum: 'datum1',
          domain: 'myDomain1',
          series: series,
          radiusPx: 10,
          domainDistance: 4,
          relativeDistance: 5);
      final details2 = DatumDetails(
          datum: 'datum2',
          domain: 'myDomain1',
          series: series,
          radiusPx: 10,
          domainDistance: 7,
          relativeDistance: 9);
      setupChart(forPoint: point, isWithinRenderer: true, respondWithDetails: [
        details1,
        details2,
      ], seriesList: [
        series,
      ]);

      // Act
      lastListener!.onHover!(point);

      // Validate
      verify(hoverSelectionModel.updateSelection([
        SeriesDatum(series, details1.datum),
        SeriesDatum(series, details2.datum)
      ], [
        series
      ]));
      verifyNoMoreInteractions(hoverSelectionModel);
      verifyNoMoreInteractions(clickSelectionModel);
    });
  });

  group('Cleanup', () {
    test('detach removes listener', () {
      // Setup
      SelectNearest behavior = makeBehavior(
          SelectionModelType.info, SelectionTrigger.hover,
          selectClosestSeries: true);
      Point<double> point = Point(100.0, 100.0);
      setupChart(
          forPoint: point,
          isWithinRenderer: true,
          respondWithDetails: [details10],
          seriesList: [series1]);
      expect(lastListener, isNotNull);

      // Act
      behavior.removeFrom(chart);

      // Validate
      expect(lastListener, isNull);
    });
  });
}
