<div align="center">
  <h1>xt-taser</h1>
  <a href="https://dsc.gg/xtdev"> <img align="center" src="https://user-images.githubusercontent.com/101474430/233859688-2b3b9ecc-41c8-41a6-b2e3-a9f1aad473ee.gif"/></a><br>
</div>

# Features
- Reloadable base game stun gun with cartridges
- Set max allowed cartridges in stun guns
- Disables stun gun when empty, prompts for reload
- Reload animation and progress
- Custom UI showing remaining cartridges

# Install
Add taser cartridges to ox_inventory
```lua
["ammo-taser"] = {
    label = "Taser Cartridge",
    weight = 100,
    stack = true,
    close = false
},
```

# Dependencies
- [ox_lib](https://github.com/CommunityOx/ox_lib/releases)
- [ox_inventory](https://github.com/CommunityOx/ox_inventory/releases)