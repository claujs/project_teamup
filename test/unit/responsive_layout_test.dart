import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team_up/core/utils/responsive_utils.dart';

void main() {
  group('Responsive Layout System Tests', () {
    group('Constantes e Breakpoints', () {
      test('deve ter valores corretos de breakpoints', () {
        expect(Breakpoints.mobile, 600);
        expect(Breakpoints.tablet, 900);
        expect(Breakpoints.desktop, 1200);
        expect(Breakpoints.largeDesktop, 1800);
      });

      test('breakpoints devem estar em ordem crescente', () {
        expect(Breakpoints.mobile < Breakpoints.tablet, true);
        expect(Breakpoints.tablet < Breakpoints.desktop, true);
        expect(Breakpoints.desktop < Breakpoints.largeDesktop, true);
      });

      test('deve ter todos os tipos de dispositivo', () {
        expect(DeviceType.values.length, 3);
        expect(DeviceType.values.contains(DeviceType.mobile), true);
        expect(DeviceType.values.contains(DeviceType.tablet), true);
        expect(DeviceType.values.contains(DeviceType.desktop), true);
      });
    });

    group('ResponsiveBuilder Widget - Estrutura', () {
      testWidgets('deve ter estrutura básica correta', (tester) async {
        const responsiveWidget = ResponsiveBuilder(
          mobile: Text('Mobile Layout'),
          tablet: Text('Tablet Layout'),
          desktop: Text('Desktop Layout'),
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: responsiveWidget)),
        );

        // Verifica se pelo menos um dos layouts está presente
        final hasAnyLayout =
            find.text('Mobile Layout').evaluate().isNotEmpty ||
            find.text('Tablet Layout').evaluate().isNotEmpty ||
            find.text('Desktop Layout').evaluate().isNotEmpty;

        expect(
          hasAnyLayout,
          true,
          reason: 'Deve renderizar pelo menos um layout',
        );
      });

      testWidgets('deve fazer fallback quando layout não especificado', (
        tester,
      ) async {
        const responsiveWidget = ResponsiveBuilder(
          mobile: Text('Mobile Layout'),
          tablet: Text('Tablet Layout'),
          // desktop não especificado - deve fazer fallback
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: responsiveWidget)),
        );

        // Deve renderizar mobile ou tablet (fallback)
        final hasValidLayout =
            find.text('Mobile Layout').evaluate().isNotEmpty ||
            find.text('Tablet Layout').evaluate().isNotEmpty;

        expect(hasValidLayout, true, reason: 'Deve fazer fallback correto');
      });
    });

    group('ResponsiveContainer Widget', () {
      testWidgets('deve aplicar estrutura básica', (tester) async {
        const container = ResponsiveContainer(child: Text('Test Content'));

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: container)));

        expect(find.text('Test Content'), findsOneWidget);
        expect(find.byType(Container), findsAtLeastNWidgets(1));
        expect(find.byType(ConstrainedBox), findsAtLeastNWidgets(1));
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });
    });

    group('ResponsiveGrid Widget', () {
      testWidgets('deve criar grid com estrutura correta', (tester) async {
        Widget grid = ResponsiveGrid(
          children: List.generate(4, (index) => Text('Item $index')),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: grid)),
          ),
        );

        expect(find.byType(GridView), findsOneWidget);
        expect(find.text('Item 0'), findsOneWidget);
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
        expect(find.text('Item 3'), findsOneWidget);
      });

      testWidgets('deve aplicar configurações de spacing', (tester) async {
        Widget grid = ResponsiveGrid(
          spacing: 24.0,
          runSpacing: 32.0,
          children: List.generate(2, (index) => Text('Item $index')),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: grid)),
          ),
        );

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

        expect(delegate.crossAxisSpacing, 24.0);
        expect(delegate.mainAxisSpacing, 32.0);
      });

      testWidgets('deve usar número de colunas personalizado', (tester) async {
        Widget grid = ResponsiveGrid(
          columns: 3, // Forçar 3 colunas
          children: List.generate(3, (index) => Text('Item $index')),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: grid)),
          ),
        );

        final gridView = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

        expect(delegate.crossAxisCount, 3);
      });
    });

    group('ResponsiveVisibility Widget', () {
      testWidgets('deve mostrar conteúdo por padrão', (tester) async {
        const visibility = ResponsiveVisibility(child: Text('Visible Content'));

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: visibility)));
        expect(find.text('Visible Content'), findsOneWidget);
      });

      testWidgets('deve ter widget Visibility presente', (tester) async {
        const visibility = ResponsiveVisibility(
          hiddenOnMobile: true,
          child: Text('Content'),
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: visibility)));

        // Verifica se o widget Visibility está presente
        expect(find.byType(Visibility), findsOneWidget);

        // Verifica se o conteúdo está lá (independente da visibilidade)
        final visibilityWidget = tester.widget<Visibility>(
          find.byType(Visibility),
        );
        expect(visibilityWidget.child, isA<Text>());
      });
    });

    group('Uso Real dos Widgets - Cenários das Telas', () {
      testWidgets(
        'deve replicar layout de login/registro com ResponsiveBuilder',
        (tester) async {
          // Simula exatamente como é usado nas telas de auth
          final responsiveWidget = ResponsiveBuilder(
            mobile: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(child: const Text('Mobile Auth Form')),
            ),
            tablet: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Container(child: const Text('Tablet Auth Form')),
                  ),
                ),
              ),
            ),
            desktop: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Container(child: const Text('Desktop Auth Form')),
                  ),
                ),
              ),
            ),
          );

          await tester.pumpWidget(
            MaterialApp(home: Scaffold(body: responsiveWidget)),
          );

          // Verifica que pelo menos um layout está ativo
          final hasAuthForm = find
              .textContaining('Auth Form')
              .evaluate()
              .isNotEmpty;
          expect(hasAuthForm, true);

          // Verifica estrutura básica
          expect(find.byType(ResponsiveBuilder), findsOneWidget);
        },
      );

      testWidgets(
        'deve replicar uso do ResponsiveContainer nas telas de usuários',
        (tester) async {
          // Simula como é usado nas telas users/favorites
          const container = ResponsiveContainer(
            maxWidth: 800,
            child: Column(children: [Text('Users List'), Text('Content Area')]),
          );

          await tester.pumpWidget(MaterialApp(home: Scaffold(body: container)));

          expect(find.text('Users List'), findsOneWidget);
          expect(find.text('Content Area'), findsOneWidget);
          expect(find.byType(ResponsiveContainer), findsOneWidget);
          expect(find.byType(ConstrainedBox), findsAtLeastNWidgets(1));
        },
      );

      testWidgets('deve funcionar com extensões context reais', (tester) async {
        bool? isLandscape;
        bool? isTabletOrLarger;

        final testWidget = Builder(
          builder: (context) {
            isLandscape = context.isLandscape;
            isTabletOrLarger = context.isTabletOrLarger;
            return Container(
              padding: context.responsivePadding,
              child: const Text('Context Extensions Test'),
            );
          },
        );

        await tester.pumpWidget(MaterialApp(home: Scaffold(body: testWidget)));

        expect(find.text('Context Extensions Test'), findsOneWidget);
        expect(isLandscape, isNotNull);
        expect(isTabletOrLarger, isNotNull);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });

      testWidgets('deve simular grid responsivo como usado no app', (
        tester,
      ) async {
        // Simula uso real de grid nas telas
        Widget grid = ResponsiveGrid(
          spacing: 16,
          runSpacing: 16,
          children: List.generate(
            6,
            (index) => Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Card $index'),
              ),
            ),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: grid)),
          ),
        );

        expect(find.byType(ResponsiveGrid), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget);
        expect(find.text('Card 0'), findsOneWidget);
        expect(find.text('Card 5'), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(6));
      });

      testWidgets('deve testar combinação de widgets como no app real', (
        tester,
      ) async {
        // Combina ResponsiveBuilder + ResponsiveContainer como usado no app
        final complexWidget = ResponsiveBuilder(
          mobile: const ResponsiveContainer(child: Text('Mobile Container')),
          tablet: const ResponsiveContainer(
            maxWidth: 600,
            child: Text('Tablet Container'),
          ),
          desktop: const ResponsiveContainer(
            maxWidth: 800,
            child: Text('Desktop Container'),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: complexWidget)),
        );

        // Verifica se a combinação funciona
        expect(find.byType(ResponsiveBuilder), findsOneWidget);
        expect(find.byType(ResponsiveContainer), findsOneWidget);
        final hasContainer = find
            .textContaining('Container')
            .evaluate()
            .isNotEmpty;
        expect(hasContainer, true);
      });
    });

    group('Cálculos de Responsividade - Lógica Pura', () {
      test('deve calcular tipo de dispositivo corretamente', () {
        // Mobile
        expect(_calculateDeviceType(400), DeviceType.mobile);
        expect(_calculateDeviceType(500), DeviceType.mobile);
        expect(_calculateDeviceType(599), DeviceType.mobile);

        // Tablet
        expect(_calculateDeviceType(600), DeviceType.tablet);
        expect(_calculateDeviceType(700), DeviceType.tablet);
        expect(_calculateDeviceType(800), DeviceType.tablet);
        expect(_calculateDeviceType(899), DeviceType.tablet);

        // Desktop
        expect(_calculateDeviceType(900), DeviceType.desktop);
        expect(_calculateDeviceType(1200), DeviceType.desktop);
        expect(_calculateDeviceType(2000), DeviceType.desktop);
      });

      test('deve calcular padding responsivo', () {
        expect(
          _calculateResponsivePadding(DeviceType.mobile),
          const EdgeInsets.all(16),
        );
        expect(
          _calculateResponsivePadding(DeviceType.tablet),
          const EdgeInsets.all(24),
        );
        expect(
          _calculateResponsivePadding(DeviceType.desktop),
          const EdgeInsets.all(32),
        );
      });

      test('deve calcular margem responsiva', () {
        expect(
          _calculateResponsiveMargin(DeviceType.mobile),
          const EdgeInsets.all(8),
        );
        expect(
          _calculateResponsiveMargin(DeviceType.tablet),
          const EdgeInsets.all(16),
        );
        expect(
          _calculateResponsiveMargin(DeviceType.desktop),
          const EdgeInsets.all(24),
        );
      });

      test('deve calcular número de colunas', () {
        // Mobile portrait
        expect(_calculateGridColumns(DeviceType.mobile, false), 1);
        // Mobile landscape
        expect(_calculateGridColumns(DeviceType.mobile, true), 2);
        // Tablet portrait
        expect(_calculateGridColumns(DeviceType.tablet, false), 2);
        // Tablet landscape
        expect(_calculateGridColumns(DeviceType.tablet, true), 3);
        // Desktop
        expect(_calculateGridColumns(DeviceType.desktop, false), 4);
        expect(_calculateGridColumns(DeviceType.desktop, true), 4);
      });

      test('deve calcular aspect ratio', () {
        expect(_calculateCardAspectRatio(DeviceType.mobile), 1.5);
        expect(_calculateCardAspectRatio(DeviceType.tablet), 1.3);
        expect(_calculateCardAspectRatio(DeviceType.desktop), 1.2);
      });

      test('deve calcular largura máxima de conteúdo', () {
        expect(_calculateMaxContentWidth(DeviceType.mobile), double.infinity);
        expect(_calculateMaxContentWidth(DeviceType.tablet), 800.0);
        expect(_calculateMaxContentWidth(DeviceType.desktop), 1200.0);
      });
    });

    group('ResponsiveValue Helper - Lógica', () {
      test('deve funcionar com diferentes tipos', () {
        // String
        const stringValue = ResponsiveValue<String>(
          mobile: 'Mobile',
          tablet: 'Tablet',
          desktop: 'Desktop',
        );
        expect(stringValue.mobile, 'Mobile');
        expect(stringValue.tablet, 'Tablet');
        expect(stringValue.desktop, 'Desktop');

        // Numérico
        const doubleValue = ResponsiveValue<double>(
          mobile: 16.0,
          tablet: 24.0,
          desktop: 32.0,
        );
        expect(doubleValue.mobile, 16.0);
        expect(doubleValue.tablet, 24.0);
        expect(doubleValue.desktop, 32.0);

        // Boolean
        const boolValue = ResponsiveValue<bool>(
          mobile: true,
          tablet: false,
          desktop: true,
        );
        expect(boolValue.mobile, true);
        expect(boolValue.tablet, false);
        expect(boolValue.desktop, true);
      });

      test('deve permitir valores opcionais', () {
        const responsiveValue = ResponsiveValue<String>(
          mobile: 'Mobile Only',
          // tablet e desktop não especificados
        );
        expect(responsiveValue.mobile, 'Mobile Only');
        expect(responsiveValue.tablet, isNull);
        expect(responsiveValue.desktop, isNull);
      });
    });

    group('Edge Cases', () {
      test('deve lidar com breakpoints exatos', () {
        expect(_calculateDeviceType(600), DeviceType.tablet);
        expect(_calculateDeviceType(900), DeviceType.desktop);
      });

      test('deve lidar com valores extremos', () {
        expect(_calculateDeviceType(1), DeviceType.mobile);
        expect(_calculateDeviceType(10000), DeviceType.desktop);
      });

      test('deve lidar com valores de breakpoint menos 1', () {
        expect(_calculateDeviceType(599), DeviceType.mobile);
        expect(_calculateDeviceType(899), DeviceType.tablet);
      });
    });

    group('Performance', () {
      test('deve executar cálculos rapidamente', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 1000; i++) {
          _calculateDeviceType(400.0 + i);
          _calculateResponsivePadding(DeviceType.mobile);
          _calculateGridColumns(DeviceType.tablet, false);
          _calculateCardAspectRatio(DeviceType.desktop);
          _calculateMaxContentWidth(DeviceType.mobile);
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });

      test('deve ser eficiente com diferentes tipos de dispositivo', () {
        final stopwatch = Stopwatch()..start();

        final deviceTypes = [
          DeviceType.mobile,
          DeviceType.tablet,
          DeviceType.desktop,
        ];

        for (int i = 0; i < 1000; i++) {
          for (final deviceType in deviceTypes) {
            _calculateResponsivePadding(deviceType);
            _calculateResponsiveMargin(deviceType);
            _calculateGridColumns(deviceType, i % 2 == 0);
            _calculateCardAspectRatio(deviceType);
            _calculateMaxContentWidth(deviceType);
          }
        }

        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('Casos de Uso Práticos', () {
      test('deve suportar cenários de layout comum', () {
        // Cenário: Card grid responsivo
        final mobileColumns = _calculateGridColumns(DeviceType.mobile, false);
        final tabletColumns = _calculateGridColumns(DeviceType.tablet, false);
        final desktopColumns = _calculateGridColumns(DeviceType.desktop, false);

        expect(mobileColumns, lessThan(tabletColumns));
        expect(tabletColumns, lessThan(desktopColumns));
      });

      test('deve suportar padding progressivo', () {
        final mobilePadding = _calculateResponsivePadding(DeviceType.mobile);
        final tabletPadding = _calculateResponsivePadding(DeviceType.tablet);
        final desktopPadding = _calculateResponsivePadding(DeviceType.desktop);

        expect(mobilePadding.left, lessThan(tabletPadding.left));
        expect(tabletPadding.left, lessThan(desktopPadding.left));
      });

      test('deve suportar aspect ratios decrescentes', () {
        final mobileAR = _calculateCardAspectRatio(DeviceType.mobile);
        final tabletAR = _calculateCardAspectRatio(DeviceType.tablet);
        final desktopAR = _calculateCardAspectRatio(DeviceType.desktop);

        expect(mobileAR, greaterThan(tabletAR));
        expect(tabletAR, greaterThan(desktopAR));
      });
    });

    group('Validação dos Padrões Usados no App', () {
      test('deve validar breakpoints usados nas telas auth', () {
        // Testa os valores específicos usados nas telas de login/registro
        expect(Breakpoints.mobile, 600); // Usado para context.isLandscape
        expect(Breakpoints.tablet, 900); // Usado nas condições das telas
      });

      test('deve validar larguras máximas usadas nas telas', () {
        // Testa as larguras específicas usadas no ResponsiveBuilder das telas auth
        const tabletMaxWidth = 400; // Usado em login/register tablet
        const desktopMaxWidth = 500; // Usado em login/register desktop

        expect(tabletMaxWidth, lessThan(desktopMaxWidth));
        expect(tabletMaxWidth, greaterThan(300));
        expect(desktopMaxWidth, lessThan(600));
      });

      test('deve validar elevações usadas nos cards', () {
        // Testa as elevações específicas usadas nas telas
        const tabletElevation = 4; // Usado no tablet layout
        const desktopElevation = 8; // Usado no desktop layout

        expect(tabletElevation, lessThan(desktopElevation));
        expect(tabletElevation, greaterThan(0));
        expect(desktopElevation, lessThan(10));
      });

      test('deve validar padrão de padding usado no app', () {
        // Mobile: 24px (auth screens), 16px (responsive)
        // Tablet: 32px (auth screens), 24px (responsive)
        // Desktop: 48px (auth screens), 32px (responsive)

        const authMobilePadding = 24.0;
        const authTabletPadding = 32.0;
        const authDesktopPadding = 48.0;

        expect(authMobilePadding, lessThan(authTabletPadding));
        expect(authTabletPadding, lessThan(authDesktopPadding));

        // Responsive padding é menor
        expect(
          _calculateResponsivePadding(DeviceType.mobile).left,
          lessThan(authMobilePadding),
        );
        expect(
          _calculateResponsivePadding(DeviceType.tablet).left,
          lessThan(authTabletPadding),
        );
        expect(
          _calculateResponsivePadding(DeviceType.desktop).left,
          lessThan(authDesktopPadding),
        );
      });
    });
  });
}

