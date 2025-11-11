/// @description Handle button clicks
if (o_game.game_state != "playing") {
    return;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var button_x = gui_w - 200;
var button_y = gui_h - 100;
var button_w = 180;
var button_h = 50;

var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);
var button_hover = (mouse_x_gui >= button_x && mouse_x_gui <= button_x + button_w && mouse_y_gui >= button_y && mouse_y_gui <= button_y + button_h);

if (button_hover && mouse_check_button_pressed(mb_left)) {
    var current_player = o_game.players[o_game.whosturn];
    current_player.mp = 0;
    current_player.endturn = true;
    
    while (array_length(current_player.hand) < o_game.hand_size && array_length(o_game.deck) > 0) {
        array_push(current_player.hand, game_draw_card(o_game.deck));
    }
    
    if (array_length(o_game.deck) == 0) {
        o_game.deck_empty = true;
    }
    
    if (o_game.whosturn == 1) {
        o_game.whosturn = 0;
    } else {
        o_game.whosturn = 1;
    }
    
    if (o_game.turncount % 2 == 0) {
        o_game.mp_pool++;
    }
    
    o_game.players[o_game.whosturn].mp = o_game.mp_pool;
    current_player.endturn = false;
    
    o_game.turncount++;
    show_debug_message("Turn ended. Now Player " + string(o_game.whosturn + 1) + "'s turn");
}
