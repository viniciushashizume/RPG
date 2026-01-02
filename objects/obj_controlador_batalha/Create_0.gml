/// Create Event - FINAL CORRIGIDO

// ==============================================================================
// 1. SISTEMA DE SEGURANÇA (Para testes diretos na rm_batalha)
// ==============================================================================
if (!variable_global_exists("party")) {
    show_debug_message("AVISO: Criando Party de Teste Automática!");
    global.party = [];

    // Cria instâncias temporárias (certifique-se de que os objetos existem)
    // Se não tiverem objetos criados, o jogo vai dar erro ao desenhar, 
    // então garanta que obj_guerreiro, etc. existem no projeto.
    if (object_exists(obj_guerreiro)) {
        var _g = instance_create_layer(-200, -200, "Instances", obj_guerreiro);
        _g.persistent = true;
        array_push(global.party, _g);
    }
    
    // Adicione outros membros se quiser testar com mais gente
    // array_push(global.party, instance_create_layer(... obj_mago));
}
// ==============================================================================

// --- CONFIGURAÇÕES INICIAIS ---
estado = ESTADO_BATALHA.INICIO;

// Pega a party global
party = global.party; 
// --- POSICIONAMENTO DA PARTY (Faltava isso!) ---
// --- POSICIONAMENTO DA PARTY (Versão Diagonal) ---
var _inicio_x = 250;
var _inicio_y = 300;
var _espaco_x = 20;  // Diferença horizontal (efeito escada)
var _espaco_y = 100; // Aumentei para 100 para dar mais ar entre eles

for (var i = 0; i < array_length(party); i++) {
    var _membro = party[i];
    
    // Posiciona em diagonal
    // O Guerreiro fica na frente, o próximo um pouco pra trás, etc.
    _membro.x = _inicio_x - (i * _espaco_x); 
    _membro.y = _inicio_y + (i * _espaco_y);
    
    // Garante visibilidade e profundidade correta
    // depth = -y faz com que quem está mais embaixo (frente) cubra quem está atrás
    _membro.visible = true;
    _membro.depth = -_membro.y; 
    
    // IMPORTANTE: Impede que eles andem sozinhos se você tiver código de movimento no Step
    _membro.em_batalha = true; 
}

// Controle de Turnos da Party
membro_atual_index = 0; 

// Segurança caso a party esteja vazia (evita crash imediato)
if (array_length(party) > 0) {
    personagem_atual = party[membro_atual_index];
} else {
    personagem_atual = noone;
}

inimigos = [];
delay_turno = 0;

// --- CORES & VISUAL ---
cor_borda = make_color_rgb(255, 140, 0);
cor_texto = make_color_rgb(255, 140, 0); 
cor_selecionado = c_yellow;
cor_fundo = c_black;

// --- DEFINIÇÃO DOS MENUS (AQUI ESTAVA O ERRO) ---
opcoes_principal = ["ATACAR", "REAGIR", "MAGIA", "CONVERSA", "FUGA"];
opcoes_reacao = ["BLOQUEIO", "ESQUIVA", "CONTRA"]; // <--- ESSA LINHA FALTAVA

menu_atual = opcoes_principal; 
menu_index = 0;

// --- CRIAÇÃO DO INIMIGO ---
// Cria um inimigo básico para teste
var _ini = instance_create_layer(800, 400, "Instances", obj_inimigo); 
array_push(inimigos, _ini);

texto_log = "Batalha Iniciada!";


// ==============================================================================
// FUNÇÕES DE AÇÃO (ATUALIZADAS PARA O SISTEMA DE PARTY)
// ==============================================================================

// --- FUNÇÃO PARA EXECUTAR MAGIA ---
executar_magia = function(_magia_struct) {
    var _alvo = inimigos[0];
    
    // Verifica Sanidade/Mana do PERSONAGEM ATUAL
    if (personagem_atual.sanidade >= _magia_struct.custo) {
        personagem_atual.sanidade -= _magia_struct.custo;

        // Causa o dano (ou cura se for negativo)
        if (_magia_struct.dano < 0) {
            // Cura
            var _cura = abs(_magia_struct.dano);
            personagem_atual.hp_atual = min(personagem_atual.hp_atual + _cura, personagem_atual.hp_max);
            texto_log = "Voce se curou em " + string(_cura) + " HP!";
        } else {
            // Dano
            var _res_rit = _alvo.receber_dano(_magia_struct.dano, personagem_atual);
            texto_log = _magia_struct.nome + "! " + _res_rit;
        }

        // Verifica morte do inimigo
        if (instance_exists(_alvo) && _alvo.hp_atual <= 0) {
            instance_destroy(_alvo);
            estado = ESTADO_BATALHA.VITORIA;
            texto_log = "VITORIA!";
        } else {
            delay_turno = 80;
            avancar_turno_party(); // Chama função auxiliar para passar a vez
        }

    } else {
        texto_log = "Sanidade insuficiente!";
    }
}

// --- FUNÇÃO DE AÇÃO FÍSICA ---
executar_acao_jogador = function(_tipo_acao) {
    var _alvo = inimigos[0];
    
    switch (_tipo_acao) {
        case "ATACAR":
            var _dano = 5; 
            if (variable_instance_exists(personagem_atual, "arma_equipada") && personagem_atual.arma_equipada != undefined) {
                _dano = personagem_atual.arma_equipada.dano;
            }
            var _res = _alvo.receber_dano(_dano, personagem_atual);
            texto_log = "Voce atacou: " + _res;
            break;

        case "BLOQUEIO":
            personagem_atual.esta_defendendo = true;
            texto_log = "Defesa preparada.";
            break;
            
        case "ESQUIVA":
            personagem_atual.esta_esquivando = true;
            texto_log = "Pronto para esquivar.";
            break;

        case "CONTRA":
            personagem_atual.esta_contra_atacando = true;
            texto_log = "Posicao de contra-ataque!";
            break;
            
        case "CONVERSA": 
            texto_log = "Sem resposta...";
            break;

        case "FUGA": 
            if (random(100) > 50) { 
                room_goto(rm_mapa); 
                return; 
            }
            else texto_log = "Fuga falhou!";
            break;
    }

    // Finalização do turno
    if (_tipo_acao != "FUGA") {
        if (instance_exists(_alvo) && _alvo.hp_atual <= 0) {
            instance_destroy(_alvo);
            estado = ESTADO_BATALHA.VITORIA;
            texto_log = "VITORIA!";
        } else {
            delay_turno = 80;
            avancar_turno_party(); // Chama função auxiliar
        }
    }
}

// --- FUNÇÃO AUXILIAR PARA PASSAR A VEZ ENTRE OS MEMBROS ---
avancar_turno_party = function() {
    membro_atual_index++;
    
    // Se acabou os membros da party, vai para o inimigo
    if (membro_atual_index >= array_length(party)) {
        estado = ESTADO_BATALHA.TURNO_INIMIGO;
    } else {
        // Se tem mais membro, atualiza o atual e reseta menu
        texto_log = "Vez de " + party[membro_atual_index].nome;
        menu_index = 0;
        menu_atual = opcoes_principal;
        estado = ESTADO_BATALHA.TURNO_JOGADOR;
    }
}