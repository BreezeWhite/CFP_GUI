
import numpy as np
import Statistics as st
from keras.models import load_model
from keras.utils.generic_utils import get_custom_objects


def CNN_predict(Data, useType=['Spec', 'Ceps', 'GCoS']):
    numFrames = 5
    test_batchSize = 2000
    shape = Data.shape
    
    msg = '\nTesting on %d samples.' % shape[0]
    print(msg)
    yield msg
    
    get_custom_objects().update({"Precision": st.Precision})
    get_custom_objects().update({"Recall": st.Recall})
    get_custom_objects().update({"Fscore": st.Fscore})
    model_path = './'
    model_name = 'Pretrained_Model'
    
    yield "Loading model..."
    model = load_model(model_name+'.hdf5')
    
    yield "Predicting..."
    idx = np.random.permutation(shape[0])
    batches = int(np.ceil(shape[0]/test_batchSize))
    yield "_batches_ %d" % batches 
    pred_midi = []
    for i in range(batches):
        sel_t = idx[i*test_batchSize:(i+1)*test_batchSize]
        if i == batches-1:
            sel_t = idx[i*test_batchSize:]
            
        data = preCNN_processBatch(Data, sel_t, numFrames)
        
        pred = model.predict(data)
#        pred = np.where(pred>0.5, 1, 0)
        pred_midi.append({'pred':pred, 'idx':sel_t})
        
        info = 'Progress: %d/%d' % ((i+1), batches)
        print(info, end='\r')
        yield info
    
    yield "END"
    yield SortPredict(pred_midi, shape[0])

def preCNN_processBatch(data, sel_idx, numFrames):
# Process data for each batch
    assert numFrames%2 == 1    
    
    half_numFrames = int(numFrames/2)
    shape = (len(sel_idx), numFrames, data.shape[2], data.shape[3])
    new_data = np.zeros(shape)
    index = [{'start_i': 0, 'length': data.shape[0]}]
    
    cur_pos = 0
    for i in sel_idx:
        ith_song = 0
        
        song_len = index[ith_song]['length']
        i -= index[ith_song]['start_i']
        
        # Combine frames. For each sample, $half_numFrames frames before and after are combined together.
        # Here will check the border of each song. Zeros will be padded if the range is out of the bound.
        if i < half_numFrames:
            frame_idx = range(0, i+half_numFrames+1)
            x = np.zeros((numFrames, 1, shape[2], shape[3]))
            x[half_numFrames-i:] = data[frame_idx]
        elif i >= song_len-half_numFrames:
            offset = song_len-i
            frame_idx = range(i-half_numFrames, i+offset)
            x = np.zeros((numFrames, 1, shape[2], shape[3]))
            x[0:half_numFrames+offset] = data[frame_idx]
        else:
            frame_idx = range(i-half_numFrames, i+half_numFrames+1)
            x = data[frame_idx]
            
        new_data[cur_pos] = x.reshape((1, numFrames, shape[2], shape[3]))
        cur_pos += 1
		
    return new_data

def SortPredict(pred_note, sample_num):
    new_pred = np.zeros((sample_num, 88))
    for p in pred_note:
        for ii in range(len(p['idx'])):
            new_pred[p['idx'][ii]] = p['pred'][ii]
    
    return new_pred.transpose()
        
    
