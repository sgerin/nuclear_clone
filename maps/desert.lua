local tileString = [[
oooooooooooooooooooooooooooooo
o                            o
o                            o
o   r            ooo     o   o
o   r            o o     o   o
o   r     o      o o     o   o
o   r     o      o o     o   o
o   r     o      o o     o   o
o   r     o      o o     o   o
o   r     o      o o     o   o
o         o      ooo     o   o
o         o    rrr       o   o
o              rrr       o   o
o   rrrrrrrrrrrrrr       o   o
o   rrrrrrrrrrrrrr       o   o
o                  b     o   o
o                        o   o
o                        o   o
o                            o
oooooooooooooooooooooooooooooo
]]

--[[local tileString = [[
oooooo
o    o
o    o
o   bo
oooooo
]]--



local quadInfo = { 
  { ' ',  0,  0 }, -- yellow sand
  { 'r',  0, 32 }, -- orange sand, obstacle
  { 'o', 32,  0 }, -- red sand, slow sand
  { 'b', 32, 32 }, -- black sand, goal
}

newMap(32,32,'/images/sands.png', tileString, quadInfo)
