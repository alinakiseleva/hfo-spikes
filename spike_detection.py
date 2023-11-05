from __future__ import print_function, division
import pandas as pd
import scipy.io as sio
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from matplotlib.pyplot import specgram
import torch
# import torchvision
from torchvision import datasets, transforms
import shutil
import os
import h5py
import warnings
from utils.detector_functions import *
import argparse
warnings.filterwarnings('ignore')

def color_str(string, color='b'): 
    
    cstr = dict()
    
    cstr['y'] = '\033[33m'
    cstr['r'] = '\033[91m'
    cstr['g'] = '\033[92m'
    cstr['b'] = '\033[94m'
    cstr['end'] = '\033[0m'
    
    return cstr[color] + string + cstr['end']


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='A script to run CNN spike detection on the delphos detector candidates'
    )

    parser.add_argument('-patient', type=str, help='Patient number')

    parser.add_argument('-data_root', type=str,
                        default=r'Z:\Alina Kiseleva\DATA\pirogov_data',
                        help='Path to patients data directory')

    parser.add_argument('-save_root', type=str,
                        default=r'Z:\Alina Kiseleva\DATA\pirogov_data',
                        help='Path to patients results directory')

    parser.add_argument('-overwrite', type=int,
                        default=0,
                        help='Overwrite the previous result. 0 for False, 1 for True')
    
    patient, data_root, save_root, overwrite = vars(parser.parse_args()).values()
    
    eegdir = os.getcwd()  # CURRENT DIRECTORY
    spectdir = eegdir + '/SPECTS/IEDS/'  # DIRECTORY FOR SAVING IMAGES
    
    ### A: LOAD ALL DATA --- extract clip_id from path
    model_dir = eegdir + "/"  # dir with trained model
    proj_dir = eegdir + "/"  # dir with main project script
    imgs = 'SPECTS'  # dir with IED / NONIED image dirs (name of subdir)
    
    ### B: LOAD PRETRAINED MODEL
    try:
        model = torch.load(model_dir + 'model_aied.pt')
        # model.eval() # model architecture
    except ImportError:
        print(
            'TRAINED MODEL NOT FOUND: Check that trained model is in eegdir and name matches: model_aied.pt')
    cnn_freq = 200 # the fs for CNN
 
    print(color_str(f'Started patient: {patient}'))
        
    patient_folder = None 
    folders = os.listdir(data_root)
    for folder in folders:
        if patient in folder:
            patient_folder = folder
    
    if patient_folder is None: 
        print(color_str(f'Not found patient {patient}', 'r'))
        quit()
    
    pat_num = os.listdir(os.path.join(data_root, patient_folder, 'Block_samples'))[1][8:10]
    
    patient_save_path = os.path.join(save_root, patient_folder)
    patient_data_path = os.path.join(data_root, patient_folder, 'Block_samples')
    
    delphos_results_path = os.path.join(patient_save_path, 'delphos_results')
    cnn_delphos_results_path = os.path.join(patient_save_path, 'cnn_delphos_results')
    
    if not os.path.exists(cnn_delphos_results_path):
      os.makedirs(cnn_delphos_results_path)
    
    filenames = os.listdir(os.path.join(data_root, patient_folder, 'Block_samples'))
    for filename in filenames:
    
        if '.mat' in filename and 'result' not in filename:
    
            data_filename = os.path.join(patient_data_path, filename)  # CHOOSE MATLAB FILE
            delphos_results_filename = os.path.join(delphos_results_path, filename)  # FILENAME DELPHOS RESULTS
            cnn_delphos_out_filename = os.path.join(cnn_delphos_results_path, filename)  # FILENAME FOR OUTPUT FOR MATLAB
    
            if os.path.isfile(data_filename) and os.path.isfile(delphos_results_filename) and (not os.path.isfile(cnn_delphos_out_filename) or overwrite == 1):
                
                print(f'Processing file {data_filename}')
                orig_data, Fs, Nch, labels = read_pirogov_HFOobj(data_filename)  # reading HFOobj
    
                # should be orig_data.shape[0] > orig_data.shape[1]
                data = np.zeros((Nch, int(orig_data.shape[1] / Fs * cnn_freq)))
                for ch in range(Nch):
                    data[ch] = signal.resample(orig_data[ch], int(orig_data.shape[1] / Fs * cnn_freq))  # DECIMATE SIGNAL
    
                print(data.shape)
                data = pd.DataFrame(data)
                data = data.astype(float)
    
                spikes = load_detection_results(delphos_results_filename, cnn_freq, patient, 'delphos')
    
                delete_previous_images(spectdir) #clear the spects folder
    
                spectimgs(data, spikes, spectdir)  ### 4. GENERATE INPUT IMAGES FOR CNN
                ### 5. ResNet-18 CNN DETECTOR:
                data_transforms = {
                    imgs: transforms.Compose([
                        transforms.Resize(224),
                        transforms.Pad(1, fill=0, padding_mode='constant'),
                        transforms.ToTensor(),
                        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
                    ])}
    
                image_datasets = {x: ImageFolderWithPaths(os.path.join(proj_dir, x),
                                                        data_transforms[x]) for x in [imgs]}
                dataloaders = {x: torch.utils.data.DataLoader(image_datasets[x], batch_size=1,  # use batch=1, shuffle=F
                                                            shuffle=False, num_workers=0) for x in [imgs]}
                class_names = image_datasets[imgs].classes
                device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
                # extract image paths
                path_names = []
    
                for images, labels, paths in dataloaders[imgs]:
                    path_names.append(paths)
    
                # convert list of paths to dataframe col
                df = pd.DataFrame(path_names)
                df.columns = ['clip_ids']
                df['clip_ids'] = df['clip_ids'].str.replace('\\', '/')
                df[['clip_ids', 'clip']] = df['clip_ids'].str.split("IEDS/", expand=True)
                df['clip'] = df['clip'].str.rstrip('.png')
                df[['subject', 'start', 'chan']] = df['clip'].str.split('_', expand=True)
    
                ### C: RUN MODEL
                y_pred = []
                with torch.no_grad():
                    for inputs, labels, paths in dataloaders[imgs]:
                        inputs = inputs.to(device)
                        labels = labels.to(device)
                        outputs = model.forward(inputs)
                        _, predicted = torch.max(outputs, 1)
                        pred = predicted.numpy()
                        lab = labels.numpy()
                        y_pred.append(pred)
    
                # reformat outputs:
                y_pred_flat = np.concatenate((y_pred), axis=0)
                df['predicted_class'] = y_pred_flat
    
                # SAVE OUTPUT DATA TO MATLAB FILE. 1 column = channel, 2 column = spike time (in ms)
                # channel indexing starts from 1
                df.start = df.start.astype(float)
                df.chan = df.chan.astype(int)
                df = df[df.predicted_class == 0]  # spikes == 0
                df.drop_duplicates()
                df = df.sort_values(by=['chan', 'start'])
                output_delphos_cnn = np.stack((df.chan, df.start), axis=1).astype(float)
                output_delphos_cnn[:, 0] += 1
                output_delphos_cnn[:, 1] /= cnn_freq  # account for decimating
    
                mdict = {'output_delphos_cnn': output_delphos_cnn}
                sio.savemat(cnn_delphos_out_filename, mdict, oned_as='column')
                print(color_str(f'Saved file: {cnn_delphos_out_filename}', 'g'))
    
            elif not os.path.exists(os.path.isfile(data_filename)):
                print(color_str(f'Not found file: {data_filename}', 'r'))
    
            elif not os.path.isfile(delphos_results_filename):
                print(color_str(f'Not found delphos detection file: {delphos_results_filename}', 'r'))
    
            elif os.path.isfile(cnn_delphos_out_filename):
                print(color_str(f'Skipping file: {filename}, already exists detection', 'y'))
    
            else:
                print(color_str(f'Skipping file {filename}', 'r'))