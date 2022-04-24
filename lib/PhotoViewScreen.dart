import 'package:flutter/material.dart';

class PhotoViewScreen extends StatefulWidget {
  const PhotoViewScreen({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  late PageController _controller;

  // ダミー画像一覧
  final List<String> imageList = [
    'https://placehold.jp/400x300.png?text=0',
    'https://placehold.jp/400x300.png?text=1',
    'https://placehold.jp/400x300.png?text=2',
    'https://placehold.jp/400x300.png?text=3',
    'https://placehold.jp/400x300.png?text=4',
    'https://placehold.jp/400x300.png?text=5',
  ];

  @override
  void initState() {
    super.initState();

    final initialPage = imageList.indexOf(widget.imageUrl);
    _controller = PageController(
      initialPage: initialPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => {},
            children: imageList.map((imageUrl) {
              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
              );
            }).toList(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.bottomCenter,
                  end: FractionalOffset.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () => {},
                    color: Colors.white,
                    icon: const Icon(Icons.share),
                  ),
                  IconButton(
                    onPressed: () => {},
                    color: Colors.white,
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
