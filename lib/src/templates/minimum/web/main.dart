import 'package:pulsar_web/pulsar.dart';

void main() {
  runApp(Hello());
}

class Hello extends ContentView {
  @override
  Future<String> get template async => "<h1>Hello World!</h1>";
}
