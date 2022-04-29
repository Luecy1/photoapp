import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stateprovider = StateProvider((ref) {
  return 0;
});

final streamProvider = StreamProvider.autoDispose((ref) {
  return FirebaseFirestore.instance.collection('samples').snapshots();
});

final scopedProvider = ScopedProvider<int>(null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(
      child: MaterialApp(
    home: MyWidget(),
  )));
}

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final int state = watch(stateprovider).state;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () {
                context.read(stateprovider).state += 1;
              },
              child: Text('COUNT: $state'),
            ),
            Consumer(builder: (context, watch, child) {
              final asyncStream = watch(streamProvider);
              return asyncStream.when(data: (data) {
                return Column(
                  children: data.docs.map((doc) {
                    return Text(doc.get('value') as String);
                  }).toList(),
                );
              }, loading: () {
                return const CircularProgressIndicator();
              }, error: (e, stacktrace) {
                return Text(e.toString());
              });
            }),
            ProviderScope(
              overrides: [
                scopedProvider.overrideWithValue(state * 2),
              ],
              child: const OtherWidget(),
            ),
            ProviderScope(
              overrides: [
                scopedProvider.overrideWithValue(state * 10),
              ],
              child: const OtherWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class OtherWidget extends ConsumerWidget {
  const OtherWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final scoped = watch(scopedProvider);
    return Text('$scoped');
  }
}
