--[[Settings
	name = "On Demand"
	description = ""
	version = "0.3.6"
	link = ""
EndSettings]]--


--[[Director
	arrParam = {}

	function director:StartPlayerSearch(myurl)
		return true
	end

	function director:get_PlayerSearchCriteria()
		return PlayerBounds(360, 100, 1.0, 2.2)
	end

	function director:GetPlayerViewingRectangle(playerSize)
		if # arrParam > 2 then
			local arrSub = str_split(arrParam[2], ",")
			if tonumber(arrSub[1]) == 2 then
				SendMouseClick(arrSub[2], arrSub[3], arrSub[4])
			end
		end
		if # arrParam > 2 then
			local arrSub = str_split(arrParam[3], ",")
			return Rectangle(0 + tonumber(arrSub[1]), 0 + tonumber(arrSub[2]), playerSize.Width + tonumber(arrSub[3]), playerSize.Height + tonumber(arrSub[4]))
		elseif # arrParam > 1 then
			local arrSub = str_split(arrParam[2], ",")
			return Rectangle(0 + tonumber(arrSub[1]), 0 + tonumber(arrSub[2]), playerSize.Width + tonumber(arrSub[3]), playerSize.Height + tonumber(arrSub[4]))
		else
			return Rectangle(0, 0, playerSize.Width, playerSize.Height)
		end
	end

	function director:OnPlayerFound(player)
		if # arrParam > 2 then
			local arrSub = str_split(arrParam[2], ",")
			if tonumber(arrSub[1]) == 1 then
				SendMouseClick(arrSub[2], arrSub[3], arrSub[4])
			end
		end
	end

	function director:TranslateUrl(origurl)
		arrParam = str_split(origurl, "~~")
		return arrParam[1]
	end

	function wait(seconds)
		local start = os.time()
		repeat until os.time() > start + seconds
	end

	function SendMouseClick(delay, xcoord, ycoord)
		if tonumber(delay) > 0 then
			wait(tonumber(delay))
		end
		Mouse.SimulateMove(director:get_PlayerWindow(), tonumber(xcoord), tonumber(ycoord))
		Mouse.SimulateClick(director:get_PlayerWindow(), tonumber(xcoord), tonumber(ycoord))
	end
EndDirector]]--


--------------

SiteURL = "http://www.primewire.ag"


--------------

local versionCheck = GetURL("https://sites.google.com/site/fs4apu/home")
if versionCheck ~= "<error>" then
	local scriptVersionLocal = 036
	local scriptVersionSite = string.match(versionCheck, "OC%s*Script%s*Version:%s*(%d%.%d%.%d)")
	if scriptVersionSite then
		scriptVersionSite = tonumber(str_replace(scriptVersionSite, ".", ""))
		if scriptVersionSite > scriptVersionLocal then
			local saveScript = DownloadAndSaveFile("https://sites.google.com/site/fs4apu/onechannel.lua?attredirects=0&d=1", GetCurrentPath() .. "\\Scripts\\ocupdate.tmp")
			if saveScript then
				local newScriptCode = OpenFile(GetCurrentPath() .. "\\Scripts\\ocupdate.tmp")
				if string.find(newScriptCode, "UNIQUE".."EOF".."MARKER", 1, true) then
					os.remove(GetCurrentPath().."\\Scripts\\onechannel.lua")
					os.rename(GetCurrentPath().."\\Scripts\\ocupdate.tmp", GetCurrentPath().."\\Scripts\\onechannel.lua")
					ShowMsg('**Script Updated: A new version of "On Demand" has been downloaded**')
					ShowMsg('**"On Demand" has automatically updated to version '..scriptVersionSite..'**')
					RunScript(newScriptCode)
					return nil
				end
			end
			os.remove(GetCurrentPath().."\\Scripts\\ocupdate.tmp")
			ShowMsg('**Script Update Available; Automatic Update Failed**')
		end
	end
end

if FileExists(GetCurrentPath().."\\Scripts\\onechannel_moviedb_v1.txt") then
	os.remove(GetCurrentPath().."\\Scripts\\onechannel_moviedb_v1.txt")
end

if FileExists(GetCurrentPath().."\\Scripts\\onechannel_tvdb_v1.txt") then
	os.remove(GetCurrentPath().."\\Scripts\\onechannel_tvdb_v1.txt")
