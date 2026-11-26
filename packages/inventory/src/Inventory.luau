--!strict

local Inventory = {}

export type Definition = { read maxStack: number, read equipmentSlot: string? }
export type Definitions = { [string]: Definition }
export type Stack = { read itemId: string, read quantity: number }
export type State = {
	read capacity: number,
	read definitions: Definitions,
	read slots: { [number]: Stack },
	read equipmentSlots: { [string]: boolean },
	read equipped: { [string]: number },
}
export type Entry = { read slot: number, read itemId: string, read quantity: number }

local MAX_CAPACITY = 512
local MAX_QUANTITY = 1000000

local function integer(value: unknown, minimum: number, maximum: number): boolean
	return typeof(value) == "number"
		and value == value
		and value >= minimum
		and value <= maximum
		and value % 1 == 0
end

local function identifier(value: unknown): boolean
	return typeof(value) == "string" and #value > 0 and #value <= 96
end

local function updated(state: State, slots: { [number]: Stack }?, equipped: { [string]: number }?): State
	return table.freeze({
		capacity = state.capacity,
		definitions = state.definitions,
		equipmentSlots = state.equipmentSlots,
		slots = if slots then table.freeze(slots) else state.slots,
		equipped = if equipped then table.freeze(equipped) else state.equipped,
	})
end

local function itemError(state: State, itemId: string, quantity: number): string?
	if not identifier(itemId) then
		return "invalid_item_id"
	end
	if not state.definitions[itemId] then
		return "unknown_item"
	end
	if not integer(quantity, 1, MAX_QUANTITY) then
		return "invalid_quantity"
	end
	return nil
end

function Inventory.create(capacity: number, definitions: Definitions, equipmentSlots: { [string]: boolean }?): (State?, string?)
	if not integer(capacity, 1, MAX_CAPACITY) then
		return nil, "invalid_capacity"
	end
	if typeof(definitions) ~= "table" or (equipmentSlots ~= nil and typeof(equipmentSlots) ~= "table") then
		return nil, "invalid_definitions"
	end
	local allowed: { [string]: boolean } = {}
	local slotCount = 0
	for name, enabled in equipmentSlots or {} do
		slotCount += 1
		if not identifier(name) or enabled ~= true or slotCount > 32 then
			return nil, "invalid_equipment_slots"
		end
		allowed[name] = true
	end
	local copied: Definitions = {}
	local count = 0
	for itemId, definition in definitions do
		count += 1
		if count > 1024 or not identifier(itemId) or typeof(definition) ~= "table" then
			return nil, "invalid_definitions"
		end
		if not integer(definition.maxStack, 1, MAX_QUANTITY) then
			return nil, "invalid_stack_limit"
		end
		local equipmentSlot = definition.equipmentSlot
		if equipmentSlot ~= nil then
			if not identifier(equipmentSlot) or not allowed[equipmentSlot] then
				return nil, "invalid_equipment_slot"
			end
			if definition.maxStack ~= 1 then
				return nil, "equipment_must_not_stack"
			end
		end
		copied[itemId] = table.freeze({ maxStack = definition.maxStack, equipmentSlot = equipmentSlot })
	end
	if count == 0 then
		return nil, "invalid_definitions"
	end
	return table.freeze({
		capacity = capacity,
		definitions = table.freeze(copied),
		slots = table.freeze({}) :: { [number]: Stack },
		equipmentSlots = table.freeze(allowed),
		equipped = table.freeze({}) :: { [string]: number },
	}), nil
end

function Inventory.count(state: State, itemId: string): (number?, string?)
	if not identifier(itemId) or not state.definitions[itemId] then
		return nil, "unknown_item"
	end
	local total = 0
	for _, stack in state.slots do
		if stack.itemId == itemId then
			total += stack.quantity
		end
	end
	return total, nil
end

function Inventory.list(state: State): { Entry }
	local entries: { Entry } = {}
	for slot = 1, state.capacity do
		local stack = state.slots[slot]
		if stack then
			table.insert(entries, table.freeze({ slot = slot, itemId = stack.itemId, quantity = stack.quantity }))
		end
	end
	return table.freeze(entries)
end

