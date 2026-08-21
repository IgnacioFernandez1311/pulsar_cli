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
    print(json);
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
  final TodoList todos = TodoList();
  String inputValue = '';
  Filter currentFilter = Filter.all;

  // Computed state
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

  // Actions
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
  Morphic render() =>
      Div().classes(
        "min-h-screen bg-slate-900 text-slate-200 flex items-center justify-center p-4 font-sans",
      )([
        Main().classes(
          "w-full max-w-lg bg-slate-800 border border-slate-700 rounded-xl shadow-2xl overflow-hidden animate-fade-in",
        )([
          // Title
          H1().classes(
            "m-0 p-6 text-2xl sm:text-3xl font-bold text-blue-500 text-center border-b border-slate-700 bg-slate-800/80",
          )(['Todo List']),

          // Input Section
          Div().classes(
            "p-6 flex flex-col sm:flex-row gap-2 border-b border-slate-700 bg-slate-800",
          )([
            Input()
                .value(inputValue)
                .onInput(handleInput)
                .placeholder('What needs to be done?')
                .onKeyDown(handleEnter)
                .classes(
                  "flex-1 px-4 py-3 bg-slate-700 text-slate-100 border border-slate-600 rounded-lg text-base focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 placeholder-slate-500 transition-all",
                )(),
            Button()
                .onClick(handleAdd)
                .classes(
                  "px-6 py-3 bg-blue-600 hover:bg-blue-700 active:scale-95 text-white font-medium rounded-lg text-base transition-all whitespace-nowrap shadow-md",
                )(['Add']),
          ]),

          // Filters
          Div().classes(
            "flex flex-col sm:flex-row gap-1 p-4 border-b border-slate-700 bg-slate-800/50",
          )([
            _buildFilterButton('All', Filter.all),
            _buildFilterButton('Active', Filter.active),
            _buildFilterButton('Completed', Filter.completed),
          ]),

          // Todo list
          Ul().classes(
            "list-none p-0 m-0 max-h-96 overflow-y-auto divide-y divide-slate-700",
          )([
            if (filteredTodos.isEmpty)
              Li().classes("p-8 text-center text-slate-500 italic text-sm")([
                'No todos yet. Add one above!',
              ])
            else
              todoElements,
          ]),

          // Stats
          P().classes(
            "m-0 p-4 text-center text-slate-400 text-sm bg-slate-800 border-t border-slate-700",
          )(['${todos.active.length} items left']),
        ]),
      ]);

  Morphic _buildFilterButton(String label, Filter filter) {
    final isActive = currentFilter == filter;
    final activeClasses = "bg-blue-600 text-white border-blue-600";
    final inactiveClasses =
        "bg-slate-700 text-slate-400 border-slate-600 hover:border-blue-500 hover:text-blue-400 hover:bg-blue-500/10";

    return Button()
        .onClick((_) => setFilter(filter))
        .classes(
          "flex-1 py-2 px-4 border rounded-lg text-sm font-medium transition-all ${isActive ? activeClasses : inactiveClasses}",
        )([label]);
  }
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
    final itemClasses =
        "flex items-center gap-4 px-6 py-4 transition-all hover:bg-slate-700/50 ${todo.completed ? 'opacity-50' : ''}";

    final textClasses =
        "flex-1 text-base text-slate-100 break-words text-left ${todo.completed ? 'line-through text-slate-400' : ''}";

    return Li().classes(itemClasses)([
      Input()
          .type(InputType.checkbox)
          .checked(todo.completed)
          .onChange((_) => onToggle())
          .classes(
            "w-5 h-5 cursor-pointer accent-blue-500 shrink-0 rounded border-slate-600",
          )(),
      Span().classes(textClasses)([todo.text]),
      Button()
          .onClick((_) => onRemove())
          .classes(
            "w-8 h-8 flex items-center justify-center text-slate-500 hover:text-white hover:bg-red-500 hover:scale-110 active:scale-95 rounded transition-all shrink-0 font-bold text-xl",
          )(['×']),
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
