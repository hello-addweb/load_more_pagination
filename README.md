<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->


# Load More Pagination

```load_more_pagination```  Extensible and highly customizable package to help you lazily load and display small chunks of items as the user scrolls down the screen. ✨

It's support any type of list view builder with endless scrolling pagination, lazy loading pagination, progressive loading pagination, etc.

Very smooth animations supporting Android, iOS & WebApp, DesktopApp.

## Show Cases

<div style="display:flex">
<img width="355" alt="alert2" src="https://github.com/hello-addweb/-TikTok-Flutter/assets/133627084/1e69b847-17f1-48a5-8bd4-52284df382be" width="200">
<div/>

## Why?

We build this package because we wanted to:

- have a complete pagination handling package with list view.
- user able to refresh the page on end of listview.
- set isFinish bool true if pagination count is ended.
- Endless scrolling pagination.

## Installation

Create a new project with the command

```yaml
flutter create MyApp
```

Add

```yaml
load_more_pagination: ...
```

to your `pubspec.yaml` of your flutter project.
**OR**
run

```yaml
flutter pub add load_more_pagination
```

in your project's root directory.

In your library add the following import:

```dart
import 'package:load_more_pagination/load_more_pagination.dart';
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Usage

```dart
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagination Demo',
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
    productList.addAll(List.generate(10, (v) => v));
    setState(() {});
  }

  Future<bool> _loadMoreData() async {
    await Future.delayed(const Duration(seconds: 2));
    initiateList();
    if(productList.length>=30){
      isFinishLoadMore = true;
    }
    return true;
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 2));
    productList.clear();
    isFinishLoadMore = false;
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
        child: LoadMorePagination(
          isFinish: isFinishLoadMore,
          onLoadMorePagination: _loadMoreData,
          loaderColor: Colors.green,
          whenEmptyLoad: true,
          delegate: const DefaultLoadMorePaginationDelegate(),
          textBuilder: DefaultLoadMorePaginationTextBuilder.english,
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text('Product ${index+1}'),
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
```         

## Usage With GetX State Management

```dart
class OrdersNotificationController extends GetxController {
  
  Repository repository = Repository();
  RxList<OrderListModel> myOrdersList = <OrderListModel>[].obs;
  RxBool isFinishLoadMore = false.obs;
  RxBool isOrdersListLoading = true.obs;
  RxInt pageNumber = 1.obs;

  Future<bool> loadMore() async {
    await Future.delayed(const Duration(seconds: 0, milliseconds: 2000));
    await getOrdersList(shouldShowLoader: false);
    return true;
  }

  getOrdersList({bool shouldShowLoader = true, bool isPageRefresh = false}) async {
    try {
      String qParams = "pageSize=20&current=${pageNumber.value}";
      if (shouldShowLoader) isOrdersListLoading(true);
      List<dynamic>? response =
      await repository.getApiCall(url: "order/list?$qParams");
      if (isPageRefresh) myOrdersList.clear();
      if (response != null && response.isNotEmpty) {
        for (var element in response) {
          myOrdersList.add(OrderListModel.fromJson(element));
        }
        pageNumber.value += 1;
      } else {
        /// Changing isFinishLoadMore flag true when no more data available in pagination api.
        isFinishLoadMore(true);
      }
      isOrdersListLoading(false);
    } catch (e, stackTrace) {
      isOrdersListLoading(false);
    }
  }
}

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  /// find orders notification controller.
  final OrdersNotificationController _ordersNC = Get.find();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((Duration time) => init());
    super.initState();
  }

  init() {
    bool isLogin = CommonLogics.checkUserLogin();
    if (isLogin) {
      _ordersNC.isFinishLoadMore(false);
      _ordersNC.pageNumber(1);
      _ordersNC.getOrdersList(shouldShowLoader: false, isPageRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CommonColors.appBgColor,
        body: Obx(() {
          return _ordersNC.isOrdersListLoading.value
              ? const Center(
            child: CircularProgressIndicator(
              color: CommonColors.appColor,
            ),
          )
              : ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: RefreshIndicator(
              onRefresh: () async {
                _ordersNC.isFinishLoadMore(false);
                _ordersNC.pageNumber(1);
                await _ordersNC.getOrdersList(
                    shouldShowLoader: false, isPageRefresh: true);
                return;
              },
              child: _ordersNC.myOrdersList.isNotEmpty
                  ? LoadMore(
                  isFinish: _ordersNC.isFinishLoadMore.value,
                  onLoadMore: _ordersNC.loadMore,
                  textBuilder: DefaultLoadMoreTextBuilder.english,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _ordersNC.myOrdersList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              Get.to(() => OrderDetailsScreen(
                                orderId: _ordersNC
                                    .myOrdersList[index]
                                    .orderItemId,
                              ));
                            },
                            child: OrderTileWidget(
                              orderListItem:
                              _ordersNC.myOrdersList[index],
                            ));
                      }))
                  : const NoDataScreen(),
            ),
          );
        }));
  }
}

``` 


## Constructor

#### Basic

| Parameter             | Default                                                        | Description                                                    | Required |
|-----------------------|:---------------------------------------------------------------|:---------------------------------------------------------------|:--------:|
| child                 | -                                                              | ListView widget as a child.                                    |   true   |
| onLoadMorePagination  | -                                                              | On load function for handling pagination.                      |   true   |
| loaderColor           | -                                                              | Bottom CircularProgressIndicator loader color.                 |   true   |
| isFinish              | false                                                          | is Finish book for handling load more end functionality.       |  false   |
