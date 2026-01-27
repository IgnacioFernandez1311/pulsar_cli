import 'package:pulsar_web/pulsar.dart';
import 'views/counter/counter.dart';

void main() {
  mountApp(CounterApp(), selector: "#app");
}
