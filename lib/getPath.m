function [ targetPath ] = getPath( targetFolder, settings )
%GETPATH Summary of this function goes here
%   Detailed explanation goes here

activeFunctionFilename = mfilename('fullpath');
rootPath = getParentFolder(activeFunctionFilename, 2);

if nargin > 1
    flagTemporal = isfield(settings, 'windowSize');
end

if nargin > 1 && flagTemporal
    nestaStringFormat = '%s/temporal/mu=%g/subSample=%g.sampleMode=%s.percSamples=%g.noise=%g.stretch=%g.addNeighbors=%d.windowSize=%d.%s.%s';
    cvxStringFormat = '%s/temporal/cvx/subSample=%g.sampleMode=%s.percSamples=%g.noise=%g.stretch=%g.addNeighbors=%d.windowSize=%d.%s.%s';
else
    nestaStringFormat = '%s/single/mu=%g/subSample=%g.sampleMode=%s.percSamples=%g.noise=%g.stretch=%g.addNeighbors=%d.%s.%s';
    cvxStringFormat = '%s/single/cvx/subSample=%g.sampleMode=%s.percSamples=%g.noise=%g.stretch=%g.addNeighbors=%d.%s.%s';
end

switch targetFolder
    case 'root'
        targetPath = rootPath;
    case 'lib'
        targetPath = sprintf('%s/lib', rootPath);
    case 'data'
        targetPath = sprintf('%s/data', rootPath);
        if nargin > 1
            targetPath = sprintf('%s/%s', targetPath, settings.dataset);
        end
    case 'results'
%         parentOfRoot = getParentFolder(rootPath, 1);
%         targetPath = sprintf('%s/results', parentOfRoot);
        targetPath = sprintf('%s/results', rootPath);
        if nargin > 1
            if flagTemporal
                switch settings.solver
                    case 'nesta'
                        targetPath = sprintf(nestaStringFormat, ...
                            targetPath, settings.mu, settings.subSample, ...
                            settings.sampleMode, settings.percSamples, ...
                            settings.epsilon, settings.stretch.delta_y, ...
                            settings.doAddNeighbors, settings.windowSize, ...
                            settings.solver, settings.dataset);
                    case 'cvx'
                        targetPath = sprintf(cvxStringFormat, ...
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
                        targetPath = sprintf(nestaStringFormat, ...
                            targetPath, settings.mu, settings.subSample, ...
                            settings.sampleMode, settings.percSamples, ...
                            settings.epsilon, settings.stretch.delta_y, ...
                            settings.doAddNeighbors, settings.solver, settings.dataset);
                    case 'cvx'
                        targetPath = sprintf(cvxStringFormat, ...
                            targetPath, settings.subSample, ...
                            settings.sampleMode, settings.percSamples, ...
                            settings.epsilon, settings.stretch.delta_y, ...
                            settings.doAddNeighbors, settings.solver, settings.dataset);
                    otherwise
                        error('getPath(): incorrect settings for solver.')
                end  
            end
        end
    case 'figures'
%         parentOfRoot = getParentFolder(rootPath, 1);
%         targetPath = sprintf('%s/results/figures', parentOfRoot);
        targetPath = sprintf('%s/figures', getPath( 'results' ));
        if nargin > 1
            if flagTemporal
                switch settings.solver
                    case 'nesta'
                        targetPath = sprintf(nestaStringFormat, ...
                            targetPath, settings.mu, settings.subSample, ...
                            settings.sampleMode, settings.percSamples, ...
                            settings.epsilon, settings.stretch.delta_y, ...
                            settings.doAddNeighbors, settings.windowSize, ...
                            settings.solver, settings.dataset);
                    case 'cvx'
                        targetPath = sprintf(cvxStringFormat, ...
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
                        targetPath = sprintf(nestaStringFormat, ...
                            targetPath, settings.mu, settings.subSample, ...
                            settings.sampleMode, settings.percSamples, ...
                            settings.epsilon, settings.stretch.delta_y, ...
                            settings.doAddNeighbors, ...
                            settings.solver, settings.dataset);
                    case 'cvx'
                        targetPath = sprintf(cvxStringFormat, ...
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

function parentFolderPath = getParentFolder(targetPath, levelUp)
    indexAllSlashes = findstr(targetPath, '/');
    indexSlash = indexAllSlashes(end-levelUp+1) - 1;
    parentFolderPath = targetPath(1:indexSlash);
end

