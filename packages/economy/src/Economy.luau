--!strict

local Economy = {}

export type Wallet = { read balance: number, read maxBalance: number }
export type Offer = { read itemId: string, read price: number, read maxQuantity: number }
export type OfferInput = { itemId: string, price: number, maxQuantity: number? }
export type Catalogue = { [string]: Offer }
export type AddItems<T> = (T, string, number) -> (T?, string?)
export type Purchase<T> = { read wallet: Wallet, read inventory: T, read offerId: string, read itemId: string, read quantity: number, read totalCost: number }

local MAX_BALANCE = 1000000000000
local MAX_PRICE = 1000000000
local MAX_QUANTITY = 1000000

local function integer(value: unknown, minimum: number, maximum: number): boolean
	return typeof(value) == "number" and value == value and value >= minimum and value <= maximum and value % 1 == 0
end

local function identifier(value: unknown): boolean
	return typeof(value) == "string" and #value > 0 and #value <= 96
end

function Economy.create(balance: number?, maxBalance: number?): (Wallet?, string?)
	local initial = if balance == nil then 0 else balance
	local maximum = if maxBalance == nil then MAX_BALANCE else maxBalance
	if not integer(maximum, 0, MAX_BALANCE) or not integer(initial, 0, maximum) then
		return nil, "invalid_balance"
	end
	return table.freeze({ balance = initial, maxBalance = maximum }), nil
end

function Economy.credit(wallet: Wallet, amount: number): (Wallet?, string?)
	if not integer(amount, 0, MAX_BALANCE) then
		return nil, "invalid_amount"
	end
	if amount > wallet.maxBalance - wallet.balance then
		return nil, "balance_limit"
	end
	return table.freeze({ balance = wallet.balance + amount, maxBalance = wallet.maxBalance }), nil
end

function Economy.debit(wallet: Wallet, amount: number): (Wallet?, string?)
	if not integer(amount, 0, MAX_BALANCE) then
		return nil, "invalid_amount"
	end
	if amount > wallet.balance then
		return nil, "insufficient_funds"
	end
	return table.freeze({ balance = wallet.balance - amount, maxBalance = wallet.maxBalance }), nil
end

function Economy.createCatalogue(offers: { [string]: OfferInput }): (Catalogue?, string?)
	if typeof(offers) ~= "table" then
		return nil, "invalid_catalogue"
	end
	local catalogue: Catalogue = {}
	local count = 0
	for offerId, offer in offers do
		count += 1
		if count > 1024 or not identifier(offerId) or typeof(offer) ~= "table" or not identifier(offer.itemId) then
			return nil, "invalid_offer"
		end
		local maximum = if offer.maxQuantity == nil then MAX_QUANTITY else offer.maxQuantity
		if not integer(offer.price, 0, MAX_PRICE) or not integer(maximum, 1, MAX_QUANTITY) then
			return nil, "invalid_offer"
		end
		catalogue[offerId] = table.freeze({ itemId = offer.itemId, price = offer.price, maxQuantity = maximum })
	end
	return table.freeze(catalogue), nil
end

-- The injected adder must return a new inventory without mutating its input.
-- Commit both returned values together in the consuming game's server code.
function Economy.purchase<T>(wallet: Wallet, inventory: T, catalogue: Catalogue, offerId: string, quantity: number, addItems: AddItems<T>): (Purchase<T>?, string?)
	if not identifier(offerId) then
		return nil, "invalid_offer_id"
	end
	local offer = catalogue[offerId]
	if not offer then
		return nil, "unknown_offer"
	end
	if not integer(quantity, 1, offer.maxQuantity) then
		return nil, "invalid_quantity"
	end
	if typeof(addItems) ~= "function" then
		return nil, "invalid_inventory_adapter"
	end
	-- These configured bounds keep integer multiplication below 2^53.
	local cost = offer.price * quantity
	if cost > wallet.balance then
		return nil, "insufficient_funds"
	end
	local nextInventory, inventoryError = addItems(inventory, offer.itemId, quantity)
	if nextInventory == nil then
		return nil, inventoryError or "inventory_rejected"
	end
	local nextWallet = table.freeze({ balance = wallet.balance - cost, maxBalance = wallet.maxBalance })
	return table.freeze({ wallet = nextWallet, inventory = nextInventory, offerId = offerId, itemId = offer.itemId, quantity = quantity, totalCost = cost }), nil
end

Economy.Limits = table.freeze({ balance = MAX_BALANCE, price = MAX_PRICE, quantity = MAX_QUANTITY, offers = 1024 })

return table.freeze(Economy)
