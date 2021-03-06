﻿package code {
	
	import flash.display.MovieClip;
	
	/**
	 * This class is an ABSTRACT class for out GameScene Finite State Machine. All game scenes are child classes of this class.
	 */
	public class GameScene extends MovieClip {

		/**
		 * Each game scene should OVERRIDE this method and add specific implementation.
		 */
		public function update(previousScene:GameScene = null):GameScene {
			return null;
		} // end update
		/**
		 * This should get called right after this object is created.
		 * Each game scene should OVERRIDE this method and add specific implementation.
		 */
		public function onBegin():void {
			
		} // end onBegin
		/**
		 * This should get called right before this object is destroyed.
		 * Each game scene should OVERRIDE this method and add specific implementation.
		 */
		public function onEnd():void {
			
		} // end onEnd
	} // end class GameScene
} // end package code