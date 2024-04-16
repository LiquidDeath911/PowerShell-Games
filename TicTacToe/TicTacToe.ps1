Clear-Host
 
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Both players must have Modify access to this path
$networkPath = ""

if ( $networkPath.Length -eq 0 ) {
    Write-Warning "You must edit the script and add a path to the variable on line 7"
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
 
function Set-Colors {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
   
    $GameMaster.colors.x = [System.Drawing.Color]::Red
    $GameMaster.colors.o = [System.Drawing.Color]::Blue
    $GameMaster.colors.blank = [System.Drawing.Color]::White
 
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
 
function Out-Message {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [string]$Type,
        [string]$Message       
    )
 
    Write-Host "$( $Type ) | $( $Message )"
 
    return
}
 
function New-Click {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name
    )
 
    $split = $Name.Split( "_" )
    $column = $split[0]
    $row = $split[1]
 
    if ( $GameMaster.grid."$( $Name )".Text.Length -eq 0 ) {
        if ( $GameMaster.infoLabel.Text -eq "It is your turn" ) {
            if ( $env:USERNAME -eq $GameMaster.player ) {
                $GameMaster.grid."$( $Name )".Text = "X"
                $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.x
            } else {
                $GameMaster.grid."$( $Name )".Text = "O"
                $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.o
            }
            Send-Game -GameMaster $GameMaster -Column $column -Row $row
        }
    }
 
    return
}
 
function New-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    $GameMaster.end = $false
 
    while ( $true ) {
        $GameMaster.gameID = Get-UserInput -Message "Please create a 4 character alphanumeric code that you provide to your opponent"
        $GameMaster.gameID = $GameMaster.gameID.ToLower()
        if ( $GameMaster.gameID -eq "cancel" ) {
            Out-Message -Type "Notice" -Message "New Game cancelled"
            return
        }
        if (( $GameMaster.gameID.Length ) -ne 4 -or ( $GameMaster.gameID -match '[^A-Za-z0-9]' )) {
            Out-Message -Type "Error" -Message "Code must be 4 characters long and only consist of alphanumeric characters"
            continue
        }
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" ) {
            Out-Message -Type "Error" -Message "That code is already in use"
            continue
        }
        New-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -ItemType Directory
        break
    }
 
    while ( $true ) {
        $GameMaster.opponent = Get-UserInput -Message "Please enter your oppenent's sAMAccountName"
        try {
            $GameMaster.opponent = ( Get-ADUser -Identity "$( $GameMaster.opponent )" -ErrorAction Stop |
                Select-Object -ExpandProperty sAMAccountName )
            break
        } catch {
            if ( $GameMaster.opponent -eq "cancel" ) {
                Out-Message -Type "Notice" -Message "New Game cancelled"
                return
            }
            Out-Message -Type "Error" -Message "Invalid sAMAccountName"
        }
    }
 
    Set-Grid -GameMaster $GameMaster -Reset
 
    $GameMaster | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" -Force
    $GameMaster | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" -Force
 
    $GameMaster.symbolLabel.Text = "You are: X"
    $GameMaster.infoLabel.Text = "It is your turn"
 
    return
}
 
