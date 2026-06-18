--[[
		.\hksc.exe ".\Lua\Chat.Lua" -o "C:\Program Files (x86)\Call of Duty Black Ops 4\project-bo4\mods\T8ShieldSupport\Lua\Game\Chat.luac"
]]

---------------------------

if CoD.isFrontend then
	return
end

CoD.ShieldInitLuaFile()

---------------------------

function ChatClientEnabled( f399_arg0 )
	return true
end

function ChatClientIsAvailable( f400_arg0, f400_arg1, f400_arg2 )
	return true
end

function ChatClientStaticAllowed( f409_arg0 )
	return true
end

function ChatClientOnlineChannelsAvailable( f406_arg0 )
	return true
end

function ChatClientShow( f398_arg0 )
	return true
end

function ChatClientInputEnabled( f407_arg0 )
	return true
end

---------------------------

-- Chat Overhul, Colors and Shit
DataSources.ChatClientEntriesList = {
	prepare = function ( f648_arg0, f648_arg1, f648_arg2 )
		f648_arg1.controller = f648_arg0
		local f648_local0 = Engine[@"getxuid64"]( f648_arg0 )
		local f648_local1 = CoD.ChatClientUtility.GetChatEntriesListModel( f648_arg0 )
		f648_arg1.chatClientEntriesModel = f648_local1
		f648_arg1.GetList = Engine[@"hash_3244BA82C570F260"]
		f648_arg1.CountEntries = math.min( Engine[@"hash_5089CD24046934B2"]( true ), 50 )
		if not f648_arg1.lastTimeStamp then
			f648_arg1.lastTimeStamp = 0
		end
		local f648_local2 = {
			xuid = 0,
			fullname = "",
			realName = "",
			text = "",
			timestamp = "",
			timeMs = 0,
			chId = "0-0-0",
			chText = "",
			chColor = "255 255 255",
			displayName = "",
			fullLineOfText = "",
			isNew = false
		}
		f648_arg1.chatEntries = {}
		for f648_local3 = 1, f648_arg1.CountEntries, 1 do
			f648_arg1.chatEntries[f648_local3] = {}
			f648_arg1.chatEntries[f648_local3].root = Engine[@"createmodel"]( f648_local1, "entry_" .. f648_local3 )
			f648_arg1.chatEntries[f648_local3].model = Engine[@"createmodel"]( f648_arg1.chatEntries[f648_local3].root, "model" )
			f648_arg1.chatEntries[f648_local3].properties = {}
			for f648_local9, f648_local10 in pairs( f648_local2 ) do
				local f648_local11 = Engine[@"createmodel"]( f648_arg1.chatEntries[f648_local3].model, f648_local9 )
			end
		end
		local f648_local3 = {}
		f648_local3 = f648_arg1.GetList( true, 0, 50 )
		if f648_local3 then
			for f648_local4 = 1, #f648_local3, 1 do
				local f648_local7 = f648_local3[f648_local4]
				local f648_local8 = f648_local4
				for f648_local14, f648_local15 in pairs( f648_local7 ) do
					if f648_local14 ~= "isNew" then
						local f648_local13 = Engine[@"getmodel"]( f648_arg1.chatEntries[f648_local8].model, f648_local14 )
						if f648_local13 ~= nil then
							f648_local13:set( f648_local15 )
						end
						f648_arg1.chatEntries[f648_local8].properties[f648_local14] = f648_local15
					end
				end

				-- here is fixing dumb decompiler issue
				local f648_local9 = f648_arg1.chatEntries[f648_local8].properties.channeltype -- UI ERROR 756
				local f648_local15 = nil
				local f648_local14 = nil
				local f648_local16 = nil
				local f648_local11 = nil
				local f648_local10 = nil

				--CoD.EnhPrintInfo("Test")

				if f648_local9 ~= nil then
					--CoD.EnhPrintInfo("Test")
					if f648_local9 == Enum[@"hash_7F6296F5D7A38AD2"][@"hash_659073B959F68608"] then
						f648_local11 = f648_arg1.chatEntries[f648_local8].properties.text
						f648_local14, f648_local15 = string.match( f648_local11, "^^(%d)(.*)" )
						if f648_local14 then
							f648_local10 = CoD.ChatClientUtility.ColorToString( CoD.ChatClientUtility.GetColorForGameEventType( tonumber( f648_local14 ) ) )
						end
						if f648_local15 == nil then
							f648_local15 = f648_local11
						end
						-- replace black text, since its usless
						f648_arg1.chatEntries[f648_local8].properties.text = string.gsub(f648_local11, "%^0", "%^5")
					end
					if f648_local10 == nil then
						f648_local10 = CoD.ChatClientUtility.ColorToString( CoD.ChatClientUtility.GetColorForChannelType( f648_local9 ) )
					end
					f648_local11 = Engine[@"getmodel"]( f648_arg1.chatEntries[f648_local8].model, "chColor" )
					if f648_local11 ~= nil then
						--f648_local11:set( f648_local10 ) -- don't set color, no need
					end
					--f648_arg1.chatEntries[f648_local8].properties.chColor = f648_local10
				end
				f648_local10 = CoD.PCBattlenetUtility.StripBattleTagNumber( f648_arg1.chatEntries[f648_local8].properties.fullname )
				f648_local11 = f648_local10
				if f648_local10 ~= "" and Engine[@"getprofilevarint"]( f648_arg0, @"show_real_names" ) ~= 0 and (f648_local0 ~= f648_arg1.chatEntries[f648_local8].properties.xuid or f648_local9 == Enum[@"hash_7F6296F5D7A38AD2"][@"hash_75E57997D82BCBD1"]) then
					f648_local15 = f648_arg1.chatEntries[f648_local8].properties.realname
					if f648_local15 and f648_local15 ~= "" then
						f648_local10 = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_52482C16CD79B0E8", f648_local10, f648_local15 )
					end
				end
				f648_local15 = f648_arg1.chatEntries[f648_local8].model.fullName
				if f648_local15 ~= nil then
					f648_local15:set( f648_local10 )
				end
				if f648_local9 ~= Enum[@"hash_7F6296F5D7A38AD2"][@"hash_659073B959F68608"] then
					local f648_local13, f648_local16 = string.match( f648_local10, "%[(.*)%](.+)" )
					if f648_local13 then
						f648_local10 = "[" .. f648_local13 .. "][" .. f648_local16 .. "]"
					else
						f648_local10 = "[" .. f648_local10 .. "]"
					end
				end
				if f648_local9 == Enum[@"hash_7F6296F5D7A38AD2"][@"hash_75E57997D82BCBD1"] and f648_local0 == f648_arg1.chatEntries[f648_local8].properties.xuid then
					f648_local10 = Engine[@"hash_4F9F1239CFD921FE"]( @"hash_2434C934E77B37E9", f648_local10 )
					f648_arg1.chatEntries[f648_local8].model.xuid:set( f648_local7.whisperTargetxuid )
				end
				local f648_local13 = Engine[@"getmodel"]( f648_arg1.chatEntries[f648_local8].model, "displayName" )
				if f648_local13 ~= nil then
					Engine[@"setmodelvalue"]( f648_local13, f648_local11 )
				end
				local f648_local16 = Engine[@"getmodel"]( f648_arg1.chatEntries[f648_local8].model, "fullLineOfText" )
				if f648_local10 and f648_local10 ~= "" then
					f648_local16:set( f648_local10 .. ": " .. f648_arg1.chatEntries[f648_local8].properties.text )
				else
					f648_local16:set( f648_arg1.chatEntries[f648_local8].properties.text )
				end
				local f648_local17 = Engine[@"getmodel"]( f648_arg1.chatEntries[f648_local8].model, "timeMs" )
				if f648_arg1.lastTimeStamp < f648_local17:get() then
					local f648_local18 = Engine[@"getmodel"]( f648_arg1.chatEntries[f648_local8].model, "isNew" )
					f648_local18:set( true )
				end
			end
			for f648_local4 = #f648_local3 + 1, 50, 1 do
				local f648_local7 = f648_local4
				if f648_arg1.chatEntries[f648_local7] then
					for f648_local11, f648_local14 in pairs( f648_local2 ) do
						if f648_local11 == "xuid" then
							f648_local14 = LuaDefine.INVALID_XUID_X64
						end
						if f648_local11 ~= "isNew" then
							local f648_local15 = Engine[@"getmodel"]( f648_arg1.chatEntries[f648_local7].model, f648_local11 )
							if f648_local15 ~= nil then
								f648_local15:set( f648_local14 )
							end
							f648_arg1.chatEntries[f648_local7].properties[f648_local11] = f648_local14
						end
					end
				end
			end
		end
		if f648_arg1.updateSubscription then
			f648_arg1:removeSubscription( f648_arg1.updateSubscription )
		end
		f648_arg1.updateSubscription = f648_arg1:subscribeToModel( CoD.ChatClientUtility.GetEventModel( f648_arg0 ), function ( model )
			f648_arg1:updateDataSource()
		end, false )
		f648_arg1.lastTimeStamp = Engine[@"milliseconds"]()
	end,
	getCount = function ( f650_arg0 )
		return f650_arg0.CountEntries
	end,
	getItem = function ( f651_arg0, f651_arg1, f651_arg2 )
		return f651_arg1.chatEntries[f651_arg1.CountEntries - f651_arg2 + 1].model
	end
}

