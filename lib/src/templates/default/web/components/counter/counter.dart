import 'package:pulsar_web/pulsar.dart';
import 'package:universal_web/web.dart';

class CounterApp extends Component {
  @override
  List<Stylesheet> get styles => [css("components/counter/counter.css")];

  int count = 0;

  void increment(Event event) => setState(() => count++);

  void decrement(Event event) => setState(() => count--);

  @override
  PulsarNode render() {
    return div(
      children: <PulsarNode>[
        h1(children: [text("Welcome to Pulsar Web")]),
        img(attrs: {"src": StringAttribute("assets/Logo.png")}),
        hr(),
        h2(children: [text("$count")]),
        div(
          classes: "buttons",
          children: <PulsarNode>[
            button(
              classes: "button-circular",
              attrs: <String, Attribute>{'onClick': EventAttribute(decrement)},
              children: <PulsarNode>[text('-')],
            ),
            button(
              classes: "button-circular",
              attrs: <String, Attribute>{'onClick': EventAttribute(increment)},
              children: <PulsarNode>[text("+")],
            ),
          ],
        ),
      ],
    );
  }
}
