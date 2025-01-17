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

import 'package:flutter/material.dart';
import '../gallery_scaffold.dart';
import '../gallery_scaffold_group.dart';
import 'confidence_interval.dart';
import 'end_points_axis.dart';
import 'line_annotation.dart';
import 'log_scale.dart';
import 'range_annotation.dart';
import 'range_annotation_margin.dart';
import 'simple.dart';
import 'symbol_annotation.dart';
import 'with_bar_renderer.dart';

GalleryScaffoldGroup buildGalleryGroup() {
  return GalleryScaffoldGroup(
      listTileIcon: const Icon(Icons.date_range),
      title: 'Time Series Charts',
      children: buildGallery());
}

List<GalleryScaffold> buildGallery() {
  return [
    GalleryScaffold(
      listTileIcon: const Icon(Icons.date_range),
      title: 'Time Series Chart',
      subtitle: 'Simple single time series chart',
      childBuilder: () => SimpleTimeSeriesChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.date_range),
      title: 'End Points Axis Time Series Chart',
      subtitle: 'Time series chart with an end points axis',
      childBuilder: () => EndPointsAxisTimeSeriesChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.date_range),
      title: 'Line Annotation on Time Series Chart',
      subtitle: 'Time series chart with future line annotation',
      childBuilder: () => TimeSeriesLineAnnotationChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.date_range),
      title: 'Range Annotation on Time Series Chart',
      subtitle: 'Time series chart with future range annotation',
      childBuilder: () => TimeSeriesRangeAnnotationChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.date_range),
      title: 'Range Annotation Margin Labels on Time Series Chart',
      subtitle:
          'Time series chart with range annotations with labels in margins',
      childBuilder: () => TimeSeriesRangeAnnotationMarginChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.date_range),
      title: 'Symbol Annotation Time Series Chart',
      subtitle: 'Time series chart with annotation data below the draw area',
      childBuilder: () => TimeSeriesSymbolAnnotationChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.date_range),
      title: 'Time Series Chart with Bars',
      subtitle: 'Time series chart using the bar renderer',
      childBuilder: () => TimeSeriesBar.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.date_range),
      title: 'Time Series Chart with Confidence Interval',
      subtitle: 'Draws area around the confidence interval',
      childBuilder: () => TimeSeriesConfidenceInterval.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.date_range),
      title: 'Time Series Chart with Log Scale (Base 10) Axis',
      subtitle: 'Common logarithm scaled measure axis',
      childBuilder: () => TimeSeriesLogScale.commonLogarithmWithRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.date_range),
      title: 'Time Series Chart with Log Scale (Base e) Axis',
      subtitle: 'Natural Logarithm scaled measure axis',
      childBuilder: () => TimeSeriesLogScale.naturalLogarithmWithRandomData(),
    ),
  ];
}
