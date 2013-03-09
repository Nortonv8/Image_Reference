AddCSLuaFile()

if CLIENT then
	local function GenerateHTML(width,height,url)

		local css = [[
		body {
		  margin: 0;
		  padding: 0;
		  border: 0;
		  background: #000000;
		  overflow: hidden;
		}
		td {
		  text-align: center;
		  vertical-align: middle;
		}
		]]
			
		-- Resizing code
		local js = [[
		var keepResizing = true;
		function resize(obj) {
		  var ratio = obj.width / obj.height;
		  if (]] .. width .. [[ / ]] .. height .. [[ > ratio) {
			obj.style.width = (]] .. height .. [[ * ratio) + "px";
		  } else {
			obj.style.height = (]] .. width .. [[ / ratio) + "px";
		  }
		}
		setInterval(function() {
		  if (keepResizing && document.images[0]) {
			resize(document.images[0]);
		  }
		}, 1000);
		]]
			
		local body = [[
		<div style="width: ]] .. width .. [[px; height: ]] .. height .. [[px; overflow: hidden">
		<table border="0" cellpadding="0" cellmargin="0" style="width: ]] .. width .. [[px; height: ]] .. height .. [[px">
		<tr>
		<td style="text-align: center">
		<img src="]] .. url .. [[" alt="" onload="resize(this); keepResizing = false" style="margin: auto" />
		</td>
		</tr>
		</table>
		</div>
		]]
		
		return [[
		<!DOCTYPE html>
		<html>
		<head>
		<title>Image Reference</title>
		<style type="text/css">
		]] .. css .. [[
		</style>
		<script type="text/javascript">
		]] .. (js and js or "") .. [[
		</script>
		</head>
		<body>
		]] .. body .. [[
		</body>
		</html>
		]]
	end
	
	local Focus=false

	function imgref_menu( ply )
		local GenerateCanvas
		
		if IsValid(ImgrefMenu) and ImgrefMenu:IsVisible() then ImgrefMenu:Close() return end
		
		local LastSize={0,0}
		local Sheets={}
		
		ImgrefMenu = vgui.Create( "DFrame" )
		ImgrefMenu:SetSize( ScrW()*0.3, ScrH()*0.3 )
		ImgrefMenu:SetPos( ScrW()*0.02, ScrH()*0.02 )
		ImgrefMenu:SetTitle( "Image Reference" )
		ImgrefMenu:SetVisible( true )
		ImgrefMenu:SetScreenLock( true )
		ImgrefMenu:SetDraggable( true )
		ImgrefMenu:SetSizable(true)
		ImgrefMenu:SetMinWidth(ScrW()*0.2)
		ImgrefMenu:SetMinHeight(ScrH()*0.2)
		//ImgrefMenu:ShowCloseButton( false ) -- doesnt appear to work
		ImgrefMenu:MakePopup()
		
		local width=function() return ImgrefMenu:GetWide() - 10 end
		local height=function() return ImgrefMenu:GetTall() - 35 end
		
		local PropertySheet = vgui.Create( "DPropertySheet", ImgrefMenu )
		PropertySheet:SetPos( 5,30 )
		PropertySheet:SetSize( width(),height() )

		function GenerateCanvas(s)
			local Panel=vgui.Create("DPanel")
			
			local ImageCanvas = vgui.Create("HTML",Panel)
			ImageCanvas:SetPos(5,30)
			ImageCanvas:SetSize(width(),height())

			local URLEntry = vgui.Create("DTextEntry",Panel)
			URLEntry:SetPos( 5, 5 )
			URLEntry:SetSize(620,20)
			URLEntry:SetEnterAllowed( true )
			URLEntry.OnEnter = function()
				PropertySheet:SetSize(width(),height())
				ImageCanvas:SetSize(width()-25,height()-70)
				ImageCanvas:SetHTML(GenerateHTML(width(),height(),string.Trim(URLEntry:GetValue())))
				ImgrefMenu:SetMouseInputEnabled( false )
				ImgrefMenu:SetKeyboardInputEnabled( false )
				LastSize={width(),height()}
			end
			URLEntry.OnGetFocus = function()
				Focus=true
			end
			URLEntry.OnLoseFocus = function()
				/*
				if Focus then
					ImgrefMenu:SetMouseInputEnabled( false )
					ImgrefMenu:SetKeyboardInputEnabled( false )
				end
				*/
				Focus=false
			end
			
			function URLEntry:Think()
				self:SetWidth(width()-25)
			end
			
			function ImageCanvas:Think()
				if not ((width()==LastSize[1]) and (height()==LastSize[2])) then
					PropertySheet:SetSize(width(),height())
					ImageCanvas:SetSize(width()-25,height()-70)
					ImageCanvas:SetHTML(GenerateHTML(width(),height(),string.Trim(URLEntry:GetValue())))
					LastSize={width(),height()}
				end
			end
			
			Sheets[#Sheets+1]=PropertySheet:AddSheet(s, Panel, "icon16/book.png")
			PropertySheet:SetActiveTab(Sheets[#Sheets].Tab)
			URLEntry:RequestFocus()
		end
		
		GenerateCanvas("")
		
		local newCanvas = vgui.Create("DImageButton", ImgrefMenu)
		newCanvas:SetPos(width()-105,5)
		newCanvas:SetImage( "icon16/add.png" )
		newCanvas:SizeToContents()
		newCanvas:SetToolTip("Click to create a new image reference tab")
		newCanvas.DoClick = function()
			GenerateCanvas("")
		end
		function newCanvas:Think()
			newCanvas:SetPos(width()-105,5)
		end

	end
	concommand.Add( "imgref_menu", imgref_menu )
	
	hook.Add("OnContextMenuOpen", "ImageRef-Plugin", function()
		if IsValid(ImgrefMenu) and ImgrefMenu:IsVisible() then
			ImgrefMenu:SetMouseInputEnabled( true )
			ImgrefMenu:SetKeyboardInputEnabled( true )
		end
	end)
	
	hook.Add("OnContextMenuClose", "ImageRef-Plugin", function()
		if IsValid(ImgrefMenu) and ImgrefMenu:IsVisible() and not Focus then
			ImgrefMenu:SetMouseInputEnabled( false )
			ImgrefMenu:SetKeyboardInputEnabled( false )
		end
	end)
end