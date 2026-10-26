function root = setup_glider()
%SETUP_GLIDER Add only the project and its small, licensed Lie library.
root = fileparts(mfilename('fullpath'));
addpath(root,fullfile(root,'third_party','modern_robotics'));
end
