import 'dart:async';
import 'dart:math';

import 'package:choi_game/game/circle.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class MainGame extends Forge2DGame {
  MainGame() : super(zoom: 20, gravity: Vector2(0, 60.0), world: ChoiWorld()) {
    // camera = CameraComponent.withFixedResolution(
    //     width: 1920, height: 1080, world: world);
    // debugMode = true;
  }
}

class ChoiWorld extends Forge2DWorld
    with TapCallbacks, HasGameReference<MainGame> {
  double cooldown = 0;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    game.add(Wall(Vector2(0, 0), Vector2(0, game.canvasSize.y)));
    game.add(Wall(Vector2(game.canvasSize.x, 0), game.canvasSize.xy));
    game.add(Wall(Vector2(0, game.canvasSize.y), game.canvasSize.xy));
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (cooldown <= 0) {
      double rad = Random().nextInt(3) * 20 + 20;
      game.add(Circle(rad, Vector2(event.canvasPosition.x, rad),
          Vector2(0, rad * rad * 100000)));
      cooldown = 0.5;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (cooldown > 0) {
      cooldown -= dt;
    }

    List<Component> t = [];
    game.children.query<Circle>().forEach((element) {
      if (element.tagged) {
        t.add(element);
      }
    });

    for (final e in t) {
      game.remove(e);
    }
  }
}

class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;
  final double strokeWidth;

  Wall(this.start, this.end, {double? strokeWidth})
      : strokeWidth = strokeWidth ?? 1;

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      userData: this, // To be able to determine object in collision
      position: Vector2.zero(),
    );
    paint.strokeWidth = strokeWidth;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

List<Wall> createBoundaries(Forge2DGame game, {double? strokeWidth}) {
  final visibleRect = game.camera.visibleWorldRect;
  final topLeft = visibleRect.topLeft.toVector2();
  final topRight = visibleRect.topRight.toVector2();
  final bottomRight = visibleRect.bottomRight.toVector2();
  final bottomLeft = visibleRect.bottomLeft.toVector2();

  return [
    Wall(topLeft, topRight, strokeWidth: strokeWidth),
    Wall(topRight, bottomRight, strokeWidth: strokeWidth),
    Wall(bottomLeft, bottomRight, strokeWidth: strokeWidth),
    Wall(topLeft, bottomLeft, strokeWidth: strokeWidth),
  ];
}
