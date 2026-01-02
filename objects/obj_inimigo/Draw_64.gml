/// Draw Event do obj_inimigo

draw_self(); // Desenha o sprite do inimigo

// Desenha barra de vida pequena em cima da cabeça
var _x1 = x - 20;
var _y1 = bbox_top - 15;
var _x2 = x + 20;
var _y2 = bbox_top - 10;
var _pct = (hp_atual / hp_max) * 100;

draw_healthbar(_x1, _y1, _x2, _y2, _pct, c_black, c_red, c_lime, 0, true, true);