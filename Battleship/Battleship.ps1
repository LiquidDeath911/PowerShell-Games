Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

### Change this variable to be the path where the game file is saved
### Necessary for both players to have write access to this location
$networkPath = ""

if ( -not $networkPath ) {
    Write-Warning "You must add a network path on line 8 of this script for the game to work."
    exit
}

#Import-Module .\Battleship_Modules.psm1 -Force

function Set-KeyDown {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [PSCustomObject]$GameMaster,
        $Control
    )

    $Control.Add_KeyDown({
        if ( $_.KeyCode -eq "Return" ) {
            New-KeyDown -GameMaster $GameMaster -Key 0
        } elseif ( $_.KeyCode -eq "Space" ) {
            New-KeyDown -GameMaster $GameMaster -Key 1
        }
    })

    return
}

function Reset-Gamemaster {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.gameID = $null
    $GameMaster.thisPlayer = 0
    $GameMaster.otherPlayer = 0
    $GameMaster.fileName = ""
    $GameMaster.phase = 0
    $GameMaster.sendPhase = 0
    $GameMaster.turn = 0
    $GameMaster.needSend = $false
    $GameMaster.p1.shots = ""
    $GameMaster.p1.hits = ""
    $GameMaster.p1.misses = ""
    $GameMaster.p1.ships.lives = 0
    $GameMaster.p1.ships.s1.direction = 1
    $GameMaster.p1.ships.s1.column = 0
    $GameMaster.p1.ships.s1.row = 0
    $GameMaster.p1.ships.s2.direction = 1
    $GameMaster.p1.ships.s2.column = 0
    $GameMaster.p1.ships.s2.row = 0
    $GameMaster.p1.ships.s3.direction = 1
    $GameMaster.p1.ships.s3.column = 0
    $GameMaster.p1.ships.s3.row = 0
    $GameMaster.p1.ships.s4.direction = 1
    $GameMaster.p1.ships.s4.column = 0
    $GameMaster.p1.ships.s4.row = 0
    $GameMaster.p1.ships.s5.direction = 1
    $GameMaster.p1.ships.s5.column = 0
    $GameMaster.p1.ships.s5.row = 0
    $GameMaster.p2.shots = ""
    $GameMaster.p2.hits = ""
    $GameMaster.p2.misses = ""
    $GameMaster.p2.ships.lives = 0
    $GameMaster.p2.ships.s1.direction = 1
    $GameMaster.p2.ships.s1.column = 0
    $GameMaster.p2.ships.s1.row = 0
    $GameMaster.p2.ships.s2.direction = 1
    $GameMaster.p2.ships.s2.column = 0
    $GameMaster.p2.ships.s2.row = 0
    $GameMaster.p2.ships.s3.direction = 1
    $GameMaster.p2.ships.s3.column = 0
    $GameMaster.p2.ships.s3.row = 0
    $GameMaster.p2.ships.s4.direction = 1
    $GameMaster.p2.ships.s4.column = 0
    $GameMaster.p2.ships.s4.row = 0
    $GameMaster.p2.ships.s5.direction = 1
    $GameMaster.p2.ships.s5.column = 0
    $GameMaster.p2.ships.s5.row = 0
    $GameMaster.phaseData.one.currentShip = 0
    $GameMaster.phaseData.one.selectedTile.column = 0
    $GameMaster.phaseData.one.selectedTile.row = 0
    $GameMaster.phaseData.two.selectedTiles = ""
      
    return
}

function Set-AutoSize {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        $Control
    )

    foreach ($prop in $control.PSObject.Properties) {
        if ($prop.Name -eq "AutoSizeMode") {
            $Control.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
        } elseif ($prop.Name -eq "AutoSize") {
            $Control.AutoSize = $true
        }
    }

    if ( $Control.Controls.Count -gt 0 ) {
        foreach ( $subControl in $Control.Controls ) {
            if ( -not $subControl.Name ) {
                Set-AutoSize $subControl
            }
        }
    }

    return
}
function New-KeyDown {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Key
    )

    Switch ( $Key ) {
        0 {  
            Switch ( $GameMaster.phase ) {
                1 { New-EnterPhaseOne -GameMaster $GameMaster }
                2 { New-EnterPhaseTwo -GameMaster $GameMaster }
            }
        }
        1 { 
            Switch ( $GameMaster.phase ) {
                1 { New-SpacePhaseOne -GameMaster $GameMaster }
                2 { New-SpacePhaseTwo -GameMaster $GameMaster }
            }
        }
    }

    return
}

function Set-Colors {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
    
    $GameMaster.colors.shots.shot = [System.Drawing.Color]::Pink
    $GameMaster.colors.shots.hit = [System.Drawing.Color]::Red
    $GameMaster.colors.shots.miss = [System.Drawing.Color]::White
    $GameMaster.colors.tiles.header = [System.Drawing.Color]::LightGray
    $GameMaster.colors.tiles.selected = [System.Drawing.Color]::Orange
    $GameMaster.colors.water.p1 = [System.Drawing.Color]::LightBlue
    $GameMaster.colors.water.p2 = [System.Drawing.Color]::DarkBlue
    $GameMaster.colors.ships.s1 = [System.Drawing.Color]::ForestGreen
    $GameMaster.colors.ships.s2 = [System.Drawing.Color]::LawnGreen
    $GameMaster.colors.ships.s3 = [System.Drawing.Color]::MediumSeaGreen
    $GameMaster.colors.ships.s4 = [System.Drawing.Color]::LimeGreen
    $GameMaster.colors.ships.s5 = [System.Drawing.Color]::DarkOliveGreen

    return
}
function Out-Message {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [string]$Type,
        [string]$Message        
    )

    Write-Host "$( $Type ) | $( $Message )"

    return
}

