import 'dart:html' as html;

import 'package:dawn/src/core/build_context.dart';
import 'package:dawn/widgets.dart';

import 'utils/bulma_widget.dart';

class Button extends StatelessWidget {
  final Widget child;
  final void Function() onTap;
  final String? style;

  const Button({required this.child, required this.onTap, this.style});

  @override
  Widget build(BuildContext context) {
    return _ButtonHtmlWidget(
      child,
      cssClass: 'button${style != null ? ' $style' : ''}',
      onTap: (_) => onTap(),
    );
  }
}

class _ButtonHtmlWidget extends BulmaPaintedWidget {
  final Widget child;
  _ButtonHtmlWidget(this.child,
      {required super.cssClass, required super.onTap});

  @override
  BulmaPaintedNode<BulmaPaintedWidget, html.Element> createNode() =>
      _ButtonHtmlNode(this);
}

class _ButtonHtmlNode
    extends BulmaSingleChildPaintedNode<_ButtonHtmlWidget, html.ButtonElement> {
  _ButtonHtmlNode(super.widget) : super(element: html.ButtonElement());

  @override
  Widget get childWidget => widget.child;
}
