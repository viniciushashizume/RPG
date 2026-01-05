/// Step Event - CORRIGIDO (Lógica de Espera e Menu)

switch(estado) {
    
    // --- TURNO DO JOGADOR ---
    case ESTADO_BATALHA.TURNO_JOGADOR:
        if (!instance_exists(personagem_atual)) {
            avancar_turno();
            break;
        }

        // Inputs
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

            // 1. Menu Principal
            if (menu_atual == opcoes_principal) {
                switch(_acao_selecionada) {
                    case "ATACAR": executar_acao_jogador("ATACAR"); break;
                    case "REAGIR": menu_atual = opcoes_reacao; menu_index = 0; break;
                    case "MAGIA":
                        // Carrega magias dinamicamente
                        if (variable_instance_exists(personagem_atual, "magias_conhecidos") && array_length(personagem_atual.magias_conhecidos) > 0) {
                            var _nomes = [];
                            for(var i=0; i<array_length(personagem_atual.magias_conhecidos); i++) {
                                array_push(_nomes, personagem_atual.magias_conhecidos[i].nome);
                            }
                            menu_atual = _nomes;
                            menu_index = 0;
                        } else {
                            texto_log = "Nenhuma magia aprendida!";
                        }
                        break;
                    case "CONVERSA": executar_acao_jogador("CONVERSA"); break;
                    case "FUGA": executar_acao_jogador("FUGA"); break;
                }
            }
            // 2. Menu Reação
            else if (menu_atual == opcoes_reacao) {
                executar_acao_jogador(_acao_selecionada);
            }
            // 3. Menu de Magias (O ELSE IMPORTANTE)
            else {
                // Recupera a struct da magia e executa
                var _magia_real = personagem_atual.magias_conhecidos[menu_index];
                executar_magia(_magia_real);
                
                // Reseta menu
                menu_atual = opcoes_principal;
                menu_index = 0;
            }
        }

        // Voltar
        if (_back && menu_atual != opcoes_principal) {
            menu_atual = opcoes_principal;
            menu_index = 0;
        }
        break;

    // --- TURNO DO INIMIGO ---
    case ESTADO_BATALHA.TURNO_INIMIGO:
        if (delay_turno > 0) {
            delay_turno--;
        } else {
            if (instance_exists(entidade_ativa) && entidade_ativa.hp_atual > 0) {
                // IA Básica
                var _alvos_vivos = [];
                for(var i=0; i<array_length(party); i++) {
                    if (party[i].hp_atual > 0) array_push(_alvos_vivos, party[i]);
                }

                if (array_length(_alvos_vivos) > 0) {
                    var _alvo = _alvos_vivos[irandom(array_length(_alvos_vivos)-1)];
                    var _res = _alvo.receber_dano(5, entidade_ativa);
                    texto_log = entidade_ativa.nome + " ataca " + _alvo.nome + ": " + _res;
                }
                
                // Pausa para ler ataque do inimigo
                delay_turno = 60;
                // Prepara para passar a vez
                estado = ESTADO_BATALHA.PROCESSANDO_ACAO;
                acao_completada = true; // Inimigo também usa a flag agora
            } else {
                avancar_turno();
            }
        }
        break;

    // --- ESTADO DE ESPERA (PROCESSANDO) ---
    case ESTADO_BATALHA.PROCESSANDO_ACAO:
        if (delay_turno > 0) {
            delay_turno--;
        } else {
            // O tempo de leitura acabou.
            
            // Se foi uma ação que finaliza turno (ataque/magia):
            if (acao_completada) {
                acao_completada = false; // Reseta flag
                avancar_turno();         // Passa a vez e muda o Texto para "Vez de..."
            } 
            else {
                // Se foi apenas uma pausa sem passar turno (ex: animação), devolve controle
                 if (object_is_ancestor(entidade_ativa.object_index, obj_jogador) || entidade_ativa.object_index == obj_jogador) {
                    estado = ESTADO_BATALHA.TURNO_JOGADOR;
                } else {
                    estado = ESTADO_BATALHA.TURNO_INIMIGO;
                }
            }
        }
        break;

case ESTADO_BATALHA.VITORIA:
    if (keyboard_check_pressed(vk_enter)) {
        
        // LOOP DE LIMPEZA: Percorre toda a party para resetar o estado
        for (var i = 0; i < array_length(global.party); i++) {
            var _membro = global.party[i];
            
            // 1. Tira o modo de batalha (para liberar movimento do líder)
            _membro.em_batalha = false;
            
            // 2. Define a visibilidade
            if (i == 0) {
                // Se for o primeiro da lista (Líder/Guerreiro), FICA VISÍVEL
                _membro.visible = true; 
            } else {
                // Se forem os outros (Mago, Ladino), FICA INVISÍVEL
                _membro.visible = false;
            }
        }

        // Volta para a sala do mapa
        room_goto(Room1);
    }
    break;
    case ESTADO_BATALHA.DERROTA:
        if (keyboard_check_pressed(vk_enter)) game_restart();
        break;
}