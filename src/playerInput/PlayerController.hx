package playerInput;

/**
	The base class for different input methods for the Player.
**/
interface PlayerController {
	public var xAxis(get, null):Float;
	public var yAxis(get, null):Float;

	public var jumpDown(get, null):Bool;
	public var jumpPressed(get, null):Bool;

	public function destroy():Void;
}
