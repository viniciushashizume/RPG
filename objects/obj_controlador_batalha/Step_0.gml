/// Step Event - COMPLETO E CORRIGIDO

// 1. SISTEMA DE DELAY (PAUSA PARA LEITURA)
// Se houver delay, desconta 1 frame e não faz mais nada
if (delay_turno > 0) {
    delay_turno--;
    return; // Sai do evento, impedindo que o jogo continue
}

// 2. NAVEGAÇÃO DO MENU (Esquerda / Direita)
// Só permite navegar se for turno do jogador
if (estado == ESTADO_BATALHA.TURNO_JOGADOR || estado == ESTADO_BATALHA.MENU_REACAO) {
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

    // --- TURNO DO JOGADOR (MENU PRINCIPAL) ---
    case ESTADO_BATALHA.TURNO_JOGADOR:
        menu_atual = opcoes_principal; 
        
        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            var _escolha = menu_atual[menu_index];
            
            if (_escolha == "REAGIR") {
                estado = ESTADO_BATALHA.MENU_REACAO;
                menu_atual = opcoes_reacao;
                menu_index = 0;
            } else {
                executar_acao_jogador(_escolha);
            }
        }
        break;

    // --- SUB-MENU DE REAÇÃO ---
    case ESTADO_BATALHA.MENU_REACAO:
        if (keyboard_check_pressed(ord("X"))) { // Voltar
            estado = ESTADO_BATALHA.TURNO_JOGADOR;
            menu_atual = opcoes_principal;
            menu_index = 1; 
            return;
        }

        if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
            executar_acao_jogador(menu_atual[menu_index]); 
        }
        break;

    // --- TURNO DO INIMIGO (A PARTE QUE FALTAVA) ---
    case ESTADO_BATALHA.TURNO_INIMIGO:
        // O código só chega aqui depois que o delay_turno acabar
        
        if (array_length(inimigos) > 0 && instance_exists(inimigos[0])) {
            var _inimigo = inimigos[0];
            
            // Inimigo ataca
            var _dano_base = (_inimigo.arma_equipada != undefined) ? _inimigo.arma_equipada.dano : 5;
            var _resultado_texto = jogador.receber_dano(_dano_base, _inimigo);
            
            texto_log = "Inimigo atacou: " + _resultado_texto;
            
            // Reseta status do jogador
            jogador.esta_defendendo = false;
            jogador.esta_esquivando = false;
            jogador.esta_contra_atacando = false;
            
            // Pausa de novo para você ler o que o inimigo fez
            delay_turno = 80; 
            
            // Devolve a vez para o jogador
            estado = ESTADO_BATALHA.TURNO_JOGADOR;
        } else {
            // Se não tiver inimigo (erro de segurança), vence
            estado = ESTADO_BATALHA.VITORIA;
        }
        break;
        
    case ESTADO_BATALHA.VITORIA:
        // Opcional: Voltar para o mapa ao apertar Z
        if (keyboard_check_pressed(ord("Z"))) room_goto(rm_mapa);
        break;
}