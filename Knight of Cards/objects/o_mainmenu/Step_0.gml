/// @description Handle menu input with mouse
if (array_length(available_heroes) == 0) {
    return; // No heroes available
}

var center_x = display_get_gui_width() / 2;
var center_y = display_get_gui_height() / 2;
var y_start = center_y - 50 + 60; // Same as Draw event
var line_height = 30;

var mouse_x_pos = device_mouse_x_to_gui(0);
var mouse_y_pos = device_mouse_y_to_gui(0);

// Check mouse hover over menu items
var old_selection = menu_selection;
menu_selection = -1;
for (var i = 0; i < array_length(available_heroes); i++) {
    var item_y = y_start + (i * line_height);
    if (mouse_y_pos >= item_y && mouse_y_pos < item_y + line_height) {
        if (mouse_x_pos >= center_x - 200 && mouse_x_pos <= center_x + 200) {
            menu_selection = i;
            break;
        }
    }
}

// Selection on mouse click
if (mouse_check_button_pressed(mb_left) && menu_selection >= 0) {
    if (menu_state == "select_hero_1") {
        selected_hero_1 = available_heroes[menu_selection];
        array_delete(available_heroes, menu_selection, 1);
        menu_selection = 0;
        menu_state = "select_hero_2";
    } else if (menu_state == "select_hero_2") {
        selected_hero_2 = available_heroes[menu_selection];
        show_debug_message("Both heroes selected, initializing game...");
        
        with (o_game) {
            players[0] = other.heroes[other.selected_hero_1];
            players[1] = other.heroes[other.selected_hero_2];
            players[0].alive = true;
            players[1].alive = true;
            show_debug_message("Players set: " + players[0].title + " vs " + players[1].title);
            
            all_cards = game_load_cards_from_csv();
            show_debug_message("Loaded " + string(array_length(all_cards)) + " card types");
            deck = game_create_deck(all_cards);
            show_debug_message("Created deck with " + string(array_length(deck)) + " cards");
            deck = game_shuffle_deck(deck);
            
            for (var i = 0; i < hand_size; i++) {
                if (array_length(deck) > 0) {
                    array_push(players[0].hand, game_draw_card(deck));
                }
            }
            show_debug_message("Player 1 hand: " + string(array_length(players[0].hand)) + " cards");
            
            for (var i = 0; i < hand_size; i++) {
                if (array_length(deck) > 0) {
                    array_push(players[1].hand, game_draw_card(deck));
                }
            }
            show_debug_message("Player 2 hand: " + string(array_length(players[1].hand)) + " cards");
            
            mp_pool = 1;
            players[0].mp = mp_pool;
            players[1].mp = mp_pool;
            
            playing = true;
            game_state = "playing";
            show_debug_message("Game state set to: " + game_state);
        }
        
        instance_create_layer(0, 0, "Instances", o_player_stats);
        instance_destroy();
    }
}
