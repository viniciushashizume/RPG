/// Create Event do obj_ladino
event_inherited();

nome = "Ladino";

// Atributos D&D Nível 1 (Foco em DEX)
atributo_forca = 10;
atributo_destreza = 17; // +3 mod
atributo_constituicao = 12;
atributo_inteligencia = 12;

// Recalcula Status
hp_max = 8 + floor((atributo_constituicao - 10) / 2);
hp_atual = hp_max;
iniciativa = atributo_destreza * 2; // Ladino é muito rápido

// Equipamento
// Adaga usa Destreza no dano
var _dano_adaga = 4 + floor((atributo_destreza - 10) / 2);
arma_equipada = new Arma("Adaga", _dano_adaga, "MELEE", -1);

// Habilidade: Ataque Furtivo (Alto dano, alto custo de preparo ou sanidade)
var _sneak_attack = new Magia("Ataque Furtivo", 20, 10, 0);
array_push(magias_conhecidos, _sneak_attack);

subir_nivel = function() {
    nivel++;
    xp_atual -= xp_proximo_nivel;
    xp_proximo_nivel = floor(xp_proximo_nivel * 1.5);
    
    // Atributos de Ladino
    atributo_destreza += 2;
    iniciativa = atributo_destreza * 2;
    hp_max += 6;
    hp_atual = hp_max;

    // Habilidade Nível 2: Ação Astuta
    if (nivel == 2) {
        var _skill = new Magia("Ação Astuta", 0, 0, 0);
        array_push(magias_conhecidos, _skill);
        show_debug_message("Aprendeu Ação Astuta!");
    }
}