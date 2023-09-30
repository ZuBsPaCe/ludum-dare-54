extends Node

enum GameState {
	NONE,
	MAIN_MENU,
#	RESTART,
#	NEXT_LEVEL,
	GAME,
	PAUSE,
	DEAD
}

enum LevelState {
	NONE,
	RUNNING,
	STOPPED
}

enum TileType {
	Ground,
	Wall
}
