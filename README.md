create_image.sh is a script that creates an image for an nvidia jetson SBC. So far I have only tested it on a jetson nano B01.

Flashing an image:
1. Download the image from the releases page ( if you are ok with the default settings like being for a jetson nano B01 board ) or create your own image
2. flash the image onto your jetson's SD card with your favorate flashing software. I like balena etcher because it has a great UI, and will automaticly decompress files.


Creating an image ( Using github actions ):
1. Fork the repository
2. Commit your changes
3. Wait for github actions to finish ( ~20 minutes )
3. Download the artifact actions created by clicking on the actions tab, then the most recent workflow run, then tje image artifact


Creating an image ( On your debian based machine ):
1. Clone the repository
2. CD into the repository:
```console
cd jetson
```
3. Run the script with root permisions:
```console
sudo bash create_image.sh
```
4. The image will be created in ./jetson_image.img
<br/>
<br/>
Credits:
    https://github.com/pythops/jetson-nano-image has been an amazing resource for which packages are nessesary or useful. I created this project, instead of using pythop's script, becuase I want an fast and convient way to get a fully configured desktop.