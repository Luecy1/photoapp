import 'package:flutter/material.dart';
import 'package:photoapp/PhotoViewScreen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo App'),
        actions: [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.exit_to_app)),
        ],
      ),
      body: PageView(
        controller: _controller,
        onPageChanged: (int index) => {_onPageChanged(index)},
        children: [
          Center(
            child: PhotoGridView(
              onTap: ((imageUrl) {
                _onTapPhoto(imageUrl);
              }),
            ),
          ),
          Center(
            child: Text('ページ：お気に入り'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
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

  void _onTapPhoto(String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return PhotoViewScreen(imageUrl: imageUrl);
    }));
  }
}

class PhotoGridView extends StatelessWidget {
  PhotoGridView({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final void Function(String imageUrl) onTap;

  final List<String> imageList = [
    'https://placehold.jp/400x300.png?text=0',
    'https://placehold.jp/400x300.png?text=1',
    'https://placehold.jp/400x300.png?text=2',
    'https://placehold.jp/400x300.png?text=3',
    'https://placehold.jp/400x300.png?text=4',
    'https://placehold.jp/400x300.png?text=5',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(8),
      children: imageList.map((imageUrl) {
        return Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: InkWell(
                onTap: () => onTap(imageUrl),
                child: Image.network(
                  imageUrl,
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
