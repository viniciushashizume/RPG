/// Draw GUI - CORRIGIDO

draw_set_font(-1); // Use sua fonte pixel art se tiver
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// --- DESENHA A LISTA DE INICIATIVA (Debug Visual) ---
// Opcional: mostra quem é o próximo no topo da tela
var _lista_str = "Turnos: ";
for(var i=0; i<array_length(lista_turnos); i++) {
    var _ent = lista_turnos[i];
    if (instance_exists(_ent)) {
        if (_ent == entidade_ativa) _lista_str += "[" + _ent.nome + "] ";
        else _lista_str += _ent.nome + " ";
    }
}
draw_text(10, 10, _lista_str);


// --- DESENHA HUD DA PARTY ---
var _y_hud = display_get_gui_height() - 150;
var _x_hud = 50;

for (var i = 0; i < array_length(party); i++) {
    var _membro = party[i];
    
    // Verifica se o membro existe
    if (!instance_exists(_membro)) continue;
    
    // Cor do texto (Amarelo se for a vez dele, Branco normal, Vermelho se morto)
    if (_membro.hp_atual <= 0) draw_set_color(c_red);
    else if (_membro == entidade_ativa) draw_set_color(c_yellow);
    else draw_set_color(c_white);
    
    // Desenha Nome e HP
    draw_text(_x_hud, _y_hud + (i * 30), _membro.nome + " HP: " + string(_membro.hp_atual) + "/" + string(_membro.hp_max));
    
    // Seta indicativa (AGORA USA ENTIDADE_ATIVA em vez de index)
    if (_membro == entidade_ativa) {
        draw_text(_x_hud - 20, _y_hud + (i * 30), ">");
    }
}

// --- DESENHA MENU DE AÇÕES (Só se for turno do jogador) ---
if (estado == ESTADO_BATALHA.TURNO_JOGADOR) {
    var _menu_x = display_get_gui_width() - 200;
    var _menu_y = display_get_gui_height() - 150;
    
    // Fundo do Menu
    draw_set_color(c_black);
    draw_rectangle(_menu_x - 10, _menu_y - 10, _menu_x + 150, _menu_y + (array_length(menu_atual) * 25) + 10, false);
    draw_set_color(c_white);
    draw_rectangle(_menu_x - 10, _menu_y - 10, _menu_x + 150, _menu_y + (array_length(menu_atual) * 25) + 10, true);

    for (var i = 0; i < array_length(menu_atual); i++) {
        if (i == menu_index) draw_set_color(c_yellow);
        else draw_set_color(c_white);
        
        draw_text(_menu_x, _menu_y + (i * 25), menu_atual[i]);
    }
}

// --- LOG DE BATALHA (Topo Central) ---
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text(display_get_gui_width()/2, 50, texto_log);
draw_set_halign(fa_left);