function ifr_compare_plot_p(data, pool1, pool2, r1, r2, r3, r4, kernel_size)

    clc;

%     pool1 = 1:10;
%     pool2 = 11:20;

    figure();
    patch([r1 r2 r2 r1], [-30 -30 +30 +30], [0.5 0.9 0.9]);hold("on");
    patch([r3 r4 r4 r3], [-30 -30 +30 +30], [0.9 0.5 0.9]);hold("on");

    for i = 1:size(data, 2)
        
        t = data(i).time;
        x = data(i).deepE_V;
%         plot_rasters(data(i));
        raster = computeRaster(t, x);
        
%         disp(size(raster));
        O1 = 5e2 * NWepanechnikovKernelRegrRaster(t, raster, pool1, kernel_size, 1, 1);
        O2 = 5e2 * NWepanechnikovKernelRegrRaster(t, raster, pool2, kernel_size, 1, 1);
        plot(t, O1 - O2, 'o');hold("on");

    end

    grid("on");title("iFR(O1) - iFR (O2)");xlabel("time (ms)");ylabel("iFR difference");
    legend("First Cue interval", "Second cue", "A", "B", "C", "No stimulus");
    fprintf("Done.\n");

end