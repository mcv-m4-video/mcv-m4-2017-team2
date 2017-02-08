function show_particles(X, Y_k)

f=figure(1);
image(Y_k)
title('+++ Showing Particles +++')

hold on
plot(X(2,:), X(1,:), '.')
hold off

drawnow

%frame =getframe(f);