function Inventory.add(state: State, itemId: string, quantity: number): (State?, string?)
	local problem = itemError(state, itemId, quantity)
	if problem then
		return nil, problem
	end
	local limit = state.definitions[itemId].maxStack
	local space = 0
	for slot = 1, state.capacity do
		local stack = state.slots[slot]
		if not stack then
			space += limit
		elseif stack.itemId == itemId then
			space += limit - stack.quantity
		end
	end
	if quantity > space then
		return nil, "inventory_full"
	end
	local slots = table.clone(state.slots)
	local remaining = quantity
	-- Existing matching stacks take priority over empty slots.
	for slot = 1, state.capacity do
		local stack = slots[slot]
		if stack and stack.itemId == itemId and remaining > 0 then
			local added = math.min(remaining, limit - stack.quantity)
			slots[slot] = table.freeze({ itemId = itemId, quantity = stack.quantity + added })
			remaining -= added
		end
	end
	for slot = 1, state.capacity do
		if not slots[slot] and remaining > 0 then
			local added = math.min(remaining, limit)
			slots[slot] = table.freeze({ itemId = itemId, quantity = added })
			remaining -= added
		end
	end
	return updated(state, slots, nil), nil
end

function Inventory.remove(state: State, itemId: string, quantity: number): (State?, string?)
	local problem = itemError(state, itemId, quantity)
	if problem then
		return nil, problem
	end
	local total = Inventory.count(state, itemId)
	if total == nil or total < quantity then
		return nil, "insufficient_items"
	end
	local slots = table.clone(state.slots)
	local equipped = table.clone(state.equipped)
	local remaining = quantity
	for slot = 1, state.capacity do
		local stack = slots[slot]
		if stack and stack.itemId == itemId and remaining > 0 then
			local removed = math.min(remaining, stack.quantity)
			remaining -= removed
			if removed == stack.quantity then
				slots[slot] = nil
				for name, equippedSlot in equipped do
					if equippedSlot == slot then
						equipped[name] = nil
					end
				end
			else
				slots[slot] = table.freeze({ itemId = itemId, quantity = stack.quantity - removed })
			end
		end
	end
	return updated(state, slots, equipped), nil
end

function Inventory.move(state: State, from: number, to: number): (State?, string?)
	if not integer(from, 1, state.capacity) or not integer(to, 1, state.capacity) then
		return nil, "invalid_slot"
	end
	local source = state.slots[from]
	if not source then
		return nil, "empty_slot"
	end
	if from == to then
		return state, nil
	end
	local target = state.slots[to]
	if target then
		if target.itemId ~= source.itemId then
			return nil, "incompatible_target"
		end
		if target.quantity + source.quantity > state.definitions[source.itemId].maxStack then
			return nil, "stack_full"
		end
	end
	local slots = table.clone(state.slots)
	local equipped = table.clone(state.equipped)
	slots[from] = nil
	slots[to] = if target then table.freeze({ itemId = source.itemId, quantity = target.quantity + source.quantity }) else source
	for name, slot in equipped do
		if slot == from then
			equipped[name] = to
		end
	end
	return updated(state, slots, equipped), nil
end

function Inventory.equip(state: State, slot: number): (State?, string?)
	if not integer(slot, 1, state.capacity) then
		return nil, "invalid_slot"
	end
	local stack = state.slots[slot]
	if not stack then
		return nil, "empty_slot"
	end
	local name = state.definitions[stack.itemId].equipmentSlot
	if not name then
		return nil, "not_equippable"
	end
	local equipped = table.clone(state.equipped)
	equipped[name] = slot
	return updated(state, nil, equipped), nil
end

function Inventory.unequip(state: State, name: string): (State?, string?)
	if not identifier(name) or not state.equipmentSlots[name] then
		return nil, "invalid_equipment_slot"
	end
	local equipped = table.clone(state.equipped)
	equipped[name] = nil
	return updated(state, nil, equipped), nil
end

function Inventory.getEquipped(state: State, name: string): (Stack?, string?)
	if not identifier(name) or not state.equipmentSlots[name] then
		return nil, "invalid_equipment_slot"
	end
	local slot = state.equipped[name]
	return if slot then state.slots[slot] else nil, nil
end

Inventory.Limits = table.freeze({ capacity = MAX_CAPACITY, quantity = MAX_QUANTITY, identifierLength = 96 })

return table.freeze(Inventory)
