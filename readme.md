## EAGLEView app

**Now open source. Collaborators welcome.**

I have come to the conclusion that I simply do not have enough time to finish the EAGLEView app by myself. So I have decided to release the app as open source so everyone can download the source and build it.

Also, people are welcome (more than welcome, in fact) to contribute to the project.

The app is not finished but lots of functionality is already in place. These features already work:

- Display schematic and board files. EAGLE version 6 or higher.
- Open .sch or .brd file from Dropbox
- Open files by clicking links to .sch, .brd or .zip files (the zip file will be extracted and scanned for .sch and .brd files)
- Pan and zoom
- Click component to see details
- Search for specific components by name or value
- Show/hide individual layers
- Support for multiple modules

There is also some stuff that is not yet implemented. Among these are:

- Ploygon pours. (At the moment, the entire polygon will be filled completely.)
- Need to speed up drawing routines to avoid flickering when redrawing.
- Support for multiple sheets
- Different shapes for SMD pads
- Get the zoom-to-fit working properly
- And other stuff – refer to the `todo.txt` file

Remember, the app is read-only. You can't modify the schematics or boards. And it requires iOS 8.

### How to build

1. Get the code and open in the most recent Xcode.
2. Configure the project to use an appropriate bundle ID. You can either change the value directly in the `EAGLEView-Info.plist` file or you can change the value of the custom build setting named `BUNDLE_ID` (Project info -> Build Settings -> scroll down to the bottom).
3. Run. You do need to be enrolled in Apple's iOS Developer Program in order to run the app on a device.

### How to contact me

Mail me at <jenswilly@gmail.com>.

### How to contribute

Just like any other GitHub project:

1. Fork the repository.
2. Make the fix.
3. Submit a pull request to me.

### More info

I will be posting updates on my website: <http://jenswilly.dk>.
