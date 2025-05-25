// ################################################# //
// #  Created by Hamza & Optimized by JVL Customs  # //
// #        Updated with new HTML interface        # //
// ################################################# //
let sellItems = [];
let playerInventory = [];
let selectedSellItems = {};
let isOpen = false;

$(function() {
    // Listen for NUI messages
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (!data || !data.type) {
            return;
        }
        
        console.log('Mensaje recibido:', data.type);
        
        switch(data.type) {
            case 'openSalesMenu':
                handleOpenSalesMenu(data);
                break;
            case 'closeSalesMenu':
                handleCloseSalesMenu();
                break;
            case 'updateInventory':
                handleUpdateInventory(data);
                break;
        }
    });

    // Initialize event listeners
    initializeEventListeners();
});

// Handle messages
function handleOpenSalesMenu(data) {
    if (isOpen) return;
    
    console.log('Abriendo Sales Menu');
    isOpen = true;
    
    // Store data
    sellItems = data.sellItems || [];
    playerInventory = data.inventory || [];
    
    // Set image base path
    window.imageBasePath = data.imageBasePath || 'img/';
    
    // Show sell menu
    showSellMenu();
}

function handleCloseSalesMenu() {
    if (!isOpen) return;
    
    console.log('Cerrando Sales Menu');
    closeMenu();
}

function handleUpdateInventory(data) {
    console.log('Actualizando inventario');
    playerInventory = data.inventory || [];
    
    // Refresh the sell menu
    if (isOpen) {
        setupSellItems();
    }
}

// Initialize event listeners
function initializeEventListeners() {
    // Close button
    $('#close-sell-btn').on('click', closeMenu);
    
    // Action button
    $('#sell-selected-btn').on('click', processSellTransaction);
    
    // Close with escape key
    $(document).keyup(function(e) {
        if (e.key === "Escape" && isOpen) {
            closeMenu();
        }
    });
}

// Show sell menu
function showSellMenu() {
    selectedSellItems = {};
    setupSellItems();
    $('#sell-container').show();
}

function closeMenu() {
    isOpen = false;
    $('#sell-container').hide();
    
    // Clear data
    selectedSellItems = {};
    sellItems = [];
    playerInventory = [];
    
    // Notify client to close NUI
    $.post('https://jvl_sales/closeMenu', JSON.stringify({}));
}

// Setup sell items
function setupSellItems() {
    const container = $('#sell-items-container');
    container.empty();
    selectedSellItems = {};
    
    // Filter items that player has and can be sold
    const availableItems = [];
    
    sellItems.forEach(configItem => {
        const inventoryItem = playerInventory.find(invItem => invItem.name === configItem.itemName);
        if (inventoryItem && inventoryItem.count > 0) {
            availableItems.push({
                ...configItem,
                count: inventoryItem.count
            });
        }
    });
    
    if (availableItems.length === 0) {
        container.html('<div class="empty-message"><i class="fas fa-box-open"></i>No tienes materiales para vender</div>');
        updateSellTotal();
        return;
    }
    
    const fragment = document.createDocumentFragment();
    
    availableItems.forEach(item => {
        const itemElement = createSellItemElement(item);
        if (itemElement) {
            fragment.appendChild(itemElement);
            selectedSellItems[item.itemName] = 0;
        }
    });
    
    container.append(fragment);
    setupSellControls();
    updateSellTotal();
}

// Create sell item element
function createSellItemElement(item) {
    const template = document.getElementById('sell-item-template');
    if (!template) return null;
    
    const clone = document.importNode(template.content, true);
    const itemElement = clone.querySelector('.item');
    
    itemElement.dataset.item = item.itemName;
    
    // Image
    const img = clone.querySelector('.item-img');
    img.src = getItemImage(item.itemName);
    img.alt = item.label;
    img.onerror = function() {
        this.src = window.imageBasePath + 'default.png';
    };
    
    // Count and price badge
    clone.querySelector('.item-count').textContent = `x${item.count}`;
    clone.querySelector('.item-price-badge').textContent = `$${item.SellPrice}`;
    
    // Name and price
    clone.querySelector('.item-name').textContent = item.label;
    clone.querySelector('.item-price').textContent = `Precio: $${item.SellPrice.toLocaleString()} c/u`;
    
    // Quantity input
    const quantityInput = clone.querySelector('.quantity-input');
    quantityInput.value = 0;
    quantityInput.max = item.count;
    
    return clone;
}

