﻿package code {
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import sounds.*;
	
	/**
	 * The class for the Player object.
	 */
	public class Player extends MovieClip {
		/** The current health of the player.*/
		public var health: int = 100; 
		
		/** The max health of the player.*/
		public var maxHealth: int = 100;
		
		/** Sets the gravity for the player. */
		private var gravity: Point = new Point(0, 1000);
		
		/** Sets the X max speed for the player. */
		private var maxSpeedX: Number = 300;
		
		/** Sets the velocity for the player. */
		private var velocity: Point = new Point(1, 5);

		/** Sets the horizontal acceleration constant for the player. */
		private const HORIZONTAL_ACCELERATION: Number = 800;
		
		/** Sets the horizontal deceleration constant for the player. */
		private const HORIZONTAL_DECELERATION: Number = 800;
		
		/** Checks if the player is on the ground. */
		private var isGrounded:Boolean = false;
		
		/** Whether or not the player is moving upward in a jump.  This affects gravity. */
		public var isJumping:Boolean = false;
		
		/** How many times the player can currently jump in the air. */
		private var airJumpsLeft:int = 1;
		
		/** The max number of jumps the player can perform in the air. */
		private var airJumpsMax:int = 1;
		
		/** The player's jump velocity. */
		private var jumpVelocity:Number = 500;
		
		/** Detects the ground in the game. */
		var ground: Number = 1000;
		
		/** The angle that the gun is pointed. */
		public var angle: Number = 0;
		
		/** The collider for the player. */
		public var collider:AABB;
		
		/** Whether or not This object should be dead. */
		public var isDead:Boolean = false;
		
		/** The sound that is played when the player jumps. */
		private var jumpSound: JumpSound = new JumpSound();
		
		/** The sound that is played when the player double jumps. */
		private var doubleJumpSound: DoubleJumpSound = new DoubleJumpSound();
		
		/**
		 * The Player constructor class
		 */
		public function Player() {
			collider = new AABB(base.width / 2, base.height / 2);
		} // ends Player
		
		/**
		 * The update design pattern for the player.
		 * Handles physics, walking, jumping, aiming, and calculating our collision box.
		 */
		public function update(): void {
			
			parent.setChildIndex(this, parent.numChildren - 1);
			
			handleJumping();

			handleWalking();

			doPhysics();

			detectDeathGround();
			
			handleAiming();
			
			collider.calcEdges(x, y);
			
			if (y < ground){
				isGrounded = false; // this allows us to walk off edges and only be allowed one air jump.
			}
			if (health <= 0) isDead = true;
			//trace(y);
		} // ends update
		
		/**
		 * Changes the gun's rotation based on where the mouse is pointing.
		 */
		private function handleAiming(): void {
			var tx: Number = parent.mouseX - x;
			var ty: Number = parent.mouseY - y;
			
			angle = Math.atan2(ty, tx);
			angle *= 180 / Math.PI;
			gun.rotation = angle + 90;
			
			if (gun.rotation > -45 && gun.rotation < 0) gun.rotation = -45;
			if (gun.rotation < 45 && gun.rotation > 0) gun.rotation = 45;
			if (gun.rotation < -135 && gun.rotation > -170) gun.rotation = -135;
			if (gun.rotation > 135 && gun.rotation < 170) gun.rotation = 135;
		} // end handleAiming
		
		/**
		 * Handles the jumping action for the player.
		 */
		private function handleJumping(): void {
			if (KeyboardInput.onKeyDown(Keyboard.SPACE)) {
				if (isGrounded) { // we are on the ground...
					jumpSound.play();
					isGrounded = false; // not on ground
					velocity.y = -jumpVelocity; // apply an impulse up
					isJumping = true;
				} else { // in air, attempting a double-jump
					if (airJumpsLeft > 0 && isJumping == false) { // if we have air-jumps left:
						doubleJumpSound.play();
						velocity.y = -jumpVelocity; // air jump
						airJumpsLeft--;
						isJumping = true;
					}
				}
			}
			
			if (!KeyboardInput.isKeyDown(Keyboard.SPACE)) isJumping = false;
			if (velocity.y > 0) isJumping = false;
		} // ends handleJumping
		
		/**
		 * This function looks at the keyboard input in order to accelerate the player
		 * left or right.  As a result, this function changes the player's velocity.
		 */
		private function handleWalking(): void {
			if (KeyboardInput.isKeyDown(Keyboard.A)) velocity.x -= HORIZONTAL_ACCELERATION * Time.dt;
			if (KeyboardInput.isKeyDown(Keyboard.D)) velocity.x += HORIZONTAL_ACCELERATION * Time.dt;

			if (!KeyboardInput.isKeyDown(Keyboard.A) && !KeyboardInput.isKeyDown(Keyboard.D)) { // left and right not being pressed...
				if (velocity.x < 0) { // moving left
					velocity.x += HORIZONTAL_DECELERATION * Time.dt; // accelerate right
					if (velocity.x > 0) velocity.x = 0; // clamp at 0
				}

				if (velocity.x > 0) {
					velocity.x -= HORIZONTAL_DECELERATION * Time.dt; // accelerate left
					if (velocity.x < 0) velocity.x = 0; // clamp at 0
				}
			}
		} // ends handleWalking
		
		/**
		 * Handles physics for the player.
		 * Sets the velocity to the gravity and max speed.
		 */
		private function doPhysics(): void {
			
			var gravityMultiplier:Number = .5;
			
			if (!isJumping) gravityMultiplier = 2;
			
			// apply gravity to velocity:
			//velocity.x += gravity.x * Time.dt * gravityMultiplier;
			velocity.y += gravity.y * Time.dt * gravityMultiplier;

			// constrain to maxSpeed:
			if (velocity.x > maxSpeedX) velocity.x = maxSpeedX; // clamp going right
			if (velocity.x < -maxSpeedX) velocity.x = -maxSpeedX; // clamp going left

			// apply velocity to position:
			x += velocity.x * Time.dt;
			y += velocity.y * Time.dt;
		} // ends doPhysics
		
		/**
		 * Detects when the player has hit the death plane.
		 */
		private function detectDeathGround(): void {
			// look at y position
			if (y >= ground) {
				isDead = true;
			}
		} // ends detectGround
		
		/**
		 * Applies the overlap fix detected by the collider.
		 * Adjusts the player position according to the fix.
		 */
		public function applyFix(fix: Point):void {
			if (fix.x != 0){
				x += fix.x;
				velocity.x = 0;
			}
			
			if (fix.y != 0) {
				y += fix.y;
				velocity.y = 0;
			}
			
			if (fix.y < 0) { // we moved the player up, so they are on the ground.
				isGrounded = true;
				airJumpsLeft = airJumpsMax;
			}
			
			collider.calcEdges(x, y);
		} // ends applyFix
		
	} // ends class
} // ends package