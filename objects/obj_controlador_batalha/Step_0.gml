/// Step Event - ATUALIZADO COM MENU DE MAGIA

// 1. SISTEMA DE DELAY
if (delay_turno > 0) {
    delay_turno--;
    return;
}

// 2. NAVEGAÇÃO (Funciona para todos os menus)
if (estado == ESTADO_BATALHA.TURNO_JOGADOR || estado == ESTADO_BATALHA.MENU_REACAO || estado == ESTADO_BATALHA.MENU_MAGIA) {
    var _move = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
    if (_move != 0) {
        menu_index += _move;
        var _tamanho = array_length(menu_atual);
        if (menu_index < 0) menu_index = _tamanho - 1;
        if (menu_index >= _tamanho) menu_index = 0;
    }
}

// 3. MÁQUINA DE ESTADOS
switch (estado) {
    case ESTADO_BATALHA.INICIO:
        estado = ESTADO_BATALHA.TURNO_JOGADOR;
        break;

    // --- MENU PRINCIPAL ---
case ESTADO_BATALHA.TURNO_JOGADOR:
        menu_atual = opcoes_principal;
        
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            var _escolha = menu_atual[menu_index];

            // 1. Se for REAGIR -> Abre submenu de reação
            if (_escolha == "REAGIR") {
                estado = ESTADO_BATALHA.MENU_REACAO;
                menu_atual = opcoes_reacao;
                menu_index = 0;
            } 
            // 2. CORREÇÃO: Se for MAGIA -> Abre submenu de magia
			else if (_escolha == "MAGIA") {
			    if (array_length(jogador.magias_conhecidos) > 0) {
			        estado = ESTADO_BATALHA.MENU_MAGIA;
        
			        menu_atual = [];
			        for (var i = 0; i < array_length(jogador.magias_conhecidos); i++) {
			            array_push(menu_atual, jogador.magias_conhecidos[i].nome);
			        }
			        menu_index = 0;
        
			        io_clear(); // <--- ADICIONE ISSO! (Limpa o "Z" da memória)
        
			    } else {
			        texto_log = "Sem magias aprendidas!";
			    }
			}
            // 3. Qualquer outra coisa (Atacar, Item, Fuga) -> Executa imediatamente
            else {
                executar_acao_jogador(_escolha);
            }
        }
        break;

    // --- SUB-MENU REAÇÃO ---
    case ESTADO_BATALHA.MENU_REACAO:
        if (keyboard_check_pressed(ord("X"))) { 
            estado = ESTADO_BATALHA.TURNO_JOGADOR;
            menu_atual = opcoes_principal;
            menu_index = 1; // Volta cursor para 'Reagir'
            return;
        }
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            executar_acao_jogador(menu_atual[menu_index]);
        }
        break;

    case ESTADO_BATALHA.MENU_MAGIA:
        // Botão de Voltar
        if (keyboard_check_pressed(ord("X"))) { 
            estado = ESTADO_BATALHA.TURNO_JOGADOR;
            menu_atual = opcoes_principal;
            menu_index = 2; 
            return;
        }

        // Confirmar Magia
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            var _magia_selecionada = jogador.magias_conhecidos[menu_index];
            
            executar_magia(_magia_selecionada);
            
            io_clear(); // <--- ADICIONE ISSO (Impede repetição de inputs)
            menu_index = 0; // Reseta o cursor para evitar erros
        }
        break;

    // --- TURNO DO INIMIGO ---
    case ESTADO_BATALHA.TURNO_INIMIGO:
        if (array_length(inimigos) > 0 && instance_exists(inimigos[0])) {
            var _inimigo = inimigos[0];
            var _dano_base = (_inimigo.arma_equipada != undefined) ? _inimigo.arma_equipada.dano : 5;
            var _resultado_texto = jogador.receber_dano(_dano_base, _inimigo);
            
            texto_log = "Inimigo atacou: " + _resultado_texto;
            
            // Reseta status
            jogador.esta_defendendo = false;
            jogador.esta_esquivando = false;
            jogador.esta_contra_atacando = false;
            
            delay_turno = 80;
            estado = ESTADO_BATALHA.TURNO_JOGADOR;
        } else {
            estado = ESTADO_BATALHA.VITORIA;
        }
        break;
        
    case ESTADO_BATALHA.VITORIA:
        if (keyboard_check_pressed(ord("Z"))) room_goto(rm_mapa);
        break;
}