/// Create Event - Inicializa a Party Global
// Lista global que conterá as INSTÂNCIAS dos seus heróis

if (instance_number(object_index) > 1) { 
    instance_destroy(); 
    exit; 
}

// 2. Se a party já existe (voltando da batalha), não crie os personagens de novo!
if (variable_global_exists("party") && array_length(global.party) > 0) {
    exit;
}
global.party = [];

var _guerreiro = instance_create_layer(-100, -100, "Instances", obj_guerreiro);
var _mago = instance_create_layer(-100, -100, "Instances", obj_mago);
var _ladino = instance_create_layer(-100, -100, "Instances", obj_ladino);

// Importante: Marcar como persistentes para manter HP/Status entre salas
_guerreiro.persistent = true;
_mago.persistent = true;
_ladino.persistent = true;

// Desativar ou esconder visualmente no mapa se apenas o líder deve aparecer
_mago.visible = false;
_ladino.visible = false;

// Adiciona ao array
array_push(global.party, _guerreiro);
array_push(global.party, _mago);
array_push(global.party, _ladino);