end


--------------

function lvss_lib_download()
	if io.open(GetCurrentPath().."\\Scripts\\libVidSupplement.llf") == nil then
		local i
		for i = 1, 3 do
			local saveScript = DownloadAndSaveFile("https://sites.google.com/site/fs4apu/libVidSupplement.llf?attredirects=0&d=1", GetCurrentPath() .. "\\Scripts\\lvssupdate.tmp")
			local newScriptCode = OpenFile(GetCurrentPath() .. "\\Scripts\\lvssupdate.tmp")
			if string.find(newScriptCode, "UNIQUE".."EOF".."MARKER", 1, true) then
				os.remove(GetCurrentPath().."\\Scripts\\libVidSupplement.llf")
				os.rename(GetCurrentPath().."\\Scripts\\lvssupdate.tmp", GetCurrentPath().."\\Scripts\\libVidSupplement.llf")
				break
			else
				os.remove(GetCurrentPath().."\\Scripts\\lvssupdate.tmp")
			end
		end
		if io.open(GetCurrentPath().."\\Scripts\\libVidSupplement.llf") == nil then
			return false
		end
	end
	return true
end

if lvss_lib_download() then
	Import(GetCurrentPath().."\\Scripts\\libVidSupplement.llf")
	my_lvss = LVSS:new()
	if my_lvss:CheckUpdate() then
		RunScript(OpenFile(GetCurrentPath() .. "\\Scripts\\onechannel.lua"))
		return nil
	end
else
	ShowMsg("ERROR, unable to download libVidSupplement.llf")
end


--------------

if io.open(GetCurrentPath().."\\Scripts\\veeHD_stop.jpg") == nil then
	DownloadAndSaveFile("http://sites.google.com/site/gmgetwhateveriputhere/veeHD_stop.jpg?attredirects=0&d=1", GetCurrentPath().."\\Scripts\\veeHD_stop.jpg")
end


--------------

--title: libSearch.llf
--author: Jeromy Huber

Search = {}
Search_mt = { __index = Search }
 
