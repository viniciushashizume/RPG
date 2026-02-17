/// Create Event do obj_guerreiro

// 1. Executa o código do pai (obj_jogador/obj_entidade_base)
// Isso inicializa hp_max = 100, sanidade = 50, etc.
event_inherited(); 

// 2. AGORA nós sobrescrevemos os valores. 
// Como este código roda DEPOIS do inherited, ele "ganha" do código do pai.

nome = "Guerreiro";

// Definindo Atributos Iniciais (Nível 1)
atributo_forca = 16;       
atributo_destreza = 10;
atributo_constituicao = 15; 
atributo_inteligencia = 8;

// Recalculando status baseados nos novos atributos
// Note que estamos mudando o valor que o pai definiu
hp_max = 12 + floor((atributo_constituicao - 10) / 2) * 20; // Multiplicador para ficar visível na barra
hp_atual = hp_max;

// Trocando a arma padrão (Punhos) pela Espada
var _dano_espada = 6 + floor((atributo_forca - 10) / 2);
arma_equipada = new Arma("Espada Longa", _dano_espada, "MELEE", -1);

// Adicionando habilidade única
var _skill = new Magia("Retomar Folego", -10, 2, 0); // Dano negativo = cura
array_push(magias_conhecidos, _skill);

subir_nivel = function() {
    nivel++;
    xp_atual -= xp_proximo_nivel;
    xp_proximo_nivel = floor(xp_proximo_nivel * 1.5);
    
    // Atributos de Guerreiro
    atributo_forca += 2;
    atributo_constituicao += 1;
    hp_max += 10;
    hp_atual = hp_max;

    // Habilidade Nível 2: Pulso de Ação
    if (nivel == 2) {
        // Custo 0, Dano 0 (efeito especial no controlador)
        var _skill = new Magia("Pulso de Ação", 0, 0, 0); 
        array_push(magias_conhecidos, _skill);
        show_debug_message("Aprendeu Pulso de Ação!");
    }
    
    texto_log = "Guerreiro subiu para Nvl " + string(nivel) + "!";
}
