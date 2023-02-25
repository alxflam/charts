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

/// Scatter plot chart example
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleScatterPlotChart extends StatelessWidget {
  final List<charts.Series<dynamic, num>> seriesList;
  final bool animate;

  const SimpleScatterPlotChart(this.seriesList,
      {super.key, this.animate = false});

  factory SimpleScatterPlotChart.withRandomData() {
    return SimpleScatterPlotChart(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<LinearSales, num>> _createRandomData() {
    final random = Random();

    makeRadius(int value) => (random.nextInt(value) + 2).toDouble();

    final data = [
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
    ];

    const maxMeasure = 100;

    return [
      charts.Series<LinearSales, int>(
        id: 'Sales',
        colorFn: (LinearSales sales, _) {
          // Color bucket the measure column value into 3 distinct colors.
          final bucket = sales.sales / maxMeasure;

          if (bucket < 1 / 3) {
            return charts.MaterialPalette.blue.shadeDefault;
          } else if (bucket < 2 / 3) {
            return charts.MaterialPalette.red.shadeDefault;
          } else {
            return charts.MaterialPalette.green.shadeDefault;
          }
        },
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        radiusPxFn: (LinearSales sales, _) => sales.radius,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.ScatterPlotChart(seriesList, animate: animate);
  }
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final int sales;
  final double radius;

  LinearSales(this.year, this.sales, this.radius);
}
