/// @description Draw card
if (card_data == -1) return;

var card_color = can_afford ? c_white : c_dkgray;
var card_bg = can_afford ? c_black : c_gray;

draw_set_color(card_bg);
draw_rectangle(x, y, x + card_width, y + card_height, false);

draw_set_color(card_color);
draw_rectangle(x, y, x + card_width, y + card_height, true);

draw_set_font(f_font_small);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(card_color);

var card_text_y = y + 10;
draw_text_ext(x + card_width/2, card_text_y, card_data.title, 12, card_width - 10);

card_text_y += 40;
draw_text(x + card_width/2, card_text_y, "Cost: " + string(card_data.cost) + " MP");

card_text_y += 20;
draw_set_font(f_font_small);
draw_text_ext(x + card_width/2, card_text_y, card_data.info, 12, card_width - 10);

card_text_y = y + card_height - 60;
if (card_data.hp != 0) draw_text(x + card_width/2, card_text_y, "HP: " + string(card_data.hp));
card_text_y += 15;
if (card_data.mp != 0) draw_text(x + card_width/2, card_text_y, "MP: " + string(card_data.mp));
card_text_y += 15;
if (card_data.armor != 0) draw_text(x + card_width/2, card_text_y, "Armor: " + string(card_data.armor));
card_text_y += 15;
if (card_data.atk != 0) draw_text(x + card_width/2, card_text_y, "Atk: " + string(card_data.atk));
