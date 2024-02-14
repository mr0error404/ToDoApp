// ignore_for_file: curly_braces_in_flow_control_structures, use_key_in_widget_constructors, must_be_immutable

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../shared/components/componennts.dart';
import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  // List<Map> tasks = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
          listener: (BuildContext context, AppStates state) {
        if (state is AppInsertDatabaseState) {
          Navigator.pop(context);
        }
      }, builder: (BuildContext context, AppStates state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(
              cubit.title[cubit.currentIndex],
            ),
          ),
          body: ConditionalBuilder(
            condition: state is! AppGetDatabaseLoadingState,
            builder: (context) => cubit.screens[cubit.currentIndex],
            fallback: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (cubit.isShowBottomSheet) {
                if (formKey.currentState!.validate()) {
                  cubit.insertToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text);
                }
              } else {
                scaffoldKey.currentState!
                    .showBottomSheet(
                      (context) => Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultFormField(
                                    textEditingController: titleController,
                                    prefix: Icons.title,
                                    type: TextInputType.none,
                                    validation: (value) {
                                      if (value!.isEmpty)
                                        return "title most not be empty";
                                      return null;
                                    },
                                    lable: "Title",
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultFormField(
                                    textEditingController: timeController,
                                    prefix: Icons.watch_later_outlined,
                                    type: TextInputType.datetime,
                                    validation: (value) {
                                      if (value!.isEmpty)
                                        return "Time most npt be empty";
                                      return null;
                                    },
                                    lable: "Time Tasks",
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then(
                                        (value) {
                                          timeController.text =
                                              value!.format(context).toString();
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(
                                    height: 15.0,
                                  ),
                                  defaultFormField(
                                    textEditingController: dateController,
                                    prefix: Icons.calendar_month,
                                    type: TextInputType.datetime,
                                    validation: (value) {
                                      if (value!.isEmpty)
                                        return "Date most npt be empty";
                                      return null;
                                    },
                                    lable: "Tasks Date",
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse("2024-05-22"),
                                      ).then((value) {
                                        print(
                                            DateFormat.yMMMd().format(value!));
                                        dateController.text =
                                            DateFormat.yMMMd().format(value);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      elevation: 20.0,
                    )
                    .closed
                    .then((value) {
                  cubit.changeBottomSheetState(
                    isShow: false,
                    icon: Icons.edit,
                  ); // Navigator.pop(context);
                });
                cubit.changeBottomSheetState(
                  isShow: true,
                  icon: Icons.add,
                );
              }
            },
            child: Icon(
              cubit.fabIcon,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: AppCubit.get(context).currentIndex,
            onTap: (index) {
              AppCubit.get(context).changeIndex(index);
              print(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.menu,
                ),
                label: "Tasks",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.check_circle_outline,
                ),
                label: "Done",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.archive_outlined,
                ),
                label: "Archive",
              ),
            ],
          ),
        );
      }),
    );
  }
}
