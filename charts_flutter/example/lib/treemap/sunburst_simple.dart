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

class SimpleSunburstMap extends StatelessWidget {
  final List<charts.Series<charts.TreeNode<TreeNodeData>, String>> seriesList;
  final bool animate;

  const SimpleSunburstMap(this.seriesList, {super.key, this.animate = false});

  factory SimpleSunburstMap.withRandomData() {
    return SimpleSunburstMap(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<charts.TreeNode<TreeNodeData>, String>>
      _createRandomData() {
    var rootNode = SampleTreeNode(TreeNodeData("Level0", 1))
      ..addChild(SampleTreeNode(TreeNodeData('Root', 500))
        ..addChildren([
          SampleTreeNode(TreeNodeData('A', 100))
            ..addChildren([
              SampleTreeNode(TreeNodeData('Ab', 40)),
              SampleTreeNode(TreeNodeData('Ac', 60))
            ]),
          SampleTreeNode(TreeNodeData('B', 100)),
          SampleTreeNode(TreeNodeData('C', 100)),
          SampleTreeNode(TreeNodeData('D', 100)),
          SampleTreeNode(TreeNodeData('E', 100)),
        ]));

    var tree = charts.Tree<TreeNodeData, String>(
      id: 'Sales',
      domainFn: (node, _) => node.label,
      measureFn: (node, _) => node.data,
      root: rootNode,
    );

    return [tree.toSeries()];
  }

  @override
  Widget build(BuildContext context) {
    return charts.SunburstChart<Object>(
      seriesList,
      animate: false,
      behaviors: [
        charts.SunburstRingExpander(),
      ],
      defaultRenderer: charts.SunburstArcRendererConfig(initialDisplayLevel: 1),
    );
  }
}

class TreeNodeData {
  final String label;
  final int data;

  TreeNodeData(this.label, this.data);
}

class SampleTreeNode extends charts.TreeNode<TreeNodeData> {
  SampleTreeNode(super.data);
}
