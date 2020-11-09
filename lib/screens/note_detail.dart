import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notetaker/models/note.dart';
import 'package:notetaker/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String title;
  final Note note;

  NoteDetail({this.note, this.title = 'Edit Note'});

  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.title);
}

class _NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['High', 'Low'];

  DatabaseHelper databaseHelper = DatabaseHelper();

  String title;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  _NoteDetailState(this.note, this.title);

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  //Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //Convert int prioirity to String priority and display it to user in Drop Down

  String getPriorityAsString(int value) {
//my code
    // return (value == 1) ? _priorities[0] : _priorities[1];

//his code
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }

  //Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  //Update the descriptiom of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  //Save data to the database
  void _save() async {
    //his code
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      result = await databaseHelper.updateNote(note);
    } else {
      // Case 2: Insert Operation
      result = await databaseHelper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
//my code
      // note.date = DateFormat.yMMMd().format(DateTime.now());
      // int result;
      // print(note.id);
      // print('hello');
      // if (note.id != null) {
      //   //Update Op
      //   result = await databaseHelper.updateNote(note);
      // } else {
      //   result = await databaseHelper.insertNote(note);
      // }

      // print('result is: $result');
      // if (result != 0) {
      //   //Success
      //   _showAlertDialog('Status', 'Note Saved Successfully');
      //   moveToLastScreen();
      // } else {
      //   _showAlertDialog('Status', 'Problem Saving Note');
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = note.title;
    descriptionController.text = note.description;

    TextStyle textStyle = Theme.of(context).textTheme.headline6;
    return WillPopScope(
      onWillPop: () {
        moveToLastScreen();
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToLastScreen();
              }),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 15, left: 10, right: 10),
          child: ListView(
            children: <Widget>[
              //First Element
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriorityAsString(note.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint('User selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  },
                ),
              ),
              //Second Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Title Text Field');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              //Third Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: descriptionController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Description Text Field');
                    updateDescription();
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
              // Fourth Element
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Save',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint('Save button clicked');
                            _save();
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    //Delete button
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Delete',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint('Delete button clicked');
                            _delete();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _delete() async {
    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
    //my code
    //Case 1: If user is trying to delete the New Note
    // if (note.id == null) {
    //   _showAlertDialog('Status', 'Note Cancelled');
    // } else {
    //   //Case 2: User is trying to delete the old note that already has a valid ID.
    //   _showAlertDialog('Status', 'Note Saved Succesfully');
    //   int result = await databaseHelper.deleteNote(note.id);
    //   if (result != 0) {
    //     //Success
    //     _showAlertDialog('Status', 'Note Deleted Successfully');
    //     moveToLastScreen();
    //   } else {
    //     _showAlertDialog('Status', 'Problem Deleting Note');
    //     return;
    //   }
  }
}
