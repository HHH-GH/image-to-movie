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

command -v "${IM_CONVERT}"  >/dev/null 2>&1 || { echo >&2 "ERROR: ImageMagick convert command is not available. Is ImageMagick installed properly? Is the .env file set correctly?"; exit 1; }
command -v "${IM_IDENTIFY}"  >/dev/null 2>&1 || { echo >&2 "ERROR: ImageMagick identify command is not available. Is ImageMagick installed properly? Is the .env file set correctly?"; exit 1; }
command -v "${IM_MAJICK}"  >/dev/null 2>&1 || { echo >&2 "ERROR: ImageMagick majick command is not available. Is ImageMagick installed properly? Is the .env file set correctly?"; exit 1; }
command -v "${FF_FFMPEG}"  >/dev/null 2>&1 || { echo >&2 "ERROR: FFmpeg ffmpeg command is not available. Is FFmpeg installed properly? Is the .env file set correctly?"; exit 1; }

# 3. Set program defaults

# Folder locations
readonly IMG_SOURCE_DIR='./source'
readonly IMG_OUTPUT_DIR='./output'
readonly IMG_TEST_SOURCE_DIR='./test'

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

	echo -ne "$menu_options\t"
	
}


#######################################
# Make the images into a movie.
# Globals:
#	None
# Arguments:
#	make_img_src_dir
#	make_img_output_dir
#	make_vid_output_width
#	make_vid_output_height
#	make_vid_output_fps
# Outputs:
#	Takes the images in make_img_src_dir
#	Resizes them on a canvas that is
#	make_vid_output_width × 
#	make_vid_output_height
#	and saves each image into 
#	make_img_output_dir/tmp
#	Then combines those images into a
#	video at make_vid_output_fps that is 
#	saved in make_img_output_dir
#	Finishing by deleting 
#	make_img_output_dir/tmp and the images
#	inside it
#######################################


images_to_movie(){

	# Make sure there are 5 arguments
	# https://stackoverflow.com/questions/18568706/check-number-of-arguments-passed-to-a-bash-script
	if [ "$#" -ne 5 ]; then 
		echo -e "\n\tError: All five parameters are required" >&2
		return
	fi
	
	# Names for the arguments
	local make_img_src_dir=$1
	local make_img_output_dir=$2
	local make_vid_output_width=$3
	local make_vid_output_height=$4
	local make_vid_output_fps=$5

	# Set the temp location for the image processing
	local make_img_output_tmp_dir="$make_img_output_dir/tmp"

	# First test - echo out the variables
	# TODO(HHH-GH): replace this with a message about the image to movie process and what's about to happen
	echo -e "\tImages source directory: ......... '${make_img_src_dir}'"
	echo -e "\tMovie output directory: .......... '${make_img_output_dir}'"
	echo -e "\tOutput temporary directory: ...... '${make_img_output_tmp_dir}'"
	echo -e "\tMovie output width: .............. '${make_vid_output_width}'"
	echo -e "\tMovie output height: ............. '${make_vid_output_height}'"
	echo -e "\tMovie output frames per second: .. '${make_vid_output_fps}'\n"
	
	# TODO(HHH-GH): everything under here, including the 
	# part about Safely Handling pathnames and filenames in 
	# shell https://dwheeler.com/essays/filenames-in-shell.html 
	
	# Look for files in make_img_src_dir and then 
	# 1. Loop through, resize/etc, save to the tmp location
	# 2. Use the files in the tmp location to make a movie
	#	 and save the movie in the output location
	# 3. Delete the tmp files and folder
	# 4. Print a success message that says the name of the 
	#	 output file
	
	
	# 1.
	# Loop through the files in make_img_src_dir, resizing and 
	# positioning on a canvas that is sized 
	# 'make_vid_output_width × make_vid_output_height'
	# and then save each of the images into make_img_output_tmp_dir
	# To show that something is happening, print a . every $i % 5
	# or something like that
	
	# 2.
	# Make a movie from those files using make_vid_output_fps
	# Movie name like this, with timestamp and fps and size tags so they're unique 
	# e.g. `202209161139_8fps_720w_720h.mp4`
	
	# 3.
	# Delete make_img_output_tmp_dir and the files inside
	# Keep the folder, only delete JPG files?
	# Delete only JPG files, then delete the folder only if it is empty
	
	# 4.
	# Print a success message
	
}

