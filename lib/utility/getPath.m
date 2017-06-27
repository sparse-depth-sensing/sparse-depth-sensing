function [ targetPath ] = getPath( targetFolder, settings )
%GETPATH returns the full path to a target folder or file
%   Detailed explanation goes here

activeFunctionFilename = mfilename('fullpath'); % get the full path of `getPath.m`
rootPath = getParentFolder(activeFunctionFilename, 3);  % get the full path of the repo root folder

if nargin > 1
  isMultiframe = isfield(settings, 'windowSize'); % set to true if running multi-frame reconstruction
  if isMultiframe
    filenameStringFormat = 'subSample=%g.sampleMode=%s.percSamples=%g.noise=%g.stretch=%g.addNeighbors=%d.windowSize=%d.%s.%s';
    nestaResultStringFormat = ['%s', filesep, 'temporal', filesep, 'mu=%g', filesep, filenameStringFormat];
    cvxResultStringFormat = ['%s', filesep, 'temporal', filesep, 'cvx', filesep, filenameStringFormat];
  else
    filenameStringFormat = 'subSample=%g.sampleMode=%s.percSamples=%g.noise=%g.stretch=%g.addNeighbors=%d.%s.%s';
    nestaResultStringFormat = ['%s', filesep, 'single', filesep, 'mu=%g', filesep, filenameStringFormat];
    cvxResultStringFormat = ['%s', filesep, 'single', filesep, 'cvx', filesep, filenameStringFormat];
  end
end

switch targetFolder
  case 'root' % get the repo root folder
    targetPath = rootPath;
  case 'lib'  % get the lib folder
    targetPath = fullfile(rootPath, 'lib');
  case 'data' % get the data folder
    targetPath = fullfile(rootPath, 'data');
    if nargin > 1
      targetPath = fullfile(targetPath, settings.dataset);
    end
  case 'results'  % get the result folder
    targetPath = fullfile(rootPath, 'results');
    if nargin > 1
      if isMultiframe
        switch settings.solver
          case 'nesta'
            targetPath = sprintf(nestaResultStringFormat, ...
              targetPath, settings.mu, settings.subSample, ...
              settings.sampleMode, settings.percSamples, ...
              settings.epsilon, settings.stretch.delta_y, ...
              settings.doAddNeighbors, settings.windowSize, ...
              settings.solver, settings.dataset);
          case 'cvx'
            targetPath = sprintf(cvxResultStringFormat, ...
              targetPath, settings.subSample, ...
              settings.sampleMode, settings.percSamples, ...
              settings.epsilon, settings.stretch.delta_y, ...
              settings.doAddNeighbors, settings.windowSize, ...
              settings.solver, settings.dataset);
          otherwise
            error('getPath(): incorrect settings for solver.')
        end
      else
        switch settings.solver
          case 'nesta'
            targetPath = sprintf(nestaResultStringFormat, ...
              targetPath, settings.mu, settings.subSample, ...
              settings.sampleMode, settings.percSamples, ...
              settings.epsilon, settings.stretch.delta_y, ...
              settings.doAddNeighbors, settings.solver, settings.dataset);
          case 'cvx'
            targetPath = sprintf(cvxResultStringFormat, ...
              targetPath, settings.subSample, ...
              settings.sampleMode, settings.percSamples, ...
              settings.epsilon, settings.stretch.delta_y, ...
              settings.doAddNeighbors, settings.solver, settings.dataset);
          otherwise
            error('getPath(): incorrect settings for solver.')
        end
      end
    end
  case 'figures'  % get the figure folder
    targetPath = fullfile(getPath('results'), 'figures');
    if nargin > 1
      if isMultiframe
        switch settings.solver
          case 'nesta'
            targetPath = sprintf(nestaResultStringFormat, ...
              targetPath, settings.mu, settings.subSample, ...
              settings.sampleMode, settings.percSamples, ...
              settings.epsilon, settings.stretch.delta_y, ...
              settings.doAddNeighbors, settings.windowSize, ...
              settings.solver, settings.dataset);
          case 'cvx'
            targetPath = sprintf(cvxResultStringFormat, ...
              targetPath, settings.subSample, ...
              settings.sampleMode, settings.percSamples, ...
              settings.epsilon, settings.stretch.delta_y, ...
              settings.doAddNeighbors, settings.windowSize, ...
              settings.solver, settings.dataset);
          otherwise
            error('getPath(): incorrect settings for solver.')
        end
      else
        switch settings.solver
          case 'nesta'
            targetPath = sprintf(nestaResultStringFormat, ...
              targetPath, settings.mu, settings.subSample, ...
              settings.sampleMode, settings.percSamples, ...
              settings.epsilon, settings.stretch.delta_y, ...
              settings.doAddNeighbors, ...
              settings.solver, settings.dataset);
          case 'cvx'
            targetPath = sprintf(cvxResultStringFormat, ...
              targetPath, settings.subSample, ...
              settings.sampleMode, settings.percSamples, ...
              settings.epsilon, settings.stretch.delta_y, ...
              settings.doAddNeighbors, ...
              settings.solver, settings.dataset);
          otherwise
            error('getPath(): incorrect settings for solver.')
        end
      end
    end
  otherwise
    error('Unknown target folder')
end

end

% TODO: fix this for multi-platform
function parentFolderPath = getParentFolder(targetPath, levelUp)
indexAllSlashes = findstr(targetPath, filesep);
indexSlash = indexAllSlashes(end-levelUp+1) - 1;
parentFolderPath = targetPath(1:indexSlash);
end

