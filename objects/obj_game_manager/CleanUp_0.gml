// Stop arena music when this manager is destroyed (room change away from
// arena). This is the catch-all cleanup — every code path that leaves the
// arena (main menu button, tutorial finish, lose, win, retry) eventually
// destroys this instance, so we know the music is always stopped.
if (variable_instance_exists(self, "music")
	&& music != -1
	&& audio_is_playing(music))
{
	audio_stop_sound(music);
	music = -1;
}
if (variable_global_exists("arena_music_inst")) global.arena_music_inst = -1;
