import 'package:pulsar_web/pulsar.dart';

final class App extends Component {
  int count = 0;

  void increment(Event event) => morph(() => count++);
  void decrement(Event event) => morph(() => count--);

  @override
  Morphic render() {
    return Div().classes("flex flex-col items-center gap-4 text-center")([
      Img()
          .src("assets/Logo.png")
          .width(140)
          .height(140)
          .classes("mt-4 opacity-90")(),

      H1().classes("text-3xl font-medium m-0")(["Pulsar Web"]),

      P().classes("max-w-xs text-sm text-gray-400 m-0")([
        "Pulsar is a declarative web framework focused on clarity, explicit state and predictable rendering. ",
        A()
            .href("https://pulsar-web.netlify.app/docs")
            .target(Target.blank)
            .classes(
              "text-indigo-500 font-medium transition hover:text-indigo-400",
            )(["Read the documentation."]),
      ]),

      Div().classes("my-2 text-5xl font-mono")(["$count"]),

      Div().classes("flex gap-4")([
        Button()
            .onClick(decrement)
            .classes(
              "w-10 h-10 rounded-full border border-gray-300 text-gray-200 text-xl transition hover:bg-gray-800",
            )(["−"]),
        Button()
            .onClick(increment)
            .classes(
              "w-10 h-10 rounded-full border border-gray-300 text-gray-200 text-xl transition hover:bg-gray-800",
            )(["+"]),
      ]),
    ]);
  }
}
