import 'package:flutter/material.dart';
import 'package:event_calendar/services/training_service.dart';
import 'package:intl/intl.dart';

class EditTrainingPage extends StatefulWidget {
  final Map<String, dynamic> training;
  final trainingService = TrainingService();

  EditTrainingPage({super.key, required this.training});

  @override
  _EditTrainingPageState createState() => _EditTrainingPageState();
}

class _EditTrainingPageState extends State<EditTrainingPage> {
  late TextEditingController titleController;
  late TextEditingController codeController;
  late TextEditingController descriptionController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController maxStudentsController;
  late TextEditingController minStudentsController;

  // Format the date to show only the date part
  String formatDate(String isoDateString) {
    DateTime dateTime = DateTime.parse(isoDateString);
    return DateFormat('yyyy-MM-dd').format(dateTime); // Format as 'YYYY-MM-DD'
  }
  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing training data
    titleController = TextEditingController(text: widget.training['title']);
    codeController = TextEditingController(text: widget.training['code']);
    descriptionController = TextEditingController(text: widget.training['description']);
    startDateController = TextEditingController(text: formatDate(widget.training['start_date']));
    endDateController = TextEditingController(text: formatDate(widget.training['end_date']));
    startTimeController = TextEditingController(text: widget.training['start_time']);
    endTimeController = TextEditingController(text: widget.training['end_time']);
    maxStudentsController = TextEditingController(text: widget.training['max_enrolled_students'].toString());
    minStudentsController = TextEditingController(text: widget.training['min_enrolled_students'].toString());
  }

  @override
  void dispose() {
    titleController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    maxStudentsController.dispose();
    minStudentsController.dispose();
    super.dispose();
  }

  Future<void> updateTraining() async {
    try {
      await TrainingService().updateTraining(
        code: codeController.text,
        title: titleController.text,
        description: descriptionController.text,
        startDate: startDateController.text,
        endDate: endDateController.text,
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        maxEnrolledStudents: int.parse(maxStudentsController.text),
        minEnrolledStudents: int.parse(minStudentsController.text),
      );
      print('Training updated successfully');
      Navigator.pop(context, true); // Return to the previous screen
    } catch (error) {
      print('Error updating training: $error');
      Navigator.pop(context, false);
    }
  }

  // Method to pick date
  Future<void> _selectDate(TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2101);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0]; // Formatting date
      });
    }
  }

  // Method to pick time
  Future<void> _selectTime(TextEditingController controller) async {
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null && pickedTime != initialTime) {
      setState(() {
        final now = DateTime.now();
        final formattedTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
        controller.text = "${formattedTime.hour.toString().padLeft(2, '0')}:${formattedTime.minute.toString().padLeft(2, '0')}:00";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Training')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Code'),
              readOnly: true, // Code is typically non-editable as it's unique
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            GestureDetector(
              onTap: () => _selectDate(startDateController),
              child: AbsorbPointer(
                child: TextField(
                  controller: startDateController,
                  decoration: const InputDecoration(labelText: 'Start Date'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _selectDate(endDateController),
              child: AbsorbPointer(
                child: TextField(
                  controller: endDateController,
                  decoration: const InputDecoration(labelText: 'End Date'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _selectTime(startTimeController),
              child: AbsorbPointer(
                child: TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(labelText: 'Start Time'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _selectTime(endTimeController),
              child: AbsorbPointer(
                child: TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(labelText: 'End Time'),
                ),
              ),
            ),
            TextField(
              controller: maxStudentsController,
              decoration: const InputDecoration(labelText: 'Max Students'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: minStudentsController,
              decoration: const InputDecoration(labelText: 'Min Students'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateTraining,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
