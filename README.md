create_image.sh is a script that creates an image for an Nvidia Jetson SBC. So far, I have only tested it on a jetson nano B01.

Flashing an image:
1. Download the image from the releases page ( if you are ok with the default settings like being for a jetson nano B01 board ) or build your own image
2. flash the image onto your jetson's SD card with your favorite flashing software. I like Balena Etcher because it has a great UI and will automatically decompress files.


Creating an image ( Using GitHub actions ):
1. Fork the repository
2. Commit your changes
3. Wait for GitHub actions to finish ( ~20 minutes with default settings )
3. Download the artifact actions created by clicking on the Actions tab, then the most recent workflow run, then the image artifact


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