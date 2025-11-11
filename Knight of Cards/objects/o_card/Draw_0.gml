/// @description Draw card
if (card_data == -1) return;

// Create or recreate surface if needed
if (!surface_exists(card_surface)) {
    card_surface = surface_create(card_width, card_height);
}

// Draw card content to surface
surface_set_target(card_surface);

// Get colors from global variables based on suit
var suit_bg_color = c_white;
var suit_text_color = c_black;
var suit_border_color = c_white;
if (card_data.suit == "Diamonds") {
    suit_bg_color = global.card_diamonds_bg;
    suit_text_color = global.card_diamonds_text;
    suit_border_color = global.card_diamonds_border;
} else if (card_data.suit == "Hearts") {
    suit_bg_color = global.card_hearts_bg;
    suit_text_color = global.card_hearts_text;
    suit_border_color = global.card_hearts_border;
} else if (card_data.suit == "Clubs") {
    suit_bg_color = global.card_clubs_bg;
    suit_text_color = global.card_clubs_text;
    suit_border_color = global.card_clubs_border;
} else if (card_data.suit == "Spades") {
    suit_bg_color = global.card_spades_bg;
    suit_text_color = global.card_spades_text;
    suit_border_color = global.card_spades_border;
}

var card_bg = can_afford ? suit_bg_color : c_dkgray;
var card_text_color = can_afford ? suit_text_color : c_ltgray;
var card_border_color = can_afford ? suit_border_color : c_gray;

// Clear surface with background color
draw_clear(card_bg);

// Draw card background
draw_set_color(card_bg);
draw_rectangle(0, 0, card_width, card_height, false);

// Draw card border
draw_set_color(card_border_color);
draw_rectangle(0, 0, card_width, card_height, true);

// Get suit symbol
var suit_symbol = "?";
if (card_data.suit == "Spades") suit_symbol = "♠";
else if (card_data.suit == "Clubs") suit_symbol = "♣";
else if (card_data.suit == "Hearts") suit_symbol = "♥";
else if (card_data.suit == "Diamonds") suit_symbol = "♦";

// Draw playing card corners - top left
draw_set_font(f_font_small);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(card_text_color);
var corner_size = 20;
draw_text(5, 5, card_data.card_name);
draw_text(5, 18, suit_symbol);

// Draw playing card corners - top right (rotated)
draw_set_halign(fa_right);
draw_text(card_width - 5, 5, card_data.card_name);
draw_text(card_width - 5, 18, suit_symbol);

// Draw playing card corners - bottom left (upside down)
draw_set_valign(fa_bottom);
draw_text(5, card_height - 5, card_data.card_name);
draw_text(5, card_height - 18, suit_symbol);

// Draw playing card corners - bottom right (upside down)
draw_set_halign(fa_right);
draw_text(card_width - 5, card_height - 5, card_data.card_name);
draw_text(card_width - 5, card_height - 18, suit_symbol);

// Draw center content
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(card_text_color);

var card_text_y = 45;
draw_text_ext(card_width/2, card_text_y, card_data.title, 12, card_width - 20);

card_text_y += 35;
draw_text(card_width/2, card_text_y, "Cost: " + string(card_data.cost) + " MP");

card_text_y += 20;
draw_text_ext(card_width/2, card_text_y, card_data.info, 10, card_width - 20);

// Draw stats at bottom
card_text_y = card_height - 60;
draw_set_color(card_text_color);
if (card_data.hp != 0) draw_text(card_width/2, card_text_y, "HP: " + string(card_data.hp));
card_text_y += 15;
if (card_data.mp != 0) draw_text(card_width/2, card_text_y, "MP: " + string(card_data.mp));
card_text_y += 15;
if (card_data.armor != 0) draw_text(card_width/2, card_text_y, "Armor: " + string(card_data.armor));
card_text_y += 15;
if (card_data.atk != 0) draw_text(card_width/2, card_text_y, "Atk: " + string(card_data.atk));

surface_reset_target();

// Calculate perspective transformation based on tilt
var tilt_factor_x = tilt_amount_x / 50.0; // Normalize to -1 to 1
var tilt_factor_y = tilt_amount_y / 50.0; // Normalize to -1 to 1
var perspective_scale = 1.0; // How much width perspective effect (STRONG for left-right)
var height_perspective = 0.15; // How much height perspective effect (REDUCED for top-down)

// Apply hover scale
var scaled_width = card_width * hover_scale;
var scaled_height = card_height * hover_scale;
var center_x = x + card_width / 2;
var center_y = y + card_height / 2;

// Horizontal perspective: left/right tilt
// When tilting left (negative), left side gets shorter (closer), right side longer (further)
// When tilting right (positive), right side gets shorter (closer), left side longer (further)
var left_scale = 1.0 - (tilt_factor_x * perspective_scale);
var right_scale = 1.0 + (tilt_factor_x * perspective_scale);

// Vertical perspective: up/down tilt
// When tilting up (negative), top gets shorter (closer), bottom longer (further)
// When tilting down (positive), bottom gets shorter (closer), top longer (further)
var top_scale = 1.0 - (tilt_factor_y * height_perspective);
var bottom_scale = 1.0 + (tilt_factor_y * height_perspective);

// Horizontal offset for depth: closer side moves toward center
var horizontal_offset = abs(tilt_factor_x) * perspective_scale * card_width * 0.2;

// Vertical offset for depth: closer side moves up/down
var vertical_offset = abs(tilt_factor_y) * height_perspective * card_height * 0.3;

// Top corners - apply both horizontal and vertical perspective with hover scale
var top_left_x = center_x - (scaled_width / 2) * left_scale * top_scale;
var top_left_y = center_y - (scaled_height / 2) * top_scale - (tilt_factor_y < 0 ? vertical_offset : 0) - (tilt_factor_x < 0 ? horizontal_offset * 0.3 : 0);
var top_right_x = center_x + (scaled_width / 2) * right_scale * top_scale;
var top_right_y = center_y - (scaled_height / 2) * top_scale - (tilt_factor_y < 0 ? vertical_offset : 0) - (tilt_factor_x > 0 ? horizontal_offset * 0.3 : 0);

// Bottom corners - apply both horizontal and vertical perspective with hover scale
var bottom_left_x = center_x - (scaled_width / 2) * left_scale * bottom_scale;
var bottom_left_y = center_y + (scaled_height / 2) * bottom_scale - (tilt_factor_y > 0 ? vertical_offset : 0) - (tilt_factor_x < 0 ? horizontal_offset * 0.3 : 0);
var bottom_right_x = center_x + (scaled_width / 2) * right_scale * bottom_scale;
var bottom_right_y = center_y + (scaled_height / 2) * bottom_scale - (tilt_factor_y > 0 ? vertical_offset : 0) - (tilt_factor_x > 0 ? horizontal_offset * 0.3 : 0);

// Draw surface as quad with perspective transformation
draw_primitive_begin_texture(pr_trianglestrip, surface_get_texture(card_surface));
draw_vertex_texture(top_left_x, top_left_y, 0, 0);
draw_vertex_texture(top_right_x, top_right_y, 1, 0);
draw_vertex_texture(bottom_left_x, bottom_left_y, 0, 1);
draw_vertex_texture(bottom_right_x, bottom_right_y, 1, 1);
draw_primitive_end();
