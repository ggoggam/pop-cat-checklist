import 'colors.dart';
import 'widgets.dart';
import 'todo_item.dart';

import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:refreshable_reorderable_list/refreshable_reorderable_list.dart';


void main() {
  runApp(TodoListApp());
}
                                                                       
class TodoListApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TO-DO CHECKLIST',
        theme: ThemeData(
          primarySwatch: colorMap[0xFF00022E],
          fontFamily: 'NanumSquare'
        ),
        home: HomeScreen(),
      );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  TextEditingController textController = new TextEditingController();
  List<todoItem> todoList = [];

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList = prefs.getStringList('my_list') ?? [];
    setState(() {
      todoList = stringList.map((item) => _stringTodo(item)).toList();
    });
  }

  _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList = todoList.map((item) => _todoString(item)).toList();
    setState(() {
      prefs.setStringList('my_list', stringList);
    });
  }

  // Converts a string item to a todoItem class instance
  todoItem _stringTodo(String item) {
    var mapper = jsonDecode(item);
    return todoItem(
      id: mapper['id'],
      timeStamp: mapper['time_stamp'],
      isChecked: mapper['is_checked'],
      isPinned: mapper['is_pinned'],
      title: mapper['title'],
      color: colorMap[int.parse(mapper['color_hex'], radix:16)]
    );
  }

  // Converta a todoItem class instance to a string.
  String _todoString(todoItem item) {
    var mapper = {
      'id': item.id,
      'time_stamp': item.timeStamp,
      'is_checked': item.isChecked,
      'is_pinned' : item.isPinned,
      'title'     : item.title,
      'color_hex' : item.color.value.toRadixString(16)
    };
    return jsonEncode(mapper);
  }

  // Add checklist item
  void _addTodoItem(String title, MaterialColor pickedColor) {
    setState(() {
      todoList.add(todoItem(title: title, color: pickedColor));
      _saveTodoList();
    });
    Fluttertoast.showToast(
      msg: 'Item added.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM
    );
  }

  // Edit checklist item
  void _editTodoItem(todoItem item, String title, MaterialColor pickedColor) {
    todoItem _found = todoList.firstWhere((element) => element.id == item.id);
    setState(() {
      _found.title = title;
      _found.color = pickedColor;
      _saveTodoList();
    });
    Fluttertoast.showToast(
      msg: 'Item edited.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM
    );
  }

  // Remove a checklist item
  void _removeTodoItem(todoItem item) {
    setState(() {
      todoList.removeWhere((element) => element.id == item.id);
      _saveTodoList();
    });
    Fluttertoast.showToast(
      msg: 'Item removed.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM
    );
  }

  // HELPER: Comparison between booleans
  int compareBool(bool a, bool b) {
    if (a != b) {
      if (a != false) return 1;
      else return -1;
    }
    else return 0;
  }

  // Sort checklist
  void _sortTodoList() {
    // First order by check, then pins, by creation time (most recent first)
    setState(() {
      todoList.sort(
        (a,b) {
          var comparePinned = compareBool(a.isPinned, b.isPinned) * -1;
          if (comparePinned != 0) return comparePinned;
          var compareChecked = compareBool(a.isChecked, b.isChecked);
          if (compareChecked != 0) return compareChecked;
          return a.timeStamp.compareTo(b.timeStamp) * -1;
        }
      );
      _saveTodoList();
    });
  }

  // Reorder checklist (for use in ReorderableListView)
  void _reorderTodoList(int oldindex, int newindex){
    setState(() {
      if(newindex > oldindex){
        newindex -= 1;
      }
      final item = todoList.removeAt(oldindex);
      todoList.insert(newindex, item);
      _saveTodoList();
    });
  }

  // Build checklist with ReorderableListView.
  // Sorting can be done via refresh.
  Widget _buildTodoList() {
    return new RefreshIndicator(
      onRefresh: () async { setState(() { _sortTodoList(); }); },
      child: RefreshableReorderableListView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        children: <Widget> [
          for(final item in todoList)
            _buildTodoItem(item)
        ],
        onReorder: _reorderTodoList
      )
    );
  }

  // Build each checklist item. 
  // Each item is a card that is dismissble with swipe gesture.
  Widget _buildTodoItem(todoItem item) {
    if (item != null) {
      return new Dismissible(
        key: Key(item.id),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) => _removeTodoItem(item),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                PinnableIconButton(
                  color: item.color, 
                  value: item.isPinned,
                  onChanged: (value) { setState(() { item.isPinned = value; _saveTodoList(); }); }
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: item.title,
                      style: TextStyle(
                        color: colorMap[0xFF1F1F1F],
                        fontFamily: 'NanumSquare'
                      ),
                      // This edits a checklist item.
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _openDialog(item);
                        }
                    )
                  )
                ),
                ImageSoundCheckbox(
                  value: item.isChecked,
                  onChanged: (value) { setState(() { item.isChecked = value; _saveTodoList(); }); },
                ),
              ],
            ),
          ),
        )
      );
    }
    else { return null; }    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('TO-DO LIST'),
      ),
      body: _buildTodoList(),
      // This adds a new checklist item.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openDialog(null),
        elevation: 2.0,
        tooltip: 'Add a checklist item.',
        child: Icon(Icons.create_sharp),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Opens AlertDialog for Adding / Editing a checklist item.
  _openDialog(todoItem item) async {
    // Initialize dialogue
    textController.text = item != null ? item.title : '';
    MaterialColor pickedColor = item != null ? item.color : colorMap[0xFFAA0000];
    // Show Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) { 
        return ButtonBarTheme(
          data: ButtonBarThemeData(alignment: MainAxisAlignment.end),
          child: AlertDialog(
            contentPadding: const EdgeInsets.all(6.0),
            content: Column(
              children: <Widget> [
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.bookmark),
                    labelText: 'TO-DO',
                    hintText: 'Enter a task'
                  ),
                ),
                Container(
                  width: 300,
                  height: 150,
                  child: MaterialColorPicker(
                    onMainColorChange: (newColor) => pickedColor = newColor,
                    selectedColor: pickedColor,
                    allowShades: false,
                    colors: colorPickerList,
                    circleSize: 40.0,
                    elevation: 0.5,
                    spacing: 15.0
                  )
                )
              ],
              mainAxisSize: MainAxisSize.min,
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FlatButton(
                    child: Text('CANCEL'),
                    onPressed: () { Navigator.of(context).pop(); }
                  ),
                  FlatButton(
                    child: Text('SUBMIT'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      item != null ? _editTodoItem(item, textController.text, pickedColor) : _addTodoItem(textController.text, pickedColor); 
                    }
                  )
                ]
              )
            ]
          )
        );
      }
    );
  }
}

