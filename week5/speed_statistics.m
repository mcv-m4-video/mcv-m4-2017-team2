%%%%%%%%%%%
% Calcular y mostrar las estadísticas relativas a la secuencia de icaria.

clearvars
close all

set_velocities = csvread('speeds_icaria.csv');

% Discard cases where the speed was not found:
valid_idx = set_velocities > 0;
valid_velocities = set_velocities(valid_idx);

hist(valid_velocities)

fprintf('Mean speed: %f km/h.\n', mean(valid_velocities))
fprintf('Max speed: %f km/h.\n', max(valid_velocities))
fprintf('Min speed: %f km/h.\n', min(valid_velocities))

vehicle_rate = length(set_velocities) / (27/60);
fprintf('Number of vehicles per minute: %f.\n', vehicle_rate)







