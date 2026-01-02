/// Draw GUI Event

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

draw_set_font(-1); // Use sua fonte pixelada

// ==================================================
// 1. TOPO: STATUS DO JOGADOR (Nome e Vida)
// ==================================================
if (instance_exists(jogador)) {
    var _topo_y = 40;
    
    // Nome do Personagem (Esquerda Superior ou Centro)
    draw_set_halign(fa_left);
    draw_set_color(cor_texto);
    draw_text(50, _topo_y, jogador.nome); // Ex: "Leon"

    // Barra de Vida (Ao lado do nome)
    var _hp_x = 200;
    var _hp_w = 200;
    var _hp_h = 20;
    var _hp_pct = (jogador.hp_atual / jogador.hp_max);
    
    // Label HP
    draw_text(_hp_x - 40, _topo_y, "HP");
    
    // Fundo Vermelho
    draw_set_color(c_maroon);
    draw_rectangle(_hp_x, _topo_y, _hp_x + _hp_w, _topo_y + _hp_h, false);
    
    // Frente Amarela
    draw_set_color(cor_selecionado);
    draw_rectangle(_hp_x, _topo_y, _hp_x + (_hp_w * _hp_pct), _topo_y + _hp_h, false);
    
    // Texto numérico (ex: 50 / 100)
    draw_set_color(c_white);
    draw_text(_hp_x + _hp_w + 20, _topo_y, string(jogador.hp_atual) + " / " + string(jogador.hp_max));
}

// ==================================================
// 2. CENTRO: LOG DE TEXTO
// ==================================================
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text(_gui_w / 2, 100, texto_log);


// ==================================================
// 3. RODAPÉ: BOTÕES HORIZONTAIS
// ==================================================
if (estado == ESTADO_BATALHA.TURNO_JOGADOR || estado == ESTADO_BATALHA.MENU_REACAO) {
    
    var _qtd = array_length(menu_atual);
    var _largura_botao = 180;
    var _altura_botao = 60;
    var _espaco = 10;
    
    // Centraliza
    var _largura_total = (_qtd * _largura_botao) + ((_qtd - 1) * _espaco);
    var _start_x = (_gui_w / 2) - (_largura_total / 2);
    var _start_y = _gui_h - 100;

    draw_set_valign(fa_middle);
    // draw_set_line_width(3); <--- LINHA REMOVIDA (CAUSAVA O ERRO)

    for (var i = 0; i < _qtd; i++) {
        var _bx = _start_x + (i * (_largura_botao + _espaco));
        var _by = _start_y;
        
        var _cor_atual_borda = cor_borda;
        var _cor_atual_texto = cor_texto;
        
        // Se este for o botão selecionado
        if (i == menu_index) {
            _cor_atual_borda = cor_selecionado; 
            _cor_atual_texto = cor_selecionado;
            
            // Fundo semi-transparente
            draw_set_alpha(0.2);
            draw_set_color(cor_selecionado);
            draw_rectangle(_bx, _by, _bx + _largura_botao, _by + _altura_botao, false);
            draw_set_alpha(1);
        }

        // Desenha Borda (TÉCNICA DE BORDA GROSSA MANUAL)
        draw_set_color(_cor_atual_borda);
        
        // Desenhamos 3 retângulos um dentro do outro para simular espessura
        var _espessura = 3; 
        for (var t = 0; t < _espessura; t++) {
            draw_rectangle(_bx + t, _by + t, _bx + _largura_botao - t, _by + _altura_botao - t, true);
        }
        
        // Desenha Texto
        draw_set_halign(fa_center);
        draw_set_color(_cor_atual_texto);
        draw_text(_bx + (_largura_botao/2), _by + (_altura_botao/2), menu_atual[i]);
    }
    
    // Reset
    // draw_set_line_width(1); <--- LINHA REMOVIDA
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}