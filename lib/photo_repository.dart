import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:photoapp/photo.dart';

class PhotoRepository {
  final User _user;

  PhotoRepository(this._user);

  Stream<List<Photo>> getPhotoList() {
    return FirebaseFirestore.instance
        .collection('users/${_user.uid}/photos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_queryToPhotoToList);
  }

  Future<void> addPhoto(File file) async {
    final user = FirebaseAuth.instance.currentUser!;
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final name = file.path.split('/').last;
    final path = '${timestamp}_$name';

    final task = await FirebaseStorage.instance
        .ref()
        .child('users/${user.uid}/photos')
        .child(path)
        .putFile(file);

    final imageUrl = await task.ref.getDownloadURL();
    final imagePath = task.ref.fullPath;

    final data = {
      'imageURL': imageUrl,
      'imagePath': imagePath,
      'isFavorite': false,
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('users/${user.uid}/photos')
        .doc()
        .set(data);
  }

  List<Photo> _queryToPhotoToList(QuerySnapshot query) {
    return query.docs.map((doc) {
      return Photo(
        id: doc.id,
        imageURL: doc.get('imageURL'),
        imagePath: doc.get('imagePath'),
        isFavorite: doc.get('isFavorite'),
        createdAt: (doc.get('createdAt') as Timestamp).toDate(),
      );
    }).toList();
  }

  Map<String, dynamic> _photoToMap(Photo photo) {
    return {
      'imageURL': photo.imageURL,
      'imagePath': photo.imagePath,
      'isFavorite': photo.isFavorite,
      'createdAt': photo.createdAt == null
          ? Timestamp.now()
          : Timestamp.fromDate(photo.createdAt!)
    };
  }

  Future<void> deletePhoto(Photo photo) async {
    final task1 = FirebaseFirestore.instance
        .collection('users/${_user.uid}/photos')
        .doc(photo.id)
        .delete();
    final task2 =
        FirebaseStorage.instance.ref().child(photo.imagePath).delete();

    Future.wait([task1, task2]);
  }

  /// お気に入り状況を更新
  Future<void> updatePhoto(Photo photo) async {
    await FirebaseFirestore.instance
        .collection('users/${_user.uid}/photos')
        .doc(photo.id)
        .update(_photoToMap(photo));
  }
}
