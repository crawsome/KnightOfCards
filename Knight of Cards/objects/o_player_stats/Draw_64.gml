/// @description Draw game UI
if (o_game.game_state != "playing") {
    return;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

draw_set_font(f_menu_font_large);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var current_player = o_game.players[o_game.whosturn];
var other_player = o_game.players[o_game.whosturn == 0 ? 1 : 0];

draw_set_color(c_yellow);
draw_text(20, 20, "TURN " + string(o_game.turncount) + " - PLAYER " + string(o_game.whosturn + 1));

draw_set_font(f_menu_font_small);
draw_set_color(c_white);
draw_text(20, 60, "Your Hero: " + current_player.title);
draw_set_color(c_aqua);
draw_text(20, 85, "HP: " + string(current_player.hp) + " / MP: " + string(current_player.mp) + "/" + string(o_game.mp_pool));
draw_set_color(c_white);
draw_text(20, 110, "ATK: " + string(current_player.atk) + " DEF: " + string(current_player.armor));

draw_set_color(c_red);
draw_text(gui_w - 300, 60, "Enemy: " + other_player.title);
draw_text(gui_w - 300, 85, "HP: " + string(other_player.hp) + " MP: " + string(other_player.mp));
draw_text(gui_w - 300, 110, "ATK: " + string(other_player.atk) + " DEF: " + string(other_player.armor));

draw_set_color(c_lime);
draw_text(20, 150, "YOUR HAND:");

var hand_y = 190;
var line_height = 30;

if (array_length(current_player.hand) == 0) {
    draw_set_color(c_gray);
    draw_text(40, hand_y, "Hand is empty!");
    current_player.hand_empty = true;
} else {
    current_player.hand_empty = false;
    for (var i = 0; i < array_length(current_player.hand); i++) {
        var card = current_player.hand[i];
        var can_afford = (card.cost <= current_player.mp);
        
        draw_set_color(can_afford ? c_white : c_gray);
        
        var card_text = string(i + 1) + ". " + card.title + " - Cost: " + string(card.cost) + "MP";
        draw_text(40, hand_y, card_text);
        
        hand_y += line_height;
    }
}

var button_x = gui_w - 200;
var button_y = gui_h - 100;
var button_w = 180;
var button_h = 50;

var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);
var button_hover = (mouse_x_gui >= button_x && mouse_x_gui <= button_x + button_w && mouse_y_gui >= button_y && mouse_y_gui <= button_y + button_h);

draw_set_color(button_hover ? c_lime : c_yellow);
draw_rectangle(button_x, button_y, button_x + button_w, button_y + button_h, false);
draw_set_color(c_black);
draw_rectangle(button_x, button_y, button_x + button_w, button_y + button_h, true);
draw_set_color(button_hover ? c_lime : c_yellow);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(button_x + button_w/2, button_y + button_h/2, "END TURN");
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(c_yellow);
draw_text(20, gui_h - 80, "Drag cards to play, or click END TURN");
draw_text(20, gui_h - 50, "Deck: " + string(array_length(o_game.deck)) + " cards remaining");
