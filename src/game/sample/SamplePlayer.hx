package sample;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/

class SamplePlayer extends Entity {
	public static var ME : SamplePlayer = null;
	var ca : ControllerAccess<GameAction>;
	var walkSpeed = 0.;


	public function new() {
		super(5,5);

		ME = this;

		// Start point using level entity "PlayerStart"
		var start = level.data.l_Entities.all_PlayerStart[0];
		if( start!=null )
			setPosCase(start.cx, start.cy);

		// Misc inits
		frictX = 0.84;
		frictY = 0.94;

		// Camera tracks this
		camera.trackEntity(this, true);
		camera.clampToLevelBounds = true;

		// Init controller
		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;

		spr.set(Assets.hero, D.hero.idle);
	}


	override function dispose() {
		super.dispose();
		if( ME==this )
			ME = null;
		ca.dispose(); // don't forget to dispose controller accesses
	}


	override function onLand(cHei:Float) {
		super.onLand(cHei);
		var heiPow = M.fclamp( cHei/5, 0, 1 ) ;
		if( gameFeelFx )
			setSquashY(0.9 - 0.4*heiPow);

		ca.rumble(0.25*heiPow, 0.06);
	}


	/**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/
	override function preUpdate() {
		super.preUpdate();

		walkSpeed = 0;
		if( onGround )
			cd.setS("recentlyOnGround",0.1); // allows "just-in-time" jumps


		// Jump
		if( cd.has("recentlyOnGround") && ca.isPressed(Jump) ) {
			dy = -0.85;
			if( gameFeelFx )
				setSquashX(0.5);
			cd.unset("recentlyOnGround");
			// if( gameFeelFx )
			// 	fx.dotsExplosionExample(centerX, centerY, 0xffcc00);
			ca.rumble(0.05, 0.06);
		}

		// Walk
		if( ca.getAnalogDist(MoveX)>0 ) {
			// As mentioned above, we don't touch physics values (eg. `dx`) here. We just store some "requested walk speed", which will be applied to actual physics in fixedUpdate.
			walkSpeed = ca.getAnalogValue(MoveX); // -1 to 1
		}
	}


	override function fixedUpdate() {
		// Apply requested walk movement
		if( walkSpeed!=0 ) {
			var speed = 0.045;
			dx += walkSpeed * speed;
		}

		super.fixedUpdate();
	}
}