function Get-UserInput {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [string]$Message
    )

    $formInput = [System.Windows.Forms.Form]::new()

    $inputPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
    $inputPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
    $inputPanel.Dock = [System.Windows.Forms.DockStyle]::Fill

    $inputLabel = [System.Windows.Forms.Label]::new()
    $inputLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $inputLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
    $inputLabel.Text = $Message

    $inputTextbox = [System.Windows.Forms.TextBox]::new()
    $inputTextbox.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $formInput.Controls.Add( $inputPanel ) | Out-Null
    $inputPanel.Controls.Add( $inputLabel ) | Out-Null
    $inputPanel.Controls.Add( $inputTextbox ) | Out-Null

    $buttonOkay = [System.Windows.Forms.Button]::new()
    $buttonOkay.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $buttonOkay.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $buttonOkay.Text = "OK"

    $buttonCancel = [System.Windows.Forms.Button]::new()
    $buttonCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $buttonCancel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $buttonCancel.Text = "Cancel"
    $formInput.AcceptButton = $buttonOkay
    $inputPanel.Controls.Add( $buttonOkay ) | Out-Null
    $formInput.CancelButton = $buttonCancel
    $inputPanel.Controls.Add( $buttonCancel ) | Out-Null
    Set-AutoSize -Control $formInput

    $formInput.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $result = $formInput.ShowDialog()
    $formInput.Focus() | Out-Null
    $inputTextbox.Focus() | Out-Null

    if ( $result -eq [System.Windows.Forms.DialogResult]::Cancel ) {
        $userInput = "cancel"
    } else {
        $userInput = $inputTextbox.Text
    }

    return $userInput
}

function New-Click {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name,
        [int]$Grid
    )

    Switch ( $GameMaster.phase ) {
        1 { New-ClickPhaseOne -GameMaster $GameMaster -Name $Name -Grid $Grid }
        2 { New-ClickPhaseTwo -GameMaster $GameMaster -Name $Name -Grid $Grid }
        3 { New-ClickPhaseThree -GameMaster $GameMaster -Name $Name -Grid $Grid }
        4 { New-ClickPhaseFour -GameMaster $GameMaster -Name $Name -Grid $Grid }
        5 { New-ClickPhaseFive -GameMaster $GameMaster -Name $Name -Grid $Grid }
    }

    return
}

function Reset-Tiles {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [Switch]$All,
        [Switch]$Selected
    )

    if ( $All ) {
        foreach ( $property in $GameMaster."p$( $Grid )".grid.psobject.properties ) {
            if ( $property.Value.BackColor -eq $GameMaster.colors.tiles.selected ) {
                $property.Value.BackColor = $GameMaster.colors.water."p$( $Grid )"
            } elseif ( $property.Value.BackColor -eq $GameMaster.colors.ships.s1 ) {
                $property.Value.BackColor = $GameMaster.colors.water."p$( $Grid )"
            } elseif ( $property.Value.BackColor -eq $GameMaster.colors.ships.s2 ) {
                $property.Value.BackColor = $GameMaster.colors.water."p$( $Grid )"
            } elseif ( $property.Value.BackColor -eq $GameMaster.colors.ships.s3 ) {
                $property.Value.BackColor = $GameMaster.colors.water."p$( $Grid )"
            } elseif ( $property.Value.BackColor -eq $GameMaster.colors.ships.s4 ) {
                $property.Value.BackColor = $GameMaster.colors.water."p$( $Grid )"
            } elseif ( $property.Value.BackColor -eq $GameMaster.colors.ships.s5 ) {
                $property.Value.BackColor = $GameMaster.colors.water."p$( $Grid )"
            } elseif ( $property.Value.BackColor -eq $GameMaster.colors.shots.shot ) {
                $property.Value.BackColor = $GameMaster.colors.water."p$( $Grid )"
            } elseif ( $property.Value.BackColor -eq $GameMaster.colors.shots.hit ) {
                $property.Value.BackColor = $GameMaster.colors.water."p$( $Grid )"
            } elseif ( $property.Value.BackColor -eq $GameMaster.colors.shots.miss ) {
                $property.Value.BackColor = $GameMaster.colors.water."p$( $Grid )"
            }
        }
    }

    if ( $Selected ) {
        foreach ( $property in $GameMaster."p$( $Grid )".grid.psobject.properties ) {
            if ( $property.Value.BackColor -eq $GameMaster.colors.tiles.selected ) {
                $property.Value.BackColor = $GameMaster.colors.water."p$( $Grid )"
                
            }
        }
    }

    return
}

function Set-Tiles {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [string]$FromType,
        [string]$From,
        [string]$ToType,
        [string]$To
    )

    foreach ( $property in $GameMaster."p$( $Grid )".grid.psobject.properties ) {
        if ( $property.Value.BackColor -eq $GameMaster.colors.$FromType.$From ) {
            $property.Value.BackColor = $GameMaster.colors.$ToType.$To
        }
    }

    return
}

function Restore-Tiles {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid
    )

    if ( $Grid -eq $GameMaster.thisPlayer ) {
        foreach ($num in 1..5 ) {
            if ( $GameMaster."p$( $Grid )".ships."s$( $num )".direction -eq 1 ) {
                foreach ( $x in $GameMaster."p$( $Grid )".ships."s$( $num )".column..( $GameMaster."p$( $Grid )".ships."s$( $num )".column + $GameMaster."p$( $Grid )".ships."s$( $num )".size - 1 )) {
                    $GameMaster."p$( $Grid )".grid."$( $x )_$( $GameMaster."p$( $Grid )".ships."s$( $num )".row )".BackColor = $GameMaster.colors.ships."s$( $num )"
                }
            } elseif ( $GameMaster."p$( $Grid )".ships."s$( $num )".direction -eq 2 ) {
                foreach ( $x in $GameMaster."p$( $Grid )".ships."s$( $num )".row..( $GameMaster."p$( $Grid )".ships."s$( $num )".row + $GameMaster."p$( $Grid )".ships."s$( $num )".size - 1 )) {
                    $GameMaster."p$( $Grid )".grid."$( $GameMaster."p$( $Grid )".ships."s$( $num )".column )_$( $x )".BackColor = $GameMaster.colors.ships."s$( $num )"
                }
            }
        }

        $shots = ($GameMaster."p$( $Grid )".shots).Split( ";" )
        foreach ( $shot in $shots ) {
            if ( $shot.Length -eq 0 ) {
                continue
            }
            $split = $shot.Split( "_" )
            $column = $split[0]
            $row = $split[1]
            if (( $column -eq 0 ) -or ( $row -eq 0 )) {
                continue
            }
            $GameMaster."p$( $GameMaster.otherPlayer )".grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.shots.shot
        }
    }

    $hits = ($GameMaster."p$( $Grid )".hits).Split( ";" )
    foreach ( $hit in $hits ) {
        if ( $hit.Length -eq 0 ) {
            continue
        }

        $split = $hit.Split( "_" )
        $column = $split[0]
        $row = $split[1]

        if (( $column -eq 0 ) -or ( $row -eq 0 )) {
            continue
        }

        $GameMaster."p$( $Grid )".grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.shots.hit
    }

    $misses = ($GameMaster."p$( $Grid )".misses).Split( ";" )
    foreach ( $miss in $misses ) {

        if ( $miss.Length -eq 0 ) {
            continue
        }

        $split = $miss.Split( "_" )
        $column = $split[0]
        $row = $split[1]

        if (( $column -eq 0 ) -or ( $row -eq 0 )) {
            continue
        }

        $GameMaster."p$( $Grid )".grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.shots.miss
    }

    return
}

