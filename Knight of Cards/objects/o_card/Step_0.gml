/// @description Card interaction
if (played) return;

var hovering = (mouse_x >= x && mouse_x <= x + card_width && mouse_y >= y && mouse_y <= y + card_height);

// Hover zoom
target_scale = hovering ? 1.2 : 1.0;
hover_scale = lerp(hover_scale, target_scale, 0.2);

if (!is_dragging) {
    x = lerp(x, target_x, 0.2);
    y = lerp(y, target_y, 0.2);
    velocity_x = lerp(velocity_x, 0, 0.3);
    velocity_y = lerp(velocity_y, 0, 0.3);
    tilt_amount_x = lerp(tilt_amount_x, 0, 0.3);
    tilt_amount_y = lerp(tilt_amount_y, 0, 0.3);
    
    if (hovering && mouse_check_button_pressed(mb_left)) {
        if (can_afford) {
            is_dragging = true;
            drag_offset_x = mouse_x - x;
            drag_offset_y = mouse_y - y;
            prev_x = x;
            prev_y = y;
            velocity_x = 0;
            velocity_y = 0;
            show_debug_message("Started dragging card: " + card_data.title);
        } else {
            show_debug_message("Cannot afford card: " + card_data.title + " (Cost: " + string(card_data.cost) + ", MP: " + string(o_game.players[o_game.whosturn].mp) + ")");
        }
    }
} else {
    var new_x = mouse_x - drag_offset_x;
    var new_y = mouse_y - drag_offset_y;
    
    // Smooth velocity calculation to reduce jitter
    var raw_velocity_x = new_x - prev_x;
    var raw_velocity_y = new_y - prev_y;
    velocity_x = lerp(velocity_x, raw_velocity_x, 0.5);
    velocity_y = lerp(velocity_y, raw_velocity_y, 0.5);
    
    prev_x = new_x;
    prev_y = new_y;
    
    x = new_x;
    y = new_y;
    
    // Smooth tilt amount changes and reduce multiplier
    var target_tilt_x = clamp(velocity_x * 0.8, -40, 40);
    var target_tilt_y = clamp(velocity_y * 0.8, -40, 40);
    tilt_amount_x = lerp(tilt_amount_x, target_tilt_x, 0.4);
    tilt_amount_y = lerp(tilt_amount_y, target_tilt_y, 0.4);
    
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