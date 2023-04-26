// Copyright 2023
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

class SimpleTreeMap extends StatelessWidget {
  final List<charts.Series<charts.TreeNode<String>, String>> seriesList;
  final bool animate;

  const SimpleTreeMap(this.seriesList, {super.key, this.animate = false});

  factory SimpleTreeMap.withRandomData() {
    return SimpleTreeMap(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<charts.TreeNode<String>, String>>
      _createRandomData() {
    var rootNode = SampleTreeNode('Root', 500)
      ..addChildren([
        SampleTreeNode('A', 100)
          ..addChildren([SampleTreeNode('Ab', 40), SampleTreeNode('Ac', 60)]),
        SampleTreeNode('B', 100),
        SampleTreeNode('C', 100),
        SampleTreeNode('D', 100),
        SampleTreeNode('E', 100),
      ]);

    var tree = [
      charts.Tree<String, String>(
        id: 'Sales',
        domainFn: (node, _) => node,
        measureFn: (node, _) {
          int res = 0;
          rootNode.visit((n) {
            if (n.data == node) {
              res = (n as SampleTreeNode).sales;
            }
          });

          return res;
        },
        root: rootNode,
      ),
    ];

    return tree.map((e) => e.toSeries()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return charts.TreeMapChart<String>(
      seriesList,
      animate: true,
      defaultRenderer: charts.TreeMapRendererConfig(
        tileType: charts.TreeMapTileType.squarified,
        labelDecorator: charts.TreeMapLabelDecorator(
          labelStyleSpec: const charts.TextStyleSpec(
              fontSize: 24, color: charts.Color.white),
        ),
      ),
    );
  }
}

class SampleTreeNode extends charts.TreeNode<String> {
  final int sales;

  SampleTreeNode(super.data, this.sales);
}
