-- bouncer.lua
-- Atomic slot decrement for drop traffic control.
-- KEYS[1] = drop capacity key (e.g. "drop:genesis:2025:slots")
-- Returns:
--   1  = slot acquired
--   0  = sold out (no slots remaining)

local current = redis.call('GET', KEYS[1])
if current == false then
  return 0
end

local slots = tonumber(current)
if slots <= 0 then
  return 0
end

redis.call('DECR', KEYS[1])
return 1
