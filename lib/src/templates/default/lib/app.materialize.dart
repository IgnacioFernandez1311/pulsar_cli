import 'package:pulsar_web/pulsar.dart';

class App extends Component {
  int count = 0;

  void increment(Event event) => setState(() => count++);
  void decrement(Event event) => setState(() => count--);

  @override
  PulsarNode render() {
    return div(
      classes: "container",
      children: [
        img(
          src: "assets/Logo.png",
          width: 140,
          height: 140,
          classes: "responsive-img",
        ),

        h4(classes: "grey-text text-lighten-3", children: [text("Pulsar Web")]),

        p(
          classes: "grey-text text-lighten-1",
          children: [
            text(
              "Pulsar is a declarative web framework focused on clarity, explicit state and predictable rendering. ",
            ),
            a(
              href: "https://pulsar-web.netlify.app/docs",
              target: "_blank",
              classes: "indigo-text text-lighten-2",
              children: [text("Read the documentation.")],
            ),
          ],
        ),

        h3(classes: "white-text", children: [text("$count")]),

        div(
          classes: "row",
          children: [
            div(
              classes: "col s6 center-align",
              children: [
                button(
                  onClick: decrement,
                  classes:
                      "btn-floating transparent z-depth-0 white-text grey darken-3",
                  children: [
                    i(classes: "material-icons", children: [text("remove")]),
                  ],
                ),
              ],
            ),
            div(
              classes: "col s6 center-align",
              children: [
                button(
                  onClick: increment,
                  classes:
                      "btn-floating transparent z-depth-0 white-text grey darken-3",
                  children: [
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
