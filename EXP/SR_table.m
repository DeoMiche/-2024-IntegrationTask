
noise_sigma =100;
noise_dur = [1,3,5,7,9,11,13,15,20]; % in frames
stim_dir = [-1 1]; % upward or downward
stim_dur = [0]; % minimum stimulus duration
nRep = 10;

expTable = [];
i_trial = 1;
for i_rep = 1:nRep
    for i_sigma = 1:length(noise_sigma)
        for i_dur = 1:length(noise_dur)
            for i_wait = 1:length(stim_dur)
                for i_dir = 1:length(stim_dir)
                    expTable(i_trial,:) = [noise_sigma(i_sigma), noise_dur(i_dur), stim_dir(i_dir), stim_dur(i_wait)];
                    i_trial = i_trial+1;
                end
            end
        end
    end
end

expTable = expTable(randperm(size(expTable,1)), :);
expLabels = {'sigma', 'dur', 'dir', 'wait'};

expTable = array2table(expTable, 'VariableNames', expLabels);