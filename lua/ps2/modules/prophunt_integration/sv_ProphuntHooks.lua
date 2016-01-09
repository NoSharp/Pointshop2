local S = function( id )
	return Pointshop2.GetSetting( "Prop Hunt Integration", id )
end

local teamPlayers
local function PreRoundStart( num )
	teamPlayers = {}

	for k, v in pairs( player.GetAll( ) ) do
		teamPlayers[v:Team()] = teamPlayers[v:Team()] or {}
		table.insert( teamPlayers[v:Team()],  v )
	end

	if #player.GetAll( ) > S('RoundWin.MinimumPlayers') then
		GAMEMODE.Jackpot = #player.GetAll( ) * S('RoundWin.TimeJackpotPerPlayer')
		for k, v in pairs( player.GetAll( ) ) do
			if v:Team() == TEAM_HUNTERS then
				v:PS2_DisplayInformation( "Round started. Points pot is at " .. GAMEMODE.Jackpot .. " points. It decreases by " .. math.floor( GAMEMODE.Jackpot / ( ROUND_TIME / 60 ) ) .. " points every minute, kill the Props quickly for maximum reward!" )
			end
		end
		GAMEMODE.PS2_NoPoints = false
	else
		GAMEMODE.PS2_NoPoints = true
		Pointshop2.BroadcastInfo( "No points will be given this round. Minimum of " .. S('RoundWin.MinimumPlayers') .. " players required" )
	end
	print("round started")
	PrintTable(teamPlayers)
end


local function SetRoundResult( result, resulttext )
	if GAMEMODE.PS2_NoPoints then
		return
	end

	if result == 1001 then
		return
	end

	Pointshop2.StandardPointsBatch:begin( )
	if result == TEAM_PROPS then
		for k, v in pairs( teamPlayers[TEAM_PROPS] ) do
			if not IsValid( v ) then
				return
			end

			if v:Alive() and v:Team( ) == TEAM_PROPS then
				v:PS2_AddStandardPoints( S('RoundWin.AliveBonus'), 'Alive Bonus', true )
			end
			v:PS2_AddStandardPoints( S('RoundWin.PropsWin'), 'Winning the round' )
		end
	end

	if result == TEAM_HUNTERS then
		local aliveHuntersCount = 0
		for k, v in pairs( teamPlayers[TEAM_HUNTERS] ) do
			if IsValid( v ) and v:Alive() and v:Team() == TEAM_HUNTERS then
				aliveHuntersCount = aliveHuntersCount + 1
			end
		end
		for k, v in pairs( teamPlayers[TEAM_HUNTERS] ) do
			if not IsValid( v ) then
				return
			end

			if v:Alive() and v:Team( ) == TEAM_HUNTERS then
				v:PS2_AddStandardPoints( S('RoundWin.AliveBonus'), 'Alive Bonus', true )
			end
			local timeElapsed = GetGlobalFloat( "RoundEndTime" ) - CurTime()
			timeElapsed = timeElapsed > 0 and timeElapsed or ROUND_TIME
			local pot = GAMEMODE.Jackpot * ( 1 - timeElapsed / ROUND_TIME )
			v:PS2_AddStandardPoints( math.floor( pot / aliveHuntersCount ), 'Winning the round', true )
		end
	end
	Pointshop2.StandardPointsBatch:finish( )

	hook.Call( "Pointshop2GmIntegration_RoundEnded" )
end

hook.Add( "PH_PropKilled", "PH_PropKilled", function( victim, inflictor, attacker )
	if attacker:IsPlayer( ) and not GAMEMODE.PS2_NoPoints then
		attacker:PS2_AddStandardPoints( S("Kills.HunterKillsProp"), "Killed Prop" )
	end
end )

local function installHooks( )
	GAMEMODE.OriginalSetRoundResult = GAMEMODE.OriginalSetRoundResult or GAMEMODE.SetRoundResult -- need to use this as fretta resets timer before OnRoundResult
	GAMEMODE.OriginalPreRoundStart = GAMEMODE.OriginalPreRoundStart or GAMEMODE.PreRoundStart

	function GAMEMODE:SetRoundResult( result, resulttext )
		SetRoundResult( result, resulttext )
		GAMEMODE.OriginalSetRoundResult( self, result, resulttext )
	end

	function GAMEMODE:PreRoundStart( num )
		GAMEMODE.OriginalPreRoundStart( self, num )
		PreRoundStart( num )
	end
end
hook.Add( "InitPostEntity", "PS2_InstallPropHuntHooks", installHooks )
hook.Add( "OnReloaded", "PS2_ReloadPropHuntHooks", installHooks )