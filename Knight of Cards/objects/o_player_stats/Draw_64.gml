/// @description Draw game UI
if (o_game.game_state == "gameover") {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    
    draw_set_font(f_menu_font_large);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // GAME OVER header
    draw_set_color(c_red);
    draw_text(gui_w / 2, gui_h / 2 - 100, "GAME OVER");
    
    // Determine winner
    var winner_text = "";
    var winner_color = c_white;
    if (array_length(o_game.players) >= 2) {
        if (o_game.players[0].hp <= 0) {
            winner_text = o_game.players[1].title + " WINS!";
            winner_color = make_color_rgb(255, 100, 100);
        } else if (o_game.players[1].hp <= 0) {
            winner_text = o_game.players[0].title + " WINS!";
            winner_color = c_aqua;
        } else {
            winner_text = "DRAW - Deck Empty";
            winner_color = c_yellow;
        }
    }
    
    draw_set_color(winner_color);
    draw_text(gui_w / 2, gui_h / 2 - 40, winner_text);
    
    // Show final stats
    draw_set_font(f_menu_font_small);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    if (array_length(o_game.players) >= 2) {
        draw_text(gui_w / 2, gui_h / 2 + 20, o_game.players[0].title + ": " + string(o_game.players[0].hp) + " HP");
        draw_text(gui_w / 2, gui_h / 2 + 45, o_game.players[1].title + ": " + string(o_game.players[1].hp) + " HP");
    }
    
    draw_text(gui_w / 2, gui_h / 2 + 80, "Press SPACE, ENTER, or CLICK to return to menu");
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    return;
}

if (o_game.game_state != "playing") {
    return;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

draw_set_font(f_menu_font_large);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var current_player = o_game.players[0];

draw_set_color(c_yellow);
draw_text(20, 20, "TURN " + string(o_game.turncount) + " - PLAYER " + string(o_game.whosturn + 1));

draw_set_font(f_menu_font_small);
draw_set_color(c_white);
draw_text(20, 60, "Your Hero: " + current_player.title);
draw_set_color(c_aqua);
draw_text(20, 85, "HP: " + string(current_player.hp) + " / MP: " + string(current_player.mp) + "/" + string(o_game.mp_pool));
draw_set_color(c_white);
draw_text(20, 110, "ATK: " + string(current_player.atk) + " DEF: " + string(current_player.armor));

// Draw status ailments if they exist
var status_y = 135;
if (variable_struct_exists(current_player, "status_ailments") && array_length(current_player.status_ailments) > 0) {
    draw_set_color(c_orange);
    draw_text(20, status_y, "STATUS:");
    status_y += 20;
    for (var i = 0; i < array_length(current_player.status_ailments); i++) {
        var ailment = current_player.status_ailments[i];
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
        draw_text(40, status_y, ailment_text);
        status_y += 18;
    }
}

// Set hand_empty flag
if (array_length(current_player.hand) == 0) {
    current_player.hand_empty = true;
} else {
    current_player.hand_empty = false;
}

var button_x = gui_w - 200;
var button_y = gui_h - 100;
var button_w = 180;
var button_h = 50;

var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);
var button_hover = (mouse_x_gui >= button_x && mouse_x_gui <= button_x + button_w && mouse_y_gui >= button_y && mouse_y_gui <= button_y + button_h);

// END TURN button
draw_set_color(button_hover ? c_lime : c_yellow);
draw_rectangle(button_x, button_y, button_x + button_w, button_y + button_h, false);
draw_set_color(c_black);
draw_rectangle(button_x, button_y, button_x + button_w, button_y + button_h, true);
draw_set_color(c_black); // Text color - black on yellow/lime background
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(button_x + button_w/2, button_y + button_h/2, "END TURN");
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// BASE ATTACK button (top)
var attack_button_x = button_x;
var attack_button_y = button_y - (button_h * 2) - 20; // Above REDRAW button
var attack_button_hover = (mouse_x_gui >= attack_button_x && mouse_x_gui <= attack_button_x + button_w && mouse_y_gui >= attack_button_y && mouse_y_gui <= attack_button_y + button_h);

draw_set_color(attack_button_hover ? c_aqua : c_blue);
draw_rectangle(attack_button_x, attack_button_y, attack_button_x + button_w, attack_button_y + button_h, false);
draw_set_color(c_black);
draw_rectangle(attack_button_x, attack_button_y, attack_button_x + button_w, attack_button_y + button_h, true);
draw_set_color(c_white); // White text on blue/aqua background
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(attack_button_x + button_w/2, attack_button_y + button_h/2, "HERO ATTACK");
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// REDRAW/SHUFFLE button (middle)
var shuffle_button_x = button_x;
var shuffle_button_y = button_y - button_h - 10; // Above END TURN button
var shuffle_button_hover = (mouse_x_gui >= shuffle_button_x && mouse_x_gui <= shuffle_button_x + button_w && mouse_y_gui >= shuffle_button_y && mouse_y_gui <= shuffle_button_y + button_h);

draw_set_color(shuffle_button_hover ? c_orange : c_red);
draw_rectangle(shuffle_button_x, shuffle_button_y, shuffle_button_x + button_w, shuffle_button_y + button_h, false);
draw_set_color(c_black);
draw_rectangle(shuffle_button_x, shuffle_button_y, shuffle_button_x + button_w, shuffle_button_y + button_h, true);
draw_set_color(c_white); // White text on red/orange background
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(shuffle_button_x + button_w/2, shuffle_button_y + button_h/2, "REDRAW");
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(c_yellow);
draw_text(20, gui_h - 80, "Drag cards to play, or click END TURN");
draw_text(20, gui_h - 50, "Deck: " + string(array_length(o_game.deck)) + " cards remaining");
