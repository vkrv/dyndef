Item {
	anchors.fill: context;
	clip: true;

	Image {
		source: "res/wall.jpg";
		width: 100%; height: 50%;
		fillMode: Image.Tile;

		Text {
			font.pixelSize: 42;
			anchors.fill: parent;
			verticalAlignment: Text.AlignVCenter;
			horizontalAlignment: Text.AlignHCenter;
			visible: game.active && creator.countdown > 0;
			color: "#EEEEEE";
			text: "Next wave start in " + creator.countdown + " sec.";
			opacity: visible;
			Behavior on opacity, visible { Animation { duration: 700;}}
		}		
	}

	Rectangle {
		id: gameOver;
		anchors.fill: parent;
		color: "#B71C1C";
		opacity: visible ? 0.7 : 0;
		visible: false;
		z: visible ? 100 : -10;

		Text {
			color: "white";
			anchors.centerIn: parent;
			font.pixelSize: 64;
			text: "GEIMOVA";
			HoverMixin { cursor: "pointer"; }
			onClicked: { gameOver.visible = false; }
		}

		Behavior on opacity, visible { Animation { duration: 1600; }}
	}

	Rectangle {
		color: "#dfe2a6";
		width: 100%;
		height: 50%;
		y: 50%;
		ColorInput {
			z: 4;
			onColorChanged: {
				this.parent.color = value;
			}
		}
	}

	Text {
		z: 1; x: 10; y: 10;
		color: hover.value ? "#CDDC39" : "white";
		font.pixelSize: 30;
		text: game.active ? "RESTART" : "START";
		property HoverMixin hover: HoverMixin { cursor: "pointer"; }
		onClicked: { game.start(); }
		Behavior on color { Animation {duration: 500;}}
	}


	Image {
		source: "res/heart.png";
		x: 100% - width - 10;
		y: 10;

		Text {
			font.pixelSize: 42;
			color: "white";
			y: 100%;
			anchors.horizontalCenter: parent.horizontalCenter;
			text: brain.health;
		}
	}

	Repeater {
		id: game;
		width: 100%;
		height: 200;
		y: 50% - 120;
		property bool active;
		property int level;
		property bool lost: brain.health <= 0;


		start: {
			log("restart")
			this.model.clear();
			creator.interval = 1000;
			creator.countdown = 5;
			brain.health = 100;
			this.active = true;
		}

		onCountChanged: {
			log("onCountChanged", value)
		}

		model: ListModel { }

		Timer {
			id: creator;
			interval: 1000;
			running: game.active && !game.lost;
			repeat: true;
			triggeredOnStart: true;
			property int countdown: 5;

			onTriggered: {
				log("creator onTriggered", this.countdown, this.interval)
				if(this.countdown > 0) {
					--this.countdown
					return
				}

				this.interval = Math.floor(Math.random() * 4000) + 2000
				var s = Math.floor(Math.random() * 60) + 70
				var y = Math.floor(Math.random() * 30)
				var n = "zombie1"

				this.parent.model.append({ speed: s, name: n, y: y})
			}
		}
		delegate: Enemy {
			active: true;
			height: 181;  width: 122;
			name: model.name;
			interval: model.speed;
			state: parent.lost ? Enemy.Idle : (x > parent.width - 150 ? Enemy.Attack : Enemy.Walk);
			idx: model.index;
			y: model.y;
			z: model.y;

			onTriggered: {
				if (this.state === this.Attack)
					brain.health--;
				else if (this.state === this.Walk)
					this.x += this.speed;
			}
			onFinished: {
				if (this.state === this.Hurt) {
					this.state = this.Walk
				} else if (this.state === this.Dead) {
					this.parent.model.remove(this.idx)
				}
			}

			function discard() {
				log("discard called", this.idx)
//				this.stop();
				_globals.core.Item.prototype.discard.apply(this)
			}
		}

		Image {
			id: brain;
			property int health: 100;
			source: "res/brain.png";
			x: (health !== 0 && game.active) ? 100% - width / 2 : 100%;
			Behavior on x { Animation { duration: 600; }}

			onHealthChanged: { if (!value) gameOver.visible = true; }
		}
	}
}
