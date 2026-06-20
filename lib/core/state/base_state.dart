enum ViewState { initial, loading, success, error }

class BaseState<T> {
  final ViewState status;
  final T? data;
  final String? message;

  const BaseState({
    required this.status,
    this.data,
    this.message,
  });

  factory BaseState.initial() =>
      const BaseState(status: ViewState.initial);

  factory BaseState.loading({T? data}) =>
      BaseState(status: ViewState.loading, data: data);

  factory BaseState.success(T data) =>
      BaseState(status: ViewState.success, data: data);

  factory BaseState.error(String message, {T? data}) =>
      BaseState(status: ViewState.error, message: message, data: data);
}