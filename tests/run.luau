--!strict

local Inventory = require("../packages/inventory/src/Inventory")
local Progression = require("../packages/progression/src/Progression")
local Combat = require("../packages/combat/src/Combat")
local Economy = require("../packages/economy/src/Economy")

local passed = 0
local failed = 0
local function test(name: string, body: () -> ())
	local ok, message = pcall(body)
	if ok then
		passed += 1
		print("PASS", name)
	else
		failed += 1
		print("FAIL " .. name .. ": " .. tostring(message))
	end
end

local function bag(capacity: number?): Inventory.State
	local state, problem = Inventory.create(capacity or 4, {
		ore = { maxStack = 10 },
		sword = { maxStack = 1, equipmentSlot = "hand" },
		hat = { maxStack = 1, equipmentSlot = "head" },
	}, { hand = true, head = true })
	assert(state, problem)
	return state
end

test("inventory fills matching stacks before empty slots", function()
	local first = Inventory.add(bag(), "ore", 12)
	assert(first)
	local moved = Inventory.move(first, 1, 3)
	assert(moved)
	local added = Inventory.add(moved, "ore", 5)
	assert(added)
	assert(added.slots[1] == nil and added.slots[2].quantity == 7 and added.slots[3].quantity == 10)
	assert(Inventory.count(added, "ore") == 17)
end)

test("full inventory rejects the entire addition", function()
	local original = Inventory.add(bag(1), "ore", 8)
	assert(original)
	local result, problem = Inventory.add(original, "ore", 3)
	assert(result == nil and problem == "inventory_full")
	assert(original.slots[1].quantity == 8)
end)

test("remove crosses stacks and rejects insufficient items", function()
	local original = Inventory.add(bag(), "ore", 15)
	assert(original)
	local removed = Inventory.remove(original, "ore", 12)
	assert(removed and removed.slots[1] == nil and removed.slots[2].quantity == 3)
	local rejected, problem = Inventory.remove(removed, "ore", 4)
	assert(rejected == nil and problem == "insufficient_items")
	assert(Inventory.count(original, "ore") == 15 and Inventory.count(removed, "ore") == 3)
end)

test("move merges completely or leaves state unchanged", function()
	local original = Inventory.add(bag(), "ore", 15)
	assert(original)
	local rejected, problem = Inventory.move(original, 2, 1)
	assert(rejected == nil and problem == "stack_full")
	local reduced = Inventory.remove(original, "ore", 8)
	assert(reduced)
	local merged = Inventory.move(reduced, 1, 2)
	assert(merged and merged.slots[2].quantity == 7 and merged.slots[1] == nil)
	assert(Inventory.count(original, "ore") == 15)
end)

test("equipment follows a moved stack and clears on removal", function()
	local original = Inventory.add(bag(), "sword", 1)
	assert(original)
	local equipped = Inventory.equip(original, 1)
	assert(equipped and equipped.equipped.hand == 1)
	local moved = Inventory.move(equipped, 1, 4)
	assert(moved and moved.equipped.hand == 4)
	local removed = Inventory.remove(moved, "sword", 1)
	assert(removed and removed.equipped.hand == nil)
	assert(equipped.equipped.hand == 1)
end)

test("equipment replaces a slot without deleting owned items", function()
	local original = Inventory.add(bag(), "sword", 2)
	assert(original)
	local first = Inventory.equip(original, 1)
	assert(first)
	local second = Inventory.equip(first, 2)
	assert(second and second.equipped.hand == 2 and Inventory.count(second, "sword") == 2)
	local cleared = Inventory.unequip(second, "hand")
	assert(cleared and Inventory.getEquipped(cleared, "hand") == nil)
	local invalid, problem = Inventory.unequip(second, "back")
	assert(invalid == nil and problem == "invalid_equipment_slot")
end)

test("inventory rejects invalid values, indexes and definitions", function()
	local state = bag()
	for _, amount in { 0, -1, 1.5, 0 / 0, math.huge } do
		local result, problem = Inventory.add(state, "ore", amount)
		assert(result == nil and problem == "invalid_quantity")
	end
	assert(Inventory.add(state, "missing", 1) == nil)
	assert(Inventory.move(state, 0, 1) == nil)
	assert(Inventory.equip(state, 1) == nil)
	assert(Inventory.create(0, { ore = { maxStack = 10 } }) == nil)
	assert(Inventory.create(1, { sword = { maxStack = 2, equipmentSlot = "hand" } }, { hand = true }) == nil)
end)

