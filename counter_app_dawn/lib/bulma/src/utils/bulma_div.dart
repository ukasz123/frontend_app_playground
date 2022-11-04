import 'dart:html' as html;

import 'package:dawn/dawn.dart';

import 'bulma_widget.dart';

class BulmaDivWidget extends BulmaPaintedWidget {
  final List<Widget> children;
  BulmaDivWidget({required this.children, required super.cssClass});

  factory BulmaDivWidget.just(
          {required Widget child, required String cssClass}) =>
      BulmaDivWidget(children: [child], cssClass: cssClass);

  factory BulmaDivWidget.empty({required String cssClass}) =>
      BulmaDivWidget(children: [], cssClass: cssClass);

  @override
  BulmaPaintedNode<BulmaPaintedWidget, html.Element> createNode() =>
      _BulmaDivNode(this);
}

class _BulmaDivNode
    extends BulmaMultiChildPaintedNode<BulmaDivWidget, html.DivElement> {
  _BulmaDivNode(super.widget) : super(element: html.DivElement());

  @override
  List<Widget> get childWidgets => widget.children;
}
