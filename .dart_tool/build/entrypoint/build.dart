// ignore_for_file: directives_ordering
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:fast_i18n/src/builder.dart' as _i2;
import 'dart:isolate' as _i3;
import 'package:build_runner/build_runner.dart' as _i4;
import 'dart:io' as _i5;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(
    r'fast_i18n:fast_i18n',
    [_i2.i18nBuilder],
    _i1.toRoot(),
    hideOutput: false,
  )
];
void main(
  List<String> args, [
  _i3.SendPort? sendPort,
]) async {
  var result = await _i4.run(
    args,
    _builders,
  );
  sendPort?.send(result);
  _i5.exitCode = result;
}
