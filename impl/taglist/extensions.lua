-- This file provide extensions 

local capi = { screen = screen, client=client}
local setmetatable = setmetatable
local ipairs,pairs = ipairs,pairs
local type         = type
local radical   = require( "radical"    )
local beautiful = require( "beautiful"  )
local awful     = require( "awful"      )
local util      = require( "awful.util" )
local wibox     = require( "wibox"      )
local taglist = nil

local module = {}

local current_client = nil

local classes = {}
local global = {}

local extension_list = {}

local per_m,per_glob,per_this = nil
local function persistence_menu(ext)
  if not taglist then
    taglist = require("radical.impl.taglist")
  end
  if not per_m then
    per_m = radical.context{}
    per_glob  = per_m:add_item{text= "All clients"      ,checkable = true , button1 = function()
      local i1 = taglist.item(current_client)
      if i1 and (not i1._internal.has_widget or not i1._internal.has_widget[ext]) then
        i1:add_suffix(ext(current_client))
        i1._internal.has_widget = i1._internal.has_widget or {}
        i1._internal.has_widget[ext] = true
      end
      for k,v in ipairs(capi.client.get()) do
        local i2 = taglist.item(v)
        if i2 and  (not i2._internal.has_widget or not i2._internal.has_widget[ext]) then
          i2:add_suffix(ext(v))
          i2._internal.has_widget = i2._internal.has_widget or {}
          i2._internal.has_widget[ext] = true
        end
      end
      per_glob.checked = true
    end}
    per_this  = per_m:add_item{text= "This client only" ,checkable = true, button1 = function()
      local i1 = taglist.item(current_client)
      if i1 and (not i1._internal.has_widget or not i1._internal.has_widget[ext]) then
        i1:add_suffix(ext(current_client))
        i1._internal.has_widget = i1._internal.has_widget or {}
        i1._internal.has_widget[ext] = true
      end
      per_this.checked = true
    end}
  end

  -- Check the checkboxes
  local i1 = taglist.item(current_client)
  if global[ext] then
    per_glob.checked  = true
    per_this.checked  = false
  elseif classes[ext] and classes[ext][current_client.class] then
    per_this.checked  = false
    per_glob.checked  = false
  elseif i1 and i1._internal.has_widget and i1._internal.has_widget[ext] then
    per_this.checked  = true
    per_glob.checked  = false
  else
    per_this.checked  = false
    per_glob.checked  = false
  end

  return per_m
end

local ext_list_m = nil
local function extension_list_menu()
  if not ext_list_m then
    ext_list_m = radical.context{}
    for k,v in pairs(extension_list) do
      ext_list_m:add_item{text=k,sub_menu=function() return persistence_menu(v) end}
    end
  end
  return ext_list_m
end

local ext_m = nil
function module.extensions_menu(c)
  current_client = c
  if not ext_m then
    ext_m = radical.context{}
    ext_m:add_item{text="Overlay widget", sub_menu=extension_list_menu() }
    ext_m:add_item{text="Prefix widget" , sub_menu=extension_list_menu() }
    ext_m:add_item{text="Suffix widget" , sub_menu=extension_list_menu() }
  end
  return ext_m
end

function module.add(name,f)
  extension_list[name] = f
  if ext_list_m then
    ext_list_m:add_item{text=name,sub_menu=function() return persistence_menu(f) end}
  end
end

return setmetatable(module, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;