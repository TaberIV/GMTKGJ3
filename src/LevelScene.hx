import h2d.Scene;
import entity.*;
import entities.*;
import level.*;

class LevelScene extends Scene {
	private var game:Game;
	private var level:Level;
	private var camera:Camera;

	private var index:Int;

	public function new(game:Game, index:Int) {
		super();
		this.game = game;
		this.index = index;

		buildLevel(index);
	}

	private function buildLevel(index:Int) {
		// Load level data from CastleDb
		var levelData = Data.levels.all[index];

		// Find layer for game entities
		var levelLayer = 1;
		for (i in 0...levelData.layers.length) {
			if (levelData.layers[i].name == "level") {
				levelLayer = i;
				break;
			}
		}

		// Build level
		level = new Level(Data.levels, index, this, levelLayer);
		camera = new Camera(level, width, height, 2);
		camera.update(0);

		final tileSize = levelData.props.tileSize;

		var entMap = new Map<Data.EntityKind, Array<Entity>>();
		for (ent in levelData.entities) {
			var inst:Entity = null;

			switch ent.kindId {
				case player:
					inst = new Player(level, ent.x * tileSize, ent.y * tileSize, ent.id.toString());
					camera.entity = inst;
			}

			// Add inst to map
			var a = entMap.get(ent.kindId);
			if (a == null) {
				a = new Array();
				entMap.set(ent.kindId, a);
			}

			a.push(inst);
		}

		// Add triggers to level
		for (t in levelData.triggers) {
			var nt = Trigger.levelTrigger(level, t.x, t.y, t.width, t.height, tileSize);
			switch (t.action) {
				case NextLevel(_):
					nt.onActorExit = function(a) {
						trace("Exit");
						if (a.col.xMin >= nt.xMax)
							game.setLevel(index + 1);
					};
				case RefreshJump:
					nt.onActorEnter = function(player) {
						if (Std.downcast(player, Player) != null) {
							Std.downcast(player, Player).refreshJump();
						}
					}
			}
		}

		// Build level properties
		var colMap = new Map<String, Level.LevelObject>();
		colMap.set("full", Solid.levelSolid);
		level.buildProperty("collision", colMap);
		Solid.levelSolid(level, -1, 0, 1, height, tileSize);
	}

	public function update(dt:Float) {
		if (hxd.Key.isPressed(hxd.Key.R)) {
			buildLevel(index);
		}

		camera.update(dt);
		level.update(dt);
	}
}
