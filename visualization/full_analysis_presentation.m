function full_analysis_presentation(config, patients, presentation_path, template_path)

    import mlreportgen.ppt.*
    
    ppt = Presentation(presentation_path, template_path);

    for patient = patients

        paths = build_patient_paths(config, patient); 

        if flag_use_every_second_channel
            half_chs_fname_add = '_half_chs'; 
        else
            half_chs_fname_add = ''; 
        end    

        graph_pic = [ls([fullfile(paths.prop_plots_path, [flag_results '_graph_seqwin_200' half_chs_fname_add '_cleaned.png'])]), ...
                    ls([fullfile(paths.prop_plots_path, [flag_results '_graph_seqwin_205' half_chs_fname_add '_cleaned.png'])])];

        pic_names = {fullfile(paths.bar_plot_folder, [num2str(patient) '_hfo_spike_rates_thr_' num2str(prctile_thr) '.png']), ...
                     fullfile(paths.prop_plots_path, [flag_results 'bar_travelling_waves_all_int_patient_' num2str(patient) half_chs_fname_add '.png']), ...
                     fullfile(paths.prop_plots_path, graph_pic), ...
                     fullfile(paths.prop_plots_path, ['propagation_layout_pat_' num2str(patient) '_position_top_thr_' num2str(graph_thr) '.png']), ...
                     fullfile(paths.prop_plots_path, ['In_out_strength_pat_' num2str(patient) '.png'])}; 

        for pic_name = pic_names 
            try    
                pictureSlide = add(ppt, 'Title and Full Picture');

                pictureSlide.Style = [FontSize('20')]; 
                replace(pictureSlide, pictureSlide.Children(1, 1).Name, num2str(patient));

                plot1 = Picture(char(pic_name));
                replace(pictureSlide, pictureSlide.Children(1, 2).Name, plot1);

            catch
                disp(pic_name)
            end 
        end 
    end 

    close(ppt);
    rptview(ppt);
    
end
