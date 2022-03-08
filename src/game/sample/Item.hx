package sample;

class Item extends Entity {
	public static var ALL : Array<Item> = [];

	public function new(d:Entity_Item) {
		super(0,0);

		ALL.push(this);
		setPosPixel( d.pixelX, d.pixelY );
		frictX = 0.84;
		frictY = 0.96;
		gravityPow = 0.5;
		dy = -0.2;

		var t = Assets.worldData.getEnumTile(d.f_type);
		t.setCenterRatio(0.5,1);
		new h2d.Bitmap(t, spr);
		spr.set(Assets.gameTiles, D.gameTiles.empty);
	}


	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}


	override function onLand(cHei:Float) {
		super.onLand(cHei);
		dy = -0.2;
	}


	override function fixedUpdate() {
		super.fixedUpdate();
		if( SamplePlayer.ME.distCase(this)<=1 ) {
			// Pick
			fx.dotsExplosionExample(centerX, centerY, 0xffcc00);
			destroy();
		}
	}
}