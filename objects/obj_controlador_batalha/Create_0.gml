/// Create Event - CORRIGIDO (Iniciativa)

// ==============================================================================
// 1. SISTEMA DE SEGURANÇA E PARTY
// ==============================================================================
if (!variable_global_exists("party")) {
    global.party = [];
    if (object_exists(obj_guerreiro)) {
        var _g = instance_create_layer(-200, -200, "Instances", obj_guerreiro);
        _g.persistent = true;
        _g.nome = "Guerreiro"; // Garante que tem nome para não dar erro no log
        _g.iniciativa = 10;    // Valor padrão caso não tenha
        array_push(global.party, _g);
    }
}

party = global.party;

// --- POSICIONAMENTO DA PARTY ---
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
// 2. CRIAÇÃO DOS INIMIGOS (MOVIDO PARA CIMA)
// ==============================================================================
inimigos = [];

// Cria um inimigo básico para teste
var _ini = instance_create_layer(800, 400, "Instances", obj_inimigo); 
// Garante que o inimigo tenha valores padrão se faltar no objeto
if (!variable_instance_exists(_ini, "iniciativa")) _ini.iniciativa = 5; 
if (!variable_instance_exists(_ini, "nome")) _ini.nome = "Inimigo";

array_push(inimigos, _ini);

// ==============================================================================
// 3. SISTEMA DE ORDEM DE TURNOS (LISTA UNIFICADA)
// ==============================================================================
lista_turnos = [];

// Adiciona heróis
for (var i = 0; i < array_length(party); i++) {
    array_push(lista_turnos, party[i]);
}

// Adiciona inimigos (Agora funciona pois 'inimigos' já foi criado acima)
for (var i = 0; i < array_length(inimigos); i++) {
    array_push(lista_turnos, inimigos[i]);
}

// Ordena pela INICIATIVA (Maior -> Menor)
array_sort(lista_turnos, function(_a, _b) {
    // Se a variavel iniciativa não existir, usa 0 para evitar crash
    var _init_a = variable_instance_exists(_a, "iniciativa") ? _a.iniciativa : 0;
    var _init_b = variable_instance_exists(_b, "iniciativa") ? _b.iniciativa : 0;
    return _init_b - _init_a;
});

// Configuração Inicial do Turno
turno_index = 0;
entidade_ativa = lista_turnos[turno_index];

// Define cores e menus
cor_borda = make_color_rgb(255, 140, 0);
cor_texto = make_color_rgb(255, 140, 0); 
cor_selecionado = c_yellow;
cor_fundo = c_black;

opcoes_principal = ["ATACAR", "REAGIR", "MAGIA", "CONVERSA", "FUGA"];
opcoes_reacao = ["BLOQUEIO", "ESQUIVA", "CONTRA"];
menu_atual = opcoes_principal; 
menu_index = 0;

// Verifica quem começa
if (object_is_ancestor(entidade_ativa.object_index, obj_jogador) || entidade_ativa.object_index == obj_jogador) {
    estado = ESTADO_BATALHA.TURNO_JOGADOR;
    personagem_atual = entidade_ativa;
    texto_log = "Vez de " + entidade_ativa.nome;
} else {
    estado = ESTADO_BATALHA.TURNO_INIMIGO;
    personagem_atual = noone; // Menu desativado
    texto_log = "Vez de " + entidade_ativa.nome;
}

delay_turno = 0;


// ==============================================================================
// 4. FUNÇÕES DO CONTROLADOR
// ==============================================================================

// --- NOVA FUNÇÃO PARA AVANÇAR TURNO ---
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
    
    texto_log = "Vez de " + entidade_ativa.nome;
    
    // Verifica se é Jogador ou Inimigo
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

// --- EXECUTAR MAGIA ---
executar_magia = function(_magia_struct) {
    // Nota: precisa selecionar alvo dinamicamente depois, por enquanto pega o primeiro vivo
    var _alvo = inimigos[0]; 
    if (!instance_exists(_alvo) || _alvo.hp_atual <= 0) {
        // Tenta achar outro vivo
        for(var i=0; i<array_length(inimigos); i++) {
            if (inimigos[i].hp_atual > 0) { _alvo = inimigos[i]; break; }
        }
    }

    if (personagem_atual.sanidade >= _magia_struct.custo) {
        personagem_atual.sanidade -= _magia_struct.custo;

        if (_magia_struct.dano < 0) {
            var _cura = abs(_magia_struct.dano);
            personagem_atual.hp_atual = min(personagem_atual.hp_atual + _cura, personagem_atual.hp_max);
            texto_log = "Cura: " + string(_cura);
        } else {
            if (instance_exists(_alvo)) {
                var _res = _alvo.receber_dano(_magia_struct.dano, personagem_atual);
                texto_log = _magia_struct.nome + "! " + _res;
            }
        }
        
        // Verifica vitoria
        var _inimigos_vivos = 0;
        for(var i=0; i<array_length(inimigos); i++) {
            if (inimigos[i].hp_atual > 0) _inimigos_vivos++;
        }

        if (_inimigos_vivos == 0) {
            estado = ESTADO_BATALHA.VITORIA;
            texto_log = "VITORIA!";
        } else {
            delay_turno = 80;
            avancar_turno();
        }

    } else {
        texto_log = "Sanidade insuficiente!";
    }
}

// --- AÇÃO FÍSICA JOGADOR ---
executar_acao_jogador = function(_tipo_acao) {
    // Seleção simples de alvo (primeiro inimigo vivo)
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
            if (random(100) > 50) { 
                room_goto(rm_mapa); // Ajuste para sua sala de mapa
                return; 
            }
            texto_log = "Fuga falhou!";
            break;
    }

    // Finaliza Turno
    if (_tipo_acao != "FUGA") {
        // Checa Vitória
        var _todos_mortos = true;
        for(var i=0; i<array_length(inimigos); i++) {
            if (inimigos[i].hp_atual > 0) _todos_mortos = false;
        }

        if (_todos_mortos) {
            estado = ESTADO_BATALHA.VITORIA;
            texto_log = "VITORIA!";
        } else {
            delay_turno = 80;
            avancar_turno();
        }
    }
}