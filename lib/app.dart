import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/auth_screen.dart';
import 'features/tasks/screens/task_list_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gig Task Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6C6FEF),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 15),
        ),
      ),

      home: authState.when(
        data: (user) {
          if (user == null) {
            return AuthScreen();
          }
          return const TaskListScreen();
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
