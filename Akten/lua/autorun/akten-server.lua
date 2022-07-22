if CLIENT then return end

Alleexxii = Alleexxii or {}
Alleexxii.Akten = Alleexxii.Akten or {}

util.AddNetworkString("Alleexxii_Akten_Request")
util.AddNetworkString("Alleexxii_Akten_Send")

sql.Query( "CREATE TABLE IF NOT EXISTS Akten_data_jedi ( SteamID TEXT,JobId INTEGER, Name TEXT, Rang TEXT, Meister TEXT, Straftat TEXT, Datum TEXT, Haftzeit TEXT )" )
sql.Query( "CREATE TABLE IF NOT EXISTS Akten_data_sith ( SteamID TEXT,JobId INTEGER, Name TEXT, Rang TEXT, Meister TEXT, Straftat TEXT, Datum TEXT, Haftzeit TEXT )" )



Alleexxii.Akten.JediOrSith = {
    -- Musst halt hier noch die Team IDs angeben usw.
    -- [Team] = {NameDesMySqlTables, DürfenSieEsBenutzen}

    [TEAM_JEDI] = {"Akten_data_jedi",false},
    
    [TEAM_SITH] = {"Akten_data_sith",false},
}

function GetJediOrSith(ply)
    return Alleexxii.Akten.JediOrSith[ply:getJobTable().team]
end

function SendAkten(ply,target)
    print(target)
    local JediOrSith = GetJediOrSith(ply)
    if not JediOrSith then return end
    if not JediOrSith[2] then return end
    local Akten
    if not target then Akten = sql.Query("SELECT * FROM " .. JediOrSith[1]) else Akten = sql.Query( "SELECT * FROM "..JediOrSith[1].." WHERE SteamID = ".. sql.SQLStr(target) ) end

    net.Start("Alleexxii_Akten_Request")
        net.WriteTable(Akten or {})
    net.Send(ply)
end

function Akten_Send(ply)
    net.Start("Alleexxii_Akten_Send")
    net.Send(ply)
end

net.Receive("Alleexxii_Akten_Send",function(len,ply)
    local Ent,Meister,Straftat,Minuten = net.ReadEntity(),net.ReadString(),net.ReadString(),net.ReadString()
    if not IsValid(Ent) then return end
    if not Ent:IsPlayer() then return end
    if not Meister or not Straftat or not tonumber(Minuten) then return end
    local JediOrSith = GetJediOrSith(ply)
    if not JediOrSith then return end
    if not JediOrSith[2] then return end
    sql.Query( string.format("INSERT INTO " .. JediOrSith[1] .. " ( SteamID,JobId,Name,Rang,Meister,Straftat,Datum,Haftzeit ) VALUES( %s,%d,%s,%s,%s,%s,%s,%s )",sql.SQLStr(Ent:SteamID()),Ent:getJobTable().team,sql.SQLStr(Ent:getDarkRPVar("rpname")),sql.SQLStr(Ent:GetJobRankName() or "-"),sql.SQLStr(Meister),sql.SQLStr(Straftat),sql.SQLStr(os.date('%Y-%m-%d %H:%M:%S')),sql.SQLStr(Minuten)) )
end)


concommand.Add("DropJediAkten",function()
    sql.Query("DROP TABLE Akten_data_jedi")
    sql.Query( "CREATE TABLE IF NOT EXISTS Akten_data_jedi ( SteamID TEXT,JobId INTEGER, Name TEXT, Rang TEXT, Meister TEXT, Straftat TEXT, Datum TEXT, Haftzeit TEXT )" )
end)

concommand.Add("DropSithAkten",function()
    sql.Query("DROP TABLE Akten_data_sith")
    sql.Query( "CREATE TABLE IF NOT EXISTS Akten_data_sith ( SteamID TEXT,JobId INTEGER, Name TEXT, Rang TEXT, Meister TEXT, Straftat TEXT, Datum TEXT, Haftzeit TEXT )" )
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
