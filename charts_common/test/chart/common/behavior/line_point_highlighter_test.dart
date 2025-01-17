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

import 'dart:math' show Point, Rectangle;

import 'package:charts_common/src/chart/cartesian/axis/axis.dart';
import 'package:charts_common/src/chart/common/base_chart.dart';
import 'package:charts_common/src/chart/common/behavior/line_point_highlighter.dart';
import 'package:charts_common/src/chart/common/datum_details.dart';
import 'package:charts_common/src/chart/common/processed_series.dart';
import 'package:charts_common/src/chart/common/series_datum.dart';
import 'package:charts_common/src/chart/common/series_renderer.dart';
import 'package:charts_common/src/chart/common/selection_model/selection_model.dart';
import 'package:charts_common/src/common/material_palette.dart';
import 'package:charts_common/src/common/math.dart';
import 'package:charts_common/src/data/series.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../mocks.mocks.dart';

class MockNumericAxis extends Mock implements NumericAxis {
  @override
  double? getLocation(num? domain) {
    return 10.0;
  }
}

class MockSeriesRenderer<D> extends BaseSeriesRenderer<D> {
  MockSeriesRenderer() : super(rendererId: 'fake', layoutPaintOrder: 0);

  @override
  void update(_, __) {}

  @override
  void paint(_, __) {}

  @override
  List<DatumDetails<D>> getNearestDatumDetailPerSeries(
    Point<double> chartPoint,
    bool byDomain,
    Rectangle<int>? boundsOverride, {
    selectOverlappingPoints = false,
    selectExactEventLocation = false,
  }) =>
      [];

  @override
  DatumDetails<D> addPositionToDetailsForSeriesDatum(
      DatumDetails<D> details, SeriesDatum<D> seriesDatum) {
    return DatumDetails.from(details, chartPosition: NullablePoint(0.0, 0.0));
  }
}

