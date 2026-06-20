import 'package:flutter/material.dart';
import 'base_state.dart';

class BaseViewModel<T> extends ChangeNotifier {
  BaseState<T> _state = BaseState.initial();

  BaseState<T> get state => _state;

  void setLoading() {
    _state = BaseState.loading(data: _state.data);
    notifyListeners();
  }

  void setSuccess(T data) {
    _state = BaseState.success(data);
    notifyListeners();
  }

  void setError(String message) {
    _state = BaseState.error(message, data: _state.data);
    notifyListeners();
  }

  void reset() {
    _state = BaseState.initial();
    notifyListeners();
  }
}