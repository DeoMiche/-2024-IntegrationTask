
data_dir_fn = '../DATA';
data_dir = dir(data_dir_fn);
subj_dir_fn = {data_dir.name}';
subj_dir_fn = subj_dir_fn(4:end);

for i_subj = 1:length(subj_dir_fn)
    % LOAD DATA
    data_fn = [subj_dir_fn{i_subj} '_SR*'];
    data_fn = dir(fullfile(data_dir_fn, subj_dir_fn{i_subj}, data_fn));
    data_fn = data_fn.name;
    
    load(fullfile(data_dir_fn, subj_dir_fn{i_subj}, data_fn))
    
    age(i_subj) = EXP.DEMO.age;
    % FIT DATA

    expT = EXP.data;
    noise_dur = unique(expT.dur);

    for i_dur = 1:length(noise_dur)
        p_thresh(i_dur) = mean(expT.resp(expT.dur == noise_dur(i_dur)));
    end

    fo = fitoptions('Method','NonlinearLeastSquares',...
                   'Lower',[-Inf, -1, 0],...
                   'Upper',[0,0, 50]); %,...
    %                'StartPoint',[50, .05, max(p_thresh), min(p_thresh)]);

    myfit = fittype('a*exp(b*x)+c',...
                    'dependent',{'y'},...
                    'independent',{'x'},...
                    'coefficients',{'a','b','c'},...
                    'options', fo);

    fun_PMF = @(beta,x) beta(1)*exp(beta(2)*x)+beta(3);

    [expmdl, GoFtmp] = fit(noise_dur*10, p_thresh',myfit);
    GoF = GoFtmp.adjrsquare;

    x2plot=0:0.01:160;
    
    % PLOT
    figure(1)
    subplot(7,7,i_subj); hold on
    plot(noise_dur*10, p_thresh,'k.', 'MarkerSize', 20)
    plot(x2plot,fun_PMF(coeffvalues(expmdl), x2plot), 'r-', 'LineWidth', 2)
    xlabel('noise duration (ms)')
    ylabel('contrast threshold (power)')
    title(['GoF : ' num2str(GoF)])

    % THRESHOLD
    x2plot = 1:0.01:200;
    y = fun_PMF(coeffvalues(expmdl), x2plot);
    y = (y-min(y)) / (max(y)-min(y));
    diffY = diff(y);
    th = .00005;
    I = find(diffY<th,1);
    if isempty(I); I=1; end
    [~, Imin] = min(abs(y-.5));

    % SAVE
    SR(i_subj,:)=[x2plot(I), x2plot(Imin), coeffvalues(expmdl) GoF];
    DATA(i_subj,:) = p_thresh;
end

save('SR.mat', 'SR', 'DATA', 'noise_dur', 'age')