function Search:new(mv, t)
	function Search:ShowWordFolders()
		for i = 1, 10 do
			_dvf("[ Show Word "..i.."]", self.MainVariable .. ":ShowWordAndSuggestions");
		end;
	end;
	
	function Search:ShowWordAndSuggestions()
		_sm(self:GetWord());
		if self.EnableSuggestions then
			local a = { "", 0, 0 };
			local s = GetURL("http://sg.media-imdb.com/suggests/"..string.sub(_sr(string.lower(self:GetWord()), " ", "_"), 1, 1).."/".._sr(string.lower(self:GetWord()), " ", "_")..".json");
			
			for i = 1, 10 do
				a = _sgba(s, '"l":"', '"', a[3] + 1);
					if not a then break; end;
				_vf("Suggestion: ".._shd(a[1]), "code:" .. self.MainVariable .. ".Word = '".. _sr(_shd(a[1]), "'", "\\'") .."'; "..self.ExecuteFunction.."();");
			end;
		end;
	end;

	function Search:ShowExeFolders()
		for i = 1, 10 do
			_dvf("[ Execute "..i.."]", self.ExecuteFunction);
		end;
	end;

	function Search:AddBookmark()
		local i = GetScriptOption("Search Count");
		if isnumeric(i) then
			i = tonumber(i) + 1;
		else
			i = 1;
		end;
		SetScriptOption("Search Count", tostring(i));
		SetScriptOption("Search Bookmark "..i, self:GetWord());
	end;

	function Search:GetBookmarks()
		local i = GetScriptOption("Search Count");
		if i~="" then
			local k = tonumber(i);
			for i = 1, k do
				if GetScriptOption("Search Bookmark "..i)~="" then
					_dvf(GetScriptOption("Search Bookmark "..i), "code:"..self.MainVariable..".Word='".. GetScriptOption("Search Bookmark "..i) .."'; _vf('[ Delete this Bookmark ]', 'code:SetScriptOption(\"Search Bookmark "..i.."\", \"\"); _sm(\"Bookmark Deleted\");'); "..self.ExecuteFunction.."();");
				end;
			end;
		end;	
	end;

	function Search:ShowFolders()
		_dvf("[ Show Word ]", self.MainVariable..":ShowWordFolders");
		if self.NotSearch then 
			_dvf("[ Create List ]", self.MainVariable..":ShowExeFolders");
		else
			_dvf("[ Execute Search ]", self.MainVariable..":ShowExeFolders");
		end
		if self.EnableBookmarks then _dvf("[ Bookmark Word ]", "code:if os.clock() - "..self.MainVariable..".Time > 1.5 then "..self.MainVariable..".Time=os.clock(); "..self.MainVariable..":AddBookmark(); end;"); end;
		if self.EnableBookmarks then _dvf("[ Bookmarks ]", self.MainVariable..":GetBookmarks"); end;
		_dvf("[ Reset Word ]", "code:"..self.MainVariable..".Word='';");
		_dvf("[ NEXT LETTER ]", "code:"..self.MainVariable..".Word = "..self.MainVariable..".Word .. '-';");
		_dvf("[ BACKSPACE ]", "code:if os.clock() - "..self.MainVariable..".Time > 1.5 then "..self.MainVariable..".Time=os.clock(); "..self.MainVariable..".Word = string.sub("..self.MainVariable..".Word, 1, string.len("..self.MainVariable..".Word) - 1); end;");
		_dvf("[ SPACE ]", "code:if os.clock() - "..self.MainVariable..".Time > 1.5 then "..self.MainVariable..".Time=os.clock(); "..self.MainVariable..".Word = "..self.MainVariable..".Word .. ' '; end;");

		for i = 48, 57 do
			_dvf("#"..string.char(i), "code:if os.clock() - "..self.MainVariable..".Time > 1.5 then "..self.MainVariable..".Time=os.clock(); "..self.MainVariable..".Word = "..self.MainVariable..".Word .. '"..string.char(i).."'; end;");
		end;

		for i = 65, 90 do
			_dvf("#"..string.char(i), "code:if os.clock() - "..self.MainVariable..".Time > 1.5 then "..self.MainVariable..".Time=os.clock(); "..self.MainVariable..".Word = "..self.MainVariable..".Word .. '"..string.char(i).."'; end;");
		end;
	end;

	function Search:GetWord()
		local new = "";
		if str_find(self.Word, "-", 0) > -1 then
			local arr = str_split(self.Word, "-");
			for i = 1, table.getn(arr) do
				new = new .. string.sub(arr[i], 1, 2);
			end;
		else
			new = self.Word;
		end;
		return new
	end;

	--remove duplicate seach entries added by friggin PS3's multiple folder requests
	local sc = GetScriptOption("Search Count");
	if sc~="" then
		local k = tonumber(sc);
		local last = ""
		local olast = ""
		for sc = 1, k do
			olast = GetScriptOption("Search Bookmark "..sc)
			if last ~= "" and last == GetScriptOption("Search Bookmark "..sc) then SetScriptOption("Search Bookmark "..sc, "") end
			last = olast
		end;
	end;	
	
	local word = "";
	if t.DefaultWord then word = t.DefaultWord end;
	
	return setmetatable( {
   Version = 2,
   Time = 0,
   Word = word,
   EnableSuggestions = t.EnableSuggestions,
   EnableBookmarks = t.EnableBookmarks,
   ExecuteFunction = t.ExecuteFunction,
   NotSearch = t.NotSearch,
   MainVariable = mv
   
   }, Search_mt)
end;


--------------

function load_favorites()
	local x, y, z, name, tmp, layer3
	local flag = false
	favoritesGlobal = {}
	x = OpenFile(GetCurrentPath().."\\Scripts\\OC_favorites.txt")
	if x == "<error>" then
		x = ""
	end
	if not string.find(x, "#", 1, true) then
		x = string.gsub(x, "[\r\n]", "")
		x = "2#{My%20Favorites+"..x.."}"
		flag = true
	end
	y = str_split(x, "#")[2]
	local data = { "", 0, -1 }
	while y do
		data = str_get_between_a(y, '{', '}', data[3] + 1)
		if not data then
			break
		end
		z = str_split(data[1], "\\+")
		name = str_unescape(z[1])
		z = z[2]
		layer3 = {}
		local data2 = { "", 0, -1 }
		while z do
			data2 = str_get_between_a(z, '[', ']', data2[3] + 1)
			if not data2 then
				break
			end
			tmp = str_split(data2[1], "\\|")
			table.insert(layer3, { str_unescape(tmp[1]), str_unescape(tmp[2]), str_unescape(tmp[3]) })
		end
		table.insert(favoritesGlobal, { name, layer3 })
	end
	if flag then
		save_favorites()
	end
