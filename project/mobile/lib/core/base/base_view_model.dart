import 'package:flutter/foundation.dart';

abstract class BaseViewModel<T> extends ChangeNotifier {
  BaseViewModel(T defaultState) : _state = defaultState;

  bool _isDisposed = false;
  T _state;

  bool get isDisposed => _isDisposed;

  T get state => _state;

  set state(T newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @protected
  void safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
