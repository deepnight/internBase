package sample;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/

class SamplePlayer extends Entity {
	var ca : ControllerAccess<GameAction>;
	var walkSpeed = 0.;
	var minFallY = 0.;

	// This is TRUE if the player is not falling
	var onGround(get,never) : Bool;
		inline function get_onGround() return !destroyed && dy==0 && yr==1 && level.hasCollision(cx,cy+1);


	public function new() {
		super(5,5);

		// Start point using level entity "PlayerStart"
		var start = level.data.l_Entities.all_PlayerStart[0];
		if( start!=null )
			setPosCase(start.cx, start.cy);

		// Misc inits
		frictX = 0.84;
		frictY = 0.94;
		minFallY = cy+yr;

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
		ca.dispose(); // don't forget to dispose controller accesses
	}


	override function setPosCase(x:Int, y:Int) {
		super.setPosCase(x, y);
		minFallY = cy+yr;
	}

	override function setPosPixel(x:Float, y:Float) {
		super.setPosPixel(x, y);
		minFallY = cy+yr;
	}


	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();

		// Right collision
		if( xr>0.8 && level.hasCollision(cx+1,cy) )
			xr = 0.8;

		// Left collision
		if( xr<0.2 && level.hasCollision(cx-1,cy) )
			xr = 0.2;
	}


	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();

		// Land on ground
		if( yr>1 && level.hasCollision(cx,cy+1) ) {
			var heiPow = M.fclamp( ( cy+yr - minFallY ) / 5, 0, 1 ) ;
			if( gameFeelFx )
				setSquashY(0.9 - 0.5*heiPow);
			dy = 0;
			yr = 1;
			ca.rumble(0.2, 0.06);
			onPosManuallyChangedY();
		}

		// Ceiling collision
		if( yr<0.6 && level.hasCollision(cx,cy-1) )
			yr = 0.6;
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
			if( gameFeelFx )
				fx.dotsExplosionExample(centerX, centerY, 0xffcc00);
			ca.rumble(0.05, 0.06);
		}

		// Walk
		if( ca.getAnalogDist(MoveX)>0 ) {
			// As mentioned above, we don't touch physics values (eg. `dx`) here. We just store some "requested walk speed", which will be applied to actual physics in fixedUpdate.
			walkSpeed = ca.getAnalogValue(MoveX); // -1 to 1
		}
	}


	override function fixedUpdate() {
		// Reset fall Y
		if( dy<=0 || onGround )
			minFallY = cy+yr;

		// Gravity
		if( !onGround )
			dy+=0.05;

		// Apply requested walk movement
		if( walkSpeed!=0 ) {
			var speed = 0.045;
			dx += walkSpeed * speed;
		}

		super.fixedUpdate();
	}
}