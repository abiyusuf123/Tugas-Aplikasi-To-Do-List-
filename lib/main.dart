import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// Entry point widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi ToDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return HomeScreen();
          }
          return AuthPage(onLoginSuccess: () => {});
        },
      ),
    );
  }
}

// Main screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? updateDocId;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Tambah task
  Future<void> addTask(String task, DateTime? date, TimeOfDay? time) async {
    if (task.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tugas tidak boleh kosong')));
      return;
    }
    if (date == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tanggal harus dipilih')));
      return;
    }
    if (time == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jam harus dipilih')));
      return;
    }
    await FirebaseFirestore.instance.collection('tasks').add({
      'task': task,
      'date': date.toIso8601String(),
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'isDone': false,
    });
    _controller.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  // Update task
  Future<void> updateTask(
    String task,
    String docId,
    DateTime? date,
    TimeOfDay? time,
  ) async {
    if (task.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tugas tidak boleh kosong')));
      return;
    }
    if (date == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tanggal harus dipilih')));
      return;
    }
    if (time == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jam harus dipilih')));
      return;
    }
    await FirebaseFirestore.instance.collection('tasks').doc(docId).update({
      'task': task,
      'date': date.toIso8601String(),
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    });
    setState(() {
      updateDocId = null;
      _selectedDate = null;
      _selectedTime = null;
    });
    _controller.clear();
  }

  // Hapus task
  Future<void> deleteTask(String docId) async {
    await FirebaseFirestore.instance.collection('tasks').doc(docId).delete();
  }

  Future<void> _showTaskSheet({
    String? docId,
    String? initialTask,
    DateTime? initialDate,
    String? initialTime,
  }) async {
    final TextEditingController taskController = TextEditingController(
      text: initialTask ?? '',
    );
    DateTime? selectedDate = initialDate;
    TimeOfDay? selectedTime =
        initialTime != null && initialTime.isNotEmpty
            ? TimeOfDay(
              hour: int.parse(initialTime.split(':')[0]),
              minute: int.parse(initialTime.split(':')[1]),
            )
            : null;
    final isEdit = docId != null;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit : Icons.add,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Edit Tugas' : 'Tambah Tugas',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: taskController,
                decoration: const InputDecoration(
                  labelText: 'Tugas',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.green,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? now,
                    firstDate: now,
                    lastDate: DateTime(now.year + 5),
                    helpText: 'Pilih Tanggal Tugas',
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(primary: Colors.green),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedDate == null
                            ? 'Pilih Tanggal'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        style: TextStyle(
                          color:
                              selectedDate == null
                                  ? Colors.grey
                                  : Colors.green[900],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedTime = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.green),
                      const SizedBox(width: 10),
                      Text(
                        selectedTime == null
                            ? 'Pilih Jam'
                            : selectedTime!.format(context),
                        style: TextStyle(
                          color:
                              selectedTime == null
                                  ? Colors.grey
                                  : Colors.green[900],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    final task = taskController.text;
                    if (task.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tugas tidak boleh kosong'),
                        ),
                      );
                      return;
                    }
                    if (selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tanggal harus dipilih')),
                      );
                      return;
                    }
                    if (selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jam harus dipilih')),
                      );
                      return;
                    }
                    if (isEdit) {
                      await updateTask(
                        task,
                        docId!,
                        selectedDate,
                        selectedTime,
                      );
                    } else {
                      await addTask(task, selectedDate, selectedTime);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Tugas'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FA),
      appBar: AppBar(
        title: Text(
          'Aplikasi ToDo',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            // List View
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('tasks')
                        .orderBy('date')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada tugas'));
                  }
                  final docs = snapshot.data!.docs;
                  return AnimatedList(
                    key: _listKey,
                    initialItemCount: docs.length,
                    itemBuilder: (context, index, animation) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final date =
                          data.containsKey('date')
                              ? DateTime.tryParse(data['date'])
                              : null;
                      final timeStr =
                          data.containsKey('time')
                              ? data['time'] as String
                              : '';
                      final isDone =
                          data.containsKey('isDone')
                              ? data['isDone'] as bool
                              : false;
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: FadeTransition(
                          opacity: animation,
                          child: Container(
                            key: ValueKey(doc.id),
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green[200]!,
                                  Colors.green[400]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isDone,
                                  onChanged: (value) {
                                    FirebaseFirestore.instance
                                        .collection('tasks')
                                        .doc(doc.id)
                                        .update({'isDone': value});
                                  },
                                  activeColor: Colors.green,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['task'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                          decoration:
                                              isDone
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                        ),
                                      ),
                                      if (date != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4.0,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: Colors.green,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${date.day}/${date.month}/${date.year}' +
                                                    (timeStr.isNotEmpty
                                                        ? '  |  $timeStr'
                                                        : ''),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.green[900],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    onPressed: () {
                                      _showTaskSheet(
                                        docId: doc.id,
                                        initialTask: data['task'],
                                        initialDate: date,
                                        initialTime: timeStr,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'Ubah',
                                    splashRadius: 24,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    onPressed: () => deleteTask(doc.id),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Hapus',
                                    splashRadius: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Floating action button for adding/updating tasks
            SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                onPressed: () {
                  _showTaskSheet();
                },
                tooltip: 'Tambah Tugas',
                child: const Icon(Icons.add, size: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                splashColor: Colors.greenAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
