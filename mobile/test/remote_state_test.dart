import 'package:deliverpuyo_mobile/state/remote_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteState', () {
    test('represents mutually exclusive states', () {
      const initial = RemoteInitial<int>();
      const loading = RemoteLoading<int>();
      const data = RemoteData(1);
      const empty = RemoteEmpty<int>();
      const error = RemoteError<int>('Error');

      expect(initial, isA<RemoteInitial<int>>());
      expect(loading, isA<RemoteLoading<int>>());
      expect(data, isA<RemoteData<int>>());
      expect(empty, isA<RemoteEmpty<int>>());
      expect(error, isA<RemoteError<int>>());
      expect(data, isNot(isA<RemoteError<int>>()));
      expect(error, isNot(isA<RemoteData<int>>()));
    });
  });
}
