import 'package:pulsar_web/pulsar.dart';

class App extends Component {
  int count = 0;

  void increment(Event event) => setState(() => count++);
  void decrement(Event event) => setState(() => count--);

  @override
  PulsarNode render() {
    return div(
      classes: "flex flex-col items-center gap-4 text-center",
      children: [
        img(
          src: "assets/Logo.png",
          width: 140,
          height: 140,
          classes: "mt-4 opacity-90",
        ),

        h1(classes: "text-3xl font-medium m-0", children: [text("Pulsar Web")]),

        p(
          classes: "max-w-xs text-sm text-gray-400 m-0",
          children: [
            text(
              "Pulsar is a declarative web framework focused on clarity, explicit state and predictable rendering. ",
            ),
            a(
              href: "https://pulsar-web.netlify.app/docs",
              target: "_blank",
              classes:
                  "text-indigo-500 font-medium transition hover:text-indigo-400",
              children: [text("Read the documentation.")],
            ),
          ],
        ),

        div(classes: "my-2 text-5xl font-mono", children: [text("$count")]),

        div(
          classes: "flex gap-4",
          children: [
            button(
              onClick: decrement,
              classes:
                  "w-10 h-10 rounded-full border border-gray-300 text-gray-200 text-xl transition hover:bg-gray-800",
              children: [text("−")],
            ),
            button(
              onClick: increment,
              classes:
                  "w-10 h-10 rounded-full border border-gray-300 text-gray-200 text-xl transition hover:bg-gray-800",
              children: [text("+")],
            ),
          ],
        ),
      ],
    );
  }
}
