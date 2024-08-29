% Data input
Data_input = [[0.1, 0.1]; [0.1,0.2]; [0.1,0.3]; [0.1,0.4]; [0.1,0.5]; [0.2, 0.1]; [0.3,0.1]];

model_path = 'P1.slx';
save_folder_path = "output\img\";
save_folder_path_final = "output\";

fig = figure('Position', [0,0,600,600]);
fig2 = figure('Position', [0 0 190 150]);

for i = 1:size(Data_input, 1)
    % Set velocity reference wheel left and right to the current data input
    Vl = Data_input(i, 1);
    Vr = Data_input(i, 2);
    
    simRes = sim(model_path);
    % get data output
    [wheel_velocity_left, wheel_velocity_right, velocity, wheel_distance_left, wheel_distance_right, distance, angular_position, angular_speed, x_position, y_position] = get_data(simRes);
    
    plot_cartesian(fig, "Range", x_position, y_position, save_folder_path_final, append(num2str(i),". range"));
    plot_data(fig, "Right Wheel Velocity", "Velocity (m/s)", wheel_velocity_right, save_folder_path, append(num2str(i), ". right_wheel_velocity"));
    plot_data(fig, "Right Wheel Distance", "Distance (m)", wheel_distance_right, save_folder_path, append(num2str(i), ". right_wheel_distance"));
    plot_data(fig, "Left Wheel Velocity", "Velocity (m/s)", wheel_velocity_left, save_folder_path, append(num2str(i), ". left_wheel_velocity"));
    plot_data(fig, "Left Wheel Distance", "Distance (m)", wheel_distance_left, save_folder_path, append(num2str(i), ". left_wheel_distance"));
    plot_data(fig, "Angular Position", "θ (deg)", angular_position, save_folder_path, append(num2str(i), ". angular_position"));
    plot_data(fig, "Angular Speed", "ω (deg/s)", angular_speed, save_folder_path, append(num2str(i), ". angular_speed"));
    plot_data(fig, "Velocity", "Velocity (m/s)", velocity, save_folder_path, append(num2str(i), ". velocity"));
    plot_data(fig, "Distance", "Distance (m)", distance, save_folder_path, append(num2str(i), ". distance"));

    % Extract last data points
    last_velocity = velocity.Data(end);
    last_angular_speed = angular_speed.Data(end);
    last_wheel_distance_left = wheel_distance_left.Data(end);
    last_wheel_distance_right = wheel_distance_right.Data(end);
    last_distance = distance.Data(end);
    last_angular_position = angular_position.Data(end);

    % Convert numeric values to strings
    data = {
        'V (m/s)', num2str(last_velocity);
        'ω (deg/s)', num2str(last_angular_speed);
        'Sl (m)', num2str(last_wheel_distance_left);
        'Sr (m)', num2str(last_wheel_distance_right);
        'S (m)', num2str(last_distance);
        'θ (deg)', num2str(last_angular_position);
    };
    uitable('Data', data, 'ColumnName', {'Name', 'Value'}, 'Position', [0 0 fig2.Position(3:4)]);
    file = append(save_folder_path_final, num2str(i), ". data.png");
    print(fig2, file, '-dpng');
    
    velocity_images = [append(save_folder_path, num2str(i), ". right_wheel_velocity.png"), append(save_folder_path, num2str(i), ". left_wheel_velocity.png"), append(save_folder_path, num2str(i), ". velocity.png")];
    distance_images = [append(save_folder_path, num2str(i), ". right_wheel_distance.png"), append(save_folder_path, num2str(i), ". left_wheel_distance.png"), append(save_folder_path, num2str(i), ". distance.png")];
    angular_images = [append(save_folder_path, num2str(i), ". angular_position.png"), append(save_folder_path, num2str(i), ". angular_speed.png")];
    
    % combine_images(velocity_images, append(save_folder_path_final, num2str(i), ". Velocities"));
    % combine_images(distance_images, append(save_folder_path_final, num2str(i), ". Distances"));
    % combine_images(angular_images, append(save_folder_path_final, num2str(i), ". Angular"));
    combine_images_all(velocity_images, distance_images, angular_images, append(save_folder_path_final, num2str(i), ". All"));

end
disp("Done!");
close(fig);
close(fig2);


function combine_images_all(vel_img_path, dis_img_path, ang_img_path, filename)
    % 2 x 4 grid image
    img_vel1 = imread(vel_img_path(1));
    img_vel2 = imread(vel_img_path(2));
    img_vel3 = imread(vel_img_path(3));
    img_dis1 = imread(dis_img_path(1));
    img_dis2 = imread(dis_img_path(2));
    img_dis3 = imread(dis_img_path(3));
    img_ang1 = imread(ang_img_path(1));
    img_ang2 = imread(ang_img_path(2));
    
    combinedImage = [img_vel1 img_dis1; img_vel2 img_dis2; img_vel3 img_dis3; img_ang1 img_ang2];
    imwrite(combinedImage, append(filename,".png"));
end

function combine_images(img_path, filename)
    combinedImage = [];
    for i = 1:length(img_path)
        img = imread(img_path(i));
        combinedImage = [combinedImage img];
    end
    imwrite(combinedImage, append(filename,".png"));
end

function plot_data(fig, title_str, y_label, data, save_folder_path, filename)
    plot(data);
    title(title_str);
    ylabel(y_label);

    if ~exist(save_folder_path, 'dir')
        mkdir(save_folder_path);
    end

    file = append(save_folder_path, filename, ".png");
    print(fig, file, '-dpng');
end

function plot_cartesian(fig, title_str, data_X, data_Y, save_folder_path, filename)
    num_points = length(data_X);
    colormap(flipud(jet(num_points)));
    scatter(data_X, data_Y, [], 1:num_points, 'filled');
    title(title_str);
    xlabel("X");
    ylabel("Y");

    if ~exist(save_folder_path, 'dir')
        mkdir(save_folder_path);
    end

    file = append(save_folder_path, filename, ".png");
    print(fig, file, '-dpng')
end

function [wheel_velocity_left, wheel_velocity_right, velocity, wheel_distance_left, wheel_distance_right, distance, angular_position, angular_speed, x_position, y_position] = get_data(simRes)
    wheel_velocity_left     = simRes.wheel_velL;
    wheel_velocity_right    = simRes.wheel_velR;
    velocity                = simRes.vel;
    wheel_distance_left     = simRes.wheel_sL;
    wheel_distance_right    = simRes.wheel_sR;
    distance                = simRes.s;
    angular_position        = simRes.theta;
    angular_speed           = simRes.omega;
    x_position              = simRes.X;
    y_position              = simRes.Y;
end