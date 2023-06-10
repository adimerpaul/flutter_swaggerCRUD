import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (mounted){
      todoGet();

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        centerTitle: true,
      ),
      body:Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: todoGet,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('Edit'),
                        value: 'edit',
                      ),
                      PopupMenuItem(
                        child: Text('Delete'),
                        value: 'delete',
                      ),
                    ];
                  },
                  onSelected: (value) async {
                    if (value == 'delete') {
                      final url = Uri.parse(
                          'https://api.nstack.in/v1/todos/${item['_id']}');
                      final response = await http.delete(url);
                      if (response.statusCode == 200) {
                        final filteredItems = items.where((element) {
                          return element['_id'] != item['_id'];
                        }).toList();
                        setState(() {
                          items = filteredItems;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.body),
                          ),
                        );
                      }
                    }else{
                      final route = MaterialPageRoute(builder: (context) => AddPage(todo: item));
                      await Navigator.push(context, route);
                      setState(() {
                        isLoading = true;
                      });
                      todoGet();
                    }
                  },
                )
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(builder: (context) => const AddPage());
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    todoGet();
  }
  Future<void> todoGet() async {
    final url = Uri.parse('https://api.nstack.in/v1/todos?page=1&limit=10');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      // print(result);
      setState(() {
        items = result;
      });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.body),
        ),
      );
    }
    setState(() {
      isLoading = false;
    });
  }
}
