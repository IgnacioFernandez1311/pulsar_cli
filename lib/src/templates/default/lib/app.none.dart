import 'package:pulsar_web/pulsar.dart';

class App extends Component {
  @override
  List<Stylesheet> get styles => [css("styles/app.css")];

  int count = 0;

  void increment(Event event) => setState(() => count++);
  void decrement(Event event) => setState(() => count--);

  @override
  PulsarNode render() {
    return div(
      classes: "app",
      children: [
        img(src: "assets/Logo.png", classes: "logo"),

        h1(classes: "title", children: [text("Pulsar Web")]),

        p(
          classes: "description",
          children: [
            text(
              "Pulsar is a declarative web framework focused on clarity, explicit state and predictable rendering. ",
            ),
            a(
              classes: "doc-link",
              href: "https://pulsar-web.netlify.app/docs",
              target: "_blank",
              children: [text("Read the documentation.")],
            ),
          ],
        ),

        div(classes: "counter", children: [text("$count")]),

        div(
          classes: "buttons",
          children: [
            button(
              classes: "button-circular",
              onClick: decrement,
              children: [text("−")],
            ),
            button(
              classes: "button-circular",
              onClick: increment,
              children: [text("+")],
            ),
          ],
        ),
      ],
    );
  }
}
