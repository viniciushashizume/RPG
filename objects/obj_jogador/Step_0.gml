// Step Event do Jogador
if (em_batalha == false) {  // Só anda se NÃO estiver em batalha
    var _vel = 4;
    var _hmove = keyboard_check(ord("D")) - keyboard_check(ord("A"));
    var _vmove = keyboard_check(ord("S")) - keyboard_check(ord("W"));

    x += _hmove * _vel;
    y += _vmove * _vel;

    // Colisão com inimigo no mapa para iniciar batalha
    var _inimigo_mapa = instance_place(x, y, obj_inimigo_mapa);
    if (_inimigo_mapa != noone) {
        em_batalha = true;
        room_goto(rm_batalha); // Vai para a sala de batalha
        // Salvar dados do inimigo em um objeto global persistente antes de trocar
    }
}