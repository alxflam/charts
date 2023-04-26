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

import 'package:example/treemap/treemap_simple.dart';
import 'package:flutter/material.dart';
import '../gallery_scaffold.dart';
import '../gallery_scaffold_group.dart';
import 'sunburst_simple.dart';

GalleryScaffoldGroup buildGalleryGroup() {
  return GalleryScaffoldGroup(
      listTileIcon: const Icon(Icons.account_tree),
      title: 'Tree Map and Sunburst Charts',
      children: buildGallery());
}

List<GalleryScaffold> buildGallery() {
  return [
    GalleryScaffold(
      listTileIcon: const Icon(Icons.account_tree),
      title: 'Simple Tree Map',
      subtitle: '',
      childBuilder: () => SimpleTreeMap.withRandomData(),
    ),
    GalleryScaffold(
      listTileIcon: const Icon(Icons.account_tree),
      title: 'Simple Sunburst Map',
      subtitle: '',
      childBuilder: () => SimpleSunburstMap.withRandomData(),
    ),
  ];
}
