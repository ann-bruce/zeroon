import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/main.dart';

void main() {
  testWidgets('renders the ZEROON entry screen', (tester) async {
    await tester.pumpWidget(const ZeroonApp());

    expect(find.text('ZEROON'), findsOneWidget);
    expect(find.text('先看见此刻的状态。'), findsOneWidget);
  });
}

