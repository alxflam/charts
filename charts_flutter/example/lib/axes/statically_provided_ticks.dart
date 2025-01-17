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

/// Example of axis using statically provided ticks.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/// Example of specifying a custom set of ticks to be used on the domain axis.
///
/// Specifying custom set of ticks allows specifying exactly what ticks are
/// used in the axis. Each tick is also allowed to have a different style set.
///
/// For an ordinal axis, the [StaticOrdinalTickProviderSpec] is shown in this
/// example defining ticks to be used with [TickSpec] of String.
///
/// For numeric axis, the [StaticNumericTickProviderSpec] can be used by passing
/// in a list of ticks defined with [TickSpec] of num.
///
/// For datetime axis, the [StaticDateTimeTickProviderSpec] can be used by
/// passing in a list of ticks defined with [TickSpec] of datetime.
class StaticallyProvidedTicks extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  const StaticallyProvidedTicks(this.seriesList,
      {super.key, this.animate = false});

  factory StaticallyProvidedTicks.withRandomData() {
    return StaticallyProvidedTicks(_createRandomData());
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
    // Create the ticks to be used the domain axis.
    final staticTicks = <charts.TickSpec<String>>[
      const charts.TickSpec(
          // Value must match the domain value.
          '2014',
          // Optional label for this tick, defaults to domain value if not set.
          label: 'Year 2014',
          // The styling for this tick.
          style: charts.TextStyleSpec(
              color: charts.Color(r: 0x4C, g: 0xAF, b: 0x50))),
      // If no text style is specified - the style from renderSpec will be used
      // if one is specified.
      const charts.TickSpec('2015'),
      const charts.TickSpec('2016'),
      const charts.TickSpec('2017'),
    ];

    return charts.BarChart(
      seriesList,
      animate: animate,
      domainAxis: charts.OrdinalAxisSpec(
          tickProviderSpec: charts.StaticOrdinalTickProviderSpec(staticTicks)),
    );
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
