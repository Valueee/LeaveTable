local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players: Players = game:GetService("Players")
local SoundService: SoundService = game:GetService('SoundService')
local UserInputService: UserInputService = game:GetService("UserInputService")

local ConvertForString: string = tostring

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Player: Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Character: Model = Player.Character or Player.CharacterAdded:Wait()

local LeaveTable = Knit.CreateController { Name = "LeaveTable" }

local TimeInit = os.clock()

LeaveTable.ModeDev = true
LeaveTable.TableConfig = nil
LeaveTable.Keys = { 
 }

function LeaveTable:KnitStart()
    
end


function LeaveTable:KnitInit()
    local ServerManager = Knit.GetService('ServerManager')
    Promise.new(function(resolve, reject, onCancel)
        
        local function _WaitForChild(instance, childName, timeout)
            return Promise.defer(function(resolve, reject)
              local child = instance:WaitForChild(childName, timeout)
          
              ;(child and resolve or reject)(child)
            end)
          end

        ServerManager.PlayLocalSound:Connect(function(SongName)
            local SongSearch: Sound = SoundService.Songs[SongName] or SoundService.Songs:WaitForChild(SongName)
            
            _WaitForChild(Player.PlayerGui, "SettingsMain", 1):andThen(function(_Instance)
                local GameFrame: Frame = _Instance.GameFrame
                GameFrame.Visible = true
                Promise.delay(SongSearch.TimeLength):andThen(function()
                    GameFrame.Visible = false
                end)
            end)

            SoundService:PlayLocalSound(SongSearch)
        end)

        -- [@Button 'leave' Visualize]:
        ServerManager.ClientEntered:Connect(function(Body, TableConfigUsing)

            local ButtonLeave: TextButton = Player.PlayerGui:WaitForChild("SettingsMain")['Leave/Out'].Button
            local Timer: number, ButtonMouseClicked: boolean = 0.2, true;
            local Signal_ = Signal.new()
            ButtonLeave.Visible = true -- [Visualize Button]
            local ConnectionWithButton = Signal_:Connect(function()
                local Connect_ = ButtonLeave.MouseButton1Click:Connect(function()
                    if (ButtonMouseClicked) then
                        ButtonMouseClicked = false

                        Character.PrimaryPart.CFrame = Body.Paths.Out.CFrame;
                        Character.PrimaryPart.Anchored = false;

                        if Player.Name == TableConfigUsing.Players.PlrL then
                            ServerManager.ClientExit:Fire('PlrL')
                            TableConfigUsing.Players['PlrL'] = nil
                        elseif Player.Name == TableConfigUsing.Players.PlrR then
                            ServerManager.ClientExit:Fire('PlrR')
                            TableConfigUsing.Players['PlrR'] = nil
                        end

                        if (LeaveTable.ModeDev) then print('[DevMode Print]: PlayerLeft -> ' .. ConvertForString(TableConfigUsing.Players.PlrL), '. PlayerRight -> ' .. ConvertForString(TableConfigUsing.Players.PlrR)) end

                    end
                end)
                ButtonLeave.MouseButton1Click:Wait()
                ButtonLeave.Visible = false -- [Des-Visualize Button]
                Promise.delay(Timer):andThen(function()
                    Connect_:Disconnect()
                    Signal_:Destroy() --[Destroy Data];
                    if (LeaveTable.ModeDev) then print('[DevMode Print]: ButtonLeave Connection destroyed!') end
                end)
                return Connect_
            end)
            Signal_:Fire()
        end)

        -- @Storage the Songs & Songs Buttons:
        Promise.try(function()
            ServerManager.MappingSongsConvertion:Connect(function(Map, Lenght, TableConfig)
                if (LeaveTable.ModeDev) then print('[Proccess-Game]: Mapping are loaded!') end
                for i = 1, (#Map) do
                    local ListSongs: ScrollingFrame = Player.PlayerGui:WaitForChild('SettingsMain')['SongsFrame'].ListSongs
                    local Song: string | any = Map[i]
                    local TextButton: TextButton = Instance.new("TextButton", ListSongs)
                    local UICorner: UICorner = Instance.new('UICorner')
                    UICorner.CornerRadius = UDim.new(0.09, 0);
                    UICorner.Parent = TextButton;
                    TextButton.Text = Song.song.song;
                    TextButton.Size = UDim2.new(0.6, 0, 0.1, 0);
                    TextButton.BackgroundColor3 = Color3.fromRGB(138, 138, 138);
                    TextButton.ZIndex = 10;
                    TextButton.MouseButton1Click:Connect(function()
                        ServerManager.VoteSong:Fire(Song.song.song)
                        if (LeaveTable.ModeDev) then print('[ModeDev Print]: You voted in a song!') end 
                    end)
                end
            end)
            ServerManager.MapSignalForConvertion:Fire(Player)
        end)

        --@Input Keys:
        UserInputService.InputBegan:Connect(function(Input: InputObject, gameProcessedEvent: boolean)
            if (Input.KeyCode) then
            end
        end)

        resolve(string.format(LeaveTable.Name .. ' Finished! [%f0.1s]', tostring(math.abs(TimeInit - os.clock()) * 1)))
    end):andThen(print)
end


return LeaveTable
