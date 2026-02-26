import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AIStudyApp());
}

class AIStudyApp extends StatelessWidget {
  const AIStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      // StreamBuilder listens to Firebase and refreshes the UI automatically
      // when someone logs in or out.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen(); // Your existing UI
          }
          return const LoginPage(); // New Login UI
        },
      ),
    );
  }
}

// --- NEW LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Method to Sign In (For existing users)
  Future<void> _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.toString()}")),
      );
    }
  }

  // Method to Sign Up (For new users)
  Future<void> _signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign Up Failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text("AI Study App", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 30),

            // Login Button (Primary Action)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signIn,
                child: const Text("Log In"),
              ),
            ),

            const SizedBox(height: 12),

            // Sign Up Button (Secondary Action)
            TextButton(
              onPressed: _signUp,
              child: const Text("New here? Create an Account"),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep your existing HomeScreen class below this...
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Study Hub"),
        actions: [
          IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressSection(),
              const SizedBox(height: 24),
              const Text("Your Tools", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _buildToolCard(context, "Quizzes", Icons.quiz_outlined, Colors.orange, "Test progress"),
                  _buildToolCard(context, "Flashcards", Icons.auto_awesome_motion_outlined, Colors.purple, "Spaced repetition"),
                  _buildToolCard(context, "AI Notes", Icons.description_outlined, Colors.blue, "Summarized info"),
                  _buildToolCard(context, "Library", Icons.folder_copy_outlined, Colors.brown, "Saved materials"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widgets for the HomeScreen
  Widget _buildProgressSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6750A4), Color(0xFF9581D1)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Weekly Progress", style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 8),
          Text("85% Mastery", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          LinearProgressIndicator(value: 0.85, backgroundColor: Colors.white24, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, Color color, String desc) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}