function Open-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    while ( $true ) {
        $GameMaster.gameID = Get-UserInput -Message "Please enter the 4 character alphanumeric code for your game"
        $GameMaster.gameID = $GameMaster.gameID.ToLower()
        if ( $GameMaster.gameID -eq "cancel" ) {
            Out-Message -Type "Notice" -Message "Open Game cancelled"
            return
        }
        if (( $GameMaster.gameID.Length ) -ne 4 -or ( $GameMaster.gameID -match '[^A-Za-z0-9]' )) {
            Out-Message -Type "Error" -Message "Code must be 4 characters long and only consist of alphanumeric characters"
            continue
        }
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" ) {
            if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $env:USERNAME ).clixml" ) {
                try {
                    $inputObject = Import-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $env:USERNAME ).clixml" -ErrorAction Stop
                } catch {
                    Out-Message -Type "Error" -Message "Couldn't open game"
                    continue
                }
 
                $GameMaster.gameID = $inputObject.gameID
                $GameMaster.player = $inputObject.player
                $GameMaster.opponent = $inputObject.opponent
                $GameMaster.infoLabel.Text = $inputObject.infoLabel.Text
 
                if ( $env:USERNAME -eq $GameMaster.player ) {
                    $GameMaster.symbolLabel.Text = "You are: X"
                } else {
                    $GameMaster.symbolLabel.Text = "You are: O"
                }
 
                Set-Grid -GameMaster $GameMaster -InputObject $inputObject
 
                break
            } else {
                Out-Message -Type "Error" -Message "You are not a part of that game"
                continue
            }
        } else {
            Out-Message -Type "Error" -Message "That game doesn't exist"
            continue
        }
    }
 
    Get-Turn -GameMaster $GameMaster
 
    return
}
 
function Set-Grid {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [PSCustomObject]$InputObject,
        [switch]$Reset
    )
 
    foreach ( $row in 0..2 ) {
        foreach ( $column in 0..2 ) {
            if ( $Reset ) {
                $GameMaster.grid."$( $column )_$( $row )".Text = ""
                $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.blank
            } else {
                $GameMaster.grid."$( $column )_$( $row )".Text = $InputObject.grid."$( $column )_$( $row )".Text
                if ( $GameMaster.grid."$( $column )_$( $row )".Text -eq "X" ) {
                    $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.x
                } else {
                    $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.o
                }
            }
        }
    }
 
    return
}
 
function Get-Turn {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    if ( $env:USERNAME -eq $GameMaster.player ) {
 
        $result = Test-Win -GameMaster $GameMaster
        if ( $result -eq "X" ) {
            Set-Win -GameMaster $GameMaster
            return
        } elseif ( $result -eq "O" ) {
            Set-Lose -GameMaster $GameMaster
            return
        } elseif ( $result -eq "Tie") {
            Set-Tie -GameMaster $GameMaster
            return
        }
 
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" ) {
            $inputObject = Import-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml"
 
            $GameMaster.grid."$( $inputObject.column )_$( $inputObject.row )".Text = "O"
 
            $result = Test-Win -GameMaster $GameMaster
            if ( $result -eq "X" ) {
                Set-Win -GameMaster $GameMaster
                return
            } elseif ( $result -eq "O" ) {
                Set-Lose -GameMaster $GameMaster
                return
            } elseif ( $result -eq "Tie") {
                Set-Tie -GameMaster $GameMaster
                return
            }
 
            $GameMaster.infoLabel.Text = "It is your turn"
            New-Notification
            $GameMaster.refreshTimer.Enabled = $false
        } else {
            $GameMaster.infoLabel.Text = "Opponent's Turn"
            $GameMaster.refreshTimer.Enabled = $true
        }
    } else {
 
        $result = Test-Win -GameMaster $GameMaster
        if ( $result -eq "O" ) {
            $GameMaster.refreshTimer.Enabled = $false
            Set-Win -GameMaster $GameMaster
            return
        } elseif ( $result -eq "X" ) {
            $GameMaster.refreshTimer.Enabled = $false
            Set-Lose -GameMaster $GameMaster
            return
        } elseif ( $result -eq "Tie") {
            $GameMaster.refreshTimer.Enabled = $false
            Set-Tie -GameMaster $GameMaster
            return
        }
 
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" ) {
            $inputObject = Import-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml"
 
            $GameMaster.grid."$( $inputObject.column )_$( $inputObject.row )".Text = "X"
 
            $result = Test-Win -GameMaster $GameMaster
            if ( $result -eq "O" ) {
                $GameMaster.refreshTimer.Enabled = $false
                Set-Win -GameMaster $GameMaster
                return
            } elseif ( $result -eq "X" ) {
                $GameMaster.refreshTimer.Enabled = $false
                Set-Lose -GameMaster $GameMaster
                return
            } elseif ( $result -eq "Tie") {
                $GameMaster.refreshTimer.Enabled = $false
                Set-Tie -GameMaster $GameMaster
                return
            }
 
            $GameMaster.infoLabel.Text = "It is your turn"
            New-Notification
            $GameMaster.refreshTimer.Enabled = $false
        } else {
            $GameMaster.infoLabel.Text = "Opponent's Turn"
            $GameMaster.refreshTimer.Enabled = $true
        }
    }
 
    return
}
 