end

function save_favorites()
	local a, b, c, d
	local e = ""
	for a = 1, #favoritesGlobal do
		b = str_escape(favoritesGlobal[a][1])
		d = ""
		for c = 1, #favoritesGlobal[a][2] do
			d = d.."["..str_escape(favoritesGlobal[a][2][c][1]).."|"..str_escape(favoritesGlobal[a][2][c][2]).."|"..str_escape(favoritesGlobal[a][2][c][3]).."]"
		end
		e = e.."{"..b.."+"..d.."}"
	end
	SaveFile(GetCurrentPath().."\\Scripts\\OC_favorites.txt", "2#"..e)
end

function view_favorites()
	local x
	for x = 1, #favoritesGlobal do
		DynamicVirtualFolder(favoritesGlobal[x][1], "code:list_favorites(favoritesGlobal["..x.."][2], "..tostring(x)..")")
	end
	VirtualFolder("New List", "new_list")
end

function list_favorites(z, x)
	local y
	for y = 1, #z do
		VirtualFolder(z[y][1], "load_favorite|"..z[y][2].."|"..z[y][3].."|"..x.."|"..tostring(y))
	end
	VirtualFolder("Delete This List", "delete_list|"..x)
end

function load_favorite(link, flag, x, y)
	VirtualFolder("[Remove Favorite]", "remove_favorite|"..x.."|"..y)
	if flag == "1" then
		onechannel_Content(SiteURL..link, "")
	else
		onechannel_Seasons(SiteURL..link, "")
	end
end

function new_list()
	onechannel_NameFavorites:ShowFolders()
end

function onechannel_NameFavorites_Execute()
	VirtualFolder("Continue, create this favorites list.", "onechannel_namefavland")
end

function onechannel_namefavland()
	table.insert(favoritesGlobal, { onechannel_NameFavorites:GetWord(), {} })
	save_favorites()
	VirtualFolder("Favorites list was created.", "")
end

function delete_list(x)
	VirtualFolder("Continue, DELETE this favorites list.", "delete_list_confirmed|"..x)
end

function delete_list_confirmed(x)
	table.remove(favoritesGlobal, tonumber(x))
	save_favorites()
	VirtualFolder("Favorites list was removed.", "")
end

function add_favorite(name, link, flag)
	local x
	for x = 1, #favoritesGlobal do
		VirtualFolder(favoritesGlobal[x][1], "insert_favorite|"..name.."|"..link.."|"..flag.."|"..tostring(x))
	end
end

function insert_favorite(name, link, flag, x)
	table.insert(favoritesGlobal[tonumber(x)][2], { name, link, flag })
	save_favorites()
	VirtualFolder("Favorite was added.", "")
end

function remove_favorite(x, y)
	VirtualFolder("Continue, DELETE this favorite.", "remove_favorite_confirmed|"..x.."|"..y)
end

function remove_favorite_confirmed(x, y)
	table.remove(favoritesGlobal[tonumber(x)][2], tonumber(y))
	save_favorites()
	VirtualFolder("Favorite was removed.", "")
end


--------------

function onechannel_Letters(indb)
	local dbase = {}
	if indb == "1" then
		dbase = moviedatabase
	else
		dbase = tvdatabase
	end
	local last = nil
	local index, count
	for i = 1, #dbase do
		if not last then
			last = string.sub(dbase[i][1], 1, 1)
			index = i
			count = 0
		elseif string.sub(dbase[i][1], 1, 1) ~= last then
			VirtualFolder(last.." - ("..tostring(count + 1).." items)", "onechannel_DB_Pages|"..indb.."|"..tostring(index).."|"..tostring(count + index).."|")
			last = string.sub(dbase[i][1], 1, 1)
			index = i
			count = 0
		else
			count = count + 1
		end
	end
	VirtualFolder(last.." ("..tostring(count + 1).." items)", "onechannel_DB_Pages|"..indb.."|"..tostring(index).."|"..tostring(count + index).."|")
