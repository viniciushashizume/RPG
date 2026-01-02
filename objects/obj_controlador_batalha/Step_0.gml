/// Step Event - CORRIGIDO (Sistema de Iniciativa)

switch(estado) {
    
    // --- TURNO DO JOGADOR ---
    case ESTADO_BATALHA.TURNO_JOGADOR:
        // Garante que personagem_atual existe
        if (!instance_exists(personagem_atual)) {
            avancar_turno();
            break;
        }

        // Controles de Menu
        var _up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
        var _down = keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"));
        var _enter = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);
        var _back = keyboard_check_pressed(vk_escape);

        // Navegação
        if (_up) {
            menu_index--;
            if (menu_index < 0) menu_index = array_length(menu_atual) - 1;
        }
        if (_down) {
            menu_index++;
            if (menu_index >= array_length(menu_atual)) menu_index = 0;
        }

        // Seleção
        if (_enter) {
            var _acao_selecionada = menu_atual[menu_index];

            // --- LÓGICA DO MENU PRINCIPAL ---
            if (menu_atual == opcoes_principal) {
                switch(_acao_selecionada) {
                    case "ATACAR":
                        executar_acao_jogador("ATACAR");
                        break;
                    case "REAGIR":
                        menu_atual = opcoes_reacao;
                        menu_index = 0;
                        break;
                    case "MAGIA":
                        // Exemplo simples: cura (no futuro você pode abrir um menu de magias)
                        executar_magia({nome: "Cura Menor", custo: 5, dano: -10}); 
                        break;
                    case "CONVERSA":
                        executar_acao_jogador("CONVERSA");
                        break;
                    case "FUGA":
                        executar_acao_jogador("FUGA");
                        break;
                }
            }
            // --- LÓGICA DO MENU DE REAÇÃO ---
            else if (menu_atual == opcoes_reacao) {
                // Ao escolher uma reação, aplica e passa o turno
                executar_acao_jogador(_acao_selecionada);
            }
        }

        // Voltar Menu
        if (_back && menu_atual == opcoes_reacao) {
            menu_atual = opcoes_principal;
            menu_index = 0;
        }
        break;

    // --- TURNO DO INIMIGO ---
    case ESTADO_BATALHA.TURNO_INIMIGO:
        if (delay_turno > 0) {
            delay_turno--;
        } else {
            // IA do Inimigo
            if (instance_exists(entidade_ativa) && entidade_ativa.hp_atual > 0) {
                
                // Escolhe um alvo vivo aleatório
                var _alvos_vivos = [];
                for(var i=0; i<array_length(party); i++) {
                    if (party[i].hp_atual > 0) array_push(_alvos_vivos, party[i]);
                }

                if (array_length(_alvos_vivos) > 0) {
                    var _alvo = _alvos_vivos[irandom(array_length(_alvos_vivos)-1)];
                    
                    // Calcula Dano
                    var _dano_base = 5;
                    if (variable_instance_exists(entidade_ativa, "arma_equipada")) {
                         // Lógica de arma se tiver
                    }
                    
                    var _res = _alvo.receber_dano(_dano_base, entidade_ativa);
                    texto_log = entidade_ativa.nome + " ataca " + _alvo.nome + ": " + _res;
                }

                // Passa a vez
                delay_turno = 60; // Pequena pausa para ler o log
                avancar_turno();
                
                // Trava momentaneamente para ler o log antes do próximo agir
                estado = ESTADO_BATALHA.PROCESSANDO_ACAO; 
            } else {
                // Se o inimigo morreu ou não existe, pula
                avancar_turno();
            }
        }
        break;
        
    // --- ESTADO DE ESPERA (Delay entre turnos) ---
    case ESTADO_BATALHA.PROCESSANDO_ACAO:
        if (delay_turno > 0) delay_turno--;
        else {
            // Retoma o estado correto baseado na nova entidade ativa
             if (object_is_ancestor(entidade_ativa.object_index, obj_jogador) || entidade_ativa.object_index == obj_jogador) {
                estado = ESTADO_BATALHA.TURNO_JOGADOR;
             } else {
                estado = ESTADO_BATALHA.TURNO_INIMIGO;
             }
        }
        break;

    case ESTADO_BATALHA.VITORIA:
        if (keyboard_check_pressed(vk_enter)) room_goto(rm_mapa);
        break;

    case ESTADO_BATALHA.DERROTA:
        if (keyboard_check_pressed(vk_enter)) game_restart();
        break;
}