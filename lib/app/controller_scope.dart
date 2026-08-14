import 'package:flutter/widgets.dart';

import 'app_controller.dart';

class ControllerScope extends InheritedNotifier<AppController> {
  const ControllerScope({
    required AppController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ControllerScope>();
    assert(scope != null, 'ControllerScope is missing');
    return scope!.notifier!;
  }

  static AppController read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<ControllerScope>();
    final scope = element?.widget as ControllerScope?;
    assert(scope != null, 'ControllerScope is missing');
    return scope!.notifier!;
  }
}