end

function onechannel_Genre(indb)
	local dbase = {}
	if indb == "1" then
		dbase = moviedatabase
	else
		dbase = tvdatabase
	end
	local gentable = { ["0"] = "Action", ["1"] = "Adventure", ["2"] = "Animation", ["3"] = "Biography", ["4"] = "Comedy", ["5"] = "Crime", ["6"] = "Documentary", ["7"] = "Drama", ["8"] = "Family", ["9"] = "Fantasy", ["a"] = "Game-Show", ["b"] = "History", ["c"] = "Horror", ["d"] = "Japanese", ["e"] = "Korean", ["f"] = "Music", ["g"] = "Musical", ["h"] = "Mystery", ["i"] = "Reality-TV", ["j"] = "Romance", ["k"] = "Sci-Fi", ["l"] = "Short", ["m"] = "Sport", ["n"] = "Talk-Show", ["o"] = "Thriller", ["p"] = "War", ["q"] = "Western", ["r"] = "Zombies", ["s"] = "Indian", ["t"] = "Russian" }
	local gens = {}
	local last = nil
	local count = 1
	for i = 1, #dbase do
		for j in string.gmatch(dbase[i][3], "%w") do
			table.insert(gens, j)
		end
	end
	table.sort(gens)
	for i = 1, #gens do
		if not last then
			last = gens[i]
		elseif gens[i] == last then
			count = count + 1
		else
			VirtualFolder(gentable[last].." ("..count.." items)", "onechannel_DB_Pages|"..indb.."|||3"..last)
			last = gens[i]
			count = 1
		end
	end
	VirtualFolder(gentable[last].." ("..count.." items)", "onechannel_DB_Pages|"..indb.."|||3"..last)
end

function onechannel_Year(indb)
	local dbase = {}
	if indb == "1" then
		dbase = moviedatabase
	else
		dbase = tvdatabase
	end
	local years = {}
	local last = nil
	local count = 1
	for i = 1, #dbase do
		if dbase[i][2] ~= "" then
			table.insert(years, dbase[i][2])
		end
	end
	table.sort(years)
	for i = #years, 1, -1 do
		if not last then
			last = years[i]
		elseif years[i] == last then
			count = count + 1
		else
			VirtualFolder(last.." ("..count.." items)", "onechannel_DB_Pages|"..indb.."|||2"..last)
			last = years[i]
			count = 1
		end
	end
	VirtualFolder(last.." ("..count.." items)", "onechannel_DB_Pages|"..indb.."|||2"..last)
end

function onechannel_rebuild_DB(indb, section, flag)
	local dbase = {}
	if indb == "1" then
		dbase = moviedatabase
	else
		dbase = tvdatabase
	end
	local tempdatabase = {}
	for i = 1, #dbase do
		if string.find(dbase[i][tonumber(section)], flag, 1, true) ~= nil then
			table.insert(tempdatabase, dbase[i])
		end
	end
	return 1, #tempdatabase, tempdatabase
end

function onechannel_DB_Pages(indb, dstart, dend, dbflag, flag)
	local dbase = {}
	if dbflag ~= "" then
		local a, b, c, d
		a, b = string.match(dbflag, "(%d)(.+)")
		c, d, dbase = onechannel_rebuild_DB(indb, a, b)
		if not flag then
			dstart, dend = c, d
		end
	else
		if indb == "1" then
			dbase = moviedatabase
		else
			dbase = tvdatabase
		end
	end
	dstart, dend = tonumber(dstart), tonumber(dend)
	if not flag and dend - dstart > 300 then
		local index, page = dstart, 0
		while index <= dend do
			local index2 = index + 299
			if index2 > dend then
				index2 = dend
			end
			page = page + 1
			VirtualFolder("Page "..tostring(page).." ("..get_prefix(dbase[index][1]).." - "..get_prefix(dbase[index2][1])..")", "onechannel_DB_Pages|"..indb.."|"..tostring(index).."|"..tostring(index2).."|"..dbflag.."|")
			index = index2 + 1
		end
	else
		for i = dstart, dend do
			VirtualFolder(dbase[i][1].." ("..dbase[i][2]..")", "favorites_landing|"..dbase[i][1].." ("..dbase[i][2]..")|"..dbase[i][4].."||"..indb)
		end
	end
