import 'package:flutter/material.dart';

bool shouldHandlePullToRefresh(ScrollNotification notification) {
  // In this screen we use RefreshIndicator + NestedScrollView + inner
  // CustomScrollView tabs. Refresh notifications can come from either the
  // outer scrollable (depth 0) or the active inner tab scrollable (depth 2).
  final isSupportedDepth = notification.depth == 0 || notification.depth == 2;
  if (!isSupportedDepth) {
    return false;
  }

  if (notification.metrics.axis != Axis.vertical) {
    return false;
  }

  final isAtTop = notification.metrics.extentBefore <= 0;
  if (!isAtTop) {
    return false;
  }

  if (notification is ScrollStartNotification) {
    return notification.dragDetails != null;
  }

  if (notification is ScrollUpdateNotification) {
    return notification.dragDetails != null;
  }

  if (notification is OverscrollNotification) {
    return notification.dragDetails != null;
  }

  // Allow refresh indicator lifecycle to complete after a valid pull sequence.
  return notification is ScrollEndNotification;
}
