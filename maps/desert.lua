local tileString = [[
ooooooooooooooooooooooooo
o                       o
o                       o
o   r       o    o o    o
o   r       o    o o    o
o   r     o o    o o    o
o   r     o o    o o    o
o   r     o      o o    o
o   r     o      o o    o
o   r     o      o o    o
o         o      ooo    o
o         o    rrr      o
o              rrr      o
o   rrrrrrrrrrrrrr      o
o   rrrrrrrrrrrrrr      o
o                  b    o
o                       o
ooooooooooooooooooooooooo
]]

local quadInfo = { 
  { ' ',  0,  0 }, -- yellow sand
  { 'r',  0, 32 }, -- orange sand, obstacle
  { 'o', 32,  0 }, -- red sand, slow sand
  { 'b', 32, 32 }, -- black sand, goal
}

newMap(32,32,'/images/sands.png', tileString, quadInfo)
