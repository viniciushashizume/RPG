// 1. Executa o código do pai (obj_entidade_base)
// Isso garante que hp_max, sanidade, etc., sejam criados.
event_inherited(); 

// 2. Agora sobrescrevemos SÓ o que queremos mudar
arma_equipada = new Arma("Garra", 8 , "MELEE", -1);
nome = "Zumbi"

xp_recompensa = 300;