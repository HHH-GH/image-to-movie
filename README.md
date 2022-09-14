# Image to Movie

## What is it

The main reason for writing this is to combine all ~2,000 of Little H’s selfies into a timelapse video.

## What is the status

Just getting started, really. (2022/09/13)

## What is the plan

- Copy all ~2,000 of Little H’s selfies from my phone
- Use Windows File Browser to sort them by "Date Taken"
- Rename them all like `0001.JPG`, `0002.jpg` because FFmpeg/ImageMagick probably won’t like files with spaces, and I’m not sure if Bash scripts can use EXIF metadata to sort by "Date Taken". (If this can be scripted there will be notes/commands in `helper-scripts-copy-paste.md`)
- Copy all the photos into a folder named `source` or suchlike.
- Run the script on the photos in that folder, resulting in an MP4 video saved in a folder named `output` or suchlike

## What is the eventual result

- Do something useful with the ~2,000 or so selfies i.e. show how much Little H has grown during the preceding 3 years.
- An entertaining video?
- Code can be reused on non-selfie photosets.

## How to
- To have landscape- and portrait-oriented photos in the same movie, we’ll make it a square movie with the photos centered horizontally and vertically, with a black background/letterboxing.
- It’s going be a Bash script because I’ve got some Bash scripts that already do something similar.
- ~~Default variables like frames per second, video width/height, etc, should be read in from a `.env` file.~~
- Default variables like frames per second, video width/height, etc, are set in `make-movie-from-images.sh`; an `.env` file is available to customise the paths to ImageMagick/FFmpeg exe files should they not be in the system `PATH` or default location.
- Run the script and pass in extra variables to override defaults if desired e.g. `./make-movie-from-images fps=1 vid_w=720 vid_h=720` or write a little menu that allows keyboard input to accept or change the default values. (So a regular landscape-oriented video could be produced from images that are all landscape-oriented)

## Program flow
- Read in the `.env` variables.
- Check that ImageMagick and FFmpeg are available.
- Loop through all the images in `source`. [1]
- Resize and position each of .them in the square canvas of the video [1]
- Add into the eventual movie.

### [1]
For each of the images, decide
- Is it portrait- or landscape-oriented: `img_width > img_height`?
- How wide or how tall it should be: if it's portrait-oriented, it is proportionally resized to `video_height` tall; if it is landscape-oriented it is proportionally resized to `video_width` wide.
- Should it be cropped at all? (not by default) [2]
- The values to center it vertically and horizontally: `x_pos = (video_width - photo_width) / 2`, `y_pos = (video_height - photo_height) / 2`

### [2]
**About cropping**
- Cropping might be helpful to put more focus on the center of the each image.
- Cropping might be useful to make a 4:3 aspect ratio video from 16:9 aspect ratio photos (or vice-versa)
- Not essential to the initial version
- Might be used when the image width/height isn't divisible by 2, as I guess the `x_pos` and `y_pos` will need to be whole numbers

## Dependencies / Requirements
- ImageMagick (resizing photos, maybe some colour processing)
- FFmpeg (combining the photos into a movie)
- Some sort of Bash shell
- Remember to `chmod+x` on `make-movie-from-images.sh`

## Next steps
- Start coding it up, starting with program defaults.