// Setup sell controls
function setupSellControls() {
    // Remove previous listeners
    $(document).off('change.sell input.sell click.sell');
    
    // Checkbox events
    $(document).on('change.sell', '#sell-items-container .select-item', function() {
        const itemElement = $(this).closest('.item');
        const itemName = itemElement.data('item');
        const item = getSellItemByName(itemName);
        const quantityInput = itemElement.find('.quantity-input');
        
        if (!item) return;
        
        if ($(this).is(':checked')) {
            itemElement.addClass('selected');
            selectedSellItems[itemName] = item.count;
            quantityInput.val(item.count);
        } else {
            itemElement.removeClass('selected');
            selectedSellItems[itemName] = 0;
            quantityInput.val(0);
        }
        
        updateSellTotal();
    });
    
    // Increase/decrease buttons
    $(document).on('click.sell', '#sell-items-container .increase', function() {
        const itemElement = $(this).closest('.item');
        const itemName = itemElement.data('item');
        const item = getSellItemByName(itemName);
        const quantityInput = $(this).siblings('.quantity-input');
        
        if (!item) return;
        
        const currentValue = parseInt(quantityInput.val()) || 0;
        const newValue = Math.min(currentValue + 1, item.count);
        
        quantityInput.val(newValue);
        selectedSellItems[itemName] = newValue;
        
        // Update checkbox
        if (newValue === item.count) {
            itemElement.find('.select-item').prop('checked', true);
            itemElement.addClass('selected');
        } else if (newValue > 0) {
            itemElement.find('.select-item').prop('checked', false);
            itemElement.addClass('selected');
        }
        
        updateSellTotal();
    });
    
    $(document).on('click.sell', '#sell-items-container .decrease', function() {
        const itemElement = $(this).closest('.item');
        const itemName = itemElement.data('item');
        const quantityInput = $(this).siblings('.quantity-input');
        const currentValue = parseInt(quantityInput.val()) || 0;
        const newValue = Math.max(currentValue - 1, 0);
        
        quantityInput.val(newValue);
        selectedSellItems[itemName] = newValue;
        
        // Update checkbox
        if (newValue === 0) {
            itemElement.find('.select-item').prop('checked', false);
            itemElement.removeClass('selected');
        }
        
        updateSellTotal();
    });
    
    // Input events
    $(document).on('input.sell', '#sell-items-container .quantity-input', function() {
        const itemElement = $(this).closest('.item');
        const itemName = itemElement.data('item');
        const item = getSellItemByName(itemName);
        
        if (!item) return;
        
        let value = parseInt($(this).val()) || 0;
        value = Math.max(0, Math.min(value, item.count));
        $(this).val(value);
        
        selectedSellItems[itemName] = value;
        
        // Update checkbox
        if (value === item.count) {
            itemElement.find('.select-item').prop('checked', true);
            itemElement.addClass('selected');
        } else if (value > 0) {
            itemElement.find('.select-item').prop('checked', false);
            itemElement.addClass('selected');
        } else {
            itemElement.find('.select-item').prop('checked', false);
            itemElement.removeClass('selected');
        }
        
        updateSellTotal();
    });
}

// Update sell total
function updateSellTotal() {
    let total = 0;
    
    Object.entries(selectedSellItems).forEach(([itemName, quantity]) => {
        if (quantity > 0) {
            const item = getSellItemByName(itemName);
            if (item) {
                total += item.SellPrice * quantity;
            }
        }
    });
    
    $('#sell-total-value').text(total.toLocaleString());
    
    // Update button state
    const hasItems = total > 0;
    $('#sell-selected-btn').prop('disabled', !hasItems);
    $('#sell-selected-btn').css('opacity', hasItems ? '1' : '0.5');
}

// Process sell transaction
function processSellTransaction() {
    const itemsToSell = [];
    let totalEarnings = 0;
    
    Object.entries(selectedSellItems).forEach(([itemName, quantity]) => {
        if (quantity > 0) {
            const item = getSellItemByName(itemName);
            if (item) {
                itemsToSell.push({
                    itemName: itemName,
                    quantity: quantity,
                    unitPrice: item.SellPrice,
                    totalPrice: item.SellPrice * quantity
                });
                totalEarnings += item.SellPrice * quantity;
            }
        }
    });
    
    if (itemsToSell.length === 0) {
        console.warn('No hay items seleccionados para vender');
        return;
    }
    
    console.log('Vendiendo items:', itemsToSell);
    
    // Send each item individually to maintain compatibility
    itemsToSell.forEach(item => {
        $.post('https://jvl_sales/sellItem', JSON.stringify({
            itemName: item.itemName,
            quantity: item.quantity,
            totalPrice: item.totalPrice
        })).fail(function(xhr, status, error) {
            console.error('Error vendiendo item:', item.itemName, error);
        });
    });
    
    // Close after transaction
    setTimeout(closeMenu, 500);
}

// Helper functions
function getSellItemByName(itemName) {
    // First check if we have the item with count (from setupSellItems)
    const container = $('#sell-items-container');
    const itemElement = container.find(`[data-item="${itemName}"]`);
    
    if (itemElement.length > 0) {
        const sellItem = sellItems.find(item => item.itemName === itemName);
        const countText = itemElement.find('.item-count').text();
        const count = parseInt(countText.replace('x', '')) || 0;
        
        if (sellItem) {
            return {
                ...sellItem,
                count: count
            };
        }
    }
    
    return null;
}

// Get item image
function getItemImage(itemName) {
    // This will be set by the client when opening the interface
    const imageBasePath = window.imageBasePath || 'img/';
    
    // Use the item name directly for the image
    return imageBasePath + itemName + '.png';
}

// Error handling
window.onerror = function(message, source, lineno, colno, error) {
    console.error('Error:', {
        message: message,
        source: source,
        line: lineno,
        column: colno,
        error: error
    });
    return true;
};

// Cleanup
$(window).on('beforeunload', function() {
    $(document).off('.sell');
});

