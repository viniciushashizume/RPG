/// Create Event do obj_slime

// 1. Executa o código do pai (obj_entidade_base) para criar as variáveis básicas
event_inherited();

// 2. Personalização do Slime
nome = "Slime";
hp_max = 20;        // Vida menor que a do Zumbi (que é 40)
hp_atual = hp_max;
xp_recompensa = 100; // XP menor

// 3. Arma/Ataque do Slime
// Dano 4 (o Zumbi tem 8)
arma_equipada = new Arma("Gosma", 4, "MELEE", -1);