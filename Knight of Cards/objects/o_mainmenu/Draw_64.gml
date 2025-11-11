/// @description Draw main menu

var center_x = display_get_gui_width() / 2;
var center_y = display_get_gui_height() / 2;

draw_set_font(f_menu_font_large);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text(center_x, 50, "KNIGHT OF CARDS");

draw_set_font(f_menu_font_small);
draw_set_color(c_white);

if (array_length(available_heroes) == 0) {
    draw_text(center_x, center_y, "No heroes loaded!");
    return;
}

var y_start = center_y - 50;
var line_height = 30;

if (menu_state == "select_hero_1") {
    draw_set_color(c_yellow);
    draw_text(center_x, y_start, "Player 1 - Choose a Hero:");
    y_start += line_height * 2;
    
    for (var i = 0; i < array_length(available_heroes); i++) {
        var hero_index = available_heroes[i];
        var hero = heroes[hero_index];
        
        var hero_color = (hero.color == "red") ? c_red : c_white;
        draw_set_color((i == menu_selection) ? c_yellow : hero_color);
        
        var prefix = (i == menu_selection) ? "> " : "  ";
        draw_text(center_x, y_start, prefix + hero.title);
        y_start += line_height;
    }
} else if (menu_state == "select_hero_2") {
    draw_set_color(c_aqua);
    draw_text(center_x, y_start, "Player 2 - Choose a Hero:");
    y_start += line_height * 2;
    
    for (var i = 0; i < array_length(available_heroes); i++) {
        var hero_index = available_heroes[i];
        var hero = heroes[hero_index];
        
        var hero_color = (hero.color == "red") ? c_red : c_white;
        draw_set_color((i == menu_selection) ? c_yellow : hero_color);
        
        var prefix = (i == menu_selection) ? "> " : "  ";
        draw_text(center_x, y_start, prefix + hero.title);
        y_start += line_height;
    }
    
    y_start += line_height;
    draw_set_color(c_lime);
    draw_text(center_x, y_start, "Player 1: " + heroes[selected_hero_1].title);
}
