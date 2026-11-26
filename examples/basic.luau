--!strict

-- Command-line example. In Studio, require each copied ModuleScript by Instance.
local Inventory = require("../packages/inventory/src/Inventory")
local Progression = require("../packages/progression/src/Progression")
local Combat = require("../packages/combat/src/Combat")
local Economy = require("../packages/economy/src/Economy")

local bag, bagError = Inventory.create(6, {
	potion = { maxStack = 10 },
	sword = { maxStack = 1, equipmentSlot = "hand" },
}, { hand = true })
assert(bag, bagError)

local withSword, swordError = Inventory.add(bag, "sword", 1)
assert(withSword, swordError)
local equipped, equipmentError = Inventory.equip(withSword, 1)
assert(equipped, equipmentError)

local wallet, walletError = Economy.create(100)
assert(wallet, walletError)
local catalogue, catalogueError = Economy.createCatalogue({ potion = { itemId = "potion", price = 15, maxQuantity = 5 } })
assert(catalogue, catalogueError)
local purchase, purchaseError = Economy.purchase(wallet, equipped, catalogue, "potion", 2, Inventory.add)
assert(purchase, purchaseError)
-- A real server should replace its authoritative profile with both values together.
local profile = { wallet = purchase.wallet, inventory = purchase.inventory }
assert(profile.wallet.balance == 70)
assert(Inventory.count(profile.inventory, "potion") == 2)
local activeItem = Inventory.getEquipped(profile.inventory, "hand")
assert(activeItem and activeItem.itemId == "sword")

local progression, progressionError = Progression.create({ 0, 100, 250 }, { [2] = { coins = 10 } })
assert(progression, progressionError)
local award, awardError = Progression.award(progression, 125)
assert(award, awardError)
assert(award.state.level == 2 and award.rewards[1].amount == 10)

local target, targetError = Combat.create(100, 20)
assert(target, targetError)
local hit, damageError = Combat.damage(target, 40, { flatReduction = 5, canDamage = true })
assert(hit, damageError)
assert(hit.state.health == 85 and hit.state.shield == 0)

print("Example passed: equipped sword, bought 2 potions for 30 coins, reached level 2, resolved shielded damage.")
