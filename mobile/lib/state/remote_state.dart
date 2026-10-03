sealed class RemoteState<T> {
  const RemoteState();
}

final class RemoteInitial<T> extends RemoteState<T> {
  const RemoteInitial();
}

final class RemoteLoading<T> extends RemoteState<T> {
  const RemoteLoading();
}

final class RemoteData<T> extends RemoteState<T> {
  const RemoteData(this.value, {this.notice});

  final String? notice;

  final T value;
}

final class RemoteEmpty<T> extends RemoteState<T> {
  const RemoteEmpty([this.message = 'No hay datos disponibles.']);

  final String message;
}

final class RemoteError<T> extends RemoteState<T> {
  const RemoteError(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}
