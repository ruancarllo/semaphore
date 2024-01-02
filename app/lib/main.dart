import 'dart:ui';
import 'dart:io';
import 'dart:convert';

import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    String license = await rootBundle.loadString('assets/fonts/ArchivoNarrow/OFL.txt');
    yield LicenseEntryWithLineBreaks(['ArchivoNarrow'], license);
  });

  SemaphoreApp semaphoreApp = const SemaphoreApp();
  runApp(semaphoreApp);
}

class SemaphoreApp extends StatelessWidget {
  const SemaphoreApp({
    super.key,
  });

  @override Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => TasksProvider())
      ],
      child: MaterialApp(
        title: 'Semaphore',
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          );
        },
        theme: ThemeData(
          colorScheme: ColorScheme.dark(
            primary: Colors.blue,
            secondary: Colors.blue.shade800,
            tertiary: Colors.grey.shade900,
            onTertiary: const Color(0xFF333333),
            tertiaryContainer: Colors.black26,
          ),
          fontFamily: 'ArchivoNarrow',
        ),
        routes: {
          '/tasks': (BuildContext context) => const TasksScreen(),
        },
        initialRoute: '/tasks',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  const TasksScreen({
    super.key,
  });

  @override Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TasksScreenAppBar(),
      body: TasksScreenBody(),
      endDrawer: TasksScreenEndDrawer(),
    );
  }
}

class TasksScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TasksScreenAppBar({
    super.key,
  });

  @override Widget build(BuildContext context) {
    return AppBar(
      title: const Padding(
        padding: EdgeInsets.only(
          left: 10,
        ),
        child: Text(
          'Semaphore',
          style: TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      actions: [
        Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.menu,
                ),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            );
          }
        ),
      ],
      centerTitle: false,
      scrolledUnderElevation: 0,
    );
  }

  @override Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight);
  }
}

class TasksScreenBody extends StatelessWidget {
  const TasksScreenBody({
    super.key,
  });

  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
            ),
          ),
          child: const Column(
            children: [
              TaskStatusMenu(),
              TaskCardsList(),
              TaskCreatorForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class TasksScreenEndDrawer extends StatelessWidget {
  const TasksScreenEndDrawer({
    super.key,
  });

  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Scaffold.of(context).closeEndDrawer();
      },
      child: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.yearsListHeader,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: FutureBuilder(
                future: TasksRegisterer.queryYears(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    List yearsQuery = snapshot.data;
              
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          for (int analyzingYear in yearsQuery) ListTile(
                            title: Text(
                              analyzingYear.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            onTap: () {
                              Provider.of<TasksProvider>(context, listen: false).displayingTasksYear = analyzingYear;
                    
                              Scaffold.of(context).closeEndDrawer();
                            },
                          ),
                        ],
                      ),
                    );
                  }
              
                  else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskStatusMenu extends StatelessWidget {
  const TaskStatusMenu({
    super.key,
  });

  @override Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 20,
          bottom: 20,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TaskStatusButton(
                  status: 'generic',
                  name: AppLocalizations.of(context)!.genericTaskStatusName,
                ),
                const SizedBox(
                  width: 10,
                ),
                TaskStatusButton(
                  status: 'entered',
                  name: AppLocalizations.of(context)!.enteredTaskStatusName,
                ),
                const SizedBox(
                  width: 10,
                ),
                TaskStatusButton(
                  status: 'progress',
                  name: AppLocalizations.of(context)!.progressTaskStatusName,
                ),
                const SizedBox(
                  width: 10,
                ),
                TaskStatusButton(
                  status: 'delivered',
                  name: AppLocalizations.of(context)!.deliveredTaskStatusName,
                ),
                const SizedBox(
                  width: 10,
                ),
                TaskStatusButton(
                  status: 'received',
                  name: AppLocalizations.of(context)!.receivedTaskStatusName,
                ),
                const SizedBox(
                  width: 10,
                ),
                TaskStatusButton(
                  status: 'unpaid',
                  name: AppLocalizations.of(context)!.unpaidTaskStatusName,
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskCardsList extends StatelessWidget {
  const TaskCardsList({
    super.key,
  });

  @override Widget build(BuildContext context) {
    Provider.of<TasksProvider>(context).displayingTaskStatus;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 20,
        ),
        child: FutureBuilder(
          future: TasksRegisterer.queryTasks(
            year: Provider.of<TasksProvider>(context).displayingTasksYear,
          ),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            List<Widget> taskCardsAndSeparators = [];

            if (snapshot.hasData) {
              List tasksQuery = snapshot.data;

              String displayingTaskStatus = Provider.of<TasksProvider>(context, listen: false).displayingTaskStatus;
      
              for (Map analyzingTask in tasksQuery) {
                if (displayingTaskStatus == 'generic' || displayingTaskStatus == analyzingTask['status']) {
                  taskCardsAndSeparators.add(
                    TaskInformationCard(
                      token: analyzingTask['token'],
                      message: analyzingTask['message'],
                      status: analyzingTask['status'],
                      price: analyzingTask['price'],
                      deadline: analyzingTask['deadline'],
                      creation: analyzingTask['creation'],
                    ),
                  );

                  taskCardsAndSeparators.add(
                    const SizedBox(
                      height: 2,
                    ),
                  );
                }
              }
            }

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: taskCardsAndSeparators,
              ),
            );
          },
        ),
      ),
    );
  }
}

class TaskCreatorForm extends StatefulWidget {
  const TaskCreatorForm({
    super.key,
  });

  @override State<TaskCreatorForm> createState() {
    return TaskCreatorFormState();
  }
}

class TaskCreatorFormState extends State<TaskCreatorForm> {
  TextEditingController taskFormMessageController = TextEditingController();
  TextEditingController taskFormDeadlineController = TextEditingController();
  TextEditingController taskFormPriceController = TextEditingController();
    
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Form(
        child: Row(
          children: [ 
            Flexible(
              flex: 2,
              child: TaskParameterField(
                readOnly: false,
                parameterName: AppLocalizations.of(context)!.messageInputPlaceholder,
                keyboardType: TextInputType.text,
                fieldController: taskFormMessageController,
                changeCallback: (String value) {
                  Provider.of<TasksProvider>(context, listen: false).creatingTaskMessage = value != '' ? value : null;
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              flex: 1,
              child: TaskParameterField(
                tapCallback: () async {
                  showCustomDatePicker(context).then((DateTime? pickedDate) {
                    if (pickedDate != null) {
                      taskFormDeadlineController.text = formatDeadlineTime(pickedDate);
                      Provider.of<TasksProvider>(context, listen: false).creatingTaskDeadline = pickedDate.millisecondsSinceEpoch;
                    }
                  });
                },
                readOnly: true,
                parameterName: AppLocalizations.of(context)!.dateInputPlaceholder,
                keyboardType: TextInputType.number,
                fieldController: taskFormDeadlineController,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              flex: 1,
              child: TaskParameterField(
                readOnly: false,
                parameterName: AppLocalizations.of(context)!.priceInputPlaceholder,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                fieldController: taskFormPriceController,
                changeCallback: (String value) {
                  Provider.of<TasksProvider>(context, listen: false).creatingTaskPrice = value != '' ? double.parse(value) : null;
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            RawMaterialButton(
              onPressed: () {
                if (Provider.of<TasksProvider>(context, listen: false).isCreatingTask == false) {
                  Provider.of<TasksProvider>(context, listen: false).isCreatingTask = true;

                  String? creatingTaskMessage = Provider.of<TasksProvider>(context, listen: false).creatingTaskMessage;
                  int? creatingTaskDeadline = Provider.of<TasksProvider>(context, listen: false).creatingTaskDeadline;
                  double? creatingTaskPrice = Provider.of<TasksProvider>(context, listen: false).creatingTaskPrice;

                  if (creatingTaskMessage != null && creatingTaskPrice != null) {
                    TasksRegisterer.createTask(
                      message: creatingTaskMessage,
                      status: 'entered',  
                      price: creatingTaskPrice,
                      deadline: creatingTaskDeadline,
                    ).then((void result) {
                      FocusNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }

                      taskFormMessageController.text = '';
                      taskFormDeadlineController.text = '';
                      taskFormPriceController.text = '';

                      Provider.of<TasksProvider>(context, listen: false).creatingTaskMessage = null;
                      Provider.of<TasksProvider>(context, listen: false).creatingTaskDeadline = null;
                      Provider.of<TasksProvider>(context, listen: false).creatingTaskPrice = null;

                      Provider.of<TasksProvider>(context, listen: false).isCreatingTask = false;
                    });
                  }

                  else {
                    Provider.of<TasksProvider>(context, listen: false).isCreatingTask = false;
                  }
                }
              
              },
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(10),
              fillColor: Theme.of(context).colorScheme.secondary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              constraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskEditorDialog extends StatefulWidget {
  final int taskToken;
  final String taskMessage;
  final double taskPrice;
  final int? taskDeadline;

  const TaskEditorDialog({
    super.key,
    required this.taskToken,
    required this.taskMessage,
    required this.taskPrice,
    required this.taskDeadline,
  });

  @override State<TaskEditorDialog> createState() {
    return TaskEditorDialogState();
  }
}

class TaskEditorDialogState extends State<TaskEditorDialog> {
  TextEditingController editFormMessageController = TextEditingController();
  TextEditingController editFormDeadlineController = TextEditingController();
  TextEditingController editFormPriceController = TextEditingController();

  @override Widget build(BuildContext context) {
    editFormMessageController.text = widget.taskMessage;

    int? deadlineCopy = widget.taskDeadline;

    DateTime? deadlineTime;

    if (deadlineCopy != null) {
      deadlineTime = DateTime.fromMillisecondsSinceEpoch(deadlineCopy);
    }

    String? formattedDeadline;

    if (deadlineTime != null) {
      formattedDeadline = formatDeadlineTime(deadlineTime);
      editFormDeadlineController.text = formattedDeadline;
    }

    editFormPriceController.text = widget.taskPrice.toString();

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5,
        sigmaY: 5,
      ),
      child: Dialog(
        child: Container(
          width: 200,
          height: 310,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Form(
                  child: Column(
                    children: [
                      TaskParameterField(
                          readOnly: false,
                          parameterName: widget.taskMessage.toString(),
                          keyboardType: TextInputType.text,
                          fieldController: editFormMessageController,
                          changeCallback: (String value) {
                            Provider.of<TasksProvider>(context, listen: false).editingTaskMessage = value != '' ? value : null;
                          },
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: TaskParameterField(
                              tapCallback: () async {
                                showCustomDatePicker(context).then((DateTime? pickedDate) {
                                  if (pickedDate != null) {
                                    editFormDeadlineController.text = formatDeadlineTime(pickedDate);
                                    Provider.of<TasksProvider>(context, listen: false).editingTaskDeadline = pickedDate.millisecondsSinceEpoch;
                                  }
                                });
                              },
                              readOnly: true,
                              parameterName: formattedDeadline ?? AppLocalizations.of(context)!.dateInputPlaceholder,
                              keyboardType: TextInputType.number,
                              fieldController: editFormDeadlineController,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            flex: 1,
                            child: TaskParameterField(
                              readOnly: false,
                              parameterName: widget.taskPrice.toString(),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              fieldController: editFormPriceController,
                              changeCallback: (String value) {
                                Provider.of<TasksProvider>(context, listen: false).editingTaskPrice = value != '' ? double.parse(value) : null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                RegisterActionButton(
                  pressCallback: () {
                    if (Provider.of<TasksProvider>(context, listen: false).isUpdatingTask == false) {
                      Provider.of<TasksProvider>(context, listen: false).isUpdatingTask = true;
  
                      TasksRegisterer.updateTask(
                        token: widget.taskToken,
                        year: Provider.of<TasksProvider>(context, listen: false).displayingTasksYear,
                        message: Provider.of<TasksProvider>(context, listen: false).editingTaskMessage,
                        deadline: Provider.of<TasksProvider>(context, listen: false).editingTaskDeadline,
                        price: Provider.of<TasksProvider>(context, listen: false).editingTaskPrice,
                      ).then((void result) {
                        Navigator.of(context).pop();
                        Provider.of<TasksProvider>(context, listen: false).isUpdatingTask = false;
                      });
                    }
                  },
                  textContent: AppLocalizations.of(context)!.saveButtonActionName,
                ),
                RegisterActionButton(
                  pressCallback: () {
                    Navigator.of(context).pop();
                    
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return TaskRemoverDialog(
                          taskToken: widget.taskToken,
                        );
                      },
                    );
                  },
                  textContent: AppLocalizations.of(context)!.removeButtonActionName,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusChangerButton(
                      taskToken: widget.taskToken,
                      taskStatus: 'entered',
                      iconData: Icons.add,
                      buttonColor: const Color.fromARGB(117, 255, 255, 255),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    StatusChangerButton(
                      taskToken: widget.taskToken,
                      taskStatus: 'progress',
                      iconData: Icons.loop,
                      buttonColor: const Color.fromARGB(117, 33, 149, 243),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    StatusChangerButton(
                      taskToken: widget.taskToken,
                      taskStatus: 'delivered',
                      iconData: Icons.done,
                      buttonColor: const Color.fromARGB(117, 255, 235, 59),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    StatusChangerButton(
                      taskToken: widget.taskToken,
                      taskStatus: 'received',
                      iconData: Icons.paid,
                      buttonColor: const Color.fromARGB(117, 76, 175, 79),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    StatusChangerButton(
                      taskToken: widget.taskToken,
                      taskStatus: 'unpaid',
                      iconData: Icons.report,
                      buttonColor: const Color.fromARGB(117, 244, 67, 54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override void dispose() {
    editFormDeadlineController.text = '';
    editFormPriceController.text = '';

    super.dispose();
  }
}

class TaskRemoverDialog extends StatelessWidget {
  final int taskToken;

  const TaskRemoverDialog({
    super.key,
    required this.taskToken,
  });

  @override Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5,
        sigmaY: 5,
      ),
      child: Dialog(
        child: Container(
          width: 200,
          height: 160,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.taskRemotionConfirmationSentence,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Provider.of<TasksProvider>(context, listen: false).isUpdatingTask = true;

                        TasksRegisterer.removeTask(
                          token: taskToken,
                          year: Provider.of<TasksProvider>(context, listen: false).displayingTasksYear,
                        ).then((void result) {
                          Navigator.of(context).pop();
                          Provider.of<TasksProvider>(context, listen: false).isUpdatingTask = false;
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context)!.confirmationButtonActionName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Provider.of<TasksProvider>(context, listen: false).isUpdatingTask = false;
                      },
                      child: Text(
                        AppLocalizations.of(context)!.negationButtonActionName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskStatusButton extends StatelessWidget {
  final String status;
  final String name;

  const TaskStatusButton({
    super.key,
    required this.status,
    required this.name,
  });

  @override Widget build(BuildContext context) {
    String displayingTaskStatus = Provider.of<TasksProvider>(context).displayingTaskStatus;
    bool isButtonSelected = displayingTaskStatus == status;

    return ElevatedButton(
      onPressed: () {
        Provider.of<TasksProvider>(context, listen: false).displayingTaskStatus = status;
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isButtonSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.background,
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isButtonSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class TaskInformationCard extends StatelessWidget {
  final int token;
  final String message;
  final String status;
  final double price;
  final int? deadline;
  final int creation;
  
  const TaskInformationCard({
    super.key,
    required this.token,
    required this.message,
    required this.status,
    required this.price,
    required this.deadline,
    required this.creation,
  });

  @override Widget build(BuildContext context) {
    int? deadlineCopy = deadline;

    DateTime? deadlineTime;

    if (deadlineCopy != null) {
      deadlineTime = DateTime.fromMillisecondsSinceEpoch(deadlineCopy);
    }

    String? formattedDeadline;

    if (deadlineTime != null) {
      formattedDeadline = formatDeadlineTime(deadlineTime);
    }

    Color textColor = Colors.white;

    if (status == 'entered') textColor = Colors.white;
    if (status == 'progress') textColor = Colors.blue;
    if (status == 'delivered') textColor = Colors.yellow;
    if (status == 'received') textColor = Colors.green;
    if (status == 'unpaid') textColor = Colors.red;

    String currentLocale = Localizations.localeOf(context).toString();

    return GestureDetector(
      onLongPress: () {
        Provider.of<TasksProvider>(context, listen: false).editingTaskMessage = message;
        Provider.of<TasksProvider>(context, listen: false).editingTaskDeadline = deadline;
        Provider.of<TasksProvider>(context, listen: false).editingTaskPrice = price;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return TaskEditorDialog(
              taskToken: token,
              taskMessage: message,
              taskPrice: price,
              taskDeadline: deadline,
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Expanded(
                flex: deadlineTime != null ? 10 : 12,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              if (formattedDeadline != null) Expanded(
                flex: 2,
                child: Text(
                  formattedDeadline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: textColor,
                  ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 4,
                child: Text(
                  NumberFormat.currency(
                    locale: currentLocale,
                    symbol: NumberFormat.simpleCurrency(locale: currentLocale).currencySymbol,
                  ).format(price),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: textColor,
                  ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskParameterField extends StatelessWidget {
  final void Function()? tapCallback;
  final void Function(String value)? changeCallback;
  final bool readOnly;
  final String parameterName;
  final TextInputType keyboardType;
  final TextEditingController fieldController;

  const TaskParameterField({
    super.key,
    this.tapCallback,
    this.changeCallback,
    required this.readOnly,
    required this.parameterName,
    required this.keyboardType,
    required this.fieldController,
  });

  @override Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onTertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        onTap: tapCallback,
        readOnly: readOnly,
        keyboardType: keyboardType,
        controller: fieldController,
        onChanged: (changeCallback),
        decoration: InputDecoration(
          isDense: false,
          hintText: parameterName,
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: 10,
          ),
        ),
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        cursorColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class RegisterActionButton extends StatelessWidget {
  final void Function() pressCallback;
  final String textContent;

  const RegisterActionButton({
    super.key,
    required this.pressCallback,
    required this.textContent,
  });

  @override Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: pressCallback,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: const Size.fromHeight(40),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      child: Text(
        textContent,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class StatusChangerButton extends StatelessWidget {
  final int taskToken;
  final String taskStatus;
  final IconData iconData;
  final Color buttonColor;

  const StatusChangerButton({
    super.key,
    required this.taskToken,
    required this.taskStatus,
    required this.iconData,
    required this.buttonColor,
  });

  @override Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: RawMaterialButton(
        onPressed: () {
          if (Provider.of<TasksProvider>(context, listen: false).isUpdatingTask == false) {
            Provider.of<TasksProvider>(context, listen: false).isUpdatingTask = true;

            TasksRegisterer.updateTask(
              token: taskToken,
              year: Provider.of<TasksProvider>(context, listen: false).displayingTasksYear,
              message: Provider.of<TasksProvider>(context, listen: false).editingTaskMessage,
              deadline: Provider.of<TasksProvider>(context, listen: false).editingTaskDeadline,
              price: Provider.of<TasksProvider>(context, listen: false).editingTaskPrice,
              status: taskStatus.toString(),
            ).then((void result) {
              Navigator.of(context).pop();
              Provider.of<TasksProvider>(context, listen: false).isUpdatingTask = false;
            });
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        fillColor: buttonColor,
        child: Icon(
          iconData,
          size: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

class TasksProvider extends ChangeNotifier {
  String _displayingTaskStatus = 'generic';

  String get displayingTaskStatus {
    return _displayingTaskStatus;
  }

  set displayingTaskStatus(String value) {
    _displayingTaskStatus = value;
    notifyListeners();
  }

  int _displayingTasksYear = DateTime.now().year;

  int get displayingTasksYear {
    return _displayingTasksYear;
  }

  set displayingTasksYear(int value) {
    _displayingTasksYear = value;
    notifyListeners();
  }

  String? _creatingTaskMessage;

  String? get creatingTaskMessage {
    return _creatingTaskMessage;
  }

  set creatingTaskMessage(String? value) {
    _creatingTaskMessage = value;
    notifyListeners();
  }

  int? _creatingTaskDeadline;

  int? get creatingTaskDeadline {
    return _creatingTaskDeadline;
  }

  set creatingTaskDeadline(int? value) {
    _creatingTaskDeadline = value;
    notifyListeners();
  }

  double? _creatingTaskPrice;

  double? get creatingTaskPrice {
    return _creatingTaskPrice;
  }

  set creatingTaskPrice(double? value) {
    _creatingTaskPrice = value;
    notifyListeners();
  }

  String? _editingTaskMessage;

  String? get editingTaskMessage {
    return _editingTaskMessage;
  }

  set editingTaskMessage(String? value) {
    _editingTaskMessage = value;
    notifyListeners();
  }


  int? _editingTaskDeadline;

  int? get editingTaskDeadline {
    return _editingTaskDeadline;
  }

  set editingTaskDeadline(int? value) {
    _editingTaskDeadline = value;
    notifyListeners();
  }

  double? _editingTaskPrice;

  double? get editingTaskPrice {
    return _editingTaskPrice;
  }

  set editingTaskPrice(double? value) {
    _editingTaskPrice = value;
    notifyListeners();
  }
  
  bool _isCreatingTask = false;

  bool get isCreatingTask {
    return _isCreatingTask;
  }

  set isCreatingTask(bool value) {
    _isCreatingTask = value;
    notifyListeners();
  }

  bool _isUpdatingTask = false;

  bool get isUpdatingTask {
    return _isUpdatingTask;
  }

  set isUpdatingTask(bool value) {
    _isUpdatingTask = value;
    notifyListeners();
  }
}

class TasksRegisterer {
  static Future<void> createTask({
    required String message,
    required String status,
    required double price,
    int? deadline,
  }) async {
    DateTime currentTime = DateTime.now();

    DateTime? deadlineTime;

    if (deadline != null) {
      deadlineTime = DateTime.fromMillisecondsSinceEpoch(deadline);
    }

    File tasksDatabaseFile = await TasksRegisterer.getTasksDatabaseFile(deadlineTime != null ? deadlineTime.year : currentTime.year);

    if (!await tasksDatabaseFile.exists()) {
      Map tasksDatabaseObject = {
        'tasksList': [],
        'creationsCount': 0,
      };

      String tasksDatabaseContent = TasksRegisterer.defaultJsonEncoder.convert(tasksDatabaseObject);

      await tasksDatabaseFile.create(recursive: true);
      await tasksDatabaseFile.writeAsString(tasksDatabaseContent);
    }

    String tasksDatabaseContent = await tasksDatabaseFile.readAsString();

    Map tasksDatabaseObject = json.decode(tasksDatabaseContent);

    List tasksList = tasksDatabaseObject['tasksList'];

    Map newTask = {
      'token': tasksDatabaseObject['creationsCount'],
      'message': message.trim(),
      'status': status,
      'price': price,
      'deadline': deadline,
      'creation': currentTime.millisecondsSinceEpoch,
    };    

    tasksList.add(newTask);
    tasksDatabaseObject['creationsCount']++;

    tasksDatabaseContent = TasksRegisterer.defaultJsonEncoder.convert(tasksDatabaseObject);

    await tasksDatabaseFile.writeAsString(tasksDatabaseContent);
  }

  static Future<void> updateTask({
    required int token,
    required int year,
    String? message,
    String? status,
    double? price,
    int? deadline,
  }) async {
    DateTime? deadlineTime;

    if (deadline != null) {
      deadlineTime = DateTime.fromMillisecondsSinceEpoch(deadline);
    }

    File tasksDatabaseFile = await TasksRegisterer.getTasksDatabaseFile(year);

    String tasksDatabaseContent = await tasksDatabaseFile.readAsString();
    Map tasksDatabaseObject = json.decode(tasksDatabaseContent);

    List tasksList = tasksDatabaseObject['tasksList'];

    for (int tasksCount = 0; tasksCount < tasksList.length; tasksCount++) {
      Map taskObject = tasksList[tasksCount];

      if (taskObject['token'] == token) {
        if (deadlineTime != null && deadlineTime.year != year) {
          await createTask(
            message: message ?? taskObject['message'],
            status: status ?? taskObject['status'],
            price: price ?? taskObject['price'],
            deadline: deadline,
          );

          await removeTask(
            token: token,
            year: year,
          );
        }

        else {
          if (message != null) taskObject['message'] = message;
          if (status != null) taskObject['status'] = status;
          if (price != null) taskObject['price'] = price;
          taskObject['deadline'] = deadline;

          tasksDatabaseContent = TasksRegisterer.defaultJsonEncoder.convert(tasksDatabaseObject);

          await tasksDatabaseFile.writeAsString(tasksDatabaseContent);
        }

        break;
      }
    }

    
  }

  static Future<void> removeTask({
    required int token,
    required int year,
  }) async {
    File tasksDatabaseFile = await TasksRegisterer.getTasksDatabaseFile(year);

    String tasksDatabaseContent = await tasksDatabaseFile.readAsString();
    Map tasksDatabaseObject = json.decode(tasksDatabaseContent);

    List tasksList = tasksDatabaseObject['tasksList'];    

    for (int tasksCount = 0; tasksCount < tasksList.length; tasksCount++) {
      Map taskObject = tasksList[tasksCount];

      if (taskObject['token'] == token) {
        tasksList.removeAt(tasksCount);
      }
    }

    tasksDatabaseContent = TasksRegisterer.defaultJsonEncoder.convert(tasksDatabaseObject);

    await tasksDatabaseFile.writeAsString(tasksDatabaseContent);
  }

  static Future<List?> queryTasks({
    required int year,
  }) async {
    File tasksDatabaseFile = await TasksRegisterer.getTasksDatabaseFile(year);

    if (await tasksDatabaseFile.exists()) {
      String tasksDatabaseContent = await tasksDatabaseFile.readAsString();
      Map tasksDatabaseObject = json.decode(tasksDatabaseContent);

      List tasksList = tasksDatabaseObject['tasksList'];

      tasksList.sort((dynamic firstTask, dynamic secondTask) {
        int firstTaskStatusIndex = taskStatusPriority.indexOf(firstTask['status']);
        int secondTaskStatusIndex = taskStatusPriority.indexOf(secondTask['status']);

        int taskStatusComparison = secondTaskStatusIndex.compareTo(firstTaskStatusIndex);

        if (taskStatusComparison == 0) {
          int firstTaskCreation = firstTask['creation'];
          int secondTaskCreation = secondTask['creation'];

          return firstTaskCreation.compareTo(secondTaskCreation);
        }

        else {
          return taskStatusComparison;
        }
      });

      return tasksList;
    }

    else {
      return null;
    }
  }

  static Future<List> queryYears() async {
    Directory applicationDocumentsDirectory = await getApplicationDocumentsDirectory();

    List tasksDatabaseYears = [];

    applicationDocumentsDirectory.listSync().forEach((FileSystemEntity entity) {
      String entityName = entity.path.split(Platform.pathSeparator).last;

      if (entityName.startsWith(TasksRegisterer.tasksDatabaseFileNameStart) && entityName.endsWith(TasksRegisterer.tasksDatabaseFileNameEnd)) {
        String tasksDatabaseYearString = entityName;

        tasksDatabaseYearString = tasksDatabaseYearString.replaceFirst(TasksRegisterer.tasksDatabaseFileNameStart, '');
        tasksDatabaseYearString = tasksDatabaseYearString.replaceFirst(TasksRegisterer.tasksDatabaseFileNameEnd, '');

        int tasksDatabaseYear = int.parse(tasksDatabaseYearString);

        tasksDatabaseYears.add(tasksDatabaseYear);
      }
    });

    tasksDatabaseYears.sort();

    return tasksDatabaseYears;
  }

  static Future<void> deleteData() async {
    Directory applicationDocumentsDirectory = await getApplicationDocumentsDirectory();

    applicationDocumentsDirectory.listSync().forEach((FileSystemEntity entity) {
      String entityName = entity.path.split(Platform.pathSeparator).last;

      if (entityName.startsWith(TasksRegisterer.tasksDatabaseFileNameStart) && entityName.endsWith(TasksRegisterer.tasksDatabaseFileNameEnd)) {
        File(entity.path).delete();
      }
    });
  }

  static Future<File> getTasksDatabaseFile(int year) async {
    Directory applicationDocumentsDirectory = await getApplicationDocumentsDirectory();

    String tasksDatabaseFileName = '${TasksRegisterer.tasksDatabaseFileNameStart}${year}${TasksRegisterer.tasksDatabaseFileNameEnd}';

    return File('${applicationDocumentsDirectory.path}${Platform.pathSeparator}${tasksDatabaseFileName}');
  }

  static const String tasksDatabaseFileNameStart = 'tasks-database-';
  static const String tasksDatabaseFileNameEnd = '.json';

  static const List taskStatusPriority = ['generic', 'entered', 'progress', 'delivered', 'received', 'unpaid'];

  static const JsonEncoder defaultJsonEncoder = JsonEncoder.withIndent('  ');
}

Future<DateTime?> showCustomDatePicker(BuildContext context) {
  DateTime currentTime = DateTime.now();

  return showDatePicker(
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData(
          colorScheme: ColorScheme.dark(
            primary: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: child!
      );
    },
    context: context,
    firstDate: DateTime(currentTime.year - 100),
    lastDate: DateTime(currentTime.year + 100),
    initialDate: currentTime,
  );
}

String formatDeadlineTime(DateTime deadlineTime) {
  return '${deadlineTime.day.toString().length == 1 ? 0 : ''}${deadlineTime.day}/${deadlineTime.month.toString().length == 1 ? 0 : ''}${deadlineTime.month}';
}