function Find-Overlap {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [int]$Column,
        [int]$Row
    )

    if ( $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction -eq 1 ) {
        foreach ( $x in $Column..( $Column + $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".size - 1 )) {
            foreach ( $num in 1..5 ) {
                if ( $GameMaster."p$( $Grid )".grid."$( $x )_$( $Row )".BackColor -eq $GameMaster.colors.ships."s$( $num )" ) {
                    Out-Message -Type "Error" -Message "The $( $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".name ) would overlap with another ship."
                    return $true
                }
            }
        }
    } elseif ( $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction -eq 2 ) {
        foreach ( $x in $Row..( $Row + $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".size - 1 )) {
            foreach ( $num in 1..5 ) {
                if ( $GameMaster."p$( $Grid )".grid."$( $Column )_$( $x )".BackColor -eq $GameMaster.colors.ships."s$( $num )" ) {
                    Out-Message -Type "Error" -Message "The $( $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".name ) would overlap with another ship."
                    return $true
                }
            }
        }
    }

    return $false
}

function New-Battleship {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Username
    )

    Reset-GameMaster -GameMaster $GameMaster

    if ( -not ( Test-Path -Path "$( $GameMaster.localPath )" )) {
        New-Item -Path $GameMaster.localPath -ItemType Directory -Force
    }

    while ($true) {
        $GameMaster.p2.label.Text = Get-UserInput -Message "Please enter your oppenent's AD sAMAccountName"
        try {
            $GameMaster.p2.label.Text = ( Get-ADUser -Identity "$( $GameMaster.p2.label.Text )" -ErrorAction Stop |
                Select-Object -ExpandProperty sAMAccountName )
            break
        } catch {
            if ( $GameMaster.p2.label.Text -eq "cancel" ) {
                Out-Message -Type "Notice" -Message "New Game cancelled"
                return
            }
            Out-Message -Type "Error" -Message "Invalid sAMAccountName"
        }
    }

    $GameMaster.gameID = "$( [System.Guid]::NewGuid())".Substring( 32 )
    $GameMaster.p1.label.Text = $env:USERNAME
    $GameMaster.p1.ships.lives = 17
    $GameMaster.p2.ships.lives = 17
    $GameMaster.thisPlayer = 1
    $GameMaster.otherPlayer = 2
    $GameMaster.fileName = "$( $GameMaster.p1.label.Text )-$( $GameMaster.p2.label.Text )-$( $GameMaster.gameID ).clixml"
    $result = Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.fileName )"

    while ( $result ) {
        $GameMaster.fileName = "$( $GameMaster.p1.label.Text )-$( $GameMaster.p2.label.Text )-$( $GameMaster.gameID ).clixml"
        $result = Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.fileName )"
    }

    $GameMaster.phase = 1
    $GameMaster.turn = 1

    Set-AutoSize -Control $GameMaster.p1.label
    Set-AutoSize -Control $GameMaster.p2.label

    Reset-Tiles -GameMaster $GameMaster -Grid 1 -All
    Reset-Tiles -GameMaster $GameMaster -Grid 2 -All

    Start-Phase -GameMaster $GameMaster

    return
}

