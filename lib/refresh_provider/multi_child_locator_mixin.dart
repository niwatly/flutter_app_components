import 'refresh_provider.dart';

mixin MultiLocatorMixin on LocatorMixin {
  bool _isInitStateDone = false;

  final List<LocatorMixin> _children = [];

  @override
  void initState() {
    super.initState();
    for (final locator in _children) {
      locator.initState();
    }
    _isInitStateDone = true;
  }

  @override
  void update(T Function<T>() watch) {
    super.update(watch);
    for (final locator in _children) {
      locator.update(watch);
    }
  }

  @override
  set read(T Function<T>() read) {
    super.read = read;
    for (final locator in _children) {
      locator.read = read;
    }
  }

  void addChildLocatorMixin(LocatorMixin child) {
    if (_isInitStateDone) {
      child.initState();
    }
    child.read = read;
    _children.add(child);
  }
}
