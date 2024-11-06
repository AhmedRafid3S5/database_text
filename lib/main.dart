import 'package:database_text/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:database_text/pages/comm_notices.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Firebase initialization with error handling
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // If Firebase initializes successfully, print success message
    if (kDebugMode) {
      print('Initialization of Firebase is successful');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization failed: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 94, 38, 189)),
        useMaterial3: true,
      ),
      home: const CommNotices(),
    );
  }
}




/*class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Firebase Connection Test'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Attempt to write data
              try {
                await FirebaseFirestore.instance.collection('messages').doc('testDoc').set({
                  'testField': 'Hello, Firebase!',
                });

                // Attempt to read data
                DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('messages').doc('testDoc').get();
                if (snapshot.exists) {
                  print('Connected: ${snapshot.data()}');
                } else {
                  print('No such document!');
                }
              } on FirebaseException catch (e) {
                // Properly handle Firebase exceptions
                print('Firebase error: ${e.message}');
              } catch (e) {
                // Handle any other exceptions
                print('Unexpected error: $e');
              }
            },
            child: Text('Test Firebase Connection'),
          ),
        ),
      ),
    );
  }
}*/

