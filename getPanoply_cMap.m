function cmap = getPanoply_cMap(scheme,show_samples)

    if nargin == 1
        show_samples = 0;
    end
    if show_samples
        preprocess()
    end
    
    load('cmaps.mat');
    
    if isfield(cmaps,scheme)
        cmap = cmaps.(scheme);
    else
        disp([scheme ' is not available! Current available color scheme is: ']);
        schemes = fieldnames(cmaps);
        disp(schemes);
        error('error');
    end
    
    
    
end

function preprocess()

    modes = {'Sequential','Divergent','Topographic','Rainbow'};
    for imode = 1 : length(modes)
        
        mode = modes{imode};
        
        files = dir([mode '/*.*']);
        files = files(3:end);
        schemes = cell(length(files),1);
        load(['data/' mode '_test.mat']);

        figure;set(gcf,'Position',[10 10 1200 900]);
        if exist('cmaps.mat','file')
            load('cmaps.mat');
        else
            cmaps = struct([]);
        end

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

            cmaps(1).(schemes{i}) = cmap;
            % test the colormap
            
            if strcmp(mode,'Sequential')
                subplot_tight(8,5,i);
                plot_globalspatial(longxy',latixy',glad');
                caxis([0 0.1]);
            elseif strcmp(mode,'Divergent')
                subplot_tight(8,5,i);
                plot_globalspatial(longxy',latixy',pr_anomaly');
                caxis([-100 100]);
            elseif strcmp(mode,'Topographic') 
                subplot_tight(3,2,i);
                plot_globalspatial(longxy',latixy',ele');
            elseif strcmp(mode,'Rainbow')
                subplot_tight(4,2,i);
                plot_globalspatial(longxy',latixy',ele');
                %caxis([-100 100]);
            end
            colormap(gca,cmap); 
            title(schemes{i},'FontSize',16,'FontWeight','bold','Interpreter','none');
            set(gca,'xtick',[],'ytick',[]);
        end
        
        suptitle(mode);

        save('cmaps.mat','cmaps');
    end
end

function [cb,lon,lat] = plot_globalspatial(lon,lat,A,opt)
    
    if nargin == 3
        opt = 1;
    end
    
    load coastlines;
    if max(lon(:)) > 180
        [m,n] = size(A);
        if lon(1,n/2+1) <= 180 
            split_i = n/2+1;
        else
            split_i = n/2;
        end
        A1 = A(:,1:split_i);
        A2 = A(:,split_i+1:end);
        A = cat(2,A2,A1);
        lon(lon > 180) = lon(lon > 180) - 360;
        lon1 = lon(:,1:split_i);
        lon2 = lon(:,split_i+1:end);
        lon = cat(2,lon2,lon1);
    end
    imAlpha = ones(size(A));
    imAlpha(isnan(A)) = 0;
    if opt == 1
        imagesc([lon(1,1),lon(end,end)],[lat(1,1),lat(end,end)],A,'AlphaData',imAlpha); hold on;
        plot(coastlon,coastlat,'k-','LineWidth',1); grid on; 
        set(gca,'YDir','normal'); hold on; cb = colorbar; colormap(gca,viridis);
    elseif opt == 2
        worldmap('world');
        pcolorm(lat,lon,A,'AlphaData',imAlpha);
        plotm(coastlat,coastlon,'k-','LineWidth',1); grid on; 
        set(gca,'YDir','normal'); hold on; cb = colorbar; colormap(viridis); 
        mlabel off; plabel off; % remove latitude and longitude label
        %gridm off; % remove latitude and longitude lines
    end
    cb.FontSize = 14;
    %ylim([-60 90]);
end


