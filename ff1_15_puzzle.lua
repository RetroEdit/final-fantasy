--
-- Display some info about FF1 GBA's 15-puzzle when it's active.
-- Extracts the current puzzle's tile coords (for documentation purposes).
-- More usefully, it shows the possible prizes for the current puzzle.
-- 
-- Author: RetroEdit
-- 
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at https://mozilla.org/MPL/2.0/.
--



--
-- If uncommented, this section will output the RNG seed for the upcoming 15-puzzle
-- Execution callbacks are necessary because RNG is partially seeded by VCOUNT,
-- which is dependent on the exact scanline the code runs.
--
-- mGBA's execute callbacks only work in BizHawk 2.4.1 or later.
--

-- local function fifteen_puzzle_seed()
    -- local reg = emu.getregisters()
    -- console.log(string.format("RNG: %8X, VCOUNT: %2X", reg["R0"], reg["R1"]))
-- end

-- event.onmemoryexecute(fifteen_puzzle_seed, 0x0803C23E, "15_puzzle_seed")

local PIX_FONT_X, PIX_FONT_Y = 4, 7
local GBA_PIX_WIDTH = math.floor(240 / PIX_FONT_X)
local GBA_PIX_HEIGHT = math.floor(160 / PIX_FONT_Y)
local function pix(x, y, s, fg, bg)
    gui.pixelText(x * PIX_FONT_X, y * PIX_FONT_Y, s, fg, bg)
end

-- Lua 5.1 makes it really messy to do seemingly simple operations,
-- because the only number type is double precision floating point.
-- Ideally, this would be as simple as multiple, add, modulo.
function next_rand(rng)
    local res = 0
    local b = 0x6C078965
    while b ~= 0 do
        if bit.band(b, 1) ~= 0 then
            res = bit.band(res + rng, 0xFFFFFFFF)
        end
        rng = bit.band(2 * rng, 0xFFFFFFFF)
        b = bit.rshift(b, 1)
    end
    rng = bit.band(res + 7, 0xFFFFFFFF)
    return rng
end

memory.usememorydomain("System Bus")

local puzzle_tiles_base = 0x02011C9C
local function draw_puzzle(y_offset)
    if y_offset == nil then
        y_offset = 0
    end
    local cursor = memory.readbyte(0x02011D1C)
    for i=15,0,-1 do
        local a = puzzle_tiles_base + 8 * i
        local tx, ty = memory.readbyte(a), memory.readbyte(a+4)
        tx = math.floor(tx / 24)
        ty = math.floor(ty / 24)
        
        local fg = "white"
        if tx + ty * 4 == cursor then
            fg = "lightgreen"
        end
        
        local num = string.format("%1X", i + 1)
        if num == '10' then
            num = '_'
        end
        pix(
            GBA_PIX_WIDTH - 4 + tx,
            ty + y_offset,
            num,
            fg
        )
    end
end

local place1 = {[0]="Megalixir", "Megalixir"}
local place2 = {[0]="Turbo Ether", "Elixir", "Remedy", "Hermes's Shoes", "Emergency Exit"}
local place3 = {[0]="Spider's Silk", "White Fang", "Red Fang", "Blue Fang", "Red Curtain", "White Curtain", "Blue Curtain", "Vampire Fang", "Cockatrice Claw"}
local participation = {[0]="Potion", "Antidote", "Gold Needle", "Ether", "Eye Drops", "Echo Grass", "Phoenix Down", "100 Gil"}

local prev_rng = nil
local prize1, prize2, prize3, extra_prize, consolation = nil, nil, nil, nil, nil
local puzzle_base = 0x0200EDA8
local function predict_prizes(y_offset)
    local rng = memory.read_u32_le(0x02001A18)
    local puzzle_state = memory.read_s32_le(puzzle_base + 0x2EE8)
    if rng ~= prev_rng and puzzle_state <= 1 then
        local main_prize_rng = next_rand(rng)
        local extra_prize_rng = next_rand(main_prize_rng)
        -- Using magic numbers like this is inideal
        prize1 = "1" .. string.format('%16s', place1[main_prize_rng % 2])
        prize2 = "2" .. string.format('%16s', place2[main_prize_rng % 5])
        prize3 = "3" .. string.format('%16s', place3[main_prize_rng % 9])
        extra_prize = "+" .. string.format('%16s', 
            participation[extra_prize_rng % 8]
        )
        -- Prize if you don't place
        consolation = "X" .. string.format('%16s', 
            participation[main_prize_rng % 8]
        )
        prev_rng = rng
    end
    pix(GBA_PIX_WIDTH - 6, y_offset, "Prizes")
    pix(GBA_PIX_WIDTH - 17, y_offset + 1, prize1)
    pix(GBA_PIX_WIDTH - 17, y_offset + 2, prize2)
    pix(GBA_PIX_WIDTH - 17, y_offset + 3, prize3)
    pix(GBA_PIX_WIDTH - 17, y_offset + 4, extra_prize)
    pix(GBA_PIX_WIDTH - 17, y_offset + 5, consolation)
end

while true do
    local rng = memory.read_u32_le(0x02001A18)
    pix(GBA_PIX_WIDTH - 8 - 5, 0, "RNG: " .. string.format('%8X',
        rng
    ))

    -- Checks the call stack for the 15-puzzle loop return address
    -- Probably improvable (could activate earlier), but works well enough.
    if memory.read_u32_le(0x03005E8C) == 0x08014977 then
        draw_puzzle(2)
        predict_prizes(2 + 4 + 1)
    end

    emu.frameadvance()
end
