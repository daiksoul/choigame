import 'package:choi_game/game/util.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Circle extends BodyComponent with ContactCallbacks {
  final double radius;
  final Vector2 _position;
  bool tagged = false;
  Vector2? initialVelocity;
  late SpriteComponent _sprite;
  bool _appliedVelocity = false;

  Circle(this.radius, this._position, [this.initialVelocity]);
  Circle.fromParent(Circle a, Circle b)
      : radius = a.radius + 20,
        _position = (a.position + b.position) / 2,
        initialVelocity = (a.body.linearVelocity + b.body.linearVelocity) / 2;
  // initialVelocity = Vector2(0, -(a.radius + 20) * 100000);

  @override
  void onRemove() {
    world.destroyBody(body);
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await loadImage('assets/images/$radius.png');
    _sprite = SpriteComponent(
      sprite: Sprite(sprite),
      size: Vector2.all(radius * 2),
      anchor: Anchor.center,
    );
    add(_sprite);
  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = radius;

    final fixDef = FixtureDef(
      shape,
      // restitution: 0.5,
      density: 1,
      friction: 0.01,
    );

    final bodDef = BodyDef(
      userData: this,
      angularDamping: 0.8,
      linearDamping: 0,
      position: _position,
      type: BodyType.dynamic,
    );

    return world.createBody(bodDef)..createFixture(fixDef);
  }

  @override
  void update(double dt) {
    if (!_appliedVelocity) {
      body.applyLinearImpulse(initialVelocity ?? Vector2(0, -10000));
      _appliedVelocity = true;
    }
    super.update(dt);
  }

  @override
  void Function(Object other, Contact contact)? get onBeginContact =>
      (other, contact) {
        if (other is Circle) {
          if (other.radius == radius &&
              !tagged &&
              !other.tagged &&
              radius < 140) {
            other.tagged = true;
            tagged = true;
            game.add(Circle.fromParent(other, this));
          }
        }
      };
}