CoD.ChatClientUtility.TrySendLine = function ( f41_arg0, f41_arg1 )
	local TextMsg = f41_arg1
	local f41_local1 = true
	local f41_local2 = true
	local f41_local3 = true
	local f41_local4 = nil

	CoD.EnhPrintInfo("Request Chat Message", TextMsg)

	local f41_local5, f41_local6, f41_local7 = CoD.ChatClientUtility.GetCommand( f41_arg0, f41_arg1 )
	if f41_local7 then
		f41_local1 = true
		f41_local2 = false
		TextMsg = nil
		f41_local4 = @"hash_256696C428AB2A8B"
	elseif f41_local5 then
		TextMsg, f41_local1, f41_local3, f41_local4 = f41_local5.fct( f41_arg0, f41_local6 )
	end

	if TextMsg then
		f41_local2 = TextMsg == ""
		if not f41_local2 then
			local f41_local8 = CoD.ChatClientUtility.GetInputChannelModel( f41_arg0 )
			local f41_local9 = "1-1-1"
			if Engine[@"getdvarint"](@"shield_is_offline") == 1 then
				Engine[@"hash_19B57C0F0680848E"]( f41_local9, TextMsg )
			end

			if Engine[@"hash_3CA0ADE9B4DA235D"]( f41_local9 ) then
				Engine[@"hash_6D1DD5DBCA5778EA"]( f41_local9 )
			end
				f41_local1 = true
		end
	end

	if f41_local4 then
		CoD.PCUtility.ShowGameEvent( Engine[@"hash_4F9F1239CFD921FE"]( f41_local4 ) )
	end
	local f41_local8
	if not CoD.isFrontend then
		f41_local8 = not CoD.PCWidgetUtility.CanShowMenuStyleChat( f41_arg0 )
	else
		f41_local8 = false
	end

	-- if its not a command
	if TextMsg ~= nil and TextMsg ~= "" and not f41_local4 and not f41_local5 then
		--CoD.PCUtility.ShowGameEvent(TextMsg)
		Engine[@"exec"](Engine[@"getprimarycontroller"](), "sendchatmessage " .. TextMsg)

		CoD.EnhPrintInfo("sent chat message", TextMsg)
	end

	return f41_local8 or f41_local3 and f41_local2, f41_local1, f41_local2 and f41_local3
