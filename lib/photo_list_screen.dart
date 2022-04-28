import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photoapp/photo.dart';
import 'package:photoapp/photo_repository.dart';
import 'package:photoapp/photo_view_screen.dart';
import 'package:photoapp/sign_in_screen.dart';

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({Key? key}) : super(key: key);

  @override
  State<PhotoListScreen> createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  late int _currentIndex;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo App'),
        actions: [
          IconButton(
              onPressed: () => _onSignOut(),
              icon: const Icon(Icons.exit_to_app)),
        ],
      ),
      body: StreamBuilder<List<Photo>>(
          stream: PhotoRepository(user).getPhotoList(),
          builder: (context, snapshot) {
            if (snapshot.hasData == false) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final photoList = snapshot.data!;

            return PageView(
              controller: _controller,
              onPageChanged: (int index) => _onPageChanged(index),
              children: [
                Center(
                  child: PhotoGridView(
                    photoList: photoList,
                    onTap: (photo) => _onTapPhoto(photo, photoList),
                  ),
                ),
                const Center(
                  child: Text('ページ：お気に入り'), // todo
                ),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddPhoto(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => {_onTapBottomNavigationItem(index)},
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'フォト'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'お気に入り'),
        ],
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTapBottomNavigationItem(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTapPhoto(Photo photo, List<Photo> photoList) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PhotoViewScreen(
        photo: photo,
        photoList: photoList,
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
}

class PhotoGridView extends StatelessWidget {
  const PhotoGridView({
    Key? key,
    required this.photoList,
    required this.onTap,
  }) : super(key: key);

  final List<Photo> photoList;
  final void Function(Photo photo) onTap;

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
                onPressed: () => {},
                color: Colors.white,
                icon: const Icon(Icons.favorite_border),
              ),
            )
          ],
        );
      }).toList(),
    );
  }
}