#######################################
# Show default settings.
# Globals:
# 	IMG_SOURCE_DIR
#	IMG_OUTPUT_DIR
#	IMG_TEST_SOURCE_DIR
#	VID_OUTPUT_WIDTH 
#	VID_OUTPUT_HEIGHT
#	VID_OUTPUT_FPS
# Arguments:
#	None
# Outputs:
#	Writes default settings to screen
#######################################
function print_default_settings(){
	
	echo -e "\n\tProgram default settings"
	echo -e "\t~~~~~~~~~~~~~~~~~~~~~~~~\n"
	echo -e "\tImages source directory: ........ '${IMG_SOURCE_DIR}'"
	echo -e "\tMovie output directory: ......... '${IMG_OUTPUT_DIR}'"
	echo -e "\tImages test source directory: ... '${IMG_TEST_SOURCE_DIR}'"
	echo -e "\tMovie output width: .............. '${VID_OUTPUT_WIDTH}'"
	echo -e "\tMovie output height: ............. '${VID_OUTPUT_HEIGHT}'"
	echo -e "\tMovie output frames per second: .. '${VID_OUTPUT_FPS}'\n"
	
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
	
	echo -e "\n\tImageMagick and FFmpeg versions"
	echo -e "\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
	# ImageMagick version
	echo -en "\tImageMagick version: "
	"${IM_MAJICK}" -version | sed -n "s/Version: ImageMagick \([-0-9.]*\).*/\1/p;"
	
	# FFmpeg version
	# -n means echo without trailing newline
	echo -en "\tFFmpeg version: "
	"${FF_FFMPEG}" -version | sed -n "s/ffmpeg version \([-0-9.]*\).*/\1/p;"
	
	echo -e "\n"
}


#######################################
# Quit the program
# Globals:
#	None
# Arguments:
#	None
#######################################
function quit_program(){
	
	echo -en "\n\tQUITTING"

	sleep .3
	echo -en "."
	sleep .3
	echo -en "."
	sleep .3
	echo -en "."
	sleep .3
	
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
						
			# Call the make movie function, passing in the default variables as parameters
			# Must be in this order
			# images_to_movie ${IMG_SOURCE_DIR} ${IMG_OUTPUT_DIR} ${VID_OUTPUT_WIDTH} ${VID_OUTPUT_HEIGHT} ${VID_OUTPUT_FPS}
									
			# Call the make movie function, passing in the default variables
			images_to_movie ${IMG_SOURCE_DIR} ${IMG_OUTPUT_DIR} ${VID_OUTPUT_WIDTH} ${VID_OUTPUT_HEIGHT} ${VID_OUTPUT_FPS}
			
		elif [[ "${menu_input}" == "s" ]]; then
			
			# Show the default settings
			print_default_settings
			
		elif [[ "${menu_input}" == "o" ]]; then
		
			echo -e "\n\tMaking movie from images with options to override defaults"
			
			# TODO(HHH-GH): make this so you can choose to use the default or override them
			# Assign the defaults to variables
			local make_img_src_dir=${IMG_SOURCE_DIR}
			# local make_img_output_dir=${IMG_OUTPUT_DIR} # no this is fixed
			local make_vid_output_width=${VID_OUTPUT_WIDTH} 
			local make_vid_output_height=${VID_OUTPUT_HEIGHT}
			local make_vid_output_fps=${VID_OUTPUT_FPS}
			
			# TODO(HHH-GH): some checks to make sure the provided options are not ridiculous
			# e.g. the width and height aren't above Xpx
			# e.g. the fps isn't like 0.0000001fps 
			# Set those as constants i.e MAX_FPS MAX_VID_OUTPUT_WIDTH
			# return if no good
			
			# Call the make movie function, passing in those variables			
			images_to_movie ${make_img_src_dir} ${make_img_output_dir} ${make_vid_output_width} ${make_vid_output_height} ${make_vid_output_fps}
			
		
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