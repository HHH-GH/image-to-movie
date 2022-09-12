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
command -v "$FF_FFMPEG"  >/dev/null 2>&1 || { echo >&2 "ERROR: FFmpeg ffmpeg command is not available. Is ImageMagick installed properly? Is the .env file set correctly?"; exit 1; }

# 3. Set program defaults TO-DO



# 4. The actual program TO-DO