import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todo/shared/cubit/cubit.dart';

Widget defaultFormField({
  required TextEditingController textEditingController,
  required IconData prefix,
  required TextInputType type,
  Function(String)? onChanged,
  Function(String)? onSubmitted,
  bool isEnabeld = true,
  Function()? onTap,
  required String? Function(String?)? validation,
  required String lable,
  bool isPassword = false,
  IconData? sufixs,
  Function()? sufixFunction,
  double circular = 30.0,
}) =>
    TextFormField(
      validator: validation,
      controller: textEditingController,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: lable,
        prefixIcon: Icon(prefix),
        suffixIcon: sufixs != null
            ? IconButton(
                icon: Icon(sufixs),
                onPressed: sufixFunction,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(circular),
        ),
      ),
      obscureText: isPassword,
      onTap: onTap,
      enabled: isEnabeld,
    );

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(
        "${model['id']}",
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFACA5AC),
              radius: 40.0,
              child: Text(
                "${model["time"]}",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${model["title"]}",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${model["data"]}",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20.0,
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateData(
                  status: "done",
                  id: model['id'],
                );
              },
              icon: Icon(
                Icons.check_box_outlined,
                color: Colors.green.shade600,
              ),
            ),
            IconButton(
              onPressed: () {
                AppCubit.get(context).updateData(
                  status: "archive",
                  id: model['id'],
                );
              },
              icon: const Icon(
                Icons.archive_outlined,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        AppCubit.get(context).deleteData(
          id: model['id'],
        );
      },
    );

Widget tasksBuilder({
  required List<Map> tasks,
}) =>
    ConditionalBuilder(
      condition: tasks.length > 0,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) => buildTaskItem(tasks[index], context),
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 35.0,
          ),
          child: Container(
            color: Colors.grey,
            width: double.infinity,
            height: 1.0,
          ),
        ),
        itemCount: tasks.length,
      ),
      fallback: (context) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu,
              size: 100.0,
              color: Colors.grey,
            ),
            Text(
              "No Task Yet, Please Add Some Tasks",
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
