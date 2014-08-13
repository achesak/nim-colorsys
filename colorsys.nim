# Nimrod module for converting between color systems.
# Ported from the colorsys module in the Python standard library.

# Written by Adam Chesak.
# Released under the MIT open source license.





# ALSO ADD IN SUPPORT TO CONSTRUCT COLORS FROM EACH TYPE (EXCLUDING RBG). SEE THE colors
# MODULE FOR HOW THIS WOULD WORK (rgb())


import math


proc rgbToYiq*(r : float, g : float, b : float): seq[float] =
    ## Converts from RGB to YIQ.
    ##
    ## YIQ: used by composite video signals (linear combinations of RGB)
    ## - Y: perceived grey level (0.0 == black, 1.0 == white)
    ## - I, Q: color components
    
    var yiq = newSeq[float](3)
    yiq[0] = (0.30 * r) + (0.59 * g) + (0.11 * b)
    yiq[1] = (0.60 * r) - (0.28 * g) - (0.32 * b)
    yiq[2] = (0.21 * r) - (0.52 * g) + (0.31 * b)
    return yiq


proc yiqToRgb*(y : float, i : float, q : float): seq[float] = 
    ## Converts from YIQ to RBG.
    
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


proc rgbToHls*(r : float, g : float, b : float): seq[float] = 
    ## Converts from RGB to HLS.
    ##
    ## HLS: Hue, Luminance, Saturation
    ## - H: position in the spectrum
    ## - L: color lightness
    ## - S: color saturation
    
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


proc hlsToRgb*(h : float, l : float, s : float): seq[float] = 
    ## Converts from HLS to RGB.
    
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


proc rgbToHsv*(r : float, g : float, b : float): seq[float] = 
    ## Converts from RGB to HSV.
    ##
    # HSV: Hue, Saturation, Value
    ## - H: position in the spectrum
    ## - S: color saturation ("purity")
    ## - V: color brightness
    
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


proc hsvToRgb*(h : float, s : float, v : float): seq[float] = 
    ## Converts from HSV to RGB.
    
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
