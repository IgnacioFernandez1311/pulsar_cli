import 'package:pulsar_web/pulsar.dart';

class App extends Component {
  int count = 0;

  void increment(Event event) => setState(() => count++);

  void decrement(Event event) => setState(() => count--);

  @override
  PulsarNode render() {
    return div(
      children: <PulsarNode>[
        h1(classes: "text-4xl", children: [text("Welcome to Pulsar Web")]),
        img(
          classes: "m-auto place-content-center p-4 my-4",
          width: 240,
          height: 240,
          src: "assets/Logo.png",
        ),
        hr(),
        h2(classes: "text-2xl mt-6 mb-2", children: [text("Count is $count")]),
        div(
          classes: "flex justify-center",
          children: <PulsarNode>[
            button(
              classes: "rounded-full p-2 m-4 w-16 h-16 text-4xl bg-gray-300",
              onClick: decrement,
              children: <PulsarNode>[text('-')],
            ),
            button(
              classes: "rounded-full p-2 m-4 w-16 h-16 text-4xl bg-gray-300",
              onClick: increment,
              children: <PulsarNode>[text("+")],
            ),
          ],
        ),
      ],
    );
  }
}
