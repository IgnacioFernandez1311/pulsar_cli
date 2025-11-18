import 'package:pulsar_web/pulsar.dart';
import '../../components/counter_component/counter_component.dart';

class CounterApp extends ContentView {
  @override
  List<Renderable> get imports => [CounterComponent()];
  @override
  Future<String> get template async =>
      '<CounterComponent title="Welcome to Pulsar" />';
}
