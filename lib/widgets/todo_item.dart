import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(bool?) onChanged;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onDelete,
    required this.onTap,
  });

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Tinggi':
        return Colors.redAccent;
      case 'Sedang':
        return Colors.orangeAccent;
      case 'Rendah':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey[600];

    return Dismissible(
      key: Key(todo.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Konfirmasi Hapus"),
              content: const Text("Apakah Anda yakin ingin menghapus tugas ini?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        color: cardColor,
        elevation: 4, // Modern Elevation
        shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: _getPriorityColor(todo.priority).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.secondary, // Coral Checkbox
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted ? Colors.grey : textColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todo.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    todo.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.indigo.shade900.withOpacity(0.3) : Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      todo.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (todo.dueDate != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      todo.isReminderActive ? Icons.alarm : Icons.calendar_today,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('d MMM, HH:mm', 'id_ID').format(todo.dueDate!),
                      style: TextStyle(fontSize: 10, color: subtitleColor),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getPriorityColor(todo.priority),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
