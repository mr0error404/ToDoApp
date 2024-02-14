import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/shared/cubit/states.dart';

import '../../modules/archive_tasks/archive_tasks.dart';
import '../../modules/done_tasks/done_tasks.dart';
import '../../modules/new_tasks/new_tasks.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  Database? database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archiveTasks = [];

  bool isShowBottomSheet = false;
  IconData fabIcon = Icons.edit;

  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchiveTasksScreen()
  ];

  List<String> title = [
    "New Tasks",
    "Done Tasks",
    "Archive Tasks",
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase(
      "tod.db",
      version: 4,
      onCreate: (database, version) async {
        database
            .execute(
                "CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, data TEXT, time TEXT, status TEXT)")
            .then((value) {})
            .catchError((error) {
          print("ERRROR --------> ${error.toString()}");
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
    ;
  }

  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction(
      (txn) => txn
          .rawInsert(
              'INSERT INTO tasks (title, data, time, status) VALUES("$title","$date","$time","new")')
          .then((value) {
        print("$value Inserted successfuly");
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);
      }).catchError(
        (error) {
          print("error insert ---> ${error.toString()}");
        },
      ),
    );
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archiveTasks = [];

    emit(AppGetDatabaseLoadingState());
    database!.rawQuery("SELECT * FROM tasks").then((value) {
      value.forEach((element) {
        if (element["status"] == "new") {
          newTasks.add(element);
        } else if (element['status'] == 'archive') {
          archiveTasks.add(element);
        } else {
          doneTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isShowBottomSheet = isShow;

    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

  void updateData({
    required String status,
    required int id,
  }) async {
    database!.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      [
        '$status',
        id,
      ],
    ).then(
      (value) {
        getDataFromDatabase(database);
        emit(AppUpdateDatabaseState());
      },
    );
  }

  void deleteData({
    required int id,
  }) async {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then(
      (value) {
        getDataFromDatabase(database);
        emit(AppDeleteDatabaseState());
      },
    );
  }
}
