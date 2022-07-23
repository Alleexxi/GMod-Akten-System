if CLIENT then return end

Alleexxii = Alleexxii or {}
Alleexxii.Akten = Alleexxii.Akten or {}

util.AddNetworkString("Alleexxii_Akten_Request")
util.AddNetworkString("Alleexxii_Akten_Send")

--sql.Query( "CREATE TABLE IF NOT EXISTS Akten_data_jedi ( SteamID TEXT,JobId INTEGER, Name TEXT, Rang TEXT, Meister TEXT, Straftat TEXT, Datum TEXT, Haftzeit TEXT )" )
--sql.Query( "CREATE TABLE IF NOT EXISTS Akten_data_sith ( SteamID TEXT,JobId INTEGER, Name TEXT, Rang TEXT, Meister TEXT, Straftat TEXT, Datum TEXT, Haftzeit TEXT )" )

if not file.IsDir("akten", "DATA") then
    file.CreateDir("akten")
end

hook.Add("DarkRPFinishedLoading", "darkrp_finished_loading_funk_addon", function()
    Alleexxii.Akten.JediOrSith = {
        [TEAM_JEDI] = "Akten_data_jedi" .. os.date('%Y') .. "-" .. (os.date('%m')-1+1), -- Man muss nicht verstehen was ich hier mache.
        
        [TEAM_SITH] = "Akten_data_sith" .. os.date('%Y') .. "-" .. (os.date('%m')-1+1), -- Monatliche Akten man kann auch %W anstatt %b das es wochentlich ist
    }

    for i,v in pairs(Alleexxii.Akten.JediOrSith) do
        if not file.Exists("akten/"..v..".txt", "DATA") then
            file.Write("akten/"..v..".txt",util.TableToJSON({}))
        end
    end

    if file.Exists("akten/".."Akten_data_jedi" .. os.date('%Y') .. "-" .. (os.date('%m')-1) .. ".txt", "DATA") then
        file.Delete("akten/".."Akten_data_jedi" .. os.date('%Y') .. "-" .. (os.date('%m')-1) .. ".txt", "DATA")
    end

    if file.Exists("akten/".."Akten_data_sith" .. os.date('%Y') .. "-" .. (os.date('%m')-1)  .. ".txt", "DATA") then
        file.Delete("akten/".."Akten_data_sith" .. os.date('%Y') .. "-" .. (os.date('%m')-1)  .. ".txt")
    end
end)

function GetJediOrSith(ply)
    return Alleexxii.Akten.JediOrSith[ply:getJobTable().team]
end

function SendAkten(ply,target)
    local JediOrSith = GetJediOrSith(ply)
    if not JediOrSith then return end

    if target then
        local normaltable = util.JSONToTable(file.Read("akten/"..JediOrSith..".txt"));
        local targettable = {};
        for i,v in pairs(normaltable) do
            if v.SteamID == target then
                targettable[#targettable + 1] = v
            end
        end

        local compress = util.Compress(util.TableToJSON(targettable))
        local compressbytes = #compress
        net.Start("Alleexxii_Akten_Request")
            net.WriteUInt(compressbytes,16)
            net.WriteData(compress,compressbytes)
        net.Send(ply)
        return
    end

    local compress = util.Compress(file.Read("akten/"..JediOrSith..".txt"))
    local compressbytes = #compress
    net.Start("Alleexxii_Akten_Request")
        net.WriteUInt(compressbytes,16)
        net.WriteData(compress,compressbytes)
    net.Send(ply)
end

function Akten_Send(ply)
    net.Start("Alleexxii_Akten_Send")
    net.Send(ply)
end

net.Receive("Alleexxii_Akten_Send",function(len,ply)
    local Player,Meister,Straftat,Minuten = net.ReadEntity(),net.ReadString(),net.ReadString(),net.ReadString()
    if not IsValid(Player) then return end
    if not Player:IsPlayer() then return end
    if not Meister or not Straftat or not tonumber(Minuten) then return end
    local JediOrSith = GetJediOrSith(ply)
    if not JediOrSith then return end
    if ply.AktenCooldown > CurTime() then 
        DarkRP.notify(ply,NOTIFY_ERROR,10,"Warte einen moment!") 
        return 
    end
    ply.AktenCooldown = CurTime() + 10

    local Table = {
        ["SteamID"] = Player:SteamID(),
        ["JobId"] = Player:getJobTable().team,
        ["Name"] = Player:getDarkRPVar("rpname"),
        ["Rang"] = Player:GetJobRankName(),
        ["Meister"] = Meister,
        ["Straftat"] = Straftat,
        ["Datum"] = os.date('%Y-%m-%d %H:%M:%S'),
        ["Haftzeit"] = Minuten,
    }
    
    local Data = util.JSONToTable(file.Read("akten/"..JediOrSith..".txt"))
    Data[#Data+1] = Table
    file.Write("akten/"..JediOrSith..".txt",util.TableToJSON(Data))
end)

hook.Add( "PlayerSay", "Akten_Commands", function( ply, text )
    if ( string.lower( text ) == "!akten" ) then
		SendAkten(ply)
		return ""
	end
	if ( string.lower( text ) == "!akte" ) then
		Akten_Send(ply)
		return ""
	end
    if ( string.StartWith( string.lower( text ), "!akten " ) ) then
		SendAkten(ply,string.sub( text, 8 ))
		return ""
	end
end )
