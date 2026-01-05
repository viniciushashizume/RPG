/// Draw GUI Event do obj_menu

if (!menu_aberto) exit;

// 1. Fundo Escuro Semi-transparente
draw_set_alpha(0.85);
draw_set_color(c_black);
draw_rectangle(0, 0, largura_gui, altura_gui, false);
draw_set_alpha(1);

// 2. Desenhar Abas no Topo (Status | Itens | Voltar)
draw_set_halign(fa_center);
draw_set_valign(fa_top);
var _qtd_abas = array_length(opcoes_principal);
var _espaco_abas = largura_gui / _qtd_abas;

for (var i = 0; i < _qtd_abas; i++) {
    var _x_aba = (i * _espaco_abas) + (_espaco_abas / 2);
    
    // Destaque da aba selecionada
    if (i == index_menu_principal) {
        draw_set_color(c_yellow);
        draw_text_transformed(_x_aba, 30, "[" + opcoes_principal[i] + "]", 1.2, 1.2, 0);
    } else {
        draw_set_color(c_gray);
        draw_text(_x_aba, 30, opcoes_principal[i]);
    }
}

draw_set_color(c_white);
draw_line(50, 60, largura_gui - 50, 60); // Linha divisória

// 3. Conteúdo das Abas
draw_set_halign(fa_left);

// === ABA STATUS ===
if (index_menu_principal == 0) { 
    // Lista de Personagens à Esquerda
    var _x_lista = 100;
    var _y_lista = 100;
    
    for (var i = 0; i < array_length(global.party); i++) {
        var _char = global.party[i];
        
        // Cor da seleção
        if (i == index_sub_menu) draw_set_color(c_yellow);
        else draw_set_color(c_white);
        
        draw_text(_x_lista, _y_lista + (i * 40), _char.nome);
    }
    
    // Detalhes do Personagem Selecionado (Direita)
    var _selecionado = global.party[index_sub_menu];
    var _x_detalhe = 400;
    var _y_detalhe = 100;
    
    draw_set_color(c_white);
    
    // Desenha Sprite (Se tiver) - Opcional, precisa ajustar escala se for sprite de mapa
    // draw_sprite_ext(_selecionado.sprite_index, 0, _x_detalhe + 50, _y_detalhe + 50, 2, 2, 0, c_white, 1);
    
    draw_text(_x_detalhe, _y_detalhe, "Nome: " + _selecionado.nome);
    draw_text(_x_detalhe, _y_detalhe + 30, "Nivel: " + string(_selecionado.nivel));
    draw_text(_x_detalhe, _y_detalhe + 60, "XP: " + string(_selecionado.xp_atual) + " / " + string(_selecionado.xp_proximo_nivel));
    
    // Barras de Status
    draw_text(_x_detalhe, _y_detalhe + 100, "HP: " + string(_selecionado.hp_atual) + "/" + string(_selecionado.hp_max));
    draw_healthbar(_x_detalhe + 150, _y_detalhe + 105, _x_detalhe + 350, _y_detalhe + 115, (_selecionado.hp_atual/_selecionado.hp_max)*100, c_dkgray, c_red, c_lime, 0, true, true);

    draw_text(_x_detalhe, _y_detalhe + 130, "Sanidade: " + string(_selecionado.sanidade));
    draw_healthbar(_x_detalhe + 150, _y_detalhe + 135, _x_detalhe + 350, _y_detalhe + 145, _selecionado.sanidade, c_dkgray, c_purple, c_aqua, 0, true, true);
    
    // Atributos
    draw_text(_x_detalhe, _y_detalhe + 180, "Forca: " + string(_selecionado.atributo_forca));
    draw_text(_x_detalhe, _y_detalhe + 210, "Destreza: " + string(_selecionado.atributo_destreza));
    draw_text(_x_detalhe, _y_detalhe + 240, "Inteligencia: " + string(_selecionado.atributo_inteligencia));
    
    // Equipamento
    var _arma_nome = "Desarmado";
    if (is_struct(_selecionado.arma_equipada)) _arma_nome = _selecionado.arma_equipada.nome;
    draw_text(_x_detalhe, _y_detalhe + 290, "Arma: " + _arma_nome);
}

// === ABA ITENS ===
else if (index_menu_principal == 1) {
    var _x_item = 100;
    var _y_item = 100;
    
    if (array_length(global.inventario) == 0) {
        draw_text(_x_item, _y_item, "Inventario Vazio");
    } else {
        for (var i = 0; i < array_length(global.inventario); i++) {
            var _item = global.inventario[i];
            
            if (i == index_sub_menu) draw_set_color(c_yellow);
            else draw_set_color(c_white);
            
            draw_text(_x_item, _y_item + (i * 40), _item.nome + " (x" + string(_item.quantidade) + ")");
            
            // Descrição do item selecionado
            if (i == index_sub_menu) {
                draw_set_color(c_ltgray);
                draw_text(largura_gui/2, altura_gui - 100, _item.descricao);
                draw_text(largura_gui/2, altura_gui - 70, "[Espaco/Enter] para usar no Lider");
            }
        }
    }
}