function Open-Battleship {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [switch]$Refresh
    )

    if ( -not ( Test-Path -Path "$( $GameMaster.localPath )" )) {
        New-Item -Path $GameMaster.localPath -ItemType Directory -Force
    }

    if ( -not $Refresh ) {
        $filePicker = [System.Windows.Forms.OpenFileDialog]::new()
        $filePicker.InitialDirectory = "$( $GameMaster.networkPath )"
        $filePicker.Filter = "clixml files (*.clixml)|*.clixml"
        $filePicker.ShowDialog() | Out-Null

        if ( $filePicker.SafeFileName.Length -eq 0 ) {
            return
        }

        $split = $filePicker.SafeFileName.Split( "-" )
        $playerOne = $split[0]
        $playerTwo = $split[1]
        $GameMaster.filename = $filePicker.SafeFileName
        $GameMaster.p1.label.text = $playerOne
        $GameMaster.p2.label.text = $playerTwo
    } else {
        $playerOne = $GameMaster.p1.label.text
        $playerTwo = $GameMaster.p2.label.text
        $temp = $GameMaster.fileName
        Reset-Gamemaster -GameMaster $GameMaster
        $GameMaster.fileName = $temp
    }

    $xmlNetwork = Get-Content -Path "$( $GameMaster.networkPath )\$( $GameMaster.filename )"
    $xmlNetwork = ConvertFrom-BattleshipEncode -Data $xmlNetwork
    $xmlNetwork | Set-Content -Path "$( $GameMaster.localPath )\$( $GameMaster.filename )"
    $xmlNetwork = Import-Clixml -Path "$( $GameMaster.localPath )\$( $GameMaster.filename )"

    if ( $env:USERNAME -eq $playerOne ) {
        $GameMaster.thisPlayer = 1
        $GameMaster.otherPlayer = 2
    } elseif ( $env:USERNAME -eq $playerTwo ) {
        $GameMaster.thisPlayer = 2
        $GameMaster.otherPlayer = 1
    } else {
        Out-Message -Type "Error" -Message "The file you chose is Not a game you are a player in."
        return
    }

    $GameMaster.turn = $xmlNetwork.turn
    $GameMaster.phase = $xmlNetwork.sendPhase
    $GameMaster.p1.shots = $xmlNetwork.p1.shots
    $GameMaster.p1.hits = $xmlNetwork.p1.hits
    $GameMaster.p1.misses = $xmlNetwork.p1.misses
    $GameMaster.p1.ships.lives = $xmlNetwork.p1.ships.lives
    $GameMaster.p1.ships.s1.direction = $xmlNetwork.p1.ships.s1.direction
    $GameMaster.p1.ships.s1.column = $xmlNetwork.p1.ships.s1.column
    $GameMaster.p1.ships.s1.row = $xmlNetwork.p1.ships.s1.row
    $GameMaster.p1.ships.s2.direction = $xmlNetwork.p1.ships.s2.direction
    $GameMaster.p1.ships.s2.column = $xmlNetwork.p1.ships.s2.column
    $GameMaster.p1.ships.s2.row = $xmlNetwork.p1.ships.s2.row
    $GameMaster.p1.ships.s3.direction = $xmlNetwork.p1.ships.s3.direction
    $GameMaster.p1.ships.s3.column = $xmlNetwork.p1.ships.s3.column
    $GameMaster.p1.ships.s3.row = $xmlNetwork.p1.ships.s3.row
    $GameMaster.p1.ships.s4.direction = $xmlNetwork.p1.ships.s4.direction
    $GameMaster.p1.ships.s4.column = $xmlNetwork.p1.ships.s4.column
    $GameMaster.p1.ships.s4.row = $xmlNetwork.p1.ships.s4.row
    $GameMaster.p1.ships.s5.direction = $xmlNetwork.p1.ships.s5.direction
    $GameMaster.p1.ships.s5.column = $xmlNetwork.p1.ships.s5.column
    $GameMaster.p1.ships.s5.row = $xmlNetwork.p1.ships.s5.row
    $GameMaster.p2.shots = $xmlNetwork.p2.shots
    $GameMaster.p2.hits = $xmlNetwork.p2.hits
    $GameMaster.p2.misses = $xmlNetwork.p2.misses
    $GameMaster.p2.ships.lives = $xmlNetwork.p2.ships.lives
    $GameMaster.p2.ships.s1.direction = $xmlNetwork.p2.ships.s1.direction
    $GameMaster.p2.ships.s1.column = $xmlNetwork.p2.ships.s1.column
    $GameMaster.p2.ships.s1.row = $xmlNetwork.p2.ships.s1.row
    $GameMaster.p2.ships.s2.direction = $xmlNetwork.p2.ships.s2.direction
    $GameMaster.p2.ships.s2.column = $xmlNetwork.p2.ships.s2.column
    $GameMaster.p2.ships.s2.row = $xmlNetwork.p2.ships.s2.row
    $GameMaster.p2.ships.s3.direction = $xmlNetwork.p2.ships.s3.direction
    $GameMaster.p2.ships.s3.column = $xmlNetwork.p2.ships.s3.column
    $GameMaster.p2.ships.s3.row = $xmlNetwork.p2.ships.s3.row
    $GameMaster.p2.ships.s4.direction = $xmlNetwork.p2.ships.s4.direction
    $GameMaster.p2.ships.s4.column = $xmlNetwork.p2.ships.s4.column
    $GameMaster.p2.ships.s4.row = $xmlNetwork.p2.ships.s4.row
    $GameMaster.p2.ships.s5.direction = $xmlNetwork.p2.ships.s5.direction
    $GameMaster.p2.ships.s5.column = $xmlNetwork.p2.ships.s5.column
    $GameMaster.p2.ships.s5.row = $xmlNetwork.p2.ships.s5.row   
    
    Reset-Tiles -GameMaster $GameMaster -Grid 1 -All
    Reset-Tiles -GameMaster $GameMaster -Grid 2 -All

    Restore-Tiles -GameMaster $GameMaster -Grid $GameMaster.thisPlayer
    Restore-Tiles -GameMaster $GameMaster -Grid $GameMaster.otherPlayer

    if ( $GameMaster.turn -ne $GameMaster.thisPlayer ) {
        $GameMaster.phase = 4
        $GameMaster.needSend = $false
    }

    if ( Test-Path -Path "$( $GameMaster.localPath )\$( $GameMaster.fileName )" ) {
        Remove-Item -Path "$( $GameMaster.localPath )\$( $GameMaster.fileName )" -Force
    }

    Start-Phase -GameMaster $GameMaster

    return
}

function Send-Battleship {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( -not ( $GameMaster.needSend )) {
        return
    }

    $GameMaster.needSend = $false
    $outputObject = [PSCustomObject]@{
        phase = $GameMaster.phase
        sendPhase = $GameMaster.sendPhase
        turn = $GameMaster.otherPlayer
        p1 = [PSCustomObject]@{
            shots = $GameMaster.p1.shots
            hits = $GameMaster.p1.hits
            misses = $GameMaster.p1.misses
            ships = [PSCustomObject]@{
                lives = $GameMaster.p1.ships.lives
                s1 = [PSCustomObject]@{
                    direction = $GameMaster.p1.ships.s1.direction
                    column = $GameMaster.p1.ships.s1.column
                    row = $GameMaster.p1.ships.s1.row
                }
                s2 = [PSCustomObject]@{
                    direction = $GameMaster.p1.ships.s2.direction
                    column = $GameMaster.p1.ships.s2.column
                    row = $GameMaster.p1.ships.s2.row
                }
                s3 = [PSCustomObject]@{
                    direction = $GameMaster.p1.ships.s3.direction
                    column = $GameMaster.p1.ships.s3.column
                    row = $GameMaster.p1.ships.s3.row
                }
                s4 = [PSCustomObject]@{
                    direction = $GameMaster.p1.ships.s4.direction
                    column = $GameMaster.p1.ships.s4.column
                    row = $GameMaster.p1.ships.s4.row
                }
                s5 = [PSCustomObject]@{
                    direction = $GameMaster.p1.ships.s5.direction
                    column = $GameMaster.p1.ships.s5.column
                    row = $GameMaster.p1.ships.s5.row
                }
            }
        }
        p2 = [PSCustomObject]@{
            shots = $GameMaster.p2.shots
            hits = $GameMaster.p2.hits
            misses = $GameMaster.p2.misses
            ships = [PSCustomObject]@{
                lives = $GameMaster.p2.ships.lives
                s1 = [PSCustomObject]@{
                    direction = $GameMaster.p2.ships.s1.direction
                    column = $GameMaster.p2.ships.s1.column
                    row = $GameMaster.p2.ships.s1.row
                }
                s2 = [PSCustomObject]@{
                    direction = $GameMaster.p2.ships.s2.direction
                    column = $GameMaster.p2.ships.s2.column
                    row = $GameMaster.p2.ships.s2.row
                }
                s3 = [PSCustomObject]@{
                    direction = $GameMaster.p2.ships.s3.direction
                    column = $GameMaster.p2.ships.s3.column
                    row = $GameMaster.p2.ships.s3.row
                }
                s4 = [PSCustomObject]@{
                    direction = $GameMaster.p2.ships.s4.direction
                    column = $GameMaster.p2.ships.s4.column
                    row = $GameMaster.p2.ships.s4.row
                }
                s5 = [PSCustomObject]@{
                    direction = $GameMaster.p2.ships.s5.direction
                    column = $GameMaster.p2.ships.s5.column
                    row = $GameMaster.p2.ships.s5.row
                }
            }
        }
    }
    
    $outputObject | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.filename )" -Force

    Start-Sleep -Seconds 2

    $xml = Get-Content -Path "$( $GameMaster.networkPath )\$( $GameMaster.filename )"
    $xml = ConvertTo-BattleshipEncode -Data $xml

    Start-Sleep -Seconds 2

    $xml | Set-Content -Path "$( $GameMaster.networkPath )\$( $GameMaster.filename )" -Force

    return
}

