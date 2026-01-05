/// Create Event do obj_menu

menu_aberto = false;
pagina_atual = 0; // 0 = Status, 1 = Itens, 2 = Sair
index_menu_principal = 0; // Qual aba está selecionada
index_sub_menu = 0;       // Qual item dentro da aba está selecionado (ex: qual herói)
opcoes_principal = ["STATUS", "ITENS", "VOLTAR"];

// Variáveis visuais
cor_fundo = c_black;
cor_texto = c_white;
cor_selecao = c_yellow;
largura_gui = display_get_gui_width();
altura_gui = display_get_gui_height();

// --- CRIAR ITENS DE TESTE (Apenas para você ver funcionando) ---
if (array_length(global.inventario) == 0) {
    var _pocao = new Item("Pocao de Vida", "Recupera 20 HP", function(_alvo) {
        _alvo.hp_atual = min(_alvo.hp_atual + 20, _alvo.hp_max);
        show_debug_message("Curou 20 HP de " + _alvo.nome);
    });
    _pocao.quantidade = 3;
    array_push(global.inventario, _pocao);
    
    var _elixir = new Item("Elixir da Mente", "Recupera 10 Sanidade", function(_alvo) {
        _alvo.sanidade += 10; // Adicione um teto máximo se tiver sanidade_max
    });
    array_push(global.inventario, _elixir);
}