end

function onechannel_setSection()
	VirtualFolder("Set for TV Shows", "onechannel_setTV")
	VirtualFolder("Search for Movies", "onechannel_setMovies")
end

function onechannel_setTV()
	search_section = "2"
	ShowMsg("Search set to TV.")
end

function onechannel_setMovies()
	search_section = "1"
	ShowMsg("Search set to Movies.")
end

function onechannel_Search_Execute()
	local URL = SiteURL
	local key = GetURL(URL)
	key = str_get_between(key, 'key" value="', '"', 0)
	local srchword = onechannel_Search:GetWord()
	srchword = str_replace(srchword, " ", "+")
	onechannel_Results(URL.."/?search_keywords="..srchword.."&key="..key.."&search_section="..search_section, URL, search_section, "s")
end

function onechannel_Results(URL, PrevURL, section, flag)
	local HTML = GetURLX(URL, "", "GET", PrevURL, "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0)", "", "", "*/*", "")
	HTML = string.gsub(HTML, "[\r\n]", "")
	if flag ~= "" and string.find(HTML, '<div class="pagination">') then
		HTML = str_get_between(HTML, '<div class="pagination">', '</div>', 0)
		while string.find(HTML, '&page=', 1, true) do
			HTML = string.sub(HTML, string.find(HTML, '&page=', 1, true) + 6)
		end
		HTML = string.sub(HTML, 1, string.find(HTML, '"', 1, true) - 1)
		local i
		for i = 1, tonumber(HTML) do
			VirtualFolder("Page "..i, "onechannel_Results|"..URL.."&page="..i.."|"..URL.."|"..section.."|")
		end
	else
		while string.find(HTML, '<div class="index_item index_item_ie">', 1, true) do
			HTML = string.sub(HTML, string.find(HTML, '<div class="index_item index_item_ie">', 1, true) + 39)
			local showTitle = str_get_between(HTML, 'title="', '"', 0)
			showTitle = string.sub(showTitle, string.find(showTitle, "Watch ", 1, true) + 6)
			local showURL = str_get_between(HTML, 'href="', '"', 0)
			VirtualFolder(showTitle, "favorites_landing|"..showTitle.."|"..showURL.."|"..URL.."|"..section)
		end
	end
end

function favorites_landing(title, link, link2, flag)
	VirtualFolder("[Add To Favorites]", "add_favorite|"..title.."|"..link.."|"..flag)
	if flag == "1" then
		onechannel_Content(SiteURL..link, link2)
	else
		onechannel_Seasons(SiteURL..link, link2)
	end
end

function onechannel_Seasons(URL, PrevURL)
	local HTML = GetURLX(URL, "", "GET", PrevURL, "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0)", "", "", "*/*", "")
	HTML = string.gsub(HTML, "[\r\n]", "")
	HTML = str_get_between(HTML, 'class="choose_tabs"', 'class="clearer"', 0)
	if string.find(HTML, "<h2>", 1, true) then
		HTML = string.sub(HTML, string.find(HTML, "<h2>", 1, true) + 4)
		if string.find(HTML, "<h2>", 1, true) then
			HTML = str_split(HTML, "<h2>")
			local i
			for i = 1, #HTML do
				if string.find(HTML[i], '<div class="tv_episode_item">', 1, true) then
					local showTitle = str_get_between(HTML[i], '>', '<' , 0)
					onechannel_Episodes(HTML[i], showTitle, URL)
				end
			end
		else
			if string.find(HTML, '<div class="tv_episode_item">', 1, true) then
				local showTitle = str_get_between(HTML, '>', '<' , 0)
				onechannel_Episodes(HTML, showTitle, URL)
			end
		end
	end
end

function onechannel_Episodes(HTML, Season, URL)
	local data = { "", 0, -1 }
	while HTML do
		data = str_get_between_a(HTML, '<div class="tv_episode_item">', '</div>', data[3] + 1)
		if not data then
			break
		end
		local showTitle = str_strip_tags(data[1], "<", ">")
		local showURL = str_get_between(data[1], 'href="', '"' , 0)
		while string.match(showTitle, "%s%s+") do
			showTitle = str_replace(showTitle, string.match(showTitle, "%s%s+"), " ")
		end
		VirtualFolder(str_replace(Season, "Season ", "S").." "..str_replace(showTitle, "Episode ", "E"), "onechannel_Content|"..SiteURL..""..showURL.."|"..URL)
	end
