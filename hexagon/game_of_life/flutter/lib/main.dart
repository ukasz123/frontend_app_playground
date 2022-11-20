// ignore_for_file: invalid_use_of_protected_member

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:hex_game_of_life/game.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 196, 122, 43),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    ),
    home: const GameScreen(),
  )); // GameOfLife(boardSize: 2)));
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int boardSize = 20;

  late GameOfLife _game;

  @override
  void initState() {
    _game = GameOfLife(boardSize: boardSize);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: GameWidget(game: _game),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320.0),
          child: _GameMenu(this),
        )
      ]),
    );
  }
}

class _GameMenu extends StatelessWidget {
  const _GameMenu(
    this._gameController, {
    Key? key,
  }) : super(key: key);

  final _GameScreenState _gameController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Game of Life',
            style: Theme.of(context).textTheme.headline3,
            textAlign: TextAlign.center,
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _gameController._game.running
                      ? null
                      : () {
                          _gameController._game.start();
                          _gameController.setState(() {});
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff0088cc)),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _gameController._game.running
                      ? () {
                          _gameController._game.stop();
                          _gameController.setState(() {});
                        }
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xffcc8800)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              _gameController._game.reset();
              _gameController.setState(() {});
            },
            icon: const Icon(Icons.replay),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 37, 16, 228)),
          ),
          const SizedBox(height: 8.0),
          const Text('Board size'),
          Row(
            children: [
              Expanded(
                child: Slider(
                    value: _gameController.boardSize.toDouble(),
                    min: 10,
                    max: 50,
                    divisions: 8,
                    label: '${_gameController.boardSize}',
                    onChanged: (value) {
                      final v = value.toInt();
                      _gameController._game.boardSize = v;

                      _gameController.setState(() {
                        _gameController.boardSize = v;
                      });
                    }),
              ),
              const SizedBox(width: 8.0),
              Text('${_gameController.boardSize}'),
            ],
          ),
          const SizedBox(height: 24.0),
          const Text('Set alive:'),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  TableCell(
                    child: Text(
                      'When alive:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  ...List.generate(
                    7,
                    (index) => TableCell(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('$index'),
                          Checkbox(
                            value:
                                _gameController._game.keepAlive.contains(index),
                            onChanged: (toggled) {
                              if (toggled ?? false) {
                                _gameController._game.keepAlive.add(index);
                              } else {
                                _gameController._game.keepAlive.remove(index);
                              }
                              _gameController.setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                    child: Text(
                      'When dead:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  ...List.generate(
                    7,
                    (index) => TableCell(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('$index'),
                          Checkbox(
                            value: _gameController._game.revive.contains(index),
                            onChanged: (toggled) {
                              if (toggled ?? false) {
                                _gameController._game.revive.add(index);
                              } else {
                                _gameController._game.revive.remove(index);
                              }
                              _gameController.setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Powered by Flutter and Flame game framework.',
            style: Theme.of(context).textTheme.caption,
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