function Send-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Column,
        [int]$Row
    )
 
    $sendObject = [PSCustomObject]@{
        column = $Column
        row = $Row
    }
 
    if ( $env:USERNAME -eq $GameMaster.player ) {
        $GameMaster | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" -Force
        $sendObject | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" -Force
        $count = 0
        while ( $true ) {
            $count++
            if ( $count -ge 25 ) {
                break
            }
            try {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" -Force -ErrorAction Stop
            } catch {
                continue
            }
            break
        }
    } else {
        $GameMaster | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" -Force
        $sendObject | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" -Force
        $count = 0
        while ( $true ) {
            $count++
            if ( $count -ge 25 ) {
                break
            }
            try {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" -Force -ErrorAction Stop
            } catch {
                continue
            }
            break
        }
    }
 
    $GameMaster.refreshTimer.Enabled = $true
    $GameMaster.infoLabel.Text = "Opponent's Turn"
 
    return
}
 
function Close-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    if ( $GameMaster.end ) {
        if ( $env:USERNAME -eq $GameMaster.player ) {
            if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" ) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" -Force
            }
            if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" ) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" -Force
            }
            if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" )) {
                if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" )) {
                    Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -Force
                }
            }
 
        } else {
            if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" ) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" -Force
            }
            if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" ) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" -Force
            }
            if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" )) {
                if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" )) {
                    Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -Force
                }
            }
        }
    }
 
    return
}
 
function Test-Win {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    if ( $GameMaster.grid."1_1".Text.Length -ne 0 ) {
        # Row 2 Check
        if (( $GameMaster.grid."1_1".Text -eq $GameMaster.grid."0_1".Text ) -and ( $GameMaster.grid."1_1".Text -eq $GameMaster.grid."2_1".Text )) {
            return $GameMaster.grid."1_1".Text
        }
 
        # Column 2 Check
        if (( $GameMaster.grid."1_1".Text -eq $GameMaster.grid."1_0".Text ) -and ( $GameMaster.grid."1_1".Text -eq $GameMaster.grid."1_2".Text )) {
            return $GameMaster.grid."1_1".Text
        }
 
        # Diagonal TopLeft to BottomRight Check
        if (( $GameMaster.grid."1_1".Text -eq $GameMaster.grid."0_0".Text ) -and ( $GameMaster.grid."1_1".Text -eq $GameMaster.grid."2_2".Text )) {
            return $GameMaster.grid."1_1".Text
        }
 
        # Column BottomLeft to TopRight Check
        if (( $GameMaster.grid."1_1".Text -eq $GameMaster.grid."0_2".Text ) -and ( $GameMaster.grid."1_1".Text -eq $GameMaster.grid."2_0".Text )) {
            return $GameMaster.grid."1_1".Text
        }
    }
   
    if ( $GameMaster.grid."0_0".Text.Length -ne 0 ) {
        # Row 1 Check
        if (( $GameMaster.grid."0_0".Text -eq $GameMaster.grid."1_0".Text ) -and ( $GameMaster.grid."0_0".Text -eq $GameMaster.grid."2_0".Text )) {
            return $GameMaster.grid."0_0".Text
        }
 
        # Column 1 Check
        if (( $GameMaster.grid."0_0".Text -eq $GameMaster.grid."0_1".Text ) -and ( $GameMaster.grid."0_0".Text -eq $GameMaster.grid."0_2".Text )) {
            return $GameMaster.grid."0_0".Text
        }
    }
 
    if ( $GameMaster.grid."2_2".Text.Length -ne 0 ) {
        # Row 3 Check
        if (( $GameMaster.grid."2_2".Text -eq $GameMaster.grid."0_2".Text ) -and ( $GameMaster.grid."2_2".Text -eq $GameMaster.grid."1_2".Text )) {
            return $GameMaster.grid."2_2".Text
        }
 
        # Column 3 Check
        if (( $GameMaster.grid."2_2".Text -eq $GameMaster.grid."2_0".Text ) -and ( $GameMaster.grid."2_2".Text -eq $GameMaster.grid."2_1".Text )) {
            return $GameMaster.grid."2_2".Text
        }
    }
 
    foreach ( $row in 0..2 ) {
        foreach ( $column in 0..2 ) {
            if ( $GameMaster.grid."$( $column )_$( $row )".Text.Length -eq 0 ) {
                return ""
            }
        }
    }
 
    return "Tie"
}
 
