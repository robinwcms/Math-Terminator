var _cw = display_get_gui_width();
var _ch = display_get_gui_height();
var _cx = _cw / 2;

var _step = steps[current_step];

// ─── DIALOG BOX (bottom of screen) ─────────────────────────────────
// Make intro box much taller so multi-line text fits cleanly.
var _box_h, _box_y, _box_x, _box_w;
if (step_state == "intro")
{
	_box_h = 380;
}
else
{
	_box_h = 110;
}
_box_y = _ch - _box_h - 20;
_box_x = 60;
_box_w = _cw - 120;

// Background
draw_set_color(make_color_rgb(15, 12, 22));
draw_set_alpha(0.92);
draw_roundrect(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);
draw_set_alpha(1.0);
// Gold border
draw_set_color(make_color_rgb(200, 160, 50));
draw_roundrect(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);
draw_roundrect(_box_x + 1, _box_y + 1, _box_x + _box_w - 1, _box_y + _box_h - 1, true);
draw_roundrect(_box_x + 2, _box_y + 2, _box_x + _box_w - 2, _box_y + _box_h - 2, true);

// Step indicator (top-right of dialog)
draw_set_font(fnt_luckiest_guy_24);
draw_set_color(make_color_rgb(150, 150, 150));
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_text(_box_x + _box_w - 20, _box_y + 12,
		  "STEP " + string(current_step + 1) + " / " + string(array_length(steps)));

// Title — only show in intro state (active/outro use a different layout)
if (step_state == "intro")
{
	draw_set_font(fnt_luckiest_guy_36_outline);
	draw_set_color(make_color_rgb(245, 195, 30));
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text(_box_x + 30, _box_y + 15, _step.title);
	
	// Body text — auto-fit each line to width
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	// Compute available vertical space: from title bottom to where the prompt sits
	var _body_top = _box_y + 80;
	var _body_bottom = _box_y + _box_h - 50;   // reserve 50px for prompt at bottom
	var _max_w = _box_w - 60;
	// Find a line height that fits all lines within body area
	var _line_count = array_length(_step.intro);
	var _available_h = _body_bottom - _body_top;
	var _line_height = min(32, _available_h / max(1, _line_count));
	var _line_y = _body_top;
	for (var _i = 0; _i < array_length(_step.intro); _i++)
	{
		var _line = _step.intro[_i];
		if (_line == "") {
			_line_y += _line_height * 0.4;
			continue;
		}
		var _tw = string_width(_line);
		var _ts = (_tw > _max_w) ? _max_w / _tw : 1.0;
		// Don't scale up larger than original (1.0 cap)
		draw_text_transformed(_box_x + 30, _line_y, _line, _ts, _ts, 0);
		_line_y += _line_height;
	}
	
	// "Click to continue" prompt (always at the very bottom of the box)
	var _alpha = 0.5 + 0.4 * sin(degtorad(prompt_pulse));
	draw_set_color(make_color_rgb(255, 215, 80));
	draw_set_alpha(_alpha);
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	draw_text(_box_x + _box_w - 30, _box_y + _box_h - 14, "> CLICK ANYWHERE TO CONTINUE <");
	draw_set_alpha(1.0);
}
else if (step_state == "active")
{
	// Compact active state: title left, objective center
	draw_set_font(fnt_luckiest_guy_24);
	draw_set_color(make_color_rgb(245, 195, 30));
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	var _ctr_y = _box_y + _box_h / 2;
	// Title (auto-fit to ~30% of box width)
	{
		var _max_w = _box_w * 0.28;
		var _tw = string_width(_step.title);
		var _ts = (_tw > _max_w) ? _max_w / _tw : 1.0;
		draw_text_transformed(_box_x + 30, _ctr_y, _step.title, _ts, _ts, 0);
	}
	// Objective text in the remaining space, pulsing
	var _alpha2 = 0.75 + 0.25 * sin(degtorad(prompt_pulse));
	draw_set_color(make_color_rgb(200, 255, 200));
	draw_set_alpha(_alpha2);
	{
		var _obj_text = "OBJECTIVE: " + _step.objective;
		var _obj_x = _box_x + _box_w * 0.32;
		var _max_w = _box_w * 0.65;
		var _tw = string_width(_obj_text);
		var _ts = (_tw > _max_w) ? _max_w / _tw : 1.0;
		draw_text_transformed(_obj_x, _ctr_y, _obj_text, _ts, _ts, 0);
	}
	draw_set_alpha(1.0);
}
else if (step_state == "outro")
{
	// Compact "GREAT JOB" confirmation — only this text, no title overlap
	draw_set_font(fnt_luckiest_guy_36_outline);
	draw_set_color(make_color_rgb(120, 255, 120));
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _ctr_y = _box_y + _box_h / 2;
	draw_text(_cx, _ctr_y, "GREAT JOB!");
}

// Reset
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1.0);
