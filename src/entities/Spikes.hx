package entities;

import entity.Actor;
import level.Level;
import entity.Trigger;

class Spikes extends Trigger {
	public static function levelSpikeGen(top:Int, bottom:Int, left:Int, right:Int) {
		return function(level:Level, x:Int, y:Int, w:Int, h:Int, tileSize:Int) {
			var t = new Trigger(level, x * tileSize + left, y * tileSize + top, w * tileSize - right, h * tileSize - bottom);
			t.onActorEnter = function(a:Actor) a.destroy();
			return t;
		}
	}
}
