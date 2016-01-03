-- if System.doesFileExist('/3ds/menuhax_manager/menuhax_manager.3dsx') ~= true then error("Menuhax Manager is not installed.") end
-- error(System.currentDirectory())
colours = {
	white = Color.new(255,255,255),
	black = Color.new(0,0,0),
	light_blue = Color.new(155,234,251),
	blue = Color.new(24,192,235),
	background_grey = Color.new(52,71,78),
	title_font_white = Color.new(200,209,214),
	action_bar_grey = Color.new(35,50,57),
	highlight_tile_white = Color.new(210,220,226),
	fab_blue = Color.new(0,172,196),
	dialog_title_black = Color.new(33,33,33),
	dialog_content_grey = Color.new(117,117,117)
}
hi_title_pos = {6, 68, 130, 192, 254}		--y-pos is always 107
title_pos = {20, 82, 144, 206, 268}		--y-pos is always 115, scale factor is always 0.667
Graphics.init()
background = Graphics.loadImage(System.currentDirectory()..'/bottom.png')
top_background = Graphics.loadImage(System.currentDirectory()..'/top.png')
tile = Graphics.loadImage(System.currentDirectory()..'/highlight.png')
next_icon = Graphics.loadImage(System.currentDirectory()..'/next_icon.png')
prev_icon = Graphics.loadImage(System.currentDirectory()..'/prev_icon.png')
no_icon = Graphics.loadImage(System.currentDirectory()..'/no_icon.png')
install_dialog = Graphics.loadImage(System.currentDirectory()..'/install_dialog.png')
no_themes_dialog = Graphics.loadImage(System.currentDirectory()..'/no_themes_dialog.png')
no_menuhax_dialog = Graphics.loadImage(System.currentDirectory()..'/no_menuhax_dialog.png')
console = Console.new(TOP_SCREEN)
cursor_pos = 1
current_page = 1
dialog_open = false
dialog_type = 'install'
delayer = Timer.new()
font = Font.load(System.currentDirectory()..'/Roboto-Bold.ttf')
Font.setPixelSizes(font, 16)
preview_state = 0		-- 0: No preview shown, 1: Top Screen Preview, 2: Bottom Screen Preview
preview_timer = Timer.new()

System.currentDirectory("/Themes/")

function GetThemes()
	local folders = {}
	for index, file in pairs(System.listDirectory(System.currentDirectory())) do
		if file.directory and System.doesFileExist(System.currentDirectory() .. file.name .. '/body_LZ.bin') then
			local smdh = {}
			local smdh_found = false

			if System.doesFileExist(System.currentDirectory() .. file.name .. '/info.smdh') then
				smdh = System.extractSMDH(System.currentDirectory() .. file.name .. '/info.smdh')
				smdh_found = true

				temp_data = Graphics.convertFrom(smdh.icon)
				Screen.freeImage(smdh.icon)
				smdh.icon = temp_data
			else
				smdh.title = file.name
				smdh.icon = no_icon
				smdh_found = false
			end

			local theme = {
						path = file.name,
						preview_info = smdh,
						smdh_found = smdh_found
		}
			table.insert(folders, theme)
		end
	end
	return folders
end

