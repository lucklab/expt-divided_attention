classdef ExptBlock < handle
    %  obj = visualSearch_statLearning_block(cueColorList, targColorList, target_presence_list)
    %
    % gonna need:
    %     exptVars.cue2targDur;
    %     exptVars.possibleColors
    %     orientationList {'up', 'down'}
    %     exptVars.validPercent
    %     exptVars.num_trial_copies
    
    
    properties
        
        subject_ID;
        run_order_num;
        trials;                     % array for SINGLETRIAL objs
        numTrials;
        
        % INPUT:
        ITI_range                       = [1.000, 1.250];
        num_trial_copies                = 1;
        
        % Factors
        set_size_list                   = { 8 };               % { 2,4,6,8 }
        
        % Non-factors
        target_presence_list            = {'present' };        % { present }
        target_quadrant_list            = {'top_left', 'top_right', 'btm_left', 'btm_right' };
        target_quadrant_distribution    = [1         , 1          ,  1        , 1           ];
        targetOrientation_list          = {'up'      , 'down'     };
        distractor_orientation_list     = {'left'    , 'right'    };
        searchAnnulusRadius             = 200;
        
%         vertJitter  = 5;
%         horizJitter = 5;
         
    end % properties
    
    
    
    
    
    methods
        
        function obj = visualSearch_statLearning_block(varargin)
            % constructor method for TRIALBLOCK obj
            %  obj = visualSearch_statLearning_block(cueColorList, targColorList, target_presence_list)
            
            % INPUT HANDLING:
            switch nargin
                
% FOR DEBUGGING PURPOSES ONLY                
                case 0                                                              % Default settings
%                     obj.subject_ID                  = 'Z99';
%                     obj.run_order_num               = '99';
%                     obj.trials                      = wedgewood_trial.empty;                        %
%                     obj.num_trial_copies            = 1;                                            %
%                     
%                     obj.cue_type_list               = {'positive'};                                 % blocked
%                     obj.SOA_list                    = { 0.400 };                                    % duration between cue display & search display
%                     obj.set_size_list               = { 4, 8, 12 };                                        %
%                     obj.target_presence_list        = { 'present' };                                % Target always present
%                     obj.target_hemifield_list        = {'top'    , 'bottom'  , 'left'    , 'right'}; %
%                     obj.color_list                  = { 'red'   ,'green'    ,'blue'     };          %
%                     obj.targetOrientation_list     = { 'up'    , 'down'    };                      %
%                     obj.distractor_orientation_list = {'left'   ,'right'    };
%                     
%                     obj.ITI_range                    = {1000 1400};                                  %
%                     obj.searchAnnulusRadius           = 200;
%                     
   
                case 11
                    
                    obj.subject_ID                  = varargin{1};
                    obj.run_order_num               = varargin{2};
                    obj.num_trial_copies            = varargin{3};                  % 1
                    obj.set_size_list               = varargin{4};                  % { 4 }
                    
                    obj.target_quadrant_list        = varargin{5};  
                    obj.target_quadrant_distribution= varargin{6};  
                    obj.target_presence_list        = varargin{7};                  % { present }
                    obj.targetOrientation_list     = varargin{8};                  %
                    obj.distractor_orientation_list = varargin{9};                  % { left, right }
                    
                    obj.ITI_range                   = varargin{10};                 % { 1000, 1400 }
                    obj.searchAnnulusRadius           = varargin{11};                 % 200
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            
            
            % --------------------------------------------------------- %
            % NOTE:                                                     %
            %   if trial multiplier is zero (default) then doesn't      %
            %   generate a trial array                                  %
            % --------------------------------------------------------- %
            obj.trials                      = visualSearch_statLearning_trial.empty();          % cell array for SINGLETRIAL objs
            trialNum                        = 1;                    % reset trial count
            for num_trial_copiesIndex = 1:obj.num_trial_copies
                unique_ID                   = 11;                   % reset the unique trial ID number (for ERPSS event codes)
                
                % -------------------- %
                % Generate Base Trials %
                % -------------------- %
                
                for setSize = obj.set_size_list
                    for targetOrientation = obj.targetOrientation_list
                        for target_presence = obj.target_presence_list
                        for target_quadrant_index = 1:length(obj.target_quadrant_list);
                            targetQuadrant              = obj.target_quadrant_list{target_quadrant_index};
                            targetQuadrantProportion    = obj.target_quadrant_distribution{target_quadrant_index};
                            
                            for x=1:targetQuadrantProportion
                                % Counterbalanced variables:
                                %                 setSize
                                %                 target_presence
                                %                 targetOrientation
                                
                                
                                % Select target LOCATION
                                switch(targetQuadrant)
                                    case 'top_left'
                                        targetLocation = RandSample([7 8]);
                                    case 'top_right'
                                        targetLocation = RandSample([1 2]);
                                    case 'btm_left'
                                        targetLocation = RandSample([5 6]);
                                    case 'btm_right'
                                        targetLocation = RandSample([3 4]);
                                end
                                
                                
                                % create new single trial
                                obj.trials(trialNum) = visualSearch_statLearning_trial  ...
                                    ( obj.subject_ID                    ...
                                    , obj.run_order_num                 ...
                                    , unique_ID                         ...
                                    , cell2mat(setSize)                ...
                                    , cell2mat(target_presence)         ...
                                    , targetLocation                    ...
                                    , cell2mat(targetOrientation)                ...
                                    , obj.ITI_range                     ...
                                    , obj.searchAnnulusRadius             ...
                                    );
                                trialNum                 = trialNum+1;                          % increment trial num

                            end
                            
                            unique_ID                = unique_ID+1;                         % increment unique trial ID
                            if(mod(trialNum, 10) == 0); fprintf('%d...', trialNum); end;    % display current status
                            
                        end         % target quadrant loop
                        end  % target presence loop    
                    end     % target orientation loop
                    
                end             % set size loop
            end                 % trial multiplier loop
            
            
            obj.numTrials   = length(obj.trials);
            fprintf('...done.\n')        % end status display
            
        end % function
        
        function value = randomize(obj)
            % returns randomized trials
            %
            % NOTE:
            % Does not mutate obj itself. Need to run command:
            %
            %       exptBlockName.trials = exptBlockName.randomize();
            %
            % to do actual randomization
            
            value = Shuffle(obj.trials);
            
        end % method
        
        function displayTrials(obj, varargin)
            
            switch nargin
                case 1
                    saveFilename_wd = false;
                case 2
                    saveFilename_wd = varargin{1};
                    
                otherwise
                    error('Wrong number of input arguments');
            end
            
            
            for trialIndex = 1:length(obj.trials)
                
                if(saveFilename_wd)
                    obj.trials(trialIndex).displayTrial(saveFilename_wd);
                else
                    obj.trials(trialIndex).displayTrial();
                end
                
            end % trial loop
            
            
            
        end % method
        
        
        
    end % methods
    
    
end % class def
