-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Author : Surya Neupane (aka - codeArtist)

local widget = require( "widget" )

-- the input text field for taking setDuration input
local setDurationField
local restIntervalField
local setEndWarningField
local setsField
local timerPaused = false
local timerStarted = false
local pauseBtn
local secondsCounter = 0
local minutesCounter = 0
local noOfSets = 1
local currentSetNumber = 1
local totalSetDurationInSec = 0
local totalrestDurationInSec = 0
local totalTime = 0
-- the timerOnRestInterval variable notifies if the timer is running on rest interval or set duration
local timerOnRestInterval = false
local setEndWarningInSec = 0

local backRectangle = display.newRect( 0, 0, 960, 1440 )
backRectangle.x = display.contentCenterX
backRectangle.y = display.contentCenterY
backRectangle:setFillColor( 0,0,0 )

local startSound = audio.loadSound( "audio/startRing.mp3" )
local warningSound = audio.loadSound( "audio/warningRing.ogg" )
local endSound = audio.loadSound( "audio/endRing.mp3" )

local optionsForText = 
{
    text = "Workout Timer",     
    x = display.contentCenterX,
    y = -50,
    font = native.systemFont,   
    fontSize = 24,
    align = "center"  -- Alignment parameter
}

local appTitleText = display.newText( optionsForText )
appTitleText:setFillColor( 1, 1, 1 )

audio.setVolume( 1 )

local timerCircle = display.newCircle( display.contentCenterX, display.contentCenterY - 20, display.viewableContentWidth/2 - 20 )
timerCircle:setFillColor( 0,0,0 )
timerCircle.strokeWidth = 10
timerCircle:setStrokeColor( 0.1,0.6,0.7)

optionsForText = 
{
	text = "00:00",
	x = timerCircle.x,
	y = timerCircle.y,
	font = native.systemFont,
	fontSize = 90,
	align = "center"
}

local timeText = display.newText(optionsForText)
timeText:setFillColor(1,1,1)

-- this text indicates whether the interval is "Set" or "Rest"
optionsForText.fontSize = 40
local intervalIndicatorText = display.newText(optionsForText)
intervalIndicatorText.text = "Set"
intervalIndicatorText:setFillColor(0,1,0)
intervalIndicatorText.y = timerCircle.y - timerCircle.width/3

-- this text is for information about number of sets going on
local noOfSetsText = display.newText(optionsForText)
noOfSetsText.text = "1/20"
noOfSetsText:setFillColor(0,1,0)
noOfSetsText.y = timerCircle.y + timerCircle.width/3

local setDurationSecondsCounter = 0
local restIntervalSecondsCounter = 0
local function timeChanger(event)
    
    if (not timerOnRestInterval) then
    	-- for the setduration

		setDurationSecondsCounter = setDurationSecondsCounter + 1

		-- the below if code is to sound the warning bell of set
		if (totalSetDurationInSec - setEndWarningInSec == setDurationSecondsCounter) then
			-- print( "warning" )
			audio.play(warningSound)
			intervalIndicatorText.text = "Warning"
			intervalIndicatorText:setFillColor(0.96,0.6,0.2)
			intervalIndicatorText.size = 35
		end

	    if (totalSetDurationInSec <= setDurationSecondsCounter) then
	    	currentSetNumber = currentSetNumber + 1
	    	setDurationSecondsCounter = 0
	    	noOfSetsText.text = currentSetNumber ..'/'..noOfSets
	    	secondsCounter = 0
	    	minutesCounter = 0
	    	timerOnRestInterval = true
	    	intervalIndicatorText.text = "Rest"
	    	intervalIndicatorText:setFillColor(0.8,0.9,0.05)
	    	intervalIndicatorText.size = 40
	    	audio.play(endSound)
	    end
    else
    	-- for the rest interval

    	restIntervalSecondsCounter = restIntervalSecondsCounter + 1
    	if (restIntervalSecondsCounter >= totalrestDurationInSec) then
    		secondsCounter = 0
    		minutesCounter = 0
    		restIntervalSecondsCounter = 0
    		timerOnRestInterval = false
    		intervalIndicatorText.text = "Set"
    		intervalIndicatorText.size = 40
    		intervalIndicatorText:setFillColor(0,1,0)
    		audio.play(startSound)
    	end

    end

    secondsCounter = secondsCounter + 1
    if (secondsCounter>=60) then
    	minutesCounter = minutesCounter + 1
    	secondsCounter = 0
    end
    timeText.text = string.format('%02d',minutesCounter)..':'..string.format('%02d',secondsCounter)
