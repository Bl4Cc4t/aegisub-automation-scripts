script_name="advancedAlpha"
script_description="Create an advanced alpha time from selection"
script_author="Bl4Cc4t"
script_url=""
script_version="0.35"
script_namespace="bl4.advancedAlpha"
submenu="_Bl4Cc4t’s Scripts"

-- modification of ua.BlurAndGlow.lua

--  --  --  --  --

function alpha(subs,sel)
  lettersInAllLines=0
  linePositionCounter=1
  for line=1, #sel do
    currentLine=subs[sel[line]]
    text=currentLine.text:match(".*}(.*)")
    lettersInAllLines=lettersInAllLines+text:len()
    currentLine.comment=true
    subs[sel[line]]=currentLine
    --currentLine.comment=false
  end
  for line=1, #sel do

    currentLine=subs[sel[line]]
    text=currentLine.text:match(".*}(.*)")
    tags=currentLine.text:match("{(.*)}.*")
    tagFontSize=tags:match("\\fs(%d*%.?%d*)")
    tagPositionY=tags:match("\\pos%(%d*%.?%d*,(%d*)%.?%d*%)")
    --aegisub.log(" "..tagPositionY)
    lettersInLine=text:len()
    inputStart=currentLine.start_time
    inputEnd=currentLine.end_time

    if res.mode == "Standard" then

      timeForOneLine=div(res.length, lettersInLine)
    elseif res.mode == ">PoRO" then
      if line == 1 then
        newStart=currentLine.start_time
      else
        newStart=newStart+timeForOneLine
      end
      timeForOneLine=div(res.length*lettersInLine, lettersInAllLines)
    end
    newText=""
    for letter=1, lettersInLine do
      newLine=currentLine
      if res.rtl then
        currentLetter=text:sub(lettersInLine-letter+1, lettersInLine-letter+1)
      else
        currentLetter=text:sub(letter, letter)
      end
      nextLetter=text:sub(letter+1, letter+1)
      lastLetter=text:sub(letter-1, letter-1)

      timeForOneLetter=div(timeForOneLine, lettersInLine)
      relativeStart=timeForOneLetter*letter
      relativeEnd=timeForOneLetter*(letter+1)

      if res.mode == "Standard" then
        newLine.start_time=inputStart+timeForOneLine*letter
        --aegisub.log(newLine.end_time)
        if letter ~= lettersInLine then
          newLine.end_time=inputStart+timeForOneLine*(letter+1)
        else
          newLine.end_time=inputEnd
        end
        if tags:match("\\fad") and letter == lettersInLine then
            newTags=tags
        else
          newTags=tags:gsub("\\fad%(.-%)", "")
        end
        newLine.comment=false
        if res.rtl then
          newText=currentLetter..newText
        else
          newText=newText..currentLetter
        end
        newLine.text="{"..newTags.."}"..newText
        subs.insert(sel[#sel]+linePositionCounter, newLine)
        linePositionCounter=linePositionCounter+1
      elseif res.mode == ">PoRO" then

        --handle apostrophe and correct quotation marks (not working)
        -- if currentLetter == "’" then
        --   newLetter="{\\fsp-20}’{\\fsp}"
        --   aegisub.log(newLetter.."\n")
        -- elseif currentLetter == " " and nextLetter == "“" then
        --   newLetter="{\\fsp-20} {\\fsp}"
        --   aegisub.log(newLetter.."\n")
        -- elseif currentLetter == " " and lastLetter == "”" then
        --   newLetter="{\\fsp-20} {\\fsp}"
        --   aegisub.log(newLetter.."\n")
        -- else
          newLetter=currentLetter
        -- end
        stylePreAlpha="\\alpha&HFF&\\blur6"
        styleSeqAlpha="\\alpha&H00&\\blur0.9"
        if res.style == options.poro2 or res.style == options.poro3 then
          stylePreAlpha=stylePreAlpha.."\\frx-30"
          styleSeqAlpha=styleSeqAlpha.."\\frx0"
        elseif res.style == options.poro5 then
          stylePreAlpha=stylePreAlpha.."\\frx-40"
          styleSeqAlpha=styleSeqAlpha.."\\frx0"
        end

        newText=newText.."{"..stylePreAlpha.."\\t("..relativeStart..","..relativeEnd..","..styleSeqAlpha..")}"..newLetter
      end
    end


    if res.mode == ">PoRO" then

      clipMod=div(tagFontSize, 10)

      if res.style == options.poro1 then -- white to red
        newTagColorBord = "&HDAE2FF&"
        newTagColorTop  = "&HDAE2FF&"
        newTagColorBot  = "&H6A49FA&"
        bordBlur        = "\\blur2.6"
        bordSize        = "\\bord2"
        additionalTags  = ""
        newTagPositionY1=tagPositionY-clipMod*6
        newTagPositionY2=tagPositionY-clipMod*4
      elseif res.style == options.poro2 then -- orange to purple, italic frx30
        newTagColorBord = "&HAFAABF&"
        newTagColorTop  = "&HAE9DDC&"
        newTagColorBot  = "&HBE397C&"
        bordBlur        = "\\blur2.6"
        bordSize        = "\\bord2.6"
        additionalTags  = "\\fax-0.2"
        newTagPositionY1=tagPositionY-clipMod*5
        newTagPositionY2=tagPositionY-clipMod*3
      elseif res.style == options.poro3 then -- pink gradient, italic fr30
        newTagColorBord = "&H9E99AC&"
        newTagColorTop  = "&H711ED9&"
        newTagColorBot  = "&H541F8B&"
        bordBlur        = "\\blur2.6"
        bordSize        = "\\bord2.6"
        additionalTags  = "\\fax-0.2"
        newTagPositionY1=tagPositionY-clipMod*6
        newTagPositionY2=tagPositionY-clipMod*3
      elseif res.style == options.poro4 then -- white to yellow
        newTagColorTop  = "&HF6FBFF&"
        newTagColorBot  = "&HC3DBEB&"
        bordBlur        = ""
        bordSize        = "\\bord0"
        additionalTags  = ""
        newTagPositionY1=tagPositionY-clipMod*6
        newTagPositionY2=tagPositionY-clipMod*3
      elseif res.style == options.poro5 then -- white to red, italic fsc300
        newTagColorTop  = "&HF9F9FF&"
        newTagColorBot  = "&H8C4AFA&"
        bordBlur        = ""
        bordSize        = "\\bord0"
        additionalTags  = "\\fax-0.2"
        newTagPositionY1=tagPositionY-clipMod*6
        newTagPositionY2=tagPositionY-clipMod*3
      elseif res.style == options.poro6 then -- white to light blue
        newTagColorTop  = "&HFFF6F0&"
        newTagColorBot  = "&HF9D3B5&"
        bordBlur        = ""
        bordSize        = "\\bord0"
        additionalTags  = ""
        newTagPositionY1=tagPositionY-clipMod*6
        newTagPositionY2=tagPositionY-clipMod*3
      elseif res.style == options.poro7 then -- yellow to green
        newTagColorTop  = "&HB9F6FE&"
        newTagColorBot  = "&HD4E0CA&"
        bordBlur        = ""
        bordSize        = "\\bord0"
        additionalTags  = ""
        newTagPositionY1=tagPositionY-clipMod*6
        newTagPositionY2=tagPositionY-clipMod*3
      elseif res.style == options.poro8 then -- pink gradient 2, italic
        newTagColorTop  = "&HB16FFB&"
        newTagColorBot  = "&H763A8A&"
        bordBlur        = ""
        bordSize        = "\\bord0"
        additionalTags  = "\\fax-0.2"
        newTagPositionY1=tagPositionY-clipMod*6
        newTagPositionY2=tagPositionY-clipMod*3
      elseif res.style == options.poro9 then -- yellow to light blue
        newTagColorTop  = "&HC6F6FF&"
        newTagColorBot  = "&HCADCC6&"
        bordBlur        = ""
        bordSize        = "\\bord0"
        additionalTags  = ""
        newTagPositionY1=tagPositionY-clipMod*6
        newTagPositionY2=tagPositionY-clipMod*3		
      end


      newTagClipTop="\\clip(0,0,1280,"..newTagPositionY1..")"
      newTagClipMid="\\clip(0,"..newTagPositionY1..",1280,"..newTagPositionY2..")"
      newTagClipBot="\\clip(0,"..newTagPositionY2..",1280,720)"

      newLines={}
      actor=newLine.actor
      newLine=currentLine
      newLine.comment=false
      newLine.start_time=newStart
      if bordSize ~= "\\bord0" then
        newLine.actor=actor.."_bord"
        newTextBord=newText:gsub("\\alpha&H00&", "\\alpha&H33&")
        newTextBord=newTextBord:gsub("\\blur%d*%.?%d*", bordBlur)
        newTagsBord=tags:gsub("\\bord%d*%.?%d*", bordSize)
        newLine.text="{"..newTagsBord..additionalTags.."\\c"..newTagColorBord.."\\3c"..newTagColorBord.."}"..newTextBord
        insertLine(subs, sel, newLine)
      end
      newLine.actor=actor.."_top"
      newLine.text="{"..tags..additionalTags..newTagClipTop.."\\c"..newTagColorTop.."}"..newText
      insertLine(subs, sel, newLine)
      newLine.actor=actor.."_mid"
      newLine.text="{"..tags..additionalTags..newTagClipMid.."\\c"..newTagColorTop.."}"..newText
      insertLine(subs, sel, newLine)
      newLine.actor=actor.."_bot"
      newLine.text="{"..tags..additionalTags..newTagClipBot.."\\c"..newTagColorBot.."}"..newText
      insertLine(subs, sel, newLine)
    end
  end
end
linePositionCounter=0
function insertLine(subs, sel, line)
  subs.insert(sel[#sel]+linePositionCounter, line)
  linePositionCounter=linePositionCounter+1
end
function div(a,b)
  --http://lua-users.org/wiki/SimpleRound
  return (a - a % b) / b
end
function saveconfig()
  --ua.BlurAndGlow.lua
  bgconf=script_name.." config\n\n"
    for key,val in ipairs(GUI) do
      if val.class=="floatedit" or val.class=="edit" or val.class=="dropdown" or val.class=="color" then
        bgconf=bgconf..val.name..":"..res[val.name].."\n"
      end
      if val.class=="checkbox" and val.name~="save" then
        bgconf=bgconf..val.name..":"..tf(res[val.name]).."\n"
      end
    end
  config=ADP("?user")..pathSeparator..script_name..".conf"
  file=io.open(config, "w")
  file:write(bgconf)
  file:close()
  ADD({{class="label",label="Config saved to:\n"..config}},{"OK"},{close='OK'})
end
function loadconfig()
  --ua.BlurAndGlow.lua
  config=ADP("?user")..pathSeparator..script_name..".conf"
  file=io.open(config)
  if file~=nil then
    konf=file:read("*all")
    io.close(file)
    for key,val in ipairs(GUI) do
      if val.class=="floatedit" or val.class=="edit" or val.class=="checkbox" or val.class=="dropdown" or val.class=="color" then
        if konf:match(val.name) then val.value=detf(konf:match(val.name..":(.-)\n")) end
      end
    end
  end
end
function tf(val)
  --ua.BlurAndGlow.lua
  if val==true then ret="true"
  elseif val==false then ret="false"
  else ret=val end
  return ret
end
function detf(txt)
  --ua.BlurAndGlow.lua
  if txt=="true" then ret=true
  elseif txt=="false" then ret=false
  else ret=txt end
  return ret
end

function main(subs,sel)
  ADD=aegisub.dialog.display
  ADP=aegisub.decode_path
  ak=aegisub.cancel
  pathSeparator=package.config:sub(1,1)
  hints={
    mode=">PoRO: utilize when typing PoRO recap signs"
  }
  options={
    poro1="white to red",
    poro2="orange to purple, italic frx30",
    poro3="pink gradient, italic frx30",
    poro4="white to yellow",
    poro5="white to red, italic frx40",
    poro6="white to light blue",
    poro7="yellow to green",
    poro8="pink gradient 2, italic",
	poro9="yellow to light blue"
  }
  GUI={
    {name="modeLabel",   x=0,  y=0,  class="label",     label="Mode:",  hint=hints.mode},
    {name="mode",        x=1,  y=0,  class="dropdown",  width=2,  items={"Standard", ">PoRO"}, value="Standard"},
    {name="styleLabel",  x=0,  y=1,  class="label",     label="Style:"},
    {name="style",       x=1,  y=1,  class="dropdown",  width=2,  items=options, value=nil},
    {name="lengthLabel", x=0,  y=2,  class="label",     label="Length:"},
    {name="length",      x=1,  y=2,  class="floatedit", width=2},
    {name="rtl",         x=0,  y=3,  class="checkbox",  width=2,  label="from right to left"},
    {name="rep",         x=0,  y=4,  class="checkbox",  width=2,  label="repeat with last settings"},
    {name="save",        x=0,  y=5,  class="checkbox",  width=2,  label="save configuration"},
  }

  loadconfig()
	buttons={"Go!", "Cancel"}
	pressed,res=ADD(GUI,buttons,{ok='Go!',close='Cancel'})
	if pressed=="cancel" then ak() end
	if res.save then saveconfig()
	else
    if res.rep then res=lastres end
    if pressed=="Go!" then alpha(subs,sel) end
  end
	if res.rep==false then lastres=res end
	aegisub.set_undo_point(script_name)
	return sel
end

aegisub.register_macro(submenu.."/"..script_name, script_description, main)