end

-- Chat Client View Text
CoD.ChatClientChatEntryLineOfText = InheritFrom( LUI.UIElement )
CoD.ChatClientChatEntryLineOfText.__defaultWidth = 508
CoD.ChatClientChatEntryLineOfText.__defaultHeight = 21
CoD.ChatClientChatEntryLineOfText.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
      local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
      self:setClass( CoD.ChatClientChatEntryLineOfText )
      self.id = "ChatClientChatEntryLineOfText"
      self.soundSet = "default"
      
      local entryBodyText = LUI.UIText.new( 0, 0, 0, 508, 0, 0, 0, 21 )
      entryBodyText:setTTF( "notosans_bold" )
      entryBodyText:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_90D57B1E92D39D7" ) )
      entryBodyText:setShaderVector( 0, 0.22, 0, 0, 0 )
      entryBodyText:setShaderVector( 1, 0.99, 0, 0, 0 )
      entryBodyText:setShaderVector( 2, 0, 0, 0, 0.8 )
      entryBodyText:setLetterSpacing( 1 )
      entryBodyText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
      entryBodyText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
      entryBodyText:linkToElementModel( self, "chColor", true, function ( model )
            local f2_local0 = model:get()
            if f2_local0 ~= nil then
                  --entryBodyText:setRGB( f2_local0 )
            end
      end )
      entryBodyText:linkToElementModel( self, "fullLineOfText", true, function ( model )
            local f3_local0 = model:get()
            if f3_local0 ~= nil then
                  entryBodyText:setText( f3_local0 --[[CoD.PCUtility.ReplaceCircumflex( f3_local0 )]] )
            end
      end )
      LUI.OverrideFunction_CallOriginalFirst( entryBodyText, "setText", function ( element, controller )
            if not ChatClientCurrentChatIsActive( f1_arg1 ) then
                  CoD.PCWidgetUtility.UpdateChatEntryState( self, f1_arg1, "FadeOut" )
                  CoD.PCWidgetUtility.UpdateChatEntryPositions( self, f1_arg1 )
            else
                  CoD.PCWidgetUtility.UpdateChatEntryPositions( self, f1_arg1 )
            end
      end )
      self:addElement( entryBodyText )
      self.entryBodyText = entryBodyText
      
      LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
      
      if PostLoadFunc then
            PostLoadFunc( self, f1_arg1, f1_arg0 )
      end
      
      local f1_local2 = self
      f1_local2 = entryBodyText
      ActivateTextStencilCulling( f1_local2 )
      DisableModelStringReplacement( f1_local2 )
      return self
end

CoD.ChatClientChatEntryLineOfText.__onClose = function ( f5_arg0 )
      f5_arg0.entryBodyText:close()
end

-- Chat Input View
local f0_local0 = 14
local f0_local1 = 18
local PostLoadFuncChatInput = function ( self, controller, menu )
      self.arrangeText = function ( f2_arg0 )
            local f2_local0, f2_local1, f2_local2, f2_local3 = f2_arg0:getLocalRect()
            local f2_local4, f2_local5, f2_local6, f2_local7 = nil
            f2_local7 = 4
            f2_local6 = f2_local7 + f2_arg0.channelText:getTextWidth()
            f2_arg0.channelText:setLeftRight( true, false, f2_local7, f2_local6 )
            f2_local7 = f2_local6 + 6
            f2_local6 = f2_local2 - f2_local0 - 6
            --f2_arg0.ChatClientInputTextBoxField:setLeftRight( true, false, f2_local7, f2_local6 )
            --f2_arg0.tabText:setLeftRight( true, false, f2_local7, f2_local6 )
      end
      
      self:registerEventHandler( "update_safe_area", function ( element, event )
            element:arrangeText()
      end )
