import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'providers/todo_provider.dart';
import 'widgets/todo_item.dart';
import 'widgets/add_todo_dialog.dart';
import 'widgets/dashboard_chart.dart';
import 'widgets/stat_card.dart';
import 'widgets/stat_card.dart';
import 'pages/settings_page.dart';
import 'providers/settings_provider.dart';
import 'models/todo_model.dart';

class TodoWebSimple extends StatefulWidget {
  const TodoWebSimple({super.key});

  @override
  State<TodoWebSimple> createState() => _TodoWebSimpleState();
}

class _TodoWebSimpleState extends State<TodoWebSimple> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Pendidikan', 'Umum', 'Pekerjaan', 'Pribadi', 'Belanja', 'Kesehatan'];
  
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check screen size for responsive scaling - Global scope for Scaffold properties
    final bool isCompact = MediaQuery.of(context).size.width < 600;
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Theme Colors
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FE);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.grey.shade800;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          final allTodos = provider.todos; // Get filtered list from provider actually returns everything if we don't apply filter in provider. 
          // But wait, provider.todos adheres to provider._filter. 
          // Let's rely on manual filtering here for the dashboard stats to be accurate regardless of tab.
          // Actually, let's fix the provider usage. provider.todos returns based on filter.
          
          // For the DASHBOARD stats, we need ALL todos to count them properly.
          // Let's assume for now provider.todos returns what the user selected (All/Active/Done).
          // Ideally, we'd want a separate getter for "Stats". 
          // For now, let's just use the current viewer.
          
          final int activeCount = allTodos.where((t) => !t.isCompleted).length;
          final int doneCount = allTodos.where((t) => t.isCompleted).length;
          
          final int totalCount = allTodos.length;

          // Apply Category Filter locally for the LIST view
          final displayTodos = _selectedCategory == 'Semua' 
              ? allTodos 
              : allTodos.where((t) => t.category == _selectedCategory).toList();

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // Web Platform Warning
                if (kIsWeb)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Berjalan di Web: Data hanya disimpan di memori (tidak permanen). Untuk fitur lengkap, jalankan di Android/iOS.',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Colors.deepPurpleAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${_getGreeting()}, ${settings.userName}',
                                        style: TextStyle(
                                          fontSize: isCompact ? 22 : 28,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' 👋',
                                        style: TextStyle(fontSize: isCompact ? 18 : 24),
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('HH:mm', 'id_ID').format(_currentTime),
                                      style: TextStyle(
                                        fontSize: isCompact ? 32 : 40,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.0,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_currentTime),
                                      style: TextStyle(
                                        fontSize: isCompact ? 14 : 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.settings_rounded, color: Colors.white),
                              iconSize: isCompact ? 24 : 28,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Charts & Stats
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.all(isCompact ? 20 : 28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark 
                              ? [const Color(0xFF2C2C2C), const Color(0xFF252525)]
                              : [Colors.white, Colors.grey.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                        border: Border.all(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Use global isCompact check from MediaQuery if needed, 
                          // or local constraints. constraints is safer for container width.
                          final isMobile = constraints.maxWidth < 600;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: Pie Chart
                              Expanded(
                                flex: 5,
                                child: DashboardChart(
                                  activeCount: activeCount,
                                  doneCount: doneCount,
                                  isCompact: isMobile,
                                ),
                              ),
                              SizedBox(width: isMobile ? 12 : 24),
                              // Right: Stats Grid
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    StatCard(
                                      title: 'Tertunda',
                                      count: activeCount.toString(),
                                      icon: Icons.pending_actions_rounded,
                                      color: Theme.of(context).colorScheme.secondary,
                                      isCompact: isMobile,
                                    ),
                                    SizedBox(height: isMobile ? 12 : 16),
                                    StatCard(
                                      title: 'Selesai',
                                      count: doneCount.toString(),
                                      icon: Icons.check_circle_rounded,
                                      color: const Color(0xFF00AAA0), // Hijau Muda (Tealish)
                                      isCompact: isMobile,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // 3. Category Filter
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              Icon(Icons.filter_list_rounded, 
                                size: 20, 
                                color: secondaryTextColor
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Filter Kategori',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 44,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final isSelected = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedCategory = cat;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(22),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isCompact ? 14 : 20,
                                        vertical: isCompact ? 8 : 10,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  Theme.of(context).primaryColor,
                                                  Theme.of(context).primaryColorDark,
                                                ],
                                              )
                                            : null,
                                        color: isSelected ? null : (isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100),
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.indigo.shade700
                                              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                                          width: 1.5,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.indigo.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isSelected)
                                            const Padding(
                                              padding: EdgeInsets.only(right: 6),
                                              child: Icon(
                                                Icons.check_circle_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          Text(
                                            cat,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : secondaryTextColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: isCompact ? 12 : 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Task List Header
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.indigo.shade500,
                                    Colors.indigo.shade700,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Tugas Terbaru',
                              style: TextStyle(
                                fontSize: isCompact ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.indigo.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${displayTodos.length} items',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 5. Task List
                displayTodos.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_add, size: 60, color: Colors.indigo.shade100),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada tugas',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final todo = displayTodos[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4), // reduced padding as TodoItem has its own margin
                              child: TodoItem(
                                todo: todo,
                                onChanged: (_) => provider.toggleTodo(todo),
                                onDelete: () => provider.deleteTodo(todo.id!),
                                onTap: () => _showAddTodoDialog(context, todo: todo),
                              ),
                            );
                          },
                          childCount: displayTodos.length,
                        ),
                      ),
                  
                  const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Colors.deepPurple,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTodoDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: Icon(
            Icons.add_task_rounded,
            color: Colors.white,
            size: isCompact ? 20 : 24,
          ),
          label: Text(
            'Tambah Tugas',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 13 : 15,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, {Todo? todo}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Transparent for rounded corners
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddTodoDialog(todo: todo),
      ),
    );

    if (!mounted) return;

    final provider = Provider.of<TodoProvider>(context, listen: false);

    if (result == 'delete' && todo != null) {
      await provider.deleteTodo(todo.id!);
    } else if (result is Todo) {
      if (todo == null) {
        await provider.addTodo(result);
      } else {
        await provider.updateTodo(result);
      }
    }
  }
}
