﻿﻿
package code {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import sounds.*;

	/**
	 * This is our ScenePlay Object, where our gameplay should take place in.
	 */
	public class ScenePlay extends GameScene {

		/** Counts how many waves of enemies have gone by. */
		public var waveCount: int = 0;

		/** Increments how many enemies spawn each wave. */
		private var spawnIncrement: int = 0;

		/** How many enemies are currently in the scene. */
		private var enemyCounter: int = 0;

		/** Set to true when the wave has started. */
		private var waveStart: Boolean = false;

		/** Set to true when the wave has ended. */
		private var waveEnd: Boolean = true;

		/** Decrements how many enemies are spawned. */
		private var spawnDecrement: int = 5;

		/** The rate at which enemies are spawned. */
		private var spawnRate: int = 2000;

		/** The minimum amount of time the enemies are spawned at. */
		private var spawnRateMin: int = 900;

		/** Counts how many enemies are remaining in the scene. */
		public var enemiesRemainingCount: int = 0;

		/** The current number of enemies remaining in the scene. */
		private var enemyNum: int = 0;

		/** The current coin count for the player. */
		public var coinCount: int = 35;

		/** */
		//private var shakeTimer: Number = 0;
		/** How long the game should wait until spawning a new Enemy. */
		private var delaySpawn: int = 0;

		/** This is our array of Platform Objects. */
		static public var platforms: Array = new Array();

		/** This is our array of floating platform objects. */
		static public var floatingPlatforms: Array = new Array();

		/** An Array that keeps track of all of our basic enemies. */
		static public var enemies: Array = new Array();
		/** An Array that keeps track of all of our flying enemies. */
		static public var flyingEnemies: Array = new Array();
		/** An Array that keeps track of all of our tough enemies. */
		static public var toughEnemies: Array = new Array();

		/** The delay between spawning smoke particles. */
		public var smokeParticleDelay: Number = 0;
		/** A SINGLETON reference to this ScenePlay Object so other objects can see every other object in this GameScene. */
		static public var main: ScenePlay; // singleton

		/** The player object for the game. */
		public var player: Player;

		/** This is our array of Bullet Objects. */
		private var bullets: Array = new Array();

		/** This is our array of Bomb Objects. */
		private var bombs: Array = new Array();

		/** The castle object for the game. */
		public var castle: Castle;

		/** The array of particle objects. */
		private var particles: Array = new Array();

		/** The sound for shooting bullets. */
		private var shootSound: ShootSound = new ShootSound();

		/** The sound for when the bullet hits a wall. */
		private var hitSound: HitSound = new HitSound();

		/** The sound for when the player builds a tower. */
		private var buildSound: BuildSound = new BuildSound();

		/** The sound for when the player loses the game. */
		private var loseSound: LoseSound = new LoseSound();

		static public var coins: Array = new Array();

		/** Identifier variable for the build spots. */
		private var buildSpotChooser: int = 0;
		/** An Array for all of the EnemyBullet Objects. */
		private var bulletsBad: Array = new Array();

		/** The array for towers. */
		static public var towers: Array = new Array();

		/** The array for turrets. */
		static public var turrets: Array = new Array();
		/** The sound that should get played whenever any enemy dies. */
		private var enemyDieSound: EnemyDieSound = new EnemyDieSound();

		/** The sound played whenever a coin is picked up. */
		private var coinSound: CoinSound = new CoinSound();

		/** The sound played whenever the player sells a tower. */
		private var sellSound: SellSound = new SellSound();

		/** The condition that must be set to true for this GameScene to switch to a SceneLose. */
		private var gameOver: Boolean = false;

		/** The sound played when the player doesn't have enough money to purchase a tower. */
		private var notEnoughSound: NotEnoughSound = new NotEnoughSound();

		/**
		 * This is our constructor script. It loads us our level.
		 */
		public function ScenePlay() {
			// constructor code
			ScenePlay.main = this;

			hud.sellText.alpha = 0;

			loadLevel();
			spawnPlayer();
		} // ends ScenePlay

		/**
		 * Adds our EventListeners to the stage when this scene is created.
		 */
		override public function onBegin(): void {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleClick);
		} // end onBegin
		/**
		 * Removes our EventListeners to the stage when this scene is created.
		 */
		override public function onEnd(): void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleClick);
			platforms = new Array();
			floatingPlatforms = new Array();
			enemies = new Array();
			flyingEnemies = new Array();
			toughEnemies = new Array();
			towers = new Array();
			waveCount = 0;
		} // end onEnd

		/**
		 * This event-handler is called everytime the left mouse button is down.
		 * It causes the player to shoot bullets.
		 * @param e The MouseEvent that triggered this event-handler.
		 */
		private function handleClick(e: MouseEvent): void {

			spawnBullet();

		} // ends handleClick

		/**
		 * This is our update function that is called every frame! It lets our game run.
		 * @param previousScene If passed in, it allows us to save everything that happened on the scene previous to this one. (Left over from pause screen functionality.)
		 * @return This returns null every frame, unless it is time to switch scenes. Then we pass in a new GameScene Object we wish to switch to.
		 */
		override public function update(previousScene: GameScene = null): GameScene {
			trace(ScenePlay.platforms.length);
			if (player.isDead) {
				killPlayer();
				spawnPlayer();
			}
			player.update();
			updateBullets();
			spawnSmokeParticles();
			spawnEnemy(5);
			if (waveCount >= 5) {
				spawnFlyingEnemy(5);
			}
			if (waveCount >= 10) {
				spawnToughEnemy(5);
			}
			updateEnemies();
			updateCoins();
			updatePlatforms();
			updateFloatingPlatforms();
			castle.update();
			updateTowers();
			updateTurrets();
			updateBullets();
			updateBulletsBad();
			updateProjectiles();
			updateParticles();
			doCollisionDetection();
			doCameraMove();
			hud.update(this);

			if (castle.isDead) {
				//start Game Over Sequence
				//replace this later for polish
				gameOver = true;
				loseSound.play();
			}

			if (gameOver) {
				return new SceneLose();
			}

			return null
		} // ends update
		/**
		 * This loads the level
		 */
		private function loadLevel(): void {
			castle = level.castle
			ScenePlay.platforms.splice(3, 1);
			level.playerWall.alpha = 0;
		}

		/**
		 * If a player is currently valid, nothing will happen. Otherwise, this method spawns us a player at our playerSpawner location.
		 */
		private function spawnPlayer(): void {
			if (!level.player) {
				level.player = new Player();
				level.addChild(level.player);
			}
			player = level.player;
			level.player.x = level.playerSpawner.x;
			level.player.y = level.playerSpawner.y;
			/*
			if (player){
				level.pleyer.isDead = false;
			}
			*/
		}

		/**
		 * Will destroy the current player object and remove it from memory. Currently does nothing.
		 */
		private function killPlayer(): void {
			if (level.contains(player)) {
				level.removeChild(player);
				player = null;
				level.player = null;
			}

		}

		/** 
		 * Spawns a bullet from the player whenever they click the left mouse button.
		 * Also spawns a bullet from the turret for each tower.
		 */
		public function spawnBullet(turret: Turret = null): void {
			if (turret) {
				var a: Bullet = new Bullet(null, turret);
				level.addChild(a);
				bullets.push(a);
				a.lifeMax = 10;
			} else {
				var b: Bullet = new Bullet(player);
				level.addChild(b);
				bullets.push(b);
			}

		} // ends spawnBullet

		/**
		 * Function handling spawning of bombs from bomb towers.
		 */
		public function spawnBomb(turret: Turret = null): void {
			var a: Bomb = new Bomb(turret);
			level.addChild(a);
			bombs.push(a);
			a.lifeMax = 10;
		} // ends spawnBomb

		/** 
		 * Spawns a bullet from the enemy.
		 */
		public function spawnBulletBad(enemy: Enemy): void {
			//trace("spawnBulletBad FIRE!");
			var b: BulletBad = new BulletBad(enemy);
			level.addChild(b);
			bulletsBad.push(b);

		} // ends spawnBulletBad
		/**
		 * Function handling the updating of all projectiles.
		 */
		private function updateProjectiles(): void {
			// update everything:
			//bullets
			updateBullets();
			//bombs
			updateBombs();
			//enemy bullets
			updateBulletsBad();
		} // ends updateProjectiles

		/**
		 * Updates bullets for every frame.
		 */
		private function updateBullets(): void {

			// update everything:
			for (var i: int = bullets.length - 1; i >= 0; i--) {
				bullets[i].update(); // Update design pattern.

				/** If bullet is dead, remove it. */
				if (bullets[i].isDead) {
					// remove it!!

					// 1. remove the object from the scene-graph
					level.removeChild(bullets[i]);

					// 2. nullify any variables pointing to it
					// if the variable is an array,
					// remove the object from the array
					bullets.splice(i, 1);
				}
			} // ends for loop updating bullets
		} // ends updateBullets

		/**
		 * Updates bombs for every frame.
		 */
		private function updateBombs(): void {
			for (var i: int = bombs.length - 1; i >= 0; i--) {
				bombs[i].update(); // Update design pattern.

				/** If bullet is dead, remove it. */
				if (bombs[i].isDead) {
					// remove it!!

					// 1. remove the object from the scene-graph
					level.removeChild(bombs[i]);

					// 2. nullify any variables pointing to it
					// if the variable is an array,
					// remove the object from the array
					bombs.splice(i, 1);
				} // ends if
			} // ends for loop updating bullets
		} // ends updateBombs
		/**
		 * Loops through all three of our enemy arrays and calls all of their update functions.
		 */
		private function updateEnemies(): void {
			for (var i: int = ScenePlay.enemies.length - 1; i >= 0; i--) {
				ScenePlay.enemies[i].update();
				if (ScenePlay.enemies[i].isDead) {
					level.removeChild(ScenePlay.enemies[i]);
					ScenePlay.enemies.splice(i, 1);
					enemiesRemainingCount--;
				}
			}
			for (var j: int = ScenePlay.flyingEnemies.length - 1; j >= 0; j--) {
				ScenePlay.flyingEnemies[j].update();
				if (ScenePlay.flyingEnemies[j].isDead) {
					level.removeChild(ScenePlay.flyingEnemies[j]);
					ScenePlay.flyingEnemies.splice(j, 1);
					enemiesRemainingCount--;
				}
			}
			for (var k: int = ScenePlay.toughEnemies.length - 1; k >= 0; k--) {
				ScenePlay.toughEnemies[k].update();
				if (ScenePlay.toughEnemies[k].isDead) {
					level.removeChild(ScenePlay.toughEnemies[k]);
					ScenePlay.toughEnemies.splice(k, 1);
					enemiesRemainingCount--;
				}
			}

			if (ScenePlay.enemies.length == 0 && ScenePlay.flyingEnemies.length == 0 && ScenePlay.toughEnemies.length == 0) {
				updateWave();
			}
		} // ends updateEnemies

		/**
		 * Because our camera moves our platforms around on-screen, we call this function to primarily recalculate our platforms AABB's.
		 * However, because it is an update function, we can add some more functionality to our platforms if we so wish.
		 */
		private function updatePlatforms(): void {
			for (var i: int = ScenePlay.platforms.length - 1; i >= 0; i--) {
				ScenePlay.platforms[i].update();
			}
		} // ends updatePlatforms

		/**
		 * Updates all floating platform game objects.
		 */
		private function updateFloatingPlatforms(): void {
			for (var i: int = ScenePlay.floatingPlatforms.length - 1; i >= 0; i--) {
				ScenePlay.floatingPlatforms[i].update();
			}
		} // ends updateFloatingPlatforms

		/**
		 * Updates particles for every frame.
		 */
		private function updateParticles(): void {
			for (var i: int = particles.length - 1; i >= 0; i--) {
				particles[i].update();

				if (particles[i].isDead) {
					level.removeChild(particles[i]);
					particles.splice(i, 1);
				}
			}
		} // ends updateParticles

		/**
		 * Updates turrets every frame.
		 */
		private function updateTurrets(): void {
			for (var i: int = turrets.length - 1; i >= 0; i--) {
				turrets[i].update();
			} // ends for
		} // ends updateTurrets

		/** 
		 * Updates the wave whenever a wave ends.
		 */
		private function updateWave(): void {
			if (waveEnd == true) {
				enemiesRemainingCount = enemyNum;
				waveCount++;
				waveEnd = false;
				waveStart = true;
			}
		} // ends updateWave

		/**
		 * This is where we do all of our AABB collision detection.
		 */
		private function doCollisionDetection(): void {

			for (var i: int = 0; i < ScenePlay.platforms.length; i++) {

				//Collision for platforms and everything else.
				platformCollision(i);

				// Collision for player bullets hitting enemies.
				bulletEnemyCollision();

				// Collision between player and enemies
				playerEnemyCollision();

				// Collision between bombs and enemies
				bombEnemyCollision();

			} // ends for
			//Keep all of the collisions that don't need to be in the for loop out!
			// Collision between good bullets and bad bullets
			doubleBulletCollision();

			// Collision for floating platforms.
			floatingPlatformCollision();

			// Collision between player and badBullets
			playerBulletBadCollision();

			// Collision between player and coins
			playerCoinCollision();

			// Collision between the Castle and badBullets
			castleBulletBadCollision();

			// Collision between the Castle and flying enemies
			castleFlyingEnemyCollision();

			castleToughEnemyCollision();

			// Collision between the player and flying enemies
			playerFlyingEnemyCollision();

			// Collision between flying enemies and tower spires
			flyingEnemyTowerSpireCollision();

			// Collision between flying enemies and tower bases
			flyingEnemyTowerBaseCollision();

			toughEnemyTowerSpireCollision();

			toughEnemyTowerBaseCollision();

			//Collision between the player and the build spot boxes
			playerBuildSpotCollsion();

			//Collision between the player and the far wall
			playerWallCollision();

			// Collision between player bullets and the invisible wall.
			bulletWallCollision();

			// Collision between coins and the invisible wall.
			coinWallCollision();

			//Collision between the towers and enemy bullets
			towerBulletsBadCollision();

			//Collision between the bombs and the invisible wall.
			bombWallCollision();

		} // ends doCollisionDetection()

		/**
		 * A function that deals damage to the player.
		 */
		private function damagePlayer(): void {
			player.health -= 5;
			if (player.health <= 0) {
				player.health = 0;
			}
		}

		/**
		 * A function that deals damage to the castle.
		 * @param d The amount of damage we want to get done to the castle.
		 */
		private function damageCastle(d: int): void {
			castle.health -= d;
			if (castle.health <= 0) {
				castle.health = 0;
			}
		}

		/**
		 * This handles our camera movement within our level to keep our player in the middle of the screen and lets make our levels bigger.
		 */
		private function doCameraMove(): void {
			var targetX: Number = -player.x + stage.stageWidth / 2.5;
			var targetY: int = -player.y + stage.stageHeight / 1.2;
			var offsetX: Number = 0 //Math.random() * 20 - 10;
			var offsetY: Number = 4 //Math.random() * 20 - 10;
			var camEaseMultipler: Number = 5;
			level.x += (targetX - level.x) * Time.dt * camEaseMultipler /* + offsetX*/ ;
			level.y += (targetY - level.y) * Time.dt * camEaseMultipler /*+ offsetY*/ ;
		} // ends doCameraMove

		/**
		 * Explodes the player bullet with particles when it hits a wall, the ground, or an enemy.
		 * @param index The index of the bullet in the bullets array.
		 */
		private function explodePlayerBullet(index: int): void {

			hitSound.play();

			bullets[index].isDead = true;

			for (var i: int = 0; i < 5; i++) {
				var p: Particle = new ParticleBoom(bullets[index].x, bullets[index].y);
				level.addChild(p);
				particles.push(p);
			} // ends for
		} // ends explodePlayerBullet

		/**
		 * Function handling the destruction of bombs.
		 * @param index The index of the bomb in the bombs array.
		 */
		private function explodeBombs(index: int): void {
			// Plays a hitsound.
			hitSound.play();
			// Sets bomb's isDead to true.
			bombs[index].isDead = true;
			// Spawns particles.
			for (var i: int = 0; i < 5; i++) {
				var p: Particle = new ParticleBoom(bombs[index].x, bombs[index].y);
				level.addChild(p);
				particles.push(p);
			} // ends for
		} // ends explodeBombs

		/**
		 * Explodes the enemy bullet with particles when it hits a wall, ground, or the player.
		 * @param index The index of the bullet in the bullets array.
		 */
		private function explodeEnemyBullet(index: int): void {

			hitSound.play();

			bulletsBad[index].isDead = true;

			for (var i: int = 0; i < 5; i++) {
				var p: Particle = new ParticleBoom(bulletsBad[index].x, bulletsBad[index].y);
				level.addChild(p);
				particles.push(p);
			} // ends for
		} // ends explodePlayerBullet



		/**
		 * Spawns smoke particles in the background of the scene.
		 */
		private function spawnSmokeParticles(): void {

			smokeParticleDelay--;

			if (smokeParticleDelay <= 0) {
				for (var i: int = 0; i < 5; i++) {
					var p: Particle = new ParticleSmokeParticle(Math.random() * stage.width, 670);
					level.addChildAt(p, 1);
					particles.push(p);
				}
				smokeParticleDelay = Math.random() * 3 + .5;
			}
		} // ends spawnSmokeParticles

		/**
		 * This function handles spawning our basic enemies and pushing them into their array.
		 * @param spawnCount How many Enemies to spawn
		 * @param enemyType What type of enemies to spawn (this feature has been broken up into different functions)
		 */
		private function spawnEnemy(spawnCount: int, enemyType: int = 0): void {
			// spawn snow:
			// spawn snow:
			spawnCount += spawnIncrement;
			enemyNum = spawnCount;
			if (enemyCounter < spawnCount && waveStart == true) {
				for (var i: int = 0; i < spawnCount; i++) {
					delaySpawn -= Time.dtScaled;
					if (delaySpawn <= 0) {
						var e: Enemy = new Enemy();
						level.addChild(e);
						ScenePlay.enemies.push(e);
						enemyCounter++;
						delaySpawn = (int)(Math.random() * spawnRate + spawnRateMin);
					}
				}
			}

			// Handles changing the spawn rate of enemies and changing waves.
			if (enemyCounter == spawnCount) {
				waveStart = false;
				waveEnd = true;
				enemyCounter = 0;
				spawnIncrement += 5;
				spawnRate -= spawnDecrement;
				spawnRateMin -= spawnDecrement;
			}

		}
		/**
		 * This function handles spawning our flying enemies and pushing them into their array.
		 * @param spawnCount How many Enemies to spawn
		 * @param enemyType What type of enemies to spawn (this feature has been broken up into different functions)
		 */
		private function spawnFlyingEnemy(spawnCount: int, enemyType: int = 0): void {
			// spawn snow:
			spawnCount += spawnIncrement;
			enemyNum = spawnCount;
			if (enemyCounter < spawnCount && waveStart == true) {
				for (var i: int = 0; i < spawnCount; i++) {
					delaySpawn -= Time.dtScaled;
					if (delaySpawn <= 0) {
						var e: EnemyFlyer = new EnemyFlyer();
						level.addChild(e);
						ScenePlay.flyingEnemies.push(e);
						enemyCounter++;
						delaySpawn = (int)(Math.random() * spawnRate + spawnRateMin);
					}
				}
			}

			if (enemyCounter == spawnCount) {
				waveStart = false;
				waveEnd = true;
				enemyCounter = 0;
				spawnIncrement += 5;
				spawnRate -= spawnDecrement;
				spawnRateMin -= spawnDecrement;
			}

		}
		/**
		 * This function handles spawning our tough enemies and pushing them into their array.
		 * @param spawnCount How many Enemies to spawn
		 * @param enemyType What type of enemies to spawn (this feature has been broken up into different functions)
		 */
		private function spawnToughEnemy(spawnCount: int, enemyType: int = 0): void {
			// spawn snow:
			spawnCount += spawnIncrement;
			enemyNum = spawnCount;
			if (enemyCounter < spawnCount && waveStart == true) {
				for (var i: int = 0; i < spawnCount; i++) {
					delaySpawn -= Time.dtScaled;
					if (delaySpawn <= 0) {
						var e: EnemyTough = new EnemyTough();
						level.addChild(e);
						ScenePlay.toughEnemies.push(e);
						enemyCounter++;
						delaySpawn = (int)(Math.random() * spawnRate + spawnRateMin);
					}
				}
			}

			if (enemyCounter == spawnCount) {
				waveStart = false;
				waveEnd = true;
				enemyCounter = 0;
				spawnIncrement += 5;
				spawnRate -= spawnDecrement;
				spawnRateMin -= spawnDecrement;
			}

		}
		/**
		 * Function handling the spawning of towers.
		 */
		private function spawnTower(): void {
			if (KeyboardInput.onKeyDown(Keyboard.NUMBER_1)) { //if "1" key is pressed...
				/* Spawns a basic tower. */
				spawnBasicTower();

			}
			if (KeyboardInput.onKeyDown(Keyboard.NUMBER_2)) { //if "2" key is pressed...
				/* Spawns a rapid fire tower. */
				spawnRapidTower();

			}
			if (KeyboardInput.onKeyDown(Keyboard.NUMBER_3)) { //if "3" key is pressed...
				/* Spawns a bomb tower. */
				spawnBombTower();

			}
		}

		/**
		 * Function for spawning a basic tower.
		 */
		private function spawnBasicTower(): void {
			// Insantiates tower + turret.
			var newBasicTower: BasicTower = new BasicTower();
			var newBasicTurret: BasicTurret = new BasicTurret();
			if (coinCount >= 20) { // If you have enough money...
				//Plays the build sound.
				buildSound.play();
				if (buildSpotChooser == 1) { // If at build spot 1...
					//Sets tower's x/y position
					newBasicTower.y = level.buildSpot1.y;
					newBasicTower.x = level.buildSpot1.x;
					// Makes build spot unusable
					level.buildSpot1.alpha = 0;
					level.buildSpot1.used = true;
				} else if (buildSpotChooser == 2) { // If at build spot 2...
					//Sets tower's x/y position
					newBasicTower.y = level.buildSpot2.y;
					newBasicTower.x = level.buildSpot2.x;
					//Makes build spot unusable
					level.buildSpot2.alpha = 0;
					level.buildSpot2.used = true;
				} // ends ifs
				// Sets turret's position
				newBasicTurret.y = newBasicTower.y - 75;
				newBasicTurret.x = newBasicTower.x;
				//Adds tower/turret to stage
				level.addChild(newBasicTower);
				level.addChild(newBasicTurret);
				// Adds tower/turret to their respective arrays
				towers.push(newBasicTower);
				turrets.push(newBasicTurret);
				// Spends coins
				spendCoins(20);
			} else { // If player doesn't have enough money...
				// Play not enough money sound/Do nothing
				notEnoughSound.play();
			} // ends ifs

		} // ends spawnBasicTower

		/**
		 * Function for spawning a rapid-fire tower.
		 */
		private function spawnRapidTower(): void {
			// Insantiates tower + turret.
			var newRapidTower: RapidTower = new RapidTower();
			var newRapidTurret: RapidTurret = new RapidTurret();
			if (coinCount >= 35) { // If you have enough money...
				// Plays build sound.
				buildSound.play();
				if (buildSpotChooser == 1) { // If at build spot 1...
					//Set tower's x/y position.
					newRapidTower.y = level.buildSpot1.y;
					newRapidTower.x = level.buildSpot1.x;
					// Makes build spot unusable.
					level.buildSpot1.alpha = 0;
					level.buildSpot1.used = true;
				} else if (buildSpotChooser == 2) { // If at build spot 2...
					// Set tower's x/y position
					newRapidTower.y = level.buildSpot2.y;
					newRapidTower.x = level.buildSpot2.x;
					// Makes build spot unusable.
					level.buildSpot2.alpha = 0;
					level.buildSpot2.used = true;
				} // ends ifs
				// Set turret's x/y position
				newRapidTurret.y = newRapidTower.y - 75;
				newRapidTurret.x = newRapidTower.x;
				// Adds tower/turret to stage.
				level.addChild(newRapidTower);
				level.addChild(newRapidTurret);
				// Adds tower/turret to their respective arrays
				towers.push(newRapidTower);
				turrets.push(newRapidTurret);
				// Spends coins
				spendCoins(35);
			} else { // If player doesn't have enough money...
				// Play not enough money sound/Do nothing
				notEnoughSound.play();
			} // ends ifs

		} // ends spawnRapidTower

		/**
		 * Function for spawning a bomb tower.
		 */
		private function spawnBombTower(): void {
			// Instantiates tower/turret.
			var newBombTower: BombTower = new BombTower();
			var newBombTurret: BombTurret = new BombTurret();
			if (coinCount >= 50) { // If player has enough money...
				// Plays build sound.
				buildSound.play();
				if (buildSpotChooser == 1) { // If player is at build spot 1...
					// Sets tower's x/y coordinates
					newBombTower.y = level.buildSpot1.y;
					newBombTower.x = level.buildSpot1.x;
					// Makes build spot unusable.
					level.buildSpot1.alpha = 0;
					level.buildSpot1.used = true;
				} else if (buildSpotChooser == 2) { // If player is at build spot 2...
					// Sets tower's x/y coordinates
					newBombTower.y = level.buildSpot2.y;
					newBombTower.x = level.buildSpot2.x;
					// Makes build spot unusable.
					level.buildSpot2.alpha = 0;
					level.buildSpot2.used = true;
				} // ends ifs
				// Sets turret's x/y positon.
				newBombTurret.y = newBombTower.y - 75;
				newBombTurret.x = newBombTower.x;
				// Adds tower/turret to stage
				level.addChild(newBombTower);
				level.addChild(newBombTurret);
				// Adds tower/turret to their respective arrays
				towers.push(newBombTower);
				turrets.push(newBombTurret);
				// Spends money
				spendCoins(50);
			} else { // If player does not have enough money...
				//Plays not enough money sound/Do nothing.
				notEnoughSound.play();
			} // ends ifs

		} // ends spawnBombTower

		/**
		 * Spawns a coin into the scene.
		 * @param coinNum The number of coins that get spawned.
		 * @param spawnX The X coordinate location where the coin will be spawned.
		 * @param spawnY The Y coordinate location where the coin will be spawned.
		 */
		private function spawnCoin(coinNum: int, spawnX: Number, spawnY: Number): void {

			for (var i: int = 0; i < coinNum; i++) {
				var c: Coin = new Coin(spawnX, spawnY);
				level.addChild(c);
				coins.push(c);
				updateCoins();
			}
		} // ends spawnCoin

		/**
		 * Updates the coins for every frame.
		 */
		private function updateCoins(): void {

			// update everything:
			for (var i: int = ScenePlay.coins.length - 1; i >= 0; i--) {
				ScenePlay.coins[i].update(); // Update design pattern.

				/** If bullet is dead, remove it. */
				if (ScenePlay.coins[i].isDead) {
					// remove it!!

					// 1. remove the object from the scene-graph
					level.removeChild(ScenePlay.coins[i]);

					// 2. nullify any variables pointing to it
					// if the variable is an array,
					// remove the object from the array
					ScenePlay.coins.splice(i, 1);
				}
			} // ends for loop updating bullets

		} // ends updateCoins

		/**
		 * Updates bullets for every frame.
		 */
		private function updateBulletsBad(): void {

			// update everything:
			for (var i: int = bulletsBad.length - 1; i >= 0; i--) {
				bulletsBad[i].update(); // Update design pattern.

				/** If bullet is dead, remove it. */
				if (bulletsBad[i].isDead) {
					// remove it!!

					// 1. remove the object from the scene-graph
					level.removeChild(bulletsBad[i]);

					// 2. nullify any variables pointing to it
					// if the variable is an array,
					// remove the object from the array
					bulletsBad.splice(i, 1);
				}
			} // ends updateBullets
		} // ends for loop updating bullets

		/**
		 * Handles detecting collision between good and bad bullets.
		 */
		private function doubleBulletCollision(): void {
			for (var j: int = 0; j < bullets.length; j++) {
				for (var i: int = 0; i < bulletsBad.length; i++) {
					if (bullets[j].collider.checkOverlap(bulletsBad[i].collider)) {
						explodePlayerBullet(j);
						explodeEnemyBullet(i);
					}
				}
			}
		}
		/**
		 * Handles detecting collision between the castle and bad bullets.
		 */
		private function castleBulletBadCollision(): void {
			for (var i: int = 0; i < bulletsBad.length; i++) {
				if (castle.colliderCenter.checkOverlap(bulletsBad[i].collider)) {
					damageCastle(5);
					explodeEnemyBullet(i);
				}
				if (castle.colliderRight.checkOverlap(bulletsBad[i].collider)) {
					damageCastle(5);
					explodeEnemyBullet(i);
				}
				if (castle.colliderLeft.checkOverlap(bulletsBad[i].collider)) {
					damageCastle(5);
					explodeEnemyBullet(i);
				}
			}
		}

		/**
		 * Handles collision between the castle and flying enemies.
		 * When a flying enemy collides with the castle, they explode and damage the castle.
		 */
		private function castleFlyingEnemyCollision(): void {
			for (var i: int = 0; i < ScenePlay.flyingEnemies.length; i++) {
				if (castle.colliderCenter.checkOverlap(ScenePlay.flyingEnemies[i].collider)) {
					damageCastle(10);
					killEnemy(i, 2);
				}
				if (castle.colliderRight.checkOverlap(ScenePlay.flyingEnemies[i].collider)) {
					damageCastle(10);
					killEnemy(i, 2);
				}
				if (castle.colliderLeft.checkOverlap(ScenePlay.flyingEnemies[i].collider)) {
					damageCastle(10);
					killEnemy(i, 2);
				}

				//updateEnemies();
			}
		} // ends castleFlyingEnemyCollision

		/**
		 * Handles collision between the castle and flying enemies.
		 * When a flying enemy collides with the castle, they explode and damage the castle.
		 */
		private function castleToughEnemyCollision(): void {
			for (var i: int = 0; i < ScenePlay.toughEnemies.length; i++) {
				ScenePlay.toughEnemies[i].collider.calcEdges(ScenePlay.toughEnemies[i].x, ScenePlay.toughEnemies[i].y);
				if (castle.colliderCenter.checkOverlap(ScenePlay.toughEnemies[i].collider)) {
					damageCastle(1);
				}
				if (castle.colliderRight.checkOverlap(ScenePlay.toughEnemies[i].collider)) {
					damageCastle(1);
				}
				if (castle.colliderLeft.checkOverlap(ScenePlay.toughEnemies[i].collider)) {
					damageCastle(1);
				}

				//updateEnemies();
			}
		} // ends castleFlyingEnemyCollision

		/**
		 * Handles collision detection between the player and flying enemies.
		 * Flying enemies explode on contact with the player, and damages them.
		 */
		private function playerFlyingEnemyCollision(): void {
			for (var i: int = 0; i < ScenePlay.flyingEnemies.length; i++) {
				if (player.collider.checkOverlap(ScenePlay.flyingEnemies[i].collider)) {
					damagePlayer();
					killEnemy(i, 2);
				}

				//updateEnemies();
			}
		} // ends playerFlyingEnemyCollision

		/**
		 * Handles collision between flying enemies and the tower spire.
		 * Damages the tower and explodes the enemy.
		 */
		private function flyingEnemyTowerSpireCollision(): void {
			for (var i: int = 0; i < ScenePlay.flyingEnemies.length; i++) {
				for (var j: int = 0; j < ScenePlay.towers.length; j++) {
					if (ScenePlay.towers[j].colliderSpire.checkOverlap(ScenePlay.flyingEnemies[i].collider)) {
						ScenePlay.towers[j].health -= 10;
						killEnemy(i, 2);
						if (ScenePlay.towers[j].health <= 0) {
							ScenePlay.towers[j].health = 0;
							ScenePlay.towers[j].isDead = true;
							if (ScenePlay.towers.length > 0) {
								for (var k: int = ScenePlay.towers.length - 1; k >= 0; k--) {
									if (ScenePlay.towers[k].isDead) {
										if (ScenePlay.towers[k].x <= level.buildSpot1.x + 50) {
											level.buildSpot1.alpha = 1;
											level.buildSpot1.used = false;
										}
										if (ScenePlay.towers[k].x <= level.buildSpot2.x + 50) {
											level.buildSpot2.alpha = 1;
											level.buildSpot2.used = false;
										}
										level.removeChild(ScenePlay.towers[k]);
										ScenePlay.towers.splice(k, 1);

										level.removeChild(turrets[k]);
										turrets.splice(k, 1);


									}
								}
							}
						}
					}
				}
			}
		} // ends flyingEnemyTowerSpireCollision

		/**
		 * Handles collision between flying enemies and the tower base.
		 * The tower gets damaged and the flying enemy explodes.
		 */
		private function flyingEnemyTowerBaseCollision(): void {
			for (var i: int = 0; i < ScenePlay.flyingEnemies.length; i++) {
				for (var j: int = 0; j < ScenePlay.towers.length; j++) {
					if (ScenePlay.towers[j].colliderBase.checkOverlap(ScenePlay.flyingEnemies[i].collider)) {
						ScenePlay.towers[j].health -= 10;
						killEnemy(i, 2);
						if (ScenePlay.towers[j].health <= 0) {
							ScenePlay.towers[j].health = 0;
							ScenePlay.towers[j].isDead = true;
							if (ScenePlay.towers.length > 0) {
								for (var m: int = ScenePlay.towers.length - 1; m >= 0; m--) {
									if (ScenePlay.towers[m].isDead) {
										level.removeChild(ScenePlay.towers[m]);
										ScenePlay.towers.splice(m, 1);

										level.removeChild(turrets[m]);
										turrets.splice(m, 1);
									}
								}
							}
						}
					}
				}
			}
		} // ends flyingEnemyTowerBaseCollision

		/**
		 * Handles collision between flying enemies and the tower spire.
		 * Damages the tower and explodes the enemy.
		 */
		private function toughEnemyTowerSpireCollision(): void {
			for (var i: int = 0; i < ScenePlay.toughEnemies.length; i++) {
				for (var j: int = 0; j < ScenePlay.towers.length; j++) {
					ScenePlay.toughEnemies[i].collider.calcEdges(ScenePlay.toughEnemies[i].x, ScenePlay.toughEnemies[i].y);
					if (ScenePlay.towers[j].colliderSpire.checkOverlap(ScenePlay.toughEnemies[i].collider)) {
						ScenePlay.towers[j].health -= 1;
						if (ScenePlay.towers[j].health <= 0) {
							ScenePlay.towers[j].health = 0;
							ScenePlay.towers[j].isDead = true;
							updateTowers();
						}
					}
				}
			}
		} // ends flyingEnemyTowerSpireCollision

		/**
		 * Handles collision between flying enemies and the tower base.
		 * The tower gets damaged and the flying enemy explodes.
		 */
		private function toughEnemyTowerBaseCollision(): void {
			for (var i: int = 0; i < ScenePlay.toughEnemies.length; i++) {
				for (var j: int = 0; j < ScenePlay.towers.length; j++) {
					if (ScenePlay.towers[j].colliderBase.checkOverlap(ScenePlay.toughEnemies[i].collider)) {
						ScenePlay.towers[j].health -= 10;
						if (ScenePlay.towers[j].health <= 0) {
							ScenePlay.towers[j].health = 0;
							ScenePlay.towers[j].isDead = true;
							updateTowers();
						}
					}
				}
			}
		} // ends flyingEnemyTowerBaseCollision

		/**
		 *  Handles detecting collision between the towers and bad bullets.
		 */
		private function towerBulletsBadCollision(): void {
			for (var i: int = 0; i < bulletsBad.length; i++) {
				for (var j: int = 0; j < ScenePlay.towers.length; j++) {
					if (ScenePlay.towers[j].colliderSpire.checkOverlap(bulletsBad[i].collider)) {
						ScenePlay.towers[j].health -= 10;
						explodeEnemyBullet(i);
						if (ScenePlay.towers[j].health <= 0) {
							ScenePlay.towers[j].health = 0;
							ScenePlay.towers[j].isDead = true;
							if (ScenePlay.towers.length > 0) {
								for (var k: int = ScenePlay.towers.length - 1; k >= 0; i--) {
									if (ScenePlay.towers[k].isDead) {
										if (ScenePlay.towers[k].x <= level.buildSpot1.x + 50) {
											level.buildSpot1.alpha = 1;
											level.buildSpot1.used = false;
										}
										if (ScenePlay.towers[k].x <= level.buildSpot2.x + 50) {
											level.buildSpot2.alpha = 1;
											level.buildSpot2.used = false;
										}
										level.removeChild(ScenePlay.towers[k]);
										ScenePlay.towers.splice(k, 1);

										level.removeChild(turrets[k]);
										turrets.splice(k, 1);


									}
								}
							}
						}
					}
					if (ScenePlay.towers[j].colliderBase.checkOverlap(bulletsBad[i].collider)) {
						ScenePlay.towers[j].health -= 10;
						explodeEnemyBullet(i);
						if (ScenePlay.towers[j].health <= 0) {
							ScenePlay.towers[j].health = 0;
							ScenePlay.towers[j].isDead = true;
							if (ScenePlay.towers.length > 0) {
								for (var k: int = ScenePlay.towers.length - 1; k >= 0; i--) {
									if (ScenePlay.towers[k].isDead) {
										level.removeChild(ScenePlay.towers[k]);
										ScenePlay.towers.splice(k, 1);

										level.removeChild(turrets[k]);
										turrets.splice(k, 1);
									}
								}
							}
						}
					}
				}
			}
		}

		/**
		 * Updates the towers for every frame.
		 */
		private function updateTowers(): void {
			if (ScenePlay.towers.length > 0) {
				for (var i: int = ScenePlay.towers.length - 1; i >= 0; i--) {
					ScenePlay.towers[i].update(this);
					if (ScenePlay.towers[i].isDead) {
						if (ScenePlay.towers[i].x <= level.buildSpot1.x + 100) {
							level.buildSpot1.alpha = 1;
							level.buildSpot1.used = false;
						}
						if (ScenePlay.towers[i].x <= level.buildSpot2.x + 100) {
							level.buildSpot2.alpha = 1;
							level.buildSpot2.used = false;
						}

						level.removeChild(ScenePlay.towers[i]);
						ScenePlay.towers.splice(i, 1);

						level.removeChild(turrets[i]);
						turrets.splice(i, 1);
					}
				}
			}
		} // ends updateTowers

		/**
		 *  Handles detecting collision between the player and bad bullets.
		 */
		private function playerBulletBadCollision(): void {
			for (var i: int = 0; i < bulletsBad.length; i++) {
				if (player.collider.checkOverlap(bulletsBad[i].collider)) {
					damagePlayer();
					explodeEnemyBullet(i);
				}
			}
		}
		/**
		 *  Handles detecting collision between the player and the invisable wall.
		 */
		private function playerWallCollision(): void {
			if (player.collider.checkOverlap(level.playerWall.collider)) {
				// find the fix:
				var fix: Point = player.collider.findOverlapFix(level.playerWall.collider);
				//trace(fix);
				// apply the fix:
				player.applyFix(fix);
			}
		}

		/**
		 * Handles collision between the coins and the invisible wall.
		 */
		private function coinWallCollision(): void {
			for (var i: int = 0; i < ScenePlay.coins.length; i++) {
				if (ScenePlay.coins[i].collider.checkOverlap(level.playerWall.collider)) {
					var fix: Point = ScenePlay.coins[i].collider.findOverlapFix(level.playerWall.collider);

					ScenePlay.coins[i].applyFix(fix);
				}
			}
		} // ends coinWallCollision

		/**
		 * Handles collision between player bullets and the invisible wall.
		 */
		private function bulletWallCollision(): void {
			for (var i: int = 0; i < bullets.length; i++) {
				if (bullets[i].collider.checkOverlap(level.playerWall.collider)) {
					explodePlayerBullet(i);
					updateBullets();
				}
			}
		}

		/**
		 * Collision with all non-floating platforms.
		 * @param i The index of the platform.
		 */
		private function platformCollision(i: Number): void {
			// Collision for player hitting platforms.
			if (player.collider.checkOverlap(ScenePlay.platforms[i].collider)) { // if we are overlapping
				// find the fix:
				var fix: Point = player.collider.findOverlapFix(ScenePlay.platforms[i].collider);
				//trace(fix);
				// apply the fix:
				player.applyFix(fix);
			}

			// Collision for enemies hitting platforms.
			for (var k: int = 0; k < ScenePlay.enemies.length; k++) {
				if (ScenePlay.enemies[k].collider.checkOverlap(ScenePlay.platforms[i].collider)) {
					var enemyFix: Point = ScenePlay.enemies[k].collider.findOverlapFix(ScenePlay.platforms[i].collider);
					ScenePlay.enemies[k].applyFix(enemyFix);

				}
			}
			for (var n: int = 0; n < ScenePlay.toughEnemies.length; n++) {
				if (ScenePlay.toughEnemies[n].collider.checkOverlap(ScenePlay.platforms[i].collider)) {
					var enemyFix2: Point = ScenePlay.toughEnemies[n].collider.findOverlapFix(ScenePlay.platforms[i].collider);
					ScenePlay.toughEnemies[n].applyFix(enemyFix2);

				}
			}
			// Collision for player bullets hitting platforms.
			for (var j: int = 0; j < bullets.length; j++) {
				if (bullets[j].collider.checkOverlap(ScenePlay.platforms[i].collider)) {
					//trace(player.collider.checkOverlap(platforms[i].collider));
					explodePlayerBullet(j);
				}
			} // ends for

			// Collision for enemy bullets hitting platforms.
			for (var m: int = 0; m < bulletsBad.length; m++) {
				if (bulletsBad[m].collider.checkOverlap(ScenePlay.platforms[i].collider)) {
					//trace(player.collider.checkOverlap(platforms[i].collider));
					explodeEnemyBullet(m);
				}
			} // ends for
			// Collision for coins hitting platforms.
			for (var l: int = 0; l < coins.length; l++) {
				if (ScenePlay.coins[l].collider.checkOverlap(ScenePlay.platforms[i].collider)) {
					var coinFix: Point = ScenePlay.coins[l].collider.findOverlapFix(ScenePlay.platforms[i].collider);
					ScenePlay.coins[l].applyFix(coinFix);
				}
			} // ends for 
		} // ends platformCollision

		/**
		 * Handles collision for all floating platform objects.
		 * Bullets do not collide with these platforms, and the player can fall through them if they hold 'down'.
		 */
		private function floatingPlatformCollision(): void {
			for (var i: int = 0; i < ScenePlay.floatingPlatforms.length; i++) {

				// Collision for player hitting platforms.
				if (player.collider.checkOverlap(ScenePlay.floatingPlatforms[i].collider)) { // if we are overlapping

					if (!KeyboardInput.onKeyDown(Keyboard.S)) {
						// find the fix:
						var fix: Point = player.collider.findOverlapFix(ScenePlay.floatingPlatforms[i].collider);

						// apply the fix:
						// only if the player is not jumping.  
						// allows the player to jump upwards through the bottom of the platform.
						if (!player.isJumping) {
							player.applyFix(fix);
						}
					}

				} // ends if

				// Collision for enemies hitting platforms.
				for (var j: int = 0; j < ScenePlay.enemies.length; j++) {
					if (ScenePlay.enemies[j].collider.checkOverlap(ScenePlay.floatingPlatforms[i].collider)) {
						var enemyFix: Point = ScenePlay.enemies[j].collider.findOverlapFix(ScenePlay.floatingPlatforms[i].collider);
						ScenePlay.enemies[j].applyFix(enemyFix);
					}
				}

				// Collision for coins hitting platforms.
				for (var k: int = 0; k < coins.length; k++) {
					if (ScenePlay.coins[k].collider.checkOverlap(ScenePlay.floatingPlatforms[i].collider)) {
						var coinFix: Point = ScenePlay.coins[k].collider.findOverlapFix(ScenePlay.floatingPlatforms[i].collider);
						ScenePlay.coins[k].applyFix(coinFix);
					}
				} // ends for 

			} // ends for
		} // ends floatingPlatformCollision

		/**
		 * Function handling player/build spot collision
		 */
		private function playerBuildSpotCollsion(): void {
			if (player.collider.checkOverlap(level.buildSpot1.collider)) { // If player is on build spot 1...
				// Show build instructions
				level.buildSpot1.buildInstructions.alpha = 1;
				if (!level.buildSpot1.used) { // If build spot 1 hasn't been used...
					// Sets buildSpotChooser variable
					buildSpotChooser = 1;
					// Runs spawnTower
					spawnTower();
				} else if (level.buildSpot1.used) { // If build spot 1 is used...
					// Shows sell text
					changeSellText();
					hud.sellText.alpha = 1;
					// Sells tower if player presses E
					if (KeyboardInput.onKeyDown(Keyboard.E)) {
						sellTower();
					}
				}
			} else { // If player is not on build spot 1...
				// Hide build instructions
				level.buildSpot1.buildInstructions.alpha = 0;
				if (!player.collider.checkOverlap(level.buildSpot2.collider)) {
					hud.sellText.alpha = 0;
				}
			} // ends ifs
			if (player.collider.checkOverlap(level.buildSpot2.collider)) { // If player is on build spot 2...
				// Show build instructions
				level.buildSpot2.buildInstructions.alpha = 1;
				if (!level.buildSpot2.used) { // If build spot hasn't been used...
					// Sets buildSpotChooser
					buildSpotChooser = 2;
					// Runs spawnTower
					spawnTower();
				} else if (level.buildSpot2.used) { // If build spot is used...
					// Show sell text
					changeSellText();
					hud.sellText.alpha = 1;
					// Sell tower if player presses E
					if (KeyboardInput.onKeyDown(Keyboard.E)) {
						sellTower();
					}
				}
			} else { // If player is not on build spot 2...
				// Hide build instructions
				level.buildSpot2.buildInstructions.alpha = 0;
				if (!player.collider.checkOverlap(level.buildSpot1.collider)) {
					hud.sellText.alpha = 0;
				}
			} // ends ifs
		} // ends playerBuildSpotCollsion

		/**
		 * Handles collision between player bullets and enemies.
		 */
		private function bulletEnemyCollision(): void {
			for (var i: int = 0; i < bullets.length; i++) {
				//trace("Enemies Array Length: " + ScenePlay.enemies.length);
				for (var j: int = 0; j < ScenePlay.enemies.length; j++) {
					if (bullets[i].collider.checkOverlap(ScenePlay.enemies[j].collider)) {
						killEnemy(j, 1);
						explodePlayerBullet(i);
						explodePlayerBullet(i);
						spawnCoin(3, ScenePlay.enemies[j].x, ScenePlay.enemies[j].y);
						updateEnemies();
					}
				} // ends for
				//trace("Flyers Array Length: " + ScenePlay.flyingEnemies.length);
				for (var k: int = 0; k < ScenePlay.flyingEnemies.length; k++) {
					if (bullets[i].collider.checkOverlap(ScenePlay.flyingEnemies[k].collider)) {
						killEnemy(k, 2);
						explodePlayerBullet(i);
						explodePlayerBullet(i);
						spawnCoin(1, ScenePlay.flyingEnemies[k].x, ScenePlay.flyingEnemies[k].y);
						updateEnemies();
					}
				} // ends for
				//trace("Toughies Array Length: " + ScenePlay.toughEnemies.length);
				for (var m: int = 0; m < ScenePlay.toughEnemies.length; m++) {
					if (bullets[i].collider.checkOverlap(ScenePlay.toughEnemies[m].collider)) {
						ScenePlay.toughEnemies[m].takeDamage(1);
						explodePlayerBullet(i);
						explodePlayerBullet(i);
						if (ScenePlay.toughEnemies[m].isDead) {
							killEnemy(m, 3);
							spawnCoin(5, ScenePlay.toughEnemies[m].x, ScenePlay.toughEnemies[m].y);
							updateEnemies();
						}
					}
				} // ends for
			} // ends for
		} // ends bulletEnemyCollision

		/** 
		 * Handles collision between bombs and enemies.
		 */
		private function bombEnemyCollision(): void {
			for (var i: int = 0; i < bombs.length; i++) {
				for (var j: int = 0; j < ScenePlay.enemies.length; j++) {
					if (bombs[i].collider.checkOverlap(ScenePlay.enemies[j].collider)) { // If a bomb hits an enemy...
						// Expand the AABB
						bombs[i].collider.xMin = x - width;
						bombs[i].collider.xMax = x + width;
						bombs[i].collider.yMin = y - height;
						bombs[i].collider.yMax = y + height;
						// Recalculate AABB's edges
						bombs[i].collider.calcEdges(x, y);
						// Re-check for collision.
						if (bombs[i].collider.checkOverlap(ScenePlay.enemies[j].collider)) { // If explosion radius hits an enemy...
							// Kill that enemy
							killEnemy(j, 1);
						}
						// Destroy the bomb
						explodeBombs(i);
					} // ends ifs
				} // ends for
				for (var j: int = 0; j < ScenePlay.flyingEnemies.length; j++) {
					if (bombs[i].collider.checkOverlap(ScenePlay.flyingEnemies[j].collider)) { // If a bomb hits an enemy...
						// Expand the AABB
						bombs[i].collider.xMin = x - width;
						bombs[i].collider.xMax = x + width;
						bombs[i].collider.yMin = y - height;
						bombs[i].collider.yMax = y + height;
						// Recalculate AABB's edges
						bombs[i].collider.calcEdges(x, y);
						// Re-check for collision.
						if (bombs[i].collider.checkOverlap(ScenePlay.flyingEnemies[j].collider)) { // If explosion radius hits an enemy...
							// Kill that enemy
							killEnemy(j, 2);
						}
						// Destroy the bomb
						explodeBombs(i);
					} // ends ifs
				} // ends for
				for (var j: int = 0; j < ScenePlay.toughEnemies.length; j++) {
					if (bombs[i].collider.checkOverlap(ScenePlay.toughEnemies[j].collider)) { // If a bomb hits an enemy...
						// Expand the AABB
						bombs[i].collider.xMin = x - width;
						bombs[i].collider.xMax = x + width;
						bombs[i].collider.yMin = y - height;
						bombs[i].collider.yMax = y + height;
						// Recalculate AABB's edges
						bombs[i].collider.calcEdges(x, y);
						// Re-check for collision.
						if (bombs[i].collider.checkOverlap(ScenePlay.toughEnemies[j].collider)) { // If explosion radius hits an enemy...
							// Kill that enemy
							killEnemy(j, 3);
						}
						// Destroy the bomb
						explodeBombs(i);
					} // ends ifs
				} // ends for
			} // ends for
		} // ends bombEnemyCollision

		/**
		 * Handles collision between the player and the enemy.
		 */
		private function playerEnemyCollision(): void {
			for (var i: int = 0; i < ScenePlay.enemies.length; i++) {
				if (player.collider.checkOverlap(ScenePlay.enemies[i].collider)) {
					var playerFix: Point = player.collider.findOverlapFix(ScenePlay.enemies[i].collider);
					//var enemyFix: Point = ScenePlay.enemies[i].collider.findOverlapFix(player.collider);
					player.applyFix(playerFix);
					//ScenePlay.enemies[i].applyFix(enemyFix);
				}
			} // ends for
		} // ends playerEnemyCollision

		/**
		 * Handles collision between the player and the coins.
		 * The player collects each coin that it collides with.
		 */
		private function playerCoinCollision(): void {
			for (var i: int = 0; i < ScenePlay.coins.length; i++) {
				if (player.collider.checkOverlap(ScenePlay.coins[i].collider)) {
					collectCoin(i);
				}
			}
		} // ends playerCoinCollision

		/**
		 * Handles collision between the bombs and the invisible wall.
		 */
		private function bombWallCollision(): void {
			for (var i: int = 0; i < bombs.length; i++) {
				if (bombs[i].collider.checkOverlap(level.playerWall.collider)) { // If bombs hit the wall...
					// Kill the bomb
					explodeBombs(i);
					// Update the bomb array
					updateBombs();
				} // ends if
			} // ends for
		} // ends bombWallCollision

		/**
		 * Increments the coin counter everytime the player collides with a coin. Removes coins from the scene as well.
		 * @param index The index of the coin in the coins array.
		 */
		private function collectCoin(index: int) {
			coinSound.play();
			ScenePlay.coins[index].isDead = true;
			updateCoins();
			coinCount++;
		} // ends collectCoin
		/**
		 * Handles killing an enemy whenever the player kills them.
		 * @param index The current index of the enemy in the enemies array.
		 * @param array The array of the Enemy you want to get rid of is in.
		 */
		private function killEnemy(index: int, array: int): void {
			enemyDieSound.play();
			switch (array) {
				case 1:
					ScenePlay.enemies[index].isDead = true;
					for (var i: int = 0; i < 10; i++) {
						var p: Particle = new ParticleBlood(ScenePlay.enemies[index].x, ScenePlay.enemies[index].y);
						level.addChild(p);
						particles.push(p);
					}
					break;
				case 2:
					ScenePlay.flyingEnemies[index].isDead = true;
					for (var j: int = 0; j < 10; j++) {
						var p1: Particle = new ParticleBlood(ScenePlay.flyingEnemies[index].x, ScenePlay.flyingEnemies[index].y);
						level.addChild(p1);
						particles.push(p1);
					}
					break;
				case 3:
					ScenePlay.toughEnemies[index].isDead = true;
					for (var k: int = 0; k < 10; k++) {
						var p2: Particle = new ParticleBlood(ScenePlay.toughEnemies[index].x, ScenePlay.toughEnemies[index].y);
						level.addChild(p2);
						particles.push(p2);
					}
					break;
			}

			for (var i: int = 0; i < 10; i++) {
				var p: Particle = new ParticleBlood(ScenePlay.enemies[index].x, ScenePlay.enemies[index].y);
				level.addChild(p);
				particles.push(p);
			}
		}

		/**
		 * Decrements the coin counter whenever the player buys a tower.
		 * @param coinNum The number of coins the player is spending.
		 */
		private function spendCoins(coinNum: int): void {
			coinCount -= coinNum;

			if (coinCount <= 0) {
				coinCount = 0;
			}
		} // ends spendCoins

		/** 
		 * Handles selling towers. The player gains coins depending on which tower they sell.
		 */
		private function sellTower(): void {
			for (var i: int = ScenePlay.towers.length - 1; i >= 0; i--) {
				if (player.x <= ScenePlay.towers[i].x + 50) { // If player is near the tower...
					// Play the sell sound
					sellSound.play();
					if (ScenePlay.towers[i].isBasicTower) { // If tower is basic...
						// Give 10 coins
						coinCount += 10;
					} else if (ScenePlay.towers[i].isRapidTower) { // If tower is rapid-fire...
						// Give 15 coins
						coinCount += 15;
					} else if (ScenePlay.towers[i].isBombTower) { // If tower is bomb...
						// Give 20 coins
						coinCount += 20;
					}
					// Remove tower.
					ScenePlay.towers[i].isDead = true;
					// Update tower array.
					updateTowers();
				} // ends ifs
			} // ends for
		} // ends sellTower

		/**
		 * Handles changing the sellText textfield whenever the player is near a tower.
		 * The text changes how many coins the player gains depending on which tower they are standing by.
		 */
		private function changeSellText(): void {
			for (var i: int = ScenePlay.towers.length - 1; i >= 0; i--) {
				if (ScenePlay.towers[i].isBasicTower) {
					hud.sellText.text = "Press 'E' to sell (+10 coins)";
				} else if (ScenePlay.towers[i].isRapidTower) {
					hud.sellText.text = "Press 'E' to sell (+15 coins)";
				} else if (ScenePlay.towers[i].isBombTower) {
					hud.sellText.text = "Press 'E' to sell (+20 coins)";
				}
			}
		} // ends changeSellText
	} // ends class
} // ends package