function Close-Battleship {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
    
    Send-Battleship -GameMaster $GameMaster

    return
}

function ConvertTo-BattleshipEncode {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        $Data
    )

    $output = [System.Collections.ArrayList]::new()

    foreach ( $line in $Data ) {
        if (( $line -match "=" ) -and ( $line -match '/' )) {
            $newLine = ""
            foreach ( $char in $line.ToCharArray() ) {
                $newLine += [char]( [int]$char + 2 )
            }
            $newLine = "~xyz~" + $newLine
        } else {
            $newLine = $line
        }
        $output.Add( $newLine ) | Out-Null
    }

    return $output
}

function ConvertFrom-BattleshipEncode {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        $Data
    )

    $output = [System.Collections.ArrayList]::new()
    foreach ( $line in $Data ) {
        if ( $line -match "~xyz~" ) {
            $tempLine = $line.Substring( 5 )
            $newLine = ""
            foreach ( $char in $tempLine.ToCharArray() ) {
                $newLine += [char]( [int]$char - 2 )
            }
        } else {
            $newLine = $line
        }
        $output.Add( $newLine ) | Out-Null
    }

    return $output
}

function Start-Phase {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.refreshTimer.Stop()
    Switch ( $GameMaster.phase ) {
        1 { Start-PhaseOne -GameMaster $GameMaster }
        2 { Start-PhaseTwo -GameMaster $GameMaster }
        3 { Start-PhaseThree -GameMaster $GameMaster }
        4 { Start-PhaseFour -GameMaster $GameMaster }
        5 { Start-PhaseFive -GameMaster $GameMaster }
    }
    return
}

#### Phase One #### Place ships

function Start-PhaseOne {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.phaseData.one.currentShip = 1
    $shipName = $GameMaster."p$( $GameMaster.thisPlayer )".ships."s$( $GameMaster.phaseData.one.currentShip )".name

    $GameMaster.infoLabel.Text = "Click a cell on your grid to place the $( $shipName ). Use 'Space' to rotate. Press 'Enter' to confirm location."
    Set-AutoSize -Control $GameMaster.infoLabel
    
    return
}

