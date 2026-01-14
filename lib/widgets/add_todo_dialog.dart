import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/todo_model.dart';

class AddTodoDialog extends StatefulWidget {
  final Todo? todo;

  const AddTodoDialog({super.key, this.todo});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isReminderActive = false;
  String _priority = 'Sedang';
  String _category = 'Umum';

  final List<String> _priorities = ['Rendah', 'Sedang', 'Tinggi'];
  final List<String> _categories = ['Umum', 'Pendidikan', 'Pekerjaan', 'Pribadi', 'Belanja', 'Kesehatan'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    
    if (widget.todo != null) {
      _isReminderActive = widget.todo!.isReminderActive;
      _priority = widget.todo!.priority;
      _category = widget.todo!.category;
      if (widget.todo!.dueDate != null) {
        _selectedDate = widget.todo!.dueDate;
        _selectedTime = TimeOfDay.fromDateTime(widget.todo!.dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: _selectedDate != null && _selectedDate!.isBefore(DateTime.now()) 
          ? _selectedDate! 
          : DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (date != null) {
      if (!mounted) return;
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
          _isReminderActive = true; // Auto-enable reminder if time is picked
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    // Shared styling for inputs
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.todo == null ? 'Tugas Baru' : 'Edit Tugas',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Title Input
              TextFormField(
                controller: _titleController,
                style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87),
                decoration: inputDecoration.copyWith(
                  labelText: 'Judul Tugas',
                  prefixIcon: Icon(Icons.edit_note_rounded, color: primaryColor),
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Description Input
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: inputDecoration.copyWith(
                  labelText: 'Catatan Tambahan',
                  prefixIcon: Icon(Icons.notes_rounded, color: Colors.grey),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Dropdowns Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Prioritas',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: _priorities.map((val) => DropdownMenuItem(
                        value: val, 
                        child: Text(val, style: TextStyle(
                          color: val == 'Tinggi' ? Colors.red : (val == 'Sedang' ? Colors.orange : Colors.green)
                        )),
                      )).toList(),
                      onChanged: (val) => setState(() => _priority = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                       dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                      decoration: inputDecoration.copyWith(
                        labelText: 'Kategori',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: _categories.map((val) => DropdownMenuItem(
                        value: val, 
                        child: Text(val, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                      )).toList(),
                      onChanged: (val) => setState(() => _category = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Reminder Section
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.indigo.shade900.withOpacity(0.2) : Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isReminderActive ? primaryColor.withOpacity(0.5) : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isReminderActive ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                      color: primaryColor,
                    ),
                  ),
                  title: Text(
                    'Pengingat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    _selectedDate == null 
                      ? 'Ketuk untuk atur waktu' 
                      : DateFormat('d MMM, HH:mm', 'id_ID').format(
                          DateTime(
                            _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
                            _selectedTime?.hour ?? 0, _selectedTime?.minute ?? 0,
                          ),
                        ),
                    style: TextStyle(
                      color: _selectedDate == null 
                        ? (isDark ? Colors.white60 : Colors.grey) 
                        : (isDark ? Colors.lightBlueAccent : primaryColor),
                      fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  trailing: Switch(
                    value: _isReminderActive,
                    activeColor: primaryColor,
                    onChanged: (val) {
                      setState(() {
                        _isReminderActive = val;
                        if (val && _selectedDate == null) _pickDateTime();
                      });
                    },
                  ),
                  onTap: () {
                     _pickDateTime(); // Allow picking time even if switch is off/on
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [primaryColor, Colors.deepPurpleAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      DateTime? finalDueDate;
                      if (_selectedDate != null && _selectedTime != null) {
                        finalDueDate = DateTime(
                          _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
                          _selectedTime!.hour, _selectedTime!.minute,
                        );
                      }
                      
                      final newTodo = Todo(
                        id: widget.todo?.id,
                        title: _titleController.text,
                        description: _descriptionController.text,
                        createdAt: widget.todo?.createdAt ?? DateTime.now(),
                        isCompleted: widget.todo?.isCompleted ?? false,
                        dueDate: finalDueDate,
                        isReminderActive: _isReminderActive,
                        priority: _priority,
                        category: _category,
                      );
                      Navigator.pop(context, newTodo);
                    }
                  },
                  child: const Text(
                    'Simpan Tugas', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
              
              if (widget.todo != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text("Hapus Tugas?"),
                          content: const Text("Tugas yang dihapus tidak dapat dikembalikan."),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Batal"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red,
                                elevation: 0,
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Hapus"),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true && mounted) Navigator.pop(context, 'delete');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Hapus Tugas Ini'),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