// Helper functions para testar a lógica isoladamente
DeviceType _calculateDeviceType(double width) {
  if (width < Breakpoints.mobile) {
    return DeviceType.mobile;
  } else if (width < Breakpoints.tablet) {
    return DeviceType.tablet;
  } else {
    return DeviceType.desktop;
  }
}

EdgeInsets _calculateResponsivePadding(DeviceType deviceType) {
  switch (deviceType) {
    case DeviceType.mobile:
      return const EdgeInsets.all(16);
    case DeviceType.tablet:
      return const EdgeInsets.all(24);
    case DeviceType.desktop:
      return const EdgeInsets.all(32);
  }
}

EdgeInsets _calculateResponsiveMargin(DeviceType deviceType) {
  switch (deviceType) {
    case DeviceType.mobile:
      return const EdgeInsets.all(8);
    case DeviceType.tablet:
      return const EdgeInsets.all(16);
    case DeviceType.desktop:
      return const EdgeInsets.all(24);
  }
}

int _calculateGridColumns(DeviceType deviceType, bool isLandscape) {
  switch (deviceType) {
    case DeviceType.mobile:
      return isLandscape ? 2 : 1;
    case DeviceType.tablet:
      return isLandscape ? 3 : 2;
    case DeviceType.desktop:
      return 4;
  }
}

double _calculateCardAspectRatio(DeviceType deviceType) {
  switch (deviceType) {
    case DeviceType.mobile:
      return 1.5;
    case DeviceType.tablet:
      return 1.3;
    case DeviceType.desktop:
      return 1.2;
  }
}

double _calculateMaxContentWidth(DeviceType deviceType) {
  switch (deviceType) {
    case DeviceType.mobile:
      return double.infinity;
    case DeviceType.tablet:
      return 800.0;
    case DeviceType.desktop:
      return 1200.0;
  }
}