function Set-Win {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    $GameMaster.infoLabel.Text = "You Won!"
    $GameMaster.refreshTimer.Enabled = $false
    $GameMaster.end = $true
 
    if ( $env:USERNAME -eq $GameMaster.player ) {
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" -Force
        }
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" -Force
        }
        if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" )) {
            if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" )) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -Force
            }
        }
 
    } else {
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" -Force
        }
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" -Force
        }
        if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" )) {
            if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" )) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -Force
            }
        }
    }
 
    return
}
 
function Set-Tie {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    $GameMaster.infoLabel.Text = "It's a tie."
    $GameMaster.refreshTimer.Enabled = $false
    $GameMaster.end = $true
 
    if ( $env:USERNAME -eq $GameMaster.player ) {
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" -Force
        }
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" -Force
        }
        if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" )) {
            if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" )) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -Force
            }
        }
 
    } else {
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" -Force
        }
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" -Force
        }
        if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" )) {
            if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" )) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -Force
            }
        }
    }
 
    return
}
 
function Set-Lose {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    $GameMaster.infoLabel.Text = "You have lost."
    $GameMaster.refreshTimer.Enabled = $false
    $GameMaster.end = $true
 
    if ( $env:USERNAME -eq $GameMaster.player ) {
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" -Force
        }
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" -Force
        }
        if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" )) {
            if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" )) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -Force
            }
        }
 
    } else {
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponent ).clixml" -Force
        }
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" ) {
            Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponent ).clixml" -Force
        }
        if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.player ).clixml" )) {
            if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.player ).clixml" )) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -Force
            }
        }
    }
 
    return
}
 
function New-Notification {
    $notification = [System.Windows.Forms.NotifyIcon]::new()
 
    $path = (Get-Process -id $pid).Path
    $notification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $notification.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $notification.BalloonTipText = "It is your turn in TicTacToe"
    $notification.BalloonTipTitle = "TicTacToe"
    $notification.Visible = $true
    $notification.ShowBalloonTip(3000)
}
 
$gameMaster = [PSCustomObject]@{
    gameID = $null
    player = $env:USERNAME
    opponent = ""
    end = $false
    networkPath = $networkPath
    symbolLabel = [System.Windows.Forms.Label]::new()
    infoLabel = [System.Windows.Forms.Label]::new()
    refreshTimer = [System.Timers.Timer]::new()
    grid = [PSCustomObject]@{}
    colors = [PSCustomObject]@{
        o = $null
        x = $null
        blank = $null
    }
}
 
$scoreObject = [PSCustomObject]@{
    TotalGames = 0; Wins = 0; Losses = 0; Ties = 0
}
 
