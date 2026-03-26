import 'package:pulsar_web/pulsar.dart';

final class App extends Component {
  @override
  List<Stylesheet> get styles => [css("styles/app.css")];

  int count = 0;

  void increment(Event event) => morph(() => count++);
  void decrement(Event event) => morph(() => count--);

  @override
  Morphic render() {
    return Div().classes("app")([
      Img().src("assets/Logo.png").classes("logo")(),

      H1().classes("title")(["Pulsar Web"]),

      P().classes("description")([
        "Pulsar is a declarative web framework focused on clarity, explicit state and predictable rendering. ",
        A()
            .href("https://pulsar-web.netlify.app/docs")
            .target(Target.blank)
            .classes("doc-link")(["Read the documentation."]),
      ]),

      Div().classes("counter")(["$count"]),

      Div().classes("buttons")([
        Button().classes("button-circular").onClick(decrement)(["−"]),
        Button().classes("button-circular").onClick(increment)(["+"]),
      ]),
    ]);
  }
}
