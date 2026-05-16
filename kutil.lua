
--copy this file to 'C:\Program Files (x86)\Lua\5.1\lua'
--and require 'kutil'

local io = require'io'

module('kutil', package.seeall)
--@{ util
-------------------------------------------------------------------------------
local tbl_printed = {}

-------------------------------------------------------------------------------
local function print_table_rcv(var, depth)

   if tbl_printed[var] then
       return
   end

   tbl_printed[var] = true
   local str = string.rep('-', depth*4)

   for k,v in pairs(var) do

       print(str, k, v)
       if type(v) == 'table' then
           print_table_rcv(v, depth + 1)
       end

   end

   if 1 == depth then tbl_printed = {} end
end

-------------------------------------------------------------------------------
-- print table recursively
-------------------------------------------------------------------------------
function print_table(var)

   print(var)
   if type(var) == 'table' then
       print_table_rcv(var, 1)
   end

end
--@}


function printf(fmt, ...)
   print(string.format(fmt, ...))
end

function print_array(arr)
   for i,v in ipairs(arr) do
       printf('[%d] : "%s"', i,v)
   end
end

-------------------------------------------------------------------------------
-- line iterator

--[[ example
local k = require'kutil'
str = require'str'
for n,l in k.lines(str) do
   print(n, l)
end
--]]
-------------------------------------------------------------------------------
function lines (str)
   local i = 1
   local s = 1
   local e = string.find(str, '\n')

   return
   function ()

       if not s then
           return nil
       elseif not e then
           local from,to = s, -1
           s = nil
           return i, string.sub(str,from,to)
       end


       local n = i
       local from,to = s, e-1
       s = e+1
       e = string.find(str, '\n', s)
       i = i+1
       return n, string.sub(str,from,to)
   end
end


function trim(s)
 -- from PiL2 20.4
 return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function startwith(s, w)
   return (string.find(s, w) == 1)
end

--kutil.print_array(kutil.split('518    연습문제 하이노탑', '%s+'))
function split(str, pat)
   pat = pat or '%s+'
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
       if s ~= 1 or cap ~= "" then
           table.insert(t,cap)
       end
       last_end = e+1
       s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
       cap = str:sub(last_end)
       table.insert(t, cap)
   end
   return t
end

function starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

function ends(String,End)
  return End=='' or string.sub(String,-string.len(End))==End
end

function repeats(s, n) return n > 0 and s .. repeats(s, n-1) or "" end

function shallowcopy(orig)
   local orig_type = type(orig)
   local copy
   if orig_type == 'table' then
       copy = {}
       for orig_key, orig_value in pairs(orig) do
           copy[orig_key] = orig_value
       end
   else -- number, string, boolean, etc
       copy = orig
   end
   return copy
end

function arraycopy(orig)
   local copy = {}

   for i,v in ipairs(orig) do
       copy[i] = v
   end

   return copy
end


function utf8charbytes (s, i)
   -- argument defaults
   i = i or 1
   local c = string.byte(s, i)

   -- determine bytes needed for character, based on RFC 3629
   if c > 0 and c <= 127 then
       -- UTF8-1
       return 1
   elseif c >= 194 and c <= 223 then
       -- UTF8-2
       local c2 = string.byte(s, i + 1)
       return 2
   elseif c >= 224 and c <= 239 then
       -- UTF8-3
       local c2 = s:byte(i + 1)
       local c3 = s:byte(i + 2)
       return 3
   elseif c >= 240 and c <= 244 then
       -- UTF8-4
       local c2 = s:byte(i + 1)
       local c3 = s:byte(i + 2)
       local c4 = s:byte(i + 3)
       return 4
   end
end

-- returns the number of characters in a UTF-8 string
function utf8len (s)
   local pos = 1
   local bytes = string.len(s)
   local len = 0

   while pos <= bytes and len ~= chars do
       local c = string.byte(s,pos)
       len = len + 1

       pos = pos + utf8charbytes(s, pos)
   end

   if chars ~= nil then
       return pos - 1
   end

   return len
end

function save(fullpath, str, overwrite)
   overwrite = overwrite or false

   if not overwrite then
       local f = io.open(fullpath, 'r')
       if f then
           f:close()
           print'error already exist'
           return
       end
   end

   local f,err = io.open(fullpath, 'wt')
   if f then
       f:write(str)
       f:close()
   else
       print('error', err)
   end
end


function load(fullpath)
   local f = io.open(fullpath, 'r')
   if f then
       local content = f:read'*all'
       f:close()
       return content
   end
end




local function getKeys(tbl)
   local hash = {}
   for k in pairs(tbl) do
       if type(k) ~= 'number' or k < 1 or k > #tbl then
           hash[#hash + 1] = k
       end
   end

   table.sort(hash)
   return hash, #tbl
end
local function rvalueString(value)
   if string.find(value, '"') and string.find(value, "'")then
       return string.format("[==[%s]==]", value)
   elseif string.find(value, '"') then
       return string.format("'%s'", value)
   end

   return string.format('"%s"', value)
end

local function table2stringRecursive(lines, tbl, depth)
   local h,num = getKeys(tbl)
   local indent = string.rep('\t', depth)
  
   if depth == 1 and #h > 0 then
       lines[#lines + 1] = ''
   end

   for i,k in ipairs(h) do
       local value = tbl[k]
       local vType = type(value)
       local kType = type(k)

       local kStr
       if kType == 'string' then
           if string.find(k, '%s+') then
               kStr = string.format('["%s"]', tostring(k))
           else
               kStr = k
           end
       else
           kStr = string.format('[%s]', tostring(k))
       end

       local vStr = (vType == 'string') and rvalueString(value) or tostring(value)

       if kType == 'string' or kType == 'number' then
           if vType == 'table' then
               lines[#lines + 1] = string.format('%s%s = {', indent, kStr)
               table2stringRecursive(lines, value, depth + 1)
               lines[#lines + 1] = string.format('%s},', indent)
           else
               lines[#lines + 1] = string.format('%s%s = %s,', indent, kStr, vStr)
           end
       else
           print('key type error : '..kType, k)
       end
   end

   if depth == 1 then
       lines[#lines + 1] = ''
   end

   for i=1, num do
       local value = tbl[i]
       local vType = type(value)
       local vStr = (vType == 'string') and rvalueString(value) or tostring(value)

       if vType == 'table' then
           if depth == 1 then
               lines[#lines + 1] = string.format('%s{ ---------------------------------------- %02d', indent, i)
           else
               lines[#lines + 1] = string.format('%s{', indent)
           end
           table2stringRecursive(lines, value, depth + 1)
           lines[#lines + 1] = string.format('%s},', indent)
       else
           lines[#lines + 1] = string.format('%s%s,', indent, vStr)
       end

   end
end


function table2string(tbl, depth)
   depth = depth or 0
   local indent = string.rep('\t', depth)
   local lines = {indent..'{'}
   table2stringRecursive(lines, tbl, depth + 1)
   lines[#lines + 1] = indent..'}'
   return table.concat(lines, '\n')
end
  
return kutil

