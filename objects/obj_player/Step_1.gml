// Safety: if for any reason health is at 0 and game state still says PLAYING,
// trigger the lose state. (Normally handled in Step_0 before destroy.)
if (player_health <= 0 && obj_game_manager.curr_game_state == GAME_STATE.PLAYING)
{
	obj_game_manager.lose_game();
}
