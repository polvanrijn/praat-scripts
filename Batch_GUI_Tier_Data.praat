###################################################################################################################################################
# @name Batch GUI tier data extracter
# @description This script opens all audio files with the corresponding TextGrid. It calculates duration, pitch, intensity (minimum, maximum and mean) and the Formant numbers (f1, f2, f3, f4) of all labled triers. With a GUI you select the data points you are interested in!
# @author Pol van Rijn
# @credits Dan McCloy, Mietta Lennes and to all snippets taken from the web!
# @version 0.01
# @Changelog:
# - Formant numbers implemented, not working properly
# @todo:
# - settings Formant numbers
# - implement min and max
# - implement min, max time
# This script is distributed under the GNU General Public License.
###############################################################################################

form Set settings
	comment Directory of sound files. Be sure to include the final "/"
	text sound_directory C:\Test\audio\
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files. Be sure to include the final "/"
	text textGrid_directory C:\Test\
	comment Path of resulting text file:
	text resultsfile C:\Test\resultsfile.txt
	comment Do you want to select the directories manually?
	boolean manual_directory 0
	comment Duration:
	boolean get_duration 1

	comment Pitch:
	boolean get_min_pitch 0
	boolean get_max_pitch 0
	boolean get_mean_pitch 1

	comment Intensity:
	boolean get_min_intensity 0
	boolean get_max_intensity 0
	boolean get_mean_intensity 1

	comment Formant:
	boolean get_f1 1
	boolean get_f2 1
	boolean get_f3 1
	boolean get_f4 1
endform

if manual_directory
sound_directory$ = chooseDirectory$: "Choose sound directory"
textGrid_directory$ = chooseDirectory$: "Choose TextGrid directory"
# add backslash
sound_directory$ = "'sound_directory$'\"
textGrid_directory$ = "'textGrid_directory$'\"

result_directory$ = chooseDirectory$: "Result directory"
beginPause: "Pitch range (Hertz)"
	text: "result name", "name of the_result_file"
endPause: "Set name for resultsfile", 1
resultsfile$ = "'result_directory$'\'result_name$'.txt"
endif

minimum_pitch = 75
if get_min_pitch or get_max_pitch or get_mean_pitch
beginPause: "Pitch range (Hertz)"
	positive: "Pitch_time_step", 0.01
	positive: "Minimum_pitch", 75
	positive: "Maximum_pitch", 500
	comment: "Pitch analysis parameters"
endPause: "Continue", 1
endif

if get_min_intensity or get_max_intensity or get_mean_intensity
beginPause: "Set intensity parameters"
	comment: "Averaging Method: dB = mean dB, energy = mean energy, sones = mean sones"
	optionMenu: "Averaging Method", 1
        option: "energy"
        option: "dB"
        option: "sones"
 
	comment: "Intensity"
	positive: "Time_step", (0.8/minimum_pitch)
endPause: "Continue", 1
endif

if get_f1 or get_f2 or get_f3 or get_f4
beginPause: "Set Formant parameters"
	positive: "Time_step", 0.01
	integer: "Maximum_number_of_formants", 5
	positive: "Maximum_formant", 5500
	positive: "Window_length", 0.025
	real: "Preemphasis_from", 50
endPause: "Continue", 1
endif

textGrid_file_extension$ = ".TextGrid"
tier = 1

# Make a listing of all the sound files in a directory:
Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Check if the result file exists:
if fileReadable (resultsfile$)
	pause The file 'resultsfile$' already exists! Do you want to overwrite it?
	filedelete 'resultsfile$'
endif

# Create a header row for the result file: (remember to edit this if you add or change the analyses!)
header$ = "Filename	TextGridLabel"
if get_duration
	header$ = "'header$'	duration"
endif

if get_min_pitch
	header$ = "'header$'	min_pitch"
endif

if get_max_pitch
	header$ = "'header$'	max_pitch"
endif

if get_mean_pitch
	header$ = "'header$'	mean_pitch"
endif

if get_min_intensity
	header$ = "'header$'	min_intensity"
endif

if get_max_intensity
	header$ = "'header$'	max_intensity"
endif

if get_mean_intensity
	header$ = "'header$'	mean_intensity"
endif

if get_f1
	header$ = "'header$'	f1"
endif

if get_f2
	header$ = "'header$'	f2"
endif

