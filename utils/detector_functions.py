# libraries
from __future__ import print_function, division
import pandas as pd
import scipy.io as sio
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from matplotlib.pyplot import specgram
import torch
from torchvision import datasets, transforms
import shutil
import os
import warnings
import h5py

class ImageFolderWithPaths(datasets.ImageFolder):
    """Custom dataset that includes image file paths.
    Extends torchvision.datasets.ImageFolder
    """

    # override the __getitem__ method. this is the method that dataloader calls
    def __getitem__(self, index):
        # this is what ImageFolder normally returns
        original_tuple = super(ImageFolderWithPaths, self).__getitem__(index)
        # the image file path
        path = self.imgs[index][0]
        # make a new tuple that includes original and the path
        tuple_with_path = (original_tuple + (path,))
        return (tuple_with_path)


def read_pirogov_HFOobj(data_filename):

    with h5py.File(data_filename, 'r') as f:

        X_raw = list()
        for i in range(0, f['HFOobj']['result'].shape[0]):

            ref = f['HFOobj']['result'][i][0]

            if len(X_raw) != 0:
                X_raw = np.append(X_raw, np.array(f[ref]['signal']), axis=1)
            else:
                X_raw = np.array(f[ref]['signal'])

        if X_raw.shape[0] > X_raw.shape[1]:
            X_raw = X_raw.T

        duration = f[ref]['time'][-1][0]

    Nch = X_raw.shape[0]
    labels = list(range(1, Nch + 1))

    Fs = int(X_raw.shape[1] / duration)

    return X_raw, Fs, Nch, labels


def read_pirogov_MNI_data(data_filename):
    mat_file = sio.loadmat(data_filename, mdict=None, appendmat=True)
    Fs = mat_file['MNI_data'][0]['fsample'][0][0][0]
    ch_names = mat_file['MNI_data'][0]['label'][0]
    X_raw = mat_file['MNI_data'][0]['trial'][0][0][0]
    mat_file = []
    if X_raw.shape[0] > X_raw.shape[1]:
            X_raw = X_raw.T
    Nch = X_raw.shape[0]
    labels = list(range(1, Nch + 1))
    return X_raw, Fs, Nch, labels


def notch_filter(ch_signal, f0, fs, Q=35.0):
    #fs  Sample frequency (Hz)
    #f0  Frequency to be removed from signal (Hz)
    # Q  Quality factor
    b, a = signal.iirnotch(f0, Q, fs)
    clean_signal = signal.filtfilt(b, a, ch_signal)
    return clean_signal


def load_detection_results(results_filename, freq, patient, level):
    """LOAD DELPHOS RESULTS
    Input:
    - path to .mat file with results
    - freq - 'fs' to convert ms in timestamps
    - patient - number of the patient
    - level: 'cnn' or 'delphos' or 'aligned'
    Output: pandasDataFrame with columns
    - 'channel' for channels (from 0 to Nch)
    - 'subject' with patient number
    - 'fs' - frequency in which the timestamps are
    - 'spikeTime' timestamps of the spikes in 'fs'
    """
    if level == 'cnn':
        level = 'output_delphos_cnn'
    elif level == 'delphos':
        level = 'spikes'
    elif level == 'aligned':
        level = 'aligned_spikes'
    mat_file = sio.loadmat(results_filename, mdict=None, appendmat=True)
    spikes = mat_file[level]
    spikes = pd.DataFrame(spikes, columns=['channel', 'spikeTime'])
    mat_file = []
    spikes['channel'] -= 1
    spikes['subject'] = f'{patient}'
    spikes['fs'] = freq
    spikes['spikeTime'] *= freq

    spikes.spikeTime = spikes.spikeTime.astype(int)
    spikes.channel = spikes.channel.astype(int)

    return spikes


def delete_previous_images(spectdir):
    """DELETES PREVIOUS IMAGES"""
    os.makedirs(spectdir, exist_ok=True)
    for filename in os.listdir(spectdir):
        file_path = os.path.join(spectdir, filename)
        try:
            if os.path.isfile(file_path) or os.path.islink(file_path):
                os.unlink(file_path)
            elif os.path.isdir(file_path):
                shutil.rmtree(file_path)
        except Exception as e:
            print('Failed to delete %s. Reason: %s' % (file_path, e))



def spectimgs(eegdata, spikedf, spectdir):
    """
    SPECTS: GENERATE SPECTS FOR CNN
        INPUT: 1) eegdata, 2) spikedf (df from automated template-matching spike detector)
        OUTPUT: spects within ./SPECTS/IEDS
    """
    samp_freq = int(float(spikedf.fs.values[0]))
    #######################################
    pad = 1  # d:1 number of seconds for window
    dpi_setting = 300  # d:300
    Nfft = 128 * (samp_freq / 500)  # d: 128
    h = 3
    w = 3
    #######################################
    chan_name = None
    for i in range(0, len(spikedf)):
        subject = spikedf.subject.values[0]
        if chan_name == int(spikedf.channel.values[i]):
            pass
        else:
            chan_name = int(spikedf.channel.values[i])  # zero idxed -1
            ### select eeg data row
            ecogclip = eegdata.iloc[chan_name]
            ### filter out line noise
            b_notch, a_notch = signal.iirnotch(50.0, 30.0, samp_freq)
            ecogclip = pd.Series(signal.filtfilt(b_notch, a_notch, ecogclip))
            ### select eeg data row
        spikestart = spikedf.spikeTime.values[i]  # spike peak
        ### trim eeg clip based on cushion
        ### mean imputation if missing indices
        end = int(float((spikestart + int(float(pad * samp_freq)))))
        start = int(float((spikestart - int(float(pad * samp_freq)))))

        if end > max(ecogclip.index):
            temp = list(ecogclip[list(range(spikestart - int(float(pad * samp_freq)), max(ecogclip.index)))])
            cushend = [np.mean(ecogclip)] * (end - max(ecogclip.index))
            temp = np.array(temp + cushend)
        elif start < min(ecogclip.index):
            temp = list(ecogclip[list(range(min(ecogclip.index), spikestart + pad * samp_freq))])
            cushstart = [np.mean(ecogclip)] * (min(ecogclip.index) - start)
            temp = np.array(cushstart + temp)
        else:
            temp = np.array(ecogclip[list(
                range(spikestart - int(float(pad * samp_freq)), spikestart + int(float(pad * samp_freq))))])
        ### PLOT AND EXPORT:
        fig = plt.figure(figsize=(h, w))
        
        _, freqs, _, _ = specgram(temp, NFFT=int(Nfft), Fs=samp_freq, noverlap=int(Nfft / 2), detrend="linear", cmap="YlOrRd")
        
        specgram(temp, NFFT=int(Nfft), Fs=samp_freq, noverlap=int(Nfft / 2), detrend="linear", cmap="YlOrRd")
        plt.axis("off")
        plt.xlim(0, pad * 2)
        plt.ylim(0, 100)
        plt.savefig(spectdir + subject + "_" + str(spikestart) + "_" + str(chan_name) + ".png", dpi=dpi_setting)
        plt.close(fig)
        del fig