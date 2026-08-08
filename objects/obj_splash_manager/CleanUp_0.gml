// Stop the menu music loop when this object is destroyed (room change)
if (variable_global_exists("menu_music_inst")
	&& global.menu_music_inst != -1
	&& audio_is_playing(global.menu_music_inst))
{
	audio_stop_sound(global.menu_music_inst);
	global.menu_music_inst = -1;
}
