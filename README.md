# Collection of Praat batch scripts
All scripts are modified already existing scripts. Many of them were originally build by [Mietta Lennes](https://lennes.github.io/spect/).

## Overview of scripts and modifications

### Batch_GUI_Trier_Data.praat

**Description:**

The script enables you to extract duration, pitch, intensity (minimum, maximum and mean) and the Formant numbers (f1, f2, f3, f4) from all labeled triers

**Modifications:**
* A GUI where you can select information you want to extract
* the possibility to collect all data (duration, pitch, intensity, Formant numbers) within one script
* intensity settings were being set to the default intensity settings in version 6021
* intensity averaging method can be changed in the GUI

### Batch_save_marked_fragments

**Description:**

*Batch_save_marked_fragments* opens all audio files within a directory and finds the corresponding TextGrid in another folder and generates a .wav file for each labeled TextGrid

**Modifications:**
* Saving the marked sequence in the TextGrid as a separate sound file

### Batch_save_marked_fragments

**Description:**

The script generates a new TextGrid for each audio file and automatically loads new audio if your done with the transcription/cutting.

**Modifications:**
* Move audio files you are done with into a subfolder (so you can pick up your work easily if you were interrupted, because your project folder only contains the audio files you haven't been working on because of the feature)
* The ability to skip audio files within the GUI 
