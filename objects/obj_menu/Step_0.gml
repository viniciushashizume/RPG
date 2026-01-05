/// Step Event do obj_menu

// Abrir/Fechar Menu com TAB ou ESC (se não estiver em batalha)
if (keyboard_check_pressed(vk_tab) || keyboard_check_pressed(vk_escape)) {
    // Verifica se NÃO existe o controlador de batalha para não abrir menu durante a luta
    if (!instance_exists(obj_controlador_batalha)) {
        menu_aberto = !menu_aberto;
        index_menu_principal = 0;
        index_sub_menu = 0;
    }
}

if (!menu_aberto) exit; // Se fechado, não roda o resto

// --- NAVEGAÇÃO ---
var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
var _left = keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"));
var _right = keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"));
var _enter = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);

// Navegar entre Abas (Status / Itens / Sair)
if (_left) {
    index_menu_principal--;
    if (index_menu_principal < 0) index_menu_principal = array_length(opcoes_principal) - 1;
    index_sub_menu = 0; // Reseta seleção interna
}
if (_right) {
    index_menu_principal++;
    if (index_menu_principal >= array_length(opcoes_principal)) index_menu_principal = 0;
    index_sub_menu = 0;
}

// Navegar DENTRO da Aba (Selecionar herói ou item)
var _tam_lista = 0;

if (index_menu_principal == 0) { // Aba STATUS (Lista de heróis)
    _tam_lista = array_length(global.party);
} 
else if (index_menu_principal == 1) { // Aba ITENS
    _tam_lista = array_length(global.inventario);
}

if (_tam_lista > 0) {
    if (_up) {
        index_sub_menu--;
        if (index_sub_menu < 0) index_sub_menu = _tam_lista - 1;
    }
    if (_down) {
        index_sub_menu++;
        if (index_sub_menu >= _tam_lista) index_sub_menu = 0;
    }
}

// --- AÇÕES ---
if (_enter) {
    // Se for SAIR
    if (opcoes_principal[index_menu_principal] == "VOLTAR") {
        menu_aberto = false;
    }
    
    // Se for usar ITEM
    if (opcoes_principal[index_menu_principal] == "ITENS" && _tam_lista > 0) {
        var _item_selecionado = global.inventario[index_sub_menu];
        
        // Exemplo simples: Usa no primeiro personagem da party (Líder)
        // Idealmente você abriria um sub-menu para escolher o alvo
        var _alvo = global.party[0]; 
        
        if (_item_selecionado.quantidade > 0) {
            _item_selecionado.efeito(_alvo); // Executa o script do item
            _item_selecionado.quantidade--;
            
            // Remove se acabar (opcional)
            if (_item_selecionado.quantidade <= 0) {
                array_delete(global.inventario, index_sub_menu, 1);
                index_sub_menu = 0;
            }
        }
    }
}