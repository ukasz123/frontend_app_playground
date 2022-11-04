import 'dart:html';

import 'package:dawn/widgets.dart';

abstract class BulmaPaintedWidget extends PaintedWidget {
  final String? cssClass;

  const BulmaPaintedWidget({
    required this.cssClass,
    super.style,
    super.animation,
    super.onTap,
    super.onPointerDown,
    super.onPointerUp,
    super.onPointerEnter,
    super.onPointerLeave,
    super.onPointerMove,
    super.onPointerCancel,
    super.onPointerOver,
    super.onPointerOut,
    super.onMouseDown,
    super.onMouseUp,
    super.onMouseEnter,
    super.onMouseLeave,
    super.onMouseMove,
    super.onMouseOver,
    super.onMouseOut,
    super.onTouchStart,
    super.onTouchEnd,
    super.onTouchMove,
    super.onTouchCancel,
    super.key,
  });

  @override
  BulmaPaintedNode<BulmaPaintedWidget, Element> createNode();
}

mixin BulmaPaintedNode<T extends BulmaPaintedWidget, U extends Element>
    on PaintedNode<T, U> {
  @override
  void initializeElement() {
    super.initializeElement();
    element.className = widget.cssClass ?? '';
  }
}

class BulmaChildlessPaintedNode<T extends BulmaPaintedWidget, U extends Element>
    extends ChildlessPaintedNode<T, U> with BulmaPaintedNode<T, U> {
  BulmaChildlessPaintedNode(super.widget, {required super.element});
}

abstract class BulmaSingleChildPaintedNode<T extends BulmaPaintedWidget,
        U extends Element> extends SingleChildPaintedNode<T, U>
    with BulmaPaintedNode<T, U> {
  BulmaSingleChildPaintedNode(super.widget, {required super.element});
}

abstract class BulmaMultiChildPaintedNode<T extends BulmaPaintedWidget,
        U extends Element> extends MultiChildPaintedNode<T, U>
    with BulmaPaintedNode<T, U> {
  BulmaMultiChildPaintedNode(super.widget, {required super.element});
}
