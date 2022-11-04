import 'package:dawn/dawn.dart';

import 'utils/bulma_div.dart';

class Row extends StatelessWidget {
  final List<Widget> children;

  Row({required this.children});

  @override
  Widget build(final BuildContext context) {
    return BulmaDivWidget(
        children: children
            .map((final child) =>
                BulmaDivWidget.just(child: child, cssClass: 'column'))
            .toList(growable: false),
        cssClass: 'columns');
  }
}
