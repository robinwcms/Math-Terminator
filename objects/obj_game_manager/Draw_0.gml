// Draws the vignette sprite at the game managers position
// Skip during airstrike or sniper zoom — both cause the vignette to render
// at the wrong size for the current view, creating a visible rectangle.
if (!instance_exists(obj_airstrike) && !obj_game_manager.sniper_active)
{
	draw_sprite(spr_vignette, 0, x, y);
}