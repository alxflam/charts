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

import 'package:charts_common/src/chart/common/base_chart.dart';
import 'package:charts_common/src/chart/common/behavior/selection/lock_selection.dart';
import 'package:charts_common/src/chart/common/selection_model/selection_model.dart';
import 'package:charts_common/src/common/gesture_listener.dart';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../../mocks.mocks.dart';

class MockChart extends Mock implements BaseChart {
  GestureListener? lastListener;

  @override
  MutableSelectionModel getSelectionModel(SelectionModelType type) {
    return super.noSuchMethod(Invocation.method(#getSelectionModel, [type]),
        returnValue: MockMutableSelectionModel());
  }

  @override
  bool pointWithinRenderer(Point<double> chartPosition) {
    return super.noSuchMethod(
        Invocation.method(#pointWithinRenderer, [chartPosition]),
        returnValue: true);
  }

  @override
  GestureListener addGestureListener(GestureListener listener) {
    lastListener = listener;
    return listener;
  }

  @override
  void removeGestureListener(GestureListener listener) {
    expect(listener, equals(lastListener));
    lastListener = null;
  }
}

void main() {
  late MockChart chart;
  late MockMutableSelectionModel hoverSelectionModel;
  late MockMutableSelectionModel clickSelectionModel;
  bool hoverSelectionModelLocked;
  bool clickSelectionModelLocked;

  LockSelection makeLockSelectionBehavior(
      SelectionModelType selectionModelType) {
    LockSelection behavior =
        LockSelection(selectionModelType: selectionModelType);

    behavior.attachTo(chart);

    return behavior;
  }

  void setupChart({Point<double>? forPoint, bool? isWithinRenderer}) {
    if (isWithinRenderer != null && forPoint != null) {
      when(chart.pointWithinRenderer(forPoint)).thenReturn(isWithinRenderer);
    }
  }

  setUp(() {
    hoverSelectionModelLocked = false;
    clickSelectionModelLocked = false;
    hoverSelectionModel = MockMutableSelectionModel();
    clickSelectionModel = MockMutableSelectionModel();
    when(hoverSelectionModel.locked)
        .thenAnswer((_) => hoverSelectionModelLocked);
    when(clickSelectionModel.locked)
        .thenAnswer((_) => clickSelectionModelLocked);
    when(hoverSelectionModel.locked = any).thenAnswer((realInvocation) {
      hoverSelectionModelLocked =
          realInvocation.positionalArguments.first as bool;
    });
    when(clickSelectionModel.locked = any).thenAnswer((realInvocation) {
      clickSelectionModelLocked =
          realInvocation.positionalArguments.first as bool;
    });

    chart = MockChart();
    when(chart.getSelectionModel(SelectionModelType.info))
        .thenReturn(hoverSelectionModel);
    when(chart.getSelectionModel(SelectionModelType.action))
        .thenReturn(clickSelectionModel);
  });

  group('LockSelection trigger handling', () {
    test('can lock model with a selection', () {
      // Setup chart matches point with single domain single series.
      makeLockSelectionBehavior(SelectionModelType.info);
      Point<double> point = Point(100.0, 100.0);
      setupChart(forPoint: point, isWithinRenderer: true);

      when(hoverSelectionModel.hasAnySelection).thenReturn(true);

      // Act
      chart.lastListener!.onTapTest(point);
      chart.lastListener!.onTap!(point);

      // Validate
      verify(hoverSelectionModel.hasAnySelection);
      expect(hoverSelectionModel.locked, equals(true));
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('can lock and unlock model', () {
      // Setup chart matches point with single domain single series.
      makeLockSelectionBehavior(SelectionModelType.info);
      Point<double> point = Point(100.0, 100.0);
      setupChart(forPoint: point, isWithinRenderer: true);

      when(hoverSelectionModel.hasAnySelection).thenReturn(true);

      // Act
      chart.lastListener!.onTapTest(point);
      chart.lastListener!.onTap!(point);

      // Validate
      verify(hoverSelectionModel.hasAnySelection);
      expect(hoverSelectionModel.locked, equals(true));

      // Act
      chart.lastListener!.onTapTest(point);
      chart.lastListener!.onTap!(point);

      // Validate
      verify(hoverSelectionModel.clearSelection());
      expect(hoverSelectionModel.locked, equals(false));
      verifyNoMoreInteractions(clickSelectionModel);
    });

    test('does not lock model with empty selection', () {
      // Setup chart matches point with single domain single series.
      makeLockSelectionBehavior(SelectionModelType.info);
      Point<double> point = Point(100.0, 100.0);
      setupChart(forPoint: point, isWithinRenderer: true);

      when(hoverSelectionModel.hasAnySelection).thenReturn(false);

      // Act
      chart.lastListener!.onTapTest(point);
      chart.lastListener!.onTap!(point);

      // Validate
      verify(hoverSelectionModel.hasAnySelection);
      expect(hoverSelectionModel.locked, equals(false));
      verifyNoMoreInteractions(clickSelectionModel);
    });
  });

  group('Cleanup', () {
    test('detach removes listener', () {
      // Setup
      final behavior = makeLockSelectionBehavior(SelectionModelType.info);
      Point<double> point = Point(100.0, 100.0);
      setupChart(forPoint: point, isWithinRenderer: true);
      expect(chart.lastListener, isNotNull);

      // Act
      behavior.removeFrom(chart);

      // Validate
      expect(chart.lastListener, isNull);
    });
  });
}
