// Step Event do Jogador
if (em_batalha == false) {  // Só anda se NÃO estiver em batalha
    var _vel = 4;
    var _hmove = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    var _vmove = keyboard_check(ord("S")) - keyboard_check(ord("W"));

    x += _hmove * _vel;
    y += _vmove * _vel;

var _inimigo_mapa = instance_place(x, y, obj_inimigo_mapa);
if (_inimigo_mapa != noone) {
    em_batalha = true;
    global.pos_antiga_x = x;
    global.pos_antiga_y = y;
    
    if (variable_instance_exists(_inimigo_mapa, "inimigo_batalha")) {
        global.inimigo_spawn = _inimigo_mapa.inimigo_batalha;
    } else {
        global.inimigo_spawn = obj_zumbi; 
    }
    // ---------------------

    instance_destroy(_inimigo_mapa);
    room_goto(rm_batalha);
}
}