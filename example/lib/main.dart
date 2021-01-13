import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: CharacterListView(),
      ),
    );
  }
}

class CharacterListView extends StatefulWidget {
  @override
  _CharacterListViewState createState() => _CharacterListViewState();
}

class _CharacterListViewState extends State<CharacterListView> {
  static const _pageSize = 20;

  final ScrollController _scrollController = ScrollController();
  final PagingController<int, Photo> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener(_fetchPage);
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    // try {
    final response = await http.get(
        'http://jsonplaceholder.typicode.com/photos?_start=$pageKey&_limit=$_pageSize');
    print('fetch $pageKey');
    if (response.statusCode == 200) {
      final List<dynamic> responseBody = jsonDecode(response.body);
      final newItems =
          responseBody.map<Photo>((x) => Photo.fromJson(x)).toList();
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } else {
      _pagingController.error = 'failed to load';
    }
    // }
    //  catch (error) {
    //   print('j');
    //   _pagingController.error = error;
    // }
  }

  @override
  Widget build(BuildContext context) => PagedListView<int, Photo>(
        scrollController: _scrollController,
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Photo>(
          itemBuilder: (context, item, index) {
            return Column(
              children: [
                Text(item.id.toString()),
                Text(item.title),
                Image.network(item.url),
                RaisedButton(
                  onPressed: () => _scrollController.animateTo(
                    _scrollController.position.minScrollExtent,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300),
                  ),
                )
              ],
            );
          },
        ),
      );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

class Photo {
  final int albumId;
  final int id;
  final String title;
  final String url;

  Photo({this.albumId, this.id, this.title, this.url});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      albumId: json['albumId'],
      id: json['id'],
      title: json['title'],
      url: json['url'],
    );
  }
}
