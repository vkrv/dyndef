AnimatedSprite {
	property string state;//: "w";
	property int health: 10;
	width: 232; height: 390;
	duration: 480;
	totalFrames: 6;
	repeat: true;
	property bool active;
	property bool walking;
	running: active && !drag.pressed;
	property string name;
	source: "res/s" + name + state + ".png";
	z: drag.pressed ? 10 : 0;
	HoverMixin { cursor: "move"; }
	property DragMixin drag: DragMixin { direction: DragMixin.Horizontal; }

	Behavior on x { Animation { duration: parent.drag.pressed || parent.active ? 0 : parent.duration / parent.totalFrames; }}
}