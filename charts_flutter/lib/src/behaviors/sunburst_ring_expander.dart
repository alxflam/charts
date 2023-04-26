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

import 'package:charts_common/common.dart' as common
    show ChartBehavior, SelectionModelType, SunburstRingExpander;
import 'package:meta/meta.dart' show immutable;

import 'chart_behavior.dart' show ChartBehavior, GestureType;

/// Chart behavior that enables to expand and collapse sunburst rings
@immutable
class SunburstRingExpander<D> extends ChartBehavior<D> {
  @override
  final desiredGestures = <GestureType>{};

  final common.SelectionModelType selectionModelType;

  SunburstRingExpander(
      {this.selectionModelType = common.SelectionModelType.info});

  @override
  common.SunburstRingExpander<D> createCommonBehavior() =>
      common.SunburstRingExpander<D>(selectionModelType);

  @override
  void updateCommonBehavior(common.ChartBehavior commonBehavior) {}

  @override
  String get role => 'SunburstRingExpander-$selectionModelType';

  @override
  bool operator ==(Object other) {
    return other is SunburstRingExpander &&
        selectionModelType == other.selectionModelType;
  }

  @override
  int get hashCode {
    return Object.hashAll([selectionModelType]);
  }
}
