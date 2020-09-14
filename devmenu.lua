local slab = require "libs.slab"
local resolution = require "libs.grove.resolution"

dbg = {
	load_jumpscares = true,
	load_voices = true,
	perspective_depth = 3.5,
	frameskip = true,
	fps_cap = true,
	prevent_big_delta = true,
	cn_ai_limit = 20,
	vis_effects = "Default",
	fullscreen_mode = "Borderless windowed",
	block_update = false,
	sub_font = "alienleague",
	show_static = true,
	show_game_ui = true,
	discord_rpc = true,

	blur_type = "Gaussian blur",
	gaussian_sigma = 5,

	fastgaussian_taps = 11,
	fastgaussian_offset = 2,
	fastgaussian_sigma = 4,

	box_radius_x = 3,
	box_radius_y = 3,

}

debugmenu = {
	init = slab.Initialize,
	update = slab.Update,
	draw = slab.Draw,
}

local store_mgpos = nil
local mousegetpos = function()
	return resolution.toScreen(store_mgpos())
end

local layoutOptions = {Columns = 2, ExpandW = false}
local function field(name)
	slab.EndLayout()
    slab.BeginLayout("l1", layoutOptions)
    slab.SetLayoutColumn(1)
    slab.Text(name)
    slab.SameLine()
	slab.SetLayoutColumn(2)
end

function debugmenu.init(args)
	slab.SetINIStatePath(nil)
	slab.SetScrollSpeed(20)
	slab.DisableDocks({"Left", "Right", "Bottom"})
	slab.Initialize(args)
end

local cmdhistoric = "> INaS command line"
local show_console = false
local enable_console = false
local completionList = {}

-- ANCHOR Auto completion
local function findMatchingFields(t, match)
	lume.clear(completionList)

	for name, value in pairs(t) do
		local start = name:find(match, 1, true)

		if start and start == 1 then
			toLast(completionList, name)
		end
	end
end

local function isTable(names)
	local ctable = nil
	
	for i, name in ipairs(names) do
		local value = (ctable or _G)[name]
		
		if type(value) == "table" then
			ctable = value
		else
			return nil
		end
	end
	return ctable
end

