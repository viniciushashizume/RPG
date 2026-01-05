// Script: GameData
enum TIPO_DANO { FISICO, FOGO, MAGIA }
enum ESTADO_BATALHA { 
    INICIO, 
    TURNO_JOGADOR, 
    MENU_REACAO,
	MENU_MAGIA,// <--- NOVO ESTADO
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
function Magia(_nome, _dano, _custo_sanidade, _turnos_carregar) constructor {
    nome = _nome;
    dano = _dano;
    custo = _custo_sanidade;
    carregar = _turnos_carregar; // Complexidade: 0 = instantâneo, 1+ = precisa preparar
}

// Adicione isso no final do script GameData.gml

// Construtor de Itens Consumíveis
function Item(_nome, _descricao, _efeito_script) constructor {
    nome = _nome;
    descricao = _descricao;
    efeito = _efeito_script; // Função a ser executada ao usar
    quantidade = 1;
}

// Cria o inventário global se não existir
if (!variable_global_exists("inventario")) {
    global.inventario = [];
}