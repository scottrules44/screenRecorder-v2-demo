local screenRecorder = require "plugin.screenRecorder.v2"
local json = require"json"

local widget = require('widget')
local json = require('json')

local _W, _H = display.actualContentWidth, display.actualContentHeight
local _CX, _CY = display.contentCenterX, display.contentCenterY

local width = _W * 0.8
local size = _H * 0.1
local buttonFontSize = 16
local spacing = _H * 0.12

widget.newButton{
	x = _CX, y = _CY-100,
	width = width, height = size,
    fillColor = { default={1,1,1,1}, over={1,1,1,0.4} },
	label = 'Start Screen Recordering',
	fontSize = buttonFontSize,
	onRelease = function()
		screenRecorder.start{
            listener = function(e)
                print(json.encode(e))
                screenRecorder.setCamera({show=true, x=_CX,y= _CY  })
            end,
            cameraEnabled = true,
            microphoneEnabled= true,
						appAudioEnabled = true, --only supported on Android (default is false)
            path=system.pathForFile( "myRec.mp4", system.TemporaryDirectory ) -- saves to temp dir
        }
	end
}
widget.newButton{
	x = _CX, y = _CY-50,
	width = width, height = size,
    fillColor = { default={1,1,1,1}, over={1,1,1,0.4} },
	label = 'Stop Screen Recordering',
	fontSize = buttonFontSize,
	onRelease = function()
		screenRecorder.stop()
	end
}
timer.performWithDelay( 1000, function()
	screenRecorder.requestPermission("microphoneCamera", function ()
	end)
end )


local video = native.newVideo( display.contentCenterX, display.contentCenterY+100, 320, 480)
widget.newButton{
    x = _CX, y = _CY,
    width = width, height = size,
    fillColor = { default={1,1,1,1}, over={1,1,1,0.4} },
    label = 'Show Screen Recordering',
    fontSize = buttonFontSize,
    onRelease = function()

        media.playVideo( "myRec.mp4", system.TemporaryDirectory, true, function  (e)
        	video:play()
        end )
        video:pause()
    end
}

timer.performWithDelay( 2000, function()
	local options =
	{
	    appPermission = "Microphone",
	    urgency = "Critical",
	    rationaleTitle = "Microphone access required",
	    rationaleDescription = "Microphone access is required to take Mic. Re-request now?",
	    settingsRedirectTitle = "Alert",
	    settingsRedirectDescription = "Without the ability to take Microphone, this app cannot properly function. Please grant Microphone access within Settings."
	}
	native.showPopup( "requestAppPermission", options )
end )
-- Load a video
local function doesFileExist( fname, path )

    local results = false

    -- Path for the file
    local filePath = system.pathForFile( fname, path )

    if ( filePath ) then
        local file, errorString = io.open( filePath, "r" )

        if not file then
            -- Error occurred; output the cause
            print( "File error: " .. errorString )
        else
            -- File exists!
            print( "File found: " .. fname )
            results = true
            -- Close the file handle
            file:close()
        end
    end

    return results
end
function copyFile( srcName, srcPath, dstName, dstPath, overwrite )

    local results = false

    local fileExists = doesFileExist( srcName, srcPath )
    if ( fileExists == false ) then
        return nil  -- nil = Source file not found
    end

    -- Check to see if destination file already exists
    if not ( overwrite ) then
        if ( fileLib.doesFileExist( dstName, dstPath ) ) then
            return 1  -- 1 = File already exists (don't overwrite)
        end
    end

    -- Copy the source file to the destination file
    local rFilePath = system.pathForFile( srcName, srcPath )
    local wFilePath = system.pathForFile( dstName, dstPath )

    local rfh = io.open( rFilePath, "rb" )
    local wfh, errorString = io.open( wFilePath, "wb" )

    if not ( wfh ) then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
        return false
    else
        -- Read the file and write to the destination directory
        local data = rfh:read( "*a" )
        if not ( data ) then
            print( "Read error!" )
            return false
        else
            if not ( wfh:write( data ) ) then
                print( "Write error!" )
                return false
            end
        end
    end

    results = 2  -- 2 = File copied successfully!

    -- Close file handles
    rfh:close()
    wfh:close()

    return results
end
copyFile( "myVideo.m4v.txt", nil, "myVideo.m4v", system.DocumentsDirectory, true )

-- Load a video
video:load( "myVideo.m4v", system.DocumentsDirectory )
video:play()



--This does not work
--[[
local webView = native.newWebView( display.contentCenterX, display.contentCenterY+100, 220, 280 )
webView:request( "https://youtube.com/" )
]]--
--this is sample I got from corona sample code
local arguments =
{
{ x=100, y=60, w=100, h=100, r=10, red=1, green=0, blue=0 },
{ x=60, y=100, w=100, h=100, r=10, red=0, green=1, blue=0 },
{ x=140, y=140, w=100, h=100, r=10, red=0, green=0, blue=1 }
}



local function onTouch( event )
    local t = event.target



    local phase = event.phase
    if "began" == phase then
    -- Make target the top-most object
    local parent = t.parent
    parent:insert( t )
    display.getCurrentStage():setFocus( t )

    -- Spurious events can be sent to the target, e.g. the user presses
    -- elsewhere on the screen and then moves the finger over the target.
    -- To prevent this, we add this flag. Only when it's true will "move"
    -- events be sent to the target.
    t.isFocus = true

    -- Store initial position
    t.x0 = event.x - t.x
    t.y0 = event.y - t.y
    elseif t.isFocus then
    if "moved" == phase then
    -- Make object move (we subtract t.x0,t.y0 so that moves are
    -- relative to initial grab point, rather than object "snapping").
    t.x = event.x - t.x0
    t.y = event.y - t.y0

    -- Gradually show the shape's stroke depending on how much pressure is applied.
    if ( event.pressure ) then
    t:setStrokeColor( 1, 1, 1, event.pressure )
    end
    elseif "ended" == phase or "cancelled" == phase then
    display.getCurrentStage():setFocus( nil )
    t:setStrokeColor( 1, 1, 1, 0 )
    t.isFocus = false
    end
    end

    -- Important to return true. This tells the system that the event
    -- should not be propagated to listeners of any objects underneath.
    return true
end

-- Iterate through arguments array and create rounded rects (vector objects) for each item
for _,item in ipairs( arguments ) do
    local button = display.newRoundedRect( item.x, item.y, item.w, item.h, item.r )
    button:setFillColor( item.red, item.green, item.blue )
    button.strokeWidth = 6
    button:setStrokeColor( 1, 1, 1, 0 )

    -- Make the button instance respond to touch events
    button:addEventListener( "touch", onTouch )
end
