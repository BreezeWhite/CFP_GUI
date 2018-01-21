import tkinter as tk
import tkinter.ttk as ttk
from PredictNote_GUI import PredictNote

class CFP_GUI(tk.Frame):
    def __init__(self, root=None):
        assert root != None, 'There is no Tk object being passed!!'
            
        tk.Frame.__init__(self, root)
        
        root.title('Piano Roll Generater')
        root.rowconfigure(0, weight=1)
        root.columnconfigure(0, weight=1)    
        root.minsize(width=600, height=250)
        self.mainframe = ttk.Frame(root, padding='7 7 12 12')
        self.mainframe.grid(column=0, row=0, sticky=('N', 'W', 'E', 'S'))
        
        # Put widgets into the frame
        self.createWidgets()
        
        # Some grid arrangement
        for child in self.mainframe.winfo_children(): child.grid_configure(padx=3, pady=5)
        for col_num in range(2, self.mainframe.grid_size()[0]): self.mainframe.columnconfigure(col_num, weight=1)
        self.mainframe.rowconfigure(3, weight=1)
        
        self.aliasFastKey()
    
    def createWidgets(self):
        # Description labels
        label = ttk.Label(self.mainframe, text='Audio path: ')
        label.grid(column=1, row=1, sticky=('N', 'W', 'E', 'S'))
        
        pr_label = ttk.Label(self.mainframe, text='Progress')
        pr_label.grid(column=1, row=2, sticky=('N', 'W', 'E', 'S'))
        
        # Path input entry
        self.audio_path = tk.StringVar()
        audio_entry = ttk.Entry(self.mainframe, textvariable=self.audio_path)
        audio_entry.grid(column=2, row=1, columnspan=2, sticky=('N', 'W', 'E', 'S'))
        audio_entry.focus()
        
        # Multiple text line logbox
        self.Log = tk.Text(self.mainframe, width=20, height=10)
        self.Log.grid(column=1, row=3, columnspan=3, sticky=('N', 'W', 'E', 'S'))
        s = ttk.Scrollbar(self.Log, orient='vertical', command=self.Log.yview)
        s.pack(side='right', fill='y')
        self.Log.configure(yscrollcommand=s.set)    
        
        # Progress bar
        self.prog_bar = ttk.Progressbar(self.mainframe, orient='horizontal', mode='determinate')
        self.prog_bar.grid(column=2, row=2, columnspan=2, sticky=('N', 'W', 'E', 'S'))
        
        # Predict button
        button = ttk.Button(self.mainframe, text = 'Predict!', 
                            command= lambda: PredictNote(self.mainframe, self.Log, self.audio_path, self.prog_bar))
        button.grid(column=2, row = 4)    
        
        
    def aliasFastKey(self):
        root.bind('<Return>', lambda _event: PredictNote(self.mainframe, self.Log, self.audio_path, self.prog_bar))

        
if __name__ == "__main__":
    root = tk.Tk()
    CFP_GUI(root)
    root.mainloop()
        
        
        
        
        
        
       
