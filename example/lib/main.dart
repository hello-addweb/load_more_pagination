import 'dart:async';
import 'package:flutter/material.dart';
import 'package:load_more_pagination/load_more_pagination.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pagination Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        platform: TargetPlatform.iOS,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,

  }) : super(key: key);


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<int> productList = [];
  bool isFinishLoadMore = false;

  @override
  void initState() {
    super.initState();
  }

  void initiateList() {
    productList.addAll(List.generate(5, (v) => v));
    setState(() {});
  }

  Future<bool> _loadMoreData() async {
    await Future.delayed(const Duration(seconds: 0, milliseconds: 100));
    initiateList();
    return true;
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 0, milliseconds: 100));
    productList.clear();
    initiateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Load More List"),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: LoadMore(
          isFinish: isFinishLoadMore,
          onLoadMore: _loadMoreData,
          whenEmptyLoad: true,
          delegate: const DefaultLoadMoreDelegate(),
          textBuilder: DefaultLoadMoreTextBuilder.english,
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text('Product $index'),
                subtitle: const Text('Subtitle'),
              );
            },
            itemCount: productList.length,
          ),
        ),
      ),
    );
  }


}
