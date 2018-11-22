function [ v_out ] = rotate_by( v_in, q_rot )
    % Rotate 3-vector v_in by quaternion q_rot
    if (abs(norm(q_rot) - 1) > 0.0001)
        disp("Invalid rotation quaternion");
        disp(q_rot);
    end
    
    q_rot_inv = [q_rot(1), -q_rot(2:4)] ./ sum(q_rot .^ 2);
    
    v_out = quat_product( quat_product(q_rot, [0, v_in]), q_rot_inv);
    v_out = v_out(2:4);
end

