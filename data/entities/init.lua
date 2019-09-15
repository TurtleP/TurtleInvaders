local PATH = (...):gsub("%.init$", "")

Entities =
{
    Barrier   = require(PATH .. ".barrier"),
    Bullet    = require(PATH .. ".bullet"),
    Bat       = require(PATH .. ".bat"),
    Explosion = require(PATH .. ".explosion"),
    Player    = require(PATH .. ".player"),
}
