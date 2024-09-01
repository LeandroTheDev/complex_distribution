# Complex Distributions
Changes completly the distributions from vanilla gaming

Features
- Remove any item from spawning
- Complex distributions creation

The loot drop table is stored in ``Lua/ComplexDistributions.ini``

Example:
```lua
{
    bedroom = {
        dresser = {
            {
                type = "combo",
                chance = 100,
                child = {
                    {
                        type = "item",
                        chance = 100,
                        quantity = 6,
                        child = "Base.Pistol"
                    },
                    {
                        type = "item",
                        chance = 100,
                        quantity = 5,
                        child = "Base.Pistol2"
                    },
                    {
                        type = "item",
                        chance = 100,
                        quantity = 3,
                        child = "Base.Pistol3"
                    }
                }
            }
        }
    }
}
```
In this example all dressers will spawn a pistol with 100% chance, the loot system is the same from [Random Airdrops](https://github.com/LeandroTheDev/random_airdrops) 

This will mod will no longer been mainted, as this mod uses the FTM license you can do whatever do you want, edit it and repost, as this is not mainted you can use the same name.

FTM License
