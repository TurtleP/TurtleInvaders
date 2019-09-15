local PATH = (...):gsub("%.init$", "")

Components =
{
    Animation   = require(PATH .. ".animation"),
    Collision   = require(PATH .. ".collision" ),
    Controls    = require(PATH .. ".controls"),
    Mask        = require(PATH .. ".mask"),
    Position    = require(PATH .. ".position"),
    Primitive   = require(PATH .. ".primitive"),
    Size        = require(PATH .. ".size"),
    Sprite      = require(PATH .. ".sprite"),
    Static      = require(PATH .. ".static"),
    Velocity    = require(PATH .. ".velocity")
}
