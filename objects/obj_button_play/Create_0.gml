// Variable used for setting intial mouse aim settings
global.is_mouse_aiming = true;

// Old Play button replaced by Unlimited/Timed buttons — destroy on spawn
instance_destroy();
exit;

// Variable for target scale
target_scale = 1.0;

// Variables for scaling rate
scale_rate = 0.1;
can_scale_at_rate = false;

// Variable for pressed state
is_pressed = false;

// Variable for play button sound
sound_button = -1;