import 'package:counter_dawn/bulma/src/utils/bulma_div.dart';
import 'package:dawn/dawn.dart';

import 'package:counter_dawn/bulma/bulma.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(final BuildContext context) {
    return Container(
      [
        const Image(
          '/assets/logo.svg',
          style: Style({'width': '128px', 'height': '128px'}),
          animation: Animation(
            keyframes: [
              Keyframe(
                offset: 0,
                style: Style({'transform': 'translateY(0px)'}),
              ),
              Keyframe(
                offset: 1,
                style: Style({'transform': 'translateY(8px)'}),
              ),
            ],
            duration: Duration(seconds: 1),
            easing: Easing(0.2, 0, 0.4, 1),
            direction: AnimationDirection.alternate,
            iterations: double.infinity,
          ),
        ),
        const Text(
          'Welcome to Dawn',
          style: Style({
            'font-size': '24px',
            'font-weight': 'bold',
            'color': '#00e690',
          }),
        ),
        const Container([
          Text('To get started, edit '),
          Text(
            'web/main.dart',
            style: Style({
              'font-family': 'monospace',
              'background': '#eeeeee',
              'border-radius': '4px',
              'padding': '4px',
            }),
          ),
          Text(' and save to reload.'),
        ]),
        CounterWidget(),
      ],
      style: const Style({
        'display': 'flex',
        'flex-flow': 'column',
        'justify-content': 'center',
        'text-align': 'center',
        'align-items': 'center',
        'gap': '16px',
        'padding': '16px',
        'width': '100%',
        'min-height': '100vh',
        'background': '#ffffff',
        'color': '#000000',
        'font-family': '"Jost", system-ui',
        'user-select': 'none',
      }),
    );
  }
}

class CounterWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int counter;
  @override
  void initialize() {
    super.initialize();
    counter = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Button(
            child: const Text('Decrease'),
            onTap: () {
              print('Hey! You\'ve tapped the button!');
              setState(() {
                counter--;
              });
            },
            style: 'is-warning'),
        BulmaDivWidget.just(
            child: Text('$counter'), cssClass: 'is-align-self-center'),
        Button(
            child: const Text('Increease'),
            onTap: () {
              print('Hey! You\'ve tapped the other button!');
              setState(() {
                counter++;
              });
            },
            style: 'is-success'),
      ],
    );
  }
}