end

function onechannel_Content(URL, PrevURL)
	-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
	-- licensed under the terms of the LGPL2
	function dec(data)
		local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
		data = string.gsub(data, '[^'..b..'=]', '')
		return (data:gsub('.', function(x)
			if (x == '=') then return '' end
			local r,f='',(b:find(x)-1)
			for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
			return r;
		end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if (#x ~= 8) then return '' end
			local c=0
			for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
		end))
	end
	local HTML = GetURLX(URL, "", "GET", PrevURL, "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0)", "", "", "*/*", "")
	HTML = string.gsub(HTML, "[\r\n]", "")
	local description = str_trim(str_get_between(HTML, '<p style="width:460px; display:block;">', '</p>', 0))
	local titlePage = str_get_between(HTML, '<meta property="og:title" content="', '"', 0)
	local section = str_get_between(HTML, '<div class="actual_tab" id="first">', '<table cellspacing', 0)
	if not section then
		ShowMsg("Could not get section data")
	end
	local block = { "", 0, 0 }
	while section do
		block = str_get_between_a(section, '<table width="100%" cellpadding="0" cellspacing="0" ', '</table>', block[3] + 1)
		if not block then
			break
		end
		local quality = str_get_between(block[1], "<span class=quality_", ">", 0)
		local rating = string.match(block[1], 'class%=%"current%-rating%"%s.-%>Currently%s(.-)%<')
		local redirectLink = SiteURL..str_get_between(block[1], '<a href="', '"', 0)
		local possibleParts = str_get_between(block[1], '="no', '</span>', 0)
		if redirectLink and possibleParts then
			if string.find(possibleParts, "'2'") then
				possibleParts = str_trim(possibleParts)
				redirectLink = 'Concantanated Parts: <a href="'..redirectLink..'" '..possibleParts
				local count = 1
				while string.find(redirectLink, 'url=', 1, true) do
					local hostPage = str_get_between(redirectLink, 'url=', '&', 0)
					if not hostPage then
						hostPage = str_get_between(redirectLink, 'url=', '"', 0)
					end
					if hostPage then
						hostPage = dec(hostPage)
						hostPage = string.gsub(hostPage, "[\r\n]", "")
						local host = str_split(str_get_between(str_html_decode(hostPage), "http://", "/", 0), "\\.")
						if string.lower(host[#host - 1]) == "co" then
							host = string.lower(host[#host - 2])
						else
							host = string.lower(host[#host - 1])
						end
						VirtualFolder("Part "..count.." - "..host.." - "..quality.." - "..rating, "play_video|"..hostPage.."|"..description)
						count = count + 1
					end
					redirectLink = string.sub(redirectLink, string.find(redirectLink, "url=", 1, true) + 4)
				end
			else
				local hostPage = str_get_between(redirectLink, 'url=', '&', 0)
				if not hostPage then
					hostPage = str_get_between(redirectLink, 'url=', '"', 0)
				end
				if hostPage then
					hostPage = dec(hostPage)
					hostPage = string.gsub(hostPage, "[\r\n]", "")
					local host = str_split(str_get_between(str_html_decode(hostPage), "http://", "/", 0), "\\.")
					if string.lower(host[#host - 1]) == "co" then
						host = string.lower(host[#host - 2])
					else
						host = string.lower(host[#host - 1])
					end
					VirtualFolder(host.." - "..quality.." - "..rating, "play_video|"..hostPage.."|"..description)
				end
			end
		end
	end
end

function get_prefix(item)
	if string.len(item) >= 6 then
		return string.sub(item, 1, 6)
	else
		return item
	end
end


--------------

function play_video(URL, description)
	Log(URL)
	VideoResource("[Stop Background Downloading]", "code:stopBackgroundLoading()", "Frees bandwidth if you are done watching a video.", GetCurrentPath().."\\Scripts\\veeHD_stop.jpg", ConvertTime("00:00:01"))
	local hoster
	local key
	local showURL = str_html_decode(URL)
	hoster, key = my_lvss:break_URL(showURL)
	if hoster and key then
		my_lvss:libVideoSites_Supplement(hoster, key, description)
	end
end


--------------

function adler32(str)
	local s1 = 1
	local s2 = 0
	for i in string.gmatch(str, ".") do
		s1 = (s1 + string.byte(i)) % 65521
		s2 = (s2 + s1) % 65521
	end
	return tostring(s2*65536 + s1)
end

function get_version(db)
	local file = io.open(GetCurrentPath().."\\Scripts\\"..db, "r")
	local version = file:read()
	file:close()
	return version
end

function update_database(db, version, chksum)
	if not FileExists(GetCurrentPath().."\\Scripts\\"..db) or tonumber(get_version(db)) < tonumber(version) then
		DownloadAndSaveFile("https://sites.google.com/site/fs4apu/"..db.."?attredirects=0&d=1", GetCurrentPath().."\\Scripts\\db.tmp")
		if adler32(OpenFile(GetCurrentPath().."\\Scripts\\db.tmp")) == chksum then
			os.remove(GetCurrentPath().."\\Scripts\\"..db)
			os.rename(GetCurrentPath().."\\Scripts\\db.tmp", GetCurrentPath().."\\Scripts\\"..db)
		else
			ShowMsg("Failed database update - "..db)
		end
	end
end

function load_database(db)
	local database = {}
	local flag = false
	for line in io.lines(GetCurrentPath().."\\Scripts\\"..db) do
		if flag then
			line = str_split(line, "\\|")
			table.insert(database, {line[1], line[2], line[3], line[4]})
		else
			flag = true
		end
	end
	return database
end


--------------

onechannel_Search = Search:new("onechannel_Search", {
	ExecuteFunction = "onechannel_Search_Execute",
	EnableBookmarks = true,
	EnableSuggestions = true,
	NotSearch = false
})

onechannel_NameFavorites = Search:new("onechannel_NameFavorites", {
	ExecuteFunction = "onechannel_NameFavorites_Execute",
	EnableBookmarks = false,
	EnableSuggestions = false,
	NotSearch = true
})

search_section = "1"

update_database("onechannel_mvdb.txt", string.match(versionCheck, "OC%s*MVDB:%s*(%d+)"), string.match(versionCheck, "OC%s*MVDB:%s*%d+%s*(%d+)"))
moviedatabase = load_database("onechannel_mvdb.txt")

update_database("onechannel_tvdb.txt", string.match(versionCheck, "OC%s*TVDB:%s*(%d+)"), string.match(versionCheck, "OC%s*TVDB:%s*%d+%s*(%d+)"))
tvdatabase = load_database("onechannel_tvdb.txt")

favoritesGlobal = {}
load_favorites()

DynamicVirtualFolder("List Favorites", "view_favorites")
VirtualFolder("Movies by Letter", "onechannel_Letters|1")
VirtualFolder("Movies by Genre", "onechannel_Genre|1")
VirtualFolder("Movies by Release Date", "onechannel_Year|1")
VirtualFolder("Movies by Popularity", "onechannel_Results|"..SiteURL.."/?sort=views||1|s")
VirtualFolder("Movies by Rating", "onechannel_Results|"..SiteURL.."/?sort=ratings||1|s")
VirtualFolder("Featured Movies", "onechannel_Results|"..SiteURL.."/?sort=featured||1|s")
VirtualFolder("TV by Letter", "onechannel_Letters|2")
VirtualFolder("TV by Genre", "onechannel_Genre|2")
VirtualFolder("TV by Release Date", "onechannel_Year|2")
VirtualFolder("TV by Popularity", "onechannel_Results|"..SiteURL.."/?tv=&sort=views||2|s")
VirtualFolder("TV by Rating", "onechannel_Results|"..SiteURL.."/?tv=&sort=ratings||2|s")
VirtualFolder("Featured Shows", "onechannel_Results|"..SiteURL.."/?tv=&sort=featured||2|s")
VirtualFolder("----- Search -----", "")
VirtualFolder("[Set Section (Default Movies)]", "onechannel_setSection")
onechannel_Search:ShowFolders()


--------------------------------------------------------------------

--[[Image
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
EndImage]]--

--------------------------------------------------------------------

-- UNIQUEEOFMARKER --