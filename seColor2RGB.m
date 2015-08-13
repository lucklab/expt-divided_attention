function rgbVal = seColor2RGB(colorName)
%
% Given a string indicating the color (e.g. 'red', 'green', 'magenta', etc)
% return that color's corresponding RGB value in a three element vector.
%
% Color list:
%   - red           - cyan          - orange 
%   - green         - yellow        - purple 
%   - blue          - magenta       - brown   
%             
%   - white
%   - black
%   - gray25
%   - gray50
%   - gray75
%
% For example:
%
%   seColor2RGB('red')
%

% Color-word RGB Values
RED     = [255 000 000];
GREEN   = [000 128 000];
BLUE    = [000 000 255];
CYAN    = [000 255 255];
YELLOW  = [255 255 000];
MAGENTA = [255 000 255];
ORANGE  = [255 165 000];
PURPLE  = [128 000 128];
BROWN   = [165 042 042]; 
GRAY25  = [064 064 064];
GRAY50  = [128 128 128];
GRAY75  = [192 192 192];
WHITE   = [255 255 255];
BLACK   = [000 000 000];

if nargin~=1
    error('ERROR: seColor2RGB(colorName) only takes one input variable')
end

if(iscell(colorName))
    colorName = colorName{1};
end


switch upper(colorName)
    case 'RED'
        rgbVal = RED;
    case 'GREEN'
        rgbVal = GREEN;
    case 'BLUE'
        rgbVal = BLUE;
    case 'CYAN'
        rgbVal = CYAN;        
    case 'YELLOW'
        rgbVal = YELLOW;
    case 'MAGENTA'
        rgbVal = MAGENTA;
    case 'ORANGE'
        rgbVal = ORANGE;
    case 'PURPLE'
        rgbVal = PURPLE;        
    case 'BROWN'
        rgbVal = BROWN;
    case 'WHITE'
        rgbVal = WHITE;
    case 'GRAY25'
        rgbVal = GRAY25;
    case 'GRAY50'
        rgbVal = GRAY50;
    case 'GRAY75'
        rgbVal = GRAY75;
    case 'BLACK'
        rgbVal = BLACK;
    otherwise
        error('ERROR: color word not found in seColor2RGB');
end

end