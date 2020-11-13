**This folder contains Matlab programs for a toolbox for DNN assisted Kalman filtering for speech enhancement. This toolbox is composed by Hongjiang Yu, based on the framework written by OSU team.**

For the details of the algorithm, please refer the following paper. please refer the following paper. <br/> 
@inproceedings{yu2019deep, <br/> 
&emsp; title={A Deep Neural Network Based Kalman Filter for Time Domain Speech Enhancement}, <br/> 
&emsp; author={Yu, Hongjiang and Ouyang, Zhiheng and Zhu, Wei-Ping and Champagne, Benoit and Ji, Yunyun}, <br/> 
&emsp; booktitle={2019 IEEE International Symposium on Circuits and Systems (ISCAS)}, <br/> 
&emsp; pages={1--5}, <br/> 
&emsp; year={2019}, <br/> 
&emsp; organization={IEEE} <br/> 
}

For the details of the DNN augmented colored-noise Kalman filtering, please refer to the following paper.<br/> 
https://www.sciencedirect.com/science/article/abs/pii/S0167639320302831 <br/> 
@article{yu2020speech,
&emsp;  title={Speech Enhancement Using a DNN-Augmented Colored-Noise Kalman Filter},<br/> 
&emsp;  author={Yu, Hongjiang and Zhu, Wei-Ping and Champagne},<br/> 
&emsp;  journal={Speech Communication},<br/> 
&emsp;  volume={in press},<br/> 
&emsp;  number={in press},<br/> 
&emsp;  pages={in press},<br/> 
&emsp;  year={2020},<br/> 
&emsp;  publisher={Elsevier}<br/> 
}


## Description of folders and files

**config/** 
Lists of clean utterances for training and test.

**DATA/**
Mixtures, features, LSFs (line spectral frequencies) and enhanced speech are stored here.

**dnn/**
Code for DNN training and test, where dnn/main/ includes key functions for DNN training/test, dnn/pretraining/ includes code for unsupervised DNN pretraining.

**gen_mixture/**
Code for creating mixtures from noise and clean utterances.

**get_feat/:**
Code for acoustic features and LSFs calculation.

**Kalman/:**
Files for Kalman filtering algorithm and objective evaluation.

**premix_data/**
Sample data including clean speech and noise.

**load_config.m**
Configures feature type, noise type, training utterance list, test utterance list, mixture SNR, etc.

**RUN.m**
Loads configurations from load_config.m and runs a speech enhancement demo.


## DEMO

(Tested on Matlab 2017b under Ubuntu 16.04 and Windows 10.)
This demo uses 670 mixtures for training and 80 mixtures for testing.
The mixtures are created by mixing clean utterances with babble and white noise at 0dB and 3 dB.
A 3-hidden-layer DNN with Relu hidden activation is used for LSFs estimation.

To run this demo, simply execute RUN.m in matlab. This matlab script will execute the following steps:
- Load configurations in load_config.m:
   1. 'train_list' and 'test_list' specify lists of clean utterances for training and test.
   2. 'mix_db' specifies the SNR of training and test mixtures.
   3. 'is_gen_mix', 'is_gen_feat' and 'is_dnn' indicate whether to perform different steps in speech separation.
- Create data folders for this demo.
- Implement DNN based speech separation. Three steps are performed:
   1. Generate training and test mixtures.
   2. Generate training and test features / LSFs
   3. DNN training and test. To use a different network architecture, you may change the configurations ('opts.*') in ./dnn/main/dnn_train.m, where:
         + 'opts.unit_type_hidden' specifies the activation function for hidden layers ('sigm': sigmoid, 'relu': ReLU).
         + 'opts.isPretrain' indicates whether to perform pretraining (0: no pretraining, 1: pretraining). Note that pretraining is only supported for the sigmoid hidden activation function.
         + 'opts.hid_struct' specifies the numbers of hidden layers and hidden units.
         + 'opts.sgd_max_epoch' specifies the maximum number of training epochs.
         + 'opts.isDropout' specifies whether to use dropout regularization.

When DNN training and test are finished, you will find the following speech separation results:
- DATA/babble_white/dnn/WAVE/db0 3/: mixture, clean speech and enhanced speech.
- DATA/babble_white/dnn/STORE/db0 3/est_lsf/: estimated LSFs and ideal LSFs.
- DATA/babble_white/log_db0 3.txt: log file for this demo.


## Acknowledgement
We use the DNN framework from the professor Deliang Wang's team of the OSU.(http://web.cse.ohio-state.edu/pnl/DNN_toolbox/)

