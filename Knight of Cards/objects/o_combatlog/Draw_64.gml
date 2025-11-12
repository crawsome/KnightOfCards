/// @description Draw combat log (GUI layer)
if (o_game.game_state != "playing") {
    return;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

if (collapsed) {
    return;
}

// Draw log background - positioned below player info, starting at halfway point
var log_x = 20;
var log_y = gui_h / 2;
var log_w = 300;
var log_h = gui_h - log_y - 20;

draw_set_color(make_color_rgb(20, 20, 20));
draw_rectangle(log_x, log_y, log_x + log_w, log_y + log_h, false);
draw_set_color(c_white);
draw_rectangle(log_x, log_y, log_x + log_w, log_y + log_h, true);

// Draw log entries
draw_set_font(f_menu_font_small);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var entry_y = log_y + 10;
var line_height = 22;
var entries_to_show = min(log_max_entries, array_length(o_game.combat_log));

for (var i = entries_to_show - 1; i >= 0; i--) {
    var log_index = array_length(o_game.combat_log) - 1 - i - log_scroll;
    if (log_index < 0 || log_index >= array_length(o_game.combat_log)) {
        continue;
    }
    
    var entry = o_game.combat_log[log_index];
    
    // Color code by player - use brighter colors
    var player_color = (entry.player_id == 0) ? c_aqua : make_color_rgb(255, 100, 100);
    draw_set_color(player_color);
    
    var log_text = "T" + string(entry.turn) + " - P" + string(entry.player_id + 1) + ": " + entry.message;
    
    // Word wrap to multiple lines
    var max_width = log_w - 20;
    var words = string_split(log_text, " ", false);
    var current_line = "";
    var lines = [];
    
    for (var w = 0; w < array_length(words); w++) {
        var test_line = current_line;
        if (string_length(test_line) > 0) {
            test_line += " ";
        }
        test_line += words[w];
        
        if (string_width(test_line) > max_width && string_length(current_line) > 0) {
            array_push(lines, current_line);
            current_line = words[w];
        } else {
            current_line = test_line;
        }
    }
    if (string_length(current_line) > 0) {
        array_push(lines, current_line);
    }
    
    // Draw each line
    for (var line_idx = 0; line_idx < array_length(lines); line_idx++) {
        if (entry_y > log_y + log_h - line_height) {
            break;
        }
        draw_text(log_x + 10, entry_y, lines[line_idx]);
        entry_y += line_height;
    }
    
    if (entry_y > log_y + log_h - line_height) {
        break;
    }
}
