/// @description Main menu initialization
show_debug_message("o_mainmenu Create event running");
menu_state = "select_hero_1";
selected_hero_1 = -1;
selected_hero_2 = -1;
heroes = game_load_heroes_from_csv();
available_heroes = [];

if (array_length(heroes) > 0) {
    for (var i = 0; i < array_length(heroes); i++) {
        array_push(available_heroes, i);
    }
} else {
    show_debug_message("Error: No heroes loaded from CSV!");
}

menu_selection = 0;
show_debug_message("Menu initialized with " + string(array_length(available_heroes)) + " heroes");
