local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.contentPanel = vgui.Create( "DPointshopContentPanel", self )
	self.contentPanel:Dock( FILL )
	self.contentPanel:EnableModify( )
	self.contentPanel:CallPopulateHook( "PS2_PopulateContent" )
	
	--Recreate content panel if items change
	hook.Add( "PS2_DynamicItemsUpdated", self, function( )
		self.contentPanel:Remove( )
		self:Init( )
	end )
	
	derma.SkinHook( "Layout", "PointshopManagementTab_Items", self )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManagementTab_Items", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Manage Items", "pointshop2/settings12.png", "DPointshopManagementTab_Items" )