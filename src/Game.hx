import hxd.App;
import hxd.Res;

class Game extends App {
	var level:LevelScene;

	override function init():Void {
		Res.initEmbed();
		Data.load(Res.data.entry.getText());
		setLevel(0);
	}

	public function setLevel(index:Int):Void {
		this.level = new LevelScene(this, index);
		setScene(level);
	}

	override function update(dt:Float):Void {
		if (level != null) {
			level.update(dt);
		}
	}

	static function main():Void {
		new Game();
	}
}
