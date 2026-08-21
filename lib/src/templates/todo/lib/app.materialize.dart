import 'package:pulsar_web/pulsar.dart';
import 'dart:convert';

// Domain object for todo logic
class TodoList {
  List<Todo> items = [];

  void loadTodos() {
    final String? stored = window.localStorage.getItem("todos");
    if (stored == null) return;

    final decoded = jsonDecode(stored) as List;
    items = decoded
        .map((todo) => Todo.fromJson(todo as Map<String, dynamic>))
        .toList();
  }

  void saveTodos() {
    final json = jsonEncode(items);
    window.localStorage.setItem("todos", json);
  }

  void add(String text) {
    items.add(
      Todo(id: DateTime.now().toString(), text: text, completed: false),
    );
  }

  void toggle(String id) {
    final todo = items.firstWhere((t) => t.id == id);
    todo.completed = !todo.completed;
  }

  void remove(String id) {
    items.removeWhere((t) => t.id == id);
  }

  List<Todo> get active => items.where((t) => !t.completed).toList();
  List<Todo> get completed => items.where((t) => t.completed).toList();
}

// Main app component
final class App extends Component {
  @override
  List<Stylesheet> get styles => [css("styles/app.css")];
  final TodoList todos = TodoList();
  String inputValue = '';
  Filter currentFilter = Filter.all;

  List<Todo> get filteredTodos => switch (currentFilter) {
    Filter.all => todos.items,
    Filter.active => todos.active,
    Filter.completed => todos.completed,
  };

  List<TodoItem> get todoElements => filteredTodos
      .map(
        (todo) => TodoItem(
          todo: todo,
          onToggle: () => handleToggle(todo.id),
          onRemove: () => handleRemove(todo.id),
        ),
      )
      .toList();

  App() {
    todos.loadTodos();
  }

  void handleAdd(Event e) {
    if (inputValue.trim().isEmpty) return;

    morph(() {
      todos.add(inputValue);
      todos.saveTodos();
      inputValue = '';
    });
  }

  void handleInput(Event e) {
    final target = e.target as HTMLInputElement;
    inputValue = target.value;
  }

  void handleEnter(Event e) {
    final keyEvent = e as KeyboardEvent;
    if (keyEvent.key == "Enter") {
      handleAdd(e);
    }
  }

  void handleToggle(String id) {
    morph(() {
      todos.toggle(id);
      todos.saveTodos();
    });
  }

  void handleRemove(String id) {
    morph(() {
      todos.remove(id);
      todos.saveTodos();
    });
  }

  void setFilter(Filter filter) {
    morph(() => currentFilter = filter);
  }

  @override
  Morphic render() => Div().classes("container")([
    Div().classes("row")([
      Div().classes("col s12 m8 offset-m2 l6 offset-l3")([
        Div().classes("card todo-card")([
          // Header
          Div().classes("card-content blue darken-3 white-text center-align")([
            Span().classes("card-title bold")(['Todo List']),
          ]),

          // Input Section
          Div().classes("card-content rowVal padding-bottom-0")([
            Div().classes("row margin-bottom-0")([
              Div().classes("input-field col s9 m10")([
                Input()
                    .type(InputType.text)
                    .value(inputValue)
                    .onInput(handleInput)
                    .placeholder('What needs to be done?')
                    .onKeyDown(handleEnter)(),
              ]),
              Div().classes("col s3 m2 input-field")([
                Button()
                    .classes(
                      "btn waves-effect waves-light blue darken-2 width-100",
                    )
                    .onClick(handleAdd)([
                  Span()(['+']),
                ]),
              ]),
            ]),
          ]),

          // Filters
          Div().classes("card-action center-align filter-container")([
            Button()
                .onClick((_) => setFilter(Filter.all))
                .classes(
                  "btn-flat waves-effect ${currentFilter == Filter.all ? 'blue white-text' : 'grey-text text-darken-1'}",
                )(['All']),
            Button()
                .onClick((_) => setFilter(Filter.active))
                .classes(
                  "btn-flat waves-effect ${currentFilter == Filter.active ? 'blue white-text' : 'grey-text text-darken-1'}",
                )(['Active']),
            Button()
                .onClick((_) => setFilter(Filter.completed))
                .classes(
                  "btn-flat waves-effect ${currentFilter == Filter.completed ? 'blue white-text' : 'grey-text text-darken-1'}",
                )(['Completed']),
          ]),

          // Todo List
          Ul().classes("collection todo-collection")([todoElements]),

          // Footer Stats
          Div().classes(
            "card-action center-align grey lighten-4 grey-text text-darken-1",
          )([
            P()(['${todos.active.length} items left']),
          ]),
        ]),
      ]),
    ]),
  ]);
}

// Child component
final class TodoItem extends Component {
  final Todo todo;
  final void Function() onToggle;
  final void Function() onRemove;

  TodoItem({
    required this.todo,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Morphic render() {
    return Li().classes(
      "collection-item todo-item ${todo.completed ? 'completed-item' : ''}",
    )([
      Label()([
        Input()
            .type(InputType.checkbox)
            .checked(todo.completed)
            .onChange((_) => onToggle())(),
        Span()([todo.text]),
      ]),
      Button()
          .classes(
            "btn-floating btn-small waves-effect waves-light red secondary-content",
          )
          .onClick((_) => onRemove())([
        Span()(['X']),
      ]),
    ]);
  }
}

enum Filter { all, active, completed }

class Todo {
  final String id;
  final String text;
  bool completed;

  Todo({required this.id, required this.text, required this.completed});

  Map<String, dynamic> toJson() {
    return {"id": id, "text": text, "completed": completed};
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json["id"],
      text: json["text"],
      completed: json["completed"],
    );
  }
}
