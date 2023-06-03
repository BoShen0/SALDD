%% Point cloud data
stlData = stlread('MeshFinal2.stl');
patchStruct.Vertices = stlData.Points;
patchStruct.Faces = stlData.ConnectivityList;
patchStruct.FaceColor = 'r';
patch(patchStruct)
view(3)


DataRaw = stlData.Points;
histogram(DataRaw(:,1))
DataRaw(DataRaw(:,1)<59.5,:) = [];
DataRaw(DataRaw(:,1)>74.5,:) = [];
histogram(DataRaw(:,2))
DataRaw(DataRaw(:,2)<-7.9,:) = [];
DataRaw(DataRaw(:,2)>7.1,:) = [];
DataRaw(:,1) = DataRaw(:,1) - min(DataRaw(:,1));
DataRaw(:,2) = DataRaw(:,2) - min(DataRaw(:,2));
for i=1:30
    index1 = find(DataRaw(:,1)>=0.5*(i-1) & DataRaw(:,1)<0.5*i);
    DataTemp = DataRaw(index1,:);
    for j=1:30
        index2 = find(DataTemp(:,2)>=0.5*(j-1) & DataTemp(:,2)<0.5*j);
        Sa(30*(i-1)+j) = mean(abs(DataTemp(index2,3) - mean(DataTemp(index2,3))));
    end
end
[B,I] = sort(Sa,'descend');
%% Image data
ImageData = cdata(181:2580,148:2547,1);
imshow(ImageData)
imshow( ImageData((28*80+1):80*30,(28*80+1):80*30) )

% mu = mean(ImageData,'all');
for ii=1:30
    for jj=1:30
        ImageTemp = double(ImageData( (80*(ii-1)+1):80*ii,(80*(jj-1)+1):80*jj ));
        DataMetal(30*(ii-1)+jj,:) =  double(ImageTemp(:));
        Sa2d(30*(ii-1)+jj) = mean(abs(ImageTemp - mean(ImageTemp,'all')),'all');
    end
end
[B2d,I2d] = sort(Sa2d,'descend');
% DataMetal = double(DataMetal);
%% C2M data
plot3(MeshC2Mfinal2(:,1), MeshC2Mfinal2(:,2), MeshC2Mfinal2(:,3),'.')

data = stlread('model.stl');
trimesh(data,'FaceColor','none','EdgeColor','k')

%% Image data
% first crop
imshow(cdata(261:2990,755:3484,3))
