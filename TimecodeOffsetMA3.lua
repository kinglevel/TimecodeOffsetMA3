require "gma3_helpers"


local pluginName = select(1, ...)
local componentName = select(2, ...)
local signalTable = select(3, ...)
local myHandle = select(4, ...)


-- Almost never tested

-- Github: https://github.com/kinglevel
-- Please commit or post updates for the community.





local function KingArt()

	local str = [[
 
 
                      /mMMMm\
                      |M3*3M|
                      \mMMMm/
                        /N\
                        M*M
         /vv\          |MMM|          /vv\
        |N33N|         |M*M|         |N33N|
         \o*o\         |MMM|         /o*o/
            \*\       |MM*MM|       /*/
/:M:\       \no\      |MMMMM|      /on/       /:M:\
|3*3N|       \*b\     |MM*MM|     /d*/       |N3*3|
 \dob/       \mMm\   |MMMMMMN|   /mMm/       \dob/
    |MM\      \M*Ms\ |MMM*MMM| /sM*M/      /MM|
    \MMMM\    |MMMMMMMMM###MMMMMMMMM|    /MMMM/
     |MMMMMbo-NMMMMMM###MMM###MMMMMMN-odMMMMM|
      \MMMMMMNMMMM###MM_SUM_MM###MMMMNMMMMMM/
       \MMMMMMM###MMM#LEDVARD#MMM###MMMMMMM/
        \MMM###MMM###MMM###MMM###MMM###MMM/
         \##MMM###MMM###MMM###MMM###MMM##/
         |mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm|
         .///////////////M\\\\\\\\\\\\\\\.
     .odNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNbo.
 
"Vision will blind. Severance ties. Median am I. True are all lies"

 
 
 
]]

	for line in string.gmatch(str, "[^\n]+") do
		--Printf(line)
	end

end





------------------------------------------------------------
-- Simple config block – tweak this for future variants
------------------------------------------------------------
local UI_CONFIG = {
    pluginName    = "Timecode Offset Tool",
    dialogWidth   = 800,
    titleBarText  = "Timecode Offset",
    subtitleText  = "Use +/- to adjust the selected timecode's offset.",
    stepSize      = 0.01,   -- default step size
}

------------------------------------------------------------
-- Utility: adjust selected timecode offset
------------------------------------------------------------
local Q24_SCALE = 2^24  -- 16,777,216 raw units per second

function AdjustOffset(mode, seconds)
    if type(seconds) ~= "number" then
        Printf("AdjustOffset(): invalid seconds value")
        return
    end

    local tc = SelectedTimecode()
    if not tc or tc.RAWOFFSETTCSLOT == nil then
        Printf("AdjustOffset(): No timecode selected")
        return
    end

    local currentRaw = tonumber(tc.RAWOFFSETTCSLOT) or 0
    local rawDelta   = math.floor(seconds * Q24_SCALE)

    local newRaw

    if mode == "plus" or mode == "+" then
        newRaw = currentRaw + rawDelta

    elseif mode == "minus" or mode == "-" then
        newRaw = currentRaw - rawDelta

    elseif mode == "SET" then
        newRaw = rawDelta  -- seconds converted directly to raw
    end

    tc.RAWOFFSETTCSLOT = newRaw

end