end
-- Function to handle button events
local function handleStartButtonEvent( event )
 
    if ( "ended" == event.phase ) then
        -- print( "Button was pressed and released" )
        -- can check for the setDuration text is valid time or not

        -- Prevent device from automatically locking
        system.setIdleTimer(false)


        if (not timerStarted) then
        	-- timerStarted has been checked for making sure that button might be pressed many times
        	-- during on going timer
        	audio.play(startSound)
        	timerStarted = true
        	currentSetNumber = 1
	        local setDurationSecond = string.sub(setDurationField.text,4,5)
	        local setDurationMinute = string.sub(setDurationField.text,1,2)
	        noOfSets = setsField.text
	        totalSetDurationInSec = setDurationSecond + setDurationMinute*60

	        local restDurationSecond = string.sub(restIntervalField.text,4,5)
	        local restDurationMinute = string.sub(restIntervalField.text,1,2)
	        totalrestDurationInSec = restDurationSecond + restDurationMinute*60

	        setEndWarningInSec = string.sub(setEndWarningField.text,4,5) + string.sub(setEndWarningField.text,1,2)*60

	        totalTime = (totalSetDurationInSec + totalrestDurationInSec) * noOfSets
	        local timerIteration = totalTime
	        -- timer gets called every second
	        timer.performWithDelay( 1000, timeChanger, timerIteration,'oneSecTimer')
	        
        end

    end
end
 
-- Create the widget
local startBtn = widget.newButton(
    {
        label = "button",
        onEvent = handleStartButtonEvent,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = 80,
        height = 30,
        cornerRadius = 15,
        fillColor = { default={0,1,0,1}, over={0,1,1,1} },
        -- strokeColor = { default={1,1,1,1}, over={0.8,0.8,0.8,1} },
        -- strokeWidth = 2,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 1 } }
    }
)

-- Center the button
startBtn.x = display.contentCenterX
startBtn.y = timerCircle.y + timerCircle.height/2 + startBtn.height + 20
 
-- Change the button's label text
startBtn:setLabel( "Start" )


-- Function to handle button events
local function handlePauseButtonEvent( event )
 
    if ( "ended" == event.phase ) then

        -- can check for the setDuration text is valid time or not
        if (timerStarted) then

	        if (not timerPaused) then
	        	timerPaused = true
	        	timer.pauseAll()
	        	pauseBtn:setFillColor(0,1,0)
	        	pauseBtn:setLabel( "Resume" )
	        else
	        	timerPaused = false
	        	timer.resumeAll( )
	        	pauseBtn:setLabel( "Pause" )
	        end

        end

    end
end

-- Create the widget
pauseBtn = widget.newButton(
    {
        label = "button",
        onEvent = handlePauseButtonEvent,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = 80,
        height = 30,
        cornerRadius = 15,
        fillColor = { default={ 0.1,0.6,0.7,1}, over={ 0.1,0.9,0.9,1} },
        -- strokeColor = { default={1,1,1,1}, over={0.8,0.8,0.8,1} },
        -- strokeWidth = 2,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 1 } }
    }
)

-- Center the button
pauseBtn.x = pauseBtn.width/2 + 10
pauseBtn.y = timerCircle.y + timerCircle.height/2 + pauseBtn.height + 20
 
-- Change the button's label text
pauseBtn:setLabel( "Pause" )

local function handleStopButtonEvent( event )
 
    if ( "ended" == event.phase ) then

    	timerPaused = false
    	pauseBtn:setFillColor(0.1,0.6,0.7,1)
	    pauseBtn:setLabel( "Pause" )

        if (timerStarted) then
        	timer.cancelAll( )
        	timeText.text = "00:00"
        	timerStarted = false
        	secondsCounter = 0
        	minutesCounter = 0
        	noOfSetsText.text = '1'..'/'..setsField.text
        	setDurationSecondsCounter = 0
        	restIntervalSecondsCounter = 0
        	timerOnRestInterval = false
        end

    end
end

-- Create the widget
local stopBtn = widget.newButton(
    {
        label = "button",
        onEvent = handleStopButtonEvent,
        emboss = false,
        -- Properties for a rounded rectangle button
        shape = "roundedRect",
        width = 80,
        height = 30,
        cornerRadius = 15,
        fillColor = { default={ 1,0.2,0.2,1}, over={ 1,0.4,0.5,1} },
        -- strokeColor = { default={1,1,1,1}, over={0.8,0.8,0.8,1} },
        -- strokeWidth = 2,
        labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 1 } }
    }
)

-- Center the button
stopBtn.x = display.viewableContentWidth - stopBtn.width/2 - 10
stopBtn.y = timerCircle.y + timerCircle.height/2 + stopBtn.height + 20
 
-- Change the button's label text
stopBtn:setLabel( "Reset" )
 
local function setstextListener( event )
 
    if ( event.phase == "ended" ) then
        -- User finished editing "setsField"
        noOfSetsText.text = '1/'..event.target.text
    end
end
 
-- Create text field
setsField = native.newTextField( 0, timerCircle.y - timerCircle.height/2 - 40, 30, 30 )
setsField.inputType = "number"
setsField:addEventListener( "userInput", setstextListener )
setsField.placeholder = "20"
setsField.text = "20"
setsField.x = setsField.width/2 + 10

