/// Create Event do obj_mago
event_inherited(); // Carrega os padrões

nome = "Mago";

// Mago é fraco fisicamente, mas inteligente
atributo_forca = 8;
atributo_destreza = 13;
atributo_constituicao = 10;
atributo_inteligencia = 17; 

// Vida menor que a do guerreiro
hp_max = 6 + floor((atributo_constituicao - 10) / 2) * 20;
hp_atual = hp_max;

// Muita sanidade para usar magias
sanidade = 30 + atributo_inteligencia;

// Arma fraca
arma_equipada = new Arma("Cajado", 4, "MELEE", -1);

// Magia de ataque inicial
var _magia = new Magia("Misseis Magicos", 15, 5, 0);
array_push(magias_conhecidos, _magia);