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

/// Example of a time series chart with log scale axis.
import 'dart:math';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

class TimeSeriesLogScale extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate;
  final NumericTickFormatterSpec logTickFormatterSpec;

  const TimeSeriesLogScale(this.seriesList, this.logTickFormatterSpec,
      {super.key, this.animate = false});

  factory TimeSeriesLogScale.commonLogarithmWithRandomData() {
    return TimeSeriesLogScale(
        _createRandomData(
            (TimeSeriesSales sales, _) => log(sales.sales) / ln10),
        charts.BasicNumericTickFormatterSpec(
            (measure) => pow(10, measure!).round().toString()));
  }

  factory TimeSeriesLogScale.naturalLogarithmWithRandomData() {
    return TimeSeriesLogScale(
        _createRandomData((TimeSeriesSales sales, _) => log(sales.sales)),
        charts.BasicNumericTickFormatterSpec(
            (measure) => exp(measure!).round().toString()));
  }

  /// Create random data
  static List<charts.Series<TimeSeriesSales, DateTime>> _createRandomData(
      TypedAccessorFn<TimeSeriesSales, num> measureFn) {
    final random = Random();
    var base = random.nextInt(10);

    final data = [
      TimeSeriesSales(DateTime(2017, 9, 1), base),
      TimeSeriesSales(DateTime(2017, 9, 2), base * 2),
      TimeSeriesSales(DateTime(2017, 9, 3), base * 4),
      TimeSeriesSales(DateTime(2017, 9, 4), base * 8),
      TimeSeriesSales(DateTime(2017, 9, 5), base * 16),
      TimeSeriesSales(DateTime(2017, 9, 6), base * 32),
      TimeSeriesSales(DateTime(2017, 9, 7), base * 64),
      TimeSeriesSales(DateTime(2017, 9, 8), base * 128),
      TimeSeriesSales(DateTime(2017, 9, 9), base * 256),
      TimeSeriesSales(DateTime(2017, 9, 10), base * 512),
      TimeSeriesSales(DateTime(2017, 9, 11), base * 1024),
    ];

    return [
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: measureFn,
        data: data,
      ),
      charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales2',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
        // Set series to use the secondary measure axis.
        ..setAttribute(charts.measureAxisIdKey, 'secondaryMeasureAxisId'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec:
            const charts.BasicNumericTickProviderSpec(zeroBound: false),
        tickFormatterSpec: logTickFormatterSpec,
      ),
      secondaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec:
            const charts.BasicNumericTickProviderSpec(zeroBound: false),
        tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
            (measure) => measure.toString()),
      ),
    );
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
