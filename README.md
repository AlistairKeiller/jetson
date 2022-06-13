Flashing an image:
1. flash the image onto your Jetson's SD card with your favorite flashing software. I like Balena Etcher because it has a great UI and will automatically decompress files.

<br/>
<br/>

Creating an image ( Using GitHub actions ):
1. Fork the repository
2. Confgiure the variables in the top of the create_image.sh script
3. Commit your changes
4. Wait for GitHub actions to finish ( ~20 minutes with default settings )
5. Download the artifact actions created by clicking on the Actions tab, then the most recent workflow run, then the image artifact

<br/>

If you want the file to be publicly accessible or if you want a smaller download size, you can manually dispatch the release action ( under the release workflow in the actions tab ), which will create a release with the image compressed in a .xz file ( the required "tag" field in the dispatch menu is the name of the release, so like v0.1 )

<br/>
<br/>

Creating an image ( On your Debian-based machine ):
1. Clone the repository:
```console
git clone https://github.com/AlistairKeiller/jetson
```
2. CD into the repository:
```console
cd jetson
```
3. Confgiure the variables in the top of the create_image.sh script
4. Run the script with root permissions:
```console
sudo bash create_image.sh
```
5. The image will be created in ./jetson_image.img


<br/>
<br/>
<br/>

Script Credits:<br/>
    https://github.com/pythops/jetson-nano-image has been an amazing resource for which packages are necessary or useful. I created this project instead of using Pythop's script because I wanted a fast and convenient way to get a fully configured desktop, and so I could learn in the process.
    I used the cuda install script from https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=arm64-sbsa&Compilation=Native&Distribution=Ubuntu&target_version=20.04&target_type=deb_network