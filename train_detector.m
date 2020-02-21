clc
clear all
%% Scarico la rete pre-addestrata
doTraining = false;
if ~doTraining && ~exist('yolov2ResNet50VehicleExample_19b.mat','file')    
    disp('Downloading pretrained detector (98 MB)...');
    pretrainedURL = 'https://www.mathworks.com/supportfiles/vision/data/yolov2ResNet50VehicleExample_19b.mat';
    websave('yolov2ResNet50VehicleExample_19b.mat',pretrainedURL);
end
%% Memorizzo le immagini gTruth in una cartella
trainingData = objectDetectorTrainingData(gTruth);

%% Carico le immagini labellate
data = load('denkmitdataset.mat');
objectsdataset=data.trainingData;
objectsdataset.imageFilename = fullfile(objectsdataset.imageFilename); %memorizzo il path delle immagini
obj = cell2mat(objectsdataset.denkmit);
obj_app = round(obj);
c = cell(size(obj_app,1),1);
for i=1:size(obj_app,1)
    c(i,:) = {obj_app(i,:)};
end
objectsdataset.denkmit=c;

%% Dividere il set di dati in un set di addestramento e un set di test 
%  Seleziona il 60% dei dati per l'allenamento e il resto per la valutazione.
rng(0);
shuffledIndices = randperm(height(objectsdataset)); %genero numeri casuali da 1 a numeroimmagini 
idx = floor(0.6 * length(shuffledIndices) ); % ottengo il 60% del numero di immagini
trainingDataTbl = objectsdataset(shuffledIndices(1:idx),:); % set di dati per il training
testDataTbl = objectsdataset(shuffledIndices(idx+1:end),:); % set di dati per il test

imdsTrain = imageDatastore(trainingDataTbl{:,'imageFilename'}); %archivio dati con immagini di training
bldsTrain = boxLabelDatastore(trainingDataTbl(:,'denkmit'));      % archivio dati per le label

imdsTest = imageDatastore(testDataTbl{:,'imageFilename'});
bldsTest = boxLabelDatastore(testDataTbl(:,'denkmit'));

trainingData = combine(imdsTrain,bldsTrain);
testData = combine(imdsTest,bldsTest);

%% immagine com bbox
data = read(trainingData);
I = data{1};
bbox = data{2};
annotatedImage = insertShape(I,'Rectangle',bbox,'LineWidth',8);
annotatedImage = imresize(annotatedImage,2);
figure
imshow(annotatedImage)

%% create detector
inputSize = [224 224 3];
numClasses = width(objectsdataset)-1;
trainingDataForEstimation = transform(trainingData,@(data)preprocessData(data,inputSize));
numAnchors = 10;
[anchorBoxes, meanIoU] = estimateAnchorBoxes(trainingDataForEstimation, numAnchors)
%[anchorBoxes, meanIoU] = estimateAnchorBoxes(trainingData, numAnchors)
%% Rete Pre-addestrata
featureExtractionNetwork = resnet50;
featureLayer = 'activation_40_relu';
lgraph = yolov2Layers(inputSize,numClasses,anchorBoxes,featureExtractionNetwork,featureLayer);

%% Aumento numero di dati
augmentedTrainingData = transform(trainingData,@augmentData);
% Visualize the augmented images.
augmentedData = cell(4,1);
for k = 1:4
    data = read(augmentedTrainingData);
    augmentedData{k} = insertShape(data{1},'Rectangle',data{2});
    reset(augmentedTrainingData);
end
figure
montage(augmentedData,'BorderSize',10)
%%
preprocessedTrainingData = transform(augmentedTrainingData,@(data)preprocessData(data,inputSize));
data = read(preprocessedTrainingData);
options = trainingOptions('sgdm', ...
        'MiniBatchSize', 16, ....
        'InitialLearnRate',1e-4, ...
        'MaxEpochs',20,...
        'CheckpointPath', tempdir, ...
        'Shuffle','never',...
        'Verbose',true,...
        'VerboseFrequency',1,...
        'Shuffle','every-epoch');
    
    % Train the YOLO v2 detector.
    [detector,info] = trainYOLOv2ObjectDetector(preprocessedTrainingData,lgraph,options);

%%
I = imread(testDataTbl.imageFilename{50});
I = imresize(I,inputSize(1:2));
[bboxes,scores] = detect(detector,I);
I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
figure
imshow(I)

%%
inputSize = [480 640 3];
c = cell(100);
j = 1;
while true
camera = rossubscriber('/camera/color/image_raw');
scandata = receive(camera);
I=readImage(scandata);
I = imresize(I,inputSize(1:2));

[bboxes,scores] = detect(detector,I);
if(not(isempty(bboxes)))
I = insertObjectAnnotation(I,'rectangle',bboxes,scores,'LineWidth',4);
% Rect = [bboxes(1)-100 bboxes(2) bboxes(3)+1000 bboxes(4)]
% I_Croped=imcrop(I_new,Rect);
% c(j) = {}
end

imshow(I)
title('Detected objects');
end


%% Calcolo centro della bounding box
u_center = bboxes(1)+(bboxes(3)/2);
v_center = bboxes(2)+(bboxes(4)/2);

pointMsg = rosmessage('geometry_msgs/Point');

pub = rospublisher('/object_center','geometry_msgs/Point');

pointMsg.X=u_center;
pointMsg.Y=v_center;
pointMsg.Z=0.0;


for i=1:5 
send(pub,pointMsg);
end 



