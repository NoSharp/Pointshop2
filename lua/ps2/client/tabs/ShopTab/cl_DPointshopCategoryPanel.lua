local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.title = vgui.Create( "DLabel", self )
	self.title:Dock( TOP )
	self.title:DockMargin( 8, 0, 5, 0 )
	
	self.layout = vgui.Create( "DTileLayout", self )
	self.layout:Dock( FILL )
	self.layout:DockMargin( 8, 8, 8, 8 )
	self.layout:SetBaseSize( 15 )
	self.layout:SetSpaceY( 5 )
	self.layout:SetSpaceX( 5 )
end

function PANEL:AddItems( )
	for _, itemClass in pairs( self.category.items ) do
		local itemClass = Pointshop2.GetItemClassByName( itemClass )
		local itemIcon = vgui.Create( itemClass:GetPointshopIconControl( ), self.layout )
		itemIcon:SetItemClass( itemClass )
	end
end

function PANEL:AddSubcategories( )
	for _, subcategory in pairs( self.category.subcategories ) do
		local subcategoryPanel = vgui.Create( "DPointshopCategoryPanel", self.layout )
		subcategoryPanel.OwnLine = true
		subcategoryPanel:SetCategory( subcategory, self.depth + 1 )
	end
end

function PANEL:SetCategory( category, depth )
	depth = depth or 0
	
	if depth == 3 and #category.subcategories > 0 then
		--Max depth reached
		KLogf( 3, "[Pointshop2][WARN] Reached max category depth for category %s, flattening all subcategories", category.self.label )
		
		--TODO: Test
		local function flatten( subcategory, tbl )
			tbl = tbl or {}
			for k, v in pairs( subcategory.subcategories ) do
				flatten( v, tbl )
				subcategory.subcategories[k] = nil
			end
			for k, v in pairs( subcategory.items ) do
				table.insert( subcategory.items, v )
			end
			subcategory.items = tbl
		end
		flatten( category )
	end
	
	self.depth = depth
	self.category = category
	
	self.title:SetText( category.self.label )
	self:AddItems( )
	self:AddSubcategories( )
	
	print( "Hooking layout ", "CategoryPanelLevel" .. self.depth, category.self.label )
	derma.SkinHook( "Layout", "CategoryPanelLevel" .. self.depth, self )
	Derma_Hook( self, "Paint", "Paint", "CategoryPanelLevel" .. self.depth )
end

function PANEL:PerformLayout( )
	if self.depth > 0 then
		local w, h = self:GetParent( ):GetSize( )
		self:SetSize( w, h )
	end	
	self.layout:PerformLayout( )
	self.layout:SizeToChildren( false, true )
	local w, h = self:ChildrenSize();
	self:SetHeight( h + 8 )
end

function PANEL:Paint( w, h )
end

derma.DefineControl( "DPointshopCategoryPanel", "", PANEL, "DPanel" )