/// @description Combat log step - handle collapse toggle
if (o_game.game_state != "playing") {
    return;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);

// Scroll handling - work anywhere when log is visible
if (!collapsed) {
    var log_x = 20;
    var log_y = gui_h / 2;
    var log_w = 300;
    var log_h = gui_h - log_y - 20;
    
    var log_hover = (mouse_x_gui >= log_x && mouse_x_gui <= log_x + log_w && mouse_y_gui >= log_y && mouse_y_gui <= log_y + log_h);
    
    if (log_hover) {
        var scroll_delta = mouse_wheel_up() - mouse_wheel_down();
        log_scroll = max(0, log_scroll + scroll_delta);
        
        var total_entries = array_length(o_game.combat_log);
        var max_scroll = max(0, total_entries - log_max_entries);
        log_scroll = clamp(log_scroll, 0, max_scroll);
    }
}
