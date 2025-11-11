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

// Card color globals - 3 colors per suit (background, text, border)
// Diamonds
global.card_diamonds_bg = make_color_rgb(240, 240, 240); // Light silver/white background
global.card_diamonds_text = make_color_rgb(192, 192, 192); // Silver text
global.card_diamonds_border = c_white; // White border

// Hearts
global.card_hearts_bg = make_color_rgb(255, 240, 245); // Light pink background
global.card_hearts_text = make_color_rgb(255, 192, 203); // Pink text
global.card_hearts_border = c_white; // White border

// Clubs
global.card_clubs_bg = make_color_rgb(245, 235, 220); // Light brown/tan background
global.card_clubs_text = make_color_rgb(139, 69, 19); // Brown text
global.card_clubs_border = c_white; // White border

// Spades
global.card_spades_bg = c_black; // Black background
global.card_spades_text = c_white; // White text
global.card_spades_border = c_white; // White border

var menu_instance = instance_create_layer(0, 0, "Instances", o_mainmenu);
show_debug_message("Created menu instance: " + string(menu_instance));

instance_create_layer(0, 0, "Instances", o_card_maker);