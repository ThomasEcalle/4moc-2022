import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

abstract class AnalyticsInterface {
  void logEvent(String name, {Map<String, String>? params});
}

class FirebaseAnalyticsImplementation extends AnalyticsInterface {
  @override
  void logEvent(String name, {Map<String, String>? params}) {
    FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
  }
}

class AnalyticsManager extends InheritedWidget {
  final AnalyticsInterface analyticsInterface;

  const AnalyticsManager({
    Key? key,
    required Widget child,
    required this.analyticsInterface,
  }) : super(key: key, child: child);

  static AnalyticsManager of(BuildContext context) {
    final AnalyticsManager? result = context.dependOnInheritedWidgetOfExactType<AnalyticsManager>();
    assert(result != null, 'No AnalyticsManager found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AnalyticsManager old) {
    return false;
  }

  void logEvent(String name, {Map<String, String>? params}) {
    analyticsInterface.logEvent(name, params: params);
  }
}
