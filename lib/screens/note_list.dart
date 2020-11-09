import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notetaker/models/note.dart';
import 'package:notetaker/utils/database_helper.dart';
import 'package:notetaker/screens/note_detail-histCode.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('FAB clicked');
          navigateToDetail(note: Note('', '', 2), title: 'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    //TODO: Fix later error with subhead.
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcon(this.noteList[position].priority),
              ),
              title: Text(
                this.noteList[position].title,
                style: titleStyle,
              ),
              subtitle: Text(this.noteList[position].date),
              trailing: GestureDetector(
                child: Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
                onTap: () {
                  _delete(context, noteList[position]);
                },
              ),
              onTap: () {
                print('List Tile Tapped');
                navigateToDetail(
                    note: this.noteList[position], title: 'Edit Note');
              },
            ),
          );
        });
  }

  //Return the prortity color;
  Color getPriorityColor(priority) {
    return priority ? Colors.red : Colors.yellow;
  }

  //Return the proirity icon;
  Icon getPriorityIcon(priority) {
    return priority ? Icon(Icons.play_arrow) : Icon(Icons.keyboard_arrow_right);
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    print('Delete result: $result');
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      //updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail({Note note, String title}) async {
    bool result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => NoteDetail(note, title)));

    if (result == true) {
      //updateListView();
    }
  }

  void updateListView() async {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      setState(() {
        this.noteList = noteList;
        this.count = noteList.length;
      });
    });
  }
}
