import 'package:dawn/core.dart';
import 'package:dawn/src/core/build_context.dart';
import 'package:dawn/widgets.dart';

class Column extends StatelessWidget {
  final List<Widget> children;

  Column({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(children,
        style: const Style({
          'display': 'flex',
          'flex-flow': 'column',
        }));
  }
}
