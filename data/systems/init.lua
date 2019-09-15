local PATH = (...):gsub("%.init$", "")

Systems =
{
    Animation      = require(PATH .. ".animation"),
    DebugRenderer  = require(PATH .. ".debugdraw"),
    Event          = require(PATH .. ".event"),
    Physics        = require(PATH .. ".physics"),
    Primitive      = require(PATH .. ".primitiverenderer"),
    SpriteRenderer = require(PATH .. ".spriterenderer")
}
