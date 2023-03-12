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
import 'home.dart';

/// The main gallery app widget.
class GalleryApp extends StatefulWidget {
  const GalleryApp({Key? key}) : super(key: key);

  @override
  GalleryAppState createState() => GalleryAppState();
}

/// The main gallery app state.
///
/// Controls performance overlay, and instantiates a [Home] widget.
class GalleryAppState extends State<GalleryApp> {
  // Initialize app settings from the default configuration.
  bool _showPerformanceOverlay = false;
  ThemeMode _themeMode = ThemeMode.system;

  void handleBrightnessChange(Brightness brightness) {
    setState(() {
      _themeMode =
          brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Charts Gallery',
        themeMode: _themeMode,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        showPerformanceOverlay: _showPerformanceOverlay,
        home: Home(
          showPerformanceOverlay: _showPerformanceOverlay,
          onShowPerformanceOverlayChanged: (bool value) {
            setState(() {
              _showPerformanceOverlay = value;
            });
          },
          onBrightnessChanged: handleBrightnessChange,
        ));
  }
}

void main() {
  runApp(const GalleryApp());
}