end

CoD.ChatClientInputTextBox = InheritFrom( LUI.UIElement )
CoD.ChatClientInputTextBox.__defaultWidth = 519
CoD.ChatClientInputTextBox.__defaultHeight = 48
CoD.ChatClientInputTextBox.new = function ( f4_arg0, f4_arg1, f4_arg2, f4_arg3, f4_arg4, f4_arg5, f4_arg6, f4_arg7, f4_arg8, f4_arg9 )
      local self = LUI.UIElement.new( f4_arg2, f4_arg3, f4_arg4, f4_arg5, f4_arg6, f4_arg7, f4_arg8, f4_arg9 )
      self:setClass( CoD.ChatClientInputTextBox )
      self.id = "ChatClientInputTextBox"
      self.soundSet = "default"
      self.onlyChildrenFocusable = true
      self.anyChildUsesUpdateState = true
      f4_arg0:addElementToPendingUpdateStateList( self )
      
      local tabText = LUI.UIText.new( 0.27, 0.27, -125, 125, 0.54, 0.54, -12.5, 8.5 )
      tabText:setRGB( 0.42, 0.42, 0.42 )
      tabText:setAlpha( 0 )

      if Engine[@"getdvarint"](@"shield_is_offline") == 1 then
		tabText:setText( "Channel is set to Offline" )
	  else
		tabText:setText( "Channel is set to " .. Engine[@"getdvarstring"]("shield_chat_type") or "GLOBAL" )
	  end

      tabText:setTTF( "notosans_bold" )
      tabText:setLetterSpacing( 1 )
      tabText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
      self:addElement( tabText )
      self.tabText = tabText

	  CoD.Menu.TabTextChat = tabText
      
      local channelText = LUI.UIText.new( 0.22, 0.22, -117, 117, 0.52, 0.52, -11.5, 9.5 )
      channelText:setTTF( "notosans_bold" )
      channelText:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_171E049B161CD00A" ) )
      channelText:setLetterSpacing( 1 )
      channelText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
      channelText:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_3F41D595A2B0EDF3"] )
      channelText:linkToElementModel( self, "InputChannel", true, function ( model )
            local f5_local0 = model:get()
            if f5_local0 ~= nil then
                  channelText:setRGB( CoD.PCWidgetUtility.GetChatChannelColor( f5_local0 ) )
            end
      end )
      channelText.__String_Reference = function ( f6_arg0 )
            local f6_local0 = f6_arg0:get()
            if f6_local0 ~= nil then
                  channelText:setText( CoD.PCUtility.ChatChannelNameFromChatId( false, f4_arg1, f6_local0 ) )
            end
      end
      
      channelText:linkToElementModel( self, "InputChannel", true, channelText.__String_Reference )
      channelText.__String_Reference_FullPath = function ()
            local f7_local0 = self:getModel()
            if f7_local0 then
                  f7_local0 = self:getModel()
                  f7_local0 = f7_local0.InputChannel
            end
            if f7_local0 then
                  channelText.__String_Reference( f7_local0 )
            end
      end
      
      LUI.OverrideFunction_CallOriginalFirst( channelText, "setText", function ( element, controller )
            ChatClientInputArrangeText( self, element, f4_arg1 )
      end )
      LUI.OverrideFunction_CallOriginalFirst( channelText, "setWidth", function ( element, controller )
            ChatClientInputArrangeText( self, element, f4_arg1 )
      end )
      channelText:linkToElementModel( self, "Event", true, function ( model )
            ChatClientInputArrangeText( self, channelText, f4_arg1 )
      end )
      self:addElement( channelText )
      self.channelText = channelText
      
      local ChatClientInputTextBoxField = CoD.ChatClientInputTextBoxField.new( f4_arg0, f4_arg1, 0, 1, 0, 0, 0.17, 0.87, 0, 0 )
      ChatClientInputTextBoxField:mergeStateConditions( {
            {
                  stateName = "Disabled",
                  condition = function ( menu, element, event )
                        return not ChatClientIsAvailable( self, element, f4_arg1 )
                  end
            }
      } )
      local LineLeft = ChatClientInputTextBoxField
      local Border = ChatClientInputTextBoxField.subscribeToModel
      local f4_local6 = Engine[@"hash_4DF5CFBC1771947"]( f4_arg1 )
      Border( LineLeft, f4_local6["ChatGlobal.Event"], function ( f12_arg0 )
            f4_arg0:updateElementState( ChatClientInputTextBoxField, {
                  name = "model_validation",
                  menu = f4_arg0,
                  controller = f4_arg1,
                  modelValue = f12_arg0:get(),
                  modelName = "ChatGlobal.Event"
            } )
      end, false )
      LineLeft = ChatClientInputTextBoxField
      Border = ChatClientInputTextBoxField.subscribeToModel
      f4_local6 = Engine[@"hash_4DF5CFBC1771947"]( f4_arg1 )
      Border( LineLeft, f4_local6["ChatGlobal.inGameChatActive"], function ( f13_arg0 )
            f4_arg0:updateElementState( ChatClientInputTextBoxField, {
                  name = "model_validation",
                  menu = f4_arg0,
                  controller = f4_arg1,
                  modelValue = f13_arg0:get(),
                  modelName = "ChatGlobal.inGameChatActive"
            } )
      end, false )
      ChatClientInputTextBoxField:setRGB( 0.49, 0.49, 0.49 )
      self:addElement( ChatClientInputTextBoxField )
      self.ChatClientInputTextBoxField = ChatClientInputTextBoxField
      
      Border = CoD.Border.new( f4_arg0, f4_arg1, 0.34, 0.34, -0.5, 342.5, 0, 1, 0, 0 )
      Border:setRGB( ColorSet.Orange.r, ColorSet.Orange.g, ColorSet.Orange.b )
      Border:setAlpha( 0 )
      self:addElement( Border )
      self.Border = Border
      
      LineLeft = LUI.UIImage.new( 0, 1, 0, 0, 0, 0, -3, 3 )
      LineLeft:setAlpha( 0 )
      LineLeft:setImage( RegisterImage( @"hash_3563843FB53DC2A3" ) )
      LineLeft:setMaterial( LUI.UIImage.GetCachedMaterial( @"hash_54E6CE42E0799F57" ) )
      self:addElement( LineLeft )
      self.LineLeft = LineLeft
      
      local f4_local7 = channelText
      f4_local6 = channelText.subscribeToModel
      local f4_local8 = Engine[@"hash_4DF5CFBC1771947"]( f4_arg1 )
      f4_local6( f4_local7, f4_local8["ChatGlobal.Event"], channelText.__String_Reference_FullPath )
      self:mergeStateConditions( {
            {
                  stateName = "ChattingEmptyAsian",
                  condition = function ( menu, element, event )
                        local f14_local0 = ChatClientIsChattingButEmpty( f4_arg1 )
                        if f14_local0 then
                              f14_local0 = ChatClientOnlineChannelsAvailable( f4_arg1 )
                              if f14_local0 then
                                    f14_local0 = CoD.BaseUtility.IsCurrentLanguageAsian()
                              end
                        end
                        return f14_local0
                  end
            },
            {
                  stateName = "ChattingAsian",
                  condition = function ( menu, element, event )
                        return ChatClientIsChatting( f4_arg1 ) and CoD.BaseUtility.IsCurrentLanguageAsian()
                  end
            },
            {
                  stateName = "DefaultStateAsian",
                  condition = function ( menu, element, event )
                        return CoD.BaseUtility.IsCurrentLanguageAsian()
                  end
            },
            {
                  stateName = "ChattingEmpty",
                  condition = function ( menu, element, event )
                        return ChatClientIsChattingButEmpty( f4_arg1 ) and ChatClientOnlineChannelsAvailable( f4_arg1 )
                  end
            },
            {
                  stateName = "Chatting",
                  condition = function ( menu, element, event )
                        return ChatClientIsChatting( f4_arg1 )
                  end
            }
      } )
      f4_local7 = self
      f4_local6 = self.subscribeToModel
      f4_local8 = Engine[@"hash_4DF5CFBC1771947"]( f4_arg1 )
      f4_local6( f4_local7, f4_local8["ChatGlobal.fieldIsEmpty"], function ( f19_arg0 )
            f4_arg0:updateElementState( self, {
                  name = "model_validation",
                  menu = f4_arg0,
                  controller = f4_arg1,
                  modelValue = f19_arg0:get(),
                  modelName = "ChatGlobal.fieldIsEmpty"
            } )
      end, false )
      f4_local7 = self
      f4_local6 = self.subscribeToModel
      f4_local8 = Engine[@"hash_4DF5CFBC1771947"]( f4_arg1 )
      f4_local6( f4_local7, f4_local8["ChatGlobal.Event"], function ( f20_arg0 )
            f4_arg0:updateElementState( self, {
                  name = "model_validation",
                  menu = f4_arg0,
                  controller = f4_arg1,
                  modelValue = f20_arg0:get(),
                  modelName = "ChatGlobal.Event"
            } )
      end, false )
      ChatClientInputTextBoxField.id = "ChatClientInputTextBoxField"
      LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
      
      if PostLoadFunc then
            PostLoadFuncChatInput( self, f4_arg1, f4_arg0 )
      end
      
      return self
