classdef visualSearch_statLearning_trial < handle
    %
    % Experimentor Defined Variables:
    %
    
    properties
        
        % Experimentor Defined Variables
        subject_ID          = 999;
        trial_order_num     = 99;
        run_order_num       = 1;
        setSize             = 8;
        targetPresence      = 'present';
        targetLocation      = 3;
        targetOrientation   = 'down';
        objectColor         = 'magenta';
        ITI;
        
        accuracy            = NaN;            % subject's single trial accuracy {1 == correct || 0 == incorrect}
        resp_keycode        = 'noResponse';   % response gamepad key number
        RT;                                   % subject's single trial response time
        
    end % properties
    
   
    
    properties (Hidden = true)
        event_code;
        searchStimuli;                    % Search stimulus to draw
        
        search_annulus_radius   = 200;
        ITI_range               = [.250 .500];

        responseKeyMap;        
        
    end
    
%     events
%         calculateAccuracy
%     end
    
    methods
        
        function obj   = visualSearch_statLearning_trial(varargin)
            
            switch nargin
                case 0
                    
                    
                case 9
                    
                    obj.subject_ID                  = varargin{1};
                    obj.run_order_num               = varargin{2};
                    obj.event_code                  = varargin{3};
                    obj.setSize                     = varargin{4};
                    obj.targetPresence              = varargin{5};
                    obj.targetLocation              = varargin{6};
                    obj.targetOrientation           = varargin{7};
                    obj.ITI_range                   = varargin{8};
                    obj.search_annulus_radius       = varargin{9};
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            obj.searchStimuli                 = stimLandoltCArray.empty;
            
            
            %% Calculate inter-trial interval
            obj.ITI  = min(obj.ITI_range) + (rand * (max(obj.ITI_range)-min(obj.ITI_range))); % create random ISI based min & max
            
            % Set up stimulus objects
            obj.searchStimuli = stimLandoltCArray(obj.setSize, obj.search_annulus_radius, obj.targetLocation, obj.targetOrientation, obj.objectColor); % , -7*pi/obj.setSize);
          
            % Set up response key mapping
            obj.responseKeyMap      = cell(10,1);
            obj.responseKeyMap{6}   = 'up';
            obj.responseKeyMap{8}   = 'down';
            
            obj.responseKeyMap = containers.Map(    ...
                { 5     , 6    , 7     , 8      } , ...  %% Keys - for both left and right handed responses
                { 'up'  , 'up' , 'down', 'down' } );     %% Values
            

            
            
        end % constructor method
        
        function trialObj = saveResponse(trialObj, subjectResponse)
            
            % Save response info into trial object
            trialObj.resp_keycode    = subjectResponse.keycode;               % response gamepad key number
            trialObj.RT              = subjectResponse.responseTime;                  % subject's single trial response time
            
            % Calculate accuracy
            if( ~isnan(trialObj.resp_keycode) && ...
                strcmpi(trialObj.responseKeyMap(trialObj.resp_keycode), trialObj.targetOrientation))
                trialObj.accuracy = true;
            else
                trialObj.accuracy = false;
            end
                        
        end       % method
    
        
    end % methods
    
end % classdef
