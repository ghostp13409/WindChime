import 'package:prog2435_final_project_app/models/todo/todo_models.dart';

import '../db_helper.dart';

class TodoRepository {
  final dbHelper = DbHelper.dbHero;

  Future<int> insert(Task task) async {
    return await dbHelper.insertDb(task.toMap(), 'todo_tasks');
  }

  Future<List<Task>> getAllTasks() async {
    final List<Map<String, dynamic>> maps = await dbHelper.readDb('todo_tasks');
    return List.generate(maps.length, (i) {
      return Task(
          id: maps[i]['id'],
          taskText: maps[i]['taskText'],
          isComplete: maps[i]['isComplete'] == 1, //Converst int to bool
          category: maps[i]['category']);
    });
  }

  Future<int> update(Task task) async {
    if (task.id == null) {
      throw Exception('Task ID cannot be null, update could not be done!');
    }
    return await dbHelper.updateDb(task.toMap(), 'todo_tasks');
  }

  Future<int> delete(int id) async {
    return await dbHelper.deleteDb(id, 'todo_tasks');
  }
}
