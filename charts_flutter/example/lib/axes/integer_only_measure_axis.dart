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

/// Example of timeseries chart forcing the measure axis to have whole number
/// ticks. This is useful if the measure units don't make sense to present as
/// fractional.
///
/// This is done by customizing the measure axis and setting
/// [dataIsInWholeNumbers] on the tick provider.
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class IntegerOnlyMeasureAxis extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate;

  const IntegerOnlyMeasureAxis(this.seriesList,
      {super.key, this.animate = false});

  factory IntegerOnlyMeasureAxis.withRandomData() {
    return IntegerOnlyMeasureAxis(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<MyRow, DateTime>> _createRandomData() {
    final random = Random();

    final data = [
      MyRow(DateTime(2017, 9, 25), random.nextDouble().round()),
      MyRow(DateTime(2017, 9, 26), random.nextDouble().round()),
      MyRow(DateTime(2017, 9, 27), random.nextDouble().round()),
      MyRow(DateTime(2017, 9, 28), random.nextDouble().round()),
      MyRow(DateTime(2017, 9, 29), random.nextDouble().round()),
      MyRow(DateTime(2017, 9, 30), random.nextDouble().round()),
      MyRow(DateTime(2017, 10, 01), random.nextDouble().round()),
      MyRow(DateTime(2017, 10, 02), random.nextDouble().round()),
      MyRow(DateTime(2017, 10, 03), random.nextDouble().round()),
      MyRow(DateTime(2017, 10, 04), random.nextDouble().round()),
      MyRow(DateTime(2017, 10, 05), random.nextDouble().round()),
    ];

    return [
      charts.Series<MyRow, DateTime>(
        id: 'Headcount',
        domainFn: (MyRow row, _) => row.timeStamp,
        measureFn: (MyRow row, _) => row.headcount,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Provides a custom axis ensuring that the ticks are in whole numbers.
      primaryMeasureAxis: const charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
              // Make sure we don't have values less than 1 as ticks
              // (ie: counts).
              dataIsInWholeNumbers: true,
              // Fixed tick count to highlight the integer only behavior
              // generating ticks [0, 1, 2, 3, 4].
              desiredTickCount: 5)),
    );
  }
}

/// Sample time series data type.
class MyRow {
  final DateTime timeStamp;
  final int headcount;
  MyRow(this.timeStamp, this.headcount);
}
