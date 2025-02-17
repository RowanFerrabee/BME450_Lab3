%% Get Excel Data
clc;
clear;

% orientation_data = xlsread("BME450_Lab3 - IMU.xlsx", "Sensor Orientation Quaternions");
% gyro_data = xlsread("BME450_Lab3 - IMU.xlsx", "Sensor Angular Velocity");
% segment_gyro_data = xlsread("BME450_Lab3 - IMU.xlsx", "Segment Angular Velocity");
% segment_marker_pos = xlsread("BME450_Lab3 - Camera.xlsx", "Segment Marker Positions");
% joint_angles = xlsread("BME450_Lab3 - IMU.xlsx", "Joint Angle");
load imu_data.mat

%% 

% Initial Quaternion Vals
dt = 0.01;

right_not_left = 0;
thigh_not_shank = 1;

orientation_left_thigh = 18:21;
gyro_left_thigh = 14:16;
global_gyro_left_thigh = 17:19;

orientation_right_thigh = 6:9;
gyro_right_thigh = 5:7;
global_gyro_right_thigh = 5:7;

orientation_left_shank = 22:25;
gyro_left_shank = 17:19;
global_gyro_left_shank = 20:22;

orientation_right_shank = 10:13;
gyro_right_shank = 8:10;
global_gyro_right_shank = 8:10;

if (right_not_left && thigh_not_shank)
    gyro_ids = gyro_right_thigh;
    global_gyro_ids = global_gyro_right_thigh;
    orientation_ids = orientation_right_thigh;
    title_string = "Right Thigh";
elseif (~(right_not_left) && thigh_not_shank)
    gyro_ids = gyro_left_thigh;
    global_gyro_ids = global_gyro_left_thigh;
    orientation_ids = orientation_left_thigh;
    title_string = "Left Thigh";
elseif (right_not_left && ~(thigh_not_shank))
    gyro_ids = gyro_right_shank;
    global_gyro_ids = global_gyro_right_shank;
    orientation_ids = orientation_right_shank;
    title_string = "Right Shank";
else
    gyro_ids = gyro_left_shank;
    global_gyro_ids = global_gyro_left_shank;
    orientation_ids = orientation_left_shank;
    title_string = "Left Shank";
end
    
samples = size(orientation_data, 1);
integrated_quat = zeros(samples, 4);
true_quat = zeros(samples, 4);
global_gyro_meas = zeros(samples, 3);

integrated_quat(1,:) = orientation_data(1,orientation_ids);
true_quat(1,:) = orientation_data(1,orientation_ids);

for i=2:samples
    % Part 1 Gyro Integration
    gyro_meas = gyro_data(i,gyro_ids);
    
    dq = to_quat(gyro_meas * dt);
    total_quat = quat_product(integrated_quat(i-1,:), dq);
    integrated_quat(i,:) = total_quat;
    true_quat(i,:) = orientation_data(i,orientation_ids);
    
    % Part 2 Global Coordinate Frames
    % Rotate local angular velocities by inverse orientation to get global
    global_gyro_meas(i,:) = rotate_by(gyro_meas, integrated_quat(i,:));
end

%% Print P1 Stuff
figure(1);
 hold on;
 plot((1:samples)/100, integrated_quat(:,1), 'b')
 plot((1:samples)/100, true_quat(:,1), 'r')
 plot((1:samples)/100, integrated_quat(:,2), 'b')
 plot((1:samples)/100, true_quat(:,2), 'r')
 plot((1:samples)/100, integrated_quat(:,3), 'b')
 plot((1:samples)/100, true_quat(:,3), 'r')
 plot((1:samples)/100, integrated_quat(:,4), 'b')
 plot((1:samples)/100, true_quat(:,4), 'r')
 legend(["Integrated From Gyro", "Given By IMU"])
 title(title_string+" Orientation Quaternions Over Time")
 xlabel("Time (s)")
 ylabel("Quaternion Coefficients")
 hold off;

%% Print P2 Stuff
figure(2);
 hold on;
 plot((1:samples)/100, segment_gyro_data(:,global_gyro_ids(1)), 'b')
 plot((1:samples)/100, global_gyro_meas(:,1), 'r')
 plot((1:samples)/100, segment_gyro_data(:,global_gyro_ids(2)), 'b')
 plot((1:samples)/100, global_gyro_meas(:,2), 'r')
 plot((1:samples)/100, segment_gyro_data(:,global_gyro_ids(3)), 'b')
 plot((1:samples)/100, global_gyro_meas(:,3), 'r')
 legend(["Segment X", "Transformed X", "Segment Y", "Transformed Y", "Segment Z", "Transformed Z"])
 title(title_string+" Angular Velocity")
 xlabel("Time (s)")
 ylabel("Angular Velocities (rad/s)")
 hold off;
 
 %% P3 Stuff
 
 knee_gyro = zeros(samples, 3);
 
for i=1:samples
    % Part 1 Gyro Integration
    if (right_not_left)
        knee_gyro(i,:) = gyro_data(i,gyro_right_shank)-gyro_data(i,gyro_right_thigh);
    else
        knee_gyro(i,:) = gyro_data(i,gyro_left_shank)-gyro_data(i,gyro_left_thigh);
    end
end

figure(3);
 hold on;
 plot((1:samples)/100, knee_gyro(:,1))
 plot((1:samples)/100, knee_gyro(:,2))
 plot((1:samples)/100, knee_gyro(:,3))
 legend(["Knee W_X", "Knee W_Y", "Knee W_Z"])
 if (right_not_left)
     title("Right Knee Joint Angular Velocity")
 else
     title("Left Knee Joint Angular Velocity")
 end
 xlabel("Time (s)")
 ylabel("Angular Velocities (rad/s)")
 hold off;

%% P4 Stuff

right_hip_angle_idx = 4;
left_hip_angle_idx = 16;
left_thigh_marker_idx = 16:17;
right_thigh_marker_idx = 19:20;

if (right_not_left)
    hip_angle_idx = right_hip_angle_idx;
    thigh_marker_idx = right_thigh_marker_idx;
else
    hip_angle_idx = left_hip_angle_idx;
    thigh_marker_idx = left_thigh_marker_idx;
end

thigh_positions = segment_marker_pos(:,thigh_marker_idx);

par = CircleFitByTaubin(thigh_positions);
