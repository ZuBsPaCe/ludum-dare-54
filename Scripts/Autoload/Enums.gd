extends Node

enum GameState {
	NONE,
	MAIN_MENU,
	
	GAME,
	TUTORIAL,
	
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
