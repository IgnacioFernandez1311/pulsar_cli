import 'package:pulsar_web/pulsar.dart';

final class App extends Component {
  int count = 0;

  void increment(Event event) => morph(() => count++);
  void decrement(Event event) => morph(() => count--);

  @override
  Morphic render() {
    return Div().classes("container")([
      Img()
          .src("assets/Logo.png")
          .width(140)
          .height(140)
          .classes("responsive-img")(),

      H4().classes("grey-text text-lighten-3")(["Pulsar Web"]),

      P().classes("grey-text text-lighten-1")([
        "Pulsar is a declarative web framework focused on clarity, explicit state and predictable rendering. ",
        A()
            .href("https://pulsar-web.netlify.app/docs")
            .target(Target.blank)
            .classes("indigo-text text-lighten-2")(["Read the documentation."]),
      ]),

      H3().classes("white-text")(["$count"]),

      Div().classes("row")([
        Div().classes("col s6 center-align")([
          Button()
              .onClick(decrement)
              .classes(
                "btn-floating transparent z-depth-0 white-text grey darken-3",
              )(["-"]),
        ]),
      ]),
      Div().classes("col s6 center-align")([
        Button()
            .onClick(increment)
            .classes(
              "btn-floating transparent z-depth-0 white-text grey darken-3",
            )(["+"]),
      ]),
    ]);
  }
}
