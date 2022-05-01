import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photoapp/photo.dart';
import 'package:photoapp/photo_repository.dart';
import 'package:photoapp/photo_view_screen.dart';
import 'package:photoapp/providers.dart';
import 'package:photoapp/sign_in_screen.dart';

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({Key? key}) : super(key: key);

  @override
  State<PhotoListScreen> createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: context.read(photoListIndexProvider).state,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo App'),
        actions: [
          IconButton(
              onPressed: () => _onSignOut(),
              icon: const Icon(Icons.exit_to_app)),
        ],
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (index) => _onPageChanged(index),
        children: [
          Consumer(
            builder: ((context, watch, child) {
              final asyncPhotoList = watch(photoListProvider);
              return asyncPhotoList.when(
                data: ((photoList) {
                  return PhotoGridView(
                    photoList: photoList,
                    onTap: (photo) => _onTapPhoto(photo, photoList),
                    onTapFav: (photo) => _onTapFav(photo),
                  );
                }),
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                error: (e, stacktrace) {
                  return Center(
                    child: Text(e.toString()),
                  );
                },
              );
            }),
          ),
          // 「お気に入り」登録した画像を表示
          Consumer(
            builder: ((context, watch, child) {
              final asyncPhotoList = watch(favoritePhotoListProvider);
              return asyncPhotoList.when(
                data: ((photoList) {
                  return PhotoGridView(
                    photoList: photoList,
                    onTap: (photo) => _onTapPhoto(photo, photoList),
                    onTapFav: (photo) => _onTapFav(photo),
                  );
                }),
                loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                error: (e, stacktrace) {
                  return Center(
                    child: Text(e.toString()),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddPhoto(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Consumer(
        builder: ((context, watch, child) {
          final photoIndex = watch(photoListIndexProvider).state;

          return BottomNavigationBar(
            onTap: (int index) => {_onTapBottomNavigationItem(index)},
            currentIndex: photoIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.image), label: 'フォト'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'お気に入り'),
            ],
          );
        }),
      ),
    );
  }

  void _onPageChanged(int index) {
    context.read(photoListIndexProvider).state = index;
  }

  void _onTapBottomNavigationItem(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    context.read(photoListIndexProvider).state = index;
  }

  void _onTapPhoto(Photo photo, List<Photo> photoList) {
    final initialIndex = photoList.indexOf(photo);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProviderScope(
        overrides: [
          photoViewInitialIndexProvider.overrideWithValue(initialIndex),
        ],
        child: PhotoViewScreen(),
      ),
    ));
  }

  Future<void> _onSignOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => SignInScreen()));
  }

  Future<void> _onAddPhoto() async {
    // 画像ファイルを選択
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('アップロード中')));

      final user = FirebaseAuth.instance.currentUser!;
      final repository = PhotoRepository(user);
      final file = File(result.files.single.path!);
      await repository.addPhoto(file);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('アップロード完了')));
    }
  }

  Future<void> _onTapFav(Photo photo) async {
    final photoRepository = context.read(photoRepositoryProvider);
    final toggledPhoto = photo.toggleIsFavorite();
    await photoRepository!.updatePhoto(toggledPhoto);
  }
}

class PhotoGridView extends StatelessWidget {
  const PhotoGridView({
    Key? key,
    required this.photoList,
    required this.onTap,
    required this.onTapFav,
  }) : super(key: key);

  final List<Photo> photoList;
  final void Function(Photo photo) onTap;
  final void Function(Photo photo) onTapFav;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      children: photoList.map((photo) {
        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: InkWell(
                onTap: () => onTap(photo),
                child: Image.network(
                  photo.imageURL,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => onTapFav(photo),
                color: Colors.pinkAccent,
                icon: photo.isFavorite
                    ? const Icon(Icons.favorite)
                    : const Icon(Icons.favorite_border),
              ),
            )
          ],
        );
      }).toList(),
    );
  }
}
