classdef stimFixationPt
%STIMFIXATIONPT Summary of this function goes here
%
%   obj    = stimFixationPt(size_px, penWidth_px, location_pt, color_wd)
%

properties

    size_px;
    penWidth_px;
    location_pt;
    color_wd;

end % properties

methods

    function obj    = stimFixationPt(varargin)
        
        switch(nargin)
            
            case 0
                
                obj.size_px     = 10;
                obj.penWidth_px = 5;
                obj.location_pt = [400, 300];
                obj.color_wd    = 'black';
            case 1
                
                obj = stimFixationPt();
                obj.location_pt = varargin{1};
                
            case 4
                obj.size_px     = varargin{1};
                obj.penWidth_px = varargin{2};
                obj.location_pt = varargin{3};
                obj.color_wd    = varargin{4};
            otherwise
                error('Wrong number of input arguments');
                               
        end % switch
        
    end % constructor method
                

    function draw(obj, winPtr)

        X=1;    % array index for x-coordinate
        Y=2;    % array index for y-coordinate
        
        top         = obj.location_pt(Y) - obj.size_px;
        btm         = obj.location_pt(Y) + obj.size_px;
        left        = obj.location_pt(X) - obj.size_px;
        right       = obj.location_pt(X) + obj.size_px;

        color_rgb   = seColor2RGB(obj.color_wd);
        
        Screen('DrawLine', winPtr, color_rgb, left,                obj.location_pt(Y),  right,              obj.location_pt(Y),  obj.penWidth_px);
        Screen('DrawLine', winPtr, color_rgb, obj.location_pt(X),   top,                obj.location_pt(X),  btm,                obj.penWidth_px);

    end
   
            function show(obj)
            
            try

                [winPtr, winRect, centerPt] = setupScreen(color2RGB('white')); %#ok<ASGLU>
                Priority(MaxPriority(winPtr));
              
                obj.location_pt = centerPt;    % set location to be center of screen
                                
                obj.draw(winPtr);

                Screen('Flip', winPtr);     % flip/draw buffer to display monitor


                KbWait;
                Screen('CloseAll');         % close psychtoolbox screen
                Priority(0);
                
            catch matlab_err
                
                ShowCursor;
                Screen('CloseAll');                             % close psychtoolbox screen
                display(getReport(matlab_err));
                

            end % try-catch
            
        end % method
    
        
end % methods


end % classdef