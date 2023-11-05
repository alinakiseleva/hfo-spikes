function fsl_flirt_acpc(mri_folder, mri_files, mri_out_files, ref_file)

     
    for i = 1:length(mri_files)

        in_file = fullfile(mri_folder, mri_files{i}); 
        out_file = fullfile(mri_folder, mri_out_files{i}); 

        system(sprintf('flirt -in %s -ref %s -out %s', in_file, ref_file, out_file));

    end

end
