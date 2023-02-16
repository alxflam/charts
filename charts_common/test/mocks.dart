import 'package:charts_common/common.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<ChartContext>(),
  MockSpec<CartesianChart>(),
  MockSpec<Axis<String>>(as: #MockStringAxis),
  MockSpec<Axis<num>>(as: #MockNumAxis),
  MockSpec<Axis<int>>(as: #MockIntAxis),
  MockSpec<Axis<DateTime>>(as: #MockDateTimeAxis),
  MockSpec<OrdinalAxis>(),
  MockSpec<ChartCanvas>(),
  MockSpec<GraphicsFactory>(),
  MockSpec<SymbolRenderer>(),
  MockSpec<TextStyle>(),
  MockSpec<TextElement>(),
  MockSpec<LineStyle>(),
  MockSpec<ChartBehavior<String>>(as: #MockStringChartBehavior),
  MockSpec<BaseChart>()
])
class Dummy {
  // just a dummy class to generate mocks
}