$form = [System.Windows.Forms.Form]::new()
$form.Text = "Tic Tac Toe"
$form.Add_FormClosing({
    Close-Game -GameMaster $gameMaster
})
$toolStrip = [System.Windows.Forms.ToolStrip]::new()
$toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
$toolStrip.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden
$mainPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$mainPanel.Padding = [System.Windows.Forms.Padding]::new( 5, $toolStrip.Height, 5, 5 )
$mainPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$form.Controls.Add( $toolStrip ) | Out-Null
$form.Controls.Add( $mainPanel ) | Out-Null
 
$gameMaster.symbolLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.symbolLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.symbolLabel.Text = " "
$mainPanel.Controls.Add( $gameMaster.symbolLabel ) | Out-Null
 
$newGameButton = [System.Windows.Forms.ToolStripButton]::new()
$newGameButton.Text = "New Game"
$newGameButton.Padding = [System.Windows.Forms.Padding]::new( 0, 0, 5, 0 )
$newGameButton.Add_Click({
    New-Game -GameMaster $gameMaster
})
$toolStrip.Items.Add( $newGameButton ) | Out-Null
$openGameButton = [System.Windows.Forms.ToolStripButton]::new()
$openGameButton.Text = "Open Game"
$openGameButton.Padding = [System.Windows.Forms.Padding]::new( 0, 0, 5, 0 )
$openGameButton.Add_Click({
    Open-Game -GameMaster $gameMaster
})
$toolStrip.Items.Add( $openGameButton ) | Out-Null
 
$outerPanelGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$middlePanelGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$middlePanelGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$innerPanelGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelGrid.RowCount = 11
$innerPanelGrid.ColumnCount = 11
$innerPanelGrid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$outerPanelGrid.Controls.Add( $middlePanelGrid ) | Out-Null
$middlePanelGrid.Controls.Add( $innerPanelGrid ) | Out-Null
$mainPanel.Controls.Add( $outerPanelGrid ) | Out-Null
 
$gameMaster.infoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel.Text = " "
$mainPanel.Controls.Add( $gameMaster.infoLabel ) | Out-Null
 
$gameMaster.refreshTimer.AutoReset = $false
$gameMaster.refreshTimer.Enabled = $false
$gameMaster.refreshTimer.Interval = 15000
$gameMaster.refreshTimer.SynchronizingObject = $form
$gameMaster.refreshTimer.Add_Elapsed({
    #Write-Host "Refreshed"
    Get-Turn -GameMaster $gameMaster
})
 
Set-Colors -GameMaster $gameMaster
 
foreach ( $row in 0..2 ) {
    foreach ( $column in 0..2 ) {
        Try {
            $gameMaster.grid | Add-Member -MemberType NoteProperty -Name "$( $column )_$($row )" -Value $([System.Windows.Forms.Label]::new()) -ErrorAction Stop
        } Catch {
            $gameMaster.grid.psobject.properties.remove( "$( $column )_$( $row )" )
            $gameMaster.grid | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $([System.Windows.Forms.Label]::new())
        }
        $gameMaster.grid."$( $column )_$( $row )".TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $gameMaster.grid."$( $column )_$( $row )".Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $gameMaster.grid."$( $column )_$( $row )".Size = [System.Drawing.Size]::new( 50, 50 )
        $gameMaster.grid."$( $column )_$( $row )".Padding = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid."$( $column )_$( $row )".Margin = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid."$( $column )_$( $row )".Dock = [System.Windows.Forms.DockStyle]::Fill
        $gameMaster.grid."$( $column )_$( $row )".Name = "$( $column )_$( $row )"
        $gameMaster.grid."$( $column )_$( $row )".Text = ""
        $gameMaster.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.blank
        $gameMaster.grid."$( $column )_$( $row )".Add_Click({
            New-Click -GameMaster $gameMaster -Name $this.Name
        })
        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $innerPanelGrid.SetCellPosition( $gameMaster.grid."$( $column )_$( $row )", $cellPosition )
        $innerPanelGrid.Controls.Add( $gameMaster.grid."$( $column )_$( $row )")
    }
}
 
Set-AutoSize -Control $form
 
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.ShowDialog() | Out-Null