create_image.sh is a script that creates an image for an nvidia jetson SBC. So far I have only tested it on a jetson nano B01.

Flashing an image:
1. Download the image from the releases page or create your own image
2. flash the image onto your jetson's SD card with your favorate flashing software. I like balena etcher.

Creating an image ( Requies a debian based machine. You can use Github Actions, which will automaticly do the following steps, by forking this repo ):
1. Clone the repository
2. cd into the repository
```console
cd jetson
```
3. Run the script with root permisions
```console
sudo bash create_image.sh
```

Credits:
    I learned a lot about what type of packages need to be installed from, https://github.com/pythops/jetson-nano-image. I created this project, instead of using pythop's script, becuase I want an fast and convient way to get a fully configured desktop.