test("inventory state and configuration are isolated and immutable", function()
	local definitions = { ore = { maxStack = 10 } }
	local state = Inventory.create(2, definitions)
	assert(state)
	definitions.ore.maxStack = 100
	local added = Inventory.add(state, "ore", 12)
	assert(added and added.slots[1].quantity == 10 and next(state.slots) == nil)
	assert(table.isfrozen(added) and table.isfrozen(added.slots) and table.isfrozen(added.slots[1]))
	local entries = Inventory.list(added)
	assert(#entries == 2 and entries[1].slot == 1 and entries[2].slot == 2)
end)

test("progression crosses exact and multiple level thresholds", function()
	local state = Progression.create({ 0, 100, 250, 500 }, { [2] = { coins = 5 }, [3] = { coins = 10 } })
	assert(state)
	local exact = Progression.award(state, 100)
	assert(exact and exact.state.level == 2 and #exact.rewards == 1 and exact.rewards[1].amount == 5)
	local multiple = Progression.award(state, 300)
	assert(multiple and multiple.state.level == 3 and #multiple.gainedLevels == 2 and #multiple.rewards == 2)
	assert(Progression.toNextLevel(multiple.state) == 200 and state.level == 1)
end)

test("progression caps experience and does not repeat earned rewards", function()
	local state = Progression.create({ 0, 100 }, { [2] = { coins = 5 } })
	assert(state)
	local capped = Progression.award(state, 1000)
	assert(capped and capped.state.experience == 100 and capped.acceptedExperience == 100)
	local again = Progression.award(capped.state, 50)
	assert(again and #again.rewards == 0 and #again.gainedLevels == 0 and Progression.toNextLevel(again.state) == 0)
end)

test("progression validates curves, rewards and experience", function()
	assert(Progression.create({ 1, 100 }) == nil)
	assert(Progression.create({ 0, 100, 100 }) == nil)
	assert(Progression.create({ [1] = 0, [3] = 100 }) == nil)
	assert(Progression.create({ 0, 100 }, { [1] = { coins = 1 } }) == nil)
	assert(Progression.create({ 0, 100 }, { [2] = { coins = -1 } }) == nil)
	local state = Progression.create({ 0, 100 })
	assert(state)
	for _, amount in { -1, 0.5, 0 / 0, math.huge } do
		assert(Progression.award(state, amount) == nil)
	end
end)

test("progression copies configuration and orders reward IDs", function()
	local curve = { 0, 100 }
	local rewards = { [2] = { z = 2, a = 1 } }
	local state = Progression.create(curve, rewards)
	assert(state)
	curve[2] = 200
	rewards[2].a = 99
	local award = Progression.award(state, 100)
	assert(award and award.state.level == 2 and award.rewards[1].id == "a" and award.rewards[1].amount == 1)
end)

test("combat applies reductions then multiplier and shield", function()
	local target = Combat.create(100, 20)
	assert(target)
	local result = Combat.damage(target, 30, { flatReduction = 5, multiplier = 2 })
	assert(result and result.absorbed == 20 and result.healthDamage == 30 and result.state.health == 70)
	assert(target.health == 100 and target.shield == 20)
end)

test("combat rejects denied attacks and supports shield piercing", function()
	local target = Combat.create(100, 20)
	assert(target)
	local denied, problem = Combat.damage(target, 10, { canDamage = false })
	assert(denied == nil and problem == "damage_denied")
	local piercing = Combat.damage(target, 10, { shieldPiercing = true })
	assert(piercing and piercing.state.health == 90 and piercing.state.shield == 20)
	local blocked = Combat.damage(target, 10, { flatReduction = 100 })
	assert(blocked and blocked.healthDamage == 0 and blocked.absorbed == 0)
end)

test("combat bounds health and refuses damage/healing after death", function()
	local target = Combat.create(100)
	assert(target)
	local lethal = Combat.damage(target, 1000)
	assert(lethal and lethal.killed and lethal.state.health == 0 and lethal.healthDamage == 100)
	assert(Combat.damage(lethal.state, 1) == nil and Combat.heal(lethal.state, 1) == nil)
	local wounded = Combat.damage(target, 30)
	assert(wounded)
	local healed = Combat.heal(wounded.state, 1000)
	assert(healed and healed.health == 100)
end)

test("combat rejects non-finite values and invalid rules", function()
	assert(Combat.create(0) == nil and Combat.create(math.huge) == nil)
	local target = Combat.create(100)
	assert(target)
	for _, amount in { -1, 0, 0 / 0, math.huge } do
		assert(Combat.damage(target, amount) == nil)
	end
	assert(Combat.damage(target, 10, { multiplier = -1 }) == nil)
	assert(Combat.damage(target, 10, { flatReduction = 0 / 0 }) == nil)
end)

test("economy credits and debits bounded integer balances", function()
	local wallet = Economy.create(100, 200)
	assert(wallet)
	local credited = Economy.credit(wallet, 50)
	assert(credited and credited.balance == 150)
	local debited = Economy.debit(credited, 25)
	assert(debited and debited.balance == 125 and wallet.balance == 100)
	local overflow, overflowError = Economy.credit(credited, 51)
	assert(overflow == nil and overflowError == "balance_limit")
	local overdraft, overdraftError = Economy.debit(wallet, 101)
	assert(overdraft == nil and overdraftError == "insufficient_funds")
end)

test("economy rejects invalid money and shop configuration", function()
	assert(Economy.create(0.5) == nil and Economy.create(-1) == nil)
	local wallet = Economy.create(100)
	assert(wallet)
	for _, amount in { -1, 0.5, 0 / 0, math.huge } do
		assert(Economy.credit(wallet, amount) == nil and Economy.debit(wallet, amount) == nil)
	end
	assert(Economy.createCatalogue({ ore = { itemId = "ore", price = -1 } }) == nil)
	assert(Economy.createCatalogue({ ore = { itemId = "ore", price = 1.5 } }) == nil)
end)

test("purchase returns consistent new wallet and inventory", function()
	local original = bag()
	local wallet = Economy.create(100)
	local catalogue = Economy.createCatalogue({ ore = { itemId = "ore", price = 7, maxQuantity = 5 } })
	assert(wallet and catalogue)
	local result, problem = Economy.purchase(wallet, original, catalogue, "ore", 3, Inventory.add)
	assert(result, problem)
	assert(result.totalCost == 21 and result.wallet.balance == 79 and Inventory.count(result.inventory, "ore") == 3)
	assert(wallet.balance == 100 and Inventory.count(original, "ore") == 0)
end)

test("failed purchase leaves both original states unchanged", function()
	local original = Inventory.add(bag(1), "ore", 10)
	local wallet = Economy.create(100)
	local catalogue = Economy.createCatalogue({ ore = { itemId = "ore", price = 7 } })
	assert(original and wallet and catalogue)
	local result, problem = Economy.purchase(wallet, original, catalogue, "ore", 1, Inventory.add)
	assert(result == nil and problem == "inventory_full")
	assert(wallet.balance == 100 and Inventory.count(original, "ore") == 10)
end)

test("shop rejects unowned offers, excessive quantity and insufficient funds", function()
	local original = bag()
	local wallet = Economy.create(5)
	local catalogue = Economy.createCatalogue({ ore = { itemId = "ore", price = 7, maxQuantity = 2 } })
	assert(wallet and catalogue)
	assert(Economy.purchase(wallet, original, catalogue, "missing", 1, Inventory.add) == nil)
	assert(Economy.purchase(wallet, original, catalogue, "ore", 3, Inventory.add) == nil)
	local result, problem = Economy.purchase(wallet, original, catalogue, "ore", 1, Inventory.add)
	assert(result == nil and problem == "insufficient_funds")
end)

test("shop snapshots prices, permits free offers and avoids unsafe totals", function()
	local offers = { ore = { itemId = "ore", price = 0, maxQuantity = 2 } }
	local catalogue = Economy.createCatalogue(offers)
	local wallet = Economy.create(0)
	assert(catalogue and wallet)
	offers.ore.price = 999
	local result = Economy.purchase(wallet, bag(), catalogue, "ore", 2, Inventory.add)
	assert(result and result.wallet.balance == 0 and Inventory.count(result.inventory, "ore") == 2)
	local expensive = Economy.createCatalogue({ ore = { itemId = "ore", price = 1000000000 } })
	assert(expensive)
	assert(Economy.purchase(wallet, bag(), expensive, "ore", 1000000, Inventory.add) == nil)
end)

print(string.format("%d passed, %d failed", passed, failed))
if failed > 0 then
	error("Behaviour checks failed")
end
