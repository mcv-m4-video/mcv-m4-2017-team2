% Block-Based Parametric Motion Model
% source: http://twiki.cis.rit.edu/twiki/pub/Main/HongqinZhang/chen_report.pdf

%% Main file for :
%% Video Stabilization Algorithm Using a Block-Based Parametric
%% Motion Model
%%
%% Class Project, EE392J Winter 2000
%% Author : Ting Chen
%% Date : 02/24/2000
%%
% clear all;
% close all;

load_step_3 = true;
sequence.name = 'traffic'; % 'kids','car','lamp','flower'
filename = strcat(sequence.name,'File_step3');

if ~load_step_3
    %% Step I : load original video sequences
    %% sequence : structure
    %% fields : name -- string
    %% originalFrames -- [nRows x nCols x nFrames]
    %%
    sequence = loadSequence2(sequence);
    %filename = strcat(sequence.name,'File_step1');
    %save(filename,'sequence')
    %load(filename)


    %% Step II : Perform motion estimation; and save all the relevant
    %% motion vector into structure sequence.estimatedMotion
    %%
    sequence.estimatedMotion = sequenceME(sequence);
    %filename = strcat(sequence.name,'File_step2');
    %save(filename,'sequence')
    %load(filename)


    %% Step III: Determine whether the motion is intentional or unwanted
    %% and smooth out/remove the unwanted motion
    %%
    sequence = motionClassification(sequence);
    
    save(filename,'sequence')
else
    load(filename)
end


%% Step IV : Correct the unwanted motion and generate stabilized
%% video sequence store the motion stabilized frame
%% into structure sequence
%%
sequence.MCpara.dThreshold = 1; % 4 for 'car', 1 for 'lamp' and 'kids', 8 for 'flower'
sequence.MCpara.aThreshold = 4; % 3 for 'flower'
sequence.MCpara.resetLength = 0;  % 12
sequence = motionCorrection(sequence);
%filename = strcat(sequence.name,'File_step4');
%save(filename,'sequence')
%load(filename)


%% Step V : Display original/stabilized video sequence
%%
% sequence.displayOption = 'color'; % by default it's b&w, i.e., the Y plane
M = sequenceDisplay2(sequence);
% movie(M,-1,12);  % forward and backward, 12 frames per second
movie(M);

