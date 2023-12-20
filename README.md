# Aseprite GBStudio Color Converter
This is a modified version of the original script. This version reduces the colors of any given image, into Gameboy colors. 

# Compatibility with Gameboy Color Palettes
This version of the script is optimized for use with Gameboy Color (GBC) color palettes. It offers 100% compatibility with GB Studio's background and sprite color palettes while retaining the flexibility to work with other color schemes.
![image](https://github.com/wolandark/Aseprite_GBStudio_Color_Converter-/assets/107309764/117eeabb-65f4-4d37-a7f0-d0ff40664b67)
![image](https://github.com/wolandark/Aseprite_GBStudio_Color_Converter-/assets/107309764/65ce38d9-6040-40ff-9f86-b363b64e1503)
![image](https://github.com/wolandark/Aseprite_GBStudio_Color_Converter-/assets/107309764/8691e8cb-e69a-468f-8cda-907463cd7c57)


# Original README
## Aseprite_Palette_Reducer
 This tool is designed to reduce/convert the current palette of the active sprite to a custom input palette. This is ideal for workflows that generate large palette sizes, or just for cleaning up existing artwork :)
 It works by analyzing the pixels of the current project and converting them to one of the input colors. It will swap to the color of the custom palette closest to its own value (either RBG or LAB values).

# How to use
## Getting Started
- Open Aseprite and click File>Scripts and then open the folder.
- Click and drag the lua script into the folder and rescan the folder.
- The script should now be useable within Aseprite!

## Using the script
WARNING: SAVE A COPY OF YOUR WORK AS THE CHANGES MADE ARE NOT UNDOABLE CURRENTLY

- Run the script and click Add Color for each color in your palette (the calculation may take a while time if more than 10 colors or applied to a large image).
- Once the color palette to use is entered, click Apply.
- Wait for the calculation to finish, please be patient as the LAB version has additional calculations to convert RBG values.
- Once the calculation is finished, I recommend clicking the Palette Options button, then selecting New Palette From Sprite, setting the number of colors equal to your custom palette size.
- Enjoy!
