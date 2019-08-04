package entities;

import hxd.Res;
import entity.Actor;
import entity.Solid;
import draw.Sprite;
import collision.Collider;
import util.Calc.*;
import playerInput.PlayerController;
import playerInput.PlayerAdditive;
import playerInput.PlayerKeyboard;

class Player extends Actor {
	final width:Int = 16;
	final height:Int = 16;

	// Movement parameters
	private var moveSpeed:Float = 160;
	private var accelTime:Float = 0.3;
	private var deccelTime:Float = 0.2;

	private var jumpDist:Float = 112;
	private var jumpHeight:Float = 102;
	private var airMobility:Float = 0.3;
	private var jumpBoost:Float = 32;

	private var bounceDecay:Float = 0.9;
	private var stopMin:Float = 300;
	private var bounceMin:Float = 5;

	// Calculated movement values
	private var moveForce:Float;
	private var friction:Float;
	private var runReduce:Float;

	private var jumpVelocity:Float;
	private var gravity:Float;

	// Movement state
	private var velX:Float = 0;
	private var velY:Float = 0;

	private var jumpCharge:Bool = true;
	private var bounce:Bool = false;

	// Collision state
	private var colX:Solid;
	private var colY:Solid;
	private var ride:Solid;
	private var onGround:Bool;

	// Refs
	private var controller:PlayerController;
	private var ballSpr:Sprite;
	private var walkSpr:Sprite;

	override public function init() {
		walkSpr = new Sprite(this, Res.img.player.purp);
		ballSpr = new Sprite(this, Res.img.player.purpBall);
		spr = walkSpr;

		col = Collider.fromSprite(this, 10, 0, 10, 10);

		// Create input controller
		controller = new PlayerAdditive();

		// Determine movement values
		moveForce = moveSpeed / accelTime;
		friction = moveSpeed / deccelTime;
		runReduce = friction / 5;

		var horSpeed = moveSpeed + jumpBoost;
		jumpVelocity = -4 * jumpHeight * horSpeed / jumpDist;
		gravity = 8 * jumpHeight * horSpeed * horSpeed / (jumpDist * jumpDist);
	}

	public override function update(dt:Float):Void {
		// Set frame constants
		onGround = checkGrounded();

		if (!onGround) {
			if (Math.abs(velY) < bounceMin || Math.abs(velY) < stopMin && !controller.jumpDown) {
				bounce = false;
			}

			if (Math.abs(velY) > stopMin) {
				bounce = true;
			}
		}

		// Acceleration
		var accX = accelerateX(dt);
		var accY = accelerateY(dt);

		// Move
		moveX(calcMovement(velX, dt, accX), onColX);
		moveY(calcMovement(velY, dt, accY), onColY);

		if (ride != null && !isRiding(ride)) {
			releaseRide();
		}

		// Pre-draw
		spr.dir = sign(velX);

		if (!onGround) {
			spr = ballSpr;
			ballSpr.visible = true;
			walkSpr.visible = false;
			ballSpr.x = x;
			ballSpr.y = y;
		} else {
			spr = walkSpr;
			walkSpr.visible = true;
			ballSpr.visible = false;
			walkSpr.x = x;
			walkSpr.y = y;
		}
	}

	private function accelerateX(dt:Float):Float {
		var accX:Float = 0;
		var mult:Float = onGround ? 1 : airMobility;

		// Friction
		if ((onGround || !Math.isFinite(friction)) && sign(controller.xAxis) != sign(velX)) {
			velX = approach(velX, 0, friction * dt);
		}

		// Reduce back if over run speed
		if (sign(controller.xAxis) == sign(velX) && Math.abs(velX) > moveSpeed) {
			if (onGround) {
				velX = approach(velX, sign(velX) * moveSpeed, runReduce * dt);
			}
		} else if (controller.xAxis != 0) {
			velX = approach(velX, moveSpeed * sign(controller.xAxis), moveForce * mult * dt);
		}

		return accX;
	}

	private function accelerateY(dt:Float):Float {
		var accY = applyGravity(dt);

		// Jump
		if (onGround && jumpCharge && controller.jumpPressed) {
			jumpCharge = false;
			bounce = true;
			velY = jumpVelocity;

			// Jump boost
			if (Math.abs(velX) > moveSpeed && sign(controller.xAxis) == sign(velX)) {
				velX = sign(velX) * Math.max(Math.abs(velX), moveSpeed + jumpBoost);
			} else {
				velX += sign(controller.xAxis) * jumpBoost;
			}

			accY = 0;
		}

		return accY;
	}

	private function applyGravity(dt:Float):Float {
		velY += gravity * dt;

		return gravity;
	}

	private function checkGrounded() {
		if (col == null || bounce) {
			return false;
		}

		return col.collideAt(x, y + 1);
	}

	private function onColX(solid:Solid) {
		velX = solid.velX + (bounce ? -velX * bounceDecay : 0);
		colX = solid;
	}

	private function onColY(solid:Solid) {
		velY = bounce || velY < 0 ? -velY * bounceDecay : 0;

		colY = solid;
	}

	public override function isRiding(solid:Solid):Bool {
		if (bounce) {
			return false;
		}

		var riding = col.intersectsAt(solid.col, x, y + 1);

		if (riding && ride != solid) {
			velX -= solid.velX;
			ride = solid;
		}

		return riding;
	}

	public function refreshJump() {
		jumpCharge = true;
	}

	public function releaseRide() {
		velX += ride.velX;
		velY += ride.velY;
		ride = null;
	}

	override function destroy() {
		super.destroy();
		controller = null;
	}
}
