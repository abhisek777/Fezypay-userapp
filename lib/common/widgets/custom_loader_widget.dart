import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class CustomLoaderWidget extends StatefulWidget {
  const CustomLoaderWidget({
    super.key,
    required this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 500),
    this.controller,
  })  : assert(!(itemBuilder is IndexedWidgetBuilder && color is Color) && !(itemBuilder == null && color == null),
  'You should specify either a itemBuilder or a color');

  final Color? color;
  final double size;
  final IndexedWidgetBuilder? itemBuilder;
  final Duration duration;
  final AnimationController? controller;

  @override
  State<CustomLoaderWidget> createState() => _CustomLoaderWidgetState();
}

class _CustomLoaderWidgetState extends State<CustomLoaderWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animationCurve;
  late Animation<double> animationSize;

  @override
  void initState() {
    super.initState();

    controller = (widget.controller ?? AnimationController(vsync: this, duration: widget.duration))
      ..addListener(() => setState(() {}))
      ..repeat(reverse: true);
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);
    animationCurve = Tween(begin: 1.0, end: 0.0).animate(animation);
    animationSize = Tween(begin: 0.5, end: 1.0).animate(animation);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeValue = widget.size * animationSize.value;
    return Center(
      child: Transform(
        transform: Matrix4.identity()..rotateZ(animationCurve.value * math.pi),
        alignment: FractionalOffset.center,
        child: SizedBox.fromSize(
          size: Size.square(sizeValue),
          child: _itemBuilder(0, 0.5 * sizeValue * animationCurve.value),
        ),
      ),
    );
  }

  Widget _itemBuilder(int index, double curveValue) => widget.itemBuilder != null
      ? widget.itemBuilder!(context, index)
      : DecoratedBox(
    decoration: BoxDecoration(
      color: widget.color,
      borderRadius: BorderRadius.all(Radius.circular(curveValue)),
    ),
  );
}