if get_f3
	header$ = "'header$'	f3"
endif

if get_f4
	header$ = "'header$'	f4"
endif

header$ = "'header$''newline$'"

fileappend "'resultsfile$'" 'header$'

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

		if get_min_intensity or get_max_intensity or get_mean_intensity
			select Sound 'soundname$'
			To Intensity... minimum_pitch time_step yes
		endif
		if get_min_pitch or get_max_pitch or get_mean_pitch
			select Sound 'soundname$'
			To Pitch... pitch_time_step minimum_pitch maximum_pitch
		endif

		if get_f1 or get_f2 or get_f3 or get_f4
			select Sound 'soundname$'
			To Formant (burg)... time_step maximum_number_of_formants maximum_formant window_length preemphasis_from
		endif

		select TextGrid 'soundname$'
		numberOfIntervals = Get number of intervals... tier

		# Pass through all intervals in the designated tier, and if they have a label, do the analysis:
		for interval to numberOfIntervals
			label$ = Get label of interval... tier interval
			if label$ <> ""
				# duration:
				start = Get starting point... tier interval
				end = Get end point... tier interval
				duration = end-start
				# pitch:
				if get_min_pitch or get_max_pitch or get_mean_pitch
					select Pitch 'soundname$'
					if get_min_pitch
						minPitch = Get minimum... start end Parabolic
					endif
					if get_max_pitch
						maxPitch = Get maximum... start end Parabolic
					endif
					if get_mean_pitch
						meanPitch = Get mean: start, end, "Hertz"
					endif
				endif
				# intensity:
				if get_min_intensity or get_max_intensity or get_mean_intensity
					select Intensity 'soundname$'
					if get_min_intensity
						minIntensity = Get minimum... start end Parabolic
						#min_time = Get time of minimum... start end Parabolic
					endif
					if get_max_intensity
						maxIntensity = Get maximum... start end Parabolic
						#max_time = Get time of maximum... start end Parabolic
					endif
					if get_mean_intensity
						# some weird bug... 
						if averaging_Method$ = "energy"
							meanIntensity = Get mean... start end energy
						else
							meanIntensity = Get mean... start end 'averaging_Method$'
						endif
					endif
				endif

				if get_f1 or get_f2 or get_f3 or get_f4
					select Formant 'soundname$'
					if get_f1
						f1 = Get mean... 1 start end Hertz
					endif
					if get_f2
						f2 = Get mean... 2 start end Hertz
					endif
					if get_f3
						f3 = Get mean... 3 start end Hertz
					endif
					if get_f4
						f4 = Get mean... 4 start end Hertz
					endif
				endif

				# Save result to text file:
				resultline$ = "'soundname$'	'label$'"
				if get_duration
					resultline$ = "'resultline$'	'duration'"
				endif
				if get_min_pitch
					resultline$ = "'resultline$'	'minPitch'"
				endif
				if get_max_pitch
					resultline$ = "'resultline$'	'maxPitch'"
				endif
				if get_mean_pitch
					resultline$ = "'resultline$'	'meanPitch'"
				endif
				if get_min_intensity
					resultline$ = "'resultline$'	'minIntensity'"
				endif
				if get_max_intensity
					resultline$ = "'resultline$'	'maxIntensity'"
				endif
				if get_mean_intensity
					resultline$ = "'resultline$'	'meanIntensity'"
				endif
				if get_f1
					resultline$ = "'resultline$'	'f1'"
				endif
				if get_f2
					resultline$ = "'resultline$'	'f2'"
				endif
				if get_f3
					resultline$ = "'resultline$'	'f3'"
				endif
				if get_f4
					resultline$ = "'resultline$'	'f4'"
				endif
				resultline$ = "'resultline$''newline$'"

				fileappend "'resultsfile$'" 'resultline$'

				# select the TextGrid so we can iterate to the next interval:
				select TextGrid 'soundname$'
			endif
		endfor
		# Remove the TextGrid, Formant, and Pitch objects
		select TextGrid 'soundname$'
		if get_min_pitch or get_max_pitch or get_mean_pitch
			plus Pitch 'soundname$'
		endif
		if get_min_intensity or get_max_intensity or get_mean_intensity
			plus Intensity 'soundname$'
		endif
		if get_f1 or get_f2 or get_f3 or get_f4
			plus Formant 'soundname$'
		endif
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