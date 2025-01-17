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

/// Line chart example
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class ComparisonPointsScatterPlotChart extends StatelessWidget {
  final List<charts.Series<dynamic, num>> seriesList;
  final bool animate;

  const ComparisonPointsScatterPlotChart(this.seriesList,
      {super.key, this.animate = false});

  factory ComparisonPointsScatterPlotChart.withRandomData() {
    return ComparisonPointsScatterPlotChart(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<LinearSales, num>> _createRandomData() {
    final random = Random();

    const maxMeasure = 100;

    final data = [
      _makeRandomDatum(maxMeasure, random),
      _makeRandomDatum(maxMeasure, random),
      _makeRandomDatum(maxMeasure, random),
      _makeRandomDatum(maxMeasure, random),
      _makeRandomDatum(maxMeasure, random),
      _makeRandomDatum(maxMeasure, random),
    ];

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
        domainLowerBoundFn: (LinearSales sales, _) => sales.yearLower,
        domainUpperBoundFn: (LinearSales sales, _) => sales.yearUpper,
        measureFn: (LinearSales sales, _) => sales.sales,
        measureLowerBoundFn: (LinearSales sales, _) => sales.salesLower,
        measureUpperBoundFn: (LinearSales sales, _) => sales.salesUpper,
        radiusPxFn: (LinearSales sales, _) => sales.radius,
        data: data,
      )
    ];
  }

  static LinearSales _makeRandomDatum(int max, Random random) {
    makeRadius(int value) => (random.nextInt(value) + 6).toDouble();

    final year = random.nextInt(max);
    final yearLower = (year * 0.8).round();
    final yearUpper = year;
    final sales = random.nextInt(max);
    final salesLower = (sales * 0.8).round();
    final salesUpper = sales;

    return LinearSales(year, yearLower, yearUpper, sales, salesLower,
        salesUpper, makeRadius(4));
  }

  @override
  Widget build(BuildContext context) {
    return charts.ScatterPlotChart(seriesList,
        animate: animate,
        defaultRenderer: charts.PointRendererConfig(pointRendererDecorators: [
          charts.ComparisonPointsDecorator(
              symbolRenderer: charts.CylinderSymbolRenderer())
        ]));
  }
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final int yearLower;
  final int yearUpper;
  final int sales;
  final int salesLower;
  final int salesUpper;
  final double radius;

  LinearSales(this.year, this.yearLower, this.yearUpper, this.sales,
      this.salesLower, this.salesUpper, this.radius);
}
