library load_more_pagination;

import 'dart:async';
import 'package:flutter/material.dart';

///
/// FutureCallBack Function return false or null is fail..
typedef FutureCallBack = Future<bool> Function();

///
/// Load more stateful widget class..
class LoadMore extends StatefulWidget {
  static DelegateBuilder<LoadMoreDelegate> buildDelegate =
      () => const DefaultLoadMoreDelegate();
  static DelegateBuilder<LoadMoreTextBuilder> buildTextBuilder =
      () => DefaultLoadMoreTextBuilder.english;

  /// Only support [ListView],[SliverList]
  final Widget child;

  /// return true is refresh success
  ///
  /// return false or null is fail
  final FutureCallBack onLoadMore;

  /// if [isFinish] is true, then loadMoreWidget status is [LoadMoreStatus.nomore].
  final bool isFinish;

  /// see [LoadMoreDelegate]
  final LoadMoreDelegate? delegate;

  /// see [LoadMoreTextBuilder]
  final LoadMoreTextBuilder? textBuilder;

  /// when [whenEmptyLoad] is true, and when listView children length is 0,or the itemCount is 0,not build loadMoreWidget
  final bool whenEmptyLoad;

  const LoadMore({
    Key? key,
    required this.child,
    required this.onLoadMore,
    this.textBuilder,
    this.isFinish = false,
    this.delegate,
    this.whenEmptyLoad = true,
  }) : super(key: key);

  @override
  _LoadMoreState createState() => _LoadMoreState();
}

///
/// Load more state.
class _LoadMoreState extends State<LoadMore> {
  Widget get child => widget.child;

