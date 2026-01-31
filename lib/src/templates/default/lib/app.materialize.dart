import 'package:pulsar_web/pulsar.dart';

class App extends Component {
  int count = 0;

  void increment(Event event) => setState(() => count++);

  void decrement(Event event) => setState(() => count--);

  @override
  PulsarNode render() {
    return div(
      children: <PulsarNode>[
        h2(children: [text("Welcome to Pulsar Web")]),
        img(attrs: {"src": StringAttribute("assets/Logo.png")}),
        hr(),
        h3(children: [text("Count is $count")]),
        div(
          classes: "row",
          children: <PulsarNode>[
            div(
              classes: "col s2 push-s4",
              children: [
                button(
                  classes: "btn-floating indigo darken-4 btn-large",
                  onClick: decrement,
                  children: <PulsarNode>[
                    i(classes: "material-icons", children: [text("remove")]),
                  ],
                ),
              ],
            ),
            div(
              classes: "col s2 push-s4",
              children: [
                button(
                  classes: "btn-floating indigo darken-4 btn-large",
                  onClick: increment,
                  children: <PulsarNode>[
                    i(classes: "material-icons", children: [text("add")]),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
