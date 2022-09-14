# Helper scripts and commands to copy-paste

## Renaming the files

- Our script is going to expect the files to be orderd by the filename because I don’t know if Bash scripts can sort by Date Taken EXIF metadata
- We want it to be something like `00001.jpg`, `00002.jpg` (not `Picture (123).jpg`, `DSC_3444.jpg`, etc.)

### How to

See [Renaming files in sequential order](https://answers.microsoft.com/en-us/windows/forum/all/renaming-files-in-sequential-order/c8ebbb03-1ba5-4441-9979-b1a5b38bdc23)

1. In Windows File Explorer, sort by Date Taken, in ascending order
2. Select all the files
3. Right-click the first one and choose Rename
4. Rename as `(10001).jpg`, and that pattern will be applied to all the files e.g. `(10002).jpg`, `(10003).jpg` and so on
5. Copy the renamed files into the `source` folder

TBD: is a filename with brackets in it going to break the Bash script.
