/// Create Event - CORRIGIDO (Sistema de Delay e Ação)

// ==============================================================================
// 1. SISTEMA DE SEGURANÇA E PARTY

// ==============================================================================
xp_processado = false;
if (!variable_global_exists("party")) {
    global.party = [];
    if (object_exists(obj_guerreiro)) {
        var _g = instance_create_layer(-200, -200, "Instances", obj_guerreiro);
        _g.persistent = true;
        _g.nome = "Guerreiro";
        _g.iniciativa = 10;
        array_push(global.party, _g);
    }
}

party = global.party;

// Posicionamento
var _inicio_x = 250;
var _inicio_y = 300;
var _espaco_y = 100;
for (var i = 0; i < array_length(party); i++) {
    var _membro = party[i];
    _membro.x = _inicio_x - (i * 20);
    _membro.y = _inicio_y + (i * _espaco_y);
    _membro.visible = true;
    _membro.depth = -_membro.y;
    _membro.em_batalha = true;
}

// ==============================================================================
// 2. CRIAÇÃO DOS INIMIGOS
// ==============================================================================
inimigos = [];
var _ini = instance_create_layer(800, 400, "Instances", obj_zumbi);
if (!variable_instance_exists(_ini, "iniciativa")) _ini.iniciativa = 5;
if (!variable_instance_exists(_ini, "nome")) _ini.nome = "Inimigo";
array_push(inimigos, _ini);

// ==============================================================================
// 3. SISTEMA DE ORDEM DE TURNOS
// ==============================================================================
lista_turnos = [];
for (var i = 0; i < array_length(party); i++) array_push(lista_turnos, party[i]);
for (var i = 0; i < array_length(inimigos); i++) array_push(lista_turnos, inimigos[i]);

array_sort(lista_turnos, function(_a, _b) {
    var _init_a = variable_instance_exists(_a, "iniciativa") ? _a.iniciativa : 0;
    var _init_b = variable_instance_exists(_b, "iniciativa") ? _b.iniciativa : 0;
    return _init_b - _init_a;
});

turno_index = 0;
entidade_ativa = lista_turnos[turno_index];

// Cores e Menus
cor_borda = make_color_rgb(255, 140, 0);
cor_texto = make_color_rgb(255, 140, 0); 
cor_selecionado = c_yellow;
cor_fundo = c_black;

opcoes_principal = ["ATACAR", "REAGIR", "MAGIA", "CONVERSA", "FUGA"];
opcoes_reacao = ["BLOQUEIO", "ESQUIVA", "CONTRA"];
menu_atual = opcoes_principal; 
menu_index = 0;

// Variáveis de Controle de Fluxo
delay_turno = 0;
acao_completada = false; // <--- NOVA VARIÁVEL IMPORTANTE

// Configuração Inicial
if (object_is_ancestor(entidade_ativa.object_index, obj_jogador) || entidade_ativa.object_index == obj_jogador) {
    estado = ESTADO_BATALHA.TURNO_JOGADOR;
    personagem_atual = entidade_ativa;
    texto_log = "Sua vez! " + entidade_ativa.nome;
} else {
    estado = ESTADO_BATALHA.TURNO_INIMIGO;
    personagem_atual = noone;
    texto_log = "Vez de " + entidade_ativa.nome;
}


// ==============================================================================
// 4. FUNÇÕES DO CONTROLADOR
// ==============================================================================

avancar_turno = function() {
    turno_index++;
    if (turno_index >= array_length(lista_turnos)) {
        turno_index = 0; // Novo Round
    }
    
    entidade_ativa = lista_turnos[turno_index];
    
    // Pula mortos
    if (!instance_exists(entidade_ativa) || entidade_ativa.hp_atual <= 0) {
        avancar_turno();
        return;
    }
    
    // Reseta status
    entidade_ativa.esta_defendendo = false;
    entidade_ativa.esta_esquivando = false;
    entidade_ativa.esta_contra_atacando = false;
    
    texto_log = "Vez de " + entidade_ativa.nome; // Define o texto do NOVO turno

    // Verifica quem joga
    if (object_is_ancestor(entidade_ativa.object_index, obj_jogador) || entidade_ativa.object_index == obj_jogador) {
        estado = ESTADO_BATALHA.TURNO_JOGADOR;
        personagem_atual = entidade_ativa;
        menu_index = 0;
        menu_atual = opcoes_principal;
    } else {
        estado = ESTADO_BATALHA.TURNO_INIMIGO;
        personagem_atual = noone;
        delay_turno = 60;
    }
}

