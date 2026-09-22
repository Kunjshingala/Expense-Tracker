import 'package:expense_tracker/utils/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps [child] inside a MaterialApp so the helpers have a Navigator.
Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

class _Screen extends StatelessWidget {
  const _Screen(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(body: Text(label));
}

void main() {
  testWidgets('openScreen pushes the screen onto the stack', (tester) async {
    await pumpHost(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => openScreen(context, const _Screen('pushed')),
          child: const Text('go'),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('pushed'), findsOneWidget);
  });

  testWidgets('closeScreen returns the result to the caller', (tester) async {
    /// The bug this pins: closeScreen passed the type parameter T to
    /// Navigator.pop instead of the result it was given, so every caller
    /// awaiting a value got the Type object back.
    Object? received = 'not-set';

    await pumpHost(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            received = await openScreenWithResult<String>(
              context,
              Builder(
                builder: (inner) => TextButton(
                  onPressed: () => closeScreen<String>(inner, 'the-result'),
                  child: const Text('close'),
                ),
              ),
            );
          },
          child: const Text('go'),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('close'));
    await tester.pumpAndSettle();

    expect(received, 'the-result');
  });

  testWidgets('closeScreen with no result returns null', (tester) async {
    Object? received = 'not-set';

    await pumpHost(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            received = await openScreenWithResult<String>(
              context,
              Builder(
                builder: (inner) => TextButton(
                  onPressed: () => closeScreen(inner),
                  child: const Text('close'),
                ),
              ),
            );
          },
          child: const Text('go'),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('close'));
    await tester.pumpAndSettle();

    expect(received, isNull);
  });

  testWidgets('closeScreen on a route that cannot pop does nothing', (tester) async {
    await pumpHost(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => closeScreen(context),
          child: const Text('close'),
        ),
      ),
    );

    await tester.tap(find.text('close'));
    await tester.pumpAndSettle();

    expect(find.text('close'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('openScreenWithClearPrevious leaves nothing to pop back to', (tester) async {
    await pumpHost(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => openScreenWithClearPrevious(context, const _Screen('only')),
          child: const Text('go'),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('only'), findsOneWidget);
    expect(find.text('go'), findsNothing);

    final BuildContext context = tester.element(find.text('only'));
    expect(canPop(context), isFalse);
  });

  testWidgets('openScreenWithReplacePrevious swaps the current screen out', (tester) async {
    await pumpHost(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => openScreenWithReplacePrevious(context, const _Screen('replacement')),
          child: const Text('go'),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(find.text('replacement'), findsOneWidget);
    expect(find.text('go'), findsNothing);
  });
}
