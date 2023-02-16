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

import 'package:charts_common/src/chart/cartesian/axis/scale.dart';
import 'package:charts_common/src/chart/cartesian/axis/simple_ordinal_scale.dart';
import 'package:charts_common/src/common/style/material_style.dart';
import 'package:charts_common/src/common/style/style_factory.dart';

import 'package:test/test.dart';

const epsilon = 0.001;

class TestStyle extends MaterialStyle {
  @override
  double rangeBandSize = 0.0;
}

void main() {
  late SimpleOrdinalScale scale;

  setUp(() {
    scale = SimpleOrdinalScale();
    scale.addDomain('a');
    scale.addDomain('b');
    scale.addDomain('c');
    scale.addDomain('d');

    scale.range = ScaleOutputExtent(2000, 1000);
  });

  group('conversion', () {
    test('with duplicate keys', () {
      scale.addDomain('c');
      scale.addDomain('a');

      // Current RangeBandConfig.styleAssignedPercent sets size to 0.65 percent.
      expect(scale.rangeBand, closeTo(250 * 0.65, epsilon));
      expect(scale['a'], closeTo(2000 - 125, epsilon));
      expect(scale['b'], closeTo(2000 - 375, epsilon));
      expect(scale['c'], closeTo(2000 - 625, epsilon));
    });

    test('invalid domain does not throw exception', () {
      expect(scale['e'], 0);
    });

    test('invalid domain can translate is false', () {
      expect(scale.canTranslate('e'), isFalse);
    });
  });

  group('copy', () {
    test('can convert domain', () {
      final copied = scale.copy();
      expect(copied['c'], closeTo(2000 - 625, epsilon));
    });

    test('does not affect original', () {
      final copied = scale.copy();
      copied.addDomain('bar');

      expect(copied.canTranslate('bar'), isTrue);
      expect(scale.canTranslate('bar'), isFalse);
    });
  });

  group('reset', () {
    test('clears domains', () {
      scale.resetDomain();
      scale.addDomain('foo');
      scale.addDomain('bar');

      expect(scale['foo'], closeTo(2000 - 250, epsilon));
    });
  });

  group('set RangeBandConfig', () {
    test('fixed pixel range band changes range band', () {
      scale.rangeBandConfig = RangeBandConfig.fixedPixel(123.0);

      expect(scale.rangeBand, closeTo(123.0, epsilon));

      // Adding another domain to ensure it still doesn't change.
      scale.addDomain('foo');
      expect(scale.rangeBand, closeTo(123.0, epsilon));
    });

    test('percent range band changes range band', () {
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(0.5);
      // 125 = 0.5f * 1000pixels / 4domains
      expect(scale.rangeBand, closeTo(125.0, epsilon));
    });

    test('space from step changes range band', () {
      scale.rangeBandConfig = RangeBandConfig.fixedPixelSpaceBetweenStep(50.0);
      // 200 = 1000pixels / 4domains) - 50
      expect(scale.rangeBand, closeTo(200.0, epsilon));
    });

    test('fixed domain throws argument exception', () {
      expect(() => scale.rangeBandConfig = RangeBandConfig.fixedDomain(5.0),
          throwsArgumentError);
    });

    test('type of none throws argument exception', () {
      expect(() => scale.rangeBandConfig = RangeBandConfig.none(),
          throwsArgumentError);
    });

    test('range band size used from style', () {
      var oldStyle = StyleFactory.style;
      StyleFactory.style = TestStyle()..rangeBandSize = 0.4;

      scale.rangeBandConfig = RangeBandConfig.styleAssignedPercent();
      // 100 = 0.4f * 1000pixels / 4domains
      expect(scale.rangeBand, closeTo(100, epsilon));

      // Restore style for other tests.
      StyleFactory.style = oldStyle;
    });
  });

  group('set step size config', () {
    test('to null does not throw', () {
      scale.stepSizeConfig = null;
    });

    test('to auto does not throw', () {
      scale.stepSizeConfig = StepSizeConfig.auto();
    });

    test('to fixed domain throw arugment exception', () {
      expect(() => scale.stepSizeConfig = StepSizeConfig.fixedDomain(1.0),
          throwsArgumentError);
    });

    test('to fixed pixel throw arugment exception', () {
      expect(() => scale.stepSizeConfig = StepSizeConfig.fixedPixels(1.0),
          throwsArgumentError);
    });
  });

  group('set range persists', () {
    test('', () {
      expect(scale.range.start, equals(2000));
      expect(scale.range.end, equals(1000));
      expect(scale.range.min, equals(1000));
      expect(scale.range.max, equals(2000));
      expect(scale.rangeWidth, equals(1000));

      expect(scale.isRangeValueWithinViewport(1500.0), isTrue);
      expect(scale.isRangeValueWithinViewport(1000.0), isTrue);
      expect(scale.isRangeValueWithinViewport(2000.0), isTrue);

      expect(scale.isRangeValueWithinViewport(500.0), isFalse);
      expect(scale.isRangeValueWithinViewport(2500.0), isFalse);
    });
  });

  group('scale factor', () {
    test('sets horizontally', () {
      scale.range = ScaleOutputExtent(1000, 2000);
      scale.setViewportSettings(2.0, -700.0);

      expect(scale.viewportScalingFactor, closeTo(2.0, epsilon));
      expect(scale.viewportTranslatePx, closeTo(-700.0, epsilon));
    });

    test('sets vertically', () {
      scale.range = ScaleOutputExtent(2000, 1000);
      scale.setViewportSettings(2.0, 700.0);

      expect(scale.viewportScalingFactor, closeTo(2.0, epsilon));
      expect(scale.viewportTranslatePx, closeTo(700.0, epsilon));
    });

    test('rangeband is scaled horizontally', () {
      scale.range = ScaleOutputExtent(1000, 2000);
      scale.setViewportSettings(2.0, -700.0);
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(1.0);

      expect(scale.rangeBand, closeTo(500.0, epsilon));
    });

    test('rangeband is scaled vertically', () {
      scale.range = ScaleOutputExtent(2000, 1000);
      scale.setViewportSettings(2.0, 700.0);
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(1.0);

      expect(scale.rangeBand, closeTo(500.0, epsilon));
    });

    test('translate to pixels is scaled horizontally', () {
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(1.0);
      scale.range = ScaleOutputExtent(1000, 2000);
      scale.setViewportSettings(2.0, -700.0);

      final scaledStepWidth = 500.0;
      final scaledInitialShift = 250.0;

      expect(scale['a'], closeTo(1000 + scaledInitialShift - 700, epsilon));

      expect(scale['b'],
          closeTo(1000 + scaledInitialShift - 700 + scaledStepWidth, epsilon));
    });

    test('translate to pixels is scaled vertically', () {
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(1.0);
      scale.range = ScaleOutputExtent(2000, 1000);
      scale.setViewportSettings(2.0, 700.0);

      final scaledStepWidth = 500.0;
      final scaledInitialShift = 250.0;

      expect(scale['a'], closeTo(2000 - scaledInitialShift + 700, epsilon));

      expect(
          scale['b'],
          closeTo(2000 - scaledInitialShift + 700 - (scaledStepWidth * 1),
              epsilon));
    });

    test('only b and c should be within the viewport horizontally', () {
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(1.0);
      scale.range = ScaleOutputExtent(1000, 2000);
      scale.setViewportSettings(2.0, -700.0);

      expect(scale.compareDomainValueToViewport('a'), equals(-1));
      expect(scale.compareDomainValueToViewport('c'), equals(0));
      expect(scale.compareDomainValueToViewport('d'), equals(1));
      expect(scale.compareDomainValueToViewport('f'), isNot(0));
    });

    test('only b and c should be within the viewport vertically', () {
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(1.0);
      scale.range = ScaleOutputExtent(2000, 1000);
      scale.setViewportSettings(2.0, 700.0);

      expect(scale.compareDomainValueToViewport('a'), equals(1));
      expect(scale.compareDomainValueToViewport('c'), equals(0));
      expect(scale.compareDomainValueToViewport('d'), equals(-1));
      expect(scale.compareDomainValueToViewport('f'), isNot(0));
    });

    test('applies in reverse horizontally', () {
      scale.range = ScaleOutputExtent(1000, 2000);
      scale.setViewportSettings(2.0, -700.0);

      expect(scale.reverse(scale['d']), 'd');
      expect(scale.reverse(scale['b']), 'b');
      expect(scale.reverse(scale['c']), 'c');
      expect(scale.reverse(scale['d']), 'd');
    });

    test('applies in reverse vertically', () {
      scale.range = ScaleOutputExtent(2000, 1000);
      scale.setViewportSettings(2.0, 700.0);

      expect(scale.reverse(scale['d']), 'd');
      expect(scale.reverse(scale['b']), 'b');
      expect(scale.reverse(scale['c']), 'c');
      expect(scale.reverse(scale['d']), 'd');
    });
  });

  group('viewport', () {
    test('set adjust scale to show viewport horizontally', () {
      scale.range = ScaleOutputExtent(1000, 2000);
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(0.5);
      scale.setViewport(2, 'b');

      expect(scale['a'], closeTo(750, epsilon));
      expect(scale['b'], closeTo(1250, epsilon));
      expect(scale['c'], closeTo(1750, epsilon));
      expect(scale['d'], closeTo(2250, epsilon));
      expect(scale.compareDomainValueToViewport('a'), equals(-1));
      expect(scale.compareDomainValueToViewport('b'), equals(0));
      expect(scale.compareDomainValueToViewport('c'), equals(0));
      expect(scale.compareDomainValueToViewport('d'), equals(1));
    });

    test('set adjust scale to show viewport vertically', () {
      scale.range = ScaleOutputExtent(2000, 1000);
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(0.5);
      // Bottom up as domain values are usually reversed.
      scale.setViewport(2, 'c');

      expect(scale['a'], closeTo(2250, epsilon));
      expect(scale['b'], closeTo(1750, epsilon));
      expect(scale['c'], closeTo(1250, epsilon));
      expect(scale['d'], closeTo(750, epsilon));
      expect(scale.compareDomainValueToViewport('a'), equals(1));
      expect(scale.compareDomainValueToViewport('b'), equals(0));
      expect(scale.compareDomainValueToViewport('c'), equals(0));
      expect(scale.compareDomainValueToViewport('d'), equals(-1));
    });

    test('illegal to set window size less than one', () {
      expect(() => scale.setViewport(0, 'b'), throwsArgumentError);
    });

    test(
        'set starting value if starting domain is not in domain list '
        'horizontally', () {
      scale.range = ScaleOutputExtent(1000, 2000);
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(0.5);
      scale.setViewport(2, 'f');

      expect(scale['a'], closeTo(1250, epsilon));
      expect(scale['b'], closeTo(1750, epsilon));
      expect(scale['c'], closeTo(2250, epsilon));
      expect(scale['d'], closeTo(2750, epsilon));
    });

    test(
        'set starting value if starting domain is not in domain list '
        'vertically', () {
      scale.range = ScaleOutputExtent(2000, 1000);
      scale.rangeBandConfig = RangeBandConfig.percentOfStep(0.5);
      scale.setViewport(2, 'f');

      expect(scale['a'], closeTo(2750, epsilon));
      expect(scale['b'], closeTo(2250, epsilon));
      expect(scale['c'], closeTo(1750, epsilon));
      expect(scale['d'], closeTo(1250, epsilon));
    });

    test(
        'get size returns number of full steps that fit scale range '
        'horizontally ', () {
      scale.range = ScaleOutputExtent(1000, 2000);

      scale.setViewportSettings(2.0, 0.0);
      expect(scale.viewportDataSize, equals(2));

      scale.setViewportSettings(5.0, 0.0);
      expect(scale.viewportDataSize, equals(0));
    });

    test(
        'get size returns number of full steps that fit scale range '
        'vertically ', () {
      scale.range = ScaleOutputExtent(2000, 1000);

      scale.setViewportSettings(2.0, 0.0);
      expect(scale.viewportDataSize, equals(2));

      scale.setViewportSettings(5.0, 0.0);
      expect(scale.viewportDataSize, equals(0));
    });

    test('get starting viewport gets first fully visible domain horizontally',
        () {
      scale.range = ScaleOutputExtent(1000, 2000);

      scale.setViewportSettings(2.0, -500.0);
      expect(scale.viewportStartingDomain, equals('b'));

      scale.setViewportSettings(2.0, -100.0);
      expect(scale.viewportStartingDomain, equals('b'));
    });

    test('get starting viewport gets first fully visible domain vertically',
        () {
      scale.range = ScaleOutputExtent(2000, 1000);

      scale.setViewportSettings(2.0, 500.0);
      expect(scale.viewportStartingDomain, equals('c'));

      scale.setViewportSettings(2.0, 500.0);
      expect(scale.viewportStartingDomain, equals('c'));
    });
  });
}
