import os
import scipy.io
import numpy as np
import mne
mne.set_log_level("CRITICAL")
from scipy.spatial import distance
from collections import Counter
import pandas as pd


def setup_volume_and_surface_src(subjects_dir, subject, labels_vol): 
    
    # volume 
    fname_aseg = os.path.join(subjects_dir, subject, 'mri', 'aseg.mgz')
    vol_src = mne.setup_volume_source_space(
        subject, 
        mri=fname_aseg, 
        surface=os.path.join(subjects_dir, 'fsaverage', 'bem', 'inner_skull_d10.surf'), 
        pos=5.0, 
        subjects_dir=subjects_dir,
        volume_label=labels_vol, 
        single_volume=True,
        add_interpolator=True,
        verbose=True)
    
    #surface
    src_fname = os.path.join(subjects_dir, subject, 'bem', f'{subject}-5-src.fif')
    surf_src = mne.read_source_spaces(src_fname)

    return surf_src, vol_src


def compute_vol_stc(subjects_dir, subject, vol_src, trial, initial_time = 1):
    
    vec_vol_coords = scipy.io.loadmat(os.path.join(subjects_dir, subject, 'files', 'vec_vol_src_coords.mat'))
    vec_vol_coords = vec_vol_coords['vol_coords']
    
    vol_inds = []
    
    for point in vec_vol_coords:
        point = np.expand_dims(point, axis=0)
        diff = distance.cdist(vol_src[0]['rr'], point)
        vol_inds.append(np.argmin(diff))

    vec_vol_stc_fname = os.path.join(subjects_dir, subject, 'files', f'vec_vol_stc_{trial}.mat')
    vec_vol_stc = scipy.io.loadmat(vec_vol_stc_fname)

    # compute volume activation
    activation = np.zeros((vol_src[0]['rr'].shape[0], 3))
    vec_vol_stc = vec_vol_stc['vec_vol_stc']

    for i, ind in enumerate(vol_inds):
        activation[ind] += vec_vol_stc[i]

    counts = Counter(vol_inds)
    for ind in counts:
        activation[ind] /= counts[ind]

    vol_verts = list(range(activation.shape[0]))
    vec_vol_stc = mne.VolVectorSourceEstimate(
        activation,
        vertices=[vol_verts],
        tmin=initial_time,
        tstep=initial_time,
        subject=subject,
        verbose=False,
    )
    vol_data = vec_vol_stc.data 
    
    return vol_data


def compute_surface_stc(subjects_dir, subject, trial):
    
    coords = ['x', 'y', 'z']
    src_estimates = []
    
    for i, coord in enumerate(coords):
        surf_stc_fname = os.path.join(subjects_dir, subject, 'files', f'seeg_wb_mne_cc_raw_mne_{trial}_{coord}-lh.stc')
        surf_stc = mne.read_source_estimate(surf_stc_fname)
        surf_stc.subject = subject
        if coord == 'x':
            cols = surf_stc.to_data_frame().columns
            surf_lh_verts, surf_rh_verts = [], []
            for col in cols:
                if 'LH' in col:
                    surf_lh_verts.append(col.split('_')[1])
                elif 'RH' in col:
                    surf_rh_verts.append(col.split('_')[1])
            surf_lh_verts = np.array(surf_lh_verts).astype(int)
            surf_rh_verts = np.array(surf_rh_verts).astype(int)
        if len(src_estimates) < 1:
            src_estimates = np.ndarray.flatten(surf_stc.data)
        else:
            src_estimates = np.column_stack((src_estimates, np.ndarray.flatten(surf_stc.data)))

    src_estimates = np.expand_dims(src_estimates, 2) 
    
    return src_estimates, surf_lh_verts, surf_rh_verts


def compute_mixed_stc(subjects_dir, subject, vol_src, trial, init_time):
    
    vol_data = compute_vol_stc(subjects_dir, subject, vol_src, trial, init_time) 
    surf_data, surf_lh_verts, surf_rh_verts = compute_surface_stc(subjects_dir, subject, trial)

    src_estimates = np.concatenate((surf_data, vol_data))
    
    stc = mne.MixedVectorSourceEstimate(
                src_estimates,
                vertices=[
                    surf_lh_verts,
                    surf_rh_verts,
                    list(range(vol_data.shape[0]))
                ],
                tmin=init_time,
                tstep=init_time,
                subject=subject,
                verbose=False,
            )
    
    return stc


def retreive_mni_source_coords(src): 
    
        for i in range(len(src)):
            if i == 0: 
                src_coords = src[i]['rr'][np.where(src[i]['inuse'])[0], :]
            else: 
                src_coords = np.vstack((
                            src_coords,
                            src[i]['rr'][np.where(src[i]['inuse'])[0], :] 
                            ))
        src_coords *= 1000
        return src_coords


def find_ra_sources(sources_coords, ra_chan_coords, max_distance): 
        
        distances = distance.cdist(sources_coords, ra_chan_coords)
        ra = np.where(distances[:] < max_distance)[0]    
        
        return np.unique(ra), sources_coords[ra]


def find_active_sources(stc, src, activity_prctile_threshold): 
            
            source_estimates = stc.magnitude().data
            activation = np.vstack((
                                source_estimates[0 : src[0]['nuse']],
                                source_estimates[src[0]['nuse'] : src[0]['nuse'] + src[1]['nuse']], 
                                source_estimates[src[0]['nuse'] + src[1]['nuse'] :][src[2]['inuse']]
            ))
            area = np.where(activation > np.percentile(activation, activity_prctile_threshold))[0]
            
            return np.unique(area)


def read_mni_localization(file_path, subject):

    df = pd.read_excel(file_path, 
                       sheet_name=f'p{subject}',
                       usecols=[0, 4, 5, 6])
    
    df.columns = ['chan_name', 'x', 'y', 'z']
    
    return df 


def read_resected_el_names(file_path, subject):
    
    df = pd.read_excel(file_path, 
                       sheet_name=f'p{subject}')
    
    return df['resected_channels'].tolist()


def select_resected_electrodes(localization, resected_el_names): 
    
    if np.sum(localization['chan_name'].isin(resected_el_names)) != len(resected_el_names): 
        
        raise ValueError(
            f"{len(resected_el_names) - np.sum(localization['chan_name'].isin(resected_el_names))} channels missing from the localization file"
            )  
    
    return localization[localization['chan_name'].isin(resected_el_names)][['x', 'y', 'z']].to_numpy()