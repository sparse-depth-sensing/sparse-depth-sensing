function [ flag ] = isSyntheticDataset( settings )
%ISKINECTDATASET Return true if we are runninng tests on a Kinect dataset
%   Detailed explanation goes here

if strcmp(settings.dataset, 'pwlinear_nbCorners=10')
    flag = true;
else
    flag = false;
end

