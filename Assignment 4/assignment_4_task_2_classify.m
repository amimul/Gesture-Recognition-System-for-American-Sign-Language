% Assignment 4: Classification
numOfFeatures = 34;
maxTimeLength = 55;
words = ["About","And","Can","Cop","Deaf","Decide","Father","Find","GoOut","Hearing"];
inputFolder = 'Classification-DataSet';
classifiers = ["DT","SVM","NN"];
results = [];
trainFileName = strcat(inputFolder,'/','training_data.csv');
trainFile = readtable(trainFileName,'ReadVariableNames',false);
trainContent = trainFile(randperm(size(trainFile,1)),:);
trainContent = table2array(trainContent);
testFileName = strcat(inputFolder,'/','testing_data.csv');
testFile = readtable(testFileName,'ReadVariableNames',false);
testContent = table2array(testFile);
[numOfTrainActions,~] = size(trainContent);
[numOfTestActions,~] = size(testContent);
%   Looping over different gestures
for i=1:length(words)
    trainLabels = trainContent(1:numOfTrainActions,end) == i;
    testLabels = testContent(1:numOfTestActions,end) == i;
    for j=1:length(classifiers)
        switch classifiers(j)
            case "DT"
%                   Decision Tree training and testing
                model = fitctree(trainContent(1:end,1:end-1),trainLabels);
                predictedLabels = predict(model,testContent(1:end,1:end-1));
            case "SVM"
%                   SVM training and testing
                model = fitcsvm(trainContent(1:end,1:end-1),trainLabels,'Standardize',true,'KernelFunction','RBF', 'KernelScale','auto');
                predictedLabels = predict(model,testContent(1:end,1:end-1));
            case "NN"
%                   Neural Network training and testing
                inputs = trainContent(1:end,1:end-1);
                targets = trainLabels;
                testInputs = testContent(1:end,1:end-1);
                testTargets = testLabels;
                net = feedforwardnet(15);
                trainedNet = train(net, inputs', targets');
                predictedValues = trainedNet(testInputs');
                predictedLabels = predictedValues >= 0.5;
                predictedLabels = predictedLabels';
        end
%           Calculation of accuracy metrics after testing
        TP = sum((predictedLabels + testLabels) == 2);
        FP = sum((predictedLabels - testLabels) == 1);
        FN = sum((predictedLabels - testLabels) == -1);
        precision = TP / (TP + FP);
        if isnan(precision)
            precision = 0;
        end
        recall = TP / (TP + FN);
        if isnan(recall)
            recall = 0;
        end
        F1 = (2 * precision * recall) / (precision + recall);
        if isnan(F1)
            F1 = 0;
        end
        accuracy = sum(predictedLabels == testLabels) / numOfTestActions;
        user = 'DM07';
        result = [words(i), classifiers(j), num2str(accuracy), num2str(precision), num2str(recall), num2str(F1)];
        if isempty(results)
            results = result;
        else
            results = cat(1, results, result);
        end
    end
end
T = table(results(1:end,1:1),results(1:end,2:2),results(1:end,3:3),results(1:end,4:4),results(1:end,5:5),results(1:end,6:6),'VariableNames',{'Gesture' 'Machine' 'Accuracy' 'Precision' 'Recall' 'F1'});
writetable(T,'Results-Report-User-Independent.csv');