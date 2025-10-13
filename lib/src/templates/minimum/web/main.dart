import 'package:pulsar_web/pulsar.dart';

void main() {
  runApp([Hello()]);
}

class Hello extends Component {
  @override
  Future<String> template() async => "<h1>Hello World!</h1>";
  @override
  Map<String, dynamic> props() => {};
}