// --- EXECUTAR MAGIA (ATUALIZADO) ---
executar_magia = function(_magia_struct) {
    var _alvo = inimigos[0];
    // Tenta achar alvo vivo
    if (!instance_exists(_alvo) || _alvo.hp_atual <= 0) {
        for(var i=0; i<array_length(inimigos); i++) {
            if (inimigos[i].hp_atual > 0) { _alvo = inimigos[i]; break; }
        }
    }

    if (personagem_atual.sanidade >= _magia_struct.custo) {
        personagem_atual.sanidade -= _magia_struct.custo;
        
        if (_magia_struct.dano < 0) {
            // Cura
            var _cura = abs(_magia_struct.dano);
            personagem_atual.hp_atual = min(personagem_atual.hp_atual + _cura, personagem_atual.hp_max);
            texto_log = "Cura: +" + string(_cura) + " HP!";
        } else {
            // Dano
            if (instance_exists(_alvo)) {
                var _res = _alvo.receber_dano(_magia_struct.dano, personagem_atual);
                texto_log = _magia_struct.nome + "! " + _res;
            }
        }
        
        // Verifica vitoria imediata
        var _inimigos_vivos = 0;
        for(var i=0; i<array_length(inimigos); i++) {
            if (inimigos[i].hp_atual > 0) _inimigos_vivos++;
        }

        if (_inimigos_vivos == 0) {
            estado = ESTADO_BATALHA.VITORIA;
            texto_log = "VITORIA!";
        } else {
            // --- AQUI ESTA A CORREÇÃO ---
            // Em vez de avancar_turno() direto, pausamos para ler
            estado = ESTADO_BATALHA.PROCESSANDO_ACAO;
            delay_turno = 90;       // 1.5 segundos para ler
            acao_completada = true; // Avisa o Step que o turno acabou
        }

    } else {
        texto_log = "Sanidade insuficiente!";
    }
}

// --- AÇÃO FÍSICA JOGADOR (ATUALIZADO) ---
executar_acao_jogador = function(_tipo_acao) {
    var _alvo = noone;
    for(var i=0; i<array_length(inimigos); i++) {
        if (inimigos[i].hp_atual > 0) { _alvo = inimigos[i]; break; }
    }

    switch (_tipo_acao) {
        case "ATACAR":
            if (_alvo != noone) {
                var _dano = 5;
                if (variable_instance_exists(personagem_atual, "arma_equipada") && is_struct(personagem_atual.arma_equipada)) {
                    _dano = personagem_atual.arma_equipada.dano;
                }
                var _res = _alvo.receber_dano(_dano, personagem_atual);
                texto_log = "Ataque: " + _res;
            }
            break;
        case "BLOQUEIO":
            personagem_atual.esta_defendendo = true;
            texto_log = "Defesa preparada.";
            break;
        case "ESQUIVA":
            personagem_atual.esta_esquivando = true;
            texto_log = "Preparando esquiva.";
            break;
        case "CONTRA":
            personagem_atual.esta_contra_atacando = true;
            texto_log = "Posicao de contra-ataque!";
            break;
        case "CONVERSA": 
            texto_log = "Sem resposta...";
            break;
        case "FUGA": 
            if (random(100) > 50) { room_goto(rm_mapa); return; }
            texto_log = "Fuga falhou!";
            break;
    }

    if (_tipo_acao != "FUGA") {
        var _todos_mortos = true;
        for(var i=0; i<array_length(inimigos); i++) {
            if (inimigos[i].hp_atual > 0) _todos_mortos = false;
        }

        if (_todos_mortos) {
            estado = ESTADO_BATALHA.VITORIA;
            texto_log = "VITORIA!";
        } else {
             // --- CORREÇÃO AQUI TAMBÉM ---
             estado = ESTADO_BATALHA.PROCESSANDO_ACAO;
             delay_turno = 90;
             acao_completada = true;
        }
    }
}