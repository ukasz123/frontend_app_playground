import 'package:dawn/dawn.dart';

import 'utils/bulma_div.dart';

class Row extends StatelessWidget {
  final List<Widget> children;
  final bool isFlex;

  Row({required this.children, this.isFlex = true});

  @override
  Widget build(final BuildContext context) {
    return BulmaDivWidget(
        children: children
            .map((final child) => BulmaDivWidget.just(
                child: child, cssClass: 'column${isFlex ? ' is-flex' : ''}'))
            .toList(growable: false),
        cssClass: 'columns');
  }
}
