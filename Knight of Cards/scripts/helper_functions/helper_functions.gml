// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function helper_functions(){

}

// Helper function to get sign string
function sign(num) {
    if (num > 0) return "increased";
    if (num < 0) return "decreased";
    return "";
}

// Suit symbols
var suits = {
    "Spades": "♠",
    "Clubs": "♣",
    "Hearts": "♥",
    "Diamonds": "♦"
};

// ==================== CSV FUNCTIONS ====================

/// @description Load CSV file and return array of rows (each row is array of values)
/// @param filename
function csv_load(filename) {
    var rows = [];
    var file = file_text_open_read(filename);
    
    while (!file_text_eof(file)) {
        var line = file_text_read_string(file);
        file_text_readln(file);
        
        if (line != "") {
            var row = [];
            var current = "";
            var in_quotes = false;
            
            for (var i = 0; i < string_length(line); i++) {
                var char = string_char_at(line, i + 1);
                
                if (char == "\"") {
                    in_quotes = !in_quotes;
                } else if (char == "," && !in_quotes) {
                    array_push(row, current);
                    current = "";
                } else {
                    current += char;
                }
            }
            array_push(row, current);
            array_push(rows, row);
        }
    }
    
    file_text_close(file);
    return rows;
}

// ==================== CARD FUNCTIONS ====================

/// @description Create a card struct from CSV data
/// @param uid, title, card_strength, card_name, suit, color, category, cost, hp, mp, armor, atk, target, turns, info, lore, art
function card_create(uid, title, card_strength, card_name, suit, color, category, cost, hp, mp, armor, atk, target, turns, info, lore, art) {
    var card = {
        uid: real(uid),
        title: title,
        card_strength: real(card_strength),
        card_name: card_name,
        suit: suit,
        color: color,
        category: category,
        cost: real(cost),
        hp: real(hp),
        mp: real(mp),
        armor: real(armor),
        atk: real(atk),
        target: real(target),
        turns: real(turns),
        info: info,
        lore: lore,
        art: art
    };
    return card;
}

/// @description Return formatted card string
/// @param card
/// @param index (optional)
function card_pretty_print(card, index = -1) {
    var t = (card.target == 0) ? "Self" : "Opponent";
    var suit_symbol = card.suit;
    switch (card.suit) {
        case "Spades": suit_symbol = "♠"; break;
        case "Clubs": suit_symbol = "♣"; break;
        case "Hearts": suit_symbol = "♥"; break;
        case "Diamonds": suit_symbol = "♦"; break;
    }
    var index_str = (index >= 0) ? string(index) : "";
    
    var result = "Card " + index_str + ":「" + card.title + "」:" + card.card_name + " of " + suit_symbol + ". Category:" + card.category + "\n";
    result += "\tInfo:" + card.info + "\n";
    result += "\tCost:" + string(card.cost) + " Turns:" + string(card.turns) + " Target:" + t + " HP:" + string(card.hp) + " MP:" + string(card.mp) + "\n";
    result += "\tDef:" + string(card.armor) + " Atk:" + string(card.atk) + " \n";
    result += "\tLore:" + card.lore;
    
    return result;
}

// ==================== PLAYER FUNCTIONS ====================

/// @description Create a player struct from CSV data
/// @param uid, title, suit, color, category, hp, mp, armor, atk, art, info
function player_create(uid, title, suit, color, category, hp, mp, armor, atk, art, info) {
    var player = {
        uid: real(uid),
        title: title,
        suit: suit,
        color: color,
        category: category,
        hp: real(hp),
        basehp: real(hp),
        mp: real(mp),
        basemp: real(mp),
        armor: real(armor),
        basearmor: real(armor),
        atk: real(atk),
        baseatk: real(atk),
        art: art,
        info: info,
        hand: [],
        hand_empty: false,
        endturn: false,
        alive: true
    };
    return player;
}

/// @description Modify player HP
/// @param player
/// @param val
function player_mod_hp(player, val) {
    var sign_str = sign(val);
    if (sign_str != "") {
        if (player.hp <= 0) {
            player.hp = 0;
            player.alive = false;
            return false;
        }
        player.hp += val;
        return true;
    }
    return false;
}

/// @description Modify player MP
/// @param player
/// @param val
function player_mod_mp(player, val) {
    var sign_str = sign(val);
    if (sign_str != "") {
        if (player.mp <= 0) {
            player.mp = 0;
            return false;
        }
        player.mp += val;
        return true;
    }
    return false;
}

