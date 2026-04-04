// Seguir jogador suavemente
if (instance_exists(obj_jogador)) {
    var _target_x = obj_jogador.x - (camera_get_view_width(view_camera[0]) / 2);
    var _target_y = obj_jogador.y - (camera_get_view_height(view_camera[0]) / 2);
    
    var _cur_x = camera_get_view_x(view_camera[0]);
    var _cur_y = camera_get_view_y(view_camera[0]);
    
    camera_set_view_pos(view_camera[0], 
        lerp(_cur_x, _target_x, 0.1), 
        lerp(_cur_y, _target_y, 0.1));
}