About
=====

nim-colorsys is a Nim module for converting between the RGB, YIQ, HLS, and HSV color systems. It is a port of the colorsys module in the Python standard library.

All coordinates used are floats, between 0 and 1 (the exception being I and Q in the YIQ color space, which can be positive or negative).

Example: 

    # Gold color
    var rgb : seq[float] = @[1.00, 0.84, 0.00]
    
    # Convert to other color systems.
    var yiq : seq[float] = rgbToYiq(rgb)
    var hls : seq[float] = rgbToHls(rgb)
    var hsv : seq[float] = rgbToHsv(rgb)
    
    # Output the color in each system.
    echo("RGB: " & $rgb) # outputs "RGB: @[1.0, 0.84, 0.0]"
    echo("YIQ: " & $yiq) # outputs "YIQ: @[0.7955999999999999, 0.3648, -0.2268]"
    echo("HLS: " & $hls) # outputs "HLS: @[0.14, 0.5, 1.0]"
    echo("HSV: " & $hsv) # outputs "HSV: @[0.14, 1.0, 1.0]"

Example based on Python ``colorsys`` example at http://effbot.org/librarybook/colorsys.htm.

License
=======

nim-colorsys is released under the MIT open source license.
