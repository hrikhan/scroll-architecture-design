import 'package:flutter/material.dart';

bool shouldHandlePullToRefresh(ScrollNotification notification) {
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
    return notification.dragDetails != null &&
        (notification.scrollDelta ?? 0) < 0;
  }

  if (notification is OverscrollNotification) {
    return notification.dragDetails != null && notification.overscroll < 0;
  }

  // Allow refresh indicator lifecycle to complete after a valid pull sequence.
  return notification is ScrollEndNotification;
}
