﻿package code {	
	import flash.display.MovieClip;
	/**
	 * This is the class for bomb projectiles.
	 */
	public class Bomb extends MovieClip{
		/* Speed of the bomb. */
		public const SPEED: Number = 420;
		/* The X Velocity of the bomb. */
		public var velocityX: Number = 0;
		/* The Y Velocity of the bomb. */
		public var velocityY: Number = -10;
		/* Checks for if the bomb should be deleted. */
		public var isDead: Boolean = false;
		/**Radius of the bomb. */
		public var radius: Number = 10;
		/* Angle of the bomb. */
		public var angle: Number = 0;
		/* The amount of time the bomb will stay alive for in seconds. */
		public var lifeMax: Number = 2;
		/* The current amount of time the bomb has been on screen */
		private var lifeCurrent: Number = 0;		
		/* The AABB collision for this object. */
		public var collider:AABB;		
		/**
		* Constructor function for the bombs.
		* @param t The turret object of the game.
		*/
		public function Bomb(t:Turret = null) {
			// Instantiates & calculates edges of the bomb's collider.
			collider = new AABB(width/2, height/2)
			collider.calcEdges(x, y);			
			// Set coordinates of bomb to turret coordinates. 
			x = t.x;
			y = t.y;
			// Set angle to gun rotation.
			angle = (t.rotation - 90) * Math.PI /180;
			// Set velocity according to speed and angle of the bomb.
			velocityX = SPEED * Math.cos(angle);
			velocityY = SPEED * Math.sin(angle);
		}// ends Bomb
		/**
		 * The update function for the bombs.
		 */
		public function update(): void {
			// Updates collider for the bomb.
			collider.calcEdges(x, y);			
			// Moves bomb according to velocity.
			x += velocityX * Time.dtScaled;
			y += velocityY * Time.dtScaled;			
			// Increment how long this bomb has been alive for.
			lifeCurrent += Time.dtScaled;
			// If this object has lived a long happy life, mark it as dead.
			if (lifeCurrent > lifeMax) isDead = true;			
		} // ends update		
	}// ends class
}// ends pakcage
