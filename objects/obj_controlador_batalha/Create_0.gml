/// Create Event - ATUALIZADO

// --- CONFIGURAÇÕES INICIAIS ---
estado = ESTADO_BATALHA.INICIO;
jogador = instance_find(obj_jogador, 0); 
inimigos = []; 
turno_atual = 0;
delay_turno = 0; // <--- NOVO: Variável para pausar o jogo entre ações

// --- CORES & MENU ---
cor_borda = make_color_rgb(255, 140, 0); 
cor_texto = make_color_rgb(255, 140, 0); 
cor_selecionado = c_yellow;
cor_fundo = c_black;

opcoes_principal = ["ATACAR", "REAGIR", "MAGIA", "CONVERSA", "FUGA"];
opcoes_reacao = ["BLOQUEIO", "ESQUIVA", "CONTRA"];
menu_atual = opcoes_principal; 
menu_index = 0; 

// --- CRIAÇÃO DO INIMIGO ---
var _ini = instance_create_layer(800, 100, "Instances", obj_inimigo); 
array_push(inimigos, _ini);

texto_log = "Batalha Iniciada!";

// --- FUNÇÃO DE AÇÃO ---
// --- FUNÇÃO PARA EXECUTAR MAGIA (NOVA) ---
executar_magia = function(_magia_struct) {
    var _alvo = inimigos[0];
    
    // Verifica Sanidade/Mana
    if (jogador.sanidade >= _magia_struct.custo) {
        jogador.sanidade -= _magia_struct.custo;
        
        // Causa o dano (ou cura se for negativo)
        // Nota: Se quiser fazer cura, o receber_dano do inimigo vai tirar vida.
        // Para cura no jogador, teríamos que fazer um if especial aqui.
        
        if (_magia_struct.dano < 0) {
            // Lógica de Cura (Ex: Guerreiro)
            var _cura = abs(_magia_struct.dano);
            jogador.hp_atual = min(jogador.hp_atual + _cura, jogador.hp_max);
            texto_log = "Voce se curou em " + string(_cura) + " HP!";
        } else {
            // Lógica de Dano (Ex: Mago)
            var _res_rit = _alvo.receber_dano(_magia_struct.dano, jogador);
            texto_log = _magia_struct.nome + "! " + _res_rit;
        }

        // Passa o turno
        if (instance_exists(_alvo) && _alvo.hp_atual <= 0) {
            instance_destroy(_alvo);
            estado = ESTADO_BATALHA.VITORIA;
            texto_log = "VITORIA!";
        } else {
            delay_turno = 80;
            estado = ESTADO_BATALHA.TURNO_INIMIGO;
        }

    } else {
        texto_log = "Sanidade insuficiente!";
        // Não passa o turno, deixa o jogador escolher outra coisa
    }
}

// --- FUNÇÃO DE AÇÃO JOGADOR (ATUALIZADA) ---
executar_acao_jogador = function(_tipo_acao) {
    var _alvo = inimigos[0];

    switch (_tipo_acao) {
        case "ATACAR":
            var _dano = jogador.arma_equipada.dano;
            // ... (logica de municao se tiver) ...
            var _res = _alvo.receber_dano(_dano, jogador);
            texto_log = "Voce atacou: " + _res;
            break;

        case "BLOQUEIO":
            jogador.esta_defendendo = true;
            texto_log = "Defesa preparada.";
            break;
            
        case "ESQUIVA":
            jogador.esta_esquivando = true;
            texto_log = "Pronto para esquivar.";
            break;

        case "CONTRA":
            jogador.esta_contra_atacando = true;
            texto_log = "Posicao de contra-ataque!";
            break;

        // REMOVI O CASE "MAGIA" DAQUI POIS AGORA ELE É TRATADO NO STEP EVENT
            
        case "CONVERSA": 
            texto_log = "Sem resposta...";
            break;

        case "FUGA": 
            if (random(100) > 50) { room_goto(rm_mapa); return; }
            else texto_log = "Fuga falhou!";
            break;
    }

    // Finalização do turno (Só acontece se não foi Fuga ou Erro)
    if (_tipo_acao != "FUGA") {
        if (instance_exists(_alvo) && _alvo.hp_atual <= 0) {
            instance_destroy(_alvo);
            estado = ESTADO_BATALHA.VITORIA;
            texto_log = "VITORIA!";
        } else {
            delay_turno = 80;
            estado = ESTADO_BATALHA.TURNO_INIMIGO;
        }
    }
}