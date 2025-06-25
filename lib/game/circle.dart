import 'package:choi_game/game/util.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Circle extends BodyComponent with ContactCallbacks {
  final double radius;
  final Vector2 _position;
  bool tagged = false;
  Vector2? initialVelocity;
  late SpriteComponent _sprite;

  Circle(this.radius, this._position, [this.initialVelocity]);
  Circle.fromParent(Circle a, Circle b)
      : radius = a.radius + 20,
        _position = (a.position + b.position) / 2,
        initialVelocity = (a.body.linearVelocity + b.body.linearVelocity) / 2 {
    Future.delayed(Duration.zero, () {
      a.removeFromParent();
      b.removeFromParent();
      // game.remove(a);
      // game.remove(b);
    });
  }

  @override
  void onRemove() {
    world.destroyBody(body);
    // try {
    //   if (!_sprite.isRemoving && _sprite.parent != null) {
    // _sprite.removeFromParent();
    //   }
    // } catch (e, v) {
    //   print(e);
    //   print(v);
    // }
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final sprite = await loadImage('assets/images/$radius.png');
    // renderBody = false;
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
      density: 0.01,
      friction: 0.1,
    );

    final bodDef = BodyDef(
      userData: this,
      angularDamping: 0.8,
      // linearDamping: 0,
      position: _position,
      type: BodyType.dynamic,
    );

    Future.delayed(Duration.zero,
        () => body.applyLinearImpulse(initialVelocity ?? Vector2(0, 0)));

    return world.createBody(bodDef)..createFixture(fixDef);
  }

  @override
  void update(double dt) {
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
            // other.removeFromParent();
            // removeFromParent();
            // body.applyLinearImpulse(Vector2(0, -radius * 1000.0));
            // game.add(Circle(radius + 20, (_position + other._position) / 2));
            game.add(Circle.fromParent(other, this));
          }
          // if (other.radius == radius) {
          //   print(
          //       " A ${other.isRemoved}(${other.isRemoving}) : $isRemoved($isRemoving)");
          //   print("${other.hashCode} : $hashCode");
          //   other.removeFromParent();
          //   removeFromParent();
          //   print(
          //       " B ${other.isRemoved}(${other.isRemoving}) : $isRemoved($isRemoving)");
          // }
        }
      };
}
