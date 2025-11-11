/// @description Update cards for current player
if (o_game.game_state != "playing") return;

var current_player = o_game.players[o_game.whosturn];
var current_hand_size = array_length(current_player.hand);

if (current_hand_size != last_hand_size || o_game.whosturn != last_turn) {
    for (var i = 0; i < array_length(card_instances); i++) {
        instance_destroy(card_instances[i]);
    }
    card_instances = [];
    
    var card_spacing = 140;
    var start_x = (room_width - (current_hand_size * card_spacing)) / 2;
    var card_y = room_height - 220;
    
    for (var i = 0; i < current_hand_size; i++) {
        var card_inst = instance_create_layer(start_x + (i * card_spacing), card_y, "Instances", o_card);
        card_inst.card_data = current_player.hand[i];
        card_inst.card_index = i;
        card_inst.target_x = start_x + (i * card_spacing);
        card_inst.target_y = card_y;
        card_inst.start_y = card_y;
        card_inst.can_afford = (current_player.hand[i].cost <= current_player.mp);
        array_push(card_instances, card_inst);
    }
    
    last_hand_size = current_hand_size;
    last_turn = o_game.whosturn;
} else {
    for (var i = 0; i < array_length(card_instances); i++) {
        card_instances[i].can_afford = (current_player.hand[i].cost <= current_player.mp);
    }
}