/// @description Modify player Armor
/// @param player
/// @param val
function player_mod_armor(player, val) {
    var sign_str = sign(val);
    if (sign_str != "") {
        if (player.armor <= 0) {
            player.armor = 0;
            return false;
        }
        player.armor += val;
        return true;
    }
    return false;
}

/// @description Modify player Attack
/// @param player
/// @param val
function player_mod_atk(player, val) {
    var sign_str = sign(val);
    if (sign_str != "") {
        if (player.atk <= 0) {
            player.atk = 0;
            return false;
        }
        player.atk += val;
        return true;
    }
    return false;
}

/// @description Spend mana, set endturn if out
/// @param player
/// @param cost
function player_spend_mp(player, cost) {
    player.mp -= cost;
    if (player.mp <= 0) {
        player.endturn = true;
    }
}

// ==================== GAME FUNCTIONS ====================

/// @description Load cards from CSV file
function game_load_cards_from_csv() {
    var rows = csv_load("csv/cardinfo.csv");
    var cards = [];
    
    // Skip header row (index 0)
    for (var i = 1; i < array_length(rows); i++) {
        var row = rows[i];
        if (array_length(row) >= 17) {
            var card = card_create(
                row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7],
                row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15], row[16]
            );
            array_push(cards, card);
        }
    }
    
    return cards;
}

/// @description Load heroes from CSV file
function game_load_heroes_from_csv() {
    var rows = csv_load("csv/heroes.csv");
    var heroes = [];
    
    // Skip header row (index 0)
    for (var i = 1; i < array_length(rows); i++) {
        var row = rows[i];
        if (array_length(row) >= 11) {
            var hero = player_create(
                row[0], row[1], row[2], row[3], row[4], row[5],
                row[6], row[7], row[8], row[9], row[10]
            );
            array_push(heroes, hero);
        }
    }
    
    return heroes;
}

/// @description Create deck from cards array (3 copies)
/// @param cards_array
function game_create_deck(cards_array) {
    var deck = [];
    for (var i = 0; i < 3; i++) {
        for (var j = 0; j < array_length(cards_array); j++) {
            array_push(deck, cards_array[j]);
        }
    }
    return deck;
}

/// @description Shuffle deck array
/// @param deck
function game_shuffle_deck(deck) {
    var len = array_length(deck);
    for (var i = len - 1; i > 0; i--) {
        var j = irandom(i);
        var temp = deck[i];
        deck[i] = deck[j];
        deck[j] = temp;
    }
    return deck;
}

/// @description Draw random card from deck
/// @param deck
function game_draw_card(deck) {
    if (array_length(deck) == 0) {
        return -1; // Empty deck
    }
    var index = irandom(array_length(deck) - 1);
    var card = deck[index];
    array_delete(deck, index, 1);
    return card;
}

/// @description Process card effects on target player
/// @param card
/// @param target_player
function game_process_card(card, target_player) {
    player_spend_mp(target_player, card.cost);
    player_mod_hp(target_player, card.hp);
    player_mod_mp(target_player, card.mp);
    player_mod_armor(target_player, card.armor);
    player_mod_atk(target_player, card.atk);
}

/// @description Check game over conditions
/// @param game_state (struct with players, deck_empty, etc.)
function game_check_game_over(game_state) {
    // Check if any player is dead
    for (var i = 0; i < array_length(game_state.players); i++) {
        if (game_state.players[i].hp <= 0) {
            return true;
        }
    }
    
    // Check if deck and all hands are empty
    if (game_state.deck_empty) {
        var all_hands_empty = true;
        for (var i = 0; i < array_length(game_state.players); i++) {
            if (!game_state.players[i].hand_empty) {
                all_hands_empty = false;
                break;
            }
        }
        if (all_hands_empty) {
            return true;
        }
    }
    
    return false;
}

/// @description End turn - switch turns, increment turncount
/// @param game_state
function game_end_turn(game_state) {
    // Switch turns
    if (game_state.whosturn == 1) {
        game_state.whosturn = 0;
    } else {
        game_state.whosturn = 1;
    }
    
    // Increment turn count
    game_state.turncount++;
    
    // Increase mana pool every other turn
    if (game_state.turncount % 2 == 0) {
        game_state.mp_pool++;
    }
}