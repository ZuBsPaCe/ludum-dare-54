extends Node

enum GameState {
	NONE,
	MAIN_MENU,
	
	GAME,
	
	START_TUTORIAL,
	TUTORIAL,
	NEXT_TUTORIAL,
	
	PAUSE,
	CONTINUE,
	
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
