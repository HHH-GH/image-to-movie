#!/bin/bash
# make-movie-from-images
# 1. Load the .env file
# 2. Check the ImageMagick and FFmpeg commands are available
# 3. Set the program defaults
# 4. The actual program


# 1. Load the .env file
# https://gist.github.com/mihow/9c7f559807069a03e302605691f85572
if [[ ! -f .env ]]; then
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
# "$IM_MAGICK" = majick in ImageMagick
# "$FF_FFMPEG" = ffmpeg in FFmpeg

command -v "${IM_CONVERT}"  >/dev/null 2>&1 || { echo >&2 "ERROR: ImageMagick convert command is not available. Is ImageMagick installed properly? Is the .env file set correctly?"; exit 1; }
command -v "${IM_IDENTIFY}"  >/dev/null 2>&1 || { echo >&2 "ERROR: ImageMagick identify command is not available. Is ImageMagick installed properly? Is the .env file set correctly?"; exit 1; }
command -v "${IM_MAGICK}"  >/dev/null 2>&1 || { echo >&2 "ERROR: ImageMagick majick command is not available. Is ImageMagick installed properly? Is the .env file set correctly?"; exit 1; }
command -v "${FF_FFMPEG}"  >/dev/null 2>&1 || { echo >&2 "ERROR: FFmpeg ffmpeg command is not available. Is FFmpeg installed properly? Is the .env file set correctly?"; exit 1; }

# 3. Set program defaults

# TODO(HHH-GH): this?
# https://dwheeler.com/essays/filenames-in-shell.html
# 3.2 Set IFS to just newline and tab at the start of each script
# IFS means the Field Separators
# Setting it to just \n (new lines) and \t (tab) means that the script
# should be able to handle file names with spaces in them
# With this setting, though, any arguments passed to commands as flags
# won't be separated on the space and won't work
# e.g. -unsharp 0.5x0.5+0.5x0.5+0.008 
# - The 0.5x0.5 etc would be counted as part of the -h
IFS="$(printf '\n\t')"


# Folder locations
readonly IMG_SOURCE_DIR='./source'
readonly IMG_OUTPUT_DIR='./output'
readonly IMG_TEST_SOURCE_DIR='./test'

# Temp file that holds a list of processed images to make into a movie
# Holds a list of images to concatenate into a movie
# https://trac.ffmpeg.org/wiki/Concatenate
# Created during processing
# Gets deleted during clean up
readonly PROCESSED_IMG_FILE_LIST='list.txt'

# Output settings
readonly VID_OUTPUT_WIDTH='720' 
readonly VID_OUTPUT_HEIGHT='720'
readonly VID_OUTPUT_FPS='12'

