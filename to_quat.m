function [ quat ] = to_quat( w )
%D_QUAT Summary of this function goes here
%   Detailed explanation goes here

    w_mag = norm(w);
    
    quat = [1,0,0,0];

    if (w_mag ~= 0)
        theta = w_mag;
        unit = w ./ w_mag;
        quat = [cos(theta/2), unit*sin(theta/2)];
        
        if (abs(norm(quat) - 1) > 0.0001)
            disp("Invalid rotation quaternion");
            norm(quat)
        end
    end
end

