#!/bin/bash
# make-movie-from-images
# 1. Load the .env file
# 2. Check the ImageMagick and FFmpeg commands are available
# 3. Set the program defaults
# 4. The actual program


# 1. Load the .env file
# https://gist.github.com/mihow/9c7f559807069a03e302605691f85572
if [ ! -f .env ]
then
	# there is no .env
	echo -e "\nERROR: No .env file" # -e flag makes echo interpret backslash characters
	echo -e "\nUse .env.sample to make a .env file"
	exit 1
else
	# Read in from .env
	# https://stackoverflow.com/a/30969768/179329
	set -o allexport
	source .env
	set +o allexport
fi


# 2. Check that the required ImageMagick and FFmpeg commands are available and set from the .env
# "$IM_CONVERT" = convert in ImageMagick
# "$IM_IDENTIFY" = identify in ImageMagick
# "$IM_MAJICK" = majick in ImageMagick
# "$FF_FFMPEG" = ffmpeg in FFmpeg

command -v "$IM_CONVERT"  >/dev/null 2>&1 || { echo >&2 "ERROR: ImageMagick convert command is not available. Is ImageMagick installed properly? Is the .env file set correctly?"; exit 1; }
command -v "$IM_IDENTIFY"  >/dev/null 2>&1 || { echo >&2 "ERROR: ImageMagick identify command is not available. Is ImageMagick installed properly? Is the .env file set correctly?"; exit 1; }
command -v "$IM_MAJICK"  >/dev/null 2>&1 || { echo >&2 "ERROR: ImageMagick majick command is not available. Is ImageMagick installed properly? Is the .env file set correctly?"; exit 1; }
command -v "$FF_FFMPEG"  >/dev/null 2>&1 || { echo >&2 "ERROR: FFmpeg ffmpeg command is not available. Is FFmpeg installed properly? Is the .env file set correctly?"; exit 1; }

# 3. Set program defaults

# Folder locations
readonly IMG_SOURCE_DIR='./source'
readonly IMG_OUTPUT_DIR='./output'
readonly IMG_SOURCE_TEST_DIR='./test'

# Output settings
readonly VID_OUTPUT_WIDTH='720' 
readonly VID_OUTPUT_HEIGHT='720'
readonly VID_OUTPUT_FPS='8'

# 4. The actual program TODO(HHH-GH): all of it (printing defaults & versions, quit and clean up, image and movie processing)

#######################################
# Print the menu options.
# Globals:
# 	None
# Arguments:
#	None
# Outputs:
#	Writes menu to screen
#######################################
function print_program_menu(){

	local menu_options

	menu_options="
	
	Make movie from images
	~~~~~~~~~~~~~~~~~~~~~~
	
	Choose an option and press Enter:
	
	m  Make movie from images according to defaults
	s  Show default settings
	o  Make movie from images with options to override defaults
	v  Show which versions of ImageMagick and FFmpeg are being used
	t  Make a test movie with the test images
	q  Quit

"

	echo "$menu_options"
	
}


#######################################
# Show default settings.
# Globals:
# 	IMG_SOURCE_DIR
#	IMG_OUTPUT_DIR
#	IMG_SOURCE_TEST_DIR
#	VID_OUTPUT_WIDTH 
#	VID_OUTPUT_HEIGHT
#	VID_OUTPUT_FPS
# Arguments:
#	None
# Outputs:
#	Writes default settings to screen
#######################################
function print_default_settings(){
	# TODO(HHH-GH): actually print them
	echo -e "\n\tShowing default settings"
}


#######################################
# Show versions of ImageMagick and 
# FFmpeg.
# Globals:
#	IM_MAGICK
# 	FF_FFMPEG
# Arguments:
#	None
# Outputs:
#	Results of version check on the
#	two executables
#######################################
function print_program_versions(){
	# TODO(HHH-GH): actually print them
	echo -e "\n\tShowing which versions of ImageMagick and FFmpeg are being used"
}


#######################################
# Quit the program
# Globals:
#	IM_MAGICK
# 	FF_FFMPEG
# Arguments:
#	None
#######################################
function quit_program(){
	# TODO(HHH-GH): unset the constants and program default variables
	echo -e "\n\tQUITTING"
}


# The workings of the program are wrapped in a main function
function main(){
	
	# Use a while loop to read menu input and call functions based on the input
	while true; do
	
		# Print out the program menu
		print_program_menu

		# Get the input
		read menu_input
		
		# Call the function that matches the input menu choice
		
		if [[ "${menu_input}" == "m" ]]; then
		
			echo -e "\n\tMaking movie from images according to defaults"
			
		elif [[ "${menu_input}" == "s" ]]; then
			
			# Show the default settings
			print_default_settings
			
		elif [[ "${menu_input}" == "o" ]]; then
		
			echo -e "\n\tMaking movie from images with options to override defaults"
		
		elif [[ "${menu_input}" == "v" ]]; then
		
			# Show the versions of ImageMagick and FFmpeg that are installed
			print_program_versions
		
		elif [[ "${menu_input}" == "t" ]]; then
		
			echo -e "\n\tMaking a test movie with the test images"
			
		elif [[ "${menu_input}" == "q" ]]; then
			
			# Quit program
			quit_program
			break
		fi
	
	done
}

# Run the program
main