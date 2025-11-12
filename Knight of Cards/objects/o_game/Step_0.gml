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
            ai_timer = 0; // Reset timer for AI turn start
            
            if (turncount % 2 == 0) {
                mp_pool++;
            }
            
            players[whosturn].mp = mp_pool;
            current_player.endturn = false;
            
            turncount++;
            show_debug_message("Turn ended. Now Player " + string(whosturn + 1) + "'s turn");
        }
    } else {
        // AI turn - wait for delay timer before taking action
        if (ai_timer > 0) {
            ai_timer--;
            return;
        }
        
        var playable_cards = [];
        for (var i = 0; i < array_length(current_player.hand); i++) {
            if (current_player.hand[i].cost <= current_player.mp) {
                array_push(playable_cards, i);
            }
        }
        
        // Check if hero attack can kill enemy
        var hero_attack_damage = max(1, current_player.atk - players[0].armor);
        var hero_attack_can_kill = hero_attack_damage >= players[0].hp;
        
        // If hero attack can kill, do it
        if (hero_attack_can_kill && current_player.atk > 0) {
            var damage = max(1, current_player.atk - players[0].armor);
            player_mod_hp(players[0], -damage);
            combat_log_add(whosturn, "Hero Attack dealt " + string(damage) + " damage to " + players[0].title);
            
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
            ai_timer = 0;
            show_debug_message("AI Hero Attack! " + string(damage) + " damage. Turn ended.");
            return;
        }
        
        if (array_length(playable_cards) > 0 && current_player.mp > 0) {
            // Check AI survival status - prioritize survival first
            var ai_hp_percent = current_player.hp / current_player.basehp;
            var enemy_player = players[0];
            var enemy_hp_percent = enemy_player.hp / enemy_player.basehp;
            
            // Separate cards into harmful (to enemy) and helpful (to self)
            var harmful_cards = []; // target == 1 with negative effects
            var helpful_cards = []; // target == 0 with positive effects
            
            for (var i = 0; i < array_length(playable_cards); i++) {
                var card_idx = playable_cards[i];
                var card = current_player.hand[card_idx];
                
                // Skip Heart and Diamond cards that target enemy (they're helpful cards)
                if (card.target == 1 && (card.suit == "Hearts" || card.suit == "Diamonds")) {
                    continue;
                }
                // Skip Clubs and Spades cards that target self (they're damage cards)
                if (card.target == 0 && (card.suit == "Clubs" || card.suit == "Spades")) {
                    continue;
                }
                
                // Harmful card: targets enemy (target == 1) with negative effects
                if (card.target == 1 && (card.hp < 0 || card.armor < 0 || card.atk < 0 || card.mp < 0)) {
                    array_push(harmful_cards, card_idx);
                }
                // Helpful card: targets self (target == 0) with positive effects
                else if (card.target == 0 && (card.hp > 0 || card.armor > 0 || card.atk > 0 || card.mp > 0)) {
                    array_push(helpful_cards, card_idx);
                }
            }
            
            var card_index = -1;
            
            // Check if any harmful card can kill enemy
            var can_kill_enemy = false;
            for (var i = 0; i < array_length(harmful_cards); i++) {
                var card = current_player.hand[harmful_cards[i]];
                if (card.hp < 0 && abs(card.hp) >= enemy_player.hp) {
                    can_kill_enemy = true;
                    break;
                }
            }
            
            // PRIORITY 1: If enemy can be killed, finish them (survival doesn't matter if we win)
            if (can_kill_enemy && array_length(harmful_cards) > 0) {
                // Find card that can kill
                var kill_cards = [];
                for (var i = 0; i < array_length(harmful_cards); i++) {
                    var card = current_player.hand[harmful_cards[i]];
                    if (card.hp < 0 && abs(card.hp) >= enemy_player.hp) {
                        array_push(kill_cards, harmful_cards[i]);
                    }
                }
                if (array_length(kill_cards) > 0) {
                    card_index = kill_cards[irandom(array_length(kill_cards) - 1)];
                }
            }
            // PRIORITY 2: If AI is critically low (< 25%), prioritize survival
            else if (ai_hp_percent < 0.25) {
                if (array_length(helpful_cards) > 0) {
                    card_index = helpful_cards[irandom(array_length(helpful_cards) - 1)];
                } else if (array_length(harmful_cards) > 0) {
                    card_index = harmful_cards[irandom(array_length(harmful_cards) - 1)];
                }
            }
            // PRIORITY 3: If enemy is low HP (< 30%) and AI is not critically low, finish them
            else if (enemy_hp_percent < 0.3 && ai_hp_percent >= 0.25) {
                if (array_length(harmful_cards) > 0) {
                    card_index = harmful_cards[irandom(array_length(harmful_cards) - 1)];
                } else if (array_length(helpful_cards) > 0) {
                    card_index = helpful_cards[irandom(array_length(helpful_cards) - 1)];
                }
            }
            // PRIORITY 4: If AI is low HP (< 50%), prioritize healing
            else if (ai_hp_percent < 0.5) {
                if (array_length(helpful_cards) > 0) {
                    card_index = helpful_cards[irandom(array_length(helpful_cards) - 1)];
                } else if (array_length(harmful_cards) > 0) {
                    card_index = harmful_cards[irandom(array_length(harmful_cards) - 1)];
                }
            }
            // PRIORITY 5: If AI is healthy, attack enemy
            else if (ai_hp_percent >= 0.5) {
                if (array_length(harmful_cards) > 0) {
                    card_index = harmful_cards[irandom(array_length(harmful_cards) - 1)];
                } else if (array_length(helpful_cards) > 0) {
                    card_index = helpful_cards[irandom(array_length(helpful_cards) - 1)];
                }
            }
            
            // Play any available card that doesn't damage self or help enemy
            if (card_index == -1 && array_length(playable_cards) > 0) {
                var safe_cards = [];
                for (var i = 0; i < array_length(playable_cards); i++) {
                    var card_idx = playable_cards[i];
                    var card = current_player.hand[card_idx];
                    // Skip cards that damage self (target == 0 with negative effects)
                    if (card.target == 0 && (card.hp < 0 || card.armor < 0 || card.atk < 0 || card.mp < 0)) {
                        continue;
                    }
                    // Skip Heart and Diamond cards that target enemy (they're helpful cards)
                    if (card.target == 1 && (card.suit == "Hearts" || card.suit == "Diamonds")) {
                        continue;
                    }
                    // Skip Clubs and Spades cards that target self (they're damage cards)
                    if (card.target == 0 && (card.suit == "Clubs" || card.suit == "Spades")) {
                        continue;
                    }
                    // Skip ALL cards that target enemy unless they have negative effects (damage enemy)
                    if (card.target == 1 && !(card.hp < 0 || card.armor < 0 || card.atk < 0 || card.mp < 0)) {
                        continue;
                    }
                    array_push(safe_cards, card_idx);
                }
                if (array_length(safe_cards) > 0) {
                    card_index = safe_cards[irandom(array_length(safe_cards) - 1)];
                }
            }
            
            if (card_index >= 0) {
                var card = current_player.hand[card_index];
                game_process_card(card, current_player, players[card.target]);
                array_delete(current_player.hand, card_index, 1);
                show_debug_message("AI played card: " + card.title);
                ai_timer = ai_delay; // Wait before next action
            } else {
                // No playable cards - do hero attack if possible
                if (current_player.atk > 0) {
                    var damage = max(1, current_player.atk - players[0].armor);
                    player_mod_hp(players[0], -damage);
                    combat_log_add(whosturn, "Hero Attack dealt " + string(damage) + " damage to " + players[0].title);
                    
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
                    ai_timer = 0;
                    show_debug_message("AI Hero Attack! " + string(damage) + " damage. Turn ended.");
                } else {
                    // No attack and no cards - end turn
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
                    ai_timer = 0;
                    show_debug_message("AI turn ended. Now Player " + string(whosturn + 1) + "'s turn");
                }
            }
        } else {
            // No playable cards and no MP - do hero attack if possible
            if (current_player.atk > 0) {
                var damage = max(1, current_player.atk - players[0].armor);
                player_mod_hp(players[0], -damage);
                combat_log_add(whosturn, "Hero Attack dealt " + string(damage) + " damage to " + players[0].title);
                
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
                ai_timer = 0;
                show_debug_message("AI Hero Attack! " + string(damage) + " damage. Turn ended.");
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
                ai_timer = 0;
                show_debug_message("AI turn ended. Now Player " + string(whosturn + 1) + "'s turn");
            }
        }
    }
} else if (game_state == "gameover") {
    // Game over - check for input to return to menu
    if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) || mouse_check_button_pressed(mb_left)) {
        game_state = "menu";
        playing = false;
        whosturn = 0;
        turncount = 1;
        mp_pool = 0;
        deck_empty = false;
        players = [];
        deck = [];
        all_cards = [];
        combat_log = [];
    }
}
