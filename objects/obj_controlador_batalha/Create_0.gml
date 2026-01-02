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

opcoes_principal = ["ATACAR", "REAGIR", "RITUAL", "CONVERSA", "FUGA"];
opcoes_reacao = ["BLOQUEIO", "ESQUIVA", "CONTRA"];
menu_atual = opcoes_principal; 
menu_index = 0; 

// --- CRIAÇÃO DO INIMIGO ---
var _ini = instance_create_layer(800, 100, "Instances", obj_inimigo); 
array_push(inimigos, _ini);

texto_log = "Batalha Iniciada!";

// --- FUNÇÃO DE AÇÃO ---
executar_acao_jogador = function(_tipo_acao) {
    var _alvo = inimigos[0]; 

    // Lógica das ações (igual ao anterior)
    switch (_tipo_acao) {
        case "ATACAR":
            var _dano = jogador.arma_equipada.dano;
            if (jogador.arma_equipada.tipo == "RANGED") {
                if (jogador.arma_equipada.municao > 0) jogador.arma_equipada.municao--;
                else _dano = floor(_dano / 4);
            }
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

        case "RITUAL":
            var _ritual = new Ritual("Bola de Fogo", 30, 10, 0);
            if (jogador.sanidade >= _ritual.custo) {
                jogador.sanidade -= _ritual.custo;
                var _res_rit = _alvo.receber_dano(_ritual.dano, jogador);
                texto_log = "Ritual! " + _res_rit;
            } else {
                texto_log = "Sem sanidade!";
                return; 
            }
            break;
            
        case "CONVERSA": texto_log = "Sem resposta..."; break;
        case "FUGA": 
            if (random(100) > 50) { room_goto(rm_mapa); return; }
            else texto_log = "Fuga falhou!";
            break;
    }

    // --- AQUI ESTÁ A CORREÇÃO DO TRAVAMENTO ---
    // Se o inimigo morreu
    if (instance_exists(_alvo) && _alvo.hp_atual <= 0) {
        instance_destroy(_alvo);
        estado = ESTADO_BATALHA.VITORIA;
        texto_log = "VITORIA!";
    } else {
        // Se o inimigo ainda vive, passa pro turno dele COM UM DELAY
        delay_turno = 80; // Espera 80 frames (aprox 1.5 seg) para você ler o texto
        estado = ESTADO_BATALHA.TURNO_INIMIGO;
    }
}