end

CoD.ChatClientInputTextBox.__resetProperties = function ( f21_arg0 )
      f21_arg0.tabText:completeAnimation()
      f21_arg0.ChatClientInputTextBoxField:completeAnimation()
      f21_arg0.tabText:setAlpha( 0 )
      f21_arg0.ChatClientInputTextBoxField:setTopBottom( 0.17, 0.87, 0, 0 )
      f21_arg0.ChatClientInputTextBoxField:setRGB( 0.49, 0.49, 0.49 )
end

CoD.ChatClientInputTextBox.__clipsPerState = {
      DefaultState = {
            DefaultClip = function ( f22_arg0, f22_arg1 )
                  f22_arg0:__resetProperties()
                  f22_arg0:setupElementClipCounter( 2 )
                  f22_arg0.tabText:completeAnimation()
                  f22_arg0.tabText:setAlpha( 0 )
                  f22_arg0.clipFinished( f22_arg0.tabText )
                  f22_arg0.ChatClientInputTextBoxField:completeAnimation()
                  f22_arg0.ChatClientInputTextBoxField:setRGB( 0.49, 0.49, 0.49 )
                  f22_arg0.clipFinished( f22_arg0.ChatClientInputTextBoxField )
            end
      },
      ChattingEmptyAsian = {
            DefaultClip = function ( f23_arg0, f23_arg1 )
                  f23_arg0:__resetProperties()
                  f23_arg0:setupElementClipCounter( 2 )
                  f23_arg0.tabText:completeAnimation()
                  f23_arg0.tabText:setAlpha( 1 )
                  f23_arg0.clipFinished( f23_arg0.tabText )
                  f23_arg0.ChatClientInputTextBoxField:completeAnimation()
                  f23_arg0.ChatClientInputTextBoxField:setTopBottom( 0, 1, 0, 0 )
                  f23_arg0.ChatClientInputTextBoxField:setRGB( 0.49, 0.49, 0.49 )
                  f23_arg0.clipFinished( f23_arg0.ChatClientInputTextBoxField )
            end
      },
      ChattingAsian = {
            DefaultClip = function ( f24_arg0, f24_arg1 )
                  f24_arg0:__resetProperties()
                  f24_arg0:setupElementClipCounter( 2 )
                  f24_arg0.tabText:completeAnimation()
                  f24_arg0.tabText:setAlpha( 0 )
                  f24_arg0.clipFinished( f24_arg0.tabText )
                  f24_arg0.ChatClientInputTextBoxField:completeAnimation()
                  f24_arg0.ChatClientInputTextBoxField:setTopBottom( 0, 1, 0, 0 )
                  f24_arg0.ChatClientInputTextBoxField:setRGB( 0.49, 0.49, 0.49 )
                  f24_arg0.clipFinished( f24_arg0.ChatClientInputTextBoxField )
            end
      },
      DefaultStateAsian = {
            DefaultClip = function ( f25_arg0, f25_arg1 )
                  f25_arg0:__resetProperties()
                  f25_arg0:setupElementClipCounter( 2 )
                  f25_arg0.tabText:completeAnimation()
                  f25_arg0.tabText:setAlpha( 0 )
                  f25_arg0.clipFinished( f25_arg0.tabText )
                  f25_arg0.ChatClientInputTextBoxField:completeAnimation()
                  f25_arg0.ChatClientInputTextBoxField:setTopBottom( 0, 1, 0, 0 )
                  f25_arg0.ChatClientInputTextBoxField:setRGB( 0.49, 0.49, 0.49 )
                  f25_arg0.clipFinished( f25_arg0.ChatClientInputTextBoxField )
            end
      },
      ChattingEmpty = {
            DefaultClip = function ( f26_arg0, f26_arg1 )
                  f26_arg0:__resetProperties()
                  f26_arg0:setupElementClipCounter( 2 )
                  f26_arg0.tabText:completeAnimation()
                  f26_arg0.tabText:setAlpha( 1 )
                  f26_arg0.clipFinished( f26_arg0.tabText )
                  f26_arg0.ChatClientInputTextBoxField:completeAnimation()
                  f26_arg0.ChatClientInputTextBoxField:setRGB( 1, 1, 1 )
                  f26_arg0.clipFinished( f26_arg0.ChatClientInputTextBoxField )
            end
      },
      Chatting = {
            DefaultClip = function ( f27_arg0, f27_arg1 )
                  f27_arg0:__resetProperties()
                  f27_arg0:setupElementClipCounter( 2 )
                  f27_arg0.tabText:completeAnimation()
                  f27_arg0.tabText:setAlpha( 0 )
                  f27_arg0.clipFinished( f27_arg0.tabText )
                  f27_arg0.ChatClientInputTextBoxField:completeAnimation()
                  f27_arg0.ChatClientInputTextBoxField:setRGB( 1, 1, 1 )
                  f27_arg0.clipFinished( f27_arg0.ChatClientInputTextBoxField )
            end
      }
}

