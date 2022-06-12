create_image.sh is a script that creates an image for an Nvidia Jetson SBC. So far, I have only tested it on a jetson nano B01.

Flashing an image:
1. flash the image onto your Jetson's SD card with your favorite flashing software. I like Balena Etcher because it has a great UI and will automatically decompress files.


Creating an image ( Using GitHub actions ):
1. Fork the repository
2. Commit your changes
3. Wait for GitHub actions to finish ( ~20 minutes with default settings )
3 ( alternative ). If you want the file to be publicly accessible or if you want a smaller download size, you can manually dispatch the release action ( under the release workflow in the actions tab ), which will create a release with the image compressed in a .xz file ( the required "tag" field in the dispatch menu is the name of the release, so like v0.1 )
4. Download the artifact actions created by clicking on the Actions tab, then the most recent workflow run, then the image artifact
4 ( alternative ). If you ran the release workflow, download jetson_image.img.xz from the release. 


Creating an image ( On your Debian-based machine ):
1. Clone the repository
2. CD into the repository:
```console
cd jetson
```
3. Run the script with root permissions:
```console
sudo bash create_image.sh
```
4. The image will be created in ./jetson_image.img


<br/>
<br/>

Credits:<br/>
    https://github.com/pythops/jetson-nano-image has been an amazing resource for which packages are necessary or useful. I created this project instead of using Pythop's script because I wanted a fast and convenient way to get a fully configured desktop, and so I could learn in the process.