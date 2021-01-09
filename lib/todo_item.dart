library checklist.todo_item;

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Globals
Uuid UUID = Uuid();

class todoItem {
  todoItem({
    id,
    timeStamp,
    this.isChecked = false,
    this.isPinned = false,
    @required this.color,
    @required this.title,
  }) 
    : id = id ?? UUID.v4(),
      timeStamp = timeStamp ?? DateTime.now().millisecondsSinceEpoch.toString();

  final String id;
  final String timeStamp;
  bool isChecked;
  bool isPinned;

  String title;
  MaterialColor color;
}