CoD.ChatClientInputTextBox.__onClose = function ( f28_arg0 )
      f28_arg0.channelText:close()
      f28_arg0.ChatClientInputTextBoxField:close()
      f28_arg0.Border:close()
end

-- Chat Client Input Text
CoD.ChatClientInputTextBoxField = InheritFrom( LUI.UIElement )
CoD.ChatClientInputTextBoxField.__defaultWidth = 250
CoD.ChatClientInputTextBoxField.__defaultHeight = 25
CoD.ChatClientInputTextBoxField.new = function ( f1_arg0, f1_arg1, f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
      local self = LUI.UIElement.new( f1_arg2, f1_arg3, f1_arg4, f1_arg5, f1_arg6, f1_arg7, f1_arg8, f1_arg9 )
      self:setClass( CoD.ChatClientInputTextBoxField )
      self.id = "ChatClientInputTextBoxField"
      self.soundSet = "default"
      f1_arg0:addElementToPendingUpdateStateList( self )
      
      local TextBox = LUI.UIText.new( 0, 0, 0, 250, 0, 0, 0, 21 )
      TextBox:setTTF( "notosans_bold" )
      TextBox:setLetterSpacing( 1 )
      TextBox:setAlignment( Enum[@"hash_67A5123B654282D2"][@"hash_558C8A85F2048829"] )
      TextBox:subscribeToGlobalModel( f1_arg1, "ChatGlobal", "InputText", function ( model )
            local f2_local0 = model:get()
            if f2_local0 ~= nil then
                  TextBox:setText( f2_local0 )
            end
      end )
      self:addElement( TextBox )
      self.TextBox = TextBox
      
      self:mergeStateConditions( {
            {
                  stateName = "NoChannelsAvailable",
                  condition = function ( menu, element, event )
                        return not ChatClientInputEnabled( f1_arg1 )
                  end
            },
            {
                  stateName = "ChattingIngame",
                  condition = function ( menu, element, event )
                        return IsInGame() and ChatClientIsChatting( f1_arg1 )
                  end
            },
            {
                  stateName = "IngameChatActivated",
                  condition = function ( menu, element, event )
                        return IsInGame() and ChatClientInGameChatIsActive( f1_arg1 )
                  end
            },
            {
                  stateName = "DefaultStateIngame",
                  condition = function ( menu, element, event )
                        return IsInGame()
                  end
            },
            {
                  stateName = "Chatting",
                  condition = function ( menu, element, event )
                        return ChatClientIsChatting( f1_arg1 )
                  end
            },
            {
                  stateName = "Disabled",
                  condition = function ( menu, element, event )
                        return true
                  end
            }
      } )
      local f1_local2 = self
      local f1_local3 = self.subscribeToModel
      local f1_local4 = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
      f1_local3( f1_local2, f1_local4["ChatGlobal.Event"], function ( f9_arg0 )
            f1_arg0:updateElementState( self, {
                  name = "model_validation",
                  menu = f1_arg0,
                  controller = f1_arg1,
                  modelValue = f9_arg0:get(),
                  modelName = "ChatGlobal.Event"
            } )
      end, false )
      f1_local2 = self
      f1_local3 = self.subscribeToModel
      f1_local4 = Engine[@"hash_4DF5CFBC1771947"]( f1_arg1 )
      f1_local3( f1_local2, f1_local4["ChatGlobal.inGameChatActive"], function ( f10_arg0 )
            f1_arg0:updateElementState( self, {
                  name = "model_validation",
                  menu = f1_arg0,
                  controller = f1_arg1,
                  modelValue = f10_arg0:get(),
                  modelName = "ChatGlobal.inGameChatActive"
            } )
      end, false )
      LUI.OverrideFunction_CallOriginalSecond( self, "close", self.__onClose )
      
      if PostLoadFunc then
            PostLoadFunc( self, f1_arg1, f1_arg0 )
      end
      
      f1_local3 = self
      CoD.BaseUtility.SetUseStencil( self )
      CoD.PCUtility.SetHandleMouse( self, true )
      f1_local3 = TextBox
      CoD.PCUtility.SetupEditControlChat( self, f1_arg1, f1_arg0, "chatInputtext" )
      CoD.PCUtility.MakeEditControlChat( self, f1_arg1, 290, 60 )
      DisableModelStringReplacement( f1_local3 )
      return self
end

CoD.ChatClientInputTextBoxField.__resetProperties = function ( f11_arg0 )
      f11_arg0.TextBox:completeAnimation()
      f11_arg0.TextBox:setRGB( 1, 1, 1 )
      f11_arg0.TextBox:setAlpha( 1 )
end

CoD.ChatClientInputTextBoxField.__clipsPerState = {
      DefaultState = {
            DefaultClip = function ( f12_arg0, f12_arg1 )
                  f12_arg0:__resetProperties()
                  f12_arg0:setupElementClipCounter( 1 )
                  f12_arg0.TextBox:completeAnimation()
                  f12_arg0.TextBox:setAlpha( 0.75 )
                  f12_arg0.clipFinished( f12_arg0.TextBox )
            end,
            Focus = function ( f13_arg0, f13_arg1 )
                  f13_arg0:__resetProperties()
                  f13_arg0:setupElementClipCounter( 1 )
                  f13_arg0.TextBox:completeAnimation()
                  f13_arg0.TextBox:setRGB( ColorSet.Orange.r, ColorSet.Orange.g, ColorSet.Orange.b )
                  f13_arg0.clipFinished( f13_arg0.TextBox )
            end,
            InputFocus = function ( f14_arg0, f14_arg1 )
                  f14_arg0:__resetProperties()
                  f14_arg0:setupElementClipCounter( 1 )
                  f14_arg0.TextBox:completeAnimation()
                  f14_arg0.TextBox:setAlpha( 0.75 )
                  f14_arg0.clipFinished( f14_arg0.TextBox )
            end,
            Over = function ( f15_arg0, f15_arg1 )
                  f15_arg0:__resetProperties()
                  f15_arg0:setupElementClipCounter( 1 )
                  f15_arg0.TextBox:completeAnimation()
                  f15_arg0.TextBox:setAlpha( 0.75 )
                  f15_arg0.clipFinished( f15_arg0.TextBox )
            end
      },
      NoChannelsAvailable = {
            DefaultClip = function ( f16_arg0, f16_arg1 )
                  f16_arg0:__resetProperties()
                  f16_arg0:setupElementClipCounter( 1 )
                  f16_arg0.TextBox:completeAnimation()
                  f16_arg0.TextBox:setAlpha( 0.75 )
                  f16_arg0.clipFinished( f16_arg0.TextBox )
            end
      },
      ChattingIngame = {
            DefaultClip = function ( f17_arg0, f17_arg1 )
                  f17_arg0:__resetProperties()
                  f17_arg0:setupElementClipCounter( 1 )
                  f17_arg0.TextBox:completeAnimation()
                  f17_arg0.TextBox:setRGB( 1, 1, 1 )
                  f17_arg0.TextBox:setAlpha( 1 )
                  f17_arg0.clipFinished( f17_arg0.TextBox )
            end,
            InputFocus = function ( f18_arg0, f18_arg1 )
                  f18_arg0:__resetProperties()
                  f18_arg0:setupElementClipCounter( 1 )
                  f18_arg0.TextBox:completeAnimation()
                  f18_arg0.TextBox:setAlpha( 0.75 )
                  f18_arg0.clipFinished( f18_arg0.TextBox )
            end
      },
      IngameChatActivated = {
            DefaultClip = function ( f19_arg0, f19_arg1 )
                  f19_arg0:__resetProperties()
                  f19_arg0:setupElementClipCounter( 1 )
                  f19_arg0.TextBox:completeAnimation()
                  f19_arg0.TextBox:setRGB( 1, 1, 1 )
                  f19_arg0.TextBox:setAlpha( 1 )
                  f19_arg0.clipFinished( f19_arg0.TextBox )
            end,
            InputFocus = function ( f20_arg0, f20_arg1 )
                  f20_arg0:__resetProperties()
                  f20_arg0:setupElementClipCounter( 1 )
                  f20_arg0.TextBox:completeAnimation()
                  f20_arg0.TextBox:setAlpha( 0.75 )
                  f20_arg0.clipFinished( f20_arg0.TextBox )
            end,
            Focus = function ( f21_arg0, f21_arg1 )
                  f21_arg0:__resetProperties()
                  f21_arg0:setupElementClipCounter( 1 )
                  f21_arg0.TextBox:completeAnimation()
                  f21_arg0.TextBox:setAlpha( 0.75 )
                  f21_arg0.clipFinished( f21_arg0.TextBox )
            end
      },
      DefaultStateIngame = {
            DefaultClip = function ( f22_arg0, f22_arg1 )
                  f22_arg0:__resetProperties()
                  f22_arg0:setupElementClipCounter( 1 )
                  f22_arg0.TextBox:completeAnimation()
                  f22_arg0.TextBox:setAlpha( 0.75 )
                  f22_arg0.clipFinished( f22_arg0.TextBox )
            end,
            Focus = function ( f23_arg0, f23_arg1 )
                  f23_arg0:__resetProperties()
                  f23_arg0:setupElementClipCounter( 1 )
                  f23_arg0.TextBox:completeAnimation()
                  f23_arg0.TextBox:setRGB( ColorSet.Orange.r, ColorSet.Orange.g, ColorSet.Orange.b )
                  f23_arg0.clipFinished( f23_arg0.TextBox )
            end,
            InputFocus = function ( f24_arg0, f24_arg1 )
                  f24_arg0:__resetProperties()
                  f24_arg0:setupElementClipCounter( 1 )
                  f24_arg0.TextBox:completeAnimation()
                  f24_arg0.TextBox:setAlpha( 0.75 )
                  f24_arg0.clipFinished( f24_arg0.TextBox )
            end,
            Over = function ( f25_arg0, f25_arg1 )
                  f25_arg0:__resetProperties()
                  f25_arg0:setupElementClipCounter( 1 )
                  f25_arg0.TextBox:completeAnimation()
                  f25_arg0.TextBox:setAlpha( 0.75 )
                  f25_arg0.clipFinished( f25_arg0.TextBox )
            end
      },
      Chatting = {
            DefaultClip = function ( f26_arg0, f26_arg1 )
                  f26_arg0:__resetProperties()
                  f26_arg0:setupElementClipCounter( 0 )
            end
      },
      Disabled = {
            DefaultClip = function ( f27_arg0, f27_arg1 )
                  f27_arg0:__resetProperties()
                  f27_arg0:setupElementClipCounter( 1 )
                  f27_arg0.TextBox:completeAnimation()
                  f27_arg0.TextBox:setAlpha( 0.75 )
                  f27_arg0.clipFinished( f27_arg0.TextBox )
            end
      }
}

CoD.ChatClientInputTextBoxField.__onClose = function ( f28_arg0 )
      f28_arg0.TextBox:close()
end