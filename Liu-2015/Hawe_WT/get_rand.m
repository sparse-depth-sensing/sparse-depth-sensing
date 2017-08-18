% (c) Simon Hawe, Lehrstuhl fuer Datenverarbeitung Technische Universitaet
% Muenchen, 2011. Contact: simon.hawe@tum.de
function series = get_rand(range,nbr)
    series = randperm(range);
    if nargin == 2
        series = series(1:min(numel(series),nbr))';
    end
end