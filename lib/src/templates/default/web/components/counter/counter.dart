import 'package:pulsar_web/pulsar.dart';

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
        img(
          classes: "logo",
          attrs: {"src": StringAttribute("assets/Logo.png")},
        ),
        hr(),
        h2(children: [text("Count is $count")]),
        div(
          classes: "buttons",
          children: <PulsarNode>[
            button(
              classes: "button-circular",
              onClick: decrement,
              children: <PulsarNode>[text('-')],
            ),
            button(
              classes: "button-circular",
              onClick: increment,
              children: <PulsarNode>[text("+")],
            ),
          ],
        ),
      ],
    );
  }
}
