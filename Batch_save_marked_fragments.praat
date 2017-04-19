###############################################################################################
# @name Batch_save_marked_fragments.praat
# @description This script opens all audio files within a directory and finds the corresponding TextGrid in another folder and generates a .wav file for each labeled TextGrid
# @author Pol van Rijn
# @credits Dan McCloy, Mietta Lennes and to all snippets taken from the web!
# @version 0.02
###############################################################################################

form Set settings
	comment Directory of sound files. Be sure to include the final "/"
	text sound_directory C:\Test\audio\
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files. Be sure to include the final "/"
	text textGrid_directory C:\Test\
	comment Directory of resulting audio files:
	text sound_path C:\Test\fragmenten\

endform

textGrid_file_extension$ = ".TextGrid"
tier = 1

# Make a listing of all the sound files in a directory:
Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings


# Open each sound file in the directory:
for ifile to numberOfFiles
	filename$ = Get string... ifile
	Read from file... 'sound_directory$''filename$'

	# get the name of the sound object:
	soundname$ = selected$ ("Sound", 1)

	# Look for a TextGrid by the same name:
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"

	# if a TextGrid exists, open it and do the analysis:
	if fileReadable (gridfile$)
		Read from file... 'gridfile$'

		select TextGrid 'soundname$'
		numberOfIntervals = Get number of intervals... tier

		# Pass through all intervals in the designated tier, and if they have a label, do the analysis:
		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			if label$ <> ""
				# duration:
				start = Get starting point... tier interval
				end = Get end point... tier interval
				
				# save wav files!!!
				select Sound 'soundname$'
				Extract part... start end rectangular 1 noExtract part... start end no
				export_path$ = "'sound_path$''label$'.wav"
				Write to WAV file... 'export_path$'
				Remove
				# select the TextGrid so we can iterate to the next interval:
				select TextGrid 'soundname$'
			endif
		endfor
		# Remove the TextGrid, Formant, and Pitch objects
		select TextGrid 'soundname$'
		Remove
	endif
	# Remove the Sound object
	select Sound 'soundname$'
	Remove
	# and go on with the next sound file!
	select Strings list
endfor

# When everything is done, remove the list of sound file paths:
Remove