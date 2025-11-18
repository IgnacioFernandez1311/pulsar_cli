import 'package:pulsar_web/pulsar.dart';

class CounterComponent extends Component {
  CounterComponent() {
    prop.title = "Pulsar Counter";
    state.count = 0;
    trigger.increment = (PulsarEvent event) => state.count++;
    trigger.decrement = (PulsarEvent event) => state.count--;
  }
  @override
  Future<String> get template async =>
      await loadFile('components/counter_component/counter_component.html');
}
