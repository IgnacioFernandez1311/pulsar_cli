import 'package:pulsar_web/pulsar.dart';

void main() {
  mountApp(Hello(), selector: "#app");
}

class Hello extends Component {
  @override
  PulsarNode render() {
    return h1(children: <PulsarNode>[text("Hello World")]);
  }
}
