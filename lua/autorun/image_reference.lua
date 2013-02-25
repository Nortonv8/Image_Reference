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

	function imgref_menu( ply )
		if IsValid(ImgrefMenu) and ImgrefMenu:IsVisible() then ImgrefMenu:Close() return end
		
		local LastSize={0,0}
		
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
		local height=function() return ImgrefMenu:GetTall() - 55 end

		local ImageCanvas = vgui.Create("HTML", ImgrefMenu)
		ImageCanvas:SetPos(5,50)
		ImageCanvas:SetSize(width(),height())

		local URLEntry = vgui.Create( "DTextEntry", ImgrefMenu)
		URLEntry:SetPos( 5,27 )
		URLEntry:SetSize(620,20)
		URLEntry:RequestFocus()
		URLEntry:SetEnterAllowed( true )
		URLEntry.OnEnter = function()
			ImageCanvas:SetSize(width(),height())
			ImageCanvas:SetHTML(GenerateHTML(width(),height(),string.Trim(URLEntry:GetValue())))
			ImgrefMenu:SetMouseInputEnabled( false )
			ImgrefMenu:SetKeyboardInputEnabled( false )
			LastSize={width(),height()}
		end
		
		function URLEntry:Think()
			self:SetWidth(width())
		end
		
		function ImageCanvas:Think()
			if not ((width()==LastSize[1]) and (height()==LastSize[2])) then
				ImageCanvas:SetSize(width(),height())
				ImageCanvas:SetHTML(GenerateHTML(width(),height(),string.Trim(URLEntry:GetValue())))
				LastSize={width(),height()}
			end
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
		if IsValid(ImgrefMenu) and ImgrefMenu:IsVisible() then
			ImgrefMenu:SetMouseInputEnabled( false )
			ImgrefMenu:SetKeyboardInputEnabled( false )
		end
	end)
end