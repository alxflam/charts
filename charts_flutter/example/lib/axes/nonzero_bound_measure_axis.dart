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

/// Example of timeseries chart that has a measure axis that does NOT include
/// zero. It starts at 100 and goes to 140.
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class NonzeroBoundMeasureAxis extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate;

  const NonzeroBoundMeasureAxis(this.seriesList,
      {super.key, this.animate = false});

  factory NonzeroBoundMeasureAxis.withRandomData() {
    return NonzeroBoundMeasureAxis(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<MyRow, DateTime>> _createRandomData() {
    final random = Random();

    final data = [
      MyRow(DateTime(2017, 9, 25), random.nextInt(100) + 100),
      MyRow(DateTime(2017, 9, 26), random.nextInt(100) + 100),
      MyRow(DateTime(2017, 9, 27), random.nextInt(100) + 100),
      MyRow(DateTime(2017, 9, 28), random.nextInt(100) + 100),
      MyRow(DateTime(2017, 9, 29), random.nextInt(100) + 100),
      MyRow(DateTime(2017, 9, 30), random.nextInt(100) + 100),
      MyRow(DateTime(2017, 10, 01), random.nextInt(100) + 100),
      MyRow(DateTime(2017, 10, 02), random.nextInt(100) + 100),
      MyRow(DateTime(2017, 10, 03), random.nextInt(100) + 100),
      MyRow(DateTime(2017, 10, 04), random.nextInt(100) + 100),
      MyRow(DateTime(2017, 10, 05), random.nextInt(100) + 100),
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
    return charts.TimeSeriesChart(seriesList,
        animate: animate,
        // Provide a tickProviderSpec which does NOT require that zero is
        // included.
        primaryMeasureAxis: const charts.NumericAxisSpec(
            tickProviderSpec:
                charts.BasicNumericTickProviderSpec(zeroBound: false)));
  }
}

/// Sample time series data type.
class MyRow {
  final DateTime timeStamp;
  final int headcount;
  MyRow(this.timeStamp, this.headcount);
}
