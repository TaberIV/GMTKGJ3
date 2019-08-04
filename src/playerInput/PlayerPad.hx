package playerInput;

import hxd.Pad;
import input.PadController;

/**
	Implements Gamepad input for the Player.
**/
class PlayerPad extends PadController implements PlayerController {
	public var jumpDown(get, null):Bool;
	public var jumpPressed(get, null):Bool;

	function get_jumpDown() {
		return pad.isDown(Pad.DEFAULT_CONFIG.A);
	}

	function get_jumpPressed() {
		return pad.isPressed(Pad.DEFAULT_CONFIG.A);
	}

	private override function get_xAxis() {
		var xAxis = super.get_xAxis();

		if (xAxis == 0) {
			if (pad.isDown(Pad.DEFAULT_CONFIG.dpadLeft)) {
				xAxis -= 1;
			}
			if (pad.isDown(Pad.DEFAULT_CONFIG.dpadRight)) {
				xAxis += 1;
			}
		}

		return xAxis;
	}
}
