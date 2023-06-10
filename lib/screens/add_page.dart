import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPage extends StatefulWidget {
  final Map? todo;
  const AddPage({
    super.key,
    this.todo
  });

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  bool idEditing = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.todo != null){
      idEditing = true;
      _titleController.text = widget.todo!['title'];
      _descriptionController.text = widget.todo!['description'];
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            idEditing? 'Edit Todo' : 'Add Todo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: idEditing ? edit : submit,
            icon: const Icon(Icons.add),
            label: Text(
              idEditing ? 'Edit' : 'Add',
            )
          ),
        ],
      ),
    );
  }
  Future<void> submit() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final todo = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final response = await http.post(
      Uri.parse('https://api.nstack.in/v1/todos'),
      body: jsonEncode(todo),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 201) {
      _titleController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
      showSuccessMessage('Created successfully');
    } else {
      showErrorMessage('Failed to create');
    }
  }
  Future<void> edit() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final todo = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final response = await http.put(
      Uri.parse('https://api.nstack.in/v1/todos/${widget.todo!['_id']}'),
      body: jsonEncode(todo),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      _titleController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
      showSuccessMessage('Updated successfully');
    } else {
      showErrorMessage('Failed to update');
    }
  }
  void showSuccessMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  void showErrorMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
