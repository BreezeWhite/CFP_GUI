# Music Visualization Project


This is the program of music visualization project, based on the CFP study.

The program is written in processing language, which is a kind of library build on java.
You can learn more on [processing](https://processing.org/).

For running the program, you need first run the CFP GUI program. Follow the instructions inside the folder first.
1. Go to the official processing website, download and install the processing IDE
1. There should be one ouput file which name is the same as the input audio after running the CFP_GUI program.
2. Put the file under the same folder, and modify the variable at line 30, 31 inside musicvisulization.pde to the file needed, 
including the original audio and the prediction file just generated.

```
29. ...
30. String[] music_path = "path_to_original_audio.wav";
31. String[] pred_path = "path_to_prediction_of_the_audio.txt";
32. ...
```


And finally, pressed run, then enjoy the performance^^

- - -

Below are elements used in this project
- Keyboard
![](./images/keyboard.png)

- Ripples
![](./images/ripple.png)

- Embolus
![](./images/embolus.png)

- Wave form
![](./images/wave_form.png)

- Auto painting

![](./images/auto_painting.png)

The demo video:
https://youtu.be/O-dhdPgN_Yk
