clearvars
Screen('Preference', 'SkipSyncTests', 1);
AssertOpenGL;

% PARTICIPANT DATA
name1='Participant Data';
prompt1={'Subject Number', ...
    'Subject ID', ...
    'Sex (f/m)', ...
    'Age', ...
    'Task order'};
numlines1=1;
defaultanswer1={ '0', 'p', 'M', '0', '1'};
answer1=inputdlg(prompt1,name1,numlines1,defaultanswer1);
DEMO.num = str2double(answer1{1});
DEMO.ID  = answer1{2};
DEMO.sex = answer1{3};
DEMO.age = str2double(answer1{4});
DEMO.order = str2double(answer1{5});
DEMO.date = datetime;

% Keyboard setup
responseKeys = {'2', '3', 'y', 'n'};
KbName('UnifyKeyNames');
KbCheckList = [KbName('space'),KbName('ESCAPE'), KbName('leftarrow'), KbName('rightarrow')];
for i = 1:length(responseKeys)
    KbCheckList = [KbName(responseKeys{i}),KbCheckList];
end
RestrictKeysForKbCheck(KbCheckList);
ListenChar(-1)
HideCursor()
try 
    % Screen setup
    s = max(Screen('Screens'));
    [w, rect] = Screen('Openwindow',s,[0 0 0]) %,[200 200 1000 1000]);
    Priority(MaxPriority(w));
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);    
    pixelSizes=Screen('PixelSizes', s);
    fps=Screen('FrameRate',w); % frames per second
    ifi=Screen('GetFlipInterval', w);
    [wx, wy] = RectCenter(rect);
    Screen('Flip', w)
    
    % STIMULUS SETUP
    fixRadius = 3;
    fixRect = CenterRectOnPoint([0, 0, fixRadius*2, fixRadius*2], wx, wy);
    fixColor = [0 0 0];
    
    SR_table;
    
    % EXPERIMENT
    Screen('DrawText', w, 'PRESS SPACE TO START',  wx-150, wy, [255, 255, 255]);
    Screen('Flip', w);
    KbWait([],2)
    Screen('Flip', w);
    
    for i_trial = 1:size(expTable,1)
        % make stim 
        x = 0:1/1000:.1;  
        f = 100;
        c_gaus = 0.07;
        contrast_width = 10;
        
        [mx,my,buttons] = GetMouse(w);
        SetMouse(wx, wy/2, w);
        Screen('Flip', w);
        stimOnset = GetSecs();
        while ~(sum(buttons)>0 && my < wy+640/2 && my > wy-640/2)
            stim = [];
            
            % generate stimulus
            for i_contrast = 1:64
                sine_wave = i_contrast * sin(2*pi*f*x);
                let_wave = sine_wave+128;
                let_wave = repmat(fliplr(let_wave), contrast_width, 1);

                noise_thres = 250;
                y_noise = let_wave + normrnd(zeros(size(let_wave)), expTable.sigma(i_trial));
                stim = [stim; (y_noise > noise_thres) * 255];     
            end
            
            % stimulus direction
            if expTable.dir(i_trial) > 0
                stim_tex =Screen('MakeTexture', w, stim);
            else
                stim_tex =Screen('MakeTexture', w, flipud(stim));
            end
              
            % plot stimulus
            for i_frame = 1:expTable.dur(i_trial)
                Screen('DrawTexture', w, stim_tex); 
                
                [mx,my,buttons] = GetMouse(w);
                if my < wy+size(stim,1)/2 && my > wy-size(stim,1)/2 && (GetSecs()-stimOnset) > expTable.wait(i_trial)
                    Screen('DrawLine', w, [255 0 0], wx-150, my, wx+150, my, 6);
                    if sum(buttons)>0
                        break;
                    end
                end
                Screen('Flip', w);

                % ESCAPE
                [keyIsDown, secs, keyCode, deltaSecs]  = KbCheck();
                if find(keyCode) == KbName('escape')
                    % finish the experiment
                    ShowCursor()
                    RestrictKeysForKbCheck([]);
                    Screen(w,'Close');
                    close all
                    sca;
                    ListenChar(0)
                end
            end
        end
        
        expTable.resp(i_trial) = ceil((expTable.dir(i_trial) * (my-wy) + size(stim,1)/2) / contrast_width);
        expTable.resp2(i_trial) = find(buttons);
        expTable.rt(i_trial) = GetSecs()-stimOnset;

        Screen('Flip', w);
        Screen('Flip', w);
        WaitSecs(1);
    end
    
    
    % SAVE DATA
    EXP.DEMO = DEMO;
    EXP.data = expTable;
    save([answer1{1} '_SR_' answer1{2} '.mat'], 'EXP') 
    
    % finish the experiment
    ShowCursor()
    RestrictKeysForKbCheck([]);
    Screen(w,'Close');
    close all
    sca;
    ListenChar(0)

catch
    % finish the experiment  
    rethrow(lasterror)
    ShowCursor()
    RestrictKeysForKbCheck([]);
    Screen(w,'Close');
    close all
    sca;
    ListenChar(0)
    
end