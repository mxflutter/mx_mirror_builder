import 'package:mxflutter_cli/proxy_builder.dart';
import 'package:test/test.dart';

void main() {
  test('checkNotNull', () {
    assert(!checkNotNull(null, 'null'));
    assert(checkNotNull('sdkpath', 'sdkpath'));
  });
}