function PaginateThemes(themes_table)
	max_pages = math.ceil(#themes_table/3)
	local paged_themes = {}
	local next_page = {
				path = 'next',
				smdh_found = 'next',
				preview_info = {
								title = 'Next Page',
								icon = next_icon,
								desc = 'Navigate to the next page.',
								author = ''
								},
				}
	local prev_page = {
				path = 'prev',
				smdh_found = 'prev',
				preview_info = {
								title = 'Previous Page',
								icon = prev_icon,
								desc = 'Navigate to the previous page.',
								author = ''
								},
				}
	for page=1, max_pages do
		if page == 1 then
			local add_array = {}
			for i=1,4 do table.insert(add_array, themes_table[i]) end
			if page ~= max_pages then table.insert(add_array, next_page) end
			paged_themes[page] = add_array
		else
			local add_array = {}
			table.insert(add_array, prev_page)
			for i=page*3-1,page*3+1 do
				if i <= #themes_table then table.insert(add_array, themes_table[i]) end
			end
			if page ~= max_pages then table.insert(add_array, next_page) end
			paged_themes[page] = add_array
		end
	end
	return paged_themes
end

themes = PaginateThemes(GetThemes())

function CopyFile(input,output)
	-- this function was taken from Rinnegatamante's Sunshell because I basically could only figure out how to move fies, not copy them.
	inp = io.open(input,FREAD)
	if System.doesFileExist(output) then
		System.deleteFile(output)
	end
	out = io.open(output,FCREATE)
	MAX_RAM_ALLOCATION = 10485760
	size = io.size(inp)
	index = 0
	while (index+(MAX_RAM_ALLOCATION/2) < size) do
		io.write(out,index,io.read(inp,index,MAX_RAM_ALLOCATION/2),(MAX_RAM_ALLOCATION/2))
		index = index + (MAX_RAM_ALLOCATION/2)
	end
	if index < size then
		io.write(out,index,io.read(inp,index,size-index),(size-index))
	end
	io.close(inp)
	io.close(out)
end

function PopulateSmallIcons(theme_page)
	for index, theme in pairs(theme_page) do
		if theme.smdh_found == true then
			Graphics.drawScaleImage(title_pos[index],115,theme.preview_info.icon, 0.667, 0.667)
		elseif theme.smdh_found == 'prev' then
			Graphics.drawScaleImage(title_pos[index],115,prev_icon,0.667,0.667)
		elseif theme.smdh_found == 'next' then
			Graphics.drawScaleImage(title_pos[index],115,next_icon,0.667,0.667)
		else
			Graphics.drawScaleImage(title_pos[index],115,no_icon,0.667,0.667)
		end
	end
end

function HighlightTile(index, icon)
	Graphics.drawImage(hi_title_pos[index], 107, tile)
	-- err()
	Graphics.drawScaleImage(hi_title_pos[index]+8,109,icon,0.92,0.92)
end

function RefreshTopUI()
	if preview_state == 0 then
		Graphics.fillRect(0, 320, 0, 240, colours.background_grey)
		Graphics.drawImage(0, 0, top_background)
		Graphics.drawImage(44, 51, themes[current_page][cursor_pos].preview_info.icon)
		-- Font.print(font, 5, 5, "Test", colours.highlight_tile_white, TOP_SCREEN)
		-- Screen.debugPrint(0, 0, "Hello World", Color.new(255,255,255), TOP_SCREEN)
	elseif preview_state == 1 then
		selection = themes[current_page][cursor_pos]
		Graphics.fillRect(0, 320, 0, 240, colours.background_grey)
		preview_image = Graphics.loadImage('/Themes/' .. selection.path .. '/preview.png')
		Graphics.drawPartialImage(0,0,0,0,400,240,preview_image)
	elseif preview_state == 2 then
		Graphics.freeImage(preview_image)
		selection = themes[current_page][cursor_pos]
		Graphics.fillRect(0, 320, 0, 240, colours.background_grey)
		preview_image = Graphics.loadImage('/Themes/' .. selection.path .. '/preview.png')
		Graphics.drawPartialImage(40,0,40,240,320,240,preview_image)
	end
end

function ShowThemeDetails()
	if #themes ~= 0 then
		selection = themes[current_page][cursor_pos]
		if preview_state == 0 then
			Font.print(font, 123, 52, selection.preview_info.title, colours.highlight_tile_white, TOP_SCREEN)
			if selection.preview_info.desc then
				Font.print(font, 123, 66, selection.preview_info.desc, colours.highlight_tile_white, TOP_SCREEN)
			else
				Font.print(font, 123, 66, "No description.", colours.highlight_tile_white, TOP_SCREEN)
			end
			if selection.preview_info.author and selection.smdh_found ~= 'prev' and selection.smdh_found ~= 'next' then
				Font.print(font, 123, 86, "By: " .. selection.preview_info.author, colours.highlight_tile_white, TOP_SCREEN)
			elseif selection.smdh_found ~= 'prev' and selection.smdh_found ~= 'next' then
				Font.print(font, 123, 86, "By: Unknown Author", colours.highlight_tile_white, TOP_SCREEN)
			end
		end
	end
end

function RefreshBottomUI()
	Graphics.fillRect(0, 320, 0, 240, colours.background_grey)
	Graphics.drawImage(0,0,background)
	PopulateSmallIcons(themes[current_page])
	HighlightTile(cursor_pos, themes[current_page][cursor_pos].preview_info.icon)
	if dialog_open == true then
		if dialog_type == 'install' then
			Graphics.drawImage(15, 31, install_dialog)
		end
	end	
end

function ResetBottomUI()
	cursor_pos = 1
	current_page = 1
	RefreshBottomUI()
end

function ShowPreview()
	selection = themes[current_page][cursor_pos]
	if System.doesFileExist('/Themes/' .. selection.path .. '/preview.png') then
		if preview_state == 0 then
			-- Console.append(console, 'preview_state = 1')
			preview_state = 1
			RefreshTopUI()
		elseif preview_state == 1 then
			-- Console.append(console, 'preview_state = 2')
			preview_state = 2
			RefreshTopUI()
		elseif preview_state == 2 then
			-- Console.append(console, 'preview_state = 0')
			preview_state = 0
			RefreshTopUI()
		end
	end
end

function Select()
	selection = themes[current_page][cursor_pos]
	if selection.path == 'next' then
		NextSelected()
	elseif selection.path == 'prev' then
		PrevSelected()
	else
		dialog_type = 'install'
		dialog_open = true
	end
end

function Install()
	dialog_open=false
	selection = themes[current_page][cursor_pos]
	temp_path_store = System.currentDirectory()
	System.currentDirectory('/')
	System.deleteFile('/3ds/menuhax_manager/body_LZ.bin')
	System.deleteFile('/3ds/menuhax_manager/bgm.bcstm')
	System.currentDirectory('/')
	CopyFile('/Themes/' .. selection.path .. '/body_LZ.bin', '/3ds/menuhax_manager/body_LZ.bin')
	if System.doesFileExist('/Themes/' .. selection.path .. '/bgm.bcstm') then
		CopyFile('/Themes/' .. selection.path .. '/bgm.bcstm', '/3ds/menuhax_manager/bgm.bcstm')
	end
	System.currentDirectory(temp_path_store)
	System.launch3DSX('/3ds/menuhax_manager/menuhax_manager.3dsx')
	-- System.exit()
end

function MoveCursorRight()
	cursor_pos = cursor_pos + 1
	if cursor_pos > 5 then cursor_pos = 5 end
	if cursor_pos > #themes[current_page] then cursor_pos = #themes[current_page] end
	RefreshBottomUI()
end

function MoveCursorLeft()
	cursor_pos = cursor_pos - 1
	if cursor_pos < 1 then cursor_pos = 1 end
	RefreshBottomUI()
end

function NextSelected()
	local max_pages = max_pages
	current_page = current_page + 1
	if current_page > max_pages then current_page = max_pages end
	cursor_pos = 1
	RefreshBottomUI()
end

function PrevSelected()
	local max_pages = max_pages
	current_page = current_page - 1
	if current_page < 1 then current_page = 1 end
	cursor_pos = 5
	RefreshBottomUI()
end

-- Console.append(console, "CWD is" .. System.currentDirectory() .. '\n' .. '===============' .. '\n')

while true do
	pad = Controls.read()
	Screen.refresh()
	if Timer.getTime(preview_timer) > 5000 and preview_state ~= 0 then
		if preview_state == 1 then preview_state = 2 elseif preview_state == 2 then preview_state = 0 end
		Screen.clear(TOP_SCREEN)
		RefreshTopUI()
		Timer.reset(preview_timer)
	end
	Graphics.initBlend(TOP_SCREEN)
	if #themes ~= 0 and System.doesFileExist('/3ds/menuhax_manager/menuhax_manager.3dsx') then
		RefreshTopUI()
	else
		Graphics.fillRect(0, 412, 0, 240, colours.background_grey)
	end
	Graphics.termBlend()
	Graphics.initBlend(BOTTOM_SCREEN)
	if #themes ~= 0 and System.doesFileExist('/3ds/menuhax_manager/menuhax_manager.3dsx') then
		RefreshBottomUI()
	elseif not System.doesFileExist('/3ds/menuhax_manager/menuhax_manager.3dsx') then
		Graphics.fillRect(0, 320, 0, 240, colours.background_grey)
		dialog_type = 'no_menuhax'
		dialog_open = true
		Graphics.drawImage(15, 31, no_menuhax_dialog)
	else
		Graphics.fillRect(0, 320, 0, 240, colours.background_grey)
		dialog_type = 'no_themes'
		dialog_open = true
		Graphics.drawImage(15, 31, no_themes_dialog)
	end
	Graphics.termBlend()
	ShowThemeDetails()
	Console.show(console)
	Screen.flip()
	Screen.waitVblankStart()
	if (Controls.check(pad, KEY_START)) and not (Controls.check(oldpad, KEY_START)) then
		Graphics.termBlend()
		Console.destroy(console)
		Font.unload(font)
		System.exit()
	elseif (Controls.check(pad, KEY_A)) and not (Controls.check(oldpad, KEY_A)) and not dialog_open and preview_state == 0 then
		Select()
	elseif (Controls.check(pad, KEY_A)) and not (Controls.check(oldpad, KEY_A)) and dialog_open and dialog_type == 'install' and preview_state == 0 then
		Install()
	elseif (Controls.check(pad, KEY_B)) and not (Controls.check(oldpad, KEY_B)) and dialog_open and dialog_type == 'install' and preview_state == 0 then
		dialog_open = false
	elseif (Controls.check(pad, KEY_Y)) and not (Controls.check(oldpad, KEY_Y)) and not dialog_open then
		ShowPreview()
	elseif (Controls.check(pad, KEY_X)) and not (Controls.check(oldpad, KEY_X)) then
		local h,m,s  = System.getTime()
		System.takeScreenshot("/screenshots/screenshot".. h .. "-" .. m .. "-" .. s .. ".png")
	elseif (Controls.check(pad, KEY_DRIGHT)) and Timer.getTime(delayer) > 200 and not dialog_open and preview_state == 0 then
		MoveCursorRight()
		Timer.reset(delayer)
	elseif (Controls.check(pad, KEY_DLEFT)) and Timer.getTime(delayer) > 200 and not dialog_open and preview_state == 0 then
		MoveCursorLeft()
		Timer.reset(delayer)
	end
	oldpad = pad
end