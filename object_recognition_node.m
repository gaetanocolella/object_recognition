clear all
close all
clc

addpath .
addpath neural_nets_iiwa

%rosinit;

server = rossvcserver('/chooseObject', 'visp_common/ChooseObject', @ObjectCallback);
disp('Waiting for client call , choose the object to be recognized...')

function resMsg = ObjectCallback(server,reqMsg,resMsg)

disp('Starting object recognition...');

object= reqMsg.Object;

switch object
    case "denkmit"
       load('detector_denkmit.mat');
    case "denkmit_oriz"
       load('detector_denkmit_oriz.mat');
    case "finish"        
       load('detector_finish.mat');
    case "heitmann"     
       load('detector_heitmann.mat');
    case "balea"
       load('detector_balea');
    otherwise
      error("Object name is incorrected");
end

inputSize = [480 640 3];
camera = rossubscriber('/camera/color/image_raw');
scandata = receive(camera);

I=readImage(scandata);
I = imresize(I,inputSize(1:2));

[bboxes,scores] = detect(detector,I);
label=object;
if(not(isempty(bboxes)))
    %% Calcolo centro della bounding box
u_center = bboxes(1)+(bboxes(3)/2);
v_center = bboxes(2)+(bboxes(4)/2);
I = insertObjectAnnotation(I,'rectangle',bboxes,label,'LineWidth',4);
resMsg.ObjectCenter.X=u_center;
resMsg.ObjectCenter.Y=v_center;
resMsg.ObjectCenter.Z=0.0;
resMsg.Success=true;
disp('Object recognized');
else
    resMsg.Success=false;
    disp('Object not recognized');

end

hold on
imshow(I)
title('Detected objects')

end