local lastWord = ""
local function findCompletion(word)
	if word == lastWord then
		return
	end
	lastWord = word

	--Disassemble the typed text
	local exploded = string.explode(word, ".", true)
	local last = exploded[#exploded]

	if #exploded == 1 then
		--Match with global variables
		findMatchingFields(_G, last)
	else
		--Find if the text is pointing to a table and return it
		table.remove(exploded, #exploded)
		local t = isTable(exploded)

		if t then
			--Match with previous table fields
			findMatchingFields(t, last)
		end
	end
end

local tooltip = ""
local file_to_hotswap = ""
local popuptestid = 0
function debugmenu.update(dt)
	store_mgpos = lm.getPosition
	lm.getPosition = mousegetpos

	slab.Update(dt)

	--Defines if the menu is focused
	if slab.IsMouseClicked() then
		debugmenu.focus = not slab.IsVoidClicked()
	end

	--Main window
	slab.BeginWindow("dbg", {Title = "Debug menu", X = 475, W = 525, H = 375, AutoSizeWindow = false})

	if slab.Button("General", {Disabled = not show_console}) then
		show_console = false
	end
	slab.SameLine()
	if slab.Button("console", {Disabled = show_console or not enable_console}) then
		show_console = true
	end
	slab.Separator()

	local ww, wh = slab.GetWindowActiveSize()

	if show_console then

		-- ANCHOR Console
		slab.Input("historic", {Text = cmdhistoric, W = ww, H = wh - 65, ReadOnly = true, Align = "left", MultiLine = true})
		
		if slab.Input("cmd", {Text = "", ReturnOnText = false, W = ww, H = 25, Align = "left", Tooltip = tooltip}) then
			
			local text = slab.GetInputText()
			local ok, err = pcall(loadstring(text))

			local out = ""
			if err then
				out = "\n"..tostring(err)
			end

			cmdhistoric = cmdhistoric.."\n\n> "..text..out
		end
		local text = slab.GetInputText()
		local _, last = string.match(text, "^(.-)%s(%S+)$")
		last = last or text

		if last and last ~= "" then
			findCompletion(last)
			tooltip = table.concat(completionList, "\n")
		else
			lume.clear(completionList)
			tooltip = ""
		end

	else
		slab.BeginLayout("l1", layoutOptions)

		-- ANCHOR Fields
		field("Load jumpscares:")
		if slab.CheckBox(dbg.load_jumpscares) then
			dbg.load_jumpscares = not dbg.load_jumpscares
		end

		field("Load voices:")
		if slab.CheckBox(dbg.load_voices) then
			dbg.load_voices = not dbg.load_voices
		end

		slab.Separator()

		field("Display visual effects:")
		if slab.BeginComboBox("vfx", {Selected = dbg.vis_effects}) then

			if slab.TextSelectable("Default") then
				dbg.vis_effects = "Default"
				chain.setActive(lowgraphics - boolto(isMobile) < 3)
			end
			if slab.TextSelectable("Always") then
				dbg.vis_effects = "Always"
				chain.setActive(true)
			end
			if slab.TextSelectable("Never") then
				dbg.vis_effects = "Never"
				chain.setActive(false)
			end
			slab.EndComboBox()
		end

		field("Perspective depth:")
		if slab.Input("pdepth", {Text = tostring(dbg.perspective_depth), NumbersOnly = true}) then
			dbg.perspective_depth = slab.GetInputNumber()
			perspective:send("depth", dbg.perspective_depth)
		end

		field("Subtitles font:")
		if slab.BeginComboBox("sfnt", {Selected = dbg.sub_font}) then

			if slab.TextSelectable("Alien League") then
				dbg.sub_font = "alienleague"
			end
			if slab.TextSelectable("Emulogic") then
				dbg.sub_font = "emulogic"
			end
			if slab.TextSelectable("OCR A") then
				dbg.sub_font = "OCRAEXT"
			end
			if slab.TextSelectable("Small Font") then
				dbg.sub_font = "small_font"
			end
			if slab.TextSelectable("Vermin Vibes") then
				dbg.sub_font = "vermin vibes"
			end
			slab.EndComboBox()
		end

		field("Show static:")
		if slab.CheckBox(dbg.show_static) then
			dbg.show_static = not dbg.show_static
		end

		field("Show in-game UI:")
		if slab.CheckBox(dbg.show_game_ui) then
			dbg.show_game_ui = not dbg.show_game_ui
		end

		field("Trophy popup test:")
		if slab.Input("popid", {Text = tostring(popuptestid), NumbersOnly = true, MinNumber = 1, MaxNumber = 11, ReturnOnText = true, W = 75}) then
			popuptestid = slab.GetInputNumber()
		end
		slab.SameLine()
		if slab.Button("Popup", {W = 75}) then
			trophies:popup(trophies.list[popuptestid])
		end

		slab.Separator()

		field("Default blur type:")
		if slab.BeginComboBox("dbt", {Selected = dbg.blur_type}) then
			if slab.TextSelectable("Gaussian blur") then
				dbg.blur_type = "Gaussian blur"

				blur = moonshine(moonshine.effects.gaussianblur)
				blur.gaussianblur.sigma = dbg.gaussian_sigma

				imgui.clearcachedimages()
			end
			
			if slab.TextSelectable("Fast gaussian blur") then
				dbg.blur_type = "Fast gaussian blur"

				blur = moonshine(moonshine.effects.fastgaussianblur)
				blur.fastgaussianblur.taps = dbg.fastgaussian_taps
				blur.fastgaussianblur.offset = dbg.fastgaussian_offset
				blur.fastgaussianblur.sigma = dbg.fastgaussian_sigma

				imgui.clearcachedimages()
			end
			
			if slab.TextSelectable("Box blur") then
				dbg.blur_type = "Box blur"

				blur = moonshine(moonshine.effects.boxblur)
				blur.boxblur.radius_x = dbg.box_radius_x
				blur.boxblur.radius_y = dbg.box_radius_y

				imgui.clearcachedimages()
			end
			slab.EndComboBox()
		end

		if dbg.blur_type == "Gaussian blur" then
			field("Sigma:")
			if slab.Input("gsigma", {Text = tostring(dbg.gaussian_sigma), NumbersOnly = true, ReturnOnText = true}) then
				dbg.gaussian_sigma = slab.GetInputNumber()

				blur.gaussianblur.sigma = dbg.gaussian_sigma
				imgui.clearcachedimages()
			end
		end

		if dbg.blur_type == "Fast gaussian blur" then
			field("Taps:")
			if slab.Input("fgtaps", {Text = tostring(dbg.fastgaussian_taps), NumbersOnly = true, ReturnOnText = true}) then
				dbg.fastgaussian_taps = max(slab.GetInputNumber(), 3)

				blur.fastgaussianblur.taps = dbg.fastgaussian_taps
				imgui.clearcachedimages()
			end

			field("Offset:")
			if slab.Input("fgoffset", {Text = tostring(dbg.fastgaussian_offset), NumbersOnly = true, ReturnOnText = true}) then
				dbg.fastgaussian_offset = slab.GetInputNumber()

				blur.fastgaussianblur.offset = dbg.fastgaussian_offset
				imgui.clearcachedimages()
			end

			field("Sigma:")
			if slab.Input("fgsigma", {Text = tostring(dbg.fastgaussian_sigma), NumbersOnly = true, ReturnOnText = true}) then
				dbg.fastgaussian_sigma = slab.GetInputNumber()

				blur.fastgaussianblur.sigma = dbg.fastgaussian_sigma
				imgui.clearcachedimages()
			end
		end

		if dbg.blur_type == "Box blur" then
			field("Radius (X,Y):")
			if slab.Input("bradx", {Text = tostring(dbg.box_radius_x), NumbersOnly = true, ReturnOnText = true, W = 75}) then
				dbg.box_radius_x = slab.GetInputNumber()

				blur.boxblur.radius_x = dbg.box_radius_x
				imgui.clearcachedimages()
			end
			slab.SameLine()
			if slab.Input("brady", {Text = tostring(dbg.box_radius_y), NumbersOnly = true, ReturnOnText = true, W = 75}) then
				dbg.box_radius_y = slab.GetInputNumber()

				blur.boxblur.radius_y = dbg.box_radius_y
				imgui.clearcachedimages()
			end
		end

		slab.Separator()
		
		field("Fullscreen:")
		if slab.BeginComboBox("fscr", {Selected = dbg.fullscreen_mode}) then
			local isfs, fstype = love.window.getFullscreen()
			
			if slab.TextSelectable("Exclusive") then
				love.window.setFullscreen(true, "exclusive")
				dbg.fullscreen_mode = "Exclusive"
			end
			
			if slab.TextSelectable("Borderless windowed") then
				love.window.setFullscreen(true, "desktop")
				dbg.fullscreen_mode = "Borderless windowed"
			end
			
			if slab.TextSelectable("Off") then
				love.window.setFullscreen(false)
				dbg.fullscreen_mode = "Off"
			end
			slab.EndComboBox()
		end
		
		field("Vsync:")
		local vsync = love.window.getVSync()
		if slab.CheckBox(vsync == 1) then
			love.window.setVSync((vsync + 1) % 2)
		end
		
		field("Mobile compatibility:")
		if slab.CheckBox(isMobile) then
			isMobile = not isMobile
		end

		field("Framerate-independent speed:")
		if slab.CheckBox(dbg.frameskip) then
			dbg.frameskip = not dbg.frameskip
		end

		field("Prevent big delta times:")
		if slab.CheckBox(dbg.prevent_big_delta) then
			dbg.prevent_big_delta = not dbg.prevent_big_delta
		end

		field("Limit framerate to 60 FPS:")
		if slab.CheckBox(dbg.fps_cap) then
			dbg.fps_cap = not dbg.fps_cap
		end

		field("Block update:")
		if slab.CheckBox(dbg.block_update) then
			dbg.block_update = not dbg.block_update
		end

		field("Hotswap file")
		if slab.Input("hotname", {Text = file_to_hotswap, ReturnOnText = true, W = 125}) then
			file_to_hotswap = slab.GetInputText()
		end
		slab.SameLine()
		if slab.Button("Hotswap", {W = 70}) then
			lume.hotswap(file_to_hotswap)
		end

		slab.Separator()

		field("AI limit:")
		if slab.Input("ailimit", {Text = tostring(dbg.cn_ai_limit), NumbersOnly = true, ReturnOnText = true}) then
			dbg.cn_ai_limit = slab.GetInputNumber()
		end

		field("Enable Discord Rich Presence:")
		if slab.CheckBox(dbg.discord_rpc) then
			dbg.discord_rpc = not dbg.discord_rpc

			if rpc then
				rpc.clearPresence()
			end
		end

		field("Enable developer console:")
		if slab.CheckBox(enable_console) then
			enable_console = not enable_console

			trophies.achieve = fnull
			savegame = fnull
			loadgame = fnull
			gamejolt.username = ""
			gamejolt.userToken = ""
			gamejolt.gameID = 0
			gamejolt.gameKey = ""
			gamejolt.isLoggedIn = false
		end
		
		slab.EndLayout()
		slab.NewLine()
		if savegame ~= fnull then
			slab.Textf("WARNING: If you enable the developer console, the game won't save your progress and you won't get any trophies for this session. To restore these features, you need to reopen the game or restart by pressing\"F2\"")
		else
			slab.Textf("Your save data and trophies are disabled.")
		end
	end
	slab.EndWindow()

	lm.getPosition = store_mgpos
end