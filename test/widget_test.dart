import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todoapps/main.dart';

void main() {
  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://ykngemphhdllhczdpqwx.supabase.co',
      anonKey: 'sb_publishable_51MagfVCx-dnEu64htfhgg_H6bQibw2',
    );
  });

  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}