optionsForText.text = "Sets"
optionsForText.fontSize = 13
optionsForText.align = "Left"
optionsForText.x = 0
optionsForText.y = setsField.y - setsField.height/2 - 15
local setsLabelText = display.newText( optionsForText )
setsLabelText:setFillColor( 1, 1, 1 )
setsLabelText.x = setsField.x - setsField.width/2 + setsLabelText.width/2

 
local function textListener( event )
 
    if ( event.phase == "began" ) then
        -- User begins editing "defaultField"
 
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
        if (not string.match(event.target.text, "^%d%d:%d%d$")) then
        	setDurationField.text = "00:00"
        	setDurationField:setTextColor(1,0,0)
        else
        	setDurationField:setTextColor(0,0,0)
        end
 
    elseif ( event.phase == "editing" ) then
        -- print( event.newCharacters )
        -- print( event.oldText )
        -- print( event.startPosition )
        -- print( event.text )
    end
end
 
-- Create text field
setDurationField = native.newTextField( setsField.x + setsField.width/2 + 50, setsField.y, 60, 30 )
setDurationField.placeholder = "00:00"
setDurationField.text = "00:45"
setDurationField:addEventListener( "userInput", textListener )


optionsForText.text = "Set Duration"
optionsForText.fontSize = 13
optionsForText.align = "Left"
optionsForText.x = 0
optionsForText.y = setDurationField.y - setDurationField.height/2 - 15
local setDurationLabelText = display.newText( optionsForText )
setDurationLabelText:setFillColor( 1, 1, 1 )
setDurationLabelText.x = setDurationField.x - setDurationField.width/2 + setDurationLabelText.width/2

 
local function restIntervalTextListener( event )
 
    if ( event.phase == "began" ) then
        -- User begins editing "defaultField"
 
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
        if (not string.match(event.target.text, "^%d%d:%d%d$")) then
        	restIntervalField.text = "00:00"
        	restIntervalField:setTextColor(1,0,0)
        else
        	restIntervalField:setTextColor(0,0,0)
        end
        
    elseif ( event.phase == "editing" ) then
        -- print( event.newCharacters )
        -- print( event.oldText )
        -- print( event.startPosition )
        -- print( event.text )
    end
end
 
-- Create text field
restIntervalField = native.newTextField( setDurationField.x + setDurationField.width/2 + 50, setDurationField.y, 60, 30 )
restIntervalField.placeholder = "00:00"
restIntervalField.text = "00:15"
restIntervalField:addEventListener( "userInput", restIntervalTextListener )


optionsForText.text = "Rest Interval"
optionsForText.fontSize = 13
optionsForText.align = "Left"
optionsForText.x = 0
optionsForText.y = restIntervalField.y - restIntervalField.height/2 - 15
local restIntervalLabelText = display.newText( optionsForText )
restIntervalLabelText:setFillColor( 1, 1, 1 )
restIntervalLabelText.x = restIntervalField.x - restIntervalField.width/2 + restIntervalLabelText.width/2

 
local function setEndWarningTextListener( event )
 
    if ( event.phase == "began" ) then
        -- User begins editing "defaultField"
 
    elseif ( event.phase == "ended" or event.phase == "submitted" ) then
        -- Output resulting text from "defaultField"
        if (not string.match(event.target.text, "^%d%d:%d%d$")) then
        	setEndWarningField.text = "00:00"
        	setEndWarningField:setTextColor(1,0,0)
        else
        	setEndWarningField:setTextColor(0,0,0)
       	end
 
    elseif ( event.phase == "editing" ) then
        -- print( event.newCharacters )
        -- print( event.oldText )
        -- print( event.startPosition )
        -- print( event.text )
    end
end
 
-- Create text field
setEndWarningField = native.newTextField( restIntervalField.x + restIntervalField.width/2 + 50, restIntervalField.y, 60, 30 )
setEndWarningField.placeholder = "00:00"
setEndWarningField.text = "00:10"
setEndWarningField:addEventListener( "userInput", setEndWarningTextListener )


optionsForText.text = "SetEnd Warning"
optionsForText.fontSize = 13
optionsForText.align = "Left"
optionsForText.x = 0
optionsForText.y = setEndWarningField.y - setEndWarningField.height/2 - 15
local setEndWarningLabelText = display.newText( optionsForText )
setEndWarningLabelText:setFillColor( 1, 1, 1 )
setEndWarningLabelText.x = setEndWarningField.x - setEndWarningField.width/2 + setEndWarningLabelText.width/2

optionsForText.text = "@waanni.com"
optionsForText.fontSize = 11
optionsForText.align = "Center"
optionsForText.x = display.contentCenterX
optionsForText.y = display.viewableContentHeight - 5
local stampText = display.newText (optionsForText)