# Nim module for converting between color systems.
# Ported from the colorsys module in the Python standard library.

# Written by Adam Chesak.
# Released under the MIT open source license.


## nim-colorsys is a Nim module for converting between the RGB, YIQ, HLS, and HSV color systems.
## It is a port of the ``colorsys`` module in the Python standard library.
##
## All coordinates used are floats between 0 and 1 (the exception being I and Q in the YIQ color space,
## which can be positive or negative).
##
## Example: 
##
## .. code-block:: nim
##
##    # Gold color
##    var rgb : seq[float] = @[1.00, 0.84, 0.00]
##    
##    # Convert to other color systems.
##    var yiq : seq[float] = rgbToYiq(rgb)
##    var hls : seq[float] = rgbToHls(rgb)
##    var hsv : seq[float] = rgbToHsv(rgb)
##    
##    # Output the color in each system.
##    echo("RGB: " & $rgb) # outputs "RGB: @[1.0, 0.84, 0.0]"
##    echo("YIQ: " & $yiq) # outputs "YIQ: @[0.7955999999999999, 0.3648, -0.2268]"
##    echo("HLS: " & $hls) # outputs "HLS: @[0.14, 0.5, 1.0]"
##    echo("HSV: " & $hsv) # outputs "HSV: @[0.14, 1.0, 1.0]"
##
## Example based on Python ``colorsys`` example at http://effbot.org/librarybook/colorsys.htm.


import math


proc rgbToYiq*(rgb : seq[float]): seq[float] =
    ## Converts from RGB to YIQ.
    ##
    ## YIQ: used by composite video signals (linear combinations of RGB)
    ## - Y: perceived grey level (0.0 == black, 1.0 == white)
    ## - I, Q: color components
    
    var r : float = rgb[0]
    var g : float = rgb[1]
    var b : float = rgb[2]
    
    var yiq = newSeq[float](3)
    yiq[0] = (0.30 * r) + (0.59 * g) + (0.11 * b)
    yiq[1] = (0.60 * r) - (0.28 * g) - (0.32 * b)
    yiq[2] = (0.21 * r) - (0.52 * g) + (0.31 * b)
    return yiq


proc yiqToRgb*(yiq : seq[float]): seq[float] = 
    ## Converts from YIQ to RBG.
    
    var y : float = yiq[0]
    var i : float = yiq[1]
    var q : float = yiq[2]
    
    var rgb = newSeq[float](3)
    rgb[0] = y + (0.948262 * i) + (0.624013 * q)
    rgb[1] = y - (0.276066 * i) - (0.639810 * q)
    rgb[2] = y - (1.105450 * i) + (1.729860 * q)
    if rgb[0] < 0.0:
        rgb[0] = 0.0
    if rgb[1] < 0.0:
        rgb[1] = 0.0
    if rgb[2] < 0.0:
        rgb[2] = 0.0
    if rgb[0] > 1.0:
        rgb[0] = 1.0
    if rgb[1] > 1.0:
        rgb[1] = 1.0
    if rgb[2] > 1.0:
        rgb[2] = 1.0
    return rgb


proc rgbToHls*(rgb : seq[float]): seq[float] = 
    ## Converts from RGB to HLS.
    ##
    ## HLS: Hue, Luminance, Saturation
    ## - H: position in the spectrum
    ## - L: color lightness
    ## - S: color saturation
    
    var r : float = rgb[0]
    var g : float = rgb[1]
    var b : float = rgb[2]
    
    var maxc : float = max(r, g, b)
    var minc : float = min(r, g, b)
    var l : float = (minc + maxc) / 2.0
    if minc == maxc:
        return @[0.0, l, 0.0]
    var s : float
    if l <= 0.5:
        s = (maxc - minc) / (maxc + minc)
    else:
        s = (maxc - minc) / (2.0 - maxc - minc)
    var rc : float = (maxc - r) / (maxc - minc)
    var gc : float = (maxc - g) / (maxc - minc)
    var bc : float = (maxc - b) / (maxc - minc)
    var h : float
    if r == maxc:
        h = bc - gc
    elif g == maxc:
        h = 2.0 + rc - bc
    else:
        h = 4.0 + gc - rc
    h = (h / 6.0) mod 1.0
    return @[h, l, s]
    

proc hlsHelper(m1 : float, m2 : float, hue : float): float = 
    ## Helper for hlsToRgb().
    
    var hue2 : float = hue mod 1.0
    if hue2 < (1.0 / 6.0):
        return m1 + ((m2 - m1) * hue2 * 6.0)
    if hue2 < 0.5:
        return m2
    if hue2 < (2.0 / 3.0):
        return m1 + ((m2 - m1) * ((2.0 / 3.0) - hue2) * 6.0)
    return m1


proc hlsToRgb*(hls : seq[float]): seq[float] = 
    ## Converts from HLS to RGB.
    
    var h : float = hls[0]
    var l : float = hls[1]
    var s : float = hls[2]
    
    if s == 0.0:
        return @[l, l, l]
    var m1 : float
    var m2 : float
    if l <= 0.5:
        m2 = l * (1.0 + s)
    else:
        m2 = l + s - (l * s)
    m1 = (2.0 * l) - m2
    return @[hlsHelper(m1, m2, (h + (1.0 / 3.0))), hlsHelper(m1, m2, h), hlsHelper(m1, m2, (h - (1.0 / 3.0)))]


proc rgbToHsv*(rgb : seq[float]): seq[float] = 
    ## Converts from RGB to HSV.
    ##
    # HSV: Hue, Saturation, Value
    ## - H: position in the spectrum
    ## - S: color saturation ("purity")
    ## - V: color brightness
    
    var r : float = rgb[0]
    var g : float = rgb[1]
    var b : float = rgb[2]
    
    var maxc : float = max(r, g, b)
    var minc : float = min(r, g, b)
    var v : float = maxc
    if minc == maxc:
        return @[0.0, 0.0, v]
    var s : float = (maxc - minc) / maxc
    var rc : float = (maxc - r) / (maxc - minc)
    var gc : float = (maxc - g) / (maxc - minc)
    var bc : float = (maxc - b) / (maxc - minc)
    var h : float
    if r == maxc:
        h = bc - gc
    elif g == maxc:
        h = 2.0 + rc - bc
    else:
        h = 4.0 + gc - rc
    h = (h / 6.0) mod 1.0
    return @[h, s, v]


proc hsvToRgb*(hsv : seq[float]): seq[float] = 
    ## Converts from HSV to RGB.
    
    var h : float = hsv[0]
    var s : float = hsv[1]
    var v : float = hsv[2]
    
    if s == 0.0:
        return @[v, v, v]
    var i : int = int(h * 6.0)
    var f : float = (h * 6.0) - float(i)
    var p : float = v * (1.0 - s)
    var q : float = v * (1.0 - (s * f))
    var t : float = v * (1.0 - (s * (1.0 - f)))
    i = i mod 6
    if i == 0:
        return @[v, t, p]
    if i == 1:
        return @[q, v, p]
    if i == 2:
        return @[p, v, t]
    if i == 3:
        return @[p, q, v]
    if i == 4:
        return @[t, p, v]
    if i == 5:
        return @[v, p, q]
