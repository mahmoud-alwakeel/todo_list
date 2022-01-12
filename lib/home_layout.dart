import 'dart:math';

import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_list/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_list/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_list/shared/components/components.dart';
import 'package:todo_list/shared/components/constants.dart';
import 'package:todo_list/shared/cubit/cubit.dart';
import 'package:todo_list/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget
{



  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state){
          if(state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state){
            AppCubit cubit = AppCubit.get(context);



          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text('TODO'),
            ),
            body: ConditionalBuilder(
              condition: state is ! AppGetDatabaseLoadingState,
              builder: (context)=> cubit.screens[cubit.currentIndex],
              fallback: (context)=> Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: ()
              {
                if(cubit.isBottomSheetShown){
                  if(formKey.currentState.validate()){
                    cubit.insertToDatabase(title: titleController.text, time: timeController.text, date: dateController.text);
                    // insertToDatabase(
                    //   title: titleController.text,
                    //   date: dateController.text,
                    //   time: timeController.text,
                    // ).then((value)
                    // {
                    //   getDataFromDatabase(database).then((value)
                    //   {
                    //     Navigator.pop(context);
                    //     // setState(() {
                    //     //
                    //     //   isBottomSheetShown = false;
                    //     //   fabIcon = Icons.edit;
                    //     //
                    //     //   tasks = value;
                    //     // });
                    //
                    //
                    //   });
                    //
                    // });

                  }

                }
                else{
                  scaffoldKey.currentState.showBottomSheet((context) =>
                      Container(
                        color: Colors.grey[300],
                        padding: EdgeInsets.all(10.0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  controller: titleController,
                                  type: TextInputType.text,

                                  validate: (String value)
                                  {
                                    if (value.isEmpty){
                                      return 'title must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'task title',
                                  prefix: Icons.title,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                defaultFormField(
                                  controller: timeController,
                                  type: TextInputType.datetime,
                                  onTap: (){
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then((value)
                                    {
                                      timeController.text = value.format(context).toString();
                                      print(value.format(context));
                                    });
                                  },
                                  validate: (String value)
                                  {
                                    if (value.isEmpty){
                                      return 'time must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'task time',
                                  prefix: Icons.timelapse,
                                ),
                                SizedBox(
                                  height: 15,
                                ),defaultFormField(
                                  controller: dateController,
                                  type: TextInputType.datetime,
                                  onTap: (){
                                    showDatePicker(context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2021-11-18'),
                                    ).then((value)
                                    {
                                      print(DateFormat.yMMMd().format(value));
                                      dateController.text = DateFormat.yMMMd().format(value);
                                    });
                                  },
                                  validate: (String value)
                                  {
                                    if (value.isEmpty){
                                      return 'date must not be empty';
                                    }
                                    return null;
                                  },
                                  label: 'task date',
                                  prefix: Icons.date_range,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    elevation: 15.0,
                  ).closed.then((value)
                  {
                    cubit.changeBottomSheetState(
                        isShow: false,
                        icon: Icons.edit
                    );

                    // setState(() {
                    //   fabIcon = Icons.edit;
                    // });
                  });
                  cubit.changeBottomSheetState(
                      isShow: true,
                      icon: Icons.add
                  );

                  // setState(() {
                  //   fabIcon = Icons.add;
                  // });
                }

              },
              child: Icon(
                cubit.fabIcon,
              ),

            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index)
              {
                cubit.changeIndex(index);
                // setState(() {
                //   currentIndex = index;
                // });
              },
              items:
              [
                BottomNavigationBarItem(
                  icon: Icon(
                      Icons.menu
                  ),
                  label: 'tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                      Icons.check_circle
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                      Icons.archive_outlined
                  ),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }


}





