extends Node

enum GameState {
	NONE,
	MAIN_MENU,
	
	NEW_GAME,
	GAME,
	
	START_TUTORIAL,
	TUTORIAL,
	NEXT_TUTORIAL,
	
	PAUSE,
	
	DEAD,
	
	EXIT
}

enum LevelState {
	NONE,
	RUNNING,
	STOPPED
}

enum GameMode {
	GAME,
	TUTORIAL
}

enum TileType {
	Ground,
	Wall,
	Empty,
	ForcedEmpty
}


enum MainMenuMode {
	Standard,
	Pause
}


enum Difficulty {
	Easy,
	Normal,
	Hard
}


enum MonsterType {
	Slime,
	Dragon,
	Ghost
}


enum Sounds {
	Block,
	Bullet,
	BulletHit,
	Hurt,
	Spawn
}
