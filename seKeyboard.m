classdef seKeyboard < handle
    %seKeyboard Class definition for seKeyboard
    %   Creates a "gamepad" programming object in order to receive and
    %   record subject's responses.
    
    properties
        isPresent = true;                          % Flag specifying if a gamepad device is connected or disconnected
        
        acceptedResponses = { 'a','b','c'} ;                  % (num) accepted gamepad-button numbers
    end
    
    properties(Hidden = true)
        escape_keys     = zeros(1,256);     % Keyboard key combination to quit experiment
        pause_keys      = zeros(1,256);     % Keyboard key combination to pause experiment
%         gamepadIndex;                     % Psychtoolbox index for gamepad devices (need for KbCheck)
        
    end
    
    properties(Constant = true, Hidden = true)
        DEFAULT_WAIT_DURATION   = 5.000;      % (secs) Default duration to wait for a subject response
        EVENT_CODE_PAUSE        = 255;
        EVENT_CODE_END          = 255;
        
    end
    
    
    methods
        
        function obj = seKeyboard(varargin)
            % Creates an seKeyboard object to collect subject responses via
            % an external USB Gamepad.
            %
            % Example:
            %   responseDuration  = 5.000       % wait for 5.000 seconds
            %   acceptedResponses = [1 2 3 4]   % accepted only buttons 1-4
            %   objGamepad        = seKeyboard(responseDuration, acceptedResponses)
            %
            
            switch nargin
                case 0                                      % No inputs -- use default values
                    %                     if ismac
                    %                         obj.acceptedResponses   = 01:10;        % (num) Default accepted gamepad-button numbers
                    %                     elseif ispc
                    %                         obj.acceptedResponses   = 01:04;
                    %                     end
                case 1
                    obj.acceptedResponses   = varargin{1};
                    
            end
            
            % Setup escape/pause keys
            KbName('UnifyKeyNames');                            % Ensure keynames work on Mac & PC
            obj.escape_keys(KbName('LeftControl'))  = 1;        % Escape keys: Left-command + Left-alt/option + Left-control
            obj.escape_keys(KbName('LeftAlt'))      = 1;        %
            obj.escape_keys(KbName('LeftGUI'))      = 1;        %
            obj.escape_keys(KbName('RightGUI'))     = 1;        %
            obj.escape_keys(KbName('RightAlt'))     = 1;        %
            
            obj.pause_keys(KbName('LeftControl'))   = 1;        % Pause keys: Left-Command + p
            obj.pause_keys(KbName('LeftAlt'))       = 1;        %
            obj.pause_keys(KbName('LeftGUI'))       = 1;        %
            obj.pause_keys(KbName('space'))         = 1;        %
            
            
            
            % Check computer for gamepad
            %             if ismac
            %                 obj.gamepadIndex = GetGamepadIndices;
            %             elseif ispc
            %                 obj.gamepadIndex = 0;
            %             end
            
            
            %             if(~isempty(obj.gamepadIndex))
            %                 obj.isPresent = true;
            %             else
            %                 obj.isPresent = false;
            %             end
            
        end
        
        function resp = waitForResponse(obj, varargin)
            % Waits for an acceptable response from the gamepad object
            %
            % Example:
            %   objGamepad = seKeyboard();
            %   objGamepad.waitForResponse();               % wait 3.000 seconds for a acceptable response
            %
            %   objGamepad.waitForResponse(3.000, objDAQ);  % sends out an event code after waiting 3.000 seconds for a response
            %
            startTime           = GetSecs();

            switch nargin
                case 0
                case 1
                    waitDuration        = obj.DEFAULT_WAIT_DURATION;
                    opt_daq.isPresent   = false;
                case 2
                    waitDuration        = varargin{1};
                    opt_daq.isPresent   = false;
                case 3
                    waitDuration        = varargin{1};
                    opt_daq             = varargin{2};
            end
            
            FlushEvents('keyDown');
            resp.responseTime   = NaN;
            resp.keycode        = NaN;
            
            if(obj.isPresent)
                
                exitLoop = false;
                while not(exitLoop);   % keep polling gamepad & keyboard for user response or experimentor pause/end key combination
                    
                    % ------------------------------------ %
                    % First, check if time limit  exceeded %
                    % ------------------------------------ %                    
                    if (GetSecs - startTime) > waitDuration
                        exitLoop      = true;     % end waiting for response
                    else
                        
                        
                        % ------------------------------- %
                        % Poll gamepad for button presses %
                        % ------------------------------- %
                        
                        if ismac
                            [keyIsDown, keyIsDownTimeStamp, keyCode]    = KbCheck();
                        elseif ispc
                            %                             [~,~,~,btn] = WinJoystickMex(obj.gamepadIndex);
                            %                             keyIsDownTimeStamp  = GetSecs();
                            %                             keyCode             = find(btn, 1);
                            %                             keyIsDown           = ~isempty(keyCode);
                        end
                        %                         [KEYBOARD_keyIsDown, ~,KEYBOARD_keyCode]         = KbCheck();
                        
                        
                        % ---------------------------- %
                        % check for quit or pause keys %
                        % ---------------------------- %
                        %                         if (KEYBOARD_keyIsDown && isequal(KEYBOARD_keyCode, obj.escape_keys))
                        %                             fprintf('Escape key-combination activated.\nProgram stopped.\n');
                        %
                        %                             opt_daq.sendEventCode(obj.EVENT_CODE_END);   % send out event codes if we have a daq var is inputted
                        %                             ShowCursor;
                        %                             Screen('CloseAll');         % close psychtoolbox
                        %                             return;                     % quit experiment
                        %                         elseif (KEYBOARD_keyIsDown && isequal(KEYBOARD_keyCode, obj.pause_keys))                  % pause experiment
                        %                             fprintf('Experiment paused.\nHit any key to continue...\n');
                        %
                        %                             opt_daq.sendEventCode(obj.EVENT_CODE_PAUSE);   % send out event codes if we have a daq var is inputted
                        %                             WaitSecs(1);
                        %                             KbWait;
                        %                             fprintf('Experiment Unpaused\n');
                        %                         end
                        
                        
                        if(keyIsDown)
                            
                            % ---------------------------- %
                            % Check for Accepted Responses %
                            % ---------------------------- %
                            foundResponses = intersect(KbName(keyCode), obj.acceptedResponses);
                            
                            if(~isempty(foundResponses))
                                                                
                                for singleFoundResponse = foundResponses                                    
                                    if(opt_daq.isPresent)
                                        opt_daq.sendEventCode(singleFoundResponse);   % send out event codes if we have a daq var is inputted
                                    end
                                    %                                     fprintf('Button pressed = %d\n', singleFoundResponse);
                                end
   
                                    resp.responseTime = keyIsDownTimeStamp - startTime;     % save response time
                                    resp.keycode      = foundResponses;                     % save found responses
                                    exitLoop          = true;                               % exit keyboard polling loop
                            end
                            
                        end % check if gamepad key is pressed
                    end % check response time duration not exceeded
                end % loop for gamepad key press
                
            else
                error('USB Gamepad is not connected'); % Throw an error if gamepad IS NOT present
            end % gamepad present check
            
        end % waitForResponse() method
        
        
        
    end
end



