function [ count ] = getNumberOfImages( settings )
%getNumberOfImages Get the number of data in a folder
%   Detailed explanation goes here

D = dir([getPath('data', settings), '/*.mat']);
count = length(D(not([D.isdir]))) - 1;

end

