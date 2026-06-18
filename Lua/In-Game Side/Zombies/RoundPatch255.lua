--[[
		.\hksc.exe ".\Lua\Social.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\Social.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

-- Utils
CoD.adjustedRoundGlobal = 0
CoD.lastRound = 0
CoD.roundOffset = 0

---------------------------

CoD.ResetRoundPatch = function()
	CoD.adjustedRoundGlobal = 0
	CoD.lastRound = 0
	CoD.roundOffset = 0
end

CoD.ApplyRoundPatches = function()
	if Engine[@"getdvarint"](@"shield_diff_rounds") == 1 and not IsDemoPlaying() then

		CoD.EnhPrintInfo("Running Diff Logic for Rounds...")

		function IsZombieRoundOnesDigitEqualTo( f227_arg0, f227_arg1, f227_arg2 )
			--CoD.EnhPrintInfo("IsZombiesRound Called...")
			local f227_local0 = f227_arg0:getModel()
			if f227_local0 then
				f227_local0 = Engine[@"getmodel"]( f227_local0, "roundsPlayed" )
			end
			local f227_local1 = f227_local0 and CoD.adjustedRoundGlobal
			if f227_local1 == nil then
				return false
			else
				--CoD.EnhPrintInfo("Returned Ones -> " .. CoD.adjustedRoundGlobal, tostring((f227_local1 - 1) % 10 == f227_arg2))
				return (f227_local1 - 1) % 10 == f227_arg2
			end
		end
		
		function IsZombieRoundTensDigitEqualTo( f228_arg0, f228_arg1, f228_arg2 )
			--CoD.EnhPrintInfo("IsZombiesRound Called...")
			local f228_local0 = f228_arg0:getModel()
			if f228_local0 then
				f228_local0 = Engine[@"getmodel"]( f228_local0, "roundsPlayed" )
			end
			local f228_local1 = f228_local0 and CoD.adjustedRoundGlobal
			if f228_local1 == nil then
				return false
			else
				f228_local1 = f228_local1 - 1
				--CoD.EnhPrintInfo("Returned Tens -> " .. CoD.adjustedRoundGlobal, tostring((f228_local1 % 100 - f228_local1 % 10) / 10 == f228_arg2))
				return (f228_local1 % 100 - f228_local1 % 10) / 10 == f228_arg2
			end
		end
		
		function IsZombieRoundHundredsDigitEqualTo( f229_arg0, f229_arg1, f229_arg2 )
			--CoD.EnhPrintInfo("IsZombiesRound Called...")
			local f229_local0 = f229_arg0:getModel()
			if f229_local0 then
				f229_local0 = Engine[@"getmodel"]( f229_local0, "roundsPlayed" )
			end
			local f229_local1 = f229_local0 and CoD.adjustedRoundGlobal
			if f229_local1 == nil then
				return false
			else
				f229_local1 = f229_local1 - 1
				--CoD.EnhPrintInfo("Returned Hundreds -> " .. CoD.adjustedRoundGlobal, tostring((f229_local1 % 1000 - f229_local1 % 100) / 100 == f229_arg2))
				return (f229_local1 % 1000 - f229_local1 % 100) / 100 == f229_arg2
			end
		end

		CoD.ZmRnd = InheritFrom( LUI.UIElement )
		CoD.ZmRnd.__defaultWidth = 336
		CoD.ZmRnd.__defaultHeight = 300
		CoD.ZmRnd.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
			local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
			self:setClass( CoD.ZmRnd )
			self.id = "ZmRnd"
			self.soundSet = "HUD"
			self.anyChildUsesUpdateState = true
			f1_arg0:addElementToPendingUpdateStateList( self )
			
			local Panel = CoD.ZmPanel_RndExt.new( f1_arg0, f1_arg1, 0, 0, 0, 336, 0, 0, 0, 300 )
			Panel:setRGB( 0.61, 0.61, 0.61 )
			Panel:setAlpha( 0 )
			self:addElement( Panel )
			self.Panel = Panel
			
			local RndDigits = CoD.ZmRndDigits.new( f1_arg0, f1_arg1, 0, 0, 46, 205, 0, 0, 126, 246 )
			RndDigits:linkToElementModel( self, nil, false, function ( model )
				RndDigits:setModel( model, f1_arg1 )
			end )
			self:addElement( RndDigits )
			self.RndDigits = RndDigits
			
			local Mrk1Def = LUI.UIImage.new( 0, 0, 60, 108, 0, 0, 126, 258 )
			Mrk1Def:setImage( RegisterImage( @"uie_t7_zm_hud_rnd_mrk1def" ) )
			self:addElement( Mrk1Def )
			self.Mrk1Def = Mrk1Def
			
			local Mrk2Def = LUI.UIImage.new( 0, 0, 98, 134, 0, 0, 112, 244 )
			Mrk2Def:setImage( RegisterImage( @"uie_t7_zm_hud_rnd_mrk2def" ) )
			self:addElement( Mrk2Def )
			self.Mrk2Def = Mrk2Def
			
			local Mrk3Def = LUI.UIImage.new( 0, 0, 128, 164, 0, 0, 120, 252 )
			Mrk3Def:setImage( RegisterImage( @"uie_t7_zm_hud_rnd_mrk3def" ) )
			self:addElement( Mrk3Def )
			self.Mrk3Def = Mrk3Def
			
			local Mrk4Def = LUI.UIImage.new( 0, 0, 158, 194, 0, 0, 120, 228 )
			Mrk4Def:setAlpha( 0 )
			Mrk4Def:setImage( RegisterImage( @"uie_t7_zm_hud_rnd_mrk4def" ) )
			self:addElement( Mrk4Def )
			self.Mrk4Def = Mrk4Def
			
			local Mrk5Def = LUI.UIImage.new( 0, 0, 60, 204, 0, 0, 132, 240 )
			Mrk5Def:setAlpha( 0 )
			Mrk5Def:setImage( RegisterImage( @"uie_t7_zm_hud_rnd_mrk5def" ) )
			self:addElement( Mrk5Def )
			self.Mrk5Def = Mrk5Def
			
			local Mrk1Act = LUI.UIImage.new( 0, 0, 60, 108, 0, 0, 126, 258 )
			Mrk1Act:setAlpha( 0 )
			Mrk1Act:setImage( RegisterImage( @"uie_t7_zm_hud_rnd_mrk1act" ) )
			Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
			Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
			Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
			Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
			Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
			Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
			self:addElement( Mrk1Act )
			self.Mrk1Act = Mrk1Act
			
			local Mrk2Act = LUI.UIImage.new( 0, 0, 98, 134, 0, 0, 112, 244 )
			Mrk2Act:setAlpha( 0 )
			Mrk2Act:setImage( RegisterImage( @"uie_t7_zm_hud_rnd_mrk2act" ) )
			Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
			Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
			Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
			Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
			Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
			Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
			self:addElement( Mrk2Act )
			self.Mrk2Act = Mrk2Act
			
			local Mrk3Act = LUI.UIImage.new( 0, 0, 128, 164, 0, 0, 120, 252 )
			Mrk3Act:setAlpha( 0 )
			Mrk3Act:setImage( RegisterImage( @"uie_t7_zm_hud_rnd_mrk3act" ) )
			Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
			Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
			Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
			Mrk3Act:setShaderVector( 2, 1.15, 0, 0, 0 )
			Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
			Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
			self:addElement( Mrk3Act )
			self.Mrk3Act = Mrk3Act
			
			local Mrk4Act = LUI.UIImage.new( 0, 0, 158, 194, 0, 0, 120, 228 )
			Mrk4Act:setAlpha( 0 )
			Mrk4Act:setImage( RegisterImage( @"uie_t7_zm_hud_rnd_mrk4act" ) )
			Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
			Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
			Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
			Mrk4Act:setShaderVector( 2, 1, 0, 0, 0 )
			Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
			Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
			self:addElement( Mrk4Act )
			self.Mrk4Act = Mrk4Act
			
			local Mrk5Act = LUI.UIImage.new( 0, 0, 60, 204, 0, 0, 132, 240 )
			Mrk5Act:setAlpha( 0 )
			Mrk5Act:setImage( RegisterImage( @"uie_t7_zm_hud_rnd_mrk5act" ) )
			Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
			Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
			Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
			Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
			Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
			Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
			self:addElement( Mrk5Act )
			self.Mrk5Act = Mrk5Act
			
			local GlowOrangeOver = LUI.UIImage.new( 0, 0, 64, 228, 0, 0, 157, 207 )
			GlowOrangeOver:setRGB( 1, 0.31, 0 )
			GlowOrangeOver:setAlpha( 0 )
			GlowOrangeOver:setZRot( -84 )
			GlowOrangeOver:setImage( RegisterImage( @"uie_t7_core_hud_mapwidget_panelglow" ) )
			GlowOrangeOver:setMaterial( LUI.UIImage.GetCachedMaterial( @"ui_add" ) )
			self:addElement( GlowOrangeOver )
			self.GlowOrangeOver = GlowOrangeOver
			
			local ZmFxSpark2Ext0 = CoD.ZmFx_Spark2Ext.new( f1_arg0, f1_arg1, 0, 0, 81, 249, 0, 0, 18, 270 )
			ZmFxSpark2Ext0:setAlpha( 0 )
			ZmFxSpark2Ext0:setZRot( 9 )
			self:addElement( ZmFxSpark2Ext0 )
			self.ZmFxSpark2Ext0 = ZmFxSpark2Ext0
			
			local ZmFxSpark20 = CoD.ZmFx_Spark2.new( f1_arg0, f1_arg1, 0, 0, 48, 243, 0, 0, -50, 274 )
			ZmFxSpark20:setAlpha( 0 )
			ZmFxSpark20:setRFTMaterial( LUI.UIImage.GetCachedMaterial( @"ui_add" ) )
			ZmFxSpark20.Image0:setShaderVector( 1, 0, 1.37, 0, 0 )
			ZmFxSpark20.Image00:setShaderVector( 1, 0, -0.62, 0, 0 )
			self:addElement( ZmFxSpark20 )
			self.ZmFxSpark20 = ZmFxSpark20
			
			self:mergeStateConditions( {
				{
					stateName = "Rnd1",
					condition = function ( menu, element, event )
						local TryRound = 2
						local BooleanTry
						
						if CoD.adjustedRoundGlobal == nil or TryRound ~= CoD.adjustedRoundGlobal then
							return AlwaysFalse()
						else
							return AlwaysTrue()
						end
					end
				},
				{
					stateName = "Rnd2",
					condition = function ( menu, element, event )
						local TryRound = 3
						local BooleanTry
						
						if CoD.adjustedRoundGlobal == nil or TryRound ~= CoD.adjustedRoundGlobal then
							return AlwaysFalse()
						else
							return AlwaysTrue()
						end
					end
				},
				{
					stateName = "Rnd3",
					condition = function ( menu, element, event )
						local TryRound = 4
						local BooleanTry
						
						if CoD.adjustedRoundGlobal == nil or TryRound ~= CoD.adjustedRoundGlobal then
							return AlwaysFalse()
						else
							return AlwaysTrue()
						end
					end
				},
				{
					stateName = "Rnd4",
					condition = function ( menu, element, event )
						local TryRound = 5
						local BooleanTry
						
						if CoD.adjustedRoundGlobal == nil or TryRound ~= CoD.adjustedRoundGlobal then
							return AlwaysFalse()
						else
							return AlwaysTrue()
						end
					end
				},
				{
					stateName = "Rnd5",
					condition = function ( menu, element, event )
						local TryRound = 6
						local BooleanTry
						
						if CoD.adjustedRoundGlobal == nil or TryRound ~= CoD.adjustedRoundGlobal then
							return AlwaysFalse()
						else
							return AlwaysTrue()
						end
					end
				},
				{
					stateName = "Digits",
					condition = function ( menu, element, event )
						local TryRound = 7
						local BooleanTry
						
						if CoD.adjustedRoundGlobal == nil or TryRound > CoD.adjustedRoundGlobal then
							return AlwaysFalse()
						else
							return AlwaysTrue()
						end
					end
				}
			} )
			self:linkToElementModel( self, "roundsPlayed", true, function ( model )
				f1_arg0:updateElementState( self, {
					name = "model_validation",
					menu = f1_arg0,
					controller = f1_arg1,
					modelValue = model:get(),
					modelName = "roundsPlayed"
				} )
			end )
			LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
			
			if PostLoadFunc then
				PostLoadFunc( self, f1_arg1, f1_arg0 )
			end
			
			return self
		end
		
		CoD.ZmRnd.__resetProperties = function ( f10_arg0 )
			f10_arg0.RndDigits:completeAnimation()
			f10_arg0.Mrk1Def:completeAnimation()
			f10_arg0.Mrk2Def:completeAnimation()
			f10_arg0.Mrk3Def:completeAnimation()
			f10_arg0.Mrk1Act:completeAnimation()
			f10_arg0.Mrk2Act:completeAnimation()
			f10_arg0.Mrk3Act:completeAnimation()
			f10_arg0.Mrk4Act:completeAnimation()
			f10_arg0.Mrk5Act:completeAnimation()
			f10_arg0.GlowOrangeOver:completeAnimation()
			f10_arg0.ZmFxSpark2Ext0:completeAnimation()
			f10_arg0.Mrk4Def:completeAnimation()
			f10_arg0.Mrk5Def:completeAnimation()
			f10_arg0.RndDigits:setAlpha( 1 )
			f10_arg0.Mrk1Def:setAlpha( 1 )
			f10_arg0.Mrk2Def:setAlpha( 1 )
			f10_arg0.Mrk3Def:setAlpha( 1 )
			f10_arg0.Mrk1Act:setAlpha( 0 )
			f10_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
			f10_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
			f10_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
			f10_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
			f10_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
			f10_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
			f10_arg0.Mrk2Act:setAlpha( 0 )
			f10_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
			f10_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
			f10_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
			f10_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
			f10_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
			f10_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
			f10_arg0.Mrk3Act:setAlpha( 0 )
			f10_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
			f10_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
			f10_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
			f10_arg0.Mrk3Act:setShaderVector( 2, 1.15, 0, 0, 0 )
			f10_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
			f10_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
			f10_arg0.Mrk4Act:setAlpha( 0 )
			f10_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
			f10_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
			f10_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
			f10_arg0.Mrk4Act:setShaderVector( 2, 1, 0, 0, 0 )
			f10_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
			f10_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
			f10_arg0.Mrk5Act:setAlpha( 0 )
			f10_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
			f10_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
			f10_arg0.Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
			f10_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
			f10_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
			f10_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
			f10_arg0.GlowOrangeOver:setLeftRight( 0, 0, 64, 228 )
			f10_arg0.GlowOrangeOver:setTopBottom( 0, 0, 157, 207 )
			f10_arg0.GlowOrangeOver:setAlpha( 0 )
			f10_arg0.GlowOrangeOver:setZRot( -84 )
			f10_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 81, 249 )
			f10_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, 18, 270 )
			f10_arg0.ZmFxSpark2Ext0:setAlpha( 0 )
			f10_arg0.Mrk4Def:setAlpha( 0 )
			f10_arg0.Mrk5Def:setAlpha( 0 )
		end
		
		CoD.ZmRnd.__clipsPerState = {
			DefaultState = {
				DefaultClip = function ( f11_arg0, f11_arg1 )
					f11_arg0:__resetProperties()
					f11_arg0:setupElementClipCounter( 11 )
					f11_arg0.RndDigits:completeAnimation()
					f11_arg0.RndDigits:setAlpha( 0 )
					f11_arg0.clipFinished( f11_arg0.RndDigits )
					f11_arg0.Mrk1Def:completeAnimation()
					f11_arg0.Mrk1Def:setAlpha( 0 )
					f11_arg0.clipFinished( f11_arg0.Mrk1Def )
					f11_arg0.Mrk2Def:completeAnimation()
					f11_arg0.Mrk2Def:setAlpha( 0 )
					f11_arg0.clipFinished( f11_arg0.Mrk2Def )
					f11_arg0.Mrk3Def:completeAnimation()
					f11_arg0.Mrk3Def:setAlpha( 0 )
					f11_arg0.clipFinished( f11_arg0.Mrk3Def )
					f11_arg0.Mrk1Act:completeAnimation()
					f11_arg0.Mrk1Act:setAlpha( 1 )
					f11_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f11_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f11_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f11_arg0.Mrk1Act:setShaderVector( 2, 0, 0, 0, 0 )
					f11_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f11_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f11_arg0.clipFinished( f11_arg0.Mrk1Act )
					f11_arg0.Mrk2Act:completeAnimation()
					f11_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f11_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f11_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f11_arg0.Mrk2Act:setShaderVector( 2, 0, 0, 0, 0 )
					f11_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f11_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f11_arg0.clipFinished( f11_arg0.Mrk2Act )
					f11_arg0.Mrk3Act:completeAnimation()
					f11_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f11_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f11_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f11_arg0.Mrk3Act:setShaderVector( 2, 0, 0, 0, 0 )
					f11_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f11_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f11_arg0.clipFinished( f11_arg0.Mrk3Act )
					f11_arg0.Mrk4Act:completeAnimation()
					f11_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f11_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f11_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f11_arg0.Mrk4Act:setShaderVector( 2, 0, 0, 0, 0 )
					f11_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f11_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f11_arg0.clipFinished( f11_arg0.Mrk4Act )
					f11_arg0.Mrk5Act:completeAnimation()
					f11_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f11_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f11_arg0.Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
					f11_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f11_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f11_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f11_arg0.clipFinished( f11_arg0.Mrk5Act )
					f11_arg0.GlowOrangeOver:completeAnimation()
					f11_arg0.GlowOrangeOver:setLeftRight( 0, 0, 2, 166 )
					f11_arg0.GlowOrangeOver:setTopBottom( 0, 0, 161, 211 )
					f11_arg0.GlowOrangeOver:setZRot( -79 )
					f11_arg0.clipFinished( f11_arg0.GlowOrangeOver )
					f11_arg0.ZmFxSpark2Ext0:completeAnimation()
					f11_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 8, 176 )
					f11_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -60, 192 )
					f11_arg0.clipFinished( f11_arg0.ZmFxSpark2Ext0 )
				end,
				Rnd1 = function ( f12_arg0, f12_arg1 )
					f12_arg0:__resetProperties()
					f12_arg0:setupElementClipCounter( 11 )
					f12_arg0.RndDigits:completeAnimation()
					f12_arg0.RndDigits:setAlpha( 0 )
					f12_arg0.clipFinished( f12_arg0.RndDigits )
					local f12_local0 = function ( f13_arg0 )
						local f13_local0 = function ( f14_arg0 )
							f14_arg0:beginAnimation( 789 )
							f14_arg0:setAlpha( 1 )
							f14_arg0:registerEventHandler( "transition_complete_keyframe", f12_arg0.clipFinished )
						end
						
						f12_arg0.Mrk1Def:beginAnimation( 1320 )
						f12_arg0.Mrk1Def:registerEventHandler( "interrupted_keyframe", f12_arg0.clipInterrupted )
						f12_arg0.Mrk1Def:registerEventHandler( "transition_complete_keyframe", f13_local0 )
					end
					
					f12_arg0.Mrk1Def:completeAnimation()
					f12_arg0.Mrk1Def:setAlpha( 0 )
					f12_local0( f12_arg0.Mrk1Def )
					f12_arg0.Mrk2Def:completeAnimation()
					f12_arg0.Mrk2Def:setAlpha( 0 )
					f12_arg0.clipFinished( f12_arg0.Mrk2Def )
					f12_arg0.Mrk3Def:completeAnimation()
					f12_arg0.Mrk3Def:setAlpha( 0 )
					f12_arg0.clipFinished( f12_arg0.Mrk3Def )
					local f12_local1 = function ( f15_arg0 )
						local f15_local0 = function ( f16_arg0 )
							local f16_local0 = function ( f17_arg0 )
								f17_arg0:beginAnimation( 1010 )
								f17_arg0:setAlpha( 0 )
								f17_arg0:registerEventHandler( "transition_complete_keyframe", f12_arg0.clipFinished )
							end
							
							f16_arg0:beginAnimation( 1209 )
							f16_arg0:registerEventHandler( "transition_complete_keyframe", f16_local0 )
						end
						
						f12_arg0.Mrk1Act:beginAnimation( 900, Enum[@"luitween"][@"luitween_ease_out"] )
						f12_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
						f12_arg0.Mrk1Act:registerEventHandler( "interrupted_keyframe", f12_arg0.clipInterrupted )
						f12_arg0.Mrk1Act:registerEventHandler( "transition_complete_keyframe", f15_local0 )
					end
					
					f12_arg0.Mrk1Act:completeAnimation()
					f12_arg0.Mrk1Act:setAlpha( 1 )
					f12_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f12_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f12_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f12_arg0.Mrk1Act:setShaderVector( 2, 0, 0, 0, 0 )
					f12_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f12_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f12_local1( f12_arg0.Mrk1Act )
					f12_arg0.Mrk2Act:completeAnimation()
					f12_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f12_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f12_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f12_arg0.Mrk2Act:setShaderVector( 2, 0, 0, 0, 0 )
					f12_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f12_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f12_arg0.clipFinished( f12_arg0.Mrk2Act )
					f12_arg0.Mrk3Act:completeAnimation()
					f12_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f12_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f12_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f12_arg0.Mrk3Act:setShaderVector( 2, 0, 0, 0, 0 )
					f12_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f12_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f12_arg0.clipFinished( f12_arg0.Mrk3Act )
					f12_arg0.Mrk4Act:completeAnimation()
					f12_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f12_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f12_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f12_arg0.Mrk4Act:setShaderVector( 2, 0, 0, 0, 0 )
					f12_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f12_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f12_arg0.clipFinished( f12_arg0.Mrk4Act )
					f12_arg0.Mrk5Act:completeAnimation()
					f12_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f12_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f12_arg0.Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
					f12_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f12_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f12_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f12_arg0.clipFinished( f12_arg0.Mrk5Act )
					local f12_local2 = function ( f18_arg0 )
						local f18_local0 = function ( f19_arg0 )
							local f19_local0 = function ( f20_arg0 )
								f20_arg0:beginAnimation( 1020 )
								f20_arg0:setAlpha( 0 )
								f20_arg0:registerEventHandler( "transition_complete_keyframe", f12_arg0.clipFinished )
							end
							
							f19_arg0:beginAnimation( 2230 )
							f19_arg0:registerEventHandler( "transition_complete_keyframe", f19_local0 )
						end
						
						f12_arg0.GlowOrangeOver:beginAnimation( 890, Enum[@"luitween"][@"luitween_bounce"] )
						f12_arg0.GlowOrangeOver:setAlpha( 1 )
						f12_arg0.GlowOrangeOver:registerEventHandler( "interrupted_keyframe", f12_arg0.clipInterrupted )
						f12_arg0.GlowOrangeOver:registerEventHandler( "transition_complete_keyframe", f18_local0 )
					end
					
					f12_arg0.GlowOrangeOver:completeAnimation()
					f12_arg0.GlowOrangeOver:setLeftRight( 0, 0, 2, 166 )
					f12_arg0.GlowOrangeOver:setTopBottom( 0, 0, 161, 211 )
					f12_arg0.GlowOrangeOver:setAlpha( 0 )
					f12_arg0.GlowOrangeOver:setZRot( -79 )
					f12_local2( f12_arg0.GlowOrangeOver )
					local f12_local3 = function ( f21_arg0 )
						local f21_local0 = function ( f22_arg0 )
							f22_arg0:beginAnimation( 199 )
							f22_arg0:setAlpha( 0 )
							f22_arg0:registerEventHandler( "transition_complete_keyframe", f12_arg0.clipFinished )
						end
						
						f12_arg0.ZmFxSpark2Ext0:beginAnimation( 680 )
						f12_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 26, 194 )
						f12_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, 28, 280 )
						f12_arg0.ZmFxSpark2Ext0:setAlpha( 1 )
						f12_arg0.ZmFxSpark2Ext0:registerEventHandler( "interrupted_keyframe", f12_arg0.clipInterrupted )
						f12_arg0.ZmFxSpark2Ext0:registerEventHandler( "transition_complete_keyframe", f21_local0 )
					end
					
					f12_arg0.ZmFxSpark2Ext0:completeAnimation()
					f12_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 8, 176 )
					f12_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -60, 192 )
					f12_arg0.ZmFxSpark2Ext0:setAlpha( 0 )
					f12_local3( f12_arg0.ZmFxSpark2Ext0 )
				end
			},
			Rnd1 = {
				DefaultClip = function ( f23_arg0, f23_arg1 )
					f23_arg0:__resetProperties()
					f23_arg0:setupElementClipCounter( 10 )
					f23_arg0.RndDigits:completeAnimation()
					f23_arg0.RndDigits:setAlpha( 0 )
					f23_arg0.clipFinished( f23_arg0.RndDigits )
					f23_arg0.Mrk2Def:completeAnimation()
					f23_arg0.Mrk2Def:setAlpha( 0 )
					f23_arg0.clipFinished( f23_arg0.Mrk2Def )
					f23_arg0.Mrk3Def:completeAnimation()
					f23_arg0.Mrk3Def:setAlpha( 0 )
					f23_arg0.clipFinished( f23_arg0.Mrk3Def )
					f23_arg0.Mrk1Act:completeAnimation()
					f23_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f23_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f23_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f23_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f23_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f23_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f23_arg0.clipFinished( f23_arg0.Mrk1Act )
					f23_arg0.Mrk2Act:completeAnimation()
					f23_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f23_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f23_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f23_arg0.Mrk2Act:setShaderVector( 2, 0, 0, 0, 0 )
					f23_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f23_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f23_arg0.clipFinished( f23_arg0.Mrk2Act )
					f23_arg0.Mrk3Act:completeAnimation()
					f23_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f23_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f23_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f23_arg0.Mrk3Act:setShaderVector( 2, 0, 0, 0, 0 )
					f23_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f23_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f23_arg0.clipFinished( f23_arg0.Mrk3Act )
					f23_arg0.Mrk4Act:completeAnimation()
					f23_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f23_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f23_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f23_arg0.Mrk4Act:setShaderVector( 2, 0, 0, 0, 0 )
					f23_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f23_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f23_arg0.clipFinished( f23_arg0.Mrk4Act )
					f23_arg0.Mrk5Act:completeAnimation()
					f23_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f23_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f23_arg0.Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
					f23_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f23_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f23_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f23_arg0.clipFinished( f23_arg0.Mrk5Act )
					f23_arg0.GlowOrangeOver:completeAnimation()
					f23_arg0.GlowOrangeOver:setLeftRight( 0, 0, 2, 166 )
					f23_arg0.GlowOrangeOver:setTopBottom( 0, 0, 161, 211 )
					f23_arg0.GlowOrangeOver:setZRot( -79 )
					f23_arg0.clipFinished( f23_arg0.GlowOrangeOver )
					f23_arg0.ZmFxSpark2Ext0:completeAnimation()
					f23_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 26, 194 )
					f23_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, 28, 280 )
					f23_arg0.clipFinished( f23_arg0.ZmFxSpark2Ext0 )
				end,
				Rnd2 = function ( f24_arg0, f24_arg1 )
					f24_arg0:__resetProperties()
					f24_arg0:setupElementClipCounter( 10 )
					f24_arg0.RndDigits:completeAnimation()
					f24_arg0.RndDigits:setAlpha( 0 )
					f24_arg0.clipFinished( f24_arg0.RndDigits )
					local f24_local0 = function ( f25_arg0 )
						local f25_local0 = function ( f26_arg0 )
							f26_arg0:beginAnimation( 869 )
							f26_arg0:setAlpha( 1 )
							f26_arg0:registerEventHandler( "transition_complete_keyframe", f24_arg0.clipFinished )
						end
						
						f24_arg0.Mrk2Def:beginAnimation( 1240 )
						f24_arg0.Mrk2Def:registerEventHandler( "interrupted_keyframe", f24_arg0.clipInterrupted )
						f24_arg0.Mrk2Def:registerEventHandler( "transition_complete_keyframe", f25_local0 )
					end
					
					f24_arg0.Mrk2Def:completeAnimation()
					f24_arg0.Mrk2Def:setAlpha( 0 )
					f24_local0( f24_arg0.Mrk2Def )
					f24_arg0.Mrk3Def:completeAnimation()
					f24_arg0.Mrk3Def:setAlpha( 0 )
					f24_arg0.clipFinished( f24_arg0.Mrk3Def )
					f24_arg0.Mrk1Act:completeAnimation()
					f24_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f24_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f24_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f24_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f24_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f24_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f24_arg0.clipFinished( f24_arg0.Mrk1Act )
					local f24_local1 = function ( f27_arg0 )
						local f27_local0 = function ( f28_arg0 )
							local f28_local0 = function ( f29_arg0 )
								f29_arg0:beginAnimation( 1010 )
								f29_arg0:setAlpha( 0 )
								f29_arg0:registerEventHandler( "transition_complete_keyframe", f24_arg0.clipFinished )
							end
							
							f28_arg0:beginAnimation( 1429 )
							f28_arg0:registerEventHandler( "transition_complete_keyframe", f28_local0 )
						end
						
						f24_arg0.Mrk2Act:beginAnimation( 680, Enum[@"luitween"][@"luitween_ease_out"] )
						f24_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
						f24_arg0.Mrk2Act:registerEventHandler( "interrupted_keyframe", f24_arg0.clipInterrupted )
						f24_arg0.Mrk2Act:registerEventHandler( "transition_complete_keyframe", f27_local0 )
					end
					
					f24_arg0.Mrk2Act:completeAnimation()
					f24_arg0.Mrk2Act:setAlpha( 1 )
					f24_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f24_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f24_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f24_arg0.Mrk2Act:setShaderVector( 2, 0, 0, 0, 0 )
					f24_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f24_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f24_local1( f24_arg0.Mrk2Act )
					f24_arg0.Mrk3Act:completeAnimation()
					f24_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f24_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f24_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f24_arg0.Mrk3Act:setShaderVector( 2, 0, 0, 0, 0 )
					f24_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f24_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f24_arg0.clipFinished( f24_arg0.Mrk3Act )
					f24_arg0.Mrk4Act:completeAnimation()
					f24_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f24_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f24_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f24_arg0.Mrk4Act:setShaderVector( 2, 0, 0, 0, 0 )
					f24_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f24_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f24_arg0.clipFinished( f24_arg0.Mrk4Act )
					f24_arg0.Mrk5Act:completeAnimation()
					f24_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f24_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f24_arg0.Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
					f24_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f24_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f24_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f24_arg0.clipFinished( f24_arg0.Mrk5Act )
					local f24_local2 = function ( f30_arg0 )
						local f30_local0 = function ( f31_arg0 )
							local f31_local0 = function ( f32_arg0 )
								f32_arg0:beginAnimation( 1020 )
								f32_arg0:setAlpha( 0 )
								f32_arg0:registerEventHandler( "transition_complete_keyframe", f24_arg0.clipFinished )
							end
							
							f31_arg0:beginAnimation( 2230 )
							f31_arg0:registerEventHandler( "transition_complete_keyframe", f31_local0 )
						end
						
						f24_arg0.GlowOrangeOver:beginAnimation( 890, Enum[@"luitween"][@"luitween_bounce"] )
						f24_arg0.GlowOrangeOver:setAlpha( 1 )
						f24_arg0.GlowOrangeOver:registerEventHandler( "interrupted_keyframe", f24_arg0.clipInterrupted )
						f24_arg0.GlowOrangeOver:registerEventHandler( "transition_complete_keyframe", f30_local0 )
					end
					
					f24_arg0.GlowOrangeOver:completeAnimation()
					f24_arg0.GlowOrangeOver:setLeftRight( 0, 0, 34.5, 197.5 )
					f24_arg0.GlowOrangeOver:setTopBottom( 0, 0, 149, 199 )
					f24_arg0.GlowOrangeOver:setAlpha( 0 )
					f24_arg0.GlowOrangeOver:setZRot( -82 )
					f24_local2( f24_arg0.GlowOrangeOver )
					local f24_local3 = function ( f33_arg0 )
						local f33_local0 = function ( f34_arg0 )
							local f34_local0 = function ( f35_arg0 )
								f35_arg0:beginAnimation( 199 )
								f35_arg0:setAlpha( 0 )
								f35_arg0:registerEventHandler( "transition_complete_keyframe", f24_arg0.clipFinished )
							end
							
							f34_arg0:beginAnimation( 620, Enum[@"luitween"][@"luitween_ease_out"] )
							f34_arg0:setLeftRight( 0, 0, 57, 225 )
							f34_arg0:setTopBottom( 0, 0, 18, 270 )
							f34_arg0:setAlpha( 1 )
							f34_arg0:registerEventHandler( "transition_complete_keyframe", f34_local0 )
						end
						
						f24_arg0.ZmFxSpark2Ext0:beginAnimation( 60 )
						f24_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 45.15, 213.15 )
						f24_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -66.79, 185.21 )
						f24_arg0.ZmFxSpark2Ext0:setAlpha( 0.45 )
						f24_arg0.ZmFxSpark2Ext0:registerEventHandler( "interrupted_keyframe", f24_arg0.clipInterrupted )
						f24_arg0.ZmFxSpark2Ext0:registerEventHandler( "transition_complete_keyframe", f33_local0 )
					end
					
					f24_arg0.ZmFxSpark2Ext0:completeAnimation()
					f24_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 44, 212 )
					f24_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -75, 177 )
					f24_arg0.ZmFxSpark2Ext0:setAlpha( 0 )
					f24_local3( f24_arg0.ZmFxSpark2Ext0 )
				end
			},
			Rnd2 = {
				DefaultClip = function ( f36_arg0, f36_arg1 )
					f36_arg0:__resetProperties()
					f36_arg0:setupElementClipCounter( 9 )
					f36_arg0.RndDigits:completeAnimation()
					f36_arg0.RndDigits:setAlpha( 0 )
					f36_arg0.clipFinished( f36_arg0.RndDigits )
					f36_arg0.Mrk3Def:completeAnimation()
					f36_arg0.Mrk3Def:setAlpha( 0 )
					f36_arg0.clipFinished( f36_arg0.Mrk3Def )
					f36_arg0.Mrk1Act:completeAnimation()
					f36_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f36_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f36_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f36_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f36_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f36_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f36_arg0.clipFinished( f36_arg0.Mrk1Act )
					f36_arg0.Mrk2Act:completeAnimation()
					f36_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f36_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f36_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f36_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
					f36_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f36_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f36_arg0.clipFinished( f36_arg0.Mrk2Act )
					f36_arg0.Mrk3Act:completeAnimation()
					f36_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f36_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f36_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f36_arg0.Mrk3Act:setShaderVector( 2, 0, 0, 0, 0 )
					f36_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f36_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f36_arg0.clipFinished( f36_arg0.Mrk3Act )
					f36_arg0.Mrk4Act:completeAnimation()
					f36_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f36_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f36_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f36_arg0.Mrk4Act:setShaderVector( 2, 0, 0, 0, 0 )
					f36_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f36_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f36_arg0.clipFinished( f36_arg0.Mrk4Act )
					f36_arg0.Mrk5Act:completeAnimation()
					f36_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f36_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f36_arg0.Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
					f36_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f36_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f36_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f36_arg0.clipFinished( f36_arg0.Mrk5Act )
					f36_arg0.GlowOrangeOver:completeAnimation()
					f36_arg0.GlowOrangeOver:setLeftRight( 0, 0, 34.5, 197.5 )
					f36_arg0.GlowOrangeOver:setTopBottom( 0, 0, 149, 199 )
					f36_arg0.GlowOrangeOver:setZRot( -82 )
					f36_arg0.clipFinished( f36_arg0.GlowOrangeOver )
					f36_arg0.ZmFxSpark2Ext0:completeAnimation()
					f36_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 57, 225 )
					f36_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, 18, 270 )
					f36_arg0.clipFinished( f36_arg0.ZmFxSpark2Ext0 )
				end,
				Rnd3 = function ( f37_arg0, f37_arg1 )
					f37_arg0:__resetProperties()
					f37_arg0:setupElementClipCounter( 9 )
					f37_arg0.RndDigits:completeAnimation()
					f37_arg0.RndDigits:setAlpha( 0 )
					f37_arg0.clipFinished( f37_arg0.RndDigits )
					local f37_local0 = function ( f38_arg0 )
						local f38_local0 = function ( f39_arg0 )
							f39_arg0:beginAnimation( 869 )
							f39_arg0:setAlpha( 1 )
							f39_arg0:registerEventHandler( "transition_complete_keyframe", f37_arg0.clipFinished )
						end
						
						f37_arg0.Mrk3Def:beginAnimation( 1240 )
						f37_arg0.Mrk3Def:registerEventHandler( "interrupted_keyframe", f37_arg0.clipInterrupted )
						f37_arg0.Mrk3Def:registerEventHandler( "transition_complete_keyframe", f38_local0 )
					end
					
					f37_arg0.Mrk3Def:completeAnimation()
					f37_arg0.Mrk3Def:setAlpha( 0 )
					f37_local0( f37_arg0.Mrk3Def )
					f37_arg0.Mrk1Act:completeAnimation()
					f37_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f37_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f37_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f37_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f37_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f37_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f37_arg0.clipFinished( f37_arg0.Mrk1Act )
					f37_arg0.Mrk2Act:completeAnimation()
					f37_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f37_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f37_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f37_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
					f37_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f37_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f37_arg0.clipFinished( f37_arg0.Mrk2Act )
					local f37_local1 = function ( f40_arg0 )
						local f40_local0 = function ( f41_arg0 )
							local f41_local0 = function ( f42_arg0 )
								f42_arg0:beginAnimation( 1000 )
								f42_arg0:setAlpha( 0 )
								f42_arg0:registerEventHandler( "transition_complete_keyframe", f37_arg0.clipFinished )
							end
							
							f41_arg0:beginAnimation( 1439 )
							f41_arg0:registerEventHandler( "transition_complete_keyframe", f41_local0 )
						end
						
						f37_arg0.Mrk3Act:beginAnimation( 680, Enum[@"luitween"][@"luitween_ease_out"] )
						f37_arg0.Mrk3Act:setShaderVector( 2, 1.15, 0, 0, 0 )
						f37_arg0.Mrk3Act:registerEventHandler( "interrupted_keyframe", f37_arg0.clipInterrupted )
						f37_arg0.Mrk3Act:registerEventHandler( "transition_complete_keyframe", f40_local0 )
					end
					
					f37_arg0.Mrk3Act:completeAnimation()
					f37_arg0.Mrk3Act:setAlpha( 1 )
					f37_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f37_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f37_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f37_arg0.Mrk3Act:setShaderVector( 2, 0, 0, 0, 0 )
					f37_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f37_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f37_local1( f37_arg0.Mrk3Act )
					f37_arg0.Mrk4Act:completeAnimation()
					f37_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f37_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f37_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f37_arg0.Mrk4Act:setShaderVector( 2, 0, 0, 0, 0 )
					f37_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f37_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f37_arg0.clipFinished( f37_arg0.Mrk4Act )
					f37_arg0.Mrk5Act:completeAnimation()
					f37_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f37_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f37_arg0.Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
					f37_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f37_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f37_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f37_arg0.clipFinished( f37_arg0.Mrk5Act )
					local f37_local2 = function ( f43_arg0 )
						local f43_local0 = function ( f44_arg0 )
							local f44_local0 = function ( f45_arg0 )
								f45_arg0:beginAnimation( 1020 )
								f45_arg0:setAlpha( 0 )
								f45_arg0:registerEventHandler( "transition_complete_keyframe", f37_arg0.clipFinished )
							end
							
							f44_arg0:beginAnimation( 2230 )
							f44_arg0:registerEventHandler( "transition_complete_keyframe", f44_local0 )
						end
						
						f37_arg0.GlowOrangeOver:beginAnimation( 890, Enum[@"luitween"][@"luitween_bounce"] )
						f37_arg0.GlowOrangeOver:setAlpha( 1 )
						f37_arg0.GlowOrangeOver:registerEventHandler( "interrupted_keyframe", f37_arg0.clipInterrupted )
						f37_arg0.GlowOrangeOver:registerEventHandler( "transition_complete_keyframe", f43_local0 )
					end
					
					f37_arg0.GlowOrangeOver:completeAnimation()
					f37_arg0.GlowOrangeOver:setLeftRight( 0, 0, 64.5, 227.5 )
					f37_arg0.GlowOrangeOver:setTopBottom( 0, 0, 157, 207 )
					f37_arg0.GlowOrangeOver:setAlpha( 0 )
					f37_local2( f37_arg0.GlowOrangeOver )
					local f37_local3 = function ( f46_arg0 )
						local f46_local0 = function ( f47_arg0 )
							local f47_local0 = function ( f48_arg0 )
								f48_arg0:beginAnimation( 199 )
								f48_arg0:setAlpha( 0 )
								f48_arg0:registerEventHandler( "transition_complete_keyframe", f37_arg0.clipFinished )
							end
							
							f47_arg0:beginAnimation( 620, Enum[@"luitween"][@"luitween_ease_out"] )
							f47_arg0:setLeftRight( 0, 0, 81, 249 )
							f47_arg0:setTopBottom( 0, 0, 18, 270 )
							f47_arg0:setAlpha( 1 )
							f47_arg0:registerEventHandler( "transition_complete_keyframe", f47_local0 )
						end
						
						f37_arg0.ZmFxSpark2Ext0:beginAnimation( 60 )
						f37_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 74.62, 242.62 )
						f37_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -65.88, 186.12 )
						f37_arg0.ZmFxSpark2Ext0:setAlpha( 0.45 )
						f37_arg0.ZmFxSpark2Ext0:registerEventHandler( "interrupted_keyframe", f37_arg0.clipInterrupted )
						f37_arg0.ZmFxSpark2Ext0:registerEventHandler( "transition_complete_keyframe", f46_local0 )
					end
					
					f37_arg0.ZmFxSpark2Ext0:completeAnimation()
					f37_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 74, 242 )
					f37_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -74, 178 )
					f37_arg0.ZmFxSpark2Ext0:setAlpha( 0 )
					f37_local3( f37_arg0.ZmFxSpark2Ext0 )
				end
			},
			Rnd3 = {
				DefaultClip = function ( f49_arg0, f49_arg1 )
					f49_arg0:__resetProperties()
					f49_arg0:setupElementClipCounter( 7 )
					f49_arg0.RndDigits:completeAnimation()
					f49_arg0.RndDigits:setAlpha( 0 )
					f49_arg0.clipFinished( f49_arg0.RndDigits )
					f49_arg0.Mrk1Act:completeAnimation()
					f49_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f49_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f49_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f49_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f49_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f49_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f49_arg0.clipFinished( f49_arg0.Mrk1Act )
					f49_arg0.Mrk2Act:completeAnimation()
					f49_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f49_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f49_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f49_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
					f49_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f49_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f49_arg0.clipFinished( f49_arg0.Mrk2Act )
					f49_arg0.Mrk3Act:completeAnimation()
					f49_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f49_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f49_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f49_arg0.Mrk3Act:setShaderVector( 2, 1.15, 0, 0, 0 )
					f49_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f49_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f49_arg0.clipFinished( f49_arg0.Mrk3Act )
					f49_arg0.Mrk4Act:completeAnimation()
					f49_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f49_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f49_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f49_arg0.Mrk4Act:setShaderVector( 2, 0, 0, 0, 0 )
					f49_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f49_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f49_arg0.clipFinished( f49_arg0.Mrk4Act )
					f49_arg0.Mrk5Act:completeAnimation()
					f49_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f49_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f49_arg0.Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
					f49_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f49_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f49_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f49_arg0.clipFinished( f49_arg0.Mrk5Act )
					f49_arg0.GlowOrangeOver:completeAnimation()
					f49_arg0.GlowOrangeOver:setLeftRight( 0, 0, 64.5, 227.5 )
					f49_arg0.GlowOrangeOver:setTopBottom( 0, 0, 157, 207 )
					f49_arg0.clipFinished( f49_arg0.GlowOrangeOver )
				end,
				Rnd4 = function ( f50_arg0, f50_arg1 )
					f50_arg0:__resetProperties()
					f50_arg0:setupElementClipCounter( 9 )
					f50_arg0.RndDigits:completeAnimation()
					f50_arg0.RndDigits:setAlpha( 0 )
					f50_arg0.clipFinished( f50_arg0.RndDigits )
					local f50_local0 = function ( f51_arg0 )
						local f51_local0 = function ( f52_arg0 )
							f52_arg0:beginAnimation( 869 )
							f52_arg0:setAlpha( 1 )
							f52_arg0:registerEventHandler( "transition_complete_keyframe", f50_arg0.clipFinished )
						end
						
						f50_arg0.Mrk4Def:beginAnimation( 1240 )
						f50_arg0.Mrk4Def:registerEventHandler( "interrupted_keyframe", f50_arg0.clipInterrupted )
						f50_arg0.Mrk4Def:registerEventHandler( "transition_complete_keyframe", f51_local0 )
					end
					
					f50_arg0.Mrk4Def:completeAnimation()
					f50_arg0.Mrk4Def:setAlpha( 0 )
					f50_local0( f50_arg0.Mrk4Def )
					f50_arg0.Mrk1Act:completeAnimation()
					f50_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f50_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f50_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f50_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f50_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f50_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f50_arg0.clipFinished( f50_arg0.Mrk1Act )
					f50_arg0.Mrk2Act:completeAnimation()
					f50_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f50_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f50_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f50_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
					f50_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f50_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f50_arg0.clipFinished( f50_arg0.Mrk2Act )
					f50_arg0.Mrk3Act:completeAnimation()
					f50_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f50_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f50_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f50_arg0.Mrk3Act:setShaderVector( 2, 1.15, 0, 0, 0 )
					f50_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f50_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f50_arg0.clipFinished( f50_arg0.Mrk3Act )
					local f50_local1 = function ( f53_arg0 )
						local f53_local0 = function ( f54_arg0 )
							local f54_local0 = function ( f55_arg0 )
								f55_arg0:beginAnimation( 1000 )
								f55_arg0:setAlpha( 0 )
								f55_arg0:registerEventHandler( "transition_complete_keyframe", f50_arg0.clipFinished )
							end
							
							f54_arg0:beginAnimation( 1439 )
							f54_arg0:registerEventHandler( "transition_complete_keyframe", f54_local0 )
						end
						
						f50_arg0.Mrk4Act:beginAnimation( 680 )
						f50_arg0.Mrk4Act:setShaderVector( 2, 1.12, 0, 0, 0 )
						f50_arg0.Mrk4Act:registerEventHandler( "interrupted_keyframe", f50_arg0.clipInterrupted )
						f50_arg0.Mrk4Act:registerEventHandler( "transition_complete_keyframe", f53_local0 )
					end
					
					f50_arg0.Mrk4Act:completeAnimation()
					f50_arg0.Mrk4Act:setAlpha( 1 )
					f50_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f50_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f50_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f50_arg0.Mrk4Act:setShaderVector( 2, 0, 0, 0, 0 )
					f50_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f50_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f50_local1( f50_arg0.Mrk4Act )
					f50_arg0.Mrk5Act:completeAnimation()
					f50_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f50_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f50_arg0.Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
					f50_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f50_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f50_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f50_arg0.clipFinished( f50_arg0.Mrk5Act )
					local f50_local2 = function ( f56_arg0 )
						local f56_local0 = function ( f57_arg0 )
							local f57_local0 = function ( f58_arg0 )
								f58_arg0:beginAnimation( 1020 )
								f58_arg0:setAlpha( 0 )
								f58_arg0:registerEventHandler( "transition_complete_keyframe", f50_arg0.clipFinished )
							end
							
							f57_arg0:beginAnimation( 2230 )
							f57_arg0:registerEventHandler( "transition_complete_keyframe", f57_local0 )
						end
						
						f50_arg0.GlowOrangeOver:beginAnimation( 890, Enum[@"luitween"][@"luitween_bounce"] )
						f50_arg0.GlowOrangeOver:setAlpha( 1 )
						f50_arg0.GlowOrangeOver:registerEventHandler( "interrupted_keyframe", f50_arg0.clipInterrupted )
						f50_arg0.GlowOrangeOver:registerEventHandler( "transition_complete_keyframe", f56_local0 )
					end
					
					f50_arg0.GlowOrangeOver:completeAnimation()
					f50_arg0.GlowOrangeOver:setLeftRight( 0, 0, 114, 240 )
					f50_arg0.GlowOrangeOver:setTopBottom( 0, 0, 142, 192 )
					f50_arg0.GlowOrangeOver:setAlpha( 0 )
					f50_arg0.GlowOrangeOver:setZRot( -93 )
					f50_local2( f50_arg0.GlowOrangeOver )
					local f50_local3 = function ( f59_arg0 )
						local f59_local0 = function ( f60_arg0 )
							local f60_local0 = function ( f61_arg0 )
								f61_arg0:beginAnimation( 199 )
								f61_arg0:setAlpha( 0 )
								f61_arg0:registerEventHandler( "transition_complete_keyframe", f50_arg0.clipFinished )
							end
							
							f60_arg0:beginAnimation( 620, Enum[@"luitween"][@"luitween_ease_out"] )
							f60_arg0:setLeftRight( 0, 0, 107, 275 )
							f60_arg0:setTopBottom( 0, 0, -6, 246 )
							f60_arg0:setAlpha( 1 )
							f60_arg0:registerEventHandler( "transition_complete_keyframe", f60_local0 )
						end
						
						f50_arg0.ZmFxSpark2Ext0:beginAnimation( 60 )
						f50_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 110.65, 278.65 )
						f50_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -68, 184 )
						f50_arg0.ZmFxSpark2Ext0:setAlpha( 0.45 )
						f50_arg0.ZmFxSpark2Ext0:registerEventHandler( "interrupted_keyframe", f50_arg0.clipInterrupted )
						f50_arg0.ZmFxSpark2Ext0:registerEventHandler( "transition_complete_keyframe", f59_local0 )
					end
					
					f50_arg0.ZmFxSpark2Ext0:completeAnimation()
					f50_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 111, 279 )
					f50_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -74, 178 )
					f50_arg0.ZmFxSpark2Ext0:setAlpha( 0 )
					f50_local3( f50_arg0.ZmFxSpark2Ext0 )
				end
			},
			Rnd4 = {
				DefaultClip = function ( f62_arg0, f62_arg1 )
					f62_arg0:__resetProperties()
					f62_arg0:setupElementClipCounter( 9 )
					f62_arg0.RndDigits:completeAnimation()
					f62_arg0.RndDigits:setAlpha( 0 )
					f62_arg0.clipFinished( f62_arg0.RndDigits )
					f62_arg0.Mrk4Def:completeAnimation()
					f62_arg0.Mrk4Def:setAlpha( 1 )
					f62_arg0.clipFinished( f62_arg0.Mrk4Def )
					f62_arg0.Mrk1Act:completeAnimation()
					f62_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f62_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f62_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f62_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f62_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f62_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f62_arg0.clipFinished( f62_arg0.Mrk1Act )
					f62_arg0.Mrk2Act:completeAnimation()
					f62_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f62_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f62_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f62_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
					f62_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f62_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f62_arg0.clipFinished( f62_arg0.Mrk2Act )
					f62_arg0.Mrk3Act:completeAnimation()
					f62_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f62_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f62_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f62_arg0.Mrk3Act:setShaderVector( 2, 1.15, 0, 0, 0 )
					f62_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f62_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f62_arg0.clipFinished( f62_arg0.Mrk3Act )
					f62_arg0.Mrk4Act:completeAnimation()
					f62_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f62_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f62_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f62_arg0.Mrk4Act:setShaderVector( 2, 0, 0, 0, 0 )
					f62_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f62_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f62_arg0.clipFinished( f62_arg0.Mrk4Act )
					f62_arg0.Mrk5Act:completeAnimation()
					f62_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f62_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f62_arg0.Mrk5Act:setShaderVector( 1, 0.35, 0, 0, 0 )
					f62_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f62_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f62_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f62_arg0.clipFinished( f62_arg0.Mrk5Act )
					f62_arg0.GlowOrangeOver:completeAnimation()
					f62_arg0.GlowOrangeOver:setLeftRight( 0, 0, 114, 240 )
					f62_arg0.GlowOrangeOver:setTopBottom( 0, 0, 142, 192 )
					f62_arg0.GlowOrangeOver:setZRot( -93 )
					f62_arg0.clipFinished( f62_arg0.GlowOrangeOver )
					f62_arg0.ZmFxSpark2Ext0:completeAnimation()
					f62_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 107, 275 )
					f62_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -6, 246 )
					f62_arg0.clipFinished( f62_arg0.ZmFxSpark2Ext0 )
				end,
				Rnd5 = function ( f63_arg0, f63_arg1 )
					f63_arg0:__resetProperties()
					f63_arg0:setupElementClipCounter( 10 )
					f63_arg0.RndDigits:completeAnimation()
					f63_arg0.RndDigits:setAlpha( 0 )
					f63_arg0.clipFinished( f63_arg0.RndDigits )
					f63_arg0.Mrk4Def:completeAnimation()
					f63_arg0.Mrk4Def:setAlpha( 1 )
					f63_arg0.clipFinished( f63_arg0.Mrk4Def )
					local f63_local0 = function ( f64_arg0 )
						local f64_local0 = function ( f65_arg0 )
							f65_arg0:beginAnimation( 869 )
							f65_arg0:setAlpha( 1 )
							f65_arg0:registerEventHandler( "transition_complete_keyframe", f63_arg0.clipFinished )
						end
						
						f63_arg0.Mrk5Def:beginAnimation( 1240 )
						f63_arg0.Mrk5Def:registerEventHandler( "interrupted_keyframe", f63_arg0.clipInterrupted )
						f63_arg0.Mrk5Def:registerEventHandler( "transition_complete_keyframe", f64_local0 )
					end
					
					f63_arg0.Mrk5Def:completeAnimation()
					f63_arg0.Mrk5Def:setAlpha( 0 )
					f63_local0( f63_arg0.Mrk5Def )
					f63_arg0.Mrk1Act:completeAnimation()
					f63_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f63_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f63_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f63_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f63_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f63_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f63_arg0.clipFinished( f63_arg0.Mrk1Act )
					f63_arg0.Mrk2Act:completeAnimation()
					f63_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f63_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f63_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f63_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
					f63_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f63_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f63_arg0.clipFinished( f63_arg0.Mrk2Act )
					f63_arg0.Mrk3Act:completeAnimation()
					f63_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f63_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f63_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f63_arg0.Mrk3Act:setShaderVector( 2, 1.15, 0, 0, 0 )
					f63_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f63_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f63_arg0.clipFinished( f63_arg0.Mrk3Act )
					f63_arg0.Mrk4Act:completeAnimation()
					f63_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f63_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f63_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f63_arg0.Mrk4Act:setShaderVector( 2, 1.12, 0, 0, 0 )
					f63_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f63_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f63_arg0.clipFinished( f63_arg0.Mrk4Act )
					local f63_local1 = function ( f66_arg0 )
						local f66_local0 = function ( f67_arg0 )
							local f67_local0 = function ( f68_arg0 )
								f68_arg0:beginAnimation( 1000 )
								f68_arg0:setAlpha( 0 )
								f68_arg0:registerEventHandler( "transition_complete_keyframe", f63_arg0.clipFinished )
							end
							
							f67_arg0:beginAnimation( 1439 )
							f67_arg0:registerEventHandler( "transition_complete_keyframe", f67_local0 )
						end
						
						f63_arg0.Mrk5Act:beginAnimation( 680 )
						f63_arg0.Mrk5Act:setShaderVector( 0, 1.15, 0, 0, 0 )
						f63_arg0.Mrk5Act:setShaderVector( 1, 0.22, 0, 0, 0 )
						f63_arg0.Mrk5Act:registerEventHandler( "interrupted_keyframe", f63_arg0.clipInterrupted )
						f63_arg0.Mrk5Act:registerEventHandler( "transition_complete_keyframe", f66_local0 )
					end
					
					f63_arg0.Mrk5Act:completeAnimation()
					f63_arg0.Mrk5Act:setAlpha( 1 )
					f63_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f63_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f63_arg0.Mrk5Act:setShaderVector( 1, 0.11, 0, 0, 0 )
					f63_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f63_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f63_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f63_local1( f63_arg0.Mrk5Act )
					local f63_local2 = function ( f69_arg0 )
						local f69_local0 = function ( f70_arg0 )
							local f70_local0 = function ( f71_arg0 )
								f71_arg0:beginAnimation( 1020 )
								f71_arg0:setAlpha( 0 )
								f71_arg0:registerEventHandler( "transition_complete_keyframe", f63_arg0.clipFinished )
							end
							
							f70_arg0:beginAnimation( 2230 )
							f70_arg0:registerEventHandler( "transition_complete_keyframe", f70_local0 )
						end
						
						f63_arg0.GlowOrangeOver:beginAnimation( 890, Enum[@"luitween"][@"luitween_bounce"] )
						f63_arg0.GlowOrangeOver:setAlpha( 1 )
						f63_arg0.GlowOrangeOver:registerEventHandler( "interrupted_keyframe", f63_arg0.clipInterrupted )
						f63_arg0.GlowOrangeOver:registerEventHandler( "transition_complete_keyframe", f69_local0 )
					end
					
					f63_arg0.GlowOrangeOver:completeAnimation()
					f63_arg0.GlowOrangeOver:setLeftRight( 0, 0, 30.5, 237.5 )
					f63_arg0.GlowOrangeOver:setTopBottom( 0, 0, 161, 211 )
					f63_arg0.GlowOrangeOver:setAlpha( 0 )
					f63_arg0.GlowOrangeOver:setZRot( -214 )
					f63_local2( f63_arg0.GlowOrangeOver )
					local f63_local3 = function ( f72_arg0 )
						local f72_local0 = function ( f73_arg0 )
							local f73_local0 = function ( f74_arg0 )
								f74_arg0:beginAnimation( 199 )
								f74_arg0:setAlpha( 0 )
								f74_arg0:registerEventHandler( "transition_complete_keyframe", f63_arg0.clipFinished )
							end
							
							f73_arg0:beginAnimation( 620, Enum[@"luitween"][@"luitween_ease_out"] )
							f73_arg0:setLeftRight( 0, 0, 128, 296 )
							f73_arg0:setTopBottom( 0, 0, 12, 264 )
							f73_arg0:registerEventHandler( "transition_complete_keyframe", f73_local0 )
						end
						
						f63_arg0.ZmFxSpark2Ext0:beginAnimation( 60 )
						f63_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, -1.47, 166.53 )
						f63_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -61.85, 190.15 )
						f63_arg0.ZmFxSpark2Ext0:setAlpha( 1 )
						f63_arg0.ZmFxSpark2Ext0:registerEventHandler( "interrupted_keyframe", f63_arg0.clipInterrupted )
						f63_arg0.ZmFxSpark2Ext0:registerEventHandler( "transition_complete_keyframe", f72_local0 )
					end
					
					f63_arg0.ZmFxSpark2Ext0:completeAnimation()
					f63_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, -14, 154 )
					f63_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, -69, 183 )
					f63_arg0.ZmFxSpark2Ext0:setAlpha( 0 )
					f63_local3( f63_arg0.ZmFxSpark2Ext0 )
				end
			},
			Rnd5 = {
				DefaultClip = function ( f75_arg0, f75_arg1 )
					f75_arg0:__resetProperties()
					f75_arg0:setupElementClipCounter( 10 )
					f75_arg0.RndDigits:completeAnimation()
					f75_arg0.RndDigits:setAlpha( 0 )
					f75_arg0.clipFinished( f75_arg0.RndDigits )
					f75_arg0.Mrk4Def:completeAnimation()
					f75_arg0.Mrk4Def:setAlpha( 1 )
					f75_arg0.clipFinished( f75_arg0.Mrk4Def )
					f75_arg0.Mrk5Def:completeAnimation()
					f75_arg0.Mrk5Def:setAlpha( 1 )
					f75_arg0.clipFinished( f75_arg0.Mrk5Def )
					f75_arg0.Mrk1Act:completeAnimation()
					f75_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f75_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f75_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f75_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f75_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f75_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f75_arg0.clipFinished( f75_arg0.Mrk1Act )
					f75_arg0.Mrk2Act:completeAnimation()
					f75_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f75_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f75_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f75_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
					f75_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f75_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f75_arg0.clipFinished( f75_arg0.Mrk2Act )
					f75_arg0.Mrk3Act:completeAnimation()
					f75_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f75_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f75_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f75_arg0.Mrk3Act:setShaderVector( 2, 1.15, 0, 0, 0 )
					f75_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f75_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f75_arg0.clipFinished( f75_arg0.Mrk3Act )
					f75_arg0.Mrk4Act:completeAnimation()
					f75_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f75_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f75_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f75_arg0.Mrk4Act:setShaderVector( 2, 1.12, 0, 0, 0 )
					f75_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f75_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f75_arg0.clipFinished( f75_arg0.Mrk4Act )
					f75_arg0.Mrk5Act:completeAnimation()
					f75_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f75_arg0.Mrk5Act:setShaderVector( 0, -0.13, 0, 0, 0 )
					f75_arg0.Mrk5Act:setShaderVector( 1, 0.11, 0, 0, 0 )
					f75_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f75_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f75_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f75_arg0.clipFinished( f75_arg0.Mrk5Act )
					f75_arg0.GlowOrangeOver:completeAnimation()
					f75_arg0.GlowOrangeOver:setLeftRight( 0, 0, 30.5, 237.5 )
					f75_arg0.GlowOrangeOver:setTopBottom( 0, 0, 161, 211 )
					f75_arg0.GlowOrangeOver:setZRot( -214 )
					f75_arg0.clipFinished( f75_arg0.GlowOrangeOver )
					f75_arg0.ZmFxSpark2Ext0:completeAnimation()
					f75_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 128, 296 )
					f75_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, 12, 264 )
					f75_arg0.clipFinished( f75_arg0.ZmFxSpark2Ext0 )
				end,
				Digits = function ( f76_arg0, f76_arg1 )
					f76_arg0:__resetProperties()
					f76_arg0:setupElementClipCounter( 13 )
					local f76_local0 = function ( f77_arg0 )
						local f77_local0 = function ( f78_arg0 )
							f78_arg0:beginAnimation( 390 )
							f78_arg0:setAlpha( 1 )
							f78_arg0:registerEventHandler( "transition_complete_keyframe", f76_arg0.clipFinished )
						end
						
						f76_arg0.RndDigits:beginAnimation( 310 )
						f76_arg0.RndDigits:registerEventHandler( "interrupted_keyframe", f76_arg0.clipInterrupted )
						f76_arg0.RndDigits:registerEventHandler( "transition_complete_keyframe", f77_local0 )
					end
					
					f76_arg0.RndDigits:completeAnimation()
					f76_arg0.RndDigits:setAlpha( 0 )
					f76_local0( f76_arg0.RndDigits )
					local f76_local1 = function ( f79_arg0 )
						f76_arg0.Mrk1Def:beginAnimation( 210 )
						f76_arg0.Mrk1Def:setAlpha( 0 )
						f76_arg0.Mrk1Def:registerEventHandler( "interrupted_keyframe", f76_arg0.clipInterrupted )
						f76_arg0.Mrk1Def:registerEventHandler( "transition_complete_keyframe", f76_arg0.clipFinished )
					end
					
					f76_arg0.Mrk1Def:completeAnimation()
					f76_arg0.Mrk1Def:setAlpha( 1 )
					f76_local1( f76_arg0.Mrk1Def )
					local f76_local2 = function ( f80_arg0 )
						local f80_local0 = function ( f81_arg0 )
							f81_arg0:beginAnimation( 160 )
							f81_arg0:setAlpha( 0 )
							f81_arg0:registerEventHandler( "transition_complete_keyframe", f76_arg0.clipFinished )
						end
						
						f76_arg0.Mrk2Def:beginAnimation( 120 )
						f76_arg0.Mrk2Def:registerEventHandler( "interrupted_keyframe", f76_arg0.clipInterrupted )
						f76_arg0.Mrk2Def:registerEventHandler( "transition_complete_keyframe", f80_local0 )
					end
					
					f76_arg0.Mrk2Def:completeAnimation()
					f76_arg0.Mrk2Def:setAlpha( 1 )
					f76_local2( f76_arg0.Mrk2Def )
					local f76_local3 = function ( f82_arg0 )
						local f82_local0 = function ( f83_arg0 )
							f83_arg0:beginAnimation( 150 )
							f83_arg0:setAlpha( 0 )
							f83_arg0:registerEventHandler( "transition_complete_keyframe", f76_arg0.clipFinished )
						end
						
						f76_arg0.Mrk3Def:beginAnimation( 220 )
						f76_arg0.Mrk3Def:registerEventHandler( "interrupted_keyframe", f76_arg0.clipInterrupted )
						f76_arg0.Mrk3Def:registerEventHandler( "transition_complete_keyframe", f82_local0 )
					end
					
					f76_arg0.Mrk3Def:completeAnimation()
					f76_arg0.Mrk3Def:setAlpha( 1 )
					f76_local3( f76_arg0.Mrk3Def )
					local f76_local4 = function ( f84_arg0 )
						local f84_local0 = function ( f85_arg0 )
							f85_arg0:beginAnimation( 150 )
							f85_arg0:setAlpha( 0 )
							f85_arg0:registerEventHandler( "transition_complete_keyframe", f76_arg0.clipFinished )
						end
						
						f76_arg0.Mrk4Def:beginAnimation( 310 )
						f76_arg0.Mrk4Def:registerEventHandler( "interrupted_keyframe", f76_arg0.clipInterrupted )
						f76_arg0.Mrk4Def:registerEventHandler( "transition_complete_keyframe", f84_local0 )
					end
					
					f76_arg0.Mrk4Def:completeAnimation()
					f76_arg0.Mrk4Def:setAlpha( 1 )
					f76_local4( f76_arg0.Mrk4Def )
					local f76_local5 = function ( f86_arg0 )
						local f86_local0 = function ( f87_arg0 )
							f87_arg0:beginAnimation( 170 )
							f87_arg0:setAlpha( 0 )
							f87_arg0:registerEventHandler( "transition_complete_keyframe", f76_arg0.clipFinished )
						end
						
						f76_arg0.Mrk5Def:beginAnimation( 380 )
						f76_arg0.Mrk5Def:registerEventHandler( "interrupted_keyframe", f76_arg0.clipInterrupted )
						f76_arg0.Mrk5Def:registerEventHandler( "transition_complete_keyframe", f86_local0 )
					end
					
					f76_arg0.Mrk5Def:completeAnimation()
					f76_arg0.Mrk5Def:setAlpha( 1 )
					f76_local5( f76_arg0.Mrk5Def )
					f76_arg0.Mrk1Act:completeAnimation()
					f76_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f76_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f76_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f76_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f76_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f76_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f76_arg0.clipFinished( f76_arg0.Mrk1Act )
					f76_arg0.Mrk2Act:completeAnimation()
					f76_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f76_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f76_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f76_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
					f76_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f76_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f76_arg0.clipFinished( f76_arg0.Mrk2Act )
					f76_arg0.Mrk3Act:completeAnimation()
					f76_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f76_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f76_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f76_arg0.Mrk3Act:setShaderVector( 2, 1.15, 0, 0, 0 )
					f76_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f76_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f76_arg0.clipFinished( f76_arg0.Mrk3Act )
					f76_arg0.Mrk4Act:completeAnimation()
					f76_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f76_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f76_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f76_arg0.Mrk4Act:setShaderVector( 2, 1.12, 0, 0, 0 )
					f76_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f76_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f76_arg0.clipFinished( f76_arg0.Mrk4Act )
					f76_arg0.Mrk5Act:completeAnimation()
					f76_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f76_arg0.Mrk5Act:setShaderVector( 0, 1.15, 0, 0, 0 )
					f76_arg0.Mrk5Act:setShaderVector( 1, 0.22, 0, 0, 0 )
					f76_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f76_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f76_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f76_arg0.clipFinished( f76_arg0.Mrk5Act )
					local f76_local6 = function ( f88_arg0 )
						local f88_local0 = function ( f89_arg0 )
							f89_arg0:beginAnimation( 1320 )
							f89_arg0:setAlpha( 0 )
							f89_arg0:registerEventHandler( "transition_complete_keyframe", f76_arg0.clipFinished )
						end
						
						f76_arg0.GlowOrangeOver:beginAnimation( 620, Enum[@"luitween"][@"luitween_bounce"] )
						f76_arg0.GlowOrangeOver:setAlpha( 1 )
						f76_arg0.GlowOrangeOver:registerEventHandler( "interrupted_keyframe", f76_arg0.clipInterrupted )
						f76_arg0.GlowOrangeOver:registerEventHandler( "transition_complete_keyframe", f88_local0 )
					end
					
					f76_arg0.GlowOrangeOver:completeAnimation()
					f76_arg0.GlowOrangeOver:setLeftRight( 0, 0, 37.5, 244.5 )
					f76_arg0.GlowOrangeOver:setTopBottom( 0, 0, 87, 269 )
					f76_arg0.GlowOrangeOver:setAlpha( 0 )
					f76_arg0.GlowOrangeOver:setZRot( 0 )
					f76_local6( f76_arg0.GlowOrangeOver )
					local f76_local7 = function ( f90_arg0 )
						local f90_local0 = function ( f91_arg0 )
							local f91_local0 = function ( f92_arg0 )
								f92_arg0:beginAnimation( 199 )
								f92_arg0:setAlpha( 0 )
								f92_arg0:registerEventHandler( "transition_complete_keyframe", f76_arg0.clipFinished )
							end
							
							f91_arg0:beginAnimation( 620, Enum[@"luitween"][@"luitween_ease_out"] )
							f91_arg0:setLeftRight( 0, 0, 116, 284 )
							f91_arg0:setTopBottom( 0, 0, 14, 266 )
							f91_arg0:registerEventHandler( "transition_complete_keyframe", f91_local0 )
						end
						
						f76_arg0.ZmFxSpark2Ext0:beginAnimation( 60 )
						f76_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 17.53, 185.53 )
						f76_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, 12.18, 264.18 )
						f76_arg0.ZmFxSpark2Ext0:setAlpha( 1 )
						f76_arg0.ZmFxSpark2Ext0:registerEventHandler( "interrupted_keyframe", f76_arg0.clipInterrupted )
						f76_arg0.ZmFxSpark2Ext0:registerEventHandler( "transition_complete_keyframe", f90_local0 )
					end
					
					f76_arg0.ZmFxSpark2Ext0:completeAnimation()
					f76_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 8, 176 )
					f76_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, 12, 264 )
					f76_arg0.ZmFxSpark2Ext0:setAlpha( 0 )
					f76_local7( f76_arg0.ZmFxSpark2Ext0 )
				end
			},
			Digits = {
				DefaultClip = function ( f93_arg0, f93_arg1 )
					f93_arg0:__resetProperties()
					f93_arg0:setupElementClipCounter( 10 )
					f93_arg0.Mrk1Def:completeAnimation()
					f93_arg0.Mrk1Def:setAlpha( 0 )
					f93_arg0.clipFinished( f93_arg0.Mrk1Def )
					f93_arg0.Mrk2Def:completeAnimation()
					f93_arg0.Mrk2Def:setAlpha( 0 )
					f93_arg0.clipFinished( f93_arg0.Mrk2Def )
					f93_arg0.Mrk3Def:completeAnimation()
					f93_arg0.Mrk3Def:setAlpha( 0 )
					f93_arg0.clipFinished( f93_arg0.Mrk3Def )
					f93_arg0.Mrk1Act:completeAnimation()
					f93_arg0.Mrk1Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f93_arg0.Mrk1Act:setShaderVector( 0, 1, 0, 0, 0 )
					f93_arg0.Mrk1Act:setShaderVector( 1, 0, 0, 0, 0 )
					f93_arg0.Mrk1Act:setShaderVector( 2, 1.25, 0, 0, 0 )
					f93_arg0.Mrk1Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f93_arg0.Mrk1Act:setShaderVector( 4, 0, 0, 0, 0 )
					f93_arg0.clipFinished( f93_arg0.Mrk1Act )
					f93_arg0.Mrk2Act:completeAnimation()
					f93_arg0.Mrk2Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f93_arg0.Mrk2Act:setShaderVector( 0, 1, 0, 0, 0 )
					f93_arg0.Mrk2Act:setShaderVector( 1, 0, 0, 0, 0 )
					f93_arg0.Mrk2Act:setShaderVector( 2, 1.08, 0, 0, 0 )
					f93_arg0.Mrk2Act:setShaderVector( 3, 0.21, 0, 0, 0 )
					f93_arg0.Mrk2Act:setShaderVector( 4, 0, 0, 0, 0 )
					f93_arg0.clipFinished( f93_arg0.Mrk2Act )
					f93_arg0.Mrk3Act:completeAnimation()
					f93_arg0.Mrk3Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f93_arg0.Mrk3Act:setShaderVector( 0, 1, 0, 0, 0 )
					f93_arg0.Mrk3Act:setShaderVector( 1, 0, 0, 0, 0 )
					f93_arg0.Mrk3Act:setShaderVector( 2, 1.15, 0, 0, 0 )
					f93_arg0.Mrk3Act:setShaderVector( 3, 0.26, 0, 0, 0 )
					f93_arg0.Mrk3Act:setShaderVector( 4, 0, 0, 0, 0 )
					f93_arg0.clipFinished( f93_arg0.Mrk3Act )
					f93_arg0.Mrk4Act:completeAnimation()
					f93_arg0.Mrk4Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f93_arg0.Mrk4Act:setShaderVector( 0, 1, 0, 0, 0 )
					f93_arg0.Mrk4Act:setShaderVector( 1, 0, 0, 0, 0 )
					f93_arg0.Mrk4Act:setShaderVector( 2, 1.12, 0, 0, 0 )
					f93_arg0.Mrk4Act:setShaderVector( 3, 0.35, 0, 0, 0 )
					f93_arg0.Mrk4Act:setShaderVector( 4, 0, 0, 0, 0 )
					f93_arg0.clipFinished( f93_arg0.Mrk4Act )
					f93_arg0.Mrk5Act:completeAnimation()
					f93_arg0.Mrk5Act:setMaterial( LUI.UIImage.GetCachedMaterial( @"uie_wipe" ) )
					f93_arg0.Mrk5Act:setShaderVector( 0, 1.15, 0, 0, 0 )
					f93_arg0.Mrk5Act:setShaderVector( 1, 0.22, 0, 0, 0 )
					f93_arg0.Mrk5Act:setShaderVector( 2, 1, 0, 0, 0 )
					f93_arg0.Mrk5Act:setShaderVector( 3, 0, 0, 0, 0 )
					f93_arg0.Mrk5Act:setShaderVector( 4, 0, 0, 0, 0 )
					f93_arg0.clipFinished( f93_arg0.Mrk5Act )
					f93_arg0.GlowOrangeOver:completeAnimation()
					f93_arg0.GlowOrangeOver:setLeftRight( 0, 0, 37.5, 244.5 )
					f93_arg0.GlowOrangeOver:setTopBottom( 0, 0, 87, 269 )
					f93_arg0.GlowOrangeOver:setZRot( 0 )
					f93_arg0.clipFinished( f93_arg0.GlowOrangeOver )
					f93_arg0.ZmFxSpark2Ext0:completeAnimation()
					f93_arg0.ZmFxSpark2Ext0:setLeftRight( 0, 0, 116, 284 )
					f93_arg0.ZmFxSpark2Ext0:setTopBottom( 0, 0, 14, 266 )
					f93_arg0.clipFinished( f93_arg0.ZmFxSpark2Ext0 )
				end
			}
		}

		CoD.ZmRnd.__onClose = function ( f94_arg0 )
			f94_arg0.Panel:close()
			f94_arg0.RndDigits:close()
			f94_arg0.ZmFxSpark2Ext0:close()
			f94_arg0.ZmFxSpark20:close()
		end

		CoD.ZmRndDigits = InheritFrom( LUI.UIElement )
		CoD.ZmRndDigits.__defaultWidth = 159
		CoD.ZmRndDigits.__defaultHeight = 120
		CoD.ZmRndDigits.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
			local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
			self:setClass( CoD.ZmRndDigits )
			self.id = "ZmRndDigits"
			self.soundSet = "HUD"
			self.anyChildUsesUpdateState = true
			f1_arg0:addElementToPendingUpdateStateList( self )
			
			local DigitsInt = CoD.ZmRndDigitsInt.new( f1_arg0, f1_arg1, 0, 0, 0.5, 159.5, 0, 0, 0, 120 )
			DigitsInt:mergeStateConditions( {
				{
					stateName = "Triple",
					condition = function ( menu, element, event )
						local TryRound = 101
						local BooleanTry
						
						if CoD.adjustedRoundGlobal == nil or TryRound > CoD.adjustedRoundGlobal then
							return AlwaysFalse()
						else
							return AlwaysTrue()
						end
					end
				},
				{
					stateName = "Double",
					condition = function ( menu, element, event )
						local TryRound = 11
						local BooleanTry
						
						if CoD.adjustedRoundGlobal == nil or TryRound > CoD.adjustedRoundGlobal then
							return AlwaysFalse()
						else
							return AlwaysTrue()
						end
					end
				}
			} )
			DigitsInt:linkToElementModel( DigitsInt, "roundsPlayed", true, function ( model )
				f1_arg0:updateElementState( DigitsInt, {
					name = "model_validation",
					menu = f1_arg0,
					controller = f1_arg1,
					modelValue = model:get(),
					modelName = "roundsPlayed"
				} )
			end )
			DigitsInt:setZRot( -10 )
			DigitsInt:linkToElementModel( self, nil, false, function ( model )
				DigitsInt:setModel( model, f1_arg1 )
			end )
			self:addElement( DigitsInt )
			self.DigitsInt = DigitsInt
			
			local DigitsOverlay = CoD.ZmRndDigitsInt.new( f1_arg0, f1_arg1, 0, 0, 0.5, 159.5, 0, 0, 0, 120 )
			DigitsOverlay:setAlpha( 0 )
			DigitsOverlay:setZRot( -19 )
			DigitsOverlay:setZoom( 52 )
			DigitsOverlay:setRFTMaterial( LUI.UIImage.GetCachedMaterial( @"ui_add" ) )
			self:addElement( DigitsOverlay )
			self.DigitsOverlay = DigitsOverlay
			
			local GlowOrangeOver = LUI.UIImage.new( 0, 0, -24, 183, 0, 0, -37, 145 )
			GlowOrangeOver:setRGB( 1, 0.31, 0 )
			GlowOrangeOver:setAlpha( 0 )
			GlowOrangeOver:setImage( RegisterImage( @"uie_t7_core_hud_mapwidget_panelglow" ) )
			GlowOrangeOver:setMaterial( LUI.UIImage.GetCachedMaterial( @"ui_add" ) )
			self:addElement( GlowOrangeOver )
			self.GlowOrangeOver = GlowOrangeOver
			
			local ZmFxFlsh10 = CoD.ZmFx_Flsh1.new( f1_arg0, f1_arg1, 0, 0, -101, 260, 0, 0, -41, 161 )
			ZmFxFlsh10:setRGB( 0, 0, 0 )
			ZmFxFlsh10:setRFTMaterial( LUI.UIImage.GetCachedMaterial( @"ui_add" ) )
			self:addElement( ZmFxFlsh10 )
			self.ZmFxFlsh10 = ZmFxFlsh10
			
			local ZmFxSpark20 = CoD.ZmFx_Spark2.new( f1_arg0, f1_arg1, 0, 0, -17.5, 177.5, 0, 0, -153, 171 )
			ZmFxSpark20:setRGB( 0.65, 0, 0 )
			ZmFxSpark20:setAlpha( 0 )
			ZmFxSpark20:setRFTMaterial( LUI.UIImage.GetCachedMaterial( @"ui_add" ) )
			ZmFxSpark20.Image0:setShaderVector( 1, 0, 1.37, 0, 0 )
			ZmFxSpark20.Image00:setShaderVector( 1, 0, -0.62, 0, 0 )
			self:addElement( ZmFxSpark20 )
			self.ZmFxSpark20 = ZmFxSpark20
			
			self:subscribeToGlobalModel( f1_arg1, "PerController", "gameScore.roundsPlayed", function ( model )
				local f6_local0 = self
				PlayClip( self, "Update", f1_arg1 )
			end )
			LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
			
			if PostLoadFunc then
				PostLoadFunc( self, f1_arg1, f1_arg0 )
			end
			
			return self
		end
		
		CoD.ZmRndDigits.__resetProperties = function ( f7_arg0 )
			f7_arg0.DigitsOverlay:completeAnimation()
			f7_arg0.DigitsInt:completeAnimation()
			f7_arg0.GlowOrangeOver:completeAnimation()
			f7_arg0.ZmFxFlsh10:completeAnimation()
			f7_arg0.DigitsOverlay:setAlpha( 0 )
			f7_arg0.DigitsOverlay:setZRot( -19 )
			f7_arg0.DigitsInt:setZoom( 0 )
			f7_arg0.GlowOrangeOver:setAlpha( 0 )
			f7_arg0.ZmFxFlsh10:setRGB( 0, 0, 0 )
			f7_arg0.ZmFxFlsh10:setAlpha( 1 )
		end
		
		CoD.ZmRndDigits.__clipsPerState = {
			DefaultState = {
				DefaultClip = function ( f8_arg0, f8_arg1 )
					f8_arg0:__resetProperties()
					f8_arg0:setupElementClipCounter( 0 )
				end,
				Update = function ( f9_arg0, f9_arg1 )
					f9_arg0:__resetProperties()
					f9_arg0:setupElementClipCounter( 4 )
					f9_arg0.DigitsInt:completeAnimation()
					f9_arg0.DigitsInt:setZoom( 25 )
					f9_arg0.clipFinished( f9_arg0.DigitsInt )
					local f9_local0 = function ( f10_arg0 )
						local f10_local0 = function ( f11_arg0 )
							local f11_local0 = function ( f12_arg0 )
								local f12_local0 = function ( f13_arg0 )
									f13_arg0:beginAnimation( 60 )
									f13_arg0:setAlpha( 0 )
									f13_arg0:setZRot( -19 )
									f13_arg0:registerEventHandler( "transition_complete_keyframe", f9_arg0.clipFinished )
								end
								
								f12_arg0:beginAnimation( 99 )
								f12_arg0:setAlpha( 0.13 )
								f12_arg0:setZRot( -2 )
								f12_arg0:registerEventHandler( "transition_complete_keyframe", f12_local0 )
							end
							
							f11_arg0:beginAnimation( 290, Enum[@"luitween"][@"luitween_bounce"] | Enum[@"luitween"][@"luitween_ease_out"] )
							f11_arg0:setAlpha( 0.36 )
							f11_arg0:setZRot( -17 )
							f11_arg0:registerEventHandler( "transition_complete_keyframe", f11_local0 )
						end
						
						f9_arg0.DigitsOverlay:beginAnimation( 110 )
						f9_arg0.DigitsOverlay:setAlpha( 1 )
						f9_arg0.DigitsOverlay:setZRot( -8 )
						f9_arg0.DigitsOverlay:registerEventHandler( "interrupted_keyframe", f9_arg0.clipInterrupted )
						f9_arg0.DigitsOverlay:registerEventHandler( "transition_complete_keyframe", f10_local0 )
					end
					
					f9_arg0.DigitsOverlay:completeAnimation()
					f9_arg0.DigitsOverlay:setAlpha( 0 )
					f9_arg0.DigitsOverlay:setZRot( 5 )
					f9_local0( f9_arg0.DigitsOverlay )
					local f9_local1 = function ( f14_arg0 )
						local f14_local0 = function ( f15_arg0 )
							local f15_local0 = function ( f16_arg0 )
								local f16_local0 = function ( f17_arg0 )
									local f17_local0 = function ( f18_arg0 )
										local f18_local0 = function ( f19_arg0 )
											local f19_local0 = function ( f20_arg0 )
												f20_arg0:beginAnimation( 840, Enum[@"luitween"][@"luitween_bounce"] )
												f20_arg0:setAlpha( 0 )
												f20_arg0:registerEventHandler( "transition_complete_keyframe", f9_arg0.clipFinished )
											end
											
											f19_arg0:beginAnimation( 9 )
											f19_arg0:setAlpha( 0.35 )
											f19_arg0:registerEventHandler( "transition_complete_keyframe", f19_local0 )
										end
										
										f18_arg0:beginAnimation( 20 )
										f18_arg0:setAlpha( 0.21 )
										f18_arg0:registerEventHandler( "transition_complete_keyframe", f18_local0 )
									end
									
									f17_arg0:beginAnimation( 69 )
									f17_arg0:setAlpha( 0.36 )
									f17_arg0:registerEventHandler( "transition_complete_keyframe", f17_local0 )
								end
								
								f16_arg0:beginAnimation( 20 )
								f16_arg0:setAlpha( 0.39 )
								f16_arg0:registerEventHandler( "transition_complete_keyframe", f16_local0 )
							end
							
							f15_arg0:beginAnimation( 20 )
							f15_arg0:setAlpha( 0.01 )
							f15_arg0:registerEventHandler( "transition_complete_keyframe", f15_local0 )
						end
						
						f9_arg0.GlowOrangeOver:beginAnimation( 20 )
						f9_arg0.GlowOrangeOver:registerEventHandler( "interrupted_keyframe", f9_arg0.clipInterrupted )
						f9_arg0.GlowOrangeOver:registerEventHandler( "transition_complete_keyframe", f14_local0 )
					end
					
					f9_arg0.GlowOrangeOver:completeAnimation()
					f9_arg0.GlowOrangeOver:setAlpha( 0.4 )
					f9_local1( f9_arg0.GlowOrangeOver )
					local f9_local2 = function ( f21_arg0 )
						local f21_local0 = function ( f22_arg0 )
							f22_arg0:beginAnimation( 680, Enum[@"luitween"][@"luitween_bounce"] )
							f22_arg0:setRGB( 0, 0, 0 )
							f22_arg0:registerEventHandler( "transition_complete_keyframe", f9_arg0.clipFinished )
						end
						
						f9_arg0.ZmFxFlsh10:beginAnimation( 320 )
						f9_arg0.ZmFxFlsh10:registerEventHandler( "interrupted_keyframe", f9_arg0.clipInterrupted )
						f9_arg0.ZmFxFlsh10:registerEventHandler( "transition_complete_keyframe", f21_local0 )
					end
					
					f9_arg0.ZmFxFlsh10:completeAnimation()
					f9_arg0.ZmFxFlsh10:setRGB( 0.9, 0.73, 0.68 )
					f9_arg0.ZmFxFlsh10:setAlpha( 1 )
					f9_local2( f9_arg0.ZmFxFlsh10 )
				end
			}
		}

		CoD.ZmRndDigits.__onClose = function ( f23_arg0 )
			f23_arg0.DigitsInt:close()
			f23_arg0.DigitsOverlay:close()
			f23_arg0.ZmFxFlsh10:close()
			f23_arg0.ZmFxSpark20:close()
		end
	end

	-- for discord rpc
	CoD.ZmRndDigitsInt = InheritFrom( LUI.UIElement )
	CoD.ZmRndDigitsInt.__defaultWidth = 159
	CoD.ZmRndDigitsInt.__defaultHeight = 120
	CoD.ZmRndDigitsInt.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
		self:setClass( CoD.ZmRndDigitsInt )
		self.id = "ZmRndDigitsInt"
		self.soundSet = "HUD"
		self.anyChildUsesUpdateState = true
		f1_arg0:addElementToPendingUpdateStateList( self )
		
		local ZmRndDigitWidget = CoD.ZmRndDigitWidget.new( f1_arg0, f1_arg1, 0, 0, -60, 24, 0, 0, 0, 120 )
		ZmRndDigitWidget:mergeStateConditions( {
			{
				stateName = "One",
				condition = function ( menu, element, event )
					return IsZombieRoundTensDigitEqualTo( element, f1_arg1, 1 )
				end
			},
			{
				stateName = "Two",
				condition = function ( menu, element, event )
					return IsZombieRoundTensDigitEqualTo( element, f1_arg1, 2 )
				end
			},
			{
				stateName = "Three",
				condition = function ( menu, element, event )
					return IsZombieRoundTensDigitEqualTo( element, f1_arg1, 3 )
				end
			},
			{
				stateName = "Four",
				condition = function ( menu, element, event )
					return IsZombieRoundTensDigitEqualTo( element, f1_arg1, 4 )
				end
			},
			{
				stateName = "Five",
				condition = function ( menu, element, event )
					return IsZombieRoundTensDigitEqualTo( element, f1_arg1, 5 )
				end
			},
			{
				stateName = "Six",
				condition = function ( menu, element, event )
					return IsZombieRoundTensDigitEqualTo( element, f1_arg1, 6 )
				end
			},
			{
				stateName = "Seven",
				condition = function ( menu, element, event )
					return IsZombieRoundTensDigitEqualTo( element, f1_arg1, 7 )
				end
			},
			{
				stateName = "Eight",
				condition = function ( menu, element, event )
					return IsZombieRoundTensDigitEqualTo( element, f1_arg1, 8 )
				end
			},
			{
				stateName = "Nine",
				condition = function ( menu, element, event )
					return IsZombieRoundTensDigitEqualTo( element, f1_arg1, 9 )
				end
			},
			{
				stateName = "Zero",
				condition = function ( menu, element, event )
					return IsZombieRoundTensDigitEqualTo( element, f1_arg1, 0 )
				end
			}
		} )
		ZmRndDigitWidget:linkToElementModel( ZmRndDigitWidget, "roundsPlayed", true, function ( model )
			f1_arg0:updateElementState( ZmRndDigitWidget, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = CoD.adjustedRoundGlobal,
				modelName = "roundsPlayed"
			} )
		end )
		ZmRndDigitWidget:linkToElementModel( self, nil, false, function ( model )
			ZmRndDigitWidget:setModel( model, f1_arg1 )
		end )
		ZmRndDigitWidget:linkToElementModel( self, "roundsPlayed", true, function ( model )
			local f14_local0 = ZmRndDigitWidget
			PlayClipOnElement( self, {
				elementName = "ZmRndDigitWidget",
				clipName = "DefaultClip"
			}, f1_arg1 )
		end )
		self:addElement( ZmRndDigitWidget )
		self.ZmRndDigitWidget = ZmRndDigitWidget
		
		local ZmRndDigitWidget0 = CoD.ZmRndDigitWidget.new( f1_arg0, f1_arg1, 0, 0, 37.5, 121.5, 0, 0, 0, 120 )
		ZmRndDigitWidget0:mergeStateConditions( {
			{
				stateName = "One",
				condition = function ( menu, element, event )
					return IsZombieRoundOnesDigitEqualTo( element, f1_arg1, 1 )
				end
			},
			{
				stateName = "Two",
				condition = function ( menu, element, event )
					return IsZombieRoundOnesDigitEqualTo( element, f1_arg1, 2 )
				end
			},
			{
				stateName = "Three",
				condition = function ( menu, element, event )
					return IsZombieRoundOnesDigitEqualTo( element, f1_arg1, 3 )
				end
			},
			{
				stateName = "Four",
				condition = function ( menu, element, event )
					return IsZombieRoundOnesDigitEqualTo( element, f1_arg1, 4 )
				end
			},
			{
				stateName = "Five",
				condition = function ( menu, element, event )
					return IsZombieRoundOnesDigitEqualTo( element, f1_arg1, 5 )
				end
			},
			{
				stateName = "Six",
				condition = function ( menu, element, event )
					return IsZombieRoundOnesDigitEqualTo( element, f1_arg1, 6 )
				end
			},
			{
				stateName = "Seven",
				condition = function ( menu, element, event )
					return IsZombieRoundOnesDigitEqualTo( element, f1_arg1, 7 )
				end
			},
			{
				stateName = "Eight",
				condition = function ( menu, element, event )
					return IsZombieRoundOnesDigitEqualTo( element, f1_arg1, 8 )
				end
			},
			{
				stateName = "Nine",
				condition = function ( menu, element, event )
					return IsZombieRoundOnesDigitEqualTo( element, f1_arg1, 9 )
				end
			},
			{
				stateName = "Zero",
				condition = function ( menu, element, event )
					return IsZombieRoundOnesDigitEqualTo( element, f1_arg1, 0 )
				end
			}
		} )

		-- GET ROUNDS FOR RPC
		ZmRndDigitWidget0:linkToElementModel( ZmRndDigitWidget0, "roundsPlayed", true, function ( model )
			if Engine[@"getdvarint"](@"shield_diff_rounds") == 1 and not IsDemoPlaying() then
				local currentRound = model:get() - 1

				if currentRound < CoD.lastRound then
					CoD.roundOffset = CoD.roundOffset + 256
				end
				
				local adjustedRound = currentRound + CoD.roundOffset
				
				CoD.lastRound = currentRound
	
				CoD.adjustedRoundGlobal = adjustedRound + 1
				
				CoD.EnhPrintInfo("Rounds, currentRound -> " .. currentRound, "Rounds, adjustedRound -> " .. adjustedRound)
				CoD.SetRoundRPC(adjustedRound)
			else
				local currentRound = model:get() - 1

				local adjustedRound = currentRound
				
				CoD.adjustedRoundGlobal = adjustedRound + 1
				
				CoD.EnhPrintInfo("Rounds, currentRound -> " .. currentRound, "Rounds, adjustedRound -> " .. adjustedRound)
				CoD.SetRoundRPC(adjustedRound)
			end
			
			f1_arg0:updateElementState( ZmRndDigitWidget0, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = CoD.adjustedRoundGlobal,
				modelName = "roundsPlayed"
			} )
		end )
		ZmRndDigitWidget0:linkToElementModel( self, nil, false, function ( model )
			ZmRndDigitWidget0:setModel( model, f1_arg1 )
		end )
		self:addElement( ZmRndDigitWidget0 )
		self.ZmRndDigitWidget0 = ZmRndDigitWidget0
		
		local ZmRndDigitWidget1 = CoD.ZmRndDigitWidget.new( f1_arg0, f1_arg1, 0, 0, -60, 24, 0, 0, 0, 120 )
		ZmRndDigitWidget1:mergeStateConditions( {
			{
				stateName = "One",
				condition = function ( menu, element, event )
					return IsZombieRoundHundredsDigitEqualTo( element, f1_arg1, 1 )
				end
			},
			{
				stateName = "Two",
				condition = function ( menu, element, event )
					return IsZombieRoundHundredsDigitEqualTo( element, f1_arg1, 2 )
				end
			},
			{
				stateName = "Three",
				condition = function ( menu, element, event )
					return IsZombieRoundHundredsDigitEqualTo( element, f1_arg1, 3 )
				end
			},
			{
				stateName = "Four",
				condition = function ( menu, element, event )
					return IsZombieRoundHundredsDigitEqualTo( element, f1_arg1, 4 )
				end
			},
			{
				stateName = "Five",
				condition = function ( menu, element, event )
					return IsZombieRoundHundredsDigitEqualTo( element, f1_arg1, 5 )
				end
			},
			{
				stateName = "Six",
				condition = function ( menu, element, event )
					return IsZombieRoundHundredsDigitEqualTo( element, f1_arg1, 6 )
				end
			},
			{
				stateName = "Seven",
				condition = function ( menu, element, event )
					return IsZombieRoundHundredsDigitEqualTo( element, f1_arg1, 7 )
				end
			},
			{
				stateName = "Eight",
				condition = function ( menu, element, event )
					return IsZombieRoundHundredsDigitEqualTo( element, f1_arg1, 8 )
				end
			},
			{
				stateName = "Nine",
				condition = function ( menu, element, event )
					return IsZombieRoundHundredsDigitEqualTo( element, f1_arg1, 9 )
				end
			},
			{
				stateName = "Zero",
				condition = function ( menu, element, event )
					return IsZombieRoundHundredsDigitEqualTo( element, f1_arg1, 0 )
				end
			}
		} )
		ZmRndDigitWidget1:linkToElementModel( ZmRndDigitWidget1, "roundsPlayed", true, function ( model )
			f1_arg0:updateElementState( ZmRndDigitWidget1, {
				name = "model_validation",
				menu = f1_arg0,
				controller = f1_arg1,
				modelValue = CoD.adjustedRoundGlobal,
				modelName = "roundsPlayed"
			} )
		end )
		ZmRndDigitWidget1:linkToElementModel( self, nil, false, function ( model )
			ZmRndDigitWidget1:setModel( model, f1_arg1 )
		end )
		ZmRndDigitWidget1:linkToElementModel( self, "roundsPlayed", true, function ( model )
			local f39_local0 = ZmRndDigitWidget1
			PlayClipOnElement( self, {
				elementName = "ZmRndDigitWidget1",
				clipName = "DefaultClip"
			}, f1_arg1 )
		end )
		self:addElement( ZmRndDigitWidget1 )
		self.ZmRndDigitWidget1 = ZmRndDigitWidget1
		
		LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
		
		if PostLoadFunc then
			PostLoadFunc( self, f1_arg1, f1_arg0 )
		end

		CoD.EnhPrintInfo("Rounds Enter")

		--local TryGetRounds = Engine[@"getmodel"]( self:getmodel(), "roundsPlayed" )
		--local RoundsGet = Engine[@"getmodelvalue"]( TryGetRounds )

		--CoD.EnhPrintInfo("Rounds", RoundsGet)
		
		return self
	end

	CoD.ZmRndDigitsInt.__resetProperties = function ( f40_arg0 )
		f40_arg0.ZmRndDigitWidget:completeAnimation()
		f40_arg0.ZmRndDigitWidget1:completeAnimation()
		f40_arg0.ZmRndDigitWidget0:completeAnimation()
		f40_arg0.ZmRndDigitWidget:setLeftRight( 0, 0, -60, 24 )
		f40_arg0.ZmRndDigitWidget:setTopBottom( 0, 0, 0, 120 )
		f40_arg0.ZmRndDigitWidget:setAlpha( 1 )
		f40_arg0.ZmRndDigitWidget1:setLeftRight( 0, 0, -60, 24 )
		f40_arg0.ZmRndDigitWidget1:setTopBottom( 0, 0, 0, 120 )
		f40_arg0.ZmRndDigitWidget1:setAlpha( 1 )
		f40_arg0.ZmRndDigitWidget0:setLeftRight( 0, 0, 37.5, 121.5 )
		f40_arg0.ZmRndDigitWidget0:setTopBottom( 0, 0, 0, 120 )
	end

	CoD.ZmRndDigitsInt.__clipsPerState = {
		DefaultState = {
			DefaultClip = function ( f41_arg0, f41_arg1 )
				f41_arg0:__resetProperties()
				f41_arg0:setupElementClipCounter( 2 )
				f41_arg0.ZmRndDigitWidget:completeAnimation()
				f41_arg0.ZmRndDigitWidget:setAlpha( 0 )
				f41_arg0.clipFinished( f41_arg0.ZmRndDigitWidget )
				f41_arg0.ZmRndDigitWidget1:completeAnimation()
				f41_arg0.ZmRndDigitWidget1:setAlpha( 0 )
				f41_arg0.clipFinished( f41_arg0.ZmRndDigitWidget1 )
			end
		},
		Triple = {
			DefaultClip = function ( f42_arg0, f42_arg1 )
				f42_arg0:__resetProperties()
				f42_arg0:setupElementClipCounter( 3 )
				f42_arg0.ZmRndDigitWidget:completeAnimation()
				f42_arg0.ZmRndDigitWidget:setLeftRight( 0, 0, 64, 148 )
				f42_arg0.ZmRndDigitWidget:setTopBottom( 0, 0, 0, 120 )
				f42_arg0.clipFinished( f42_arg0.ZmRndDigitWidget )
				f42_arg0.ZmRndDigitWidget0:completeAnimation()
				f42_arg0.ZmRndDigitWidget0:setLeftRight( 0, 0, 129, 213 )
				f42_arg0.ZmRndDigitWidget0:setTopBottom( 0, 0, 0, 120 )
				f42_arg0.clipFinished( f42_arg0.ZmRndDigitWidget0 )
				f42_arg0.ZmRndDigitWidget1:completeAnimation()
				f42_arg0.ZmRndDigitWidget1:setLeftRight( 0, 0, 0, 84 )
				f42_arg0.ZmRndDigitWidget1:setTopBottom( 0, 0, 0, 120 )
				f42_arg0.clipFinished( f42_arg0.ZmRndDigitWidget1 )
			end
		},
		Double = {
			DefaultClip = function ( f43_arg0, f43_arg1 )
				f43_arg0:__resetProperties()
				f43_arg0:setupElementClipCounter( 3 )
				f43_arg0.ZmRndDigitWidget:completeAnimation()
				f43_arg0.ZmRndDigitWidget:setLeftRight( 0, 0, -1, 83 )
				f43_arg0.clipFinished( f43_arg0.ZmRndDigitWidget )
				f43_arg0.ZmRndDigitWidget0:completeAnimation()
				f43_arg0.ZmRndDigitWidget0:setLeftRight( 0, 0, 62.5, 146.5 )
				f43_arg0.clipFinished( f43_arg0.ZmRndDigitWidget0 )
				f43_arg0.ZmRndDigitWidget1:completeAnimation()
				f43_arg0.ZmRndDigitWidget1:setAlpha( 0 )
				f43_arg0.clipFinished( f43_arg0.ZmRndDigitWidget1 )
			end
		}
	}

	CoD.ZmRndDigitsInt.__onClose = function ( f44_arg0 )
		f44_arg0.ZmRndDigitWidget:close()
		f44_arg0.ZmRndDigitWidget0:close()
		f44_arg0.ZmRndDigitWidget1:close()
	end
end

---------------------------