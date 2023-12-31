# GoPostal Job for FiveM by DreamScripts 📦

Welcome to the most immersive GoPostal Job experience for your FiveM server. Crafted meticulously in Lua, this script is optimized for both QB and ESX frameworks, ensuring seamless integration irrespective of your server setup.

## Features:
- **Framework Compatibility**: Whether you're running on QB or ESX, this script has got you covered.
- **Targeting Systems**: Enhanced gameplay with full support for `ox_target` & `qb-target`.
- **Notification Systems**: Get notified whether you use QB, ESX, okok, or mythic.

#### To Whitelist the job & add to `qb-cityhall`:
1. In config.lua make `Config.IS_WHITELISTED_TO_JOB` true.
2. In config.lua change `Config.WHITELISTED_JOB_TITLE` to job string of desired. We have it as `postal` by default.
3. Add the following snippet to `qb-cityhall/config.lua`
```lua
['postal'] = { ['label'] = 'GoPostal', ['isManaged'] = false }
```
4. Add the following snippet to `qb-core/shared/jobs.lua`
```lua
    ['postal'] = {
        label = 'GoPostal',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Delivery Driver',
                payment = 0,
                isboss = false,
            },
            [1] = {
                name = 'Manager',
                isboss = true,
                payment = 0
            },
            [2] = {
                name = 'Boss',
                isboss = true,
                payment = 0
            },
        }
    },
```

### Developer Tools:
Stuck with a package due to the job? Or maybe you're on a mission to record or find the exact coordinates of postal boxes? We've got handy developer tools for that!

#### Removing a Box:
If a player is stuck carrying a box due to the job, simply type: `/removebox`

#### Finding a Postal Box:
To get coordinates of a nearby postal box:
1. Type `/pbox`.
2. Press F8.
3. Click "Open Log".
4. Scroll to the bottom of the log and you'll find the coords!

#### Recording Postal Boxes:
Automatically detect and record postal boxes within your vicinity.
1. Begin the recording process with `/pbox_record`.
2. Drive around - the script will auto-detect postal boxes within a range of 100 units.
3. Finish recording with `/pbox_record` once more.
4. Press F8.
5. Click "Open Log".
6. Scroll to the bottom for the recorded coordinates.

#### Detecting Clothing Codes:
Detect Clothing Outfit codes for GoPostal Outfit.
1. Put on desired GoPostal Outfit in clothing store.
2. Save desired outfit onto your player.
3. Execute `/gpfit` to see the outfit codes in F8.
5. Click "Open Log".
6. Scroll to the bottom for the outfit codes and plug them into `config.lua`.

Want to collaborate, or get access to support and more? Reach out:
- **[Check out the Showcase](https://www.youtube.com/watch?v=fSwJO3C85E0)**
- **[Join the DreamScripts Discord](https://discord.gg/mvEYGraCM2)**
- **[Check out the Forum Post](https://forum.cfx.re/t/free-qb-esx-gopostal-job-optimized/5182086)**
- **Connect on Discord**: @sir_kale

![DreamScripts Logo](https://cdn.discordapp.com/attachments/998923900287205442/1166036599189020692/dreamscripts.png?ex=655241b5&is=653fccb5&hm=e16ed188536c8d0b94e5b5baef5612e0ccb907eb188b91e25c50dc6e38d8ece5&)
