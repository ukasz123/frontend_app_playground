import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:hex_game_of_life/hexagonal_grid.dart';

class GameOfLife extends FlameGame
    with HasTappables, ScrollDetector, ScaleDetector {
  GameOfLife({int boardSize = 10, Set<int>? keepAlive, Set<int>? revive})
      : _boardSize = boardSize {
    if (keepAlive != null) {
      this.keepAlive = keepAlive;
    }
    if (revive != null) {
      this.revive = revive;
    }
  }
  int _boardSize;

  Map<Hex, bool> _hexMap = {};

  Timer? _timer;

  late Point<num> hexSize;

  late HexLayout hexLayout;

  Set<int> keepAlive = {2};

  Set<int> revive = {2};

  @override
  Color backgroundColor() => _backgroundColor.withOpacity(0.2);

  bool get running => _timer?.isRunning() ?? false;

  void reset() {
    _timer?.stop();
    _resetBoard();
  }

  void start() {
    _timer?.start();
  }

  void stop() {
    _timer?.stop();
  }

  set boardSize(int boardSize) {
    _boardSize = boardSize;
    _resetBoard();
  }

  void _resetBoard() {
    // clear all existing components
    removeAll(children);
    _hexMap = {};

    // init state
    for (int q = -_boardSize; q <= _boardSize; q++) {
      for (int r = -_boardSize; r <= _boardSize; r++) {
        var hex = Hex(q, r);
        _hexMap[hex] = false;
        hex = Hex(q, -r);
        _hexMap[hex] = false;
      }
    }
    final zero = Hex(0, 0);
    _hexMap.removeWhere((hex, _) => hex.distance(zero) > _boardSize);

    // populate children
    final screenSize = size;
    _calculateHexSize(screenSize);
    _populateComponents();
  }

  @override
  Future<void>? onLoad() {
    camera.viewport = FixedResolutionViewport(size);
    camera.setRelativeOffset(Anchor.center);
    camera.speed = 100;

    _timer = Timer(
      0.67,
      onTick: _updateBoardState,
      repeat: true,
      autoStart: false,
    );

    _resetBoard();
    return super.onLoad();
  }

  void _calculateHexSize(Vector2 screenSize) {
    final pairs = _boardSize ~/ 2;
    final remainder = _boardSize % 2;

    final sides = pairs * 1.75 + remainder;

    final side = max(screenSize[1] / (sides * 4), 10.0);
    // final side = 15.0;
    hexSize = HexLayout.getOrientPointySizeFromSymmetricalSize(side);
    hexLayout = HexLayout.orientPointy(
        hexSize, Point(screenSize[0] / 2, screenSize[1] / 2));

    final boardWidth = Hex(_boardSize, 0).toPixel(hexLayout);
    final boardWidth1 = Hex(-_boardSize, 0).toPixel(hexLayout);

    camera.zoom = size.x / (boardWidth.x - boardWidth1.x) * 0.9;
    clampZoom();
    camera.moveTo(Hex(0, 0).toPixel(hexLayout).asVector2);

    camera.snap();
  }

  void _populateComponents() {
    for (var hex in _hexMap.keys) {
      add(HexComponent(hex, hexSize, hexLayout));
    }
  }

  void clampZoom() {
    camera.zoom = camera.zoom.clamp(0.05, 3.0);
  }

  static const zoomPerScrollUnit = 0.02;

  @override
  void onScroll(PointerScrollInfo info) {
    camera.zoom += info.scrollDelta.game.y.sign * zoomPerScrollUnit;
    clampZoom();
  }

  late double startZoom;

  @override
  void onScaleStart(info) {
    startZoom = camera.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      camera.zoom = startZoom * currentScale.y;
      clampZoom();
    } else {
      camera.translateBy(-info.delta.game);
      camera.snap();
    }
  }

  @override
  void update(double dt) {
    _timer?.update(dt);
    super.update(dt);
  }

  void _updateBoardState() {
    final newBoard = <Hex, bool>{};
    for (var hex in _hexMap.keys) {
      var aliveNeighbours = 0;
      for (var i = 0; i < 6; i++) {
        final neighhbour = hex.neighbor(i);
        if (_hexMap[neighhbour] ?? false) {
          aliveNeighbours += 1;
        }
      }
      newBoard[hex] = _nextState(_hexMap[hex]!, aliveNeighbours);
    }
    _hexMap = newBoard;
  }

  bool _nextState(bool currentState, int aliveNeighbours) {
    if (currentState) {
      return keepAlive.contains(aliveNeighbours);
    } else {
      return revive.contains(aliveNeighbours);
    }
  }
}

class HexComponent extends Component {
  final Hex hex;
  final Point<num> hexSize;
  final HexLayout hexLayout;

  HexComponent(this.hex, this.hexSize, this.hexLayout);

  late HexInteriorComponent _interiorHexComponent;

  @override
  Future<void>? onLoad() {
    final position = hex.toPixel(hexLayout);
    add(
      PolygonComponent(
        hex.corners(hexLayout).reversed.map((e) => e.asVector2).toList(),
        position: position.asVector2,
        anchor: Anchor.center,
        paint: Paint()
          ..color = (hex.q == 0 && hex.r == 0)
              ? const Color.fromARGB(255, 196, 122, 43)
              : _borderColor,
      ),
    );
    _interiorHexComponent = HexInteriorComponent(
      hex,
      hexLayout,
    );
    add(_interiorHexComponent);
    // add(TextComponent(
    //   text: '[${hex.q},${hex.r}]',
    //   position: position.asVector2,
    //   anchor: Anchor.center,
    // ));
    return super.onLoad();
  }
}

const _backgroundColor = Color(0xfff0f0f0);
const _borderColor = Color(0xff606060);

class HexInteriorComponent extends PolygonComponent with Tappable {
  final Hex hex;
  final HexLayout hexLayout;
  HexInteriorComponent(this.hex, this.hexLayout)
      : super(
          hex.corners(hexLayout).reversed.map((e) => e.asVector2).toList(),
          position: hex.toPixel(hexLayout).asVector2,
          scale: Vector2.all(0.96),
          anchor: Anchor.center,
          paint: Paint()..color = _backgroundColor,
        );

  @override
  void update(double dt) {
    final gameOfLife = findParent<GameOfLife>();

    final hexSet = gameOfLife?._hexMap[hex] ?? false;
    paint.color = hexSet
        ? _borderColor
        : ((hex.q == 0 && hex.r == 0) ? const Color.fromARGB(128, 196, 122, 43) : _backgroundColor);
    super.update(dt);
  }

  @override
  bool onTapUp(info) {
    final isSet = gameState[hex]!;
    gameState[hex] = !isSet;
    return true;
  }
}

extension ToVector2Extension on Point<num> {
  Vector2 get asVector2 => Vector2(x.toDouble(), y.toDouble());
}

extension GetBoardStateExt on Component {
  Map<Hex, bool> get gameState {
    final game = findParent<GameOfLife>()!;

    return game._hexMap;
  }
}
