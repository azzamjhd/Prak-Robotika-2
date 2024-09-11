% Data input
Data_input = [[1, 1]; [2,1.5]; [3,2.5]; [1,2]; [1.5,3]; [2.5, 2.5]];

model_path = 'P2.slx';
save_folder_path = "output-P2\img\";
save_folder_path_final = "output-P2\";

fig = figure('Position', [0,0,600,600]);
fig2 = figure('Position', [0 0 640 155]);

% Initialize data arrays of size of Data input 1st dimension
time_all = cell(1, size(Data_input, 1));
velR_all = cell(1, size(Data_input, 1));
velL_all = cell(1, size(Data_input, 1));
vel_all = cell(1, size(Data_input, 1));
sR_all = cell(1, size(Data_input, 1));
sL_all = cell(1, size(Data_input, 1));
s_all = cell(1, size(Data_input, 1));

% Initialize for last points data
last_data = struct('velocity', [], 'angular_speed', [], 'wheel_distance_left', [], 'wheel_distance_right', [], 'distance', [], 'angular_position', [], 'wheel_velocity_right', [], 'wheel_velocity_left', []);

for i = 1:size(Data_input, 1)
    % Set velocity reference wheel left and right to the current data input
    Sl = Data_input(i, 1);
    Sr = Data_input(i, 2);
    
    simRes = sim(model_path);
    % get data output
    [wheel_velocity_left, wheel_velocity_right, velocity, wheel_distance_left, wheel_distance_right, distance, angular_position, angular_speed, x_position, y_position] = get_data(simRes);
    
    % accumulate data
    time_all{i} = velocity.Time;
    velR_all{i} = wheel_velocity_right.Data;
    velL_all{i} = wheel_velocity_left.Data;
    sR_all{i} = wheel_distance_right.Data;
    sL_all{i} = wheel_distance_left.Data;
    vel_all{i} = velocity.Data;
    s_all{i} = distance.Data;
    
    last_data.wheel_distance_right(i) = Sr;
    last_data.wheel_distance_left(i) = Sl;
    last_data.wheel_velocity_right(i) = wheel_velocity_right.Data(end);
    last_data.wheel_velocity_left(i) = wheel_velocity_left.Data(end);
    last_data.angular_position(i) = angular_position.Data(end);
    last_data.angular_speed(i) = angular_speed.Data(end);
    last_data.velocity(i) = velocity.Data(end);
    last_data.distance(i) = distance.Data(end);

    plot_cartesian(fig, "Range", x_position, y_position, save_folder_path_final, append(num2str(i),". range"));

end

% PLot table for last data points
plot_table(fig2, last_data, save_folder_path_final, "table");

% Plot all data
velR_legend_str = [string(1:size(Data_input, 1))];

plot_all_data(fig, "Right Wheel Velocity", "Time (s)", "Velocity (m/s)", time_all, velR_all, velR_legend_str, save_folder_path_final, "right_wheel_velocity");
plot_all_data(fig, "Left Wheel Velocity", "Time (s)", "Velocity (m/s)", time_all, velL_all, velR_legend_str, save_folder_path_final, "left_wheel_velocity");
plot_all_data(fig, "Velocity", "Time (s)", "Velocity (m/s)", time_all, vel_all, velR_legend_str, save_folder_path_final, "velocity");
plot_all_data(fig, "Right Wheel Distance", "Time (s)", "Distance (m)", time_all, sR_all, velR_legend_str, save_folder_path_final, "right_wheel_distance");
plot_all_data(fig, "Left Wheel Distance", "Time (s)", "Distance (m)", time_all, sL_all, velR_legend_str, save_folder_path_final, "left_wheel_distance");
plot_all_data(fig, "Distance", "Time (s)", "Distance (m)", time_all, s_all, velR_legend_str, save_folder_path_final, "distance");

% Get image location
right_wheel_velocity_image = append(save_folder_path_final, "right_wheel_velocity.png");
right_wheel_distance_image = append(save_folder_path_final, "right_wheel_distance.png");
left_wheel_velocity_image = append(save_folder_path_final, "left_wheel_velocity.png");
left_wheel_distance_image = append(save_folder_path_final, "left_wheel_distance.png");
velocity_image = append(save_folder_path_final, "velocity.png");
distance_image = append(save_folder_path_final, "distance.png");

velocity_images = [right_wheel_velocity_image, left_wheel_velocity_image, velocity_image];
distance_images = [right_wheel_distance_image, left_wheel_distance_image, distance_image];

combine_images_all(velocity_images, distance_images, append(save_folder_path_final, "All"));

close(fig);
close(fig2);
disp("Done!");

function plot_table(fig, data, save_folder_path, filename)
    figure(fig);

    data = [
        data.wheel_distance_left; data.wheel_distance_right; data.velocity; data.angular_speed; data.wheel_velocity_left; data.wheel_velocity_right; data.distance; data.angular_position
    ];
    data = transpose(data);

    uitable('Data', data, 'ColumnName', {'SL (m)', 'SR (m)', 'V (m/s)', 'ω (deg/s)', 'Vl (m/s)', 'Vr (m/s)', 'S (m)', 'θ (deg)'}, 'Position', [0 0 fig.Position(3:4)]);
    file = append(save_folder_path, filename, ".png");
    print(fig, file, '-dpng');
end

function plot_all_data(fig, title_str, x_label, y_label, time_data, data, legend_str, save_folder_path, filename)
    figure(fig);
    clf;
    hold on;
    for i = 1:size(data, 2)
        plot(time_data{i}, data{i});
    end
    title(title_str);
    xlabel(x_label);
    ylabel(y_label);
    legend(legend_str, 'Location', 'northeast');
    hold off;
    
    if ~exist(save_folder_path, 'dir')
        mkdir(save_folder_path);
    end

    file = append(save_folder_path, filename, ".png");
    print(fig, file, '-dpng');
end

function combine_images_all(vel_img_path, dis_img_path, filename)
    % 2 x 4 grid image
    img1 = imread(vel_img_path(1));
    img2 = imread(vel_img_path(2));
    img3 = imread(vel_img_path(3));
    img4 = imread(dis_img_path(1));
    img5 = imread(dis_img_path(2));
    img6 = imread(dis_img_path(3));
    
    combinedImage = [img1 img4; img2 img5; img3 img6];
    imwrite(combinedImage, append(filename,".png"));
end

function plot_data(fig, title_str, y_label, data, save_folder_path, filename)
    figure(fig);
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
    figure(fig);
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