--!strict

local Combat = {}

export type State = { read health: number, read maxHealth: number, read shield: number }
export type Rules = { canDamage: boolean?, flatReduction: number?, multiplier: number?, shieldPiercing: boolean? }
export type Damage = { read state: State, read healthDamage: number, read absorbed: number, read killed: boolean }

local MAX_VALUE = 1000000000

local function bounded(value: unknown, minimum: number, maximum: number): boolean
	return typeof(value) == "number" and value == value and value >= minimum and value <= maximum
end

function Combat.create(maxHealth: number, shield: number?): (State?, string?)
	local initialShield = if shield == nil then 0 else shield
	if not bounded(maxHealth, 0, MAX_VALUE) or maxHealth <= 0 or not bounded(initialShield, 0, MAX_VALUE) then
		return nil, "invalid_health"
	end
	return table.freeze({ health = maxHealth, maxHealth = maxHealth, shield = initialShield }), nil
end

function Combat.damage(state: State, amount: number, rules: Rules?): (Damage?, string?)
	if not bounded(amount, 0, MAX_VALUE) or amount <= 0 then
		return nil, "invalid_damage"
	end
	if rules ~= nil and typeof(rules) ~= "table" then
		return nil, "invalid_rules"
	end
	local configuration: Rules = rules or {}
	if configuration.canDamage ~= nil and typeof(configuration.canDamage) ~= "boolean" then
		return nil, "invalid_rules"
	end
	if configuration.shieldPiercing ~= nil and typeof(configuration.shieldPiercing) ~= "boolean" then
		return nil, "invalid_rules"
	end
	local reduction = if configuration.flatReduction == nil then 0 else configuration.flatReduction
	local multiplier = if configuration.multiplier == nil then 1 else configuration.multiplier
	if not bounded(reduction, 0, MAX_VALUE) or not bounded(multiplier, 0, 100) then
		return nil, "invalid_rules"
	end
	if configuration.canDamage == false then
		return nil, "damage_denied"
	end
	if state.health <= 0 then
		return nil, "target_dead"
	end
	local resolved = math.max(0, amount - reduction) * multiplier
	local absorbed = if configuration.shieldPiercing then 0 else math.min(state.shield, resolved)
	local healthDamage = math.min(state.health, resolved - absorbed)
	local nextState = table.freeze({ health = state.health - healthDamage, maxHealth = state.maxHealth, shield = state.shield - absorbed })
	return table.freeze({ state = nextState, healthDamage = healthDamage, absorbed = absorbed, killed = nextState.health == 0 }), nil
end

function Combat.heal(state: State, amount: number): (State?, string?)
	if not bounded(amount, 0, MAX_VALUE) or amount <= 0 then
		return nil, "invalid_healing"
	end
	if state.health <= 0 then
		return nil, "target_dead"
	end
	return table.freeze({ health = math.min(state.maxHealth, state.health + amount), maxHealth = state.maxHealth, shield = state.shield }), nil
end

Combat.Limits = table.freeze({ health = MAX_VALUE, shield = MAX_VALUE, damage = MAX_VALUE, multiplier = 100 })

return table.freeze(Combat)
