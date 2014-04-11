local PANEL = {}

function PANEL:Init( )
	self.selectPlayerElem = vgui.Create( "DPanel" )
	self.selectPlayerElem:SetTall( 64 )
	self.selectPlayerElem:SetWide( self:GetWide( ) )
	function self.selectPlayerElem:Paint( ) end
	
	self.mdlPanel = vgui.Create( "SpawnIcon", self.selectPlayerElem )
	self.mdlPanel:SetSize( 64, 64 )
	self.mdlPanel:Dock( LEFT )
	self.mdlPanel:SetTooltip( "Click to Select" )
	local frame = self
	function self.mdlPanel:DoClick( )
		--Open model selector
		local window = vgui.Create( "DPlayerModelSelector" )
		window:Center( )
		window:MakePopup( )
		function window:OnChange( )
			frame.manualEntry.IgnoreChange = true
			frame.manualEntry:SetText( window.selectedModel )
			frame.manualEntry.IgnoreChange = false
			frame.mdlPanel:SetModel( window.selectedModel )
			frame.bodygroups = window.bodygroups
			frame.skin = window.skin
		end
	end
	
	local rightPnl = vgui.Create( "DPanel", self.selectPlayerElem )
	rightPnl:Dock( FILL )
	function rightPnl:Paint( )
	end

	self.manualEntry = vgui.Create( "DTextEntry", rightPnl )
	self.manualEntry:Dock( TOP )
	self.manualEntry:DockMargin( 5, 0, 5, 5 )
	self.manualEntry:SetTooltip( "Click on the icon or manually enter the model path here and press enter" )
	function self.manualEntry:OnEnter( )
		frame.bodygroups = "0"
		frame.skin = 0
		frame.mdlPanel:SetModel( self:GetText( ) )
	end
	
	local cont = self:addFormItem( "Model", self.selectPlayerElem )
	cont:SetTall( 64 )
end

function PANEL:SaveItem( saveTable )
	self.BaseClass.SaveItem( self, saveTable )
	saveTable.model = self.manualEntry:GetText( )
	saveTable.skin = self.skin
	saveTable.bodygroups = self.bodygroups
end

vgui.Register( "DPlayerModelCreator", PANEL, "DItemCreator" )