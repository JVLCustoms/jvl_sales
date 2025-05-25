--#####################################################--
--#- Created by Hamza & Optimized by JVL Customs -----#--
--#------- Updated with new HTML interface -----------#--
--#####################################################--
Config = {}

-- NEW: Interface Settings
Config.UseNewInterface = true -- Set to false to use old ESX menu interface

-- NEW: Image Settings
Config.ImageBasePath = 'nui://ox_inventory/web/images/' -- Path to your server's item images
-- Alternative paths you can use:
-- Config.ImageBasePath = 'nui://qb-inventory/html/images/' -- For QB-Core
-- Config.ImageBasePath = 'nui://es_extended/html/img/items/' -- For ESX default
-- Config.ImageBasePath = 'img/' -- For local images in html/img/ folder

-- Modelo del Ped usado en los puntos de venta
Config.PedModel = 'a_m_y_salton_01'

--  Posiciones de Venta (SellZones)
Config.SellZones = {
	{
	    Pos = vector3(-340.63, -1543.86, 27.22), -- Coordenadas para el marcador
	    Ped = {
		   Model = 'a_m_y_salton_01', -- Modelo del Ped
		   Coords = vector4(-340.63, -1543.86, 27.72, 100.05), -- Coordenadas y rotación del Ped
	    }
	}
 }
 
-- Configuración del Blip de Venta
Config.Enablejvl_salesBlip = true -- Cambia a `true` si deseas mostrar un blip en el mapa
Config.BlipSprite = 365 -- Ícono del blip (ícono de reciclaje)
Config.BlipDisplay = 3 -- Mostrar siempre
Config.BlipScale = 0.8 -- Tamaño del blip
Config.BlipColour = 2 -- Color verde
Config.BlipName = "Venta de Materiales" -- Texto que aparece en el blip

-- Configuración de texto y tecla para interactuar
Config.KeyToOpenShop = 38 -- Tecla para abrir el menú (por defecto `E`)
Config.ShopDraw3DText = "Presiona ~b~[E]~s~ para vender tus materiales" -- Texto interactivo

-- Lista de Ítems Vendibles
Config.ItemsInjvl_sales = {
    { itemName = 'garbage',       label = 'Basura',          	SellInjvl_sales = true,   SellPrice = 3 },
    { itemName = 'burger',        label = 'Hamburguesa',     	SellInjvl_sales = true,   SellPrice = 15 },
    { itemName = 'scrapmetal',    label = 'Chatarra de Metal', 	SellInjvl_sales = true,   SellPrice = 25 },
    { itemName = 'estetoscopio',  label = 'Estetoscopio',    	SellInjvl_sales = true,   SellPrice = 150 },
    { itemName = 'empty_bottle',  label = 'Botella vacia',	 	SellInjvl_sales = true,	 SellPrice = 10 },
    { itemName = 'mustard',       label = 'Mostaza',        	SellInjvl_sales = true,   SellPrice = 5 },
}