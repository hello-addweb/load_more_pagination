/// Documentation
///
/// load_more_pagination library collection.
library load_more_pagination;

import 'dart:async';
import 'package:flutter/material.dart';

///
/// FutureCallBack Function return false or null is fail..
typedef FutureCallBack = Future<bool> Function();

///
/// Load more stateful widget class..
class LoadMorePagination extends StatefulWidget {
  static DelegateBuilder<LoadMorePaginationDelegate> buildDelegate =
      () => const DefaultLoadMorePaginationDelegate();
  static DelegateBuilder<LoadMorePaginationTextBuilder> buildTextBuilder =
      () => DefaultLoadMorePaginationTextBuilder.english;

  /// Only support [ListView],[SliverList]
  final Widget child;

  /// return true is refresh success
  ///
  /// return false or null is fail
  final FutureCallBack onLoadMorePagination;

  /// if [isFinish] is true, then loadMoreWidget status is [LoadMoreStatus.nomore].
  final bool isFinish;

  /// see [LoadMorePaginationDelegate]
  final LoadMorePaginationDelegate? delegate;

  /// see [LoadMorePaginationTextBuilder]
  final LoadMorePaginationTextBuilder? textBuilder;

  /// when [whenEmptyLoad] is true, and when listView children length is 0,or the itemCount is 0,not build LoadMorePaginationWidget
  final bool whenEmptyLoad;

  /// see [LoadMorePaginationTextBuilder]
  final Color loaderColor;

  const LoadMorePagination({
    Key? key,
    required this.child,
    required this.onLoadMorePagination,
    required this.loaderColor,
    this.textBuilder,
    this.isFinish = false,
    this.delegate,
    this.whenEmptyLoad = true,
  }) : super(key: key);

  @override
  _LoadMorePaginationState createState() => _LoadMorePaginationState();
}

///
/// Load more state.
class _LoadMorePaginationState extends State<LoadMorePagination> {
  Widget get child => widget.child;

  LoadMorePaginationDelegate get loadMoreDelegate =>
      widget.delegate ?? LoadMorePagination.buildDelegate();

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

  final ValueNotifier<LoadMorePaginationStatus> _loadMoreStatus =
      ValueNotifier(LoadMorePaginationStatus.idle);
  LoadMorePaginationStatus get status => _loadMoreStatus.value;

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
          return _buildLoadMorePaginationView();
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

      delegate.children.add(_buildLoadMorePaginationView());
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
          return _buildLoadMorePaginationView();
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
      delegate.children.add(_buildLoadMorePaginationView());
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

