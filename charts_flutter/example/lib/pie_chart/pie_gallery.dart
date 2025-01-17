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
import 'auto_label.dart';
import 'donut.dart';
import 'gauge.dart';
import 'simple.dart';
import 'outside_label.dart';
import 'partial_pie.dart';

GalleryScaffoldGroup buildGalleryGroup() {
  return GalleryScaffoldGroup(
      listTileIcon: const Icon(Icons.pie_chart),
      title: 'Pie Charts',
      children: buildGallery());
}

List<GalleryScaffold> buildGallery() {
  return [
    GalleryScaffold(
      listTileIcon: const Icon(Icons.pie_chart),
      title: 'Simple Pie Chart',
      subtitle: 'With a single series',
      childBuilder: () => SimplePieChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.pie_chart),
      title: 'Outside Label Pie Chart',
      subtitle: 'With a single series and labels outside the arcs',
      childBuilder: () => PieOutsideLabelChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.pie_chart),
      title: 'Partial Pie Chart',
      subtitle: 'That doesn\'t cover a full revolution',
      childBuilder: () => PartialPieChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.donut_large),
      title: 'Simple Donut Chart',
      subtitle: 'With a single series and a hole in the middle',
      childBuilder: () => DonutPieChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.donut_large),
      title: 'Auto Label Donut Chart',
      subtitle:
          'With a single series, a hole in the middle, and auto-positioned labels',
      childBuilder: () => DonutAutoLabelChart.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.donut_large),
      title: 'Gauge Chart',
      subtitle: 'That doesn\'t cover a full revolution',
      childBuilder: () => GaugeChart.withRandomData(),
    ),
  ];
}
