/// Create Event do obj_jogador

// 1. Puxa as variáveis do pai (HP, funções de dano, etc)
event_inherited(); 

// 2. Cria a variável que estava faltando (A CORREÇÃO É AQUI)
em_batalha = false; 

// 3. Suas outras definições
arma_equipada = new Arma("ESPADA", 15, "MEELEE", 6);
nome = "Personagem";