void main() {
  late MockCartesianChart chart;
  late MockMutableSelectionModel selectionModel;
  late MockSeriesRenderer seriesRenderer;
  SelectionModelListener? lastSelectionChangedListener;
  LifecycleListener? chartLastListener;

  late MutableSeries<int> series1;
  final s1D1 = MyRow(1, 11);
  final s1D2 = MyRow(2, 12);
  final s1D3 = MyRow(3, 13);

  late MutableSeries<int> series2;
  final s2D1 = MyRow(4, 21);
  final s2D2 = MyRow(5, 22);
  final s2D3 = MyRow(6, 23);

  List<DatumDetails> mockGetSelectedDatumDetails(List<SeriesDatum> selection) {
    final details = <DatumDetails>[];

    for (SeriesDatum seriesDatum in selection) {
      details.add(seriesRenderer.getDetailsForSeriesDatum(seriesDatum));
    }

    return details;
  }

  void setupSelection(List<SeriesDatum> selection) {
    final selected = <MyRow>[];

    for (var i = 0; i < selection.length; i++) {
      selected.add(selection[0].datum as MyRow);
    }

    when(selectionModel.addSelectionChangedListener(any))
        .thenAnswer((invocation) {
      lastSelectionChangedListener = invocation.positionalArguments[0];
    });

    when(selectionModel.removeSelectionChangedListener(any))
        .thenAnswer((invocation) {
      expect(invocation.positionalArguments[0],
          equals(lastSelectionChangedListener));
      lastSelectionChangedListener = null;
    });

    for (int i = 0; i < series1.data.length; i++) {
      when(selectionModel.isDatumSelected(series1, i))
          .thenReturn(selected.contains(series1.data[i]));
    }
    for (int i = 0; i < series2.data.length; i++) {
      when(selectionModel.isDatumSelected(series2, i))
          .thenReturn(selected.contains(series2.data[i]));
    }

    when(selectionModel.selectedDatum).thenReturn(selection);

    final selectedDetails = mockGetSelectedDatumDetails(selection);

    when(chart.getSelectedDatumDetails(SelectionModelType.info))
        .thenReturn(selectedDetails);
  }

  setUp(() {
    chart = MockCartesianChart();

    when(chart.vertical).thenReturn(true);
    when(chart.addLifecycleListener(any)).thenAnswer(
        (invocation) => chartLastListener = invocation.positionalArguments[0]);

    when(chart.removeLifecycleListener(any)).thenAnswer((invocation) {
      expect(invocation.positionalArguments[0], equals(chartLastListener));
      chartLastListener = null;
      return true;
    });

    seriesRenderer = MockSeriesRenderer();

    selectionModel = MockMutableSelectionModel();

    series1 = MutableSeries(Series<MyRow, int>(
        id: 's1',
        data: [s1D1, s1D2, s1D3],
        domainFn: (MyRow row, _) => row.campaign,
        measureFn: (MyRow row, _) => row.count,
        colorFn: (_, __) => MaterialPalette.blue.shadeDefault))
      ..measureFn = (_) => 0.0;

    series2 = MutableSeries(Series<MyRow, int>(
        id: 's2',
        data: [s2D1, s2D2, s2D3],
        domainFn: (MyRow row, _) => row.campaign,
        measureFn: (MyRow row, _) => row.count,
        colorFn: (_, __) => MaterialPalette.red.shadeDefault))
      ..measureFn = (_) => 0.0;
  });

  group('LinePointHighlighter', () {
    test('highlights the selected points', () {
      // Setup
      final behavior =
          LinePointHighlighter(selectionModelType: SelectionModelType.info);
      when(chart.getSelectionModel(SelectionModelType.info))
          .thenReturn(selectionModel);
      setupSelection([
        SeriesDatum(series1, s1D2),
        SeriesDatum(series2, s2D2),
      ]);

      final tester = LinePointHighlighterTester(behavior);
      behavior.attachTo(chart);

      // Mock axes for returning fake domain locations.
      Axis domainAxis = MockNumericAxis();
      Axis primaryMeasureAxis = MockNumericAxis();

      series1.setAttr(domainAxisKey, domainAxis);
      series1.setAttr(measureAxisKey, primaryMeasureAxis);
      series1.measureOffsetFn = (_) => 0.0;

      series2.setAttr(domainAxisKey, domainAxis);
      series2.setAttr(measureAxisKey, primaryMeasureAxis);
      series2.measureOffsetFn = (_) => 0.0;

      // Act
      lastSelectionChangedListener!(selectionModel);
      verify(chart.redraw(skipAnimation: true, skipLayout: true));

      chartLastListener!.onAxisConfigured!();

      // Verify
      expect(tester.getSelectionLength(), equals(2));

      expect(tester.isDatumSelected(series1.data[0]), equals(false));
      expect(tester.isDatumSelected(series1.data[1]), equals(true));
      expect(tester.isDatumSelected(series1.data[2]), equals(false));

      expect(tester.isDatumSelected(series2.data[0]), equals(false));
      expect(tester.isDatumSelected(series2.data[1]), equals(true));
      expect(tester.isDatumSelected(series2.data[2]), equals(false));
    });

    test('listens to other selection models', () {
      // Setup
      final behavior =
          LinePointHighlighter(selectionModelType: SelectionModelType.action);
      when(chart.getSelectionModel(SelectionModelType.action))
          .thenReturn(selectionModel);

      // Act
      behavior.attachTo(chart);

      // Verify
      verify(chart.getSelectionModel(SelectionModelType.action));
      verifyNever(chart.getSelectionModel(SelectionModelType.info));
    });

    test('leaves everything alone with no selection', () {
      // Setup
      final behavior =
          LinePointHighlighter(selectionModelType: SelectionModelType.info);
      when(chart.getSelectionModel(SelectionModelType.info))
          .thenReturn(selectionModel);
      setupSelection([]);

      final tester = LinePointHighlighterTester(behavior);
      behavior.attachTo(chart);

      // Act
      lastSelectionChangedListener!(selectionModel);
      verify(chart.redraw(skipAnimation: true, skipLayout: true));
      chartLastListener!.onAxisConfigured!();

      // Verify
      expect(tester.getSelectionLength(), equals(0));

      expect(tester.isDatumSelected(series1.data[0]), equals(false));
      expect(tester.isDatumSelected(series1.data[1]), equals(false));
      expect(tester.isDatumSelected(series1.data[2]), equals(false));

      expect(tester.isDatumSelected(series2.data[0]), equals(false));
      expect(tester.isDatumSelected(series2.data[1]), equals(false));
      expect(tester.isDatumSelected(series2.data[2]), equals(false));
    });

    test('cleans up', () {
      // Setup
      final behavior =
          LinePointHighlighter(selectionModelType: SelectionModelType.info);
      when(chart.getSelectionModel(SelectionModelType.info))
          .thenReturn(selectionModel);
      setupSelection([
        SeriesDatum(series1, s1D2),
        SeriesDatum(series2, s2D2),
      ]);

      behavior.attachTo(chart);

      // Act
      behavior.removeFrom(chart);

      // Verify
      expect(chartLastListener, isNull);
      expect(lastSelectionChangedListener, isNull);
    });
  });
}

class MyRow {
  final int campaign;
  final int count;
  MyRow(this.campaign, this.count);
}
