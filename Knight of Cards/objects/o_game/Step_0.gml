/// @description Game step logic
if (game_state == "playing") {
    if (!playing) {
        game_state = "gameover";
        return;
    }
    
    var current_player = players[whosturn];
    
    if (current_player.hp <= 0) {
        current_player.alive = false;
        playing = false;
        game_state = "gameover";
        show_debug_message("Player " + string(whosturn + 1) + " died!");
    }
    
    if (deck_empty && players[0].hand_empty && players[1].hand_empty) {
        playing = false;
        game_state = "gameover";
        show_debug_message("Game over - deck and hands empty!");
    }
    
    if (whosturn == 0) {
        for (var i = 1; i <= 9; i++) {
            if (keyboard_check_pressed(ord(string(i)))) {
                var card_index = i - 1;
                if (card_index < array_length(current_player.hand)) {
                    var card = current_player.hand[card_index];
                    if (card.cost <= current_player.mp) {
                        game_process_card(card, current_player, players[card.target]);
                        array_delete(current_player.hand, card_index, 1);
                        show_debug_message("Played card: " + card.title);
                    } else {
                        show_debug_message("Not enough MP!");
                    }
                }
            }
        }
        
        if (keyboard_check_pressed(vk_space)) {
            combat_log_add(whosturn, "Ended turn");
            current_player.mp = 0;
            current_player.endturn = true;
            
            while (array_length(current_player.hand) < hand_size && array_length(deck) > 0) {
                array_push(current_player.hand, game_draw_card(deck));
            }
            
            if (array_length(deck) == 0) {
                deck_empty = true;
            }
            
            whosturn = 1;
            
            if (turncount % 2 == 0) {
                mp_pool++;
            }
            
            players[whosturn].mp = mp_pool;
            current_player.endturn = false;
            
            turncount++;
            show_debug_message("Turn ended. Now Player " + string(whosturn + 1) + "'s turn");
        }
    } else {
        var playable_cards = [];
        for (var i = 0; i < array_length(current_player.hand); i++) {
            if (current_player.hand[i].cost <= current_player.mp) {
                array_push(playable_cards, i);
            }
        }
        
        if (array_length(playable_cards) > 0 && current_player.mp > 0) {
            var card_index = playable_cards[irandom(array_length(playable_cards) - 1)];
            var card = current_player.hand[card_index];
            game_process_card(card, current_player, players[card.target]);
            array_delete(current_player.hand, card_index, 1);
            show_debug_message("AI played card: " + card.title);
        } else {
            combat_log_add(whosturn, "Ended turn");
            current_player.mp = 0;
            current_player.endturn = true;
            
            while (array_length(current_player.hand) < hand_size && array_length(deck) > 0) {
                array_push(current_player.hand, game_draw_card(deck));
            }
            
            if (array_length(deck) == 0) {
                deck_empty = true;
            }
            
            whosturn = 0;
            
            if (turncount % 2 == 0) {
                mp_pool++;
            }
            
            players[whosturn].mp = mp_pool;
            current_player.endturn = false;
            
            turncount++;
            show_debug_message("AI turn ended. Now Player " + string(whosturn + 1) + "'s turn");
        }
    }
}
