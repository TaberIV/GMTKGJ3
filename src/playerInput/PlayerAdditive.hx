package playerInput;

class PlayerAdditive implements PlayerController {
	public var xAxis(get, null):Float;
	public var yAxis(get, null):Float;

	public var jumpDown(get, null):Bool;
	public var jumpPressed(get, null):Bool;

	private var key:PlayerKeyboard;
	private var pad:PlayerPad;

	private function get_xAxis() {
		return util.Calc.absMax(key.xAxis, pad.xAxis);
	}

	private function get_yAxis() {
		return util.Calc.absMax(key.xAxis, pad.xAxis);
	}

	private function get_jumpDown() {
		return key.jumpDown || pad.jumpDown;
	}

	private function get_jumpPressed() {
		return key.jumpPressed || pad.jumpPressed;
	}

	public function new() {
		key = new PlayerKeyboard();
		pad = new PlayerPad();
	}
}
