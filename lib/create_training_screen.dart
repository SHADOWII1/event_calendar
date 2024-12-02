import 'package:flutter/material.dart';
import 'package:event_calendar/services/training_service.dart';

class CreateTrainingPage extends StatefulWidget {
  const CreateTrainingPage({super.key});

  @override
  _CreateTrainingPageState createState() => _CreateTrainingPageState();
}

class _CreateTrainingPageState extends State<CreateTrainingPage> {
  final _formKey = GlobalKey<FormState>();
  final _trainingService = TrainingService();

  // Controllers for each input field
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _maxStudentsController = TextEditingController();
  final TextEditingController _minStudentsController = TextEditingController();

  // Date picker method
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      controller.text = "${selectedDate.toLocal()}".split(' ')[0];  // Format the date to YYYY-MM-DD
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      // Convert to 24-hour format: example: 9:00 AM -> 09:00:00
      final now = DateTime.now();
      final formattedTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
      controller.text = "${formattedTime.hour.toString().padLeft(2, '0')}:${formattedTime.minute.toString().padLeft(2, '0')}:00";
    }
  }


  // Method to handle form submission
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _trainingService.createTraining(
          title: _titleController.text,
          code: _codeController.text,
          description: _descriptionController.text,
          startDate: _startDateController.text,
          endDate: _endDateController.text,
          startTime: _startTimeController.text,
          endTime: _endTimeController.text,
          maxEnrolledStudents: int.parse(_maxStudentsController.text),
          minEnrolledStudents: int.parse(_minStudentsController.text),
        );
        Navigator.pop(context,true); // Go back after successful creation
        print('Training created successfully!');
      } catch (error) {
        print('Error: $error');
        Navigator.pop(context,false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Training'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              GestureDetector(
                onTap: () => _selectDate(context, _startDateController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _startDateController,
                    decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a start date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, _endDateController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _endDateController,
                    decoration: const InputDecoration(labelText: 'End Date (YYYY-MM-DD)'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter an end date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectTime(context, _startTimeController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(labelText: 'Start Time (HH:MM AM/PM)'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter a start time';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectTime(context, _endTimeController),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(labelText: 'End Time (HH:MM AM/PM)'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter an end time';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              TextFormField(
                controller: _maxStudentsController,
                decoration: const InputDecoration(labelText: 'Max Students'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a max number of students';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _minStudentsController,
                decoration: const InputDecoration(labelText: 'Min Students'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a min number of students';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Training'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
