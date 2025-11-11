/// @description Game initialization
game_state = "menu";
players = [];
deck = [];
all_cards = [];
hand_size = 5;
mp_pool = 0;
whosturn = 0;
turncount = 1;
deck_empty = false;
playing = false;

var menu_instance = instance_create_layer(0, 0, "Instances", o_mainmenu);
show_debug_message("Created menu instance: " + string(menu_instance));

instance_create_layer(0, 0, "Instances", o_card_maker);