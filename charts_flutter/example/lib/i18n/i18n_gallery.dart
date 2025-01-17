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
import 'rtl_bar_chart.dart';
import 'rtl_line_chart.dart';
import 'rtl_line_segments.dart';
import 'rtl_series_legend.dart';

GalleryScaffoldGroup buildGalleryGroup() {
  return GalleryScaffoldGroup(
      listTileIcon: const Icon(Icons.flag),
      title: 'i18n',
      children: buildGallery());
}

List<GalleryScaffold> buildGallery() {
  return [
    GalleryScaffold(
      listTileIcon: const Icon(Icons.flag),
      title: 'RTL Bar Chart',
      subtitle: 'Simple bar chart in RTL',
      childBuilder: () => RTLBarChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.flag),
      title: 'RTL Line Chart',
      subtitle: 'Simple line chart in RTL',
      childBuilder: () => RTLLineChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.flag),
      title: 'RTL Line Segments',
      subtitle: 'Stacked area chart with style segments in RTL',
      childBuilder: () => RTLLineSegments.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.flag),
      title: 'RTL Series Legend',
      subtitle: 'Series legend in RTL',
      childBuilder: () => RTLSeriesLegend.withRandomData(),
    ),
  ];
}