  Widget _buildLoadMorePaginationView() {
    if (widget.isFinish == true) {
      _updateStatus(LoadMorePaginationStatus.nomore);
    } else {
      if (status == LoadMorePaginationStatus.nomore) {
        _updateStatus(LoadMorePaginationStatus.idle);
      }
    }
    return NotificationListener<_RetryNotify>(
      onNotification: _onRetry,
      child: NotificationListener<_BuildNotify>(
        onNotification: _onLoadMorePaginationBuild,
        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: DefaultLoadMorePaginationView(
            status: status,
            delegate: loadMoreDelegate,
            textBuilder:
                widget.textBuilder ?? LoadMorePagination.buildTextBuilder(),
          ),
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final widgetHeight = loadMoreDelegate.widgetHeight(status);
    if (notification.metrics.extentAfter < widgetHeight) {
      if (status == LoadMorePaginationStatus.loading) {
        return false;
      }
      if (status == LoadMorePaginationStatus.nomore) {
        return false;
      }
      if (status == LoadMorePaginationStatus.fail) {
        return false;
      }
      if (status == LoadMorePaginationStatus.outScreen) {
        return false;
      }
      if (status == LoadMorePaginationStatus.idle) {
        loadMore();
      }
    } else {
      _updateStatus(LoadMorePaginationStatus.outScreen);
    }

    return false;
  }

  bool _onLoadMorePaginationBuild(_BuildNotify notification) {
    if (status == LoadMorePaginationStatus.loading) {
      return false;
    }
    if (status == LoadMorePaginationStatus.nomore) {
      return false;
    }
    if (status == LoadMorePaginationStatus.fail) {
      return false;
    }
    if (status == LoadMorePaginationStatus.outScreen) {
      return false;
    }
    if (status == LoadMorePaginationStatus.idle) {
      loadMore();
    }
    return false;
  }

  void _updateStatus(LoadMorePaginationStatus status) {
    Future.delayed(Duration.zero, () {
      _loadMoreStatus.value = status;
    });
  }

  bool _onRetry(_RetryNotify notification) {
    loadMore();
    return false;
  }

  void loadMore() {
    _updateStatus(LoadMorePaginationStatus.loading);
    widget.onLoadMorePagination().then((v) {
      if (v == true) {
        _updateStatus(LoadMorePaginationStatus.idle);
      } else {
        _updateStatus(LoadMorePaginationStatus.fail);
      }
    });
  }
}

///
/// Load More status enums.
enum LoadMorePaginationStatus {
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
/// DefaultLoadMorePaginationView stateful widget class.
class DefaultLoadMorePaginationView extends StatefulWidget {
  final LoadMorePaginationStatus status;
  final LoadMorePaginationDelegate delegate;
  final LoadMorePaginationTextBuilder textBuilder;

  const DefaultLoadMorePaginationView({
    Key? key,
    this.status = LoadMorePaginationStatus.idle,
    required this.delegate,
    required this.textBuilder,
  }) : super(key: key);

  @override
  DefaultLoadMorePaginationViewState createState() =>
      DefaultLoadMorePaginationViewState();
}

const _defaultLoadMorePaginationHeight = 80.0;
const _loadMoreIndicatorSize = 33.0;
const _loadMoreDelay = 16;

///
/// Default LoadMorePagination ViewState class.
class DefaultLoadMorePaginationViewState
    extends State<DefaultLoadMorePaginationView> {
  LoadMorePaginationDelegate get delegate => widget.delegate;

  @override
  Widget build(BuildContext context) {
    notify();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.status == LoadMorePaginationStatus.fail ||
            widget.status == LoadMorePaginationStatus.idle) {
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
    if (widget.status == LoadMorePaginationStatus.idle) {
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
abstract class LoadMorePaginationDelegate {
  static DelegateBuilder<LoadMorePaginationDelegate> buildWidget =
      () => const DefaultLoadMorePaginationDelegate();

  const LoadMorePaginationDelegate();

  /// the loadMore widget height
  double widgetHeight(LoadMorePaginationStatus status) =>
      _defaultLoadMorePaginationHeight;

  /// build loadMore delay
  Duration loadMoreDelay() => const Duration(milliseconds: _loadMoreDelay);

  Widget buildChild(
    LoadMorePaginationStatus status, {
    LoadMorePaginationTextBuilder builder =
        DefaultLoadMorePaginationTextBuilder.english,
  });
}

///
/// DefaultLoadMorePaginationDelegate class extends LoadMorePaginationDelegate...
class DefaultLoadMorePaginationDelegate extends LoadMorePaginationDelegate {
  const DefaultLoadMorePaginationDelegate();

  @override
  Widget buildChild(LoadMorePaginationStatus status,
      {LoadMorePaginationTextBuilder builder =
          DefaultLoadMorePaginationTextBuilder.english}) {
    String text = builder(status);
    if (status == LoadMorePaginationStatus.fail) {
      return Text(text);
    }
    if (status == LoadMorePaginationStatus.idle) {
      return Text(text);
    }
    if (status == LoadMorePaginationStatus.loading) {
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
    if (status == LoadMorePaginationStatus.nomore) {
      return Text(text);
    }

    return Text(text);
  }
}

///
/// LoadMorePaginationTextBuilder
typedef LoadMorePaginationTextBuilder = String Function(
    LoadMorePaginationStatus status);

///
/// _buildEnglishText
String _buildEnglishText(LoadMorePaginationStatus status) {
  String text;
  switch (status) {
    case LoadMorePaginationStatus.fail:
      text = "Tap to retry";
      break;
    case LoadMorePaginationStatus.idle:
      text = "";
      break;
    case LoadMorePaginationStatus.loading:
      text = "Loading...";
      break;
    case LoadMorePaginationStatus.nomore:
      text = " ";
      break;
    default:
      text = "";
  }
  return text;
}

///
/// DefaultLoadMorePaginationTextBuilder class.
class DefaultLoadMorePaginationTextBuilder {
  static const LoadMorePaginationTextBuilder english = _buildEnglishText;
}
