// Draw player shadow rotated to body direction (matches body movement)
draw_sprite_ext(spr_player_shadow, 0, x, y, 1.0, 1.0, body_angle, c_white, image_alpha);

// Draw player body rotated to its movement direction
image_index = is_flashed;
draw_sprite_ext(spr_player_body, is_flashed, x, y, 1.0, 1.0, body_angle, c_white, image_alpha);

// Draw the gun/turret on top, rotated independently to the mouse direction
draw_sprite_ext(spr_player_gun_shadow, 0, x, y, 1.0, 1.0, gun_angle, c_white, image_alpha);
draw_sprite_ext(spr_player_gun, is_flashed, x, y, 1.0, 1.0, gun_angle, c_white, image_alpha);

// ─── POWERUP: Shield visual ─────────────────────────────────────────────
if (variable_instance_exists(self, "shield_timer") && shield_timer > 0)
{
	var _pulse = 0.6 + 0.2 * sin(current_time / 100);
	draw_set_alpha(_pulse);
	draw_set_color(c_aqua);
	draw_circle(x, y, 130, true);
	draw_circle(x, y, 132, true);
	draw_circle(x, y, 134, true);
	draw_set_alpha(1.0);
	draw_set_color(c_white);
}

// ─── POWERUP: Speed boost trail ─────────────────────────────────────────
if (variable_instance_exists(self, "speed_boost_timer") && speed_boost_timer > 0)
{
	draw_set_alpha(0.4);
	draw_set_color(c_yellow);
	draw_circle(x, y, 110, true);
	draw_set_alpha(1.0);
	draw_set_color(c_white);
}
