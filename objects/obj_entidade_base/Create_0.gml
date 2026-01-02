/// Create Event do obj_entidade_base (Atualizado)
nome = "Entidade";
nivel = 1;
xp_atual = 0;
xp_proximo_nivel = 100;

// Atributos estilo D&D (Valor base 10)
atributo_forca = 10;    // Dano físico
atributo_destreza = 10; // Iniciativa e Esquiva
atributo_inteligencia = 10; // Dano mágico/Sanidade
atributo_constituicao = 10; // HP

// Status Derivados (Baseados nos arquivos existentes)
hp_max = 10 + floor((atributo_constituicao - 10) / 2); // Fórmula D&D simples
hp_atual = hp_max;
sanidade = 10 + atributo_inteligencia;
iniciativa = atributo_destreza;

// Inventário e Status de Combate
arma_equipada = new Arma("Punhos", 1, "MELEE", -1);
magias_conhecidos = [];
esta_defendendo = false;
esta_esquivando = false;
esta_contra_atacando = false;

// --- MÉTODOS DE NIVELAMENTO ---

// Função para ganhar XP
ganhar_xp = function(_quantidade) {
    xp_atual += _quantidade;
    if (xp_atual >= xp_proximo_nivel) {
        subir_nivel();
    }
}

// Função de Level Up (Pode ser sobrescrita pelos filhos)
subir_nivel = function() {
    nivel++;
    xp_atual -= xp_proximo_nivel;
    xp_proximo_nivel = floor(xp_proximo_nivel * 1.5);
    
    // Aumenta atributos base (exemplo simples)
    hp_max += 5 + floor((atributo_constituicao - 10) / 2);
    hp_atual = hp_max; // Cura ao upar
    show_debug_message(nome + " subiu para o nível " + string(nivel) + "!");
}

// Função para Receber Dano (SISTEMA DE REAÇÃO)
receber_dano = function(_dano, _origem) {
    var _dano_final = _dano;
    var _mensagem = "";

    // Lógica de Esquiva (50% de chance se ativada)
	if (esta_esquivando) {
        // Se destreza for alta, chance aumenta (exemplo de uso de atributo)
        var _chance = 50 + (atributo_destreza - 10); 
        if (random(100) < _chance) return "ESQUIVOU!";
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