prompt_pulse += 4;

// Track shots fired by player
if (instance_exists(obj_player) && mouse_check_button_pressed(mb_left))
{
	// Only count if not clicking on the bottom dialog area
	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	if (!point_in_dialog(_mx, _my))
	{
		shots_fired++;
	}
}

var _step = steps[current_step];

if (step_state == "intro")
{
	// Pause world during intro: stop player & zombies
	if (instance_exists(obj_player))
	{
		obj_player.hspeed = 0;
		obj_player.vspeed = 0;
	}
	with (obj_enemy) {
		speed = 0;
	}
	
	// Wait for any click anywhere to advance from intro to objective
	if (mouse_check_button_pressed(mb_left))
	{
		step_state = "active";
		// Call on_start if defined
		if (!is_undefined(_step.on_start))
		{
			_step.on_start();
		}
		// If no objective (check is undefined), immediately advance step
		if (is_undefined(_step.check))
		{
			advance_step();
		}
	}
}
else if (step_state == "active")
{
	// Check if objective is complete
	if (!is_undefined(_step.check))
	{
		if (_step.check())
		{
			step_state = "outro";
			step_timer = 60;   // brief pause before next intro
		}
	}
}
else if (step_state == "outro")
{
	step_timer--;
	if (step_timer <= 0)
	{
		advance_step();
	}
}
