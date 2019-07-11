% Function identifies the number of test variables and according to which it
% applies the single ROC plot or multiple ROC plot. The script uses the
% perfcurve function and also logistic regression function.
%
% The results have been verified using:
% 1) SAS
% 2) STATA
% 3) MEDCALC
% 4) SPSS
%
% ---------------------------------------------------------------------------
% Author:
%
% Saurav Roy,
% Research and Development Engineer,
% Neuroimaging and Neurospectroscopy Lab,
% National Brain Research Centre,
% India.

function ROCplot(testvariable, statusvariable, posclass)

% Input Variables
% ---------------------------------------------------------------------------
% testvariable : continuous variables
% statusvariable : binary variable


% Example:
%
% statusvariable : (can have only 1 variable but in
% the format given below)
%
%
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 1
% 0
% 0
% 0
% 0
% 0
% 0
% 0
% 0
%
% testvariable : (can have n number of variable but in
% the format given below)
%
% 2.58089908114286	1.93567431085714
% 1.49528280097959	1.68475356685714
% 1.78204936555102	NAN
% 1.95615763689796	NAN
% 1.41847032832653	1.58233693665306
% 1.49016196946939	1.48504113795918
% 2.08417842465306	2.14562840277551
% 1.41334949681633	1.08049544865306
% 1.03440796506122	1.66427024081633
% 1.58745776816327	1.89982849028571
% 1.52088695853061	2.37094498922449
% 0.921749671836735	2.02272844653061
% 1.35189951869388	1.83837851216327
% 	2.258286696     NAN
% 1.64378691477551	1.72572021893878
% 2.0124867835102	NAN
% 1.60282026269388	1.23412039395918
% 1.45943698040816	1.60794109420408
% 1.84862017518367	1.79741186008163
% 2.258286696         2.16611172881633
% 1.36214118171429	1.02928713355102
% 1.60794109420408	1.72059938742857
% 1.60282026269388	1.73084105044898
% 1.77692853404082	NAN
% 1.83837851216327	2.14562840277551
% 1.14706625828571	1.39798700228571
% 1.85886183820408	1.5004036324898
%
% Output Variable
% ---------------------------------------------------------------------------
% ROC Curve
% AUC Values
% ---------------------------------------------------------------------------

[~, column] = size(testvariable);
xstring = 'False Positive Rate';
ystring = 'True Positive Rate';
X_all = cell([1 column]);
Y_all = cell([1 column]);

if column == 1
    % Single plot ROC
    groupVar = statusvariable;
    contdVar = testvariable;
    mdl = fitglm(contdVar,groupVar,'Distribution','binomial','Link','logit');
    scores = mdl.Fitted.Probability;
    [X,Y,~,AUC] = perfcurve(groupVar,scores, posclass);
    figure;plot(X,Y);xlabel(xstring);ylabel(ystring);
    title('Single Variable ROC');
    fprintf('AUC Curve :');disp(AUC);
    
elseif column > 1
    % Multiple plot ROC
    groupVar = statusvariable;
    contdVar = testvariable;
    data = [groupVar, contdVar];
    alterdata = rmmissing(data);
    [~, columnnum] = size(data);
    groupv = alterdata(:,1);
    contdv = alterdata(:,2:columnnum);
    
    mdl = fitglm(contdv,groupv,'Distribution','binomial','Link','logit');
    scores = mdl.Fitted.Probability;
    [X,Y,~,AUC] = perfcurve(groupv,scores, posclass);
    figure;plot(X,Y);xlabel(xstring);ylabel(ystring);
    title('Complete Classification ROC Plot');
    fprintf('AUC Curve(Complete):');disp(AUC);
    line([0,1],[0,1],'Color','k');
    
    % Plot Fitted ROC Plots with each Variable
    for i = 1: column
        binvalue = groupv;
        contvalue = contdv(:,i);
        mdl1 = fitglm(contvalue, binvalue,'Distribution','binomial','Link','logit');
        scores1 = mdl1.Fitted.Probability;
        [X1, Y1, ~, AUC1] = perfcurve(binvalue, scores1, posclass);
        figure;plot(X1,Y1),xlabel(xstring);ylabel(ystring);
        title('ROC Curve');
        fprintf('AUC Curve(%d):',i);disp(AUC1);
        X_all{i} = X1;
        Y_all{i} = Y1;
        line([0,1],[0,1],'Color','k');
    end
    
    figure; hold on
    
    for i = 1: column
        plot(X_all{i},Y_all{i});
        xlabel(xstring);ylabel(ystring);
        title('ROC for Comparison');
    end
    
    % Reference Line Plot for ROC Curve
    line([0,1],[0,1],'Color','k');
else
    % Do Nothing
end

end
