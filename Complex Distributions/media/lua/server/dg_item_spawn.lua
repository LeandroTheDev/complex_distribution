---@diagnostic disable: undefined-global, deprecated
-- All items to be removed when spawning
-- {
--     "9mmClip",
--     "Axe"
-- }
ComplexDistributionsItemsToRemove = {};

-- Stores the distributions table
-- {
--     bedroom = {
--         dresser = {
--             {
--                 type = "combo",
--                 chance = 100,
--                 child = {
--                     {
--                         type = "item",
--                         chance = 100,
--                         quantity = 6,
--                         child = "Base.Pistol"
--                     },
--                     {
--                         type = "item",
--                         chance = 100,
--                         quantity = 5,
--                         child = "Base.Pistol2"
--                     },
--                     {
--                         type = "item",
--                         chance = 100,
--                         quantity = 3,
--                         child = "Base.Pistol3"
--                     }
--                 }
--             }
--         }
--     }
-- }
ComplexDistributionsSpawnTable = {};

-- Add items to the airdrop
local function spawnContainerDistributionsItems(container, roomName, containerName)
    -- First things check if the table exists
    if ComplexDistributionsSpawnTable[roomName] then
        if ComplexDistributionsSpawnTable[roomName][containerName] then
            -- Used for the ID attribute, all ids stored here will be ignored during the loot spawn
            local idSpawneds = {};

            local alocatedSelectedType
            -- swipe the list and call the functions
            -- based on the type.
            -- the function needs to be an parameter because
            -- its is referenced after the listSpawn
            local function listSpawn(list, selectType)
                alocatedSelectedType = selectType;
                -- Swipe all elements from the list
                for i = 1, #list do
                    selectType(list[i]);
                end
            end

            -- Type: item
            local function spawnItem(child)
                container:AddItem(child);
            end

            -- Type: combo
            local function spawnCombo(child)
                -- Varremos todos os elementos do loot table
                listSpawn(child, alocatedSelectedType);
            end

            -- Type: oneof
            local function spawnOneof(child)
                local selectedIndex = ZombRand(#child) + 1;
                -- listSpawn only accepts lists so we needs to get the specific item
                alocatedSelectedType(child[selectedIndex]);
            end

            local function selectType(element)
                local jump = false;
                -- Checking if the variable ID exist
                if element.id then
                    -- Verifying if the id has already added
                    if idSpawneds[element.id] then jump = true end
                end
                -- Checking if the chancce is null
                if not element.chance then element.chance = 100 end
                -- Verifying if doesnt need to jump
                if not jump then
                    -- Verifying the type
                    if element.type == "combo" then
                        -- Veryfing if the element has any ID
                        if element.id then
                            -- If exist then add it to the idSpawneds list
                            idSpawneds[element.id] = true;
                        end
                        -- Verifying if quantity is not null
                        if element.quantity then
                            -- Add based on the quantity
                            for _ = 1, element.quantity do
                                -- Getting the chance to spawn the child
                                if ZombRand(100) + 1 <= element.chance then
                                    -- Adding the item
                                    spawnCombo(element.child);
                                end
                            end
                        else
                            -- Getting the chance to spawn the child
                            if ZombRand(100) + 1 <= element.chance then
                                -- Adding the item
                                spawnCombo(element.child);
                            end
                        end
                    elseif element.type == "item" then
                        -- Veryfing if the element has any ID
                        if element.id then
                            -- If exist then add it to the idSpawneds list
                            idSpawneds[element.id] = true;
                        end
                        -- Verifying if quantity is not null
                        if element.quantity then
                            -- Add based on the quantity
                            for _ = 1, element.quantity do
                                -- Getting the chance to spawn the child
                                if ZombRand(100) + 1 <= element.chance then
                                    -- Adding the item
                                    spawnItem(element.child);
                                end
                            end
                        else
                            -- Getting the chance to spawn the child
                            if ZombRand(100) + 1 <= element.chance then
                                -- Adding the item
                                spawnItem(element.child);
                            end
                        end
                    elseif element.type == "oneof" then
                        -- Verifying if the element has any ID
                        if element.id then
                            -- If have add it to idSpawneds list
                            idSpawneds[element.id] = true;
                        end
                        -- Verifying if quantity is not null
                        if element.quantity then
                            -- Adding based on the quantity
                            for _ = 1, element.quantity do
                                -- Getting the chance to spawn the child
                                if ZombRand(100) + 1 <= element.chance then
                                    -- Adding the item
                                    spawnOneof(element.child);
                                end
                            end
                        else
                            -- Getting the chance to spawn the child
                            if ZombRand(100) + 1 <= element.chance then
                                -- Adding the item
                                spawnOneof(element.child);
                            end
                        end
                    end
                end
            end
            listSpawn(ComplexDistributionsSpawnTable[roomName][containerName], selectType);
        end
    end
end

local function loadOptions()
    --#region ComplexDistributionsItemsToRemove
    -- Getting the configuration
    local _itemsToRemove = SandboxVars.ComplexDistributions.ItemsToRemove;
    -- Swipe the configs into the variable
    for item in _itemsToRemove:gmatch("[^/]+") do
        table.insert(ComplexDistributionsItemsToRemove, item);
    end
    --#endregion

    --#region ComplexDistributionsSpawnTable
    local fileReader = getFileReader("ComplexDistributions.ini", true)
    local lines = {}
    local line = fileReader:readLine();
    while line do
        -- Check if is a comment
        if not line:match("^%s*--") then
            table.insert(lines, line)
        end
    end
    fileReader:close()
    ComplexDistributionsSpawnTable = loadstring(table.concat(lines, "\n"))() or {}
    --#endregion
end

local function onFillContainer(roomName, containerType, itemContainer)
    -- Uncoment this for getting the names for containers in terminal
    print("CONTAINER SPAWNING: " .. roomName .. " " .. containerType);
    local containerItems = itemContainer:getItems();

    --#region Items to be removed
    local itemsToBeRemoved = {};

    -- Swipe all container items
    for i = 0, containerItems:size() - 1 do
        local containerItem = containerItems:get(i);
        -- Swiping all items from removal list
        for _, item in ipairs(ComplexDistributionsItemsToRemove) do
            if item == containerItem:getType() then
                -- Add to the remove table
                table.insert(itemsToBeRemoved, item);
            end
        end
    end

    -- Removing definitivily the item from container
    for _, item in ipairs(itemsToBeRemoved) do
        itemContainer:RemoveAll(item);
    end
    --#endregion

    -- Adding the items to the container
    spawnContainerDistributionsItems(itemContainer, roomName, containerType);
end

loadOptions();
Events.OnFillContainer.Add(onFillContainer);
