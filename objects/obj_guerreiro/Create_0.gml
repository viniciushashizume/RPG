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