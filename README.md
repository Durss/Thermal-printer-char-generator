Thermal printer char generator
==============================

Allows to easily generate Arduino compatible C code to create and print custom font chars for this Thermal Printer :
https://www.adafruit.com/product/597

The code is meant to be used with the Adafruit's library :
https://github.com/adafruit/Adafruit-Thermal-Printer-Library
But you can definitely tweek it to use with or without any other library.

Regarding the Adafruit's lib, by default writeBytes() methods are private, think about making them public inside the Adafruit_Thermal.h file.
If you don't know how to do that, you can copy/paste the file from the repository into your local library.
You should find it there :
C:\Users\{YOUR USER NAME}\Documents\Arduino\libraries\Adafruit_Thermal

Enjoy !