function New-ClickPhaseOne {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name,
        [int]$Grid
    )

    $split = $Name.Split( "_" )
    $column = ( $split[0] / 1 )
    $row = ( $split[1] / 1 )

    if ( $Grid -ne $GameMaster.thisPlayer ) {
        return
    }

    if ( $GameMaster.phaseData.one.currentShip -gt 1 ) {
        $result = Find-Overlap -GameMaster $GameMaster -Grid $GameMaster.thisPlayer -Column $column -Row $row
        if ( $result ) {
            return
        }
    }

    $shipName = $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".name
    $shipSize = $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".size

    if ( $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction -eq 1 ) {
        if (( $column + $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".size - 1 ) -gt 10 ) {
            Out-Message -Type "Error" -Message "The $( $shipName ) is $( $shipSize ) tiles long and would go off the right edge."
            return
        } else {
            Reset-Tiles -GameMaster $GameMaster -Grid $GameMaster.thisPlayer -Selected
            $GameMaster.phaseData.one.selectedTile.column = $column
            $GameMaster.phaseData.one.selectedTile.row = $row
            foreach ( $x in $column..( $column + $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".size - 1 )) {
                $GameMaster."p$( $Grid )".grid."$( $x )_$( $row )".BackColor = $GameMaster.colors.tiles.selected
            }
            $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction = 1
            $GameMaster.phaseData.one.currentDirection = 1
            $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".column = $column
            $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".row = $row
        }
    } elseif ( $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction -eq 2 ) {
        if (( $row + $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".size - 1 ) -gt 10 ) {
            Out-Message -Type "Error" -Message "The $( $shipName ) is $( $shipSize ) tiles long and would go off the bottom edge."
            return
        } else {
            Reset-Tiles -GameMaster $GameMaster -Grid $GameMaster.thisPlayer -Selected
            $GameMaster.phaseData.one.selectedTile.column = $column
            $GameMaster.phaseData.one.selectedTile.row = $row
            foreach ( $x in $row..( $row + $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".size - 1 )) {
                $GameMaster."p$( $Grid )".grid."$( $column )_$( $x )".BackColor = $GameMaster.colors.tiles.selected
            }
            $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction = 2
            $GameMaster.phaseData.one.currentDirection = 2
            $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".column = $column
            $GameMaster."p$( $Grid )".ships."s$( $GameMaster.phaseData.one.currentShip )".row = $row
        }
    }

    return
}

function New-EnterPhaseOne {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.phaseData.one.selectedTile.column -eq 0 ) {
        return
    }

    $shipName = $GameMaster."p$( $GameMaster.thisPlayer )".ships."$( $GameMaster.phaseData.one.currentShip )".name

    Set-Tiles -GameMaster $GameMaster -Grid $GameMaster.thisPlayer -FromType "tiles" -From "selected" -ToType "ships" -To "s$( $GameMaster.phaseData.one.currentShip )"
    $GameMaster."p$( $GameMaster.thisPlayer )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction = $GameMaster.phaseData.one.currentDirection

    if ( $GameMaster.phaseData.one.currentShip -eq 5 ) {
        $GameMaster.phase = 4
        if ( $GameMaster.thisPlayer -eq 1 ) {
            $GameMaster.sendPhase = 1
        } elseif ( $GameMaster.thisPlayer -eq 2 ) {
            $GameMaster.sendPhase = 2
        }
        $GameMaster.needSend = $true
        Start-Phase -GameMaster $GameMaster
    } else {
        $GameMaster.phaseData.one.currentShip++
        $GameMaster.phaseData.one.selectedTile.column = 0
        $GameMaster.phaseData.one.selectedTile.row = 0
        $GameMaster.infoLabel.Text = "Click a cell on your grid to place the $( $shipName ). Use 'Space' to rotate. Press 'Enter' to confirm location."
    }

    return
}

function New-SpacePhaseOne {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster."p$( $GameMaster.thisPlayer )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction -eq 1 ) {
        $GameMaster."p$( $GameMaster.thisPlayer )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction = 2
    } elseif ( $GameMaster."p$( $GameMaster.thisPlayer )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction -eq 2) {
        $GameMaster."p$( $GameMaster.thisPlayer )".ships."s$( $GameMaster.phaseData.one.currentShip )".direction = 1
    } else {
        
    }

    return
}

#### Phase Two #### Choose shots to send to opponent

function Start-PhaseTwo {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.infoLabel.Text = "Click 3 total cells on your opponent's grid to place your shots. Press 'Space' to clear selected cells. Press 'Enter' to submit the shots."
    $GameMaster.phaseData.two.selectedTiles = ""

    return
}

function New-ClickPhaseTwo {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name,
        [int]$Grid
    )

    $split = $Name.Split( "_" )
    $column = ( $split[0] / 1 )
    $row = ( $split[1] / 1 )

    if ( $Grid -eq $GameMaster.thisPlayer ) {
        return
    }

    if ( $GameMaster."p$( $Grid )".grid."$( $column )_$( $row )".BackColor -ne $GameMaster.colors.water."p$( $GameMaster.otherPlayer )" ) {
        return
    }

    $shotCount = ( $GameMaster.phaseData.two.selectedTiles.Split( ";" )).Count
    if ( $shotCount -eq 4 ) {
        Out-Message -Type "Notice" -Message "You have already placed 3 shots."
        return
    }

    $GameMaster."p$( $Grid )".grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.tiles.selected
    $GameMaster.phaseData.two.selectedTiles += ";$( $column )_$( $row )"

    return
}

function New-EnterPhaseTwo {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $shotCount = ( $GameMaster.phaseData.two.selectedTiles.Split( ";" )).Count -ne 4 ) {
        return
    }

    $shots = $GameMaster.phaseData.two.selectedTiles.Split( ";" )
    foreach ( $shot in $shots ) {
        if ( $shot.Length -eq 0 ) {
            continue
        }
        $split = $shot.Split( "_" )
        $column = $split[0]
        $row = $split[1]
        $GameMaster."p$( $GameMaster.otherPlayer )".grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.shots.shot 
    }
    
    $GameMaster."p$( $GameMaster.thisPlayer )".shots = $GameMaster.phaseData.two.selectedTiles.Substring( 1 )
    $GameMaster.phase = 4
    $GameMaster.sendPhase = 3
    $GameMaster.needSend = $true

    Start-Phase -GameMaster $GameMaster

    return
}

function New-SpacePhaseTwo {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.phaseData.two.selectedTiles = ""
    Set-Tiles -GameMaster $GameMaster -Grid $GameMaster.otherPlayer -FromType "tiles" -From "selected" -ToType "water" -To "p$( $GameMaster.otherPlayer )"

    return
}

#### Phase Three #### Process shots taken by opponent

function Start-PhaseThree {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $shots = $GameMaster."p$( $GameMaster.otherPlayer )".shots.Split( ";" )

    foreach ( $shot in $shots ) {
        $split = $shot.Split( "_" )
        $column = $split[0]
        $row = $split[1]

        if (( $column -eq 0 ) -or ( $row -eq 0 )) {
            continue
        }

        $result = $false
        foreach ( $num in 1..5 ) {
            if ( $GameMaster."p$( $GameMaster.thisPlayer )".grid."$( $column )_$( $row )".BackColor -eq $GameMaster.colors.ships."s$( $num )" ) {
                $GameMaster."p$( $GameMaster.thisPlayer )".grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.shots.hit
                $GameMaster."p$( $GameMaster.thisPlayer )".hits += ";$( $column )_$( $row )"
                $GameMaster."p$( $GameMaster.thisPlayer )".ships.lives--
                $result = $true
            }
        }

        if ( -not ( $result )) {
            $GameMaster."p$( $GameMaster.thisPlayer )".misses += ";$( $column )_$( $row )"
            $GameMaster."p$( $GameMaster.thisPlayer )".grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.shots.miss
        }
    }

    if ( $GameMaster."p$( $GameMaster.thisPlayer )".ships.lives -eq 0 ) {
        $GameMaster.phase = 5
        Start-Phase -GameMaster $GameMaster
    } else {
        $GameMaster.phase = 2
    }

    Start-Phase -GameMaster $GameMaster

    return
}

function New-ClickPhaseThree {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name,
        [int]$Grid
    )
    
    return
}

#### Phase Four #### Send data to opponent and wait for them

function Start-PhaseFour {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
    
    $GameMaster.infoLabel.Text = "Saving game data to file..."
    Send-Battleship -GameMaster $GameMaster
    $GameMaster.infoLabel.Text = "It is your opponent's turn."

    $GameMaster.refreshTimer.Start()

    if ( $GameMaster."p$( $GameMaster.thisPlayer )".ships.lives -eq 0 ) {
        $GameMaster.infoLabel.Text = "You almost had them! Better luck next time."
    }

    return
}

