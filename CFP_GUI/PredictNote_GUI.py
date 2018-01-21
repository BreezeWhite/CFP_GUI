import tkinter as tk
from pathlib import Path
import tkinter.ttk as ttk
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

from PostProcess import Polish
from GenFeature import PreProcessSong
from CNN_Predict_GUI import CNN_predict


class PredictNote():
    def __init__(self, mainframe, Log, audio_path, prog_bar, *args):
        self.PredictNote_GUI(mainframe, Log, audio_path, prog_bar)
        
    def PredictNote_GUI(self, mainframe, Log, audio_path, prog_bar):
        # Preprocess audio
        data = self.GenFeature(Log, audio_path.get(), prog_bar)
        if data is None: return
        
        # Predict on notes
        pred_note = self.runCNN_predict(data, Log, prog_bar)
        
        # Write prediction to file
        audio_name = audio_path.get().split("/")[-1]
        out_path = "/home/User/"
        writePredict2File(pred_note, out_path+audio_name)        
        
        # Create a new sub window and show the predction 
        self.ShowPredict(mainframe, pred_note)
        
        return 
    
    def GenFeature(self, Log, audio_path, prog_bar):
        # File legality check
        if Path(audio_path).is_file() != True:
            Log.insert(tk.END, "File not found!\n")
            return None
        sup_fmt = ['.wav']
        if any([(fmt in audio_path) for fmt in sup_fmt]) != True:
            Log.insert(tk.END, "File format not supported!\n")
            return None
        
        # Preprocess feature
        Log.insert(tk.END, "Pre-processing audio file...\n")
        Log.update_idletasks()
        Log.see(tk.END)
        
        data = PreProcessSong(audio_path)
        
        prog_bar.step(amount=30)
        prog_bar.update_idletasks()
        
        return data
        
    def runCNN_predict(self, feature, Log, prog_bar):
        # Predict on notes
        predict_generator = CNN_predict(feature, useType=['Ceps', 'GCoS'])
        msg = next(predict_generator)
        step_amt = 1
        while msg != "END":
            if "Progress" in msg:
                Log.insert(tk.END, msg+'\n')
                prog_bar.step(amount=step_amt)
                prog_bar.update_idletasks()
            elif "_batches_" in msg:
                batches = int(msg.split(' ')[1])
                rest = 99-prog_bar['value']
                step_amt = int(rest/batches)
            else:
                Log.insert(tk.END, msg+'\n')
            Log.update_idletasks()
            Log.see(tk.END)
            msg = next(predict_generator)
            
        pred_note = next(predict_generator)
        Log.insert(tk.END, "Done!\n")
        Log.update_idletasks()
        Log.see(tk.END)
        
        # Some simple post processing
        pred_note = Polish(pred_note)
        
        return pred_note

    
    def ShowPredict(self, root, pred):
        sub_win = tk.Toplevel(root)
        sub_win.title('Piano Roll')
        sub_win.rowconfigure(0, weight=1)
        sub_win.columnconfigure(0, weight=1)
        
        sub_frm = ttk.Frame(sub_win, relief='groove')
        sub_frm.grid(column=0, row=0, sticky=('N', 'W', 'E', 'S'))
        sub_frm.rowconfigure(0, weight=1)
        sub_frm.columnconfigure(0, weight=1)
        
        fig, ax = plt.subplots(nrows=1)
        fig.set_size_inches(8, 5)
        ax.imshow(pred, aspect='auto', origin='lower', cmap="RdPu")
        ax.set_xlabel("Time(ms)")
        ax.set_ylabel("Pitch number")
        ax.xaxis.set_label_coords(0.5, -0.1)
        
        roll = FigureCanvasTkAgg(fig, master=sub_frm)
        roll.get_tk_widget().grid(row=0, column=0)
        roll.draw()
    
    
def writePredict2File(pred, save_path='/home/User/'):
    pred = pred.transpose()
    
    save_path.replace('.wav', '')
    save_path.split(".")[0]
    out = open(save_path+".txt", 'w')
    for sample in pred:
        for note in sample:
            out.write('%.4f '%note)
        out.write('\n')
    out.close()
    
    
    
    
    
    
    
    
    
    
    
    
