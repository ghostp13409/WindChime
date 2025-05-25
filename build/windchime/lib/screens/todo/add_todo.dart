// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:windchime/services/utils/sound_utils.dart';
import '../../models/todo/todo_models.dart';
import 'package:reactive_forms/reactive_forms.dart';

class AddTodoFormScreen extends StatelessWidget {
  AddTodoFormScreen({super.key});

  FormGroup form = FormGroup({
    'task': FormControl<String>(validators: [Validators.required]),
    'type': FormControl<String>(validators: [Validators.required]),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add new task',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ReactiveForm(
              formGroup: form,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task Details',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ReactiveTextField(
                            formControlName: 'task',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Task Description',
                              hintText: 'Enter your task',
                              prefixIcon: Icon(Icons.edit_rounded,
                                  color: theme.primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.primaryColor.withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: theme.scaffoldBackgroundColor,
                            ),
                            textAlign: TextAlign.start,
                            keyboardType: TextInputType.text,
                            validationMessages: {
                              'required': (error) =>
                                  'The task field is required!',
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task Type',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ReactiveFormField<String, String>(
                            formControlName: 'type',
                            builder: (field) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            theme.primaryColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        ReactiveRadioListTile<String>(
                                          formControlName: 'type',
                                          title: Text(
                                            'Personal',
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          value: 'personal',
                                          activeColor: theme.primaryColor,
                                        ),
                                        ReactiveRadioListTile<String>(
                                          formControlName: 'type',
                                          title: Text(
                                            'School',
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          value: 'school',
                                          activeColor: theme.primaryColor,
                                        ),
                                        ReactiveRadioListTile<String>(
                                          formControlName: 'type',
                                          title: Text(
                                            'Work',
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          value: 'work',
                                          activeColor: theme.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (field.control.invalid &&
                                      field.control.touched)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Please select a task type!',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                            validationMessages: {
                              'required': (error) =>
                                  'The task type is required!',
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (form.valid) {
                    Task task = Task(
                      taskText: form.value['task'].toString(),
                      category: form.value['type'].toString(),
                    );
                    playSound('todo/sounds/add.mp3');
                    Navigator.pop(context, task);
                  } else {
                    form.markAllAsTouched();
                    playSound('todo/sounds/wrong.mp3');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_task_rounded),
                    const SizedBox(width: 8),
                    Text(
                      'Add Task',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
