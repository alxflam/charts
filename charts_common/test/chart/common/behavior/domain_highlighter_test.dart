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

import 'package:charts_common/src/chart/common/base_chart.dart';
import 'package:charts_common/src/chart/common/behavior/domain_highlighter.dart';
import 'package:charts_common/src/chart/common/processed_series.dart';
import 'package:charts_common/src/chart/common/selection_model/selection_model.dart';
import 'package:charts_common/src/common/material_palette.dart';
import 'package:charts_common/src/data/series.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../mocks.mocks.dart';

void main() {
  late MockBaseChart chart;
  late MockMutableSelectionModel selectionModel;

  late MutableSeries<String> series1;
  final s1D1 = MyRow('s1d1', 11);
  final s1D2 = MyRow('s1d2', 12);
  final s1D3 = MyRow('s1d3', 13);

  late MutableSeries<String> series2;
  final s2D1 = MyRow('s2d1', 21);
  final s2D2 = MyRow('s2d2', 22);
  final s2D3 = MyRow('s2d3', 23);

  LifecycleListener? chartLastListener;
  SelectionModelListener? lastSelectionChangedListener;

  void setupSelection(List<MyRow> selected) {
    for (var i = 0; i < series1.data.length; i++) {
      when(selectionModel.isDatumSelected(series1, i))
          .thenReturn(selected.contains(series1.data[i]));
    }
    for (var i = 0; i < series2.data.length; i++) {
      when(selectionModel.isDatumSelected(series2, i))
          .thenReturn(selected.contains(series2.data[i]));
    }
  }

  setUp(() {
    chart = MockBaseChart();

    when(chart.addLifecycleListener(any)).thenAnswer(
        (invocation) => chartLastListener = invocation.positionalArguments[0]);

    when(chart.removeLifecycleListener(any)).thenAnswer((invocation) {
      expect(invocation.positionalArguments[0], equals(chartLastListener));
      chartLastListener = null;
      return true;
    });

    selectionModel = MockMutableSelectionModel();
    when(chart.getSelectionModel(SelectionModelType.info))
        .thenReturn(selectionModel);

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

    series1 = MutableSeries(Series<MyRow, String>(
        id: 's1',
        data: [s1D1, s1D2, s1D3],
        domainFn: (MyRow row, _) => row.campaign,
        measureFn: (MyRow row, _) => row.count,
        colorFn: (_, __) => MaterialPalette.blue.shadeDefault))
      ..measureFn = (_) => 0.0;

    series2 = MutableSeries(Series<MyRow, String>(
        id: 's2',
        data: [s2D1, s2D2, s2D3],
        domainFn: (MyRow row, _) => row.campaign,
        measureFn: (MyRow row, _) => row.count,
        colorFn: (_, __) => MaterialPalette.red.shadeDefault))
      ..measureFn = (_) => 0.0;
  });

  group('DomainHighligher', () {
    test('darkens the selected bars', () {
      // Setup
      final behavior = DomainHighlighter(SelectionModelType.info);
      behavior.attachTo(chart);
      setupSelection([s1D2, s2D2]);
      final seriesList = [series1, series2];

      // Act
      lastSelectionChangedListener!(selectionModel);
      verify(chart.redraw(skipAnimation: true, skipLayout: true));
      chartLastListener!.onPostprocess!(seriesList);

      // Verify
      final s1ColorFn = series1.colorFn!;
      expect(s1ColorFn(0), equals(MaterialPalette.blue.shadeDefault));
      expect(s1ColorFn(1), equals(MaterialPalette.blue.shadeDefault.darker));
      expect(s1ColorFn(2), equals(MaterialPalette.blue.shadeDefault));

      final s2ColorFn = series2.colorFn!;
      expect(s2ColorFn(0), equals(MaterialPalette.red.shadeDefault));
      expect(s2ColorFn(1), equals(MaterialPalette.red.shadeDefault.darker));
      expect(s2ColorFn(2), equals(MaterialPalette.red.shadeDefault));
    });

    test('listens to other selection models', () {
      // Setup
      final behavior = DomainHighlighter(SelectionModelType.action);
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
      final behavior = DomainHighlighter(SelectionModelType.info);
      behavior.attachTo(chart);
      setupSelection([]);
      final seriesList = [series1, series2];

      // Act
      lastSelectionChangedListener!(selectionModel);
      verify(chart.redraw(skipAnimation: true, skipLayout: true));
      chartLastListener!.onPostprocess!(seriesList);

      // Verify
      final s1ColorFn = series1.colorFn!;
      expect(s1ColorFn(0), equals(MaterialPalette.blue.shadeDefault));
      expect(s1ColorFn(1), equals(MaterialPalette.blue.shadeDefault));
      expect(s1ColorFn(2), equals(MaterialPalette.blue.shadeDefault));

      final s2ColorFn = series2.colorFn!;
      expect(s2ColorFn(0), equals(MaterialPalette.red.shadeDefault));
      expect(s2ColorFn(1), equals(MaterialPalette.red.shadeDefault));
      expect(s2ColorFn(2), equals(MaterialPalette.red.shadeDefault));
    });

    test('cleans up', () {
      // Setup
      final behavior = DomainHighlighter(SelectionModelType.info);
      behavior.attachTo(chart);
      setupSelection([s1D2, s2D2]);

      // Act
      behavior.removeFrom(chart);

      // Verify
      expect(chartLastListener, isNull);
      expect(lastSelectionChangedListener, isNull);
    });
  });
}

class MyRow {
  final String campaign;
  final int count;
  MyRow(this.campaign, this.count);
}
