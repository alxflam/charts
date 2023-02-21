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

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:developer';
import 'app_config.dart';
import 'drawer.dart';
import 'a11y/a11y_gallery.dart' as a11y show buildGalleryGroup;
import 'bar_chart/bar_gallery.dart' as bar show buildGalleryGroup;
import 'time_series_chart/time_series_gallery.dart' as time_series
    show buildGalleryGroup;
import 'line_chart/line_gallery.dart' as line show buildGalleryGroup;
import 'scatter_plot_chart/scatter_plot_gallery.dart' as scatter_plot
    show buildGalleryGroup;
import 'combo_chart/combo_gallery.dart' as combo show buildGalleryGroup;
import 'pie_chart/pie_gallery.dart' as pie show buildGalleryGroup;
import 'axes/axes_gallery.dart' as axes show buildGalleryGroup;
import 'behaviors/behaviors_gallery.dart' as behaviors show buildGalleryGroup;
import 'i18n/i18n_gallery.dart' as i18n show buildGalleryGroup;
import 'legends/legends_gallery.dart' as legends show buildGalleryGroup;

/// Main entry point of the gallery app.
///
/// This renders a list of all available demos.
class Home extends StatelessWidget {
  final bool showPerformanceOverlay;
  final ValueChanged<bool> onShowPerformanceOverlayChanged;

  static final galleryScaffolds = {
    a11y.buildGalleryGroup(),
    bar.buildGalleryGroup(),
    time_series.buildGalleryGroup(),
    line.buildGalleryGroup(),
    scatter_plot.buildGalleryGroup(),
    combo.buildGalleryGroup(),
    pie.buildGalleryGroup(),
    axes.buildGalleryGroup(),
    behaviors.buildGalleryGroup(),
    i18n.buildGalleryGroup(),
    legends.buildGalleryGroup()
  };

  const Home(
      {Key? key,
      this.showPerformanceOverlay = false,
      required this.onShowPerformanceOverlayChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var galleries = galleryScaffolds
        .map((g) => g.buildGalleryGroupListTile(context))
        .toList();

    _setupPerformance();

    return Scaffold(
      drawer: GalleryDrawer(
          showPerformanceOverlay: showPerformanceOverlay,
          onShowPerformanceOverlayChanged: onShowPerformanceOverlayChanged),
      appBar: AppBar(title: Text(defaultConfig.appName)),
      body: ListView(padding: kMaterialListPadding, children: galleries),
    );
  }

  void _setupPerformance() {
    // Change [printPerformance] to true and set the app to release mode to
    // print performance numbers to console. By default, Flutter builds in debug
    // mode and this mode is slow. To build in release mode, specify the flag
    // blaze-run flag "--define flutter_build_mode=release".
    // The build target must also be an actual device and not the emulator.
    charts.Performance.time = (String tag) => Timeline.startSync(tag);
    charts.Performance.timeEnd = (_) => Timeline.finishSync();
  }
}
