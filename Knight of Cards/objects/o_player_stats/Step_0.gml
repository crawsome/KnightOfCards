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

// BASE ATTACK button (top)
var attack_button_x = button_x;
var attack_button_y = button_y - (button_h * 2) - 20; // Above REDRAW button
var attack_button_hover = (mouse_x_gui >= attack_button_x && mouse_x_gui <= attack_button_x + button_w && mouse_y_gui >= attack_button_y && mouse_y_gui <= attack_button_y + button_h);

if (attack_button_hover && mouse_check_button_pressed(mb_left)) {
    // Base Attack - attack enemy with current ATK stat
    var current_player = o_game.players[o_game.whosturn];
    var other_player = o_game.players[o_game.whosturn == 0 ? 1 : 0];
    
    // Calculate damage: ATK - DEF (minimum 1 damage)
    var damage = max(1, current_player.atk - other_player.armor);
    player_mod_hp(other_player, -damage);
    
    combat_log_add(o_game.whosturn, "Hero Attack dealt " + string(damage) + " damage to " + other_player.title);
    
    show_debug_message("Base attack! " + string(damage) + " damage dealt to " + other_player.title);
    
    // End turn
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
        o_game.ai_timer = 0; // Reset timer for AI turn start
    }
    
    if (o_game.turncount % 2 == 0) {
        o_game.mp_pool++;
    }
    
    o_game.players[o_game.whosturn].mp = o_game.mp_pool;
    current_player.endturn = false;
    
    o_game.turncount++;
    show_debug_message("Turn ended. Now Player " + string(o_game.whosturn + 1) + "'s turn");
}

// REDRAW/SHUFFLE button (middle)
var shuffle_button_x = button_x;
var shuffle_button_y = button_y - button_h - 10; // Above END TURN button
var shuffle_button_hover = (mouse_x_gui >= shuffle_button_x && mouse_x_gui <= shuffle_button_x + button_w && mouse_y_gui >= shuffle_button_y && mouse_y_gui <= shuffle_button_y + button_h);

if (shuffle_button_hover && mouse_check_button_pressed(mb_left)) {
    // Redraw/Shuffle - forfeit turn by shuffling hand back into deck
    var current_player = o_game.players[o_game.whosturn];
    
    combat_log_add(o_game.whosturn, "Redrew hand");
    
    // Shuffle hand back into deck
    for (var i = 0; i < array_length(current_player.hand); i++) {
        array_push(o_game.deck, current_player.hand[i]);
    }
    current_player.hand = [];
    
    // Shuffle deck
    o_game.deck = game_shuffle_deck(o_game.deck);
    
    // Draw new hand
    while (array_length(current_player.hand) < o_game.hand_size && array_length(o_game.deck) > 0) {
        array_push(current_player.hand, game_draw_card(o_game.deck));
    }
    
    if (array_length(o_game.deck) == 0) {
        o_game.deck_empty = true;
    }
    
    // End turn
    current_player.mp = 0;
    current_player.endturn = true;
    
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
    show_debug_message("Hand redrawn. Turn ended. Now Player " + string(o_game.whosturn + 1) + "'s turn");
}

if (button_hover && mouse_check_button_pressed(mb_left)) {
    var current_player = o_game.players[o_game.whosturn];
    combat_log_add(o_game.whosturn, "Ended turn");
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
        o_game.ai_timer = 0; // Reset timer for AI turn start
    }
    
    if (o_game.turncount % 2 == 0) {
        o_game.mp_pool++;
    }
    
    o_game.players[o_game.whosturn].mp = o_game.mp_pool;
    current_player.endturn = false;
    
    o_game.turncount++;
    show_debug_message("Turn ended. Now Player " + string(o_game.whosturn + 1) + "'s turn");
}
