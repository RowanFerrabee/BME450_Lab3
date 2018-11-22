function [ q_prod ] = quat_product( q_1, q_2 )

    % Multiply two quaternions
    q_prod(1) = q_1(1)*q_2(1) - q_1(2)*q_2(2) - q_1(3)*q_2(3) - q_1(4)*q_2(4);
    q_prod(2) = q_1(1)*q_2(2) + q_1(2)*q_2(1) + q_1(3)*q_2(4) - q_1(4)*q_2(3);
    q_prod(3) = q_1(1)*q_2(3) - q_1(2)*q_2(4) + q_1(3)*q_2(1) + q_1(4)*q_2(2);
    q_prod(4) = q_1(1)*q_2(4) + q_1(2)*q_2(3) - q_1(3)*q_2(2) + q_1(4)*q_2(1);
end

