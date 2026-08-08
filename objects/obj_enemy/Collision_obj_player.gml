// Zombies push right through the player — no slowdown, no repulsion.
// Damage is handled in obj_enemy Step_0 by distance check.
if (obj_game_manager.curr_game_state != GAME_STATE.PAUSED)
{
	is_colliding = true;
}
