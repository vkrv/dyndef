AnimatedSprite {
	property enum state { Idle, Walk, Attack, Hurt, Dead};
	property int health: 100;
	property int speed: 5;
	width: 121; height: 181;
	duration: 480;
	totalFrames: 6;
//	repeat: state === Enemy.Walk || state === Enemy.Attack;
	property bool active;
	running: active && !drag.pressed;
	property string name;
	HoverMixin { cursor: "move"; }
	property DragMixin drag: DragMixin { direction: DragMixin.Horizontal; }
	property int idx;
	onClicked: {
		if (this.drag.moved)
			this.drag.moved = false;
		else
			this.health -= 30;
	}

	onHealthChanged: {
		log("onHealthChanged", value)
		if (value > 0) {
			this.state = this.Hurt
			return
		}

		this.state = Enemy.Dead
	}

	Rectangle {
		y: -2;
		height: 2;
		width: 50;
		visible: parent.health < 100;
		color: "#EEEEEE";
		x: 35;

		Rectangle {
			height: 2; width: parent.parent.health / 2;
			color: parent.parent.health > 40 ? "#66BB6A" : "red";
		}
	}

	onStateChanged: {
		switch(value) {
			case this.Idle:
				this.repeat = true;
				this.width = 117;
				this.source = "res/s" + 'zombie1' + "i.png";
				this.totalFrames = 4;
				break;
			case this.Attack:
				this.repeat = true;
				this.width = 122;
				this.totalFrames = 6;
				this.source = "res/s" + 'zombie1' + "a.png";
				break;
			case this.Walk:
				this.repeat = true;
				this.width = 122;
				this.totalFrames = 6;
				this.source = "res/s" + 'zombie1' + "w.png";
				break; 
			case this.Hurt:
				this.repeat = false;
				this.width = 136;
				this.totalFrames = 5;
				this.source = "res/s" + 'zombie1' + "h.png";
				break;
			case this.Dead:
				this.repeat = false;
				this.width = 136;
				this.totalFrames = 15;
				this.source = "res/s" + 'zombie1' + "h.png";
				break;
		}
		this.restart();
	}

	Behavior on x { Animation { duration: parent.drag.pressed || parent.active ? 0 : parent.duration / parent.totalFrames; }}
}