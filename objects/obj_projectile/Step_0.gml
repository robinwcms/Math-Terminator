// Boundary checks - effective wall buffer reduced when sniper is active (more range)
var _eff_buffer = obj_game_manager.sniper_active ? 20 : wall_buffer;
if (x < _eff_buffer || x > (obj_game_manager.arena_grid_width * obj_game_manager.cell_width) - _eff_buffer)
{
	spark_projectile();
}
if (y < _eff_buffer || y > (obj_game_manager.arena_grid_height * obj_game_manager.cell_height) - _eff_buffer)
{
	spark_projectile();
}

// Manual collision against the boss (which has no sprite mask)
if (instance_exists(obj_boss) && instance_exists(owner) && owner.object_index == obj_player)
{
	if (point_distance(x, y, obj_boss.x, obj_boss.y) < obj_boss.body_radius)
	{
		if (obj_boss.is_marked)
		{
			obj_boss.math_finish_kill();
			spark_projectile();
		}
		else if (instance_exists(obj_player) && obj_player.rapid_fire_timer > 0)
		{
			obj_boss.math_correct_answer();
			obj_boss.math_finish_kill();
			spark_projectile();
		}
		else
		{
			// Not marked: bullet just sparks off (no damage, no progress)
			if (!obj_boss.is_flashed)
			{
				obj_boss.is_flashed = true;
				obj_boss.flash_cooldown = obj_boss.flash_time;
			}
			spark_projectile();
		}
	}
}
