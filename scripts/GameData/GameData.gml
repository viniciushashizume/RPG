// Script: GameData
enum TIPO_DANO { FISICO, FOGO, RITUAL }
enum ESTADO_BATALHA { 
    INICIO, 
    TURNO_JOGADOR, 
    MENU_REACAO, // <--- NOVO ESTADO
    PROCESSANDO_ACAO, 
    TURNO_INIMIGO, 
    VITORIA, 
    DERROTA 
}

// Construtor de Armas (Brancas ou de Fogo)
function Arma(_nome, _dano, _tipo, _municao_max) constructor {
    nome = _nome;
    dano = _dano;
    tipo = _tipo; // 'MELEE' ou 'RANGED'
    municao = _municao_max; // -1 para infinita (armas brancas)
}

// Construtor de Rituais (Magias)
function Ritual(_nome, _dano, _custo_sanidade, _turnos_carregar) constructor {
    nome = _nome;
    dano = _dano;
    custo = _custo_sanidade;
    carregar = _turnos_carregar; // Complexidade: 0 = instantâneo, 1+ = precisa preparar
}