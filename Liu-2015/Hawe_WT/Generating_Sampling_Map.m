function Sample_Map = Generating_Sampling_Map(im,p)


indx = randperm(numel(im));
[I J]=ind2sub(size(im),indx(1:floor(numel(im)*p/100)));

Sample_Map =zeros(size(im));

for ii=1:length(I)
   Sample_Map(I(ii),J(ii))=1;
end
