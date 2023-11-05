format compact

subject = ''; 

%% FSL Flirt for alignment with the template 

    ref_file = 'MNI152_T1_1mm.nii'; 
    mri_out_files = {'T1_post_acpc.nii', 'T1_post_res_acpc.nii'}; 

    fsl_flirt_acpc(mri_folder, mri_files, mri_out_files, ref_file) 

%% Add Fieldtrip libraries 

    restoredefaultpath

    fieldtrip_folder = '';
    addpath(fieldtrip_folder);
    ft_defaults

%% Volumes alignment 

    mri_post_acpc = ft_read_mri(fullfile(mridir, subject, '/T1_post_acpc.nii.gz')); % post implantation 
    fsmri_res_acpc = ft_read_mri(fullfile(mridir, subject, '/T1_post_res_acpc.nii.gz')); % post resection 

    cfg = [];
    cfg.method = 'spm';
    cfg.spmversion = 'spm12';
    cfg.coordsys = 'acpc';
    cfg.viewresult = 'yes';
    fsmri_res_acpc_f = ft_volumerealign(cfg, fsmri_res_acpc, mri_post_acpc);

    cfg = [];
    cfg.filename = fullfile(mridir, subject, '/rT1_resection_acpc.nii');
    cfg.filetype = 'nifti';
    cfg.parameter = 'anatomy';
    ft_volumewrite(cfg, fsmri_res_acpc_f);

%% Electrode placement

    fsmri_res_acpc = ft_read_mri(fullfile(mridir, subject, '/rT1_resection_acpc.nii'));
    fsmri_post_acpc = ft_read_mri(fullfile(mridir, subject,'/T1_post_acpc.nii.gz'));
    cfg = [];
    
    folder_edf = fullfile([datadir subject], '/Block_samples/');
    list_edf = dir([folder_edf, '*.mat']);
    load(fullfile(folder_edf, list_edf(1).name)); 
    
    ch_names = [HFOobj(:).label]; 

    cfg.channel = bipol_to_monopol(ch_names); 
    
    %%
    elec_acpc_f = ft_electrodeplacement(cfg, fsmri_post_acpc);
    %%
    elec_acpc_f.elecpos = str2double(compose("%0.1f", round(elec_acpc_f.elecpos,1)));
    save(fullfile(mridir, subject, [subject, '_elec_acpc_f_new.mat']), 'elec_acpc_f');
    
%% Volume-based registration

    [ftver, ftpath] = ft_version;
    cfg = [];
    cfg.nonlinear = 'yes';
    cfg.spmversion = 'spm12';
    fsmri_post_mni = ft_volumenormalise(cfg, fsmri_post_acpc);

    elec_acpc_fr = elec_acpc_f; % because of skipping brain shift
    elec_mni_frv = elec_acpc_fr;

    elec_mni_frv.elecpos = ft_warp_apply(fsmri_post_mni.params, ...
                                         elec_acpc_fr.elecpos, 'individual2sn');
    elec_acpc_fr.elecpos = str2double(compose("%0.1f",round(elec_acpc_fr.elecpos,1)));


    elec_mni_frv.chanpos = ft_warp_apply(fsmri_post_mni.params, ...                                  
    elec_acpc_fr.chanpos, 'individual2sn');

    elec_mni_frv.coordsys = 'mni';
    elec_mni_frv.elecpos = str2double(compose("%0.1f",round(elec_mni_frv.elecpos,1)));
    save(fullfile(mridir, subject, [subject, '_elec_mni_frv_new.mat']), 'elec_mni_frv');
    
%% Anatomical labeling with MNI normalized version

    atlas = ft_read_atlas([ftpath filesep ...
                          'template/atlas/brainnetome/BNA_MPM_thr25_1.25mm.nii']);

    for ch  = 1:length(elec_mni_frv.chanpos)
        
        cfg = [];
        cfg.roi = elec_mni_frv.chanpos( ...
                            match_str(elec_mni_frv.label, char(elec_mni_frv.label{ch})),:);
        cfg.atlas = atlas;
        cfg.inputcoord = 'mni';
        cfg.output     = 'label';
        labels         = ft_volumelookup(cfg, atlas);
        [~, indx]      = max(labels.count);
        elec_mni_frv.loc{ch,2} = labels.name(indx);
        elec_mni_frv.loc{ch,1} = elec_mni_frv.label{ch};

    end

    save(fullfile(mridir, subject, [subject,'_elec_mni_frv_new']),'elec_mni_frv');
    
%% Write localization in .xlsx file 

    loc_filename = fullfile(mridir, 'localization.xlsx'); 
    write_loc_file(mridir, loc_filename, subject)
    
    