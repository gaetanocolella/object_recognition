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

load('detector_multiple.mat');

object= reqMsg.Object;
try
switch object
    case "balea"
       obj='balea';
    case "heitmann"        
       obj='heitmann';
    case "denkmit"     
       obj='denkmit';
    case "finish"
       obj='finish';
    otherwise
      warning("Object name is not correct");
end


inputSize = [480 640 3];
camera = rossubscriber('/camera/color/image_raw');
scandata = receive(camera);

I=readImage(scandata);
I = imresize(I,inputSize(1:2));

[bboxes,scores,labels] = detect(detector,I);
if(not(isempty(bboxes)))
%% Calcolo centro della bounding box
l = cellstr(labels);
switch size(l,1)
        case 4
            switch obj
                case l{1,1}
                            I = insertObjectAnnotation(I,'rectangle',bboxes(1,:),l{1},'LineWidth',4);
                            u_center = bboxes(1,1)+(bboxes(1,3)/2);
                            v_center = bboxes(1,2)+(bboxes(1,4)/2);    
                case l{2,1}        
                            I = insertObjectAnnotation(I,'rectangle',bboxes(2,:),l{2},'LineWidth',4);
                            u_center = bboxes(2,1)+(bboxes(2,3)/2);
                            v_center = bboxes(2,2)+(bboxes(2,4)/2);
                case l{3,1}    
                            I = insertObjectAnnotation(I,'rectangle',bboxes(3,:),l{3},'LineWidth',4);
                            u_center = bboxes(3,1)+(bboxes(3,3)/2);
                            v_center = bboxes(3,2)+(bboxes(3,4)/2);
                case l{4,1}
                            I = insertObjectAnnotation(I,'rectangle',bboxes(4,:),l{4},'LineWidth',4);
                            u_center = bboxes(4,1)+(bboxes(4,3)/2);
                            v_center = bboxes(4,2)+(bboxes(4,4)/2);
                otherwise
                  warning("Object not present in the scene");
            end
          case 3
            switch obj
                case l{1,1}
                            I = insertObjectAnnotation(I,'rectangle',bboxes(1,:),l{1},'LineWidth',4);
                            u_center = bboxes(1,1)+(bboxes(1,3)/2);
                            v_center = bboxes(1,2)+(bboxes(1,4)/2);    
                case l{2,1}        
                            I = insertObjectAnnotation(I,'rectangle',bboxes(2,:),l{2},'LineWidth',4);
                            u_center = bboxes(2,1)+(bboxes(2,3)/2);
                            v_center = bboxes(2,2)+(bboxes(2,4)/2);
                case l{3,1}    
                            I = insertObjectAnnotation(I,'rectangle',bboxes(3,:),l{3},'LineWidth',4);
                            u_center = bboxes(3,1)+(bboxes(3,3)/2);
                            v_center = bboxes(3,2)+(bboxes(3,4)/2);
                otherwise
                  warning("Object not present in the scene");
            end
         case 2
            switch obj
                case l{1,1}
                            I = insertObjectAnnotation(I,'rectangle',bboxes(1,:),l{1},'LineWidth',4);
                            u_center = bboxes(1,1)+(bboxes(1,3)/2);
                            v_center = bboxes(1,2)+(bboxes(1,4)/2);    
                case l{2,1}        
                            I = insertObjectAnnotation(I,'rectangle',bboxes(2,:),l{2},'LineWidth',4);
                            u_center = bboxes(2,1)+(bboxes(2,3)/2);
                            v_center = bboxes(2,2)+(bboxes(2,4)/2);
                otherwise
                  warning("Object not present in the scene");
            end
          case 1
            switch obj
                case l{1,1}
                            I = insertObjectAnnotation(I,'rectangle',bboxes(1,:),l{1},'LineWidth',4);
                            u_center = bboxes(1,1)+(bboxes(1,3)/2);
                            v_center = bboxes(1,2)+(bboxes(1,4)/2);
                otherwise
                  warning("Object not present in the scene");
            end
end
resMsg.ObjectCenter.X=u_center;
resMsg.ObjectCenter.Y=v_center;
resMsg.ObjectCenter.Z=0.0;
resMsg.Success=true;
disp('Object recognized');
end

hold on
imshow(I)
title('Detected objects')
catch
    resMsg.Success=false;
    disp('Object not recognized');
end
end



