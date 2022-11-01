# Image to Movie

## What is it

The main reason for writing this is to combine all ~2,000 of Little H’s selfies into a timelapse video.

## What is the status

The basic skeleton of the program flow is complete. Now working on the program functions (2022/10/09)

## What is the plan

1. Copy all ~2,000 of Little H’s selfies from my phone
2. Use Windows File Browser to sort them by "Date Taken"
3. Rename them all like `0001.JPG`, `0002.jpg` because: 
	- FFmpeg/ImageMagick probably won’t like files with spaces
	- I don’t want to add padding 0s for ordering if there’s 1,000 files (`File (1).jpg`, `File (10).jpg`, `File (11).jpg`,`File (1000).jpg` etc would all get done before `File (2).jpg`), and 
	- I’m not sure if Bash scripts can use EXIF metadata to sort by "Date Taken", and I need the images to be in a specific order. 
	- If the file renaming can be scripted there will be notes/commands in `helper-scripts-copy-paste.md`, or at least a description of the easiest way to do it
4. Copy all the renamed photos into a folder named `source` or suchlike.
5. Run the script on the photos in that folder, resulting in an MP4 video saved in a folder named `output` or suchlike

## What is the eventual result

- Do something useful with the ~2,000 or so selfies i.e. show how much Little H has grown during the preceding 3 years.
- An entertaining video?
- Code can be reused on non-selfie photosets.

## How to

- To have landscape- and portrait-oriented photos in the same movie, we’ll make it a square movie with the photos centered horizontally and vertically, with a black background/letterboxing.
- It’s going be a Bash script because I’ve got some Bash scripts that already do something similar.
- Default variables like frames per second, video width/height, etc, are set in `make-movie-from-images.sh`; an `.env` file is available to customise the paths to ImageMagick/FFmpeg exe files should they not be in the system `PATH` or default location.
- Maybe offer the option to have an env/config file for default variables? Then they could be customised per install, and the script could still be synced/updated from GitHub if there are updates.
- Run the script and use a little menu that allows keyboard input to tell it what to do. Options: process the images using the default settings; show the default settings; process the images after allowing a change to any of the default settings (so a regular landscape-oriented video could be produced from images that are all landscape-oriented by setting the output to be 720 wide and 405 tall); show the software versions; Quit. 

## Main program flow

- Read in the `.env` variables.
- Check that ImageMagick and FFmpeg are available.
- Loop through all the images in `source`. [1]
- Resize and position each of them in the square canvas of the video [1]
- Add into the eventual movie.

### [1]

For each of the images, decide
- Is it portrait- or landscape-oriented: `img_width > img_height`?
- How wide or how tall it should be: if it's portrait-oriented, it is proportionally resized to `video_height` tall; if it is landscape-oriented it is proportionally resized to `video_width` wide.
- Should it be cropped at all? (not by default) [2]
- The values to center it vertically and horizontally: `x_pos = (video_width - photo_width) / 2`, `y_pos = (video_height - photo_height) / 2`

### [2]

**About cropping**
- Cropping might be helpful to put more focus on the center of each image.
- Cropping might be useful to make a 4:3 aspect ratio video from 16:9 aspect ratio photos (or vice-versa)
- Not essential to the initial version
- Might be used when the image width/height isn't divisible by 2, as I guess the `x_pos` and `y_pos` will need to be whole numbers

## Additional program options

**As in Main program flow but,**  
- Have an option to overide defaults
- Have an option to show the defaults
- Have an option to show the versions of FFmpeg/ImageMagick

## Dependencies / Requirements

- ImageMagick (resizing photos, maybe some colour processing)
- FFmpeg (combining the photos into a movie)
- Some sort of Bash shell
- Remember to `chmod+x` on `make-movie-from-images.sh`

## Tests

- There’s a folder called 'test' and inside it are eight images in a variety of sizes and orientations, each with a number. (These were force-added)
- Use those images to test everything works. If it all works you’ll get a short movie with all eight images.

### Test image sizes

1024x576—16:9 aspect ratio  
1024x768—4:3 aspect ratio  
400x400—1:1 aspect ratio, smaller than the canvas  
800x700—strange size  
768x1024—3:4 aspect ratio  
576x1024—9:16 aspect ratio  
700x800—strange size  
1024x1024—1:1 aspect ratio, larger than the canvas  

## Resources to use while making it

### Safely Handling pathnames and filenames in shell 
https://dwheeler.com/essays/filenames-in-shell.html  
Especially prepending ./ and the for loops, and stripping/prepending something when a path/filename starts with `-`  

### Prevent directory traversal in bash script 
https://stackoverflow.com/questions/62576599/prevent-directory-traversal-vulnerability-in-bash-script  
When a directory name could be passed in to the script

**Idea:** How about making it so the output directory is fixed, and the movies are output with timestamp and fps and size tags so they're unique e.g. `202209161139_8fps_720w_720h.mp4`. Then we don't have to worry that the script might output files into a random/bad location on the computer. Then it doesn't matter if the source directory is random/bad either, because the script will only get jpgs (?)

### Delete JPG files in tmp
https://superuser.com/questions/902064/how-to-recursivly-delete-all-jpg-files-but-keep-the-ones-containing-sample
https://superuser.com/questions/654416/is-the-rm-buildin-gnu-command-case-sensitive

### Suppress an error message if trying to delete a directory that is not empty
https://unix.stackexchange.com/questions/387048/why-does-rmdir-p-ignore-fail-on-non-empty-fail-when-encountering-home

### Check the number of arguments passed to a bash script
https://stackoverflow.com/questions/18568706/check-number-of-arguments-passed-to-a-bash-script

### Style guide for shell scripts
https://google.github.io/styleguide/shellguide.html#s7-naming-conventions  

### Printing version numbers
FFmpeg/general approach: https://stackoverflow.com/questions/54363923/finding-ffmpeg-installed-version  

### Time-lapse videos
[Build a Raspberry Pi time-lapse rig](https://reprage.com/post/how-to-build-a-raspberry-pi-time-lapse-rig)  
[Creating a time-lapse video ... with ffmpeg](https://medium.com/@sekhar.rahul/creating-a-time-lapse-video-on-the-command-line-with-ffmpeg-1a7566caf877)

### Random
- [Formatting dates for display 1](https://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/)
- [Formatting dates for display 2](https://unix.stackexchange.com/questions/428217/current-time-date-as-a-variable-in-bash-and-stopping-a-program-with-a-script)
- [Echo with no trailing newline](https://stackoverflow.com/questions/38021348/how-can-i-echo-out-things-without-a-newline)


## Next steps
Continue coding it up, next is the actual images to movie parts.
- It's basically finished?
- Need to do the function where the settings can be changed from the defaults
- Need to go through and check what else I missed
- Need to do the settings and checks and hints for max/min video dimensions, max/min fps, etc
- Should the image_to_movie function echo out the settings it is using? (Yes?)
- Image filename sanitation (doesn't begin with -, doesn't include ../, ...)
- The option to supply different settings for a single run (first do the settings and checks and hints for max/min video dimensions, max/min fps, etc)

Then tidy/refactor/check
- Make an error printing function to standardise those https://google.github.io/styleguide/shellguide.html#stdout-vs-stderr
- Refactor if needed e.g. option for overriding some of the default settings in the .env file (have certain settings at the top as readonly, other settings are set in the main file but could be overwritten when the .env file is loaded further down, make it so the .env file is not strictly necessary?)
