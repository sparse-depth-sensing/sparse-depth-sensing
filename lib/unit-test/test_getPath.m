close all; clear; clc;

disp(sprintf('root: %s', getPath( 'root' )))
disp(sprintf('lib: %s', getPath( 'lib' )))
disp(sprintf('data: %s', getPath( 'data' )))
disp(sprintf('results: %s', getPath( 'results' )))
disp(sprintf('figures: %s', getPath( 'figures' )))

disp('')
createSettings
settings.solver = 'nesta';
disp(sprintf('results-nesta: %s', getPath( 'results', settings )))
disp(sprintf('figures: %s', getPath( 'figures', settings )))
disp(sprintf('data: %s', getPath( 'data', settings )))

settings.solver = 'cvx';
disp(sprintf('results-cvx: %s', getPath( 'results', settings )))

settings.windowSize = 5;
disp(sprintf('results-cvx: %s', getPath( 'results', settings )))