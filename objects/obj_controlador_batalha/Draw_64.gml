/// Draw GUI Event

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

draw_set_font(-1); // Use sua fonte pixelada

// ==================================================
// 1. TOPO: STATUS DA PARTY (Loop pelos membros)
// ==================================================

// Define a posição inicial e o espaçamento vertical entre os membros
var _topo_y_inicial = 40;
var _espaco_vertical = 35; 

// Verifica se a variável 'party' existe e tem gente (definida no Create)
if (variable_instance_exists(id, "party") && array_length(party) > 0) {
    
    // Loop para desenhar cada membro do grupo (0, 1, 2...)
    for (var i = 0; i < array_length(party); i++) {
        var _membro = party[i];
        var _y_atual = _topo_y_inicial + (i * _espaco_vertical);
        
        // --- Indicador de Turno (Setinha >) ---
        // Se for turno do jogador E o índice (i) for igual ao membro atual
        if (estado == ESTADO_BATALHA.TURNO_JOGADOR && i == membro_atual_index) {
            draw_set_halign(fa_right);
            draw_set_color(c_yellow);
            draw_text(40, _y_atual, ">"); // Desenha a seta antes do nome
        }

        // --- Nome do Personagem ---
        draw_set_halign(fa_left);
        draw_set_color(cor_texto);
        
        // Se o personagem estiver com 0 de vida, desenha o nome cinza (opcional)
        if (_membro.hp_atual <= 0) draw_set_color(c_gray);
        
        draw_text(50, _y_atual, _membro.nome); 

        // --- Barra de Vida ---
        var _hp_x = 200;
        var _hp_w = 200;
        var _hp_h = 20; // Altura da barra
        
        // Evita divisão por zero se hp_max for 0 (segurança)
        var _hp_pct = 0;
        if (_membro.hp_max > 0) {
            _hp_pct = (_membro.hp_atual / _membro.hp_max);
        }
        
        // Label HP (opcional, removi para poupar espaço vertical se tiver 3 membros)
        // draw_text(_hp_x - 40, _y_atual, "HP");
        
        // Fundo Vermelho (Barra vazia)
        draw_set_color(c_maroon);
        draw_rectangle(_hp_x, _y_atual, _hp_x + _hp_w, _y_atual + _hp_h, false);
        
        // Frente (Verde ou Amarela dependendo da vida)
        if (_hp_pct < 0.25) draw_set_color(c_red);
        else draw_set_color(c_green); // Mudei para verde para diferenciar da cor de seleção
        
        // Garante que a barra não fique negativa visualmente
        var _largura_atual = max(0, _hp_w * _hp_pct);
        draw_rectangle(_hp_x, _y_atual, _hp_x + _largura_atual, _y_atual + _hp_h, false);
        
        // Texto numérico (ex: 50 / 100)
        draw_set_color(c_white);
        // Centraliza o texto dentro da barra ou coloca ao lado
        draw_text(_hp_x + _hp_w + 10, _y_atual, string(_membro.hp_atual) + "/" + string(_membro.hp_max));
    }
}

// ==================================================
// 2. CENTRO: LOG DE TEXTO
// ==================================================
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text(_gui_w / 2, 180, texto_log); // Baixei um pouco o Y (para 180) para não bater nos nomes


// ==================================================
// 3. RODAPÉ: BOTÕES HORIZONTAIS
// ==================================================
if ((estado == ESTADO_BATALHA.TURNO_JOGADOR || estado == ESTADO_BATALHA.MENU_REACAO || estado == ESTADO_BATALHA.MENU_MAGIA) && delay_turno == 0) {
    
    var _qtd = array_length(menu_atual);
    var _largura_botao = 180;
    var _altura_botao = 60;
    var _espaco = 10;
    
    // Centraliza
    var _largura_total = (_qtd * _largura_botao) + ((_qtd - 1) * _espaco);
    var _start_x = (_gui_w / 2) - (_largura_total / 2);
    var _start_y = _gui_h - 100;

    draw_set_valign(fa_middle);

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
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}