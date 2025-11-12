/// @description Draw enemy stats UI
if (o_game.game_state != "playing") {
    return;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

draw_set_font(f_menu_font_large);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var other_player = o_game.players[o_game.whosturn == 0 ? 1 : 0];

draw_set_color(c_yellow);
draw_text(gui_w - 350, 20, "ENEMY");

draw_set_font(f_menu_font_small);
draw_set_color(c_white);
draw_text(gui_w - 350, 60, "Enemy: " + other_player.title);
draw_set_color(c_red);
draw_text(gui_w - 350, 85, "HP: " + string(other_player.hp) + " / MP: " + string(other_player.mp) + "/" + string(o_game.mp_pool));
draw_set_color(c_white);
draw_text(gui_w - 350, 110, "ATK: " + string(other_player.atk) + " DEF: " + string(other_player.armor));

// Draw enemy status ailments if they exist
var enemy_status_y = 135;
if (variable_struct_exists(other_player, "status_ailments") && array_length(other_player.status_ailments) > 0) {
    draw_set_color(c_orange);
    draw_text(gui_w - 350, enemy_status_y, "STATUS:");
    enemy_status_y += 20;
    for (var i = 0; i < array_length(other_player.status_ailments); i++) {
        var ailment = other_player.status_ailments[i];
        var ailment_text = "";
        if (variable_struct_exists(ailment, "name")) {
            ailment_text = ailment.name;
            if (variable_struct_exists(ailment, "turns") && ailment.turns > 0) {
                ailment_text += " (" + string(ailment.turns) + " turns)";
            }
        } else {
            ailment_text = string(ailment);
        }
        draw_set_color(c_yellow);
        draw_text(gui_w - 330, enemy_status_y, ailment_text);
        enemy_status_y += 18;
    }
}