------------------------------------------------------------
-- Main window
------------------------------------------------------------
function MainWindow(displayHandle)
    -- Get the index of the display on which to create the dialog.
    local displayIndex = Obj.Index(GetFocusDisplay())
    if displayIndex > 5 then
        displayIndex = 1
    end

    -- Get the colors.
    local colorTransparent     = Root().ColorTheme.ColorGroups.Global.Transparent

    -- Get the overlay.
    local display        = GetDisplayByIndex(displayIndex)
    local screenOverlay  = display.ScreenOverlay

    -- Delete any UI elements currently displayed on the overlay.
    screenOverlay:ClearUIChildren()

    --------------------------------------------------------
    -- Base dialog
    --------------------------------------------------------
    local dialogWidth = UI_CONFIG.dialogWidth or 650
    local baseInput   = screenOverlay:Append("BaseInput")
    baseInput.Name        = UI_CONFIG.pluginName or "TimecodeOffsetTool"
    baseInput.H           = "0"
    baseInput.W           = dialogWidth
    baseInput.MaxSize     = string.format("%s,%s", display.W * 0.8, display.H)
    baseInput.MinSize     = string.format("%s,0", dialogWidth - 100)
    baseInput.Columns     = 1
    baseInput.Rows        = 2
    baseInput[1][1].SizePolicy = "Fixed"
    baseInput[1][1].Size       = "60"
    baseInput[1][2].SizePolicy = "Stretch"
    baseInput.AutoClose        = "No"
    baseInput.CloseOnEscape    = "Yes"

   

    --------------------------------------------------------
    -- Title bar
    --------------------------------------------------------
    local titleBar = baseInput:Append("TitleBar")
    titleBar.Columns = 2
    titleBar.Rows    = 1
    titleBar.Anchors = "0,0"
    titleBar[2][2].SizePolicy = "Fixed"
    titleBar[2][2].Size       = "50"
    titleBar.Texture          = "corner2"

    local titleBarIcon = titleBar:Append("TitleButton")
    titleBarIcon.Text     = UI_CONFIG.titleBarText or "Timecode Offset"
    titleBarIcon.Texture  = "corner1"
    titleBarIcon.Anchors  = "0,0"
    titleBarIcon.Icon     = "star"

    local titleBarCloseButton = titleBar:Append("CloseButton")
    titleBarCloseButton.Anchors       = "1,0"
    titleBarCloseButton.Texture       = "corner2"
    titleBarCloseButton.ToolTip       = "Close"
    titleBarCloseButton.PluginComponent = myHandle


    --------------------------------------------------------
    -- Dialog frame (body)
    -- rows: subtitle, offset row, meta+step row, buttons
    --------------------------------------------------------
    local dlgFrame = baseInput:Append("UILayoutGrid")
    dlgFrame.Columns = 1
    dlgFrame.Rows    = 4
    dlgFrame.Anchors = "0,1"
    dlgFrame[1][1].SizePolicy = "Fixed"  -- subtitle
    dlgFrame[1][1].Size       = "60"

    dlgFrame[1][2].SizePolicy = "Fixed"  -- Current offset, Name and Duration, inputsGrid.
    dlgFrame[1][2].Size       = "250"

    dlgFrame[1][3].SizePolicy = "Fixed"  -- meta + step controls
    dlgFrame[1][3].Size       = "60"

    dlgFrame[1][4].SizePolicy = "Fixed"  -- buttons
    dlgFrame[1][4].Size       = "80"



    --------------------------------------------------------
    -- Subtitle (row 1)
    --------------------------------------------------------
    local subTitle = dlgFrame:Append("UIObject")
    subTitle.Text          = UI_CONFIG.subtitleText or "Adjust selected timecode offset"
    subTitle.ContentDriven = "Yes"
    subTitle.ContentWidth  = "No"
    subTitle.TextAutoAdjust= "No"
    subTitle.Anchors       = {
        left   = 0,
        right  = 0,
        top    = 0,
        bottom = 0
    }
    subTitle.Padding       = {
        left   = 20,
        right  = 20,
        top    = 15,
        bottom = 15
    }
    subTitle.Font          = "Medium20"
    subTitle.HasHover      = "No"
    subTitle.BackColor     = colorTransparent

   

    --------------------------------------------------------
    -- Offset display grid (row 2)
    --------------------------------------------------------
    local inputsGrid = dlgFrame:Append("UILayoutGrid")
    inputsGrid.Columns = 10
    inputsGrid.Rows    = 4
    inputsGrid.Anchors = {
        left   = 0,
        right  = 0,
        top    = 1,
        bottom = 1
    }
    inputsGrid.Margin = {
        left   = 0,
        right  = 0,
        top    = 0,
        bottom = 0
    }

     --------------------------------------------------------
     --- items in offset display grid
     --- 
     --- 
     ---     -- Name label
    local nameLabel = inputsGrid:Append("UIObject")
    nameLabel.Text           = "Name"
    nameLabel.TextalignmentH = "Left"
    nameLabel.Anchors        = { left = 0, right = 5, top = 0, bottom = 0 }
    nameLabel.Padding        = "3,3"
    nameLabel.HasHover       = "No"



    -- Name value (populate once on start)
    local nameValue = inputsGrid:Append("UIObject")
    nameValue.Text           = "-"
    nameValue.TextalignmentH = "Left"
    nameValue.Anchors        = {left = 6,right = 9,top = 0,bottom = 0}
    nameValue.Padding        = "3,3"
    nameValue.HasHover       = "No"

    

    -- label: "Current Offset"
    local offsetLabel = inputsGrid:Append("UIObject")
    offsetLabel.Text           = "Current Offset"
    offsetLabel.TextalignmentH = "Left"
    offsetLabel.Anchors        = {left = 0, right = 5, top = 1, bottom = 1}
    offsetLabel.Padding        = "5,5"
    offsetLabel.Margin         = {left = 0, right = 0, top = 1, bottom = 1}
    offsetLabel.HasHover       = "No"

    -- value: shows OFFSETTCSLOT
    local offsetValue = inputsGrid:Append("UIObject")
    local initialOffset = "-"

    do
        local tc = SelectedTimecode()
        if tc and tc.OFFSETTCSLOT ~= nil then
            initialOffset = tc.OFFSETTCSLOT
        end
    end

    offsetValue.Text           = tostring(initialOffset)
    offsetValue.TextalignmentH = "Left"
    offsetValue.Padding        = "5,5"
    offsetValue.Anchors        = {left = 6,right = 9,top = 1,bottom = 1}
    offsetValue.Margin         = {left = 0,right = 0,top = 1,bottom = 1}
    offsetValue.HasHover       = "No"

    --------------------------------------------------------


    


     

    -- Duration label
    local durationLabel = inputsGrid:Append("UIObject")
    durationLabel.Text           = "Duration"
    durationLabel.TextalignmentH = "Left"
    durationLabel.Anchors        = { left = 0, right = 5, top = 2, bottom = 2 }
    durationLabel.Padding        = "3,3"
    durationLabel.HasHover       = "No"

    

    -- Duration value (populate once on start)
    local durationValue = inputsGrid:Append("UIObject")
    durationValue.Text           = "-"
    durationValue.TextalignmentH = "Left"
    durationValue.Anchors        = {left = 6,right = 9,top = 2,bottom = 2}
    durationValue.Padding        = "3,3"
    durationValue.HasHover       = "No"




    local stepSizeLabel = inputsGrid:Append("UIObject")
    stepSizeLabel.Text           = "Step Size (Seconds)"
    stepSizeLabel.TextalignmentH = "Centre"
    stepSizeLabel.Anchors        = { left = 0, right = 5, top = 3, bottom = 3 }
    stepSizeLabel.Padding        = "3,3"
    stepSizeLabel.HasHover       = "No"



    -- Step-size decrease ('.' button -> divide by 10)
    local stepDotButton = inputsGrid:Append("Button")
    stepDotButton.Textshadow      = 1
    stepDotButton.HasHover        = "Yes"
    stepDotButton.Text            = "-"
    stepDotButton.TextalignmentH  = "Centre"
    stepDotButton.Anchors        = { left = 6, right = 6, top = 3, bottom = 3 }
    stepDotButton.PluginComponent = myHandle
    stepDotButton.Clicked         = "StepSizeDotClicked"


    -- Step-size display (will be updated when step changes)
    local stepDisplay = inputsGrid:Append("UIObject")
    -- (This appended element will be present if metaGrid.Columns >= 6; keep it but hide if layout differs)
    stepDisplay.Text           = tostring(UI_CONFIG.stepSize)
    stepDisplay.TextalignmentH = "Centre"
    stepDisplay.Anchors        = { left = 7, right = 8, top = 3, bottom = 3 }
    stepDisplay.Padding        = "3,3"
    stepDisplay.HasHover       = "No"

    -- step-size increase button (placed next to meta grid display area)
    -- Note: we reuse metaGrid's last column for a '+' step button by appending here
    local stepPlusButton = inputsGrid:Append("Button")
    stepPlusButton.Textshadow      = 1
    stepPlusButton.HasHover        = "Yes"
    stepPlusButton.Text            = "+"
    stepPlusButton.TextalignmentH  = "Centre"
    stepPlusButton.Anchors        = { left = 9, right = 9, top = 3, bottom = 3 }
    stepPlusButton.PluginComponent = myHandle
    stepPlusButton.Clicked         = "StepSizePlusClicked"

    
    --------------------------------------------------------
    -- Button row (row 4)
    --------------------------------------------------------
    local buttonGrid = dlgFrame:Append("UILayoutGrid")
    buttonGrid.Columns = 3
    buttonGrid.Rows    = 1
    buttonGrid.Anchors = {
        left   = 0,
        right  = 0,
        top    = 3,
        bottom = 3
    }

    

    -- convenience text for offset buttons
    local stepSize = UI_CONFIG.stepSize or 0.01
    local function stepTextFor(size) return tostring(size) end
    local stepText = stepTextFor(stepSize)

    -- minus button (offset - stepSize)
    local minusButton = buttonGrid:Append("Button")
    minusButton.Anchors = {left = 0,right = 0,top = 0,bottom = 0}
    minusButton.Textshadow      = 1
    minusButton.HasHover        = "Yes"
    minusButton.Text            = "-" .. stepText
    minusButton.Font            = "Medium20"
    minusButton.TextalignmentH  = "Centre"
    minusButton.PluginComponent = myHandle
    minusButton.Clicked         = "MinusButtonClicked"


    -- plus button (offset + stepSize)
    local plusButton = buttonGrid:Append("Button")
    plusButton.Anchors = {
        left   = 1,
        right  = 1,
        top    = 0,
        bottom = 0
    }
    plusButton.Textshadow       = 1
    plusButton.HasHover         = "Yes"
    plusButton.Text             = "+" .. stepText
    plusButton.Font             = "Medium20"
    plusButton.TextalignmentH   = "Centre"
    plusButton.PluginComponent  = myHandle
    plusButton.Clicked          = "PlusButtonClicked"



    -- cancel button
    local cancelButton = buttonGrid:Append("Button")
    cancelButton.Anchors = {left = 2, right = 2, top = 0, bottom = 0 }
    cancelButton.Textshadow     = 1
    cancelButton.HasHover       = "Yes"
    cancelButton.Text           = "Cancel"
    cancelButton.Font           = "Medium20"
    cancelButton.TextalignmentH = "Centre"
    cancelButton.PluginComponent= myHandle
    cancelButton.Clicked        = "CancelButtonClicked"
    cancelButton.Visible        = "Yes"





    --------------------------------------------------------
    -- Handlers
    --------------------------------------------------------
    -- Close the window
    signalTable.CancelButtonClicked = function(caller)
        Echo("Cancel button clicked.")
        Obj.Delete(screenOverlay, Obj.Index(baseInput))
    end

    -- Update label helper (offset value)
    local function UpdateOffsetLabel()
        local tc = SelectedTimecode()
        if tc and tc.OFFSETTCSLOT ~= nil then
            offsetValue.Text = tostring(tc.OFFSETTCSLOT)
        else
            offsetValue.Text = "-"
        end
    end

    -- Update step display and update +/- button labels
    local function UpdateStepDisplay()
        stepDisplay.Text = tostring(stepSize)
        minusButton.Text = "-" .. tostring(stepSize) .. " (Behaving late)"
        plusButton.Text = "+" .. tostring(stepSize) .. " (triggered too fast)"
    end

    -- Minus button handler (offset - stepSize)
    signalTable.MinusButtonClicked = function(caller)
        AdjustOffset("minus", stepSize)
        UpdateOffsetLabel()
    end

    -- Plus button handler (offset + stepSize)
    signalTable.PlusButtonClicked = function(caller)
        AdjustOffset("plus", stepSize)
        UpdateOffsetLabel()
    end

    -- Step-size '.' button handler -> divide by 10 (smaller steps)
    signalTable.StepSizeDotClicked = function(caller)
        -- prevent going to zero
        if stepSize <= 1e-12 then return end
        stepSize = stepSize - 0.01
        UpdateStepDisplay()
    end

    -- Step-size '+' button handler -> multiply by 10 (larger steps)
    signalTable.StepSizePlusClicked = function(caller)
        stepSize = stepSize + 0.01
        UpdateStepDisplay()
    end

    -- Update Name and Duration once at startup (do not live update)
    do
        local tc = SelectedTimecode()
        if tc then
            nameValue.Text = tc.NAME or "-"
            durationValue.Text = tc.DURATION or "-"
        else
            nameValue.Text = "-"
            durationValue.Text = "-"
        end
    end

    -- Update displays immediately
    UpdateOffsetLabel()
    UpdateStepDisplay()
end

------------------------------------------------------------
-- Plugin entry
------------------------------------------------------------
local function main(display_handle)
    KingArt()
    Printf(UI_CONFIG.pluginName .. " started")
    MainWindow(display_handle)
end

return main