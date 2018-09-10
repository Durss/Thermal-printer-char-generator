# Thermal printer char generator

Allows to easily generate Arduino compatible C code to create and print custom font chars (or images) for this Thermal Printer :
 https://www.adafruit.com/product/597

## Printer user's manual
 http://www.adafruit.com/datasheets/A2-user%20manual.pdf

## The generated code is meant to be used with the Adafruit's library :
 https://github.com/adafruit/Adafruit-Thermal-Printer-Library
But you can definitely tweak it to use it with or without any other library.

## Tweaking Adafruit Library
 Regarding the Adafruit's library, as of its 2014 version, by default writeBytes() methods are private, think about making them public inside the Adafruit_Thermal.h file.
If you don't know how to do that, you can copy/paste the file from this repository (see "Adafruit_Thermal.h" file) into your local libraries.

#### You should find your local libraries at this location on Windows :
C:\Users\{YOUR USER NAME}\Documents\Arduino\libraries\Adafruit_Thermal


## You can find the tool here :
http://www.durss.ninja/projects/thermal-printer-code-generator/app/


Enjoy !

***[2018 EDIT]** Damn i miss the simplicity flash, 4 years after, piece of cake to update and compile T_T)*