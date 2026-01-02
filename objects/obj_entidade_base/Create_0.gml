nome = "Entidade";
hp_max = 100;
hp_atual = hp_max;
sanidade = 50; // Para rituais
iniciativa = 10;

// Inventário
arma_equipada = new Arma("Punhos", 5, "MELEE", -1);
rituais_conhecidos = [];

esta_defendendo = false; // Bloqueio
esta_esquivando = false; // Chance de esquiva
esta_contra_atacando = false; // Dano de volta

// Função para Receber Dano (SISTEMA DE REAÇÃO)
receber_dano = function(_dano, _origem) {
    var _dano_final = _dano;
    var _mensagem = "";

    // Lógica de Esquiva (50% de chance se ativada)
    if (esta_esquivando) {
        if (random(100) < 50) {
            return "ESQUIVOU!";
        }
    }

    // Lógica de Bloqueio (Reduz 50% do dano)
    if (esta_defendendo) {
        _dano_final = floor(_dano * 0.5);
        _mensagem = "BLOQUEADO! ";
    }

    // Lógica de Contra-Ataque
    if (esta_contra_atacando) {
        // Causa metade do dano recebido de volta ao atacante
        _origem.hp_atual -= floor(_dano * 0.5);
        _mensagem = "CONTRA-ATAK! ";
    }

    hp_atual -= _dano_final;
    return _mensagem + string(_dano_final) + " de dano";
}