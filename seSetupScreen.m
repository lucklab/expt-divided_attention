function [mainWindowPtr, mainWindowRect, centerPt] = seSetupScreen(bgcolor)
% [mainWindowPtr, mainWindowRect, centerPt] = seSetupScreen(bgcolor)
%
% Purpose:  set basic screen vars & open main screen,
% Return:   main Window pointer, main window rect, center point
%
% If this command is executed on Microsoft Windows:
%   Screen 0 is always the full Windows desktop.
%   Screens 1 to n are corresponding to windows display monitors 1 to n.
% If you want to open an onscreen window only on one specific display,
%   or you want to query or set the properties of  display
%   (e.g., framerate, size, colour depth or gamma tables), use the screen numbers 1 to n.

% Screen('Preference', 'SkipSyncTests', 1);

% global expt
expt.screen.mainScreenNum   = max(Screen('Screens'));   % finds display to present
expt.screen.pixelSize       = 32;                       % 32 bits per pixel
expt.screen.numBuffers      = 2;                        % double buffering: use >2 for development/debugging of PTB itself but will mess up any real experiment
expt.screen.screenRect      = [];                       % use default screen rect
expt.screen.defaultBgcolor  = bgcolor;                  % black

% Execute %
% SetResolution(expt.screen.mainScreenNum,800,600,60);
[mainWindowPtr, mainWindowRect]=Screen('OpenWindow', expt.screen.mainScreenNum, ...
    expt.screen.defaultBgcolor, ...
    expt.screen.screenRect,...
    expt.screen.pixelSize,...
    expt.screen.numBuffers);
Screen('BlendFunction', mainWindowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
[center_X_coord, center_Y_coord] = RectCenter(mainWindowRect);
centerPt = [center_X_coord center_Y_coord];

end