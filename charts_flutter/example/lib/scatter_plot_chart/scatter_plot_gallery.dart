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
import 'animation_zoom.dart';
import 'bucketing_axis.dart';
import 'comparison_points.dart';
import 'shapes.dart';
import 'simple.dart';

GalleryScaffoldGroup buildGalleryGroup() {
  return GalleryScaffoldGroup(
      listTileIcon: const Icon(Icons.scatter_plot),
      title: 'Scatter Plot Charts',
      children: buildGallery());
}

List<GalleryScaffold> buildGallery() {
  return [
    GalleryScaffold(
      listTileIcon: const Icon(Icons.scatter_plot),
      title: 'Simple Scatter Plot Chart',
      subtitle: 'With a single series',
      childBuilder: () => SimpleScatterPlotChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.scatter_plot),
      title: 'Shapes Scatter Plot Chart',
      subtitle: 'With custom shapes',
      childBuilder: () => ShapesScatterPlotChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.scatter_plot),
      title: 'Comparison Points Scatter Plot Chart',
      subtitle: 'Scatter plot chart with comparison points',
      childBuilder: () => ComparisonPointsScatterPlotChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.scatter_plot),
      title: 'Pan and Zoom Scatter Plot Chart',
      subtitle: 'Simple scatter plot chart pan and zoom behaviors enabled',
      childBuilder: () => ScatterPlotAnimationZoomChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.scatter_plot),
      title: 'Bucketing Axis Scatter Plot Chart',
      subtitle:
          'Scatter plot with a measure axis that buckets values less than 10% into a single region below the draw area',
      childBuilder: () => BucketingAxisScatterPlotChart.withRandomData(),
    ),
  ];
}
