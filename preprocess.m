clear;close all;clc;

mode = 'Divergent';

files = dir([mode '/*.*']);
files = files(3:end);
schemes = cell(length(files),1);
load(['data/' mode '_test.mat']);

figure(1);set(gcf,'Position',[10 10 1200 900]);
for i = 1 : length(files)
    schemes{i} = files(i).name(1:end-4);
    fmt =  files(i).name(end-2:end);
    
    filename = fullfile(files(i).folder,files(i).name);
    
    if strcmp(fmt,'act') || strcmp(fmt,'gct')
        fid = fopen(filename);
        A   = fread(fid);
        numc = floor(length(A)/3)*3;
        A    = A(1:numc);
        cmap = reshape(A,[3 numc/3])'./255;
        ind = find(all(cmap == 0,2));
        if ~isempty(ind)
            if ind(1) == 1
                cmap = cmap(1:ind(2)-1,:);
            else
                cmap = cmap(1:ind(1)-1,:);
            end
        end
    else
        % already in RGB format
        cmap = load(filename);
        cmap = cmap./255;
    end
    % test the colormap
    subplot_tight(8,5,i);
    
    
    if strcmp(mode,'Sequential')
        plot_globalspatial(longxy',latixy',glad');
        caxis([0 0.1]);
    elseif strcmp(mode,'Divergent')
        plot_globalspatial(longxy',latixy',pr_anomaly');
        caxis([-100 100]);
    end
    colormap(gca,cmap); 
    title(schemes{i},'FontSize',16,'FontWeight','bold','Interpreter','none');
    set(gca,'xtick',[],'ytick',[]);
end

