/// @description Card interaction
if (played) return;

var hovering = (mouse_x >= x && mouse_x <= x + card_width && mouse_y >= y && mouse_y <= y + card_height);

if (!is_dragging) {
    x = lerp(x, target_x, 0.2);
    y = lerp(y, target_y, 0.2);
    
    if (hovering && mouse_check_button_pressed(mb_left)) {
        if (can_afford) {
            is_dragging = true;
            drag_offset_x = mouse_x - x;
            drag_offset_y = mouse_y - y;
            show_debug_message("Started dragging card: " + card_data.title);
        } else {
            show_debug_message("Cannot afford card: " + card_data.title + " (Cost: " + string(card_data.cost) + ", MP: " + string(o_game.players[o_game.whosturn].mp) + ")");
        }
    }
} else {
    x = mouse_x - drag_offset_x;
    y = mouse_y - drag_offset_y;
    
    if (mouse_check_button_released(mb_left)) {
        is_dragging = false;
        show_debug_message("Released card at y: " + string(y) + " threshold: " + string(start_y - 100));
        
        if (y < start_y - 100) {
            played = true;
            with (o_game) {
                var current_player = players[whosturn];
                game_process_card(other.card_data, current_player, players[other.card_data.target]);
                array_delete(current_player.hand, other.card_index, 1);
                show_debug_message("Played card: " + other.card_data.title);
            }
            instance_destroy();
        }
    }
}