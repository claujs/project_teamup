import 'package:flutter/material.dart';

// Breakpoints padrão para diferentes tamanhos de tela
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

// Tipos de dispositivo
enum DeviceType { mobile, tablet, desktop }

// Extension para obter informações responsivas do contexto
extension ResponsiveContext on BuildContext {
  // Largura da tela
  double get screenWidth => MediaQuery.of(this).size.width;

  // Altura da tela
  double get screenHeight => MediaQuery.of(this).size.height;

  // Orientação da tela
  Orientation get orientation => MediaQuery.of(this).orientation;

  // Tipo de dispositivo baseado na largura
  DeviceType get deviceType {
    final width = screenWidth;
    if (width < Breakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  // Verificar se é mobile
  bool get isMobile => deviceType == DeviceType.mobile;

  // Verificar se é tablet
  bool get isTablet => deviceType == DeviceType.tablet;

  // Verificar se é desktop
  bool get isDesktop => deviceType == DeviceType.desktop;

  // Verificar se é tablet ou maior
  bool get isTabletOrLarger => screenWidth >= Breakpoints.mobile;

  // Verificar se é desktop ou maior
  bool get isDesktopOrLarger => screenWidth >= Breakpoints.tablet;

  // Verificar se está em modo paisagem
  bool get isLandscape => orientation == Orientation.landscape;

  // Verificar se está em modo retrato
  bool get isPortrait => orientation == Orientation.portrait;

  // Padding responsivo
  EdgeInsets get responsivePadding {
    if (isMobile) {
      return const EdgeInsets.all(16);
    } else if (isTablet) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  // Margem responsiva
  EdgeInsets get responsiveMargin {
    if (isMobile) {
      return const EdgeInsets.all(8);
    } else if (isTablet) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  // Número de colunas para grids
  int get gridColumns {
    if (isMobile) {
      return isLandscape ? 2 : 1;
    } else if (isTablet) {
      return isLandscape ? 3 : 2;
    } else {
      return 4;
    }
  }

  // Aspect ratio para cards
  double get cardAspectRatio {
    if (isMobile) {
      return 1.5;
    } else if (isTablet) {
      return 1.3;
    } else {
      return 1.2;
    }
  }

  // Largura máxima para conteúdo
  double get maxContentWidth {
    if (isMobile) {
      return double.infinity;
    } else if (isTablet) {
      return 800;
    } else {
      return 1200;
    }
  }
}

// Widget responsivo que renderiza diferentes layouts baseado no tamanho da tela
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;

    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

// Widget para criar layouts responsivos com constrains
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? context.maxContentWidth,
        ),
        child: Padding(
          padding: padding ?? context.responsivePadding,
          child: child,
        ),
      ),
    );
  }
}

// Grid responsivo
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? columns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final gridColumns = columns ?? context.gridColumns;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: context.cardAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

// Helper para valores responsivos
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  T getValue(BuildContext context) {
    final deviceType = context.deviceType;

    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

// Widget para esconder elementos em determinados tamanhos
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool hiddenOnMobile;
  final bool hiddenOnTablet;
  final bool hiddenOnDesktop;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.hiddenOnMobile = false,
    this.hiddenOnTablet = false,
    this.hiddenOnDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;

    bool shouldHide = false;

    switch (deviceType) {
      case DeviceType.mobile:
        shouldHide = hiddenOnMobile;
        break;
      case DeviceType.tablet:
        shouldHide = hiddenOnTablet;
        break;
      case DeviceType.desktop:
        shouldHide = hiddenOnDesktop;
        break;
    }

    return Visibility(visible: !shouldHide, child: child);
  }
}
