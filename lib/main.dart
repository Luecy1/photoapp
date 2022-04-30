import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photoapp/photo_list_screen.dart';
import 'package:photoapp/providers.dart';

import 'sign_in_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer(
        builder: ((context, watch, child) {
          final asyncUser = watch(userProvider);

          return asyncUser.when(data: (data) {
            return data == null ? SignInScreen() : PhotoListScreen();
          }, loading: () {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }, error: (e, stacktrace) {
            return Scaffold(
              body: Center(
                child: Text(e.toString()),
              ),
            );
          });
        }),
      ),
    );
  }
}
