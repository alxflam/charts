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

/// Custom Tick Label Alignment Example
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/// Example of using a custom primary measure replacing the renderSpec with one
/// that aligns the text under the tick and left justifies.
class MeasureAxisLabelAlignment extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  const MeasureAxisLabelAlignment(this.seriesList,
      {super.key, this.animate = false});

  factory MeasureAxisLabelAlignment.withRandomData() {
    return MeasureAxisLabelAlignment(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<OrdinalSales, String>> _createRandomData() {
    final random = Random();

    final globalSalesData = [
      OrdinalSales('2014', random.nextInt(100) * 100),
      OrdinalSales('2015', random.nextInt(100) * 100),
      OrdinalSales('2016', random.nextInt(100) * 100),
      OrdinalSales('2017', random.nextInt(100) * 100),
    ];

    return [
      charts.Series<OrdinalSales, String>(
        id: 'Global Revenue',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: globalSalesData,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,

      /// Customize the primary measure axis using a small tick renderer.
      /// Use String instead of num for ordinal domain axis
      /// (typically bar charts).
      primaryMeasureAxis: const charts.NumericAxisSpec(
          renderSpec: charts.GridlineRendererSpec(
        // Display the measure axis labels below the gridline.
        //
        // 'Before' & 'after' follow the axis value direction.
        // Vertical axes draw 'before' below & 'after' above the tick.
        // Horizontal axes draw 'before' left & 'after' right the tick.
        labelAnchor: charts.TickLabelAnchor.before,

        // Left justify the text in the axis.
        //
        // Note: outside means that the secondary measure axis would right
        // justify.
        labelJustification: charts.TickLabelJustification.outside,
      )),
    );
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
