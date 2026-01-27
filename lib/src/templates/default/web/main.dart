import 'package:pulsar_web/pulsar.dart';
import 'components/counter/counter.dart';

void main() {
  mountApp(CounterApp(), selector: "#app");
}
