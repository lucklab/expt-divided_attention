classdef stimBackground
%STIMBACKGROUND Summary of this function goes here
%   Detailed explanation goes here

properties
    
    winPtr;         % from Psychtoolbox('OpenScreen')
    color_wd;       % color to paint background (word)
    
end % properties

properties (Dependent = true)
    
    color_rgb;
    
end % dependent properties

methods
    
    function obj    = stimBackground(varargin)
        
        switch(nargin)
            case 0 
                obj.winPtr   = NaN;
                obj.color_wd = 'gray';
            case 1
                
                obj          = stimBackground();
                obj.color_wd = varargin{1};
                
            case 2
                obj          = stimBackground();
                obj.winPtr   = varargin{1};
                obj.color_wd = varargin{2};
        end
        
    end % constructor method
    
    function draw(obj, varargin)
        % drawBackground(bgColor, winRect, winPtr)
        %
        % Paints entire screen defined by WINRECT the color BGCOLOR
        %
        
        switch(nargin)
            case 1
                winPtr    = obj.winPtr;
                color     = obj.color_rgb;
            case 2 
                winPtr    = varargin{1};
                color     = obj.color_rgb;
            case 3
                winPtr    = varargin{1};
                color     = varargin{2};
        end % input switch
                
        Screen('FillRect', winPtr, color);

    end
    
    function value = get.color_rgb(obj)
        
        value = seColor2RGB(obj.color_wd);
        
    end
    
    function display(obj)
        % DISPLAY displays info for STIMBACKGROUND obj

        disp(' ');
        disp(struct(obj))
        disp(sprintf('%s is a %s object', inputname(1), class(obj)))
        disp(' ');

    end % function

end % methods

end % classdef