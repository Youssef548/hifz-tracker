import 'package:hifz_core/hifz_core.dart';
import 'package:test/test.dart';

void main() {
  test('Ok carries value', () {
    expect(const Ok<int>(3).value, 3);
  });
  test('Err carries failure', () {
    final e = Err<int>(const ApiFailure(code: 'X', message: 'm'));
    expect(e.failure.code, 'X');
  });
  test('map transforms Ok', () {
    final r = const Ok<int>(2).map((v) => v * 2);
    expect(r.when(ok: (v) => v, err: (_) => -1), 4);
  });
  test('when dispatches to ok', () {
    const Result<int> r = Ok<int>(7);
    expect(r.when(ok: (v) => v, err: (_) => -1), 7);
  });
  test('when dispatches to err', () {
    final Result<int> r = Err<int>(const ApiFailure(code: 'X', message: 'm'));
    expect(r.when(ok: (v) => v, err: (f) => -1), -1);
  });
}
