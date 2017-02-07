Item {
	anchors.fill: context;
	clip: true;

	Image {
		source: "res/wall2.jpg";
		width: 100%; height: 50%;
		fillMode: Image.Tile;			
	}

	Rectangle {
		// source: "res/grass.jpg";
		// fillMode: Image.Tile;
		color: "#EDEDED";
		width: 100%;
		height: 50%;
		y: 50%;
	}

	WebItem {
		width: 120;
		height: 42;
		radius: 21;
		color: hover ? "green" : "blue";
		border.width: 1;
		border.color: "white";
		z: 1;

		property TextMixin text: TextMixin {
			color: "white";
			verticalAlignment: Text.AlignVCenter;
			horizontalAlignment: Text.AlignHCenter;
			text: "Start";
		}

		onClicked: {
			if (!zombieGame.active) {
				zombieGame.start();
			}
		}
	}

	Repeater {
		id: zombieGame;
		width: 100%;
		height: 200;
		y: 50% - 120;
		property bool active;
		property bool eaten: brain.health === 0;

		start: {
			brain.health = 100;
			zombieGame.model.clear();
			zombieGame.active = true;
		}

		onCountChanged: {
			log("onCountChanged", value)
			if (value === 0)
				this.active = false;
		}

		model: ListModel { }

		Timer {
			id: creator;
			interval: 3000;
			running: zombieGame.active && !zombieGame.eaten;
			repeat: true;
			triggeredOnStart: true;

			onTriggered: {
				this.interval = Math.floor(Math.random() * 400) + 2000
				var s = Math.floor(Math.random() * 4) + 4
				var n = Math.random() > 0.5 ? "zombie2" : "zombie1"
				log ("timer", this.interval, s, n)

				this.parent.model.append({ speed: s, name: n})
			}
		}
		delegate: Enemy {
			active: true;
			walking: parent.eaten || (x < (parent.width - 150));
			transform.rotateY: parent.eaten ? -180 : 0;
			height: 181;  width: 122;
			name: model.name;
			property int speed: model.speed;
			state: walking ? "w" : "a";
			x: -width; z: 5;
			property int idx: model.index;

			onIdxChanged: {
				if (!this.originalIdx)
					this.originalIdx = value
				log ("new index", this.originalIdx, value)
			}

			onXChanged: {
				if ((value < -this.width) && zombieGame.eaten && !this.drag.pressed) {
					log("remove zombie", this.originalIdx, this.idx, this._local['model'])
					this.stop();
					this.parent.model.remove(this.idx);
				}
			}
			onTriggered: {
				if (!this.walking)
					brain.health--;
				else
					this.x += (zombieGame.eaten ? -this.speed : this.speed);
			}

			function discard() {
				log("discard called")
				// if (this._interval) {
				// 	clearInterval(this._interval);
				// 	this._interval = undefined;
				// }
			}
		}

		Image {
			id: brain;
			property int health: 100;
			source: "res/brain.png";
			x: (health !== 0 && zombieGame.active) ? 100% - width / 2 : 100%;
			Behavior on x { Animation { duration: 600; }}

			Rectangle {
				y: 100%;
				color: parent.health > 50 ? "green" : (parent.health > 20 ? "yellow" : "red");
				height: 4;
				width: parent.health * parent.width / 200;
			}
		}
	}
}