# Image quality and processing settings
#readonly IMG_PROCESSING_UNSHARP="-unsharp 0.5x0.5+0.5+0.008"
readonly IMG_PROCESSING_UNSHARP="0.5x0.5+0.5+0.008"				# used like -unsharp "${IMG_PROCESSING_UNSHARP}"
readonly IMG_PROCESSING_CONTRAST="1x50"							# -sigmoidal-contrast "${IMG_PROCESSING_CONTRAST}"
readonly IMG_PROCESSING_COLORSPACE="sRGB"						# -colorspace "${IMG_PROCESSING_COLORSPACE}"
readonly IMG_PROCESSING_JPG_QUALITY="100"						# -quality "${IMG_PROCESSING_COLORSPACE}"
readonly IMG_PROCESSING_INTERPOLATE="bilinear"					# -interpolate "${IMG_PROCESSING_INTERPOLATE}" Colour sampling when sized down bilinear or catrom (bicubic)
readonly IMG_PROCESSING_SATURATION="100,120,100"				# -modulate "${IMG_PROCESSING_SATURATION}" The middle number is the saturation i.e. 120 = 20%

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
	if [[ "$#" -ne 5 ]]; then 
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
	
	# Name of the output file
	make_vid_output_filename=$( date +%Y%m%d%H%M )

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
		
	# A status message
	echo -en "\n\t1/3: Resizing images\n"
	
	# Get all the jpgs	
	# This gets the file name of the image, without the folder name
	local img_arr=(`ls ${make_img_src_dir} | grep -i '.jpg'`)
	local img_count=${#img_arr[*]}
	
	# Are there any images to process
	if [[ ! "${img_count}" -gt 0 ]]; then
		echo -e "\n\tError: No JPG images found in '${make_img_src_dir}'"
		return
	fi
	
	# Make the tmp directory for the images
	mkdir -p "${make_img_output_tmp_dir}"  # -p means that it doesn't write an error if the folder exists
	
	# Loop through img_arr and process the files	
	
	local i=1
	for infile in ${img_arr[*]}; do
		
		#TODO(HHH-GH): check that the file name doesn't start with -
		# (Or it will be interpreted as an argument in the image magick function)
		
		# An indent for the dots, and the first dot
		if [[ ${i} -eq 1 ]]; then
			echo -en "\t."
		fi
		
		# Print a dot every N images
		local images_per_dot=5
		if [[ $( expr ${i} % ${images_per_dot} ) -eq 0 ]]; then
			echo -en "."
		fi
		
		# Detect image size
		# -quiet so it doesn't give warnings
		# Put the src dir in front of the image name "${make_img_src_dir}"/"${infile}"
		#local source_image_width=$("${IM_IDENTIFY}" -quiet -format "%w" "${make_img_src_dir}"/"${infile}")
		#local source_image_height=$("${IM_IDENTIFY}" -quiet -format "%h" "${make_img_src_dir}"/"${infile}")
		
		# Write the string for the resize part		
		# What should happen here
		# The image should maintain it's proportions and aspect ratio
		# Can't be wider than VID_OUTPUT_WIDTH
		# Can't be taller than VID_OUTPUT_WIDTH
		# According to www.imagemagick.org/Usage/resize/
		# If the resize string is VID_OUTPUT_WIDTHxVID_OUTPUT_HEIGHT\>		
		# this will happen automatically, and the image will only be resized
		# if it is larger than those dimensions (that's the \> part)
		# The image is saved in $make_img_output_tmp_dir
		# The image name is converted to lower case for convenience in our glob match later
		
		#TODO(HHH-GH): figure out how to pass the unsharp arguments/etc as variables
		
		# Lower case the file name for convenience in our glob match later
		# the ,, part works in Bash 4
		local lowercase_infile="${infile,,}"
			
		
		"${IM_CONVERT}" -quiet \
		"${make_img_src_dir}"/"${infile}" \
		-auto-orient \
		-resize "${make_vid_output_width}"x"${make_vid_output_height}"\> \
		-unsharp "${IMG_PROCESSING_UNSHARP}" \
		-sigmoidal-contrast "${IMG_PROCESSING_CONTRAST}" \
		-colorspace "${IMG_PROCESSING_COLORSPACE}" \
		-quality "${IMG_PROCESSING_JPG_QUALITY}" \
		-interpolate "${IMG_PROCESSING_INTERPOLATE}" \
		-modulate "${IMG_PROCESSING_SATURATION}" \
		"${make_img_output_tmp_dir}"/"${lowercase_infile}"
		
		# Increment the counter
		(( i++ ))
	done
	
	# Clean up from processing the images loop
	unset i
	unset img_arr
	unset img_count
		
	
	# 2.
	# Make a movie from those files using make_vid_output_fps
	# Movie name like this, with timestamp and fps and size tags so they're unique 
	# e.g. `202209161139_8fps_720w_720h.mp4`
	
	echo -en "\n\t2/3: Turning the images into a movie\n"
	
	# Are there any processed images to turn into a movie?
	# Get all the jpgs	
	# This gets the file name of the image, without the folder name
	local processed_img_arr=(`ls ${make_img_output_tmp_dir} | grep -i '.jpg'`)
	local processed_img_count=${#processed_img_arr[*]}
	
	# Are there any processed images to turn into a movie
	if [[ ! "${processed_img_count}" -gt 0 ]]; then
		echo -e "\n\tError: No processed JPG images found in '${make_img_output_tmp_dir}'"
		return		
	fi
	
	# Was going to loop through processed_img_arr and make a list of files to process
	# If using concat, the duration of each file should also be set
	# https://ffmpeg.org/ffmpeg-formats.html#concat
	# Duration = 1/fps
	# But bash can't do decimals so we have to do a glob match like before
	# Leaving this comment for reference
	# Globbing not supported on Windows? 
	# Also leaving in this for reference
	# So have to pass it in from a pipe
	
	
	
	# TODO(HHH-GH): the actual steps for making the movie
	# Processing the image steps
	# Might want to put making the black background into the resizing part instead of here
	# or I can create a temp file to use as one of the inputs
	# or the first input is the black background
	# But how to calculate the position?
	# Can I just use a crop and is there an option to center it?
	# https://ffmpeg.org/ffmpeg-filters.html#crop
	# -filter:v "crop=w:h:x:y" or -vf "crop=10:10:0:0"  https://bytexd.com/ffmpeg-how-to-crop-videos-images-using-the-crop-filter/
	# "If x and y are not specified, the command will default to start cropping from the center"
	# "FFmpeg gets the original input video width (iw) and height (ih) values automatically, so you can perform mathematical 
	# operations using those values (e.g. iw/2 for half the input video width, or ih-100 to subtract 100 pixels from the input video height).
	# https://www.linuxuprising.com/2020/01/ffmpeg-how-to-crop-videos-with-examples.html
	#
	# So
	# Draw a box as one input
	# Glob the files as the other input
	# Layer the files on top of the box
	# Scaling to fit the images in
	# https://superuser.com/questions/547296/resizing-videos-with-ffmpeg-avconv-to-fit-into-static-sized-player/1136305#1136305
	
	
	#echo "${FF_FFMPEG}" -framerate "${make_vid_output_fps}" -vcodec mjpeg -pattern_type glob -i "${make_img_output_tmp_dir}"/*.jpg -r 30 -c:v libx264 -crf 17 -pix_fmt yuv420p "${make_img_output_dir}"/test.mp4 -hide_banner -loglevel error
	cat "${make_img_output_tmp_dir}"/*.jpg | "${FF_FFMPEG}" -framerate "${make_vid_output_fps}" -vcodec mjpeg -f image2pipe -i - -vf "scale=${make_vid_output_width}:${make_vid_output_height}:force_original_aspect_ratio=decrease:eval=frame,pad=${make_vid_output_width}:${make_vid_output_height}:-1:-1:color=black" -r 30 -c:v libx264 -crf 17 -pix_fmt yuv420p "${make_img_output_dir}"/"${make_vid_output_filename}".mp4 -hide_banner -loglevel error
		
	# Just draw a box
	#"${FF_FFMPEG}" -i color=c=black:s="${make_vid_output_width}"x"${make_vid_output_height}":r="${make_vid_output_fps}" test.mp4 -hide_banner
	
	echo -en "\n\tMovie saved as '${make_vid_output_filename}.mp4' in '${make_img_output_dir}'\n"
	
	# Clean up from making the movies loop
	unset processed_img_arr
	unset processed_img_count
	unset make_vid_output_filename
	
	
	# 3.
	# Delete make_img_output_tmp_dir and the files inside
	# Keep the folder, only delete JPG files?
	# Delete only JPG files, then delete the folder only if it is empty
	
	echo -en "\n\tCleaning up the temporary files\n"
	
	# Delete JPG files in tmp
	# https://superuser.com/questions/902064/how-to-recursivly-delete-all-jpg-files-but-keep-the-ones-containing-sample
	# https://superuser.com/questions/654416/is-the-rm-buildin-gnu-command-case-sensitive
	# find in the output temporary directory
	# -maxdepth 1 only in that directory and not subdirectories
	# Anything that matches (case-insensitive) '.jpg'
	# and then delete it
	find "${make_img_output_tmp_dir}/" -maxdepth 1 -iname '*.jpg' -delete
	
	# Delete the list of files
	rm -f "${make_img_output_tmp_dir}"/"${PROCESSED_IMG_FILE_LIST}"
	
	# Delete tmp if empty
	# Because we don't want to delete everything by accident
	# Suppress the error message if it is not empty
	# https://unix.stackexchange.com/questions/387048/why-does-rmdir-p-ignore-fail-on-non-empty-fail-when-encountering-home
	rmdir -p --ignore-fail-on-non-empty "${make_img_output_tmp_dir}/"
	
	
	# 4.
	# Print a success message
	# Including the name of the movie and where it is located
	
	echo -en "\n\tFinished!\n"
	
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
	"${IM_MAGICK}" -version | sed -n "s/Version: ImageMagick \([-0-9.]*\).*/\1/p;"
	
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
			images_to_movie ${make_img_src_dir} ${IMG_OUTPUT_DIR} ${make_vid_output_width} ${make_vid_output_height} ${make_vid_output_fps}
			
			echo -e "\n\tTODO: finish this"
		
		elif [[ "${menu_input}" == "v" ]]; then
		
			# Show the versions of ImageMagick and FFmpeg that are installed
			print_program_versions
		
		elif [[ "${menu_input}" == "t" ]]; then
		
			echo -e "\n\tMaking a test movie with the test images"
			
			# Call the make movie function, passing in the default variables as parameters,
			# using the test directory for the source directory
			# Must be in this order
			# images_to_movie ${IMG_SOURCE_DIR} ${IMG_OUTPUT_DIR} ${VID_OUTPUT_WIDTH} ${VID_OUTPUT_HEIGHT} ${VID_OUTPUT_FPS}
									
			# Call the make movie function, passing in the default variables
			images_to_movie ${IMG_TEST_SOURCE_DIR} ${IMG_OUTPUT_DIR} ${VID_OUTPUT_WIDTH} ${VID_OUTPUT_HEIGHT} ${VID_OUTPUT_FPS}
			
		elif [[ "${menu_input}" == "q" ]]; then
			
			# Quit program
			quit_program
			break
		fi
	
	done
}

# Run the program
main