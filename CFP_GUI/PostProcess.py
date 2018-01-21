import numpy as np


def extract_note_info(pred_roll, Threshold = 0.5):
# Translate the predict piano roll to another kind of expressive way (alike midi).
    record = []
    for note in pred_roll:
        tmp_record = []
        start_i = -1
        length = 0
        for i in range(len(note)):
            if note[i] < Threshold and start_i == -1:
                continue
            elif note[i] > Threshold and start_i == -1:
                start_i = i
                length += 1
            elif note[i] > Threshold and start_i != -1:
                length += 1
            else:
                tmp_record.append({'start_i': start_i, 'end_i': i, 'length': length})
                start_i = -1
                length = 0
        record.append(tmp_record)
    return record
    
def copy(pred_roll):
	_new_ = []
	for i in range(len(pred_roll)):
		_new_.append(pred_roll[i])
	
	return np.array(_new_)
	
def Polish(roll):
    MAX_GAP = 20 # eauqls to 0.2 sec
    MIN_LEN = 10 # equals to 0.1 sec
    Threshold = 0.5
    
    record = extract_note_info(roll, Threshold)
    pred_roll = copy(roll)
	
    for ith_note in range(len(record)):
        i = 0
        while i < len(record[ith_note]):
            note = record[ith_note]
            
            if note[i]['length'] < MIN_LEN:
			# Complement or eliminate notes shorter than $MIN_LEN ms
                if i == 0:
				# Check for the note occur in the beginning
                    if i == len(note)-1:
					# There is only one note played during the whole piece.
					# Directly eliminate this note.
                        pred_roll[ith_note] = 0
                        record[ith_note].pop(i)
                    elif note[i+1]['start_i']-note[i]['end_i'] < MAX_GAP and note[i+1]['length'] > MIN_LEN:
					# Complement the note with the next note if the gap between them is shoter than $MAX_GAP and
					# the next note is longer then $MIN_LEN.
                        complement_range = range(note[i]['end_i'], note[i+1]['start_i'])
                        pred_roll[ith_note][complement_range] = 1
                        record[ith_note][i]['end_i'] = note[i+1]['end_i']
                        record[ith_note][i]['length'] = note[i+1]['end_i'] - note[i]['start_i']
                        record[ith_note].pop(i+1)
                        i += 1
                    else:
                        eliminate_range = range(note[i]['start_i'], note[i]['end_i'])
                        pred_roll[ith_note][eliminate_range] = 0
                        record[ith_note].pop(i)
                elif i == len(note)-1:
				# Check for the note occur in the end
                    if note[i]['start_i']-note[i-1]['end_i'] >= MAX_GAP:
                        eliminate_range = range(note[i]['start_i'], note[i]['end_i'])
                        pred_roll[ith_note][eliminate_range] = 0
                        record[ith_note].pop(i)
                    else:
                        complement_range = range(note[i-1]['end_i'], note[i]['start_i'])
                        pred_roll[ith_note][complement_range] = 1
                        record[ith_note][i]['start_i'] = note[i-1]['start_i']
                        record[ith_note][i]['length'] = note[i]['end_i'] - note[i-1]['start_i']
                        record[ith_note].pop(i-1)
                else:
                    early_gap = note[i]['start_i']-note[i-1]['end_i'] < MAX_GAP
                    early_merge = early_gap and (note[i-1]['length'] > MIN_LEN)
                    later_gap = note[i+1]['start_i']-note[i]['end_i'] < MAX_GAP
                    later_merge = later_gap and (note[i+1]['length'] > MIN_LEN)
                    
                    if early_merge and later_merge:
                        complement_range = range(note[i-1]['start_i'], note[i+1]['end_i'])
                        pred_roll[ith_note][complement_range] = 1
                        record[ith_note][i]['start_i'] = note[i-1]['start_i']
                        record[ith_note][i]['end_i'] = note[i+1]['end_i']
                        record[ith_note][i]['length'] = note[i+1]['end_i'] - note[i-1]['start_i']
                        record[ith_note].pop(i+1)
                        record[ith_note].pop(i-1)
                    elif early_merge:
                        complement_range = range(note[i-1]['end_i'], note[i]['start_i'])
                        pred_roll[ith_note][complement_range] = 1
                        record[ith_note][i]['end_i'] = note[i-1]['start_i']
                        record[ith_note][i]['length'] = note[i]['end_i'] - note[i-1]['start_i']
                        record[ith_note].pop(i-1)
                    elif later_merge:
                        complement_range = range(note[i]['end_i'], note[i+1]['start_i'])
                        pred_roll[ith_note][complement_range] = 1
                        record[ith_note][i]['end_i'] = note[i+1]['end_i']
                        record[ith_note][i]['length'] = note[i+1]['end_i'] - note[i]['start_i']
                        record[ith_note].pop(i+1)
                        i += 1
                    else:
                        eliminate_range = range(note[i]['start_i'], note[i]['end_i'])
                        pred_roll[ith_note][eliminate_range] = 0
                        record[ith_note].pop(i)
            else:
                if i != len(note)-1 and note[i+1]['start_i']-note[i]['end_i'] < MAX_GAP and note[i+1]['length'] > MIN_LEN:
				# Complement the space between two notes longer than $MIN_LEN if the space is shoter than $MAX_GAP.
                    complement_range = range(note[i]['end_i'], note[i+1]['start_i'])
                    pred_roll[ith_note][complement_range] = 1
                    record[ith_note][i]['end_i'] = note[i+1]['end_i']
                    record[ith_note][i]['length'] = note[i+1]['end_i'] - note[i]['start_i']
                    record[ith_note].pop(i+1)
                i += 1
    return pred_roll
    
    
    
    
    
    
    