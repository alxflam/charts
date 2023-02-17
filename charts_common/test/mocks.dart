import 'package:charts_common/common.dart';
import 'package:charts_common/src/chart/cartesian/axis/numeric_tick_provider.dart';
import 'package:charts_common/src/chart/cartesian/axis/simple_ordinal_scale.dart';
import 'package:charts_common/src/chart/cartesian/axis/time/date_time_scale.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<ChartContext>(),
  MockSpec<CartesianChart>(),
  MockSpec<Axis<String>>(as: #MockStringAxis),
  MockSpec<Axis<num>>(as: #MockNumAxis),
  MockSpec<Axis<int>>(as: #MockIntAxis),
  MockSpec<Axis<DateTime>>(as: #MockDateTimeAxis),
  MockSpec<NumericAxis>(),
  MockSpec<OrdinalAxis>(),
  MockSpec<ChartCanvas>(),
  MockSpec<GraphicsFactory>(),
  MockSpec<SymbolRenderer>(),
  MockSpec<TextStyle>(),
  MockSpec<TextElement>(),
  MockSpec<LineStyle>(),
  MockSpec<ChartBehavior<String>>(as: #MockStringChartBehavior),
  MockSpec<BaseChart>(),
  MockSpec<TickDrawStrategy<num>>(),
  MockSpec<NumericTickProvider>(),
  MockSpec<DateTimeScale>(),
  MockSpec<NumericScale>(),
  MockSpec<SimpleOrdinalScale>(),
  MockSpec<TickFormatter<num>>(as: #MockNumericTickFormatter),
  MockSpec<ImmutableSeries<String>>(as: #MockStringImmutableSeries),
  MockSpec<BaseTickDrawStrategy<num>>(
      as: #MockNumBaseTickDrawStrategy,
      unsupportedMembers: {#normalizeVerticalAnchor}),
  MockSpec<DatumDetails>(),
  MockSpec<MutableSelectionModel>(),
  MockSpec<MutableSelectionModel<String>>(as: #MockStringMutableSelectionModel),
  MockSpec<BaseChart<String>>(as: #MockStringBaseChart),
])
class Dummy {
  // just a dummy class to generate mocks
}