function New-ClickPhaseFour {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name,
        [int]$Grid
    )
    
    return
}

#### Phase Five #### A player won

function Start-PhaseFive {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster."p$( $GameMaster.thisPlayer )".ships.lives -gt 0 ) {
        $GameMaster.infoLabel.Text = "Congratulations, you won!" 
        Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.fileName )" -Force
    } else {
        $GameMaster.phase = 4
        $GameMaster.sendPhase = 5
        Start-Phase -GameMaster $GameMaster
    }

    return
}

function New-ClickPhaseFive {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name,
        [int]$Grid
    )
    
    return
}

#### End Phases ####

$gameMaster = [PSCustomObject]@{
    gameID = $null
    thisPlayer = 0
    otherPlayer = 0
    fileName = ""
    localPath = "$( $env:APPDATA )\Battleship"
    networkPath = "$( $networkPath )"
    phase = 0
    sendPhase = 0
    turn = 0
    needSend = $false
    infoLabel = [System.Windows.Forms.Label]::new()
    refreshTimer = [System.Timers.Timer]::new()
    p1 = [PSCustomObject]@{
        grid = [PSCustomObject]@{}
        label = [System.Windows.Forms.Label]::new()
        shots = ""
        hits = ""
        misses = ""
        ships = [PSCustomObject]@{
            lives = 0
            s1 = [PSCustomObject]@{
                name = "Carrier"
                size = 5
                direction = 1
                column = 0
                row = 0
            }
            s2 = [PSCustomObject]@{
                name = "Battleship"
                size = 4
                direction = 1
                column = 0
                row = 0
            }
            s3 = [PSCustomObject]@{
                name = "Destroyer"
                size = 3
                direction = 1
                column = 0
                row = 0
            }
            s4 = [PSCustomObject]@{
                name = "Submarine"
                size = 3
                direction = 1
                column = 0
                row = 0
            }
            s5 = [PSCustomObject]@{
                name = "Scout"
                size = 2
                direction = 1
                column = 0
                row = 0
            }
        }
    }
    p2 = [PSCustomObject]@{
        grid = [PSCustomObject]@{}
        label = [System.Windows.Forms.Label]::new()
        shots = ""
        hits = ""
        misses = ""
        ships = [PSCustomObject]@{
            lives = 0
            s1 = [PSCustomObject]@{
                name = "Carrier"
                size = 5
                direction = 1
                column = 0
                row = 0
            }
            s2 = [PSCustomObject]@{
                name = "Battleship"
                size = 4
                direction = 1
                column = 0
                row = 0
            }
            s3 = [PSCustomObject]@{
                name = "Destroyer"
                size = 3
                direction = 1
                column = 0
                row = 0
            }
            s4 = [PSCustomObject]@{
                name = "Submarine"
                size = 3
                direction = 1
                column = 0
                row = 0
            }
            s5 = [PSCustomObject]@{
                name = "Scout"
                size = 2
                direction = 1
                column = 0
                row = 0
            }
        }
    }
    phaseData = [PSCustomObject]@{
        one = [PSCustomObject]@{
            currentShip = 0
            currentDirection = 1
            selectedTile = [PSCustomObject]@{
                column = 0
                row = 0
            }
        }
        two = [PSCustomObject]@{
            selectedTiles = ""
        }
    }
    colors = [PSCustomObject]@{
        shots = [PSCustomObject]@{
            shot = $null
            hit = $null
            miss = $null
        }
        tiles = [PSCustomObject]@{
            header = $null
            selected = $null
        }
        water = [PSCustomObject]@{
            p1 = $null
            p2 = $null
        }
        ships = [PSCustomObject]@{
            s1 = $null
            s2 = $null
            s3 = $null
            s4 = $null
            s5 = $null
        }
    }
}

$form = [System.Windows.Forms.Form]::new()
$form.Add_FormClosing({
    Close-Battleship -GameMaster $gameMaster
})

$toolStrip = [System.Windows.Forms.ToolStrip]::new()
$toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
$toolStrip.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden

$mainPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$mainPanel.Padding = [System.Windows.Forms.Padding]::new( 5, $toolStrip.Height, 5, 5 )
$mainPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add( $toolStrip ) | Out-Null
$form.Controls.Add( $mainPanel ) | Out-Null

$newGameButton = [System.Windows.Forms.ToolStripButton]::new()
$newGameButton.Text = "New Game"
$newGameButton.Padding = [System.Windows.Forms.Padding]::new( 0, 0, 5, 0 )
$newGameButton.Add_Click({
    New-Battleship -GameMaster $gameMaster
})
$toolStrip.Items.Add( $newGameButton ) | Out-Null

$openGameButton = [System.Windows.Forms.ToolStripButton]::new()
$openGameButton.Text = "Open Game"
$openGameButton.Padding = [System.Windows.Forms.Padding]::new( 0, 0, 5, 0 )
$openGameButton.Add_Click({
    Open-Battleship -GameMaster $gameMaster
})
$toolStrip.Items.Add( $openGameButton ) | Out-Null

$outerPanelPlayerOneGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$middlePanelPlayerOneGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$middlePanelPlayerOneGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$innerPanelPlayerOneGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelPlayerOneGrid.RowCount = 11
$innerPanelPlayerOneGrid.ColumnCount = 11
$innerPanelPlayerOneGrid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$gameMaster.p1.label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.p1.label.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.p1.label.Text = "Player One"
$outerPanelPlayerOneGrid.Controls.Add( $middlePanelPlayerOneGrid ) | Out-Null
$middlePanelPlayerOneGrid.Controls.Add( $gameMaster.p1.label ) | Out-Null
$middlePanelPlayerOneGrid.Controls.Add( $innerPanelPlayerOneGrid ) | Out-Null
$mainPanel.Controls.Add( $outerPanelPlayerOneGrid ) | Out-Null

$outerPanelPlayerTwoGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$middlePanelPlayerTwoGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$middlePanelPlayerTwoGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$innerPanelPlayerTwoGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelPlayerTwoGrid.RowCount = 11
$innerPanelPlayerTwoGrid.ColumnCount = 11
$innerPanelPlayerTwoGrid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$gameMaster.p2.label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.p2.label.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.p2.label.Text = "Player Two"
$outerPanelPlayerTwoGrid.Controls.Add( $middlePanelPlayerTwoGrid ) | Out-Null
$middlePanelPlayerTwoGrid.Controls.Add( $gameMaster.p2.label ) | Out-Null
$middlePanelPlayerTwoGrid.Controls.Add( $innerPanelPlayerTwoGrid ) | Out-Null
$mainPanel.Controls.Add( $outerPanelPlayerTwoGrid ) | Out-Null
$mainPanel.SetFlowBreak( $outerPanelPlayerTwoGrid, $true )

$gameMaster.infoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel.Text = " "
$mainPanel.Controls.Add( $gameMaster.infoLabel ) | Out-Null

$gameMaster.refreshTimer.AutoReset = $false
$gameMaster.refreshTimer.Enabled = $false
$gameMaster.refreshTimer.Interval = 30000
$gameMaster.refreshTimer.SynchronizingObject = $form
$gameMaster.refreshTimer.Add_Elapsed({
    Open-Battleship -GameMaster $gameMaster -Refresh
})

Set-Colors -GameMaster $gameMaster

foreach ( $row in 0..10 ) {
    foreach ( $column in 0..10 ) {
        Try {
            $gameMaster.p1.grid | Add-Member -MemberType NoteProperty -Name "$( $column )_$($row )" -Value $([System.Windows.Forms.Label]::new()) -ErrorAction Stop
        } Catch {
            $gameMaster.p1.grid.psobject.properties.remove( "$( $column )_$( $row )" )
            $gameMaster.p1.grid | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $([System.Windows.Forms.Label]::new())
        }

        $gameMaster.p1.grid."$( $column )_$( $row )".TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $gameMaster.p1.grid."$( $column )_$( $row )".Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $gameMaster.p1.grid."$( $column )_$( $row )".Size = [System.Drawing.Size]::new( 50, 50 )
        $gameMaster.p1.grid."$( $column )_$( $row )".Padding = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.p1.grid."$( $column )_$( $row )".Margin = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.p1.grid."$( $column )_$( $row )".Dock = [System.Windows.Forms.DockStyle]::Fill
        $gameMaster.p1.grid."$( $column )_$( $row )".Name = "$( $column )_$( $row )"

        if (( $row -eq 0 ) -or ( $column -eq 0 )) {
            if (( $row -eq 0 ) -and ( $column -eq 0 )) {
                $gameMaster.p1.grid."$( $column )_$( $row )".Text = ""
                $gameMaster.p1.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.tiles.Header
            } elseif ( $row -eq 0 ) {
                $gameMaster.p1.grid."$( $column )_$( $row )".Text = "$( [char]( 64 + $column ))"
                $gameMaster.p1.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.tiles.Header
            } elseif ( $column -eq 0 ) {
                $gameMaster.p1.grid."$( $column )_$( $row )".Text = "$row"
                $gameMaster.p1.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.tiles.Header
            }
        } else {
            $gameMaster.p1.grid."$( $column )_$( $row )".Text = ""
            $gameMaster.p1.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.water.p1
            $gameMaster.p1.grid."$( $column )_$( $row )".Add_Click({
                New-Click -GameMaster $gameMaster -Name $this.Name -Grid 1
            })
        }

        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $innerPanelPlayerOneGrid.SetCellPosition( $gameMaster.p1.grid."$( $column )_$( $row )", $cellPosition )
        $innerPanelPlayerOneGrid.Controls.Add( $gameMaster.p1.grid."$( $column )_$( $row )")

        Try {
            $gameMaster.p2.grid | Add-Member -MemberType NoteProperty -Name "$( $column )_$($row )" -Value $([System.Windows.Forms.Label]::new()) -ErrorAction Stop
        } Catch {
            $gameMaster.p2.grid.psobject.properties.remove( "$( $column )_$( $row )" )
            $gameMaster.p2.grid | Add-Member -MemberType NoteProperty -Name "$( $column)_$( $row )" -Value $([System.Windows.Forms.Label]::new())
        }

        $gameMaster.p2.grid."$( $column )_$( $row )".TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $gameMaster.p2.grid."$( $column )_$( $row )".Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $gameMaster.p2.grid."$( $column )_$( $row )".Size = [System.Drawing.Size]::new( 50, 50 )
        $gameMaster.p2.grid."$( $column )_$( $row )".Padding = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.p2.grid."$( $column )_$( $row )".Margin = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.p2.grid."$( $column )_$( $row )".Dock = [System.Windows.Forms.DockStyle]::Fill
        $gameMaster.p2.grid."$( $column )_$( $row )".Name = "$( $column )_$( $row )"

        if (( $row -eq 0 ) -or ( $column -eq 0 )) {
            if (( $row -eq 0 ) -and ( $column -eq 0 )) {
                $gameMaster.p2.grid."$( $column )_$( $row )".Text = ""
                $gameMaster.p2.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.tiles.Header
            } elseif ( $row -eq 0 ) {
                $gameMaster.p2.grid."$( $column )_$( $row )".Text = "$( [char]( 64 + $column ))"
                $gameMaster.p2.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.tiles.Header
            } elseif ( $column -eq 0 ) {
                $gameMaster.p2.grid."$( $column )_$( $row )".Text = "$row"
                $gameMaster.p2.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.tiles.Header
            }
        } else {
            $gameMaster.p2.grid."$( $column )_$( $row )".Text = ""
            $gameMaster.p2.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.water.p2
            $gameMaster.p2.grid."$( $column )_$( $row )".Add_Click({
                New-Click -GameMaster $gameMaster -Name $this.Name -Grid 2
            })
        }

        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $innerPanelPlayerTwoGrid.SetCellPosition( $gameMaster.p2.grid."$( $column )_$( $row )", $cellPosition )
        $innerPanelPlayerTwoGrid.Controls.Add( $gameMaster.p2.grid."$( $column )_$( $row )")
    }
}

Set-KeyDown -GameMaster $gameMaster -Control $form

Set-AutoSize -Control $form

$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.ShowDialog() | Out-Null

