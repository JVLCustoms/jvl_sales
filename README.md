# 💸 JVL Sales System v2.0 - Modern Interface

An elegant and configurable material sales system for FiveM servers based on ESX, featuring a modern interface that allows players to sell their items intuitively and efficiently.

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![FiveM](https://img.shields.io/badge/FiveM-ESX-green)
![License](https://img.shields.io/badge/license-MIT-brightgreen)

## ✨ Key Features

### 🎨 **Modern Interface**
- Elegant design with glassmorphism and visual effects
- Responsive interface that adapts to different resolutions
- Smooth animations and fluid transitions
- Optimized user experience for sales

### 💰 **Advanced Sales System**
- Multiple item selection for selling
- Individual quantity control per item
- Real-time total calculation
- Shows only available items in inventory
- Optimized transactions

### 🔧 **Technical Features**
- Robust server-side validation system
- Automatic NPC management with ox_target
- Support for multiple locations
- Flexible item and price configuration
- Compatibility with different inventory systems

## 📋 Requirements

- **es_extended** (ESX Framework)
- **mysql-async** (Database)
- **ox_target** (Interaction System)

## 🚀 Installation

### 1. Download and Basic Installation
```bash
# Place the 'jvl_sales' folder in your resources directory
resources/
└── jvl_sales/
    ├── fxmanifest.lua
    ├── config.lua
    ├── client.lua
    ├── server.lua
    └── html/
        ├── index.html
        ├── styles.css
        ├── script.js
        └── img/
```

### 2. Server Configuration
Add to your `server.cfg`:
```cfg
ensure jvl_sales
# or
start jvl_sales
```

### 3. Configuration (Optional)
The system works immediately, but you can customize locations and items in `config.lua`.

## ⚙️ Configuration

### 🏪 Sales Locations
```lua
Config.SellZones = {
    {
        Pos = vector3(-340.63, -1543.86, 27.22), -- Blip/marker position
        Ped = {
            Model = 'a_m_y_salton_01', -- NPC model
            Coords = vector4(-340.63, -1543.86, 27.72, 100.05), -- NPC position and rotation
        }
    }
    -- You can add more locations here
}
```

### 🎨 Interface Configuration
```lua
-- Toggle between new and classic interface
Config.UseNewInterface = true -- true = modern, false = classic ESX

-- Image paths (choose the one you use on your server)
Config.ImageBasePath = 'nui://ox_inventory/web/images/'     -- OX Inventory
-- Config.ImageBasePath = 'nui://qb-inventory/html/images/' -- QB-Core
-- Config.ImageBasePath = 'nui://es_extended/html/img/items/' -- ESX
-- Config.ImageBasePath = 'img/' -- Local images
```

### 🛒 Sellable Items
```lua
Config.ItemsInjvl_sales = {
    { 
        itemName = 'garbage',       -- Item name in database
        label = 'Trash',            -- Name displayed to player
        SellInjvl_sales = true,     -- Can be sold?
        SellPrice = 3               -- Sale price
    },
    { 
        itemName = 'burger', 
        label = 'Burger', 
        SellInjvl_sales = true, 
        SellPrice = 15 
    },
    { 
        itemName = 'scrapmetal', 
        label = 'Scrap Metal', 
        SellInjvl_sales = true, 
        SellPrice = 25 
    },
    -- Add more items here...
}
```

### 🗺️ Blip Configuration
```lua
Config.Enablejvl_salesBlip = true    -- Show blip on map
Config.BlipSprite = 365              -- Blip icon
Config.BlipDisplay = 3               -- Always show
Config.BlipScale = 0.8               -- Blip size
Config.BlipColour = 2                -- Green color
Config.BlipName = "Material Sales"   -- Blip text
```

## 🎮 Usage

### For Players
1. **Find the blip** on the map (green recycling icon)
2. **Approach the NPC** at the marked location
3. **Aim at the vendor** and select "Open sales menu"
4. **Select the items** you want to sell
5. **Adjust quantities** using the +/- controls
6. **Review the total** at the top
7. **Confirm the sale** with the "Sell Selected" button

### For Administrators
- **Automatic logs**: All transactions are logged in the console
- **Simple configuration**: Edit `config.lua` to customize
- **Multiple locations**: Add as many sales points as needed
- **Robust validation**: Built-in cheat protection

## 🎨 Customization

### 🖼️ Adding Item Images
1. **Configure the path** in `Config.ImageBasePath`
2. **Place images** in the corresponding inventory folder
3. **Name files** the same as `itemName` (e.g., `garbage.png`)
4. **Supported formats**: PNG, JPG, WEBP
5. **Recommended size**: 64x64 or 128x128 pixels

### 🎨 Modifying Styles
Edit `html/styles.css` to customize:
- **Colors**: Look for CSS variables in `:root`
- **Sizes**: Modify `.app-container` width/height
- **Animations**: Adjust `transition` and `@keyframes`

### 🏪 Adding New Locations
```lua
-- In config.lua, inside Config.SellZones
{
    Pos = vector3(x, y, z),        -- Blip coordinates
    Ped = {
        Model = 'ped_model',        -- NPC model
        Coords = vector4(x, y, z, heading), -- NPC position and rotation
    }
}
```

### 🛒 Adding New Items
```lua
-- In config.lua, inside Config.ItemsInjvl_sales
{ 
    itemName = 'new_item',          -- Item name in DB
    label = 'My New Item',          -- Display name
    SellInjvl_sales = true,         -- Can be sold?
    SellPrice = 50                  -- Sale price
},
```

## 🐛 Troubleshooting

### Interface won't open
- ✅ Verify that `Config.UseNewInterface = true`
- ✅ Check F8 console for JavaScript errors
- ✅ Confirm ox_target is working
- ✅ Check that NPC exists in the world

### Images won't load
- ✅ Verify path in `Config.ImageBasePath`
- ✅ Confirm PNG files exist
- ✅ File names must match exactly with `itemName`
- ✅ Check image folder permissions

### No items appear for sale
- ✅ Verify you have items in your inventory
- ✅ Confirm `SellInjvl_sales = true` in config
- ✅ Check that item names match your database

### NPC doesn't appear
- ✅ Verify coordinates in `Config.SellZones`
- ✅ Confirm PED model is valid
- ✅ Check console for model loading errors

### Transactions fail
- ✅ Check server logs for specific errors
- ✅ Verify items exist in ESX database
- ✅ Confirm prices are correctly configured

## 🔧 Technical Features

### 🔒 Security
- ✅ Server-side validation of all transactions
- ✅ Real-time inventory verification
- ✅ Protection against price manipulation
- ✅ Detailed logs of all sales

### ⚡ Performance
- ✅ Optimized interface with event delegation
- ✅ Dynamic item loading based on inventory
- ✅ DocumentFragment for efficient DOM manipulation
- ✅ Automatic resource cleanup

### 🛡️ Compatibility
- ✅ ESX Legacy and recent versions
- ✅ Compatible with ox_inventory, qb-inventory, esx_inventory
- ✅ Support for MySQL and MariaDB
- ✅ Works with most inventory frameworks

## 🎯 Use Cases

### 🏭 **Collection Jobs**
- Perfect for trash, recycling, mining jobs
- Players can sell collected materials
- Multiple locations for different material types

### 🛠️ **Crafting System**
- Intermediate items in production chains
- Waste or byproducts from other jobs

### 💼 **Server Economy**
- Material price regulation
- Strategic sales points on the map
- Anti-inflation system with fixed prices

## 📝 Changelog

### v2.0.0 - Modern Interface
- ✨ New modern and elegant HTML interface
- ✨ Multiple item selection
- ✨ Image path configuration
- ✨ UX and performance improvements
- ✨ Enhanced validation system

### v1.1.0 - Original Version
- 🎯 Basic system with ESX menus
- 🎯 Individual sale functionality
- 🎯 ox_target support

## 🔄 Comparison with Previous Version

| Feature | v1.1.0 | v2.0.0 |
|---|---|---|
| **Interface** | Basic ESX menu | Modern HTML |
| **Selection** | Individual | Multiple |
| **UX** | Functional | Intuitive and elegant |
| **Performance** | Good | Optimized |
| **Customization** | Limited | Highly configurable |
| **Compatibility** | ESX only | ESX + multiple inventories |

## 🎮 Commands & Controls

### In-Game Controls
- **E** - Interact with NPC (default)
- **ESC** - Close interface
- **Mouse** - Navigate interface
- **Click** - Select items and adjust quantities

### Configuration Commands
No chat commands required - everything is configured through `config.lua`.

## 🔧 API Reference

### Client Events
```lua
-- Open sales interface
OpenSalesInterface()

-- Close sales interface
CloseSalesInterface()

-- Legacy sell menu (fallback)
jvl_salesSellMenu()
```

### Server Events
```lua
-- Sell item event
TriggerServerEvent("jvl_sales:SellItem", quantity, totalPrice, itemName)
```

### NUI Callbacks
```lua
-- Close menu
RegisterNUICallback('closeMenu', function(data, cb))

-- Sell item
RegisterNUICallback('sellItem', function(data, cb))
```

## 🌐 Localization

The system currently supports:
- **Spanish** (Default)
- **English** (Partial)

To add your language, edit the text strings in:
- `client.lua` - Notifications
- `html/index.html` - Interface text
- `config.lua` - Blip names

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 👥 Credits

- **Developer**: JVL Customs
- **Original Creator**: Hamza
- **Design Inspiration**: Modern inventory systems
- **Community**: FiveM community feedback and testing

## 📞 Support

If you encounter any issues or need help:

1. **Check** this documentation first
2. **Verify** server and client logs (F8)
3. **Confirm** all requirements are installed
4. **Review** configuration in `config.lua`

### 💡 Quick Tips

- **F8** to open console and see errors
- **Coordinates**: Use `/getcoords` to get exact positions
- **PED Models**: Verify model exists in GTA V
- **Items**: Names must match exactly with your ESX database

### 🆘 Getting Help

For support and questions:
- Join our Discord: [discord.gg/9vg3bSWqM7](https://discord.gg/9vg3bSWqM7)
- Check the issues section on GitHub
- Contact JVL Customs team

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Enjoy your new modern sales system! 💸✨**

*Created with ❤️ by JVL Customs for the FiveM community*