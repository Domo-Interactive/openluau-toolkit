--!strict

local Progression = {}

export type Rewards = { [number]: { [string]: number } }
export type State = { read experience: number, read level: number, read thresholds: { number }, read rewards: Rewards }
export type Grant = { read level: number, read id: string, read amount: number }
export type Award = { read state: State, read gainedLevels: { number }, read rewards: { Grant }, read acceptedExperience: number }

local MAX_EXPERIENCE = 1000000000

local function integer(value: unknown, minimum: number, maximum: number): boolean
	return typeof(value) == "number" and value == value and value >= minimum and value <= maximum and value % 1 == 0
end

function Progression.create(thresholds: { number }, rewards: Rewards?): (State?, string?)
	if typeof(thresholds) ~= "table" or (rewards ~= nil and typeof(rewards) ~= "table") then
		return nil, "invalid_configuration"
	end
	local count = 0
	for index in thresholds do
		count += 1
		if not integer(index, 1, 1000) or count > 1000 then
			return nil, "invalid_curve"
		end
	end
	if count == 0 or thresholds[1] ~= 0 then
		return nil, "invalid_curve"
	end
	local copied: { number } = {}
	local previous = -1
	for level = 1, count do
		local threshold = thresholds[level]
		if not integer(threshold, 0, MAX_EXPERIENCE) or threshold <= previous then
			return nil, "invalid_curve"
		end
		copied[level] = threshold
		previous = threshold
	end
	local copiedRewards: Rewards = {}
	for level, levelRewards in rewards or {} do
		if not integer(level, 2, count) or typeof(levelRewards) ~= "table" then
			return nil, "invalid_reward"
		end
		local rewardCount = 0
		local entries: { [string]: number } = {}
		for id, amount in levelRewards do
			rewardCount += 1
			if typeof(id) ~= "string" or #id == 0 or #id > 96 or not integer(amount, 1, MAX_EXPERIENCE) or rewardCount > 64 then
				return nil, "invalid_reward"
			end
			entries[id] = amount
		end
		copiedRewards[level] = table.freeze(entries)
	end
	return table.freeze({ experience = 0, level = 1, thresholds = table.freeze(copied), rewards = table.freeze(copiedRewards) }), nil
end

function Progression.award(state: State, amount: number): (Award?, string?)
	if not integer(amount, 0, MAX_EXPERIENCE) then
		return nil, "invalid_experience"
	end
	local experience = math.min(state.experience + amount, state.thresholds[#state.thresholds])
	local level = state.level
	local gained: { number } = {}
	local grants: { Grant } = {}
	while level < #state.thresholds and experience >= state.thresholds[level + 1] do
		level += 1
		table.insert(gained, level)
		local levelRewards = state.rewards[level]
		if levelRewards then
			-- Sort IDs so reward delivery has a reproducible order.
			local ids: { string } = {}
			for id in levelRewards do
				table.insert(ids, id)
			end
			table.sort(ids)
			for _, id in ids do
				table.insert(grants, table.freeze({ level = level, id = id, amount = levelRewards[id] }))
			end
		end
	end
	local nextState = table.freeze({ experience = experience, level = level, thresholds = state.thresholds, rewards = state.rewards })
	return table.freeze({
		state = nextState,
		gainedLevels = table.freeze(gained),
		rewards = table.freeze(grants),
		acceptedExperience = experience - state.experience,
	}), nil
end

function Progression.toNextLevel(state: State): number
	local nextThreshold = state.thresholds[state.level + 1]
	return if nextThreshold then nextThreshold - state.experience else 0
end

Progression.Limits = table.freeze({ levels = 1000, experience = MAX_EXPERIENCE, rewardsPerLevel = 64 })

return table.freeze(Progression)
