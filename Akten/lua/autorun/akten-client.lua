if SERVER then return end
Alleexxii = Alleexxii or {}
Alleexxii.Akten = Alleexxii.Akten or {}

local screenWidth = ScrW()
local screenHeight = ScrH()

function Alleexxii.Akten.DrawList(Table)
    local ply = LocalPlayer()
    local screenWidth = ScrW()
    local screenHeight = ScrH()

    local frame = vgui.Create("XeninUI.Frame")
    frame:SetSize(screenWidth/1.5, screenHeight/1.75)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("Akten")

    local TableWithScrols = {
        [1] = {Name = "Name"},
        [2] = {Name = "Rang"},
        [3] = {Name = "Meister"},
        [4] = {Name = "Straftat"},
        [5] = {Name = "Datum"},
        [6] = {Name = "Haftzeit"},
    }

    for i=1,6 do
        TableWithScrols[i]["SPanel"] = vgui.Create("XeninUI.ScrollPanel",frame)
        TableWithScrols[i]["SPanel"]:Dock(LEFT)
        TableWithScrols[i]["SPanel"]:DockMargin( 0, 0, 0,  0)
        TableWithScrols[i]["SPanel"]:SetSize((screenWidth/1.5)/6)

        TableWithScrols[i]["SPanel"].OnVScroll = function(self,pos)
            for i,v in pairs(TableWithScrols) do
                if self.VBar:GetScroll() ~= v["SPanel"].VBar:GetScroll() then 
                    v["SPanel"].VBar:SetScroll(self.VBar:GetScroll())
                    v["SPanel"].pnlCanvas:SetPos( 0, pos )
                    self.pnlCanvas:SetPos( 0, pos )
                end
            end
        end
    end

    function AddRow(...) -- Args = Name,Rang,Meister,Straftat,Datum,Haftzeit (In minuten)
        local args = {...}
        for i=1,#args do
            local Row = TableWithScrols[i]["SPanel"]:Add("XeninUI.Category")
            Row:Dock( TOP )
            Row:DockMargin( 0, 0, 0, 0 )
            Row:SetName(args[i])
            Row.Expand = function(pln,state)
                if not state then return end
            end

            Row.Top:SetCooltip(args[i],0.01)
        end
    end
    AddRow("Name","Rang","Meister","Straftat","Datum","Haftzeit")

    for i=#Table,1,-1 do
        local v = Table[i]
        AddRow(v.Name,v.Rang,v.Meister,v.Straftat,v.Datum,v.Haftzeit)
    end

    return AddRow
end

function Alleexxii.Akten.OpenSendMenu()
    local ply = LocalPlayer()
    local screenWidth = ScrW()
    local screenHeight = ScrH()

    local frame = vgui.Create("XeninUI.Frame")
    frame:SetSize(screenWidth/5, screenHeight/2.35)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("Neue Akte")

	frame.Text1 = vgui.Create("DLabel", frame)
	frame.Text1:Dock(TOP)
	frame.Text1:DockMargin(10,10, 0, 0)
	frame.Text1:SetFont("XeninUI.Frame.Title")
    frame.Text1:SetText("Spieler :")
	frame.Text1:SetTextColor(color_white)

    local Button = vgui.Create("XeninUI.Category",frame)
    Button:SetName("Player")
    Button:Dock(TOP)
    Button:DockMargin( 10, 15, 10,  0)
    Button.Expand = function(pln,state)
        if frame.ply then
            frame.ply = nil
        end
        pln.players = vgui.Create("XeninUI.PlayerDropdown",frame)
        pln.players:SetParentPanel(pln)
        pln.players:SetData(player.GetAll())
        pln.players:SetDrawOnTop(true)
        local x, y = frame:LocalToScreen()
        pln.players:SetPos(gui.MouseX(), gui.MouseY())
        pln.players:MakePopup()
        
        pln.players.OnSelected = function(dropdown, sid64)
            if (!sid64) then return end
            frame.ply = player.GetBySteamID64(sid64)
            pln:SetName(frame.ply:Nick())
        end
        if not state then return end
    end

    frame.Text2 = vgui.Create("DLabel", frame)
	frame.Text2:Dock(TOP)
	frame.Text2:DockMargin(10,10, 0, 0)
	frame.Text2:SetFont("XeninUI.Frame.Title")
    frame.Text2:SetText("Meister :")
	frame.Text2:SetTextColor(color_white)

    frame.Meister = vgui.Create( "XeninUI.TextEntry", frame ) -- create the form as a child of frame
	frame.Meister:Dock( TOP )
    frame.Meister:DockMargin(10,5, 10, 10)
    frame.Meister:SetSize(25, 35)


    frame.Text3 = vgui.Create("DLabel", frame)
	frame.Text3:Dock(TOP)
	frame.Text3:DockMargin(10,5, 0, 0)
	frame.Text3:SetFont("XeninUI.Frame.Title")
    frame.Text3:SetText("Straftat :")
	frame.Text3:SetTextColor(color_white)

    frame.Straftat = vgui.Create( "XeninUI.TextEntry", frame ) -- create the form as a child of frame
	frame.Straftat:Dock( TOP )
    frame.Straftat:DockMargin(10,5, 10, 10)
    frame.Straftat:SetSize(25, 35)


    frame.Text4 = vgui.Create("DLabel", frame)
	frame.Text4:Dock(TOP)
	frame.Text4:DockMargin(10,5, 0, 0)
	frame.Text4:SetFont("XeninUI.Frame.Title")
    frame.Text4:SetText("Haftzeit :")
	frame.Text4:SetTextColor(color_white)

    frame.Haftzeit  = vgui.Create( "XeninUI.TextEntry", frame ) -- create the form as a child of frame
	frame.Haftzeit:Dock( TOP )
    frame.Haftzeit:DockMargin(10,5, 250, 10)
    frame.Haftzeit:SetSize(25, 35)


    local Button = vgui.Create("XeninUI.Category",frame)
    Button:SetName("Absenden")
    Button:Dock(TOP)
    Button:DockMargin( 10, 15, 10,  0)
    Button.Expand = function(pln,state)
        Alleexxii.Akten.Send(frame.ply,frame.Meister:GetText(),frame.Straftat:GetText(),frame.Haftzeit:GetText())
        frame:Remove()
        if not state then return end
    end
    frame:SetSize(frame:GetWide(), frame:GetTall() + Button:GetTall() * 2.5)
    frame:SetPos(frame:GetX(), frame:GetY() - Button:GetTall() * 2.5)
end

Alleexxii.Akten.Send = function(Ent,Meister,Strafttat,haftzeit)
    net.Start("Alleexxii_Akten_Send")
        net.WriteEntity(Ent)
        net.WriteString(Meister)
        net.WriteString(Strafttat)
        net.WriteString(haftzeit)
    net.SendToServer()
end

Alleexxii.Akten.OpenRequest = function()
    net.Start("Alleexxii_Akten_Request")
    net.SendToServer()
end

net.Receive("Alleexxii_Akten_Request", function(len, ply)
    local bytes = net.ReadUInt(16);
    local Akten = net.ReadData(bytes);
    if Akten ~= nil then
        Alleexxii.Akten.DrawList(util.JSONToTable(util.Decompress(Akten)))
    end
    return
end)

net.Receive("Alleexxii_Akten_Send", function(len, ply)
    Alleexxii.Akten.OpenSendMenu()
end)
