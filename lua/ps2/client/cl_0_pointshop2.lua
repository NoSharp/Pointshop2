Pointshop2.Menu = nil
Pointshop2.RegisteredTabs = {}

function Pointshop2:OpenMenu( )
	if not IsValid( Pointshop2.Menu ) then
		Pointshop2.Menu = vgui.Create( "DPointshopFrame" )
		Pointshop2.Menu:Center( )
	end
	Pointshop2.Menu:Show( )
	CloseDermaMenus( )
	Pointshop2.Menu:MakePopup( )
	Pointshop2.Menu:SetKeyboardInputEnabled( false )
	Pointshop2.Menu:SetMouseInputEnabled( true )
	
	gui.EnableScreenClicker( true )
end

--[[---------------------------------------------------------
   Name: HOOK PointshopMenuKeyboardFocusOn
		Called when text entry needs keyboard focus
-----------------------------------------------------------]]
local function PointshopMenuKeyboardFocusOn( pnl )
	if not ValidPanel( Pointshop2.Menu ) then
		return 
	end
	
	if IsValid( pnl ) and not pnl:HasParent( Pointshop2.Menu ) then 
		return 
	end
	
	Pointshop2.Menu:StartKeyFocus( pnl )
end
hook.Add( "OnTextEntryGetFocus", "PointshopMenuKeyboardFocusOn", PointshopMenuKeyboardFocusOn )

--[[---------------------------------------------------------
   Name: HOOK PointshopMenuKeyboardFocusOff
		Called when text entry stops needing keyboard focus
-----------------------------------------------------------]]
local function PointshopMenuKeyboardFocusOff( pnl )
	if not ValidPanel( Pointshop2.Menu ) then
		return 
	end
	
	if IsValid( pnl ) and not pnl:HasParent( Pointshop2.Menu ) then 
		return 
	end
	
	Pointshop2.Menu:EndKeyFocus( pnl )
end
hook.Add( "OnTextEntryLoseFocus", "PointshopMenuKeyboardFocusOff", PointshopMenuKeyboardFocusOff )

function Pointshop2:CloseMenu( )
	if not IsValid( Pointshop2.Menu ) then
		return 
	end
	Pointshop2.Menu:Hide( )
	Pointshop2.Menu:Remove( )
	gui.EnableScreenClicker( false )
end

function Pointshop2:AddTab( title, controlName )
	KLogf( 4, "     - Tab %s: %s added", title, controlName )
	for k, v in pairs( Pointshop2.RegisteredTabs ) do
		if v.title == title then
			return
		end
	end
	table.insert( Pointshop2.RegisteredTabs, { title = title, control = controlName } )
end

--debug
concommand.Add( "pointshop2_reload", function( )
	Pointshop2.CloseMenu( )
	RunConsoleCommand( "libk_reload" )
	hook.Add( "OnReloaded", "openWhenReady", function( )
		timer.Simple( 2, function( )
			CompileString( "Pointshop2.OpenMenu( )", "chink" )( )
		end )
	end )
end )