  LoadMoreDelegate get loadMoreDelegate =>
      widget.delegate ?? LoadMore.buildDelegate();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (child is ListView) {
      return ValueListenableBuilder(
        valueListenable: _loadMoreStatus,
        builder: (context, value, child) {
          return _buildListView(widget.child as ListView) ?? Container();
        },
      );
    }
    if (child is SliverList) {
      return ValueListenableBuilder(
        valueListenable: _loadMoreStatus,
        builder: (context, value, child) {
          return _buildSliverList(widget.child as SliverList);
        },
      );
    }
    return child;
  }

  final ValueNotifier<LoadMoreStatus> _loadMoreStatus =
      ValueNotifier(LoadMoreStatus.idle);
  LoadMoreStatus get status => _loadMoreStatus.value;

  /// if call the method, then the future is not null
  /// so, return a listview and  item count + 1
  Widget? _buildListView(ListView listView) {
    var delegate = listView.childrenDelegate;
    outer:
    if (delegate is SliverChildBuilderDelegate) {
      SliverChildBuilderDelegate delegate =
          listView.childrenDelegate as SliverChildBuilderDelegate;
      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }
      var viewCount = (delegate.estimatedChildCount ?? 0) + 1;
      builder(context, index) {
        if (index == viewCount - 1) {
          return _buildLoadMoreView();
        }
        return delegate.builder(context, index) ?? Container();
      }

      return ListView.builder(
        itemBuilder: builder,
        addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
        addRepaintBoundaries: delegate.addRepaintBoundaries,
        addSemanticIndexes: delegate.addSemanticIndexes,
        dragStartBehavior: listView.dragStartBehavior,
        semanticChildCount: listView.semanticChildCount,
        itemCount: viewCount,
        cacheExtent: listView.cacheExtent,
        controller: listView.controller,
        itemExtent: listView.itemExtent,
        key: listView.key,
        padding: listView.padding,
        physics: listView.physics,
        primary: listView.primary,
        reverse: listView.reverse,
        scrollDirection: listView.scrollDirection,
        shrinkWrap: listView.shrinkWrap,
      );
    } else if (delegate is SliverChildListDelegate) {
      SliverChildListDelegate delegate =
          listView.childrenDelegate as SliverChildListDelegate;

      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }

      delegate.children.add(_buildLoadMoreView());
      return ListView(
        addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
        addRepaintBoundaries: delegate.addRepaintBoundaries,
        cacheExtent: listView.cacheExtent,
        controller: listView.controller,
        itemExtent: listView.itemExtent,
        key: listView.key,
        padding: listView.padding,
        physics: listView.physics,
        primary: listView.primary,
        reverse: listView.reverse,
        scrollDirection: listView.scrollDirection,
        shrinkWrap: listView.shrinkWrap,
        addSemanticIndexes: delegate.addSemanticIndexes,
        dragStartBehavior: listView.dragStartBehavior,
        semanticChildCount: listView.semanticChildCount,
        children: delegate.children,
      );
    }
    return listView;
  }

  Widget _buildSliverList(SliverList list) {
    final delegate = list.delegate;

    if (delegate is SliverChildListDelegate) {
      return SliverList(
        delegate: delegate,
      );
    }

    outer:
    if (delegate is SliverChildBuilderDelegate) {
      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }
      final viewCount = (delegate.estimatedChildCount ?? 0) + 1;
      builder(context, index) {
        if (index == viewCount - 1) {
          return _buildLoadMoreView();
        }
        return delegate.builder(context, index) ?? Container();
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          builder,
          addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
          addRepaintBoundaries: delegate.addRepaintBoundaries,
          addSemanticIndexes: delegate.addSemanticIndexes,
          childCount: viewCount,
          semanticIndexCallback: delegate.semanticIndexCallback,
          semanticIndexOffset: delegate.semanticIndexOffset,
        ),
      );
    }

    outer:
    if (delegate is SliverChildListDelegate) {
      if (!widget.whenEmptyLoad && delegate.estimatedChildCount == 0) {
        break outer;
      }
      delegate.children.add(_buildLoadMoreView());
      return SliverList(
        delegate: SliverChildListDelegate(
          delegate.children,
          addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
          addRepaintBoundaries: delegate.addRepaintBoundaries,
          addSemanticIndexes: delegate.addSemanticIndexes,
          semanticIndexCallback: delegate.semanticIndexCallback,
          semanticIndexOffset: delegate.semanticIndexOffset,
        ),
      );
    }

    return list;
  }

  Widget _buildLoadMoreView() {
    if (widget.isFinish == true) {
      _updateStatus(LoadMoreStatus.nomore);
    } else {
      if (status == LoadMoreStatus.nomore) {
        _updateStatus(LoadMoreStatus.idle);
      }
    }
    return NotificationListener<_RetryNotify>(
      onNotification: _onRetry,
      child: NotificationListener<_BuildNotify>(
        onNotification: _onLoadMoreBuild,
        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: DefaultLoadMoreView(
            status: status,
            delegate: loadMoreDelegate,
            textBuilder: widget.textBuilder ?? LoadMore.buildTextBuilder(),
          ),
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final widgetHeight = loadMoreDelegate.widgetHeight(status);
    if (notification.metrics.extentAfter < widgetHeight) {
      if (status == LoadMoreStatus.loading) {
        return false;
      }
      if (status == LoadMoreStatus.nomore) {
        return false;
      }
      if (status == LoadMoreStatus.fail) {
        return false;
      }
      if (status == LoadMoreStatus.outScreen) {
        return false;
      }
      if (status == LoadMoreStatus.idle) {
        loadMore();
      }
    } else {
      _updateStatus(LoadMoreStatus.outScreen);
    }

    return false;
  }

  bool _onLoadMoreBuild(_BuildNotify notification) {
    if (status == LoadMoreStatus.loading) {
      return false;
    }
    if (status == LoadMoreStatus.nomore) {
      return false;
    }
    if (status == LoadMoreStatus.fail) {
      return false;
    }
    if (status == LoadMoreStatus.outScreen) {
      return false;
    }
    if (status == LoadMoreStatus.idle) {
      loadMore();
    }
    return false;
  }

  void _updateStatus(LoadMoreStatus status) {
    Future.delayed(Duration.zero, () {
      _loadMoreStatus.value = status;
    });
  }

  bool _onRetry(_RetryNotify notification) {
    loadMore();
    return false;
  }

  void loadMore() {
    _updateStatus(LoadMoreStatus.loading);
    widget.onLoadMore().then((v) {
      if (v == true) {
        _updateStatus(LoadMoreStatus.idle);
      } else {
        _updateStatus(LoadMoreStatus.fail);
      }
    });
  }
}

///
/// Load More status enums.
enum LoadMoreStatus {
  /// wait for loading
  idle,

  /// not in screen
  outScreen,

  /// the view is loading
  loading,

  /// loading fail, need tap view to loading
  fail,

  /// not have more data
  nomore,
}

///
/// DefaultLoadMoreView stateful widget class.
class DefaultLoadMoreView extends StatefulWidget {
  final LoadMoreStatus status;
  final LoadMoreDelegate delegate;
  final LoadMoreTextBuilder textBuilder;

  const DefaultLoadMoreView({
    Key? key,
    this.status = LoadMoreStatus.idle,
    required this.delegate,
    required this.textBuilder,
  }) : super(key: key);

  @override
  DefaultLoadMoreViewState createState() => DefaultLoadMoreViewState();
}

const _defaultLoadMoreHeight = 80.0;
const _loadMoreIndicatorSize = 33.0;
const _loadMoreDelay = 16;

///
/// Default LoadMore ViewState class.
class DefaultLoadMoreViewState extends State<DefaultLoadMoreView> {
  LoadMoreDelegate get delegate => widget.delegate;

  @override
  Widget build(BuildContext context) {
    notify();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.status == LoadMoreStatus.fail ||
            widget.status == LoadMoreStatus.idle) {
          if (mounted) {
            _RetryNotify().dispatch(context);
          }
        }
      },
      child: Container(
        height: delegate.widgetHeight(widget.status),
        alignment: Alignment.center,
        child: delegate.buildChild(
          widget.status,
          builder: widget.textBuilder,
        ),
      ),
    );
  }

  void notify() async {
    var delay = max(delegate.loadMoreDelay(), const Duration(milliseconds: 16));
    await Future.delayed(delay);
    if (widget.status == LoadMoreStatus.idle) {
      if (mounted) {
        _BuildNotify().dispatch(context);
      }
    }
  }

  Duration max(Duration duration, Duration duration2) {
    if (duration > duration2) {
      return duration;
    }
    return duration2;
  }
}

///
/// _BuildNotify
class _BuildNotify extends Notification {}

///
/// _RetryNotify
class _RetryNotify extends Notification {}

///
/// DelegateBuilder
typedef DelegateBuilder<T> = T Function();

///
/// loadMore widget properties
abstract class LoadMoreDelegate {
  static DelegateBuilder<LoadMoreDelegate> buildWidget =
      () => const DefaultLoadMoreDelegate();

  const LoadMoreDelegate();

  /// the loadMore widget height
  double widgetHeight(LoadMoreStatus status) => _defaultLoadMoreHeight;

  /// build loadMore delay
  Duration loadMoreDelay() => const Duration(milliseconds: _loadMoreDelay);

  Widget buildChild(
    LoadMoreStatus status, {
    LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.english,
  });
}

///
/// DefaultLoadMoreDelegate class extends LoadMoreDelegate...
class DefaultLoadMoreDelegate extends LoadMoreDelegate {
  const DefaultLoadMoreDelegate();

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.english}) {
    String text = builder(status);
    if (status == LoadMoreStatus.fail) {
      return Text(text);
    }
    if (status == LoadMoreStatus.idle) {
      return Text(text);
    }
    if (status == LoadMoreStatus.loading) {
      return Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              width: _loadMoreIndicatorSize,
              height: _loadMoreIndicatorSize,
              child: CircularProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(text),
            ),
          ],
        ),
      );
    }
    if (status == LoadMoreStatus.nomore) {
      return Text(text);
    }

    return Text(text);
  }
}

///
/// LoadMoreTextBuilder
typedef LoadMoreTextBuilder = String Function(LoadMoreStatus status);

///
/// _buildEnglishText
String _buildEnglishText(LoadMoreStatus status) {
  String text;
  switch (status) {
    case LoadMoreStatus.fail:
      text = "Tap to retry";
      break;
    case LoadMoreStatus.idle:
      text = "";
      break;
    case LoadMoreStatus.loading:
      text = "Loading...";
      break;
    case LoadMoreStatus.nomore:
      text = " ";
      break;
    default:
      text = "";
  }
  return text;
}

///
/// DefaultLoadMoreTextBuilder class.
class DefaultLoadMoreTextBuilder {
  static const LoadMoreTextBuilder english = _buildEnglishText;
}
