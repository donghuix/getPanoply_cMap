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

