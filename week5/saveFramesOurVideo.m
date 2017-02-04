%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Guardar cada frame del video de Parc Nova Icaria.

clearvars
close all

addpath('../utils')

dirOut = './sequence_parc_nova_icaria/';
videoname = 'parc_nova_icaria.mp4';

if(exist(dirOut, 'dir') ~=7)
    mkdir(dirOut)
end

video2frames(videoname, dirOut)