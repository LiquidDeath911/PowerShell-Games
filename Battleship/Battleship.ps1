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
 
function New-KeyDown {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Key
    )
 
    Switch ( $Key ) {
        0 {
            Switch ( $GameMaster.phase ) {
                0 { New-PhaseZeroEnterKey -GameMaster $GameMaster }
                1 { New-PhaseOneEnterKey -GameMaster $GameMaster }
            }
        }
        1 {
            Switch ( $GameMaster.phase ) {
                0 { New-PhaseZeroSpaceKey -GameMaster $GameMaster }
                1 { New-PhaseOneSpaceKey -GameMaster $GameMaster }
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
   
    $GameMaster.colors.shot = [System.Drawing.Color]::Pink
    $GameMaster.colors.hit = [System.Drawing.Color]::Red
    $GameMaster.colors.miss = [System.Drawing.Color]::White
    $GameMaster.colors.header = [System.Drawing.Color]::LightGray
    $GameMaster.colors.selected = [System.Drawing.Color]::Orange
    $GameMaster.colors.water = [System.Drawing.Color]::DarkBlue
    $GameMaster.colors.s1 = [System.Drawing.Color]::ForestGreen
    $GameMaster.colors.s2 = [System.Drawing.Color]::LawnGreen
    $GameMaster.colors.s3 = [System.Drawing.Color]::MediumSeaGreen
    $GameMaster.colors.s4 = [System.Drawing.Color]::LimeGreen
    $GameMaster.colors.s5 = [System.Drawing.Color]::DarkOliveGreen
 
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
 
function New-MouseEnter {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name
    )
 
    if ( -not $GameMaster.start ) {
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        return
    }
 
    $split = $Name.Split( "_" )
    $grid = $split[0]
    $column = $split[1]
    $row = $split[2]
 
    Switch ( $GameMaster.phase ) {
        0 {
            if (( $env:USERNAME -eq $GameMaster.playerName ) -and ( $grid -eq "1" )) {
                New-PhaseZeroMouseEnter -GameMaster $GameMaster -Grid 1 -Column $column -Row $row
            } elseif (( $env:USERNAME -eq $GameMaster.opponentName ) -and ( $grid -eq "2" )) {
                New-PhaseZeroMouseEnter -GameMaster $GameMaster -Grid 2 -Column $column -Row $row
            }
        }
        1 {
            if (( $env:USERNAME -eq $GameMaster.playerName ) -and ( $grid -eq "2" )) {
                New-PhaseOneMouseEnter -GameMaster $GameMaster -Grid 2 -Column $column -Row $row
            } elseif (( $env:USERNAME -eq $GameMaster.opponentName ) -and ( $grid -eq "1" )) {
                New-PhaseOneMouseEnter -GameMaster $GameMaster -Grid 1 -Column $column -Row $row
            }
        }
    }
 
    return
}
 
function New-MouseLeave {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name
    )
 
    if ( -not $GameMaster.start ) {
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        return
    }
 
    $split = $Name.Split( "_" )
    $grid = $split[0]
    $column = $split[1]
    $row = $split[2]
 
    Switch ( $GameMaster.phase ) {
        0 {
            if (( $env:USERNAME -eq $GameMaster.playerName ) -and ( $grid -eq "1" )) {
                New-PhaseZeroMouseLeave -GameMaster $GameMaster -Grid 1 -Column $column -Row $row
            } elseif (( $env:USERNAME -eq $GameMaster.opponentName ) -and ( $grid -eq "2" )) {
                New-PhaseZeroMouseLeave -GameMaster $GameMaster -Grid 2 -Column $column -Row $row
            }
        }
        1 {
            if (( $env:USERNAME -eq $GameMaster.playerName ) -and ( $grid -eq "2" )) {
                New-PhaseOneMouseLeave -GameMaster $GameMaster -Grid 2 -Column $column -Row $row
            } elseif (( $env:USERNAME -eq $GameMaster.opponentName ) -and ( $grid -eq "1" )) {
                New-PhaseOneMouseLeave -GameMaster $GameMaster -Grid 1 -Column $column -Row $row
            }
        }
    }
 
    return
}
 
function New-MouseClick {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name,
        [switch]$Left,
        [switch]$Right
    )
 
    if ( -not $GameMaster.start ) {
        Out-Message -Type "Notice" -Message "No game currently running"
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        Out-Message -Type "Notice" -Message "It is not your turn"
        return
    }
 
    $split = $Name.Split( "_" )
    $grid = $split[0]
    $column = $split[1]
    $row = $split[2]
 
    Switch ( $GameMaster.phase ) {
        0 {
            if (( $env:USERNAME -eq $GameMaster.playerName ) -and ( $grid -eq "1" )) {
                if ( $Left ) {
                    New-PhaseZeroMouseClick -GameMaster $GameMaster -Grid 1 -Column $column -Row $row
                } elseif ( $Right ) {
                    New-PhaseZeroMouseClickRight -GameMaster $GameMaster -Grid 1 -Column $column -Row $row
                }
            } elseif (( $env:USERNAME -eq $GameMaster.opponentName ) -and ( $grid -eq "2" )) {
                if ( $Left ) {
                    New-PhaseZeroMouseClick -GameMaster $GameMaster -Grid 2 -Column $column -Row $row
                } elseif ( $Right ) {
                    New-PhaseZeroMouseClickRight -GameMaster $GameMaster -Grid 2 -Column $column -Row $row
                }
            }
        }
        1 {
            if (( $env:USERNAME -eq $GameMaster.playerName ) -and ( $grid -eq "2" )) {
                if ( $Left ) {
                    New-PhaseOneMouseClick -GameMaster $GameMaster -Grid 2 -Column $column -Row $row
                } elseif ( $Right ) {
                    New-PhaseOneMouseClickRight -GameMaster $GameMaster -Grid 2 -Column $column -Row $row
                }
            } elseif (( $env:USERNAME -eq $GameMaster.opponentName ) -and ( $grid -eq "1" )) {
                if ( $Left ) {
                    New-PhaseOneMouseClick -GameMaster $GameMaster -Grid 1 -Column $column -Row $row
                } elseif ( $Right ) {
                    New-PhaseOneMouseClickRight -GameMaster $GameMaster -Grid 1 -Column $column -Row $row
                }
            }
        }
    }
 
    return
}
 
function New-PhaseZeroMouseEnter {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [int]$Column,
        [int]$Row
    )
 
    if ( -not $GameMaster.start ) {
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        return
    }
 
    if ( -not $GameMaster.ship1.placed ) {
        if ( $GameMaster.ship1.direction ) {
            foreach ( $number in 0..4 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.water ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.selected
                }
            }
        } else {
            foreach ( $number in 0..4 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.water ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.selected
                }
            }
        }
    } elseif ( -not $GameMaster.ship2.placed ) {
        if ( $GameMaster.ship2.direction ) {
            foreach ( $number in 0..3 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.water ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.selected
                }
            }
        } else {
            foreach ( $number in 0..3 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.water ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.selected
                }
            }
        }
    } elseif ( -not $GameMaster.ship3.placed ) {
        if ( $GameMaster.ship3.direction ) {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.water ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.selected
                }
            }
        } else {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.water ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.selected
                }
            }
        }
    } elseif ( -not $GameMaster.ship4.placed ) {
        if ( $GameMaster.ship4.direction ) {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.water ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.selected
                }
            }
        } else {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.water ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.selected
                }
            }
        }
    } elseif ( -not $GameMaster.ship5.placed ) {
        if ( $GameMaster.ship5.direction ) {
            foreach ( $number in 0..1 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.water ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.selected
                }
            }
        } else {
            foreach ( $number in 0..1 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.water ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.selected
                }
            }
        }
    }
 
    return
}
 
function New-PhaseZeroMouseLeave {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [int]$Column,
        [int]$Row
    )
 
    if ( -not $GameMaster.start ) {
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        return
    }
 
    if ( -not $GameMaster.ship1.placed ) {
        foreach ( $number in 0..4 ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.water
            }
        }
        foreach ( $number in 0..4 ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.water
            }
        }
    } elseif ( -not $GameMaster.ship2.placed ) {
        foreach ( $number in 0..3 ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.water
            }
        }
        foreach ( $number in 0..3 ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.water
            }
        }
    } elseif ( -not $GameMaster.ship3.placed ) {
        foreach ( $number in 0..2 ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.water
            }
        }
        foreach ( $number in 0..2 ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.water
            }
        }
    } elseif ( -not $GameMaster.ship4.placed ) {
        foreach ( $number in 0..2 ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.water
            }
        }
        foreach ( $number in 0..2 ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.water
            }
        }
    } elseif ( -not $GameMaster.ship5.placed ) {
        foreach ( $number in 0..1 ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.water
            }
        }
        foreach ( $number in 0..1 ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.water
            }
        }
    }
 
    return
}
 
function New-PhaseZeroMouseClick {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [int]$Column,
        [int]$Row
    )
 
    if ( -not $GameMaster.start ) {
        Out-Message -Type "Notice" -Message "No game currently running"
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        Out-Message -Type "Notice" -Message "It is not your turn"
        return
    }
 
    if ( -not $GameMaster.ship1.placed ) {
        if ( $GameMaster.ship1.direction ) {
            foreach ( $number in 0..4 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -ne $GameMaster.colors.selected ) { return }
            }
            foreach ( $number in 0..4 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.s1
                }
            }
        } else {
            foreach ( $number in 0..4 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -ne $GameMaster.colors.selected ) { return }
            }
            foreach ( $number in 0..4 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.selected ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.s1
                }
            }
        }
        $GameMaster.ship1.placed = $true
        $GameMaster.ship1.column = $Column
        $GameMaster.ship1.row = $Row
    } elseif ( -not $GameMaster.ship2.placed ) {
        if ( $GameMaster.ship2.direction ) {
            foreach ( $number in 0..3 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -ne $GameMaster.colors.selected ) { return }
            }
            foreach ( $number in 0..3 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.s2
                }
            }
        } else {
            foreach ( $number in 0..3 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -ne $GameMaster.colors.selected ) { return }
            }
            foreach ( $number in 0..3 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.selected ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.s2
                }
            }
        }
        $GameMaster.ship2.placed = $true
        $GameMaster.ship2.column = $Column
        $GameMaster.ship2.row = $Row
    } elseif ( -not $GameMaster.ship3.placed ) {
        if ( $GameMaster.ship3.direction ) {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -ne $GameMaster.colors.selected ) { return }
            }
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.s3
                }
            }
        } else {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -ne $GameMaster.colors.selected ) { return }
            }
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.selected ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.s3
                }
            }
        }
        $GameMaster.ship3.placed = $true
        $GameMaster.ship3.column = $Column
        $GameMaster.ship3.row = $Row
    } elseif ( -not $GameMaster.ship4.placed ) {
        if ( $GameMaster.ship4.direction ) {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -ne $GameMaster.colors.selected ) { return }
            }
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.s4
                }
            }
        } else {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -ne $GameMaster.colors.selected ) { return }
            }
            foreach ( $number in 0..2 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.selected ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.s4
                }
            }
        }
        $GameMaster.ship4.placed = $true
        $GameMaster.ship4.column = $Column
        $GameMaster.ship4.row = $Row
    } elseif ( -not $GameMaster.ship5.placed ) {
        if ( $GameMaster.ship5.direction ) {
            foreach ( $number in 0..1 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -ne $GameMaster.colors.selected ) { return }
            }
            foreach ( $number in 0..1 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column + $number )_$( $row )".BackColor = $GameMaster.colors.s5
                }
            }
        } else {
            foreach ( $number in 0..1 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -ne $GameMaster.colors.selected ) { return }
            }
            foreach ( $number in 0..1 ) {
                if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor -eq $GameMaster.colors.selected ) {
                    $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row + $number )".BackColor = $GameMaster.colors.s5
                }
            }
        }
        $GameMaster.ship5.placed = $true
        $GameMaster.ship5.column = $Column
        $GameMaster.ship5.row = $Row
        $GameMaster.phase++
        Send-Game -GameMaster $GameMaster
    }
 
    return
}
 
function New-PhaseZeroMouseClickRight {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [int]$Column,
        [int]$Row
    )
 
    if ( -not $GameMaster.start ) {
        Out-Message -Type "Notice" -Message "No game currently running"
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        Out-Message -Type "Notice" -Message "It is not your turn"
        return
    }
 
    if ( -not $GameMaster.ship1.placed ) {
        $GameMaster.ship1.direction = ( -not $GameMaster.ship1.direction )
    } elseif ( -not $GameMaster.ship2.placed ) {
        $GameMaster.ship2.direction = ( -not $GameMaster.ship2.direction )
    } elseif ( -not $GameMaster.ship3.placed ) {
        $GameMaster.ship3.direction = ( -not $GameMaster.ship3.direction )
    } elseif ( -not $GameMaster.ship4.placed ) {
        $GameMaster.ship4.direction = ( -not $GameMaster.ship4.direction )
    } elseif ( -not $GameMaster.ship5.placed ) {
        $GameMaster.ship5.direction = ( -not $GameMaster.ship5.direction )
    } else {
        return
    }
    New-PhaseZeroMouseLeave -GameMaster $GameMaster -Grid $Grid -Column $Column -Row $Row
    New-PhaseZeroMouseEnter -GameMaster $GameMaster -Grid $Grid -Column $Column -Row $Row
 
    return
}
 
function New-PhaseZeroEnterKey {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    if ( -not $GameMaster.start ) {
        Out-Message -Type "Notice" -Message "No game currently running"
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        Out-Message -Type "Notice" -Message "It is not your turn"
        return
    }
 
    return
}
 
function New-PhaseZeroSpaceKey {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    if ( -not $GameMaster.start ) {
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        return
    }
 
    return
}
 
function New-PhaseOneMouseEnter {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [int]$Column,
        [int]$Row
    )
 
    if ( -not $GameMaster.start ) {
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        return
    }
 
    if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row )".BackColor -eq $GameMaster.colors.water ) {
        $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row )".BackColor = $GameMaster.colors.selected
    }
 
    return
}
 
function New-PhaseOneMouseLeave {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [int]$Column,
        [int]$Row
    )
 
    if ( -not $GameMaster.start ) {
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        return
    }
 
    if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row )".BackColor -eq $GameMaster.colors.selected ) {
        $GameMaster."grid$( $Grid )"."$( $Grid )_$( $column )_$( $row )".BackColor = $GameMaster.colors.water
    }
 
    return
}
 
function New-PhaseOneEnterKey {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    if ( -not $GameMaster.start ) {
        Out-Message -Type "Notice" -Message "No game currently running"
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        Out-Message -Type "Notice" -Message "It is not your turn"
        return
    }
 
    if ( $env:USERNAME -eq $GameMaster.playerName ) {
        $playerCount = 0
        foreach ( $property in $GameMaster.playerShots.PSObject.Properties ) {
            $playerCount++
        }
 
        $opponentCount = 0
        foreach ( $property in $GameMaster.opponentShots.PSObject.Properties ) {
            $opponentCount++
        }
 
        if ( $playerCount -eq ( $GameMaster.shotAmount + $opponentCount ) ) {
            Set-Grid -GameMaster $GameMaster -Reset
            Set-Grid -GameMaster $GameMaster
            Send-Game -GameMaster $GameMaster
        } else {
            Out-Message -Type "Notice" -Message "Place all 3 shots before sending"
        }
    } elseif ( $env:USERNAME -eq $GameMaster.opponentName ) {
        $playerCount = 0
        foreach ( $property in $GameMaster.playerShots.PSObject.Properties ) {
            $playerCount++
        }
 
        $opponentCount = 0
        foreach ( $property in $GameMaster.opponentShots.PSObject.Properties ) {
            $opponentCount++
        }
 
        if ( $opponentCount -eq $playerCount ) {
            Set-Grid -GameMaster $GameMaster -Reset
            Set-Grid -GameMaster $GameMaster
            Send-Game -GameMaster $GameMaster
        } else {
            Out-Message -Type "Notice" -Message "Place all 3 shots before sending"
        }
    }
 
    return
}
 
function New-PhaseOneSpaceKey {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    if ( -not $GameMaster.start ) {
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        return
    }
 
    return
}
 
function New-PhaseOneMouseClick {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [int]$Column,
        [int]$Row
    )
 
    if ( -not $GameMaster.start ) {
        Out-Message -Type "Notice" -Message "No game currently running"
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        Out-Message -Type "Notice" -Message "It is not your turn"
        return
    }
 
    if ( $env:USERNAME -eq $GameMaster.playerName ) {
        $playerCount = 0
        foreach ( $property in $GameMaster.playerShots.PSObject.Properties ) {
            $playerCount++
        }
 
        $opponentCount = 0
        foreach ( $property in $GameMaster.opponentShots.PSObject.Properties ) {
            $opponentCount++
        }
 
        if ( $playerCount -lt ( $GameMaster.shotAmount + $opponentCount )) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $Column )_$( $Row )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $Column )_$( $Row )".BackColor = $GameMaster.colors.shot
                $GameMaster.playerShots | Add-Member -MemberType NoteProperty -Name "$( $playerCount )" -Value $( [PSCustomObject]@{ column = $Column; row = $Row; checked = $false } )
            }
        }
    } elseif ( $env:USERNAME -eq $GameMaster.opponentName ) {
        $playerCount = 0
        foreach ( $property in $GameMaster.playerShots.PSObject.Properties ) {
            $playerCount++
        }
 
        $opponentCount = 0
        foreach ( $property in $GameMaster.opponentShots.PSObject.Properties ) {
            $opponentCount++
        }
 
        if ( $opponentCount -lt $playerCount ) {
            if ( $GameMaster."grid$( $Grid )"."$( $Grid )_$( $Column )_$( $Row )".BackColor -eq $GameMaster.colors.selected ) {
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $Column )_$( $Row )".BackColor = $GameMaster.colors.shot
                $GameMaster.opponentShots | Add-Member -MemberType NoteProperty -Name "$( $opponentCount )" -Value $( [PSCustomObject]@{ column = $Column; row = $Row; checked = $false } )
            }
        }
    }
 
    return
}
 
function New-PhaseOneMouseClickRight {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [int]$Column,
        [int]$Row
    )
 
    if ( -not $GameMaster.start ) {
        return
    } elseif ( $GameMaster.infoLabel.Text -ne "Your Turn" ) {
        return
    }
 
    if ( $env:USERNAME -eq $GameMaster.playerName ) {
        $playerCount = 0
        foreach ( $property in $GameMaster.playerShots.PSObject.Properties ) {
            $playerCount++
        }
 
        if ( $playerCount -gt 0 ) {
                $playerCount--
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $GameMaster.playerShots."$( $playerCount )".column )_$( $GameMaster.playerShots."$( $playerCount )".row )".BackColor = $GameMaster.colors.water
                $GameMaster.playerShots.psobject.properties.remove( "$( $playerCount )" )
        }
    } elseif ( $env:USERNAME -eq $GameMaster.opponentName ) {
        $opponentCount = 0
        foreach ( $property in $GameMaster.opponentShots.PSObject.Properties ) {
            $opponentCount++
        }
 
        if ( $opponentCount -gt 0 ) {
                $opponentCount--
                $GameMaster."grid$( $Grid )"."$( $Grid )_$( $GameMaster.opponentShots."$( $opponentCount )".column )_$( $GameMaster.opponentShots."$( $opponentCount )".row )".BackColor = $GameMaster.colors.water
                $GameMaster.opponentShots.psobject.properties.remove( "$( $opponentCount )" )
        }
    }
 
    return
}
 
function Set-Ships {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [switch]$Show,
        [switch]$Hide
    )
 
    if (( $env:USERNAME -eq $GameMaster.playerName ) -and ( $Grid -eq 1 )) {
        if ( $GameMaster.ship1.placed ) {
            foreach ( $number in 0..4 ) {
                if ( $GameMaster.ship1.direction ) {
                    if ( $Show ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship1.column + $number )_$( $GameMaster.ship1.row )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid1."1_$( $GameMaster.ship1.column + $number )_$( $GameMaster.ship1.row )".BackColor = $GameMaster.colors.s1
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship1.column + $number )_$( $GameMaster.ship1.row )".BackColor -eq $GameMaster.colors.s1) {
                            $GameMaster.grid1."1_$( $GameMaster.ship1.column + $number )_$( $GameMaster.ship1.row )".BackColor = $GameMaster.colors.water
                        }
                    }
                } else {
                    if ( $Show ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship1.column )_$( $GameMaster.ship1.row + $number )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid1."1_$( $GameMaster.ship1.column )_$( $GameMaster.ship1.row + $number )".BackColor = $GameMaster.colors.s1
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship1.column )_$( $GameMaster.ship1.row + $number )".BackColor -eq $GameMaster.colors.s1) {
                            $GameMaster.grid1."1_$( $GameMaster.ship1.column )_$( $GameMaster.ship1.row + $number )".BackColor = $GameMaster.colors.water
                        }
                    }
                }
            }
        }
 
        if ( $GameMaster.ship2.placed ) {
            foreach ( $number in 0..3 ) {
                if ( $GameMaster.ship2.direction ) {
                    if ( $Show ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship2.column + $number )_$( $GameMaster.ship2.row )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid1."1_$( $GameMaster.ship2.column + $number )_$( $GameMaster.ship2.row )".BackColor = $GameMaster.colors.s2
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship2.column + $number )_$( $GameMaster.ship2.row )".BackColor -eq $GameMaster.colors.s2) {
                            $GameMaster.grid1."1_$( $GameMaster.ship2.column + $number )_$( $GameMaster.ship2.row )".BackColor = $GameMaster.colors.water
                        }
                    }
                } else {
                    if ( $Show ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship2.column )_$( $GameMaster.ship2.row + $number )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid1."1_$( $GameMaster.ship2.column )_$( $GameMaster.ship2.row + $number )".BackColor = $GameMaster.colors.s2
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship2.column )_$( $GameMaster.ship2.row + $number )".BackColor -eq $GameMaster.colors.s2) {
                            $GameMaster.grid1."1_$( $GameMaster.ship2.column )_$( $GameMaster.ship2.row + $number )".BackColor = $GameMaster.colors.water
                        }
                    }
                }
            }
        }
 
        if ( $GameMaster.ship3.placed ) {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster.ship3.direction ) {
                    if ( $Show ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship3.column + $number )_$( $GameMaster.ship3.row )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid1."1_$( $GameMaster.ship3.column + $number )_$( $GameMaster.ship3.row )".BackColor = $GameMaster.colors.s3
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship3.column + $number )_$( $GameMaster.ship3.row )".BackColor -eq $GameMaster.colors.s3) {
                            $GameMaster.grid1."1_$( $GameMaster.ship3.column + $number )_$( $GameMaster.ship3.row )".BackColor = $GameMaster.colors.water
                        }
                    }
                } else {
                    if ( $Show ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship3.column )_$( $GameMaster.ship3.row + $number )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid1."1_$( $GameMaster.ship3.column )_$( $GameMaster.ship3.row + $number )".BackColor = $GameMaster.colors.s3
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship3.column )_$( $GameMaster.ship3.row + $number )".BackColor -eq $GameMaster.colors.s3) {
                            $GameMaster.grid1."1_$( $GameMaster.ship3.column )_$( $GameMaster.ship3.row + $number )".BackColor = $GameMaster.colors.water
                        }
                    }
                }
            }
        }
 
        if ( $GameMaster.ship4.placed ) {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster.ship4.direction ) {
                    if ( $Show ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship4.column + $number )_$( $GameMaster.ship4.row )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid1."1_$( $GameMaster.ship4.column + $number )_$( $GameMaster.ship4.row )".BackColor = $GameMaster.colors.s4
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship4.column + $number )_$( $GameMaster.ship4.row )".BackColor -eq $GameMaster.colors.s4) {
                            $GameMaster.grid1."1_$( $GameMaster.ship4.column + $number )_$( $GameMaster.ship4.row )".BackColor = $GameMaster.colors.water
                        }
                    }
                } else {
                    if ( $Show ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship4.column )_$( $GameMaster.ship4.row + $number )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid1."1_$( $GameMaster.ship4.column )_$( $GameMaster.ship4.row + $number )".BackColor = $GameMaster.colors.s4
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship4.column )_$( $GameMaster.ship4.row + $number )".BackColor -eq $GameMaster.colors.s4) {
                            $GameMaster.grid1."1_$( $GameMaster.ship4.column )_$( $GameMaster.ship4.row + $number )".BackColor = $GameMaster.colors.water
                        }
                    }
                }
            }
        }
 
        if ( $GameMaster.ship5.placed ) {
            foreach ( $number in 0..1 ) {
                if ( $GameMaster.ship5.direction ) {
                    if ( $Show ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship5.column + $number )_$( $GameMaster.ship5.row )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid1."1_$( $GameMaster.ship5.column + $number )_$( $GameMaster.ship5.row )".BackColor = $GameMaster.colors.s5
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship5.column + $number )_$( $GameMaster.ship5.row )".BackColor -eq $GameMaster.colors.s5) {
                            $GameMaster.grid1."1_$( $GameMaster.ship5.column + $number )_$( $GameMaster.ship5.row )".BackColor = $GameMaster.colors.water
                        }
                    }
                } else {
                    if ( $Show ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship5.column )_$( $GameMaster.ship5.row + $number )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid1."1_$( $GameMaster.ship5.column )_$( $GameMaster.ship5.row + $number )".BackColor = $GameMaster.colors.s5
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid1."1_$( $GameMaster.ship5.column )_$( $GameMaster.ship5.row + $number )".BackColor -eq $GameMaster.colors.s5) {
                            $GameMaster.grid1."1_$( $GameMaster.ship5.column )_$( $GameMaster.ship5.row + $number )".BackColor = $GameMaster.colors.water
                        }
                    }
                }
            }
        }
    } elseif (( $env:USERNAME -eq $GameMaster.opponentName ) -and ( $Grid -eq 2 )) {
        if ( $GameMaster.ship1.placed ) {
            foreach ( $number in 0..4 ) {
                if ( $GameMaster.ship1.direction ) {
                    if ( $Show ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship1.column + $number )_$( $GameMaster.ship1.row )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid2."2_$( $GameMaster.ship1.column + $number )_$( $GameMaster.ship1.row )".BackColor = $GameMaster.colors.s1
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship1.column + $number )_$( $GameMaster.ship1.row )".BackColor -eq $GameMaster.colors.s1) {
                            $GameMaster.grid2."2_$( $GameMaster.ship1.column + $number )_$( $GameMaster.ship1.row )".BackColor = $GameMaster.colors.water
                        }
                    }
                } else {
                    if ( $Show ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship1.column )_$( $GameMaster.ship1.row + $number )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid2."2_$( $GameMaster.ship1.column )_$( $GameMaster.ship1.row + $number )".BackColor = $GameMaster.colors.s1
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship1.column )_$( $GameMaster.ship1.row + $number )".BackColor -eq $GameMaster.colors.s1) {
                            $GameMaster.grid2."2_$( $GameMaster.ship1.column )_$( $GameMaster.ship1.row + $number )".BackColor = $GameMaster.colors.water
                        }
                    }
                }
            }
        }
 
        if ( $GameMaster.ship2.placed ) {
            foreach ( $number in 0..3 ) {
                if ( $GameMaster.ship2.direction ) {
                    if ( $Show ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship2.column + $number )_$( $GameMaster.ship2.row )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid2."2_$( $GameMaster.ship2.column + $number )_$( $GameMaster.ship2.row )".BackColor = $GameMaster.colors.s2
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship2.column + $number )_$( $GameMaster.ship2.row )".BackColor -eq $GameMaster.colors.s2) {
                            $GameMaster.grid2."2_$( $GameMaster.ship2.column + $number )_$( $GameMaster.ship2.row )".BackColor = $GameMaster.colors.water
                        }
                    }
                } else {
                    if ( $Show ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship2.column )_$( $GameMaster.ship2.row + $number )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid2."2_$( $GameMaster.ship2.column )_$( $GameMaster.ship2.row + $number )".BackColor = $GameMaster.colors.s2
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship2.column )_$( $GameMaster.ship2.row + $number )".BackColor -eq $GameMaster.colors.s2) {
                            $GameMaster.grid2."2_$( $GameMaster.ship2.column )_$( $GameMaster.ship2.row + $number )".BackColor = $GameMaster.colors.water
                        }
                    }
                }
            }
        }
 
        if ( $GameMaster.ship3.placed ) {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster.ship3.direction ) {
                    if ( $Show ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship3.column + $number )_$( $GameMaster.ship3.row )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid2."2_$( $GameMaster.ship3.column + $number )_$( $GameMaster.ship3.row )".BackColor = $GameMaster.colors.s3
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship3.column + $number )_$( $GameMaster.ship3.row )".BackColor -eq $GameMaster.colors.s3) {
                            $GameMaster.grid2."2_$( $GameMaster.ship3.column + $number )_$( $GameMaster.ship3.row )".BackColor = $GameMaster.colors.water
                        }
                    }
                } else {
                    if ( $Show ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship3.column )_$( $GameMaster.ship3.row + $number )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid2."2_$( $GameMaster.ship3.column )_$( $GameMaster.ship3.row + $number )".BackColor = $GameMaster.colors.s3
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship3.column )_$( $GameMaster.ship3.row + $number )".BackColor -eq $GameMaster.colors.s3) {
                            $GameMaster.grid2."2_$( $GameMaster.ship3.column )_$( $GameMaster.ship3.row + $number )".BackColor = $GameMaster.colors.water
                        }
                    }
                }
            }
        }
 
        if ( $GameMaster.ship4.placed ) {
            foreach ( $number in 0..2 ) {
                if ( $GameMaster.ship4.direction ) {
                    if ( $Show ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship4.column + $number )_$( $GameMaster.ship4.row )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid2."2_$( $GameMaster.ship4.column + $number )_$( $GameMaster.ship4.row )".BackColor = $GameMaster.colors.s4
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship4.column + $number )_$( $GameMaster.ship4.row )".BackColor -eq $GameMaster.colors.s4) {
                            $GameMaster.grid2."2_$( $GameMaster.ship4.column + $number )_$( $GameMaster.ship4.row )".BackColor = $GameMaster.colors.water
                        }
                    }
                } else {
                    if ( $Show ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship4.column )_$( $GameMaster.ship4.row + $number )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid2."2_$( $GameMaster.ship4.column )_$( $GameMaster.ship4.row + $number )".BackColor = $GameMaster.colors.s4
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship4.column )_$( $GameMaster.ship4.row + $number )".BackColor -eq $GameMaster.colors.s4) {
                            $GameMaster.grid2."2_$( $GameMaster.ship4.column )_$( $GameMaster.ship4.row + $number )".BackColor = $GameMaster.colors.water
                        }
                    }
                }
            }
       }
 
        if ( $GameMaster.ship5.placed ) {
            foreach ( $number in 0..1 ) {
                if ( $GameMaster.ship5.direction ) {
                    if ( $Show ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship5.column + $number )_$( $GameMaster.ship5.row )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid2."2_$( $GameMaster.ship5.column + $number )_$( $GameMaster.ship5.row )".BackColor = $GameMaster.colors.s5
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship5.column + $number )_$( $GameMaster.ship5.row )".BackColor -eq $GameMaster.colors.s5) {
                            $GameMaster.grid2."2_$( $GameMaster.ship5.column + $number )_$( $GameMaster.ship5.row )".BackColor = $GameMaster.colors.water
                        }
                    }
                } else {
                    if ( $Show ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship5.column )_$( $GameMaster.ship5.row + $number )".BackColor -eq $GameMaster.colors.water) {
                            $GameMaster.grid2."2_$( $GameMaster.ship5.column )_$( $GameMaster.ship5.row + $number )".BackColor = $GameMaster.colors.s5
                        }
                    } elseif ( $Hide ) {
                        if ($GameMaster.grid2."2_$( $GameMaster.ship5.column )_$( $GameMaster.ship5.row + $number )".BackColor -eq $GameMaster.colors.s5) {
                            $GameMaster.grid2."2_$( $GameMaster.ship5.column )_$( $GameMaster.ship5.row + $number )".BackColor = $GameMaster.colors.water
                        }
                    }
                }
            }
        }
    }
 
    return
}
 
function Set-Grid {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [switch]$Reset
    )
 
    if ( $Reset ) {
        foreach ( $row in 0..9 ) {
            foreach ( $column in 0..9 ) {
                $GameMaster.grid1."1_$( $column )_$( $row )".BackColor = $GameMaster.colors.water
                $GameMaster.grid2."2_$( $column )_$( $row )".BackColor = $GameMaster.colors.water
            }
        }
        return
    }
 
    foreach ( $property in $GameMaster.playerShots.PSObject.Properties ) {
        $GameMaster.grid2."2_$( $GameMaster.playerShots."$( $property.Name )".column )_$( $GameMaster.playerShots."$( $property.Name )".row )".BackColor = $GameMaster.colors.shot
    }
 
    foreach ( $property in $GameMaster.playerHits.PSObject.Properties ) {
        $GameMaster.grid2."2_$( $GameMaster.playerHits."$( $property.Name )".column )_$( $GameMaster.playerHits."$( $property.Name )".row )".BackColor = $GameMaster.colors.hit
    }
 
    foreach ( $property in $GameMaster.playerMisses.PSObject.Properties ) {
        $GameMaster.grid2."2_$( $GameMaster.playerMisses."$( $property.Name )".column )_$( $GameMaster.playerMisses."$( $property.Name )".row )".BackColor = $GameMaster.colors.miss
    }
 
    foreach ( $property in $GameMaster.opponentShots.PSObject.Properties ) {
        $GameMaster.grid1."1_$( $GameMaster.opponentShots."$( $property.Name )".column )_$( $GameMaster.opponentShots."$( $property.Name )".row )".BackColor = $GameMaster.colors.shot
    }
 
    foreach ( $property in $GameMaster.opponentHits.PSObject.Properties ) {
        $GameMaster.grid1."1_$( $GameMaster.opponentHits."$( $property.Name )".column )_$( $GameMaster.opponentHits."$( $property.Name )".row )".BackColor = $GameMaster.colors.hit
    }
 
    foreach ( $property in $GameMaster.opponentMisses.PSObject.Properties ) {
        $GameMaster.grid1."1_$( $GameMaster.opponentMisses."$( $property.Name )".column )_$( $GameMaster.opponentMisses."$( $property.Name )".row )".BackColor = $GameMaster.colors.miss
    }
 
    return
}
 
function Confirm-ShipSqaure {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Ship,
        [int]$Column,
        [int]$Row
    )
 
    $range = 0
 
    switch ( $Ship ) {
        1 { $range = 4 }
       2 { $range = 3 }
        3 { $range = 2 }
        4 { $range = 2 }
        5 { $range = 1 }
    }
 
    foreach ( $number in 0..$range ) {
        if ( $GameMaster."ship$( $Ship )".direction ) {
            if ((( $GameMaster."ship$( $Ship )".column + $number ) -eq $Column ) -and ( $GameMaster."ship$( $Ship )".row -eq $Row )) {
                return $true
            }
        } else {
            if (( $GameMaster."ship$( $Ship )".column  -eq $Column ) -and (( $GameMaster."ship$( $Ship )".row + $number ) -eq $Row )) {
                return $true
            }
        }
    }
 
    return $false
}
 
function Get-Turn {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    if ( $env:USERNAME -eq $GameMaster.playerName ) {
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.playerName ).clixml" ) {
            $inputObject = Import-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.playerName ).clixml"
 
            foreach ( $property in $inputObject.opponentShots.PSObject.Properties ) {
                if ( -not $inputObject.opponentShots."$( $property.Name )".checked ) {
                    if ( -not $GameMaster.opponentShots."$( $property.Name )" ) {
                        $GameMaster.opponentShots | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                        $GameMaster.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.opponentShots."$( $property.Name )".column )
                        $GameMaster.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.opponentShots."$( $property.Name )".row )
                        $GameMaster.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.opponentShots."$( $property.Name )".checked )
                    } else {
                        $GameMaster.opponentShots."$( $property.Name )".checked = $true
                    }
                    if ( Confirm-ShipSqaure -GameMaster $GameMaster -Ship 1 -Column $( $inputObject.opponentShots."$( $property.Name )".column ) -Row $( $inputObject.opponentShots."$( $property.Name )".row )) {
                        if ( -not $GameMaster.opponentHits."$( $property.Name )" ) {
                            $GameMaster.ship1.hits++
                            $GameMaster.opponentHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.opponentShots."$( $property.Name )".column )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.opponentShots."$( $property.Name )".row )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.opponentShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.opponentHits."$( $property.Name )".checked = $true
                        }
                    } elseif ( Confirm-ShipSqaure -GameMaster $GameMaster -Ship 2 -Column $( $inputObject.opponentShots."$( $property.Name )".column ) -Row $( $inputObject.opponentShots."$( $property.Name )".row )) {
                        if ( -not $GameMaster.opponentHits."$( $property.Name )" ) {
                            $GameMaster.ship2.hits++
                            $GameMaster.opponentHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.opponentShots."$( $property.Name )".column )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.opponentShots."$( $property.Name )".row )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.opponentShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.opponentHits."$( $property.Name )".checked = $true
                        }
                    } elseif ( Confirm-ShipSqaure -GameMaster $GameMaster -Ship 3 -Column $( $inputObject.opponentShots."$( $property.Name )".column ) -Row $( $inputObject.opponentShots."$( $property.Name )".row )) {
                        if ( -not $GameMaster.opponentHits."$( $property.Name )" ) {
                            $GameMaster.ship3.hits++
                            $GameMaster.opponentHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.opponentShots."$( $property.Name )".column )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.opponentShots."$( $property.Name )".row )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.opponentShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.opponentHits."$( $property.Name )".checked = $true
                        }
                    } elseif ( Confirm-ShipSqaure -GameMaster $GameMaster -Ship 4 -Column $( $inputObject.opponentShots."$( $property.Name )".column ) -Row $( $inputObject.opponentShots."$( $property.Name )".row )) {
                        if ( -not $GameMaster.opponentHits."$( $property.Name )" ) {
                            $GameMaster.ship4.hits++
                            $GameMaster.opponentHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.opponentShots."$( $property.Name )".column )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.opponentShots."$( $property.Name )".row )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.opponentShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.opponentHits."$( $property.Name )".checked = $true
                        }
                    } elseif ( Confirm-ShipSqaure -GameMaster $GameMaster -Ship 5 -Column $( $inputObject.opponentShots."$( $property.Name )".column ) -Row $( $inputObject.opponentShots."$( $property.Name )".row )) {
                        if ( -not $GameMaster.opponentHits."$( $property.Name )" ) {
                            $GameMaster.ship5.hits++
                            $GameMaster.opponentHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.opponentShots."$( $property.Name )".column )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.opponentShots."$( $property.Name )".row )
                            $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.opponentShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.opponentHits."$( $property.Name )".checked = $true
                        }
                    } else {
                        if ( -not $GameMaster.opponentMisses."$( $property.Name )" ) {
                            $GameMaster.opponentMisses | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.opponentShots."$( $property.Name )".column )
                            $GameMaster.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.opponentShots."$( $property.Name )".row )
                            $GameMaster.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.opponentShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.opponentMisses."$( $property.Name )".checked = $true
                        }
                    }
                    $GameMaster.opponentShots."$( $property.Name )".checked = $true
                }
            }
 
            foreach ( $property in $inputObject.playerShots.PSObject.Properties ) {
                if ( -not $GameMaster.playerShots."$( $property.Name )" ) {
                    $GameMaster.playerShots | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                    $GameMaster.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.playerShots."$( $property.Name )".column )
                    $GameMaster.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.playerShots."$( $property.Name )".row )
                    $GameMaster.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.playerShots."$( $property.Name )".checked )
                } else {
                    $GameMaster.playerShots."$( $property.Name )".checked = $true
                }
            }
            foreach ( $property in $inputObject.playerHits.PSObject.Properties ) {
                if ( -not $GameMaster.playerHits."$( $property.Name )" ) {
                    $GameMaster.playerHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                    $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.playerHits."$( $property.Name )".column )
                    $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.playerHits."$( $property.Name )".row )
                    $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.playerHits."$( $property.Name )".checked )
                } else {
                    $GameMaster.playerHits."$( $property.Name )".checked = $true
                }
            }
            foreach ( $property in $inputObject.playerMisses.PSObject.Properties ) {
                if ( -not $GameMaster.playerMisses."$( $property.Name )" ) {
                    $GameMaster.playerMisses | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                    $GameMaster.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.playerMisses."$( $property.Name )".column )
                    $GameMaster.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.playerMisses."$( $property.Name )".row )
                    $GameMaster.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.playerMisses."$( $property.Name )".checked )
                } else {
                    $GameMaster.playerMisses."$( $property.Name )".checked = $true
                }
            }
 
            $playerHitCount = 0
            foreach ( $property in $GameMaster.playerHits.PSObject.Properties ) {
                $playerHitCount++
            }
 
            $opponentHitCount = 0
            foreach ( $property in $GameMaster.opponentHits.PSObject.Properties ) {
                $opponentHitCount++
            }
 
            if ( $playerHitCount -ge $GameMaster.lives ) {
                Set-Win -GameMaster $GameMaster
                return
            } elseif ( $opponentHitCount -ge $GameMaster.lives ) {
                Set-Lose -GameMaster $GameMaster
                return
            }
 
            $GameMaster.infoLabel.Text = "Your Turn"
            $GameMaster.refreshTimer.Enabled = $false
 
            switch( $GameMaster.phase ) {
                0 { $GameMaster.infoLabel2.Text = "Click: Place ship;  Right Click: Rotate ship;" }
                1 { $GameMaster.infoLabel2.Text = "Click: Place shot;  Right Click: Remove last shot;  Enter: Send shots;" }
            }
 
            New-Notification
 
        } elseif ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponentName ).clixml" ) {
            $GameMaster.infoLabel.Text = "Opponent's Turn"
            $GameMaster.refreshTimer.Enabled = $true
 
            $GameMaster.infoLabel2.Text = "Hover over the S square in the top left of your grid to see your ships"
        } else {
            Out-Message -Type "Error" -Message "Failed to find necessary files"
        }
    } elseif ( $env:USERNAME -eq $GameMaster.opponentName ) {
        if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponentName ).clixml" ) {
            $inputObject = Import-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponentName ).clixml"
 
            foreach ( $property in $inputObject.playerShots.PSObject.Properties ) {
                if ( -not $inputObject.playerShots."$( $property.Name )".checked ) {
                    if ( -not $GameMaster.playerShots."$( $property.Name )" ) {
                        $GameMaster.playerShots | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                        $GameMaster.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.playerShots."$( $property.Name )".column )
                        $GameMaster.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.playerShots."$( $property.Name )".row )
                        $GameMaster.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.playerShots."$( $property.Name )".checked )
                    } else {
                        $GameMaster.playerShots."$( $property.Name )".checked = $true
                    }
                    if ( Confirm-ShipSqaure -GameMaster $GameMaster -Ship 1 -Column $( $inputObject.playerShots."$( $property.Name )".column ) -Row $( $inputObject.playerShots."$( $property.Name )".row )) {
                        if ( -not $GameMaster.playerHits."$( $property.Name )" ) {
                            $GameMaster.ship1.hits++
                            $GameMaster.playerHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.playerShots."$( $property.Name )".column )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.playerShots."$( $property.Name )".row )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.playerShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.playerHits."$( $property.Name )".checked = $true
                        }
                    } elseif ( Confirm-ShipSqaure -GameMaster $GameMaster -Ship 2 -Column $( $inputObject.playerShots."$( $property.Name )".column ) -Row $( $inputObject.playerShots."$( $property.Name )".row )) {
                        if ( -not $GameMaster.playerHits."$( $property.Name )" ) {
                            $GameMaster.ship2.hits++
                            $GameMaster.playerHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.playerShots."$( $property.Name )".column )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.playerShots."$( $property.Name )".row )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.playerShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.playerHits."$( $property.Name )".checked = $true
                        }
                    } elseif ( Confirm-ShipSqaure -GameMaster $GameMaster -Ship 3 -Column $( $inputObject.playerShots."$( $property.Name )".column ) -Row $( $inputObject.playerShots."$( $property.Name )".row )) {
                        if ( -not $GameMaster.playerHits."$( $property.Name )" ) {
                            $GameMaster.ship3.hits++
                            $GameMaster.playerHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.playerShots."$( $property.Name )".column )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.playerShots."$( $property.Name )".row )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.playerShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.playerHits."$( $property.Name )".checked = $true
                        }
                    } elseif ( Confirm-ShipSqaure -GameMaster $GameMaster -Ship 4 -Column $( $inputObject.playerShots."$( $property.Name )".column ) -Row $( $inputObject.playerShots."$( $property.Name )".row )) {
                        if ( -not $GameMaster.playerHits."$( $property.Name )" ) {
                            $GameMaster.ship4.hits++
                            $GameMaster.playerHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.playerShots."$( $property.Name )".column )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.playerShots."$( $property.Name )".row )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.playerShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.playerHits."$( $property.Name )".checked = $true
                        }
                    } elseif ( Confirm-ShipSqaure -GameMaster $GameMaster -Ship 5 -Column $( $inputObject.playerShots."$( $property.Name )".column ) -Row $( $inputObject.playerShots."$( $property.Name )".row )) {
                        if ( -not $GameMaster.playerHits."$( $property.Name )" ) {
                            $GameMaster.ship5.hits++
                            $GameMaster.playerHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.playerShots."$( $property.Name )".column )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.playerShots."$( $property.Name )".row )
                            $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.playerShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.playerHits."$( $property.Name )".checked = $true
                        }
                    } else {
                        if ( -not $GameMaster.playerMisses."$( $property.Name )" ) {
                            $GameMaster.playerMisses | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                            $GameMaster.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.playerShots."$( $property.Name )".column )
                            $GameMaster.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.playerShots."$( $property.Name )".row )
                            $GameMaster.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.playerShots."$( $property.Name )".checked )
                        } else {
                            $GameMaster.playerMisses."$( $property.Name )".checked = $true
                        }
                    }
                    $GameMaster.playerShots."$( $property.Name )".checked = $true
                }
            }
 
            foreach ( $property in $inputObject.opponentShots.PSObject.Properties ) {
                if ( -not $GameMaster.opponentShots."$( $property.Name )" ) {
                    $GameMaster.opponentShots | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                    $GameMaster.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.opponentShots."$( $property.Name )".column )
                    $GameMaster.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.opponentShots."$( $property.Name )".row )
                    $GameMaster.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.opponentShots."$( $property.Name )".checked )
                } else {
                    $GameMaster.opponentShots."$( $property.Name )".checked = $true
                }
            }
            foreach ( $property in $inputObject.opponentHits.PSObject.Properties ) {
                if ( -not $GameMaster.opponentHits."$( $property.Name )" ) {
                    $GameMaster.opponentHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                    $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.opponentHits."$( $property.Name )".column )
                    $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.opponentHits."$( $property.Name )".row )
                    $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.opponentHits."$( $property.Name )".checked )
                } else {
                    $GameMaster.opponentHits."$( $property.Name )".checked = $true
                }
            }
            foreach ( $property in $inputObject.opponentMisses.PSObject.Properties ) {
                if ( -not $GameMaster.opponentMisses."$( $property.Name )" ) {
                    $GameMaster.opponentMisses | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
                    $GameMaster.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $inputObject.opponentMisses."$( $property.Name )".column )
                    $GameMaster.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $inputObject.opponentMisses."$( $property.Name )".row )
                    $GameMaster.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $inputObject.opponentMisses."$( $property.Name )".checked )
                } else {
                    $GameMaster.opponentMisses."$( $property.Name )".checked = $true
                }
            }
 
            $playerHitCount = 0
            foreach ( $property in $GameMaster.playerHits.PSObject.Properties ) {
                $playerHitCount++
            }
 
            $opponentHitCount = 0
            foreach ( $property in $GameMaster.opponentHits.PSObject.Properties ) {
                $opponentHitCount++
            }
 
            if ( $opponentHitCount -ge $GameMaster.lives ) {
               Set-Win -GameMaster $GameMaster
                return
            } elseif ( $playerHitCount -ge $GameMaster.lives ) {
                Set-Lose -GameMaster $GameMaster
                return
            }
 
            $GameMaster.infoLabel.Text = "Your Turn"
            $GameMaster.refreshTimer.Enabled = $false
 
            switch( $GameMaster.phase ) {
                0 { $GameMaster.infoLabel2.Text = "Click: Place ship;  Right Click: Rotate ship;" }
                1 { $GameMaster.infoLabel2.Text = "Click: Place shot;  Right Click: Remove last shot;  Enter: Send shots;" }
            }
 
            New-Notification
 
        } elseif ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.playerName ).clixml" ) {
            $GameMaster.infoLabel.Text = "Opponent's Turn"
            $GameMaster.refreshTimer.Enabled = $true
 
            $GameMaster.infoLabel2.Text = "Hover over the S square in the top left of your grid to see your ships"
        } else {
            Out-Message -Type "Error" -Message "Failed to find necessary files"
        }
    }
    Set-Grid -GameMaster $GameMaster
 
    return
}
 
function Set-Win {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    Set-Grid -GameMaster $GameMaster
 
    $GameMaster.infoLabel.Text = "Congrats! You win!"
    $GameMaster.refreshTimer.Enabled = $false
    $GameMaster.end = $true
 
    $playerHitCount = 0
    foreach ( $property in $GameMaster.playerHits.PSObject.Properties ) {
        $playerHitCount++
    }
 
    $playerMissCount = 0
    foreach ( $property in $GameMaster.playerMisses.PSObject.Properties ) {
        $playerMissCount++
    }
 
    $opponentHitCount = 0
    foreach ( $property in $GameMaster.opponentHits.PSObject.Properties ) {
        $opponentHitCount++
    }
 
    $opponentMissCount = 0
    foreach ( $property in $GameMaster.opponentMisses.PSObject.Properties ) {
        $opponentMissCount++
    }
 
    if ( $env:USERNAME -eq $GameMaster.playerName ) {
        $scoreObject = [PSCustomObject]@{
            "Result of game" = "Win"
            "Your Total Hits" = $playerHitCount; "Your Total Misses" = $playerMissCount;
            "Opponent Total Hits" = $opponentHitCount; "Opponent Total Misses" = $opponentMissCount
        }
    } elseif ( $env:USERNAME -eq $GameMaster.opponentName ) {
        $scoreObject = [PSCustomObject]@{
            "Result of game" = "Win"
            "Your Total Hits" = $opponentHitCount; "Your Total Misses" = $opponentMissCount;
            "Opponent Total Hits" = $playerHitCount; "Opponent Total Misses" = $playerMissCount
        }
    }

    foreach ( $property in $scoreObject.PSObject.Properties ) {
        Write-Host "$( $property.Name ) = $( $property.Value )"
    }
 
    Close-Game -GameMaster $GameMaster
 
    return
}
 
function Set-Lose {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    Set-Grid -GameMaster $GameMaster
    Send-Game -GameMaster $GameMaster
 
    $GameMaster.infoLabel.Text = "You have lost. Better luck next time."
    $GameMaster.refreshTimer.Enabled = $false
    $GameMaster.end = $true
 
    $playerHitCount = 0
    foreach ( $property in $GameMaster.playerHits.PSObject.Properties ) {
        $playerHitCount++
    }
 
    $playerMissCount = 0
    foreach ( $property in $GameMaster.playerMisses.PSObject.Properties ) {
        $playerMissCount++
    }
 
    $opponentHitCount = 0
    foreach ( $property in $GameMaster.opponentHits.PSObject.Properties ) {
        $opponentHitCount++
    }
 
    $opponentMissCount = 0
    foreach ( $property in $GameMaster.opponentMisses.PSObject.Properties ) {
        $opponentMissCount++
    }
 
    if ( $env:USERNAME -eq $GameMaster.playerName ) {
        $scoreObject = [PSCustomObject]@{
            "Result of game" = "Lose"
            "Your Total Hits" = $playerHitCount; "Your Total Misses" = $playerMissCount;
            "Opponent Total Hits" = $opponentHitCount; "Opponent Total Misses" = $opponentMissCount
        }
    } elseif ( $env:USERNAME -eq $GameMaster.opponentName ) {
        $scoreObject = [PSCustomObject]@{
            "Result of game" = "Lose"
            "Your Total Hits" = $opponentHitCount; "Your Total Misses" = $opponentMissCount;
            "Opponent Total Hits" = $playerHitCount; "Opponent Total Misses" = $playerMissCount
        }
    }

    foreach ( $property in $scoreObject.PSObject.Properties ) {
        Write-Host "$( $property.Name ) = $( $property.Value )"
    }
 
    Close-Game -GameMaster $GameMaster
 
    return
}
 
function New-SaveObject {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$InputObject,
        [PSCustomObject]$SaveObject
    )
 
    $SaveObject.gameID = $InputObject.gameID
    $SaveObject.shotAmount = $InputObject.shotAmount
    $SaveObject.playerName = $InputObject.playerName
    $SaveObject.opponentName = $InputObject.opponentName
    $SaveObject.phase = $InputObject.phase
    $SaveObject.start = $InputObject.start
    $SaveObject.end = $InputObject.end
    $SaveObject.lives = $InputObject.lives
    $SaveObject.ship1.placed = $InputObject.ship1.placed
    $SaveObject.ship1.column = $InputObject.ship1.column
    $SaveObject.ship1.row = $InputObject.ship1.row
    $SaveObject.ship1.direction = $InputObject.ship1.direction
    $SaveObject.ship1.hits = $InputObject.ship1.hits
    $SaveObject.ship2.placed = $InputObject.ship2.placed
    $SaveObject.ship2.column = $InputObject.ship2.column
    $SaveObject.ship2.row = $InputObject.ship2.row
    $SaveObject.ship2.direction = $InputObject.ship2.direction
    $SaveObject.ship2.hits = $InputObject.ship2.hits
    $SaveObject.ship3.placed = $InputObject.ship3.placed
    $SaveObject.ship3.column = $InputObject.ship3.column
    $SaveObject.ship3.row = $InputObject.ship3.row
    $SaveObject.ship3.direction = $InputObject.ship3.direction
    $SaveObject.ship3.hits = $InputObject.ship3.hits
    $SaveObject.ship4.placed = $InputObject.ship4.placed
    $SaveObject.ship4.column = $InputObject.ship4.column
    $SaveObject.ship4.row = $InputObject.ship4.row
    $SaveObject.ship4.direction = $InputObject.ship4.direction
    $SaveObject.ship4.hits = $InputObject.ship4.hits
    $SaveObject.ship5.placed = $InputObject.ship5.placed
    $SaveObject.ship5.column = $InputObject.ship5.column
    $SaveObject.ship5.row = $InputObject.ship5.row
    $SaveObject.ship5.direction = $InputObject.ship5.direction
    $SaveObject.ship5.hits = $InputObject.ship5.hits
 
    foreach ( $property in $InputObject.playerShots.PSObject.Properties ) {
        $SaveObject.playerShots | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SaveObject.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.playerShots."$( $property.Name )".column )
        $SaveObject.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.playerShots."$( $property.Name )".row )
        $SaveObject.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.playerShots."$( $property.Name )".checked )
    }
 
    foreach ( $property in $InputObject.playerHits.PSObject.Properties ) {
        $SaveObject.playerHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SaveObject.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.playerHits."$( $property.Name )".column )
        $SaveObject.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.playerHits."$( $property.Name )".row )
        $SaveObject.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.playerHits."$( $property.Name )".checked )
    }
 
    foreach ( $property in $InputObject.playerMisses.PSObject.Properties ) {
        $SaveObject.playerMisses | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SaveObject.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.playerMisses."$( $property.Name )".column )
        $SaveObject.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.playerMisses."$( $property.Name )".row )
        $SaveObject.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.playerMisses."$( $property.Name )".checked )
    }
 
    foreach ( $property in $InputObject.opponentShots.PSObject.Properties ) {
        $SaveObject.opponentShots | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SaveObject.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.opponentShots."$( $property.Name )".column )
        $SaveObject.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.opponentShots."$( $property.Name )".row )
        $SaveObject.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.opponentShots."$( $property.Name )".checked )
    }
 
    foreach ( $property in $InputObject.opponentHits.PSObject.Properties ) {
        $SaveObject.opponentHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SaveObject.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.opponentHits."$( $property.Name )".column )
        $SaveObject.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.opponentHits."$( $property.Name )".row )
        $SaveObject.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.opponentHits."$( $property.Name )".checked )
    }
 
    foreach ( $property in $InputObject.opponentMisses.PSObject.Properties ) {
        $SaveObject.opponentMisses | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SaveObject.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.opponentMisses."$( $property.Name )".column )
        $SaveObject.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.opponentMisses."$( $property.Name )".row )
        $SaveObject.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.opponentMisses."$( $property.Name )".checked )
    }
 
    return
}
 
function New-SendObject {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$InputObject,
        [PSCustomObject]$SendObject
    )
 
    foreach ( $property in $InputObject.playerShots.PSObject.Properties ) {
        $SendObject.playerShots | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SendObject.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.playerShots."$( $property.Name )".column )
        $SendObject.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.playerShots."$( $property.Name )".row )
        $SendObject.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.playerShots."$( $property.Name )".checked )
    }
 
    foreach ( $property in $InputObject.playerHits.PSObject.Properties ) {
        $SendObject.playerHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SendObject.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.playerHits."$( $property.Name )".column )
        $SendObject.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.playerHits."$( $property.Name )".row )
        $SendObject.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.playerHits."$( $property.Name )".checked )
    }
 
    foreach ( $property in $InputObject.playerMisses.PSObject.Properties ) {
        $SendObject.playerMisses | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SendObject.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.playerMisses."$( $property.Name )".column )
        $SendObject.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.playerMisses."$( $property.Name )".row )
        $SendObject.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.playerMisses."$( $property.Name )".checked )
    }
 
    foreach ( $property in $InputObject.opponentShots.PSObject.Properties ) {
        $SendObject.opponentShots | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SendObject.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.opponentShots."$( $property.Name )".column )
        $SendObject.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.opponentShots."$( $property.Name )".row )
        $SendObject.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.opponentShots."$( $property.Name )".checked )
    }
 
    foreach ( $property in $InputObject.opponentHits.PSObject.Properties ) {
        $SendObject.opponentHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SendObject.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.opponentHits."$( $property.Name )".column )
        $SendObject.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.opponentHits."$( $property.Name )".row )
        $SendObject.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.opponentHits."$( $property.Name )".checked )
    }
 
    foreach ( $property in $InputObject.opponentMisses.PSObject.Properties ) {
        $SendObject.opponentMisses | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $SendObject.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $InputObject.opponentMisses."$( $property.Name )".column )
        $SendObject.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $InputObject.opponentMisses."$( $property.Name )".row )
        $SendObject.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $InputObject.opponentMisses."$( $property.Name )".checked )
    }
 
    return
}
 
function Copy-SaveToGameMaster {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [PSCustomObject]$SaveObject
    )
 
    $GameMaster.gameID = $SaveObject.gameID
    $GameMaster.shotAmount = $SaveObject.shotAmount
    $GameMaster.playerName = $SaveObject.playerName
    $GameMaster.opponentName = $SaveObject.opponentName
    $GameMaster.phase = $SaveObject.phase
    $GameMaster.start = $SaveObject.start
    $GameMaster.end = $SaveObject.end
    $GameMaster.lives = $SaveObject.lives
    $GameMaster.ship1.placed = $SaveObject.ship1.placed
    $GameMaster.ship1.column = $SaveObject.ship1.column
    $GameMaster.ship1.row = $SaveObject.ship1.row
    $GameMaster.ship1.direction = $SaveObject.ship1.direction
    $GameMaster.ship1.hits = $SaveObject.ship1.hits
    $GameMaster.ship2.placed = $SaveObject.ship2.placed
    $GameMaster.ship2.column = $SaveObject.ship2.column
    $GameMaster.ship2.row = $SaveObject.ship2.row
    $GameMaster.ship2.direction = $SaveObject.ship2.direction
    $GameMaster.ship2.hits = $SaveObject.ship2.hits
    $GameMaster.ship3.placed = $SaveObject.ship3.placed
    $GameMaster.ship3.column = $SaveObject.ship3.column
    $GameMaster.ship3.row = $SaveObject.ship3.row
    $GameMaster.ship3.direction = $SaveObject.ship3.direction
    $GameMaster.ship3.hits = $SaveObject.ship3.hits
    $GameMaster.ship4.placed = $SaveObject.ship4.placed
    $GameMaster.ship4.column = $SaveObject.ship4.column
    $GameMaster.ship4.row = $SaveObject.ship4.row
    $GameMaster.ship4.direction = $SaveObject.ship4.direction
    $GameMaster.ship4.hits = $SaveObject.ship4.hits
    $GameMaster.ship5.placed = $SaveObject.ship5.placed
    $GameMaster.ship5.column = $SaveObject.ship5.column
    $GameMaster.ship5.row = $SaveObject.ship5.row
    $GameMaster.ship5.direction = $SaveObject.ship5.direction
    $GameMaster.ship5.hits = $SaveObject.ship5.hits
 
    foreach ( $property in $SaveObject.playerShots.PSObject.Properties ) {
        $GameMaster.playerShots | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $GameMaster.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $SaveObject.playerShots."$( $property.Name )".column )
        $GameMaster.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $SaveObject.playerShots."$( $property.Name )".row )
        $GameMaster.playerShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $SaveObject.playerShots."$( $property.Name )".checked )
    }
 
    foreach ( $property in $SaveObject.playerHits.PSObject.Properties ) {
        $GameMaster.playerHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $SaveObject.playerHits."$( $property.Name )".column )
        $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $SaveObject.playerHits."$( $property.Name )".row )
        $GameMaster.playerHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $SaveObject.playerHits."$( $property.Name )".checked )
    }
 
    foreach ( $property in $SaveObject.playerMisses.PSObject.Properties ) {
        $GameMaster.playerMisses | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $GameMaster.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $SaveObject.playerMisses."$( $property.Name )".column )
        $GameMaster.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $SaveObject.playerMisses."$( $property.Name )".row )
        $GameMaster.playerMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $SaveObject.playerMisses."$( $property.Name )".checked )
    }
 
    foreach ( $property in $SaveObject.opponentShots.PSObject.Properties ) {
        $GameMaster.opponentShots | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $GameMaster.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $SaveObject.opponentShots."$( $property.Name )".column )
        $GameMaster.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $SaveObject.opponentShots."$( $property.Name )".row )
        $GameMaster.opponentShots."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $SaveObject.opponentShots."$( $property.Name )".checked )
    }
 
    foreach ( $property in $SaveObject.opponentHits.PSObject.Properties ) {
        $GameMaster.opponentHits | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $SaveObject.opponentHits."$( $property.Name )".column )
        $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $SaveObject.opponentHits."$( $property.Name )".row )
        $GameMaster.opponentHits."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $SaveObject.opponentHits."$( $property.Name )".checked )
    }
 
    foreach ( $property in $SaveObject.opponentMisses.PSObject.Properties ) {
        $GameMaster.opponentMisses | Add-Member -MemberType NoteProperty -Name "$( $property.Name )" -Value $( [PSCustomObject]@{} )
        $GameMaster.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "column" -Value $( $SaveObject.opponentMisses."$( $property.Name )".column )
        $GameMaster.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "row" -Value $( $SaveObject.opponentMisses."$( $property.Name )".row )
        $GameMaster.opponentMisses."$( $property.Name )" | Add-Member -MemberType NoteProperty -Name "checked" -Value $( $SaveObject.opponentMisses."$( $property.Name )".checked )
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
        $GameMaster.opponentName = Get-UserInput -Message "Please enter your oppenent's sAMAccountName"
        try {
            $GameMaster.opponentName = ( Get-ADUser -Identity "$( $GameMaster.opponentName )" -ErrorAction Stop |
                Select-Object -ExpandProperty sAMAccountName )
            break
        } catch {
            if ( $GameMaster.opponent.name -eq "cancel" ) {
                Out-Message -Type "Notice" -Message "New Game cancelled"
                return
            }
            Out-Message -Type "Error" -Message "Invalid sAMAccountName"
        }
    }
 
    Set-Grid -GameMaster $GameMaster -Reset
 
    foreach ( $property in $GameMaster.playerShots.PSObject.Properties ) {
        $GameMaster.playerShots.psobject.properties.remove( "$( $property.Name )" )
    }
    foreach ( $property in $GameMaster.playerHits.PSObject.Properties ) {
        $GameMaster.playerHits.psobject.properties.remove( "$( $property.Name )" )
    }
    foreach ( $property in $GameMaster.playerMisses.PSObject.Properties ) {
        $GameMaster.playerMisses.psobject.properties.remove( "$( $property.Name )" )
    }
    foreach ( $property in $GameMaster.opponentShots.PSObject.Properties ) {
        $GameMaster.opponentShots.psobject.properties.remove( "$( $property.Name )" )
    }
    foreach ( $property in $GameMaster.opponentHits.PSObject.Properties ) {
        $GameMaster.opponentHits.psobject.properties.remove( "$( $property.Name )" )
    }
    foreach ( $property in $GameMaster.opponentMisses.PSObject.Properties ) {
        $GameMaster.opponentMisses.psobject.properties.remove( "$( $property.Name )" )
    }
 
    $GameMaster.start = $true
    $GameMaster.infoLabel.Text = "Your Turn"
    $GameMaster.infoLabel2.Text = "Click: Place ship;  Right Click: Rotate ship;"
 
    $GameMaster.playerLabel.Text = $GameMaster.playerName
    $GameMaster.opponentLabel.Text = $GameMaster.opponentName
 
    $saveObject = [PSCustomObject]@{
        gameID = $null
        shotAmount = $null
        playerName = $null
        playerShots = [PSCustomObject]@{}
        playerHits = [PSCustomObject]@{}
        playerMisses = [PSCustomObject]@{}
        opponentName = $null
        opponentShots = [PSCustomObject]@{}
        opponentHits = [PSCustomObject]@{}
        opponentMisses = [PSCustomObject]@{}
        phase = $null
        start = $null
        end = $null
        lives = $null
        ship1 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
        ship2 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
        ship3 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
        ship4 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
        ship5 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
    }
 
    New-SaveObject -InputObject $GameMaster -SaveObject $saveObject
 
    $saveObject | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.playerName ).clixml" -Force
    $saveObject | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponentName ).clixml" -Force   
 
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
 
                $saveObject = [PSCustomObject]@{
                    gameID = $null
                    shotAmount = $null
                    playerName = $null
                    playerShots = [PSCustomObject]@{}
                    playerHits = [PSCustomObject]@{}
                    playerMisses = [PSCustomObject]@{}
                    opponentName = $null
                    opponentShots = [PSCustomObject]@{}
                    opponentHits = [PSCustomObject]@{}
                    opponentMisses = [PSCustomObject]@{}
                    phase = $null
                    start = $null
                    end = $null
                    lives = $null
                    ship1 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
                    ship2 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
                    ship3 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
                    ship4 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
                    ship5 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
                }
 
                New-SaveObject -InputObject $inputObject -SaveObject $saveObject
 
                Copy-SaveToGameMaster -GameMaster $GameMaster -SaveObject $saveObject
 
                Set-Grid -GameMaster $GameMaster
 
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
 
    $GameMaster.playerLabel.Text = $GameMaster.playerName
    $GameMaster.opponentLabel.Text = $GameMaster.opponentName
 
    Set-Grid -GameMaster $GameMaster -Reset
 
    Get-Turn -GameMaster $GameMaster
 
    return
}
 
function Send-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    $sendObject = [PSCustomObject]@{
        playerShots = [PSCustomObject]@{}
        playerHits = [PSCustomObject]@{}
        playerMisses = [PSCustomObject]@{}
        opponentShots = [PSCustomObject]@{}
        opponentHits = [PSCustomObject]@{}
        opponentMisses = [PSCustomObject]@{}
    }
 
    New-SendObject -InputObject $GameMaster -SendObject $sendObject
 
    $saveObject = [PSCustomObject]@{
        gameID = $null
        shotAmount = $null
        playerName = $null
        playerShots = [PSCustomObject]@{}
        playerHits = [PSCustomObject]@{}
        playerMisses = [PSCustomObject]@{}
        opponentName = $null
        opponentShots = [PSCustomObject]@{}
        opponentHits = [PSCustomObject]@{}
        opponentMisses = [PSCustomObject]@{}
        phase = $null
        start = $null
        end = $null
        lives = $null
        ship1 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
        ship2 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
        ship3 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
        ship4 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
        ship5 = [PSCustomObject]@{ placed = $null; column = $null; row = $null; direction = $null; hits = $null }
    }
 
    New-SaveObject -InputObject $GameMaster -SaveObject $saveObject
 
    if ( $env:USERNAME -eq $GameMaster.playerName ) {
        $saveObject | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.playerName ).clixml" -Force
        $sendObject | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponentName ).clixml" -Force
        $count = 0
        while ( $true ) {
            $count++
            if ( $count -ge 25 ) {
                break
            }
            try {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.playerName ).clixml" -Force -ErrorAction Stop
            } catch {
                continue
            }
            break
        }
 
        foreach ( $property in $GameMaster.playerShots.PSObject.Properties ) {
            $GameMaster.playerShots.psobject.properties.remove( "$( $property.Name )" )
        }
 
    } elseif ( $env:USERNAME -eq $GameMaster.opponentName ) {
        $saveObject | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponentName ).clixml" -Force
        $sendObject | Export-Clixml -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.playerName ).clixml" -Force
        $count = 0
        while ( $true ) {
            $count++
            if ( $count -ge 25 ) {
                break
            }
            try {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponentName ).clixml" -Force -ErrorAction Stop
            } catch {
                continue
            }
            break
        }
 
        foreach ( $property in $GameMaster.opponentShots.PSObject.Properties ) {
            $GameMaster.opponentShots.psobject.properties.remove( "$( $property.Name )" )
        }
    }
 
    $GameMaster.refreshTimer.Enabled = $true
    $GameMaster.infoLabel.Text = "Opponent's Turn"
    $GameMaster.infoLabel2.Text = "Hover over the S square in the top left of your grid to see your ships"
 
    return
}
 
function Close-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    if ( $GameMaster.end ) {
        if ( $env:USERNAME -eq $GameMaster.playerName ) {
            if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.playerName ).clixml" ) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.playerName ).clixml" -Force
            }
            if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.playerName ).clixml" ) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.playerName ).clixml" -Force
            }
            if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponentName ).clixml" )) {
                if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponentName ).clixml" )) {
                    Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -Force
                }
            }
 
        } elseif ( $env:USERNAME -eq $GameMaster.opponentName ) {
            if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponentName ).clixml" ) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.opponentName ).clixml" -Force
            }
            if ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponentName ).clixml" ) {
                Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.opponentName ).clixml" -Force
            }
            if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\$( $GameMaster.playerName ).clixml" )) {
                if ( -not ( Test-Path -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )\To$( $GameMaster.playerName ).clixml" )) {
                    Remove-Item -Path "$( $GameMaster.networkPath )\$( $GameMaster.gameID )" -Force
                }
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
    $notification.BalloonTipText = "It is your turn in Battleship"
    $notification.BalloonTipTitle = "Battleship"
    $notification.Visible = $true
    $notification.ShowBalloonTip(3000)
}
 
$gameMaster = [PSCustomObject]@{
    gameID = $null
    shotAmount = 3
    playerName = $env:USERNAME
    playerLabel = [System.Windows.Forms.Label]::new()
    playerShots = [PSCustomObject]@{}
    playerHits = [PSCustomObject]@{}
    playerMisses = [PSCustomObject]@{}
    opponentName = ""
    opponentLabel = [System.Windows.Forms.Label]::new()
    opponentShots = [PSCustomObject]@{}
    opponentHits = [PSCustomObject]@{}
    opponentMisses = [PSCustomObject]@{}
    phase = 0
    start = $false
    end = $false
    lives = 17
    networkPath = $networkPath
    infoLabel = [System.Windows.Forms.Label]::new()
    infoLabel2 = [System.Windows.Forms.Label]::new()
    refreshTimer = [System.Timers.Timer]::new()
    grid1 = [PSCustomObject]@{}
    grid2 = [PSCustomObject]@{}
    ship1 = [PSCustomObject]@{ name = "Carrier"; size = 5; placed = $false; column = 0; row = 0; direction = $true; hits = 0 }
    ship2 = [PSCustomObject]@{ name = "Battleship"; size = 4; placed = $false; column = 0; row = 0; direction = $true; hits = 0 }
    ship3 = [PSCustomObject]@{ name = "Destroyer"; size = 3; placed = $false; column = 0; row = 0; direction = $true; hits = 0 }
    ship4 = [PSCustomObject]@{ name = "Submarine"; size = 3; placed = $false; column = 0; row = 0; direction = $true; hits = 0 }
    ship5 = [PSCustomObject]@{ name = "Scout"; size = 2; placed = $false; column = 0; row = 0; direction = $true; hits = 0 }
    colors = [PSCustomObject]@{
        shot = $null
        hit = $null
        miss = $null
        header = $null
        selected = $null
        water = $null
        s1 = $null
        s2 = $null
        s3 = $null
        s4 = $null
        s5 = $null
    }
}
 
Set-Colors -GameMaster $gameMaster
 
$form = [System.Windows.Forms.Form]::new()
$form.Text = "Battleship"
$form.Add_FormClosing({
    Close-Game -GameMaster $gameMaster
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
 
$outerPanelPlayerGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$middlePanelPlayerGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$middlePanelPlayerGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$playerBlankLabel = [System.Windows.Forms.Label]::new()
$playerBlankLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$playerBlankLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$playerBlankLabel.Text = " "
$playerBlankCell = [System.Windows.Forms.TableLayoutPanel]::new()
$playerBlankCell.RowCount = 1
$playerBlankCell.ColumnCount = 1
$playerBlankCell.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$playerBlankCellLabel = [System.Windows.Forms.Label]::new()
$playerBlankCellLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$playerBlankCellLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$playerBlankCellLabel.Text = "S"
$playerBlankCellLabel.Size = [System.Drawing.Size]::new( 50, 50 )
$playerBlankCellLabel.Padding = [System.Windows.Forms.Padding]::new( 0 )
$playerBlankCellLabel.Margin = [System.Windows.Forms.Padding]::new( 0 )
$playerBlankCellLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$playerBlankCellLabel.Name = "S"
$playerBlankCellLabel.Add_MouseEnter({ Set-Ships -GameMaster $gameMaster -Grid 1 -Show })
$playerBlankCellLabel.Add_MouseLeave({ Set-Ships -GameMaster $gameMaster -Grid 1 -Hide })
$playerBlankCell.SetCellPosition( $playerBlankCellLabel, [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 0, 0 ))
$playerBlankCell.Controls.Add( $playerBlankCellLabel )
$innerPanelPlayerNumbers = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelPlayerNumbers.RowCount = 10
$innerPanelPlayerNumbers.ColumnCount = 1
$innerPanelPlayerNumbers.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$innerPanelPlayerLetters = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelPlayerLetters.RowCount = 1
$innerPanelPlayerLetters.ColumnCount = 10
$innerPanelPlayerLetters.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$innerPanelPlayerGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelPlayerGrid.RowCount = 10
$innerPanelPlayerGrid.ColumnCount = 10
$innerPanelPlayerGrid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$gameMaster.playerLabel = [System.Windows.Forms.Label]::new()
$gameMaster.playerLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.playerLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.playerLabel.Text = "Player"
$outerPanelPlayerGrid.Controls.Add( $middlePanelPlayerGrid ) | Out-Null
$middlePanelPlayerGrid.Controls.Add( $playerBlankLabel ) | Out-Null
$middlePanelPlayerGrid.Controls.Add( $playerBlankCell ) | Out-Null
$middlePanelPlayerGrid.Controls.Add( $innerPanelPlayerNumbers ) | Out-Null
$middlePanelPlayerGrid.Controls.Add( $gameMaster.playerLabel ) | Out-Null
$middlePanelPlayerGrid.Controls.Add( $innerPanelPlayerLetters ) | Out-Null
$middlePanelPlayerGrid.Controls.Add( $innerPanelPlayerGrid ) | Out-Null
$middlePanelPlayerGrid.SetFlowBreak( $innerPanelPlayerNumbers, $true )
$mainPanel.Controls.Add( $outerPanelPlayerGrid ) | Out-Null
 
$outerPanelOpponentGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$middlePanelOpponentGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$middlePanelOpponentGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$opponentBlankLabel = [System.Windows.Forms.Label]::new()
$opponentBlankLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$opponentBlankLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$opponentBlankLabel.Text = " "
$opponentBlankCell = [System.Windows.Forms.TableLayoutPanel]::new()
$opponentBlankCell.RowCount = 1
$opponentBlankCell.ColumnCount = 1
$opponentBlankCell.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$opponentBlankCellLabel = [System.Windows.Forms.Label]::new()
$opponentBlankCellLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$opponentBlankCellLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$opponentBlankCellLabel.Text = "S"
$opponentBlankCellLabel.Size = [System.Drawing.Size]::new( 50, 50 )
$opponentBlankCellLabel.Padding = [System.Windows.Forms.Padding]::new( 0 )
$opponentBlankCellLabel.Margin = [System.Windows.Forms.Padding]::new( 0 )
$opponentBlankCellLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$opponentBlankCellLabel.Name = "S"
$opponentBlankCellLabel.Add_MouseEnter({ Set-Ships -GameMaster $gameMaster -Grid 2 -Show })
$opponentBlankCellLabel.Add_MouseLeave({ Set-Ships -GameMaster $gameMaster -Grid 2 -Hide })
$opponentBlankCell.SetCellPosition( $opponentBlankCellLabel, [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 0, 0 ))
$opponentBlankCell.Controls.Add( $opponentBlankCellLabel )
$innerPanelOpponentNumbers = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelOpponentNumbers.RowCount = 10
$innerPanelOpponentNumbers.ColumnCount = 1
$innerPanelOpponentNumbers.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$innerPanelOpponentLetters = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelOpponentLetters.RowCount = 1
$innerPanelOpponentLetters.ColumnCount = 10
$innerPanelOpponentLetters.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$innerPanelOpponentGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelOpponentGrid.RowCount = 10
$innerPanelOpponentGrid.ColumnCount = 10
$innerPanelOpponentGrid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$gameMaster.opponentLabel = [System.Windows.Forms.Label]::new()
$gameMaster.opponentLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.opponentLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.opponentLabel.Text = "Opponent"
$outerPanelOpponentGrid.Controls.Add( $middlePanelOpponentGrid ) | Out-Null
$middlePanelOpponentGrid.Controls.Add( $opponentBlankLabel ) | Out-Null
$middlePanelOpponentGrid.Controls.Add( $opponentBlankCell ) | Out-Null
$middlePanelOpponentGrid.Controls.Add( $innerPanelOpponentNumbers ) | Out-Null
$middlePanelOpponentGrid.Controls.Add( $gameMaster.opponentLabel ) | Out-Null
$middlePanelOpponentGrid.Controls.Add( $innerPanelOpponentLetters ) | Out-Null
$middlePanelOpponentGrid.Controls.Add( $innerPanelOpponentGrid ) | Out-Null
$middlePanelOpponentGrid.SetFlowBreak( $innerPanelOpponentNumbers, $true )
$mainPanel.Controls.Add( $outerPanelOpponentGrid ) | Out-Null
$mainPanel.SetFlowBreak( $outerPanelOpponentGrid, $true )
 
$gameMaster.infoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel.Text = "Battleship"
$mainPanel.Controls.Add( $GameMaster.infoLabel ) | Out-Null
$mainPanel.SetFlowBreak( $GameMaster.infoLabel, $true )
 
$gameMaster.infoLabel2.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel2.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel2.Text = " "
$mainPanel.Controls.Add( $GameMaster.infoLabel2 ) | Out-Null
 
$gameMaster.refreshTimer.AutoReset = $false
$gameMaster.refreshTimer.Enabled = $false
$gameMaster.refreshTimer.Interval = 15000
$gameMaster.refreshTimer.SynchronizingObject = $form
$gameMaster.refreshTimer.Add_Elapsed({
    Get-Turn -GameMaster $GameMaster
})
 
foreach ( $number in 1..10 ) {
    try {
        New-Variable -Name "playerLabelNumber$( $number )" -Value $( [System.Windows.Forms.Label]::new() ) -ErrorAction Stop
    } catch {
        Remove-Variable -Name "playerLabelNumber$( $number )" -Force
        New-Variable -Name "playerLabelNumber$( $number )" -Value $( [System.Windows.Forms.Label]::new() )
    }
 
    $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly).TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly).Font = [System.Drawing.Font]::new( "Verdana", 14 )
    $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly).Text = "$( $number )"
    $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly).Size = [System.Drawing.Size]::new( 50, 50 )
    $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly).Padding = [System.Windows.Forms.Padding]::new( 0 )
    $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly).Margin = [System.Windows.Forms.Padding]::new( 0 )
    $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly).Dock = [System.Windows.Forms.DockStyle]::Fill
    $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly).Name = "$( $number )"
    $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly).BackColor = $gameMaster.colors.header
    $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 0, ( $number - 1 ))
    $innerPanelPlayerNumbers.SetCellPosition( $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly), $cellPosition )
    $innerPanelPlayerNumbers.Controls.Add( $(Get-Variable -Name "playerLabelNumber$( $number )" -ValueOnly ))
 
    try {
        New-Variable -Name "opponentLabelNumber$( $number )" -Value $( [System.Windows.Forms.Label]::new() ) -ErrorAction Stop
    } catch {
        Remove-Variable -Name "opponentLabelNumber$( $number )" -Force
        New-Variable -Name "opponentLabelNumber$( $number )" -Value $( [System.Windows.Forms.Label]::new() )
    }
 
    $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly).TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly).Font = [System.Drawing.Font]::new( "Verdana", 14 )
    $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly).Text = "$( $number )"
    $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly).Size = [System.Drawing.Size]::new( 50, 50 )
    $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly).Padding = [System.Windows.Forms.Padding]::new( 0 )
    $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly).Margin = [System.Windows.Forms.Padding]::new( 0 )
    $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly).Dock = [System.Windows.Forms.DockStyle]::Fill
    $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly).Name = "$( $number )"
    $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly).BackColor = $gameMaster.colors.header
    $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 0, ( $number - 1 ))
    $innerPanelOpponentNumbers.SetCellPosition( $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly), $cellPosition )
    $innerPanelOpponentNumbers.Controls.Add( $(Get-Variable -Name "opponentLabelNumber$( $number )" -ValueOnly ))
}
 
foreach ( $letter in 65..74 ) {
    try {
        New-Variable -Name "playerLabelLetter$( [char]$letter )" -Value $( [System.Windows.Forms.Label]::new() ) -ErrorAction Stop
    } catch {
        Remove-Variable -Name "playerLabelLetter$( [char]$letter )" -Force
        New-Variable -Name "playerLabelLetter$( [char]$letter )" -Value $( [System.Windows.Forms.Label]::new() )
    }
 
    $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly).TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly).Font = [System.Drawing.Font]::new( "Verdana", 14 )
    $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly).Text = "$( [char]$letter )"
    $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly).Size = [System.Drawing.Size]::new( 50, 50 )
    $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly).Padding = [System.Windows.Forms.Padding]::new( 0 )
    $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly).Margin = [System.Windows.Forms.Padding]::new( 0 )
    $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly).Dock = [System.Windows.Forms.DockStyle]::Fill
    $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly).Name = "$( [char]$letter )"
    $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly).BackColor = $gameMaster.colors.header
    $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new(( $letter - 65 ), 0 )
    $innerPanelPlayerLetters.SetCellPosition( $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly), $cellPosition )
    $innerPanelPlayerLetters.Controls.Add( $(Get-Variable -Name "playerLabelLetter$( [char]$letter )" -ValueOnly ))
 
    try {
        New-Variable -Name "opponentLabelLetter$( [char]$letter )" -Value $( [System.Windows.Forms.Label]::new() ) -ErrorAction Stop
    } catch {
        Remove-Variable -Name "opponentLabelLetter$( [char]$letter )" -Force
        New-Variable -Name "opponentLabelLetter$( [char]$letter )" -Value $( [System.Windows.Forms.Label]::new() )
    }
 
    $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly).TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly).Font = [System.Drawing.Font]::new( "Verdana", 14 )
    $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly).Text = "$( [char]$letter )"
    $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly).Size = [System.Drawing.Size]::new( 50, 50 )
    $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly).Padding = [System.Windows.Forms.Padding]::new( 0 )
    $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly).Margin = [System.Windows.Forms.Padding]::new( 0 )
    $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly).Dock = [System.Windows.Forms.DockStyle]::Fill
    $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly).Name = "$( [char]$letter )"
    $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly).BackColor = $gameMaster.colors.header
    $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new(( $letter - 65 ), 0 )
    $innerPanelOpponentLetters.SetCellPosition( $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly), $cellPosition )
    $innerPanelOpponentLetters.Controls.Add( $(Get-Variable -Name "opponentLabelLetter$( [char]$letter )" -ValueOnly ))
}
 
foreach ( $row in 0..9 ) {
    foreach ( $column in 0..9 ) {
        Try {
            $gameMaster.grid1 | Add-Member -MemberType NoteProperty -Name "1_$( $column )_$($row )" -Value $([System.Windows.Forms.Label]::new()) -ErrorAction Stop
        } Catch {
            $gameMaster.grid1.psobject.properties.remove( "1_$( $column )_$( $row )" )
            $gameMaster.grid1 | Add-Member -MemberType NoteProperty -Name "1_$( $column )_$( $row )" -Value $([System.Windows.Forms.Label]::new())
        }
        $gameMaster.grid1."1_$( $column )_$( $row )".TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $gameMaster.grid1."1_$( $column )_$( $row )".Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $gameMaster.grid1."1_$( $column )_$( $row )".Size = [System.Drawing.Size]::new( 50, 50 )
        $gameMaster.grid1."1_$( $column )_$( $row )".Padding = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid1."1_$( $column )_$( $row )".Margin = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid1."1_$( $column )_$( $row )".Dock = [System.Windows.Forms.DockStyle]::Fill
        $gameMaster.grid1."1_$( $column )_$( $row )".Name = "1_$( $column )_$( $row )"
        $gameMaster.grid1."1_$( $column )_$( $row )".Text = ""
        $gameMaster.grid1."1_$( $column )_$( $row )".BackColor = $gameMaster.colors.water
        $gameMaster.grid1."1_$( $column )_$( $row )".Add_MouseClick({
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseClick -GameMaster $gameMaster -Name $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseClick -GameMaster $gameMaster -Name $this.Name -Right
            }
        })
        $gameMaster.grid1."1_$( $column )_$( $row )".Add_MouseEnter({
            New-MouseEnter -GameMaster $gameMaster -Name $this.Name
        })
        $gameMaster.grid1."1_$( $column )_$( $row )".Add_MouseLeave({
            New-MouseLeave -GameMaster $gameMaster -Name $this.Name
        })
        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $innerPanelPlayerGrid.SetCellPosition( $gameMaster.grid1."1_$( $column )_$( $row )", $cellPosition )
        $innerPanelPlayerGrid.Controls.Add( $gameMaster.grid1."1_$( $column )_$( $row )" )
 
        Try {
            $gameMaster.grid2 | Add-Member -MemberType NoteProperty -Name "2_$( $column )_$($row )" -Value $([System.Windows.Forms.Label]::new()) -ErrorAction Stop
        } Catch {
            $gameMaster.grid2.psobject.properties.remove( "2_$( $column )_$( $row )" )
            $gameMaster.grid2 | Add-Member -MemberType NoteProperty -Name "2_$( $column)_$( $row )" -Value $([System.Windows.Forms.Label]::new())
        }
        $gameMaster.grid2."2_$( $column )_$( $row )".TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $gameMaster.grid2."2_$( $column )_$( $row )".Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $gameMaster.grid2."2_$( $column )_$( $row )".Size = [System.Drawing.Size]::new( 50, 50 )
        $gameMaster.grid2."2_$( $column )_$( $row )".Padding = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid2."2_$( $column )_$( $row )".Margin = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid2."2_$( $column )_$( $row )".Dock = [System.Windows.Forms.DockStyle]::Fill
        $gameMaster.grid2."2_$( $column )_$( $row )".Name = "2_$( $column )_$( $row )"
        $gameMaster.grid2."2_$( $column )_$( $row )".Text = ""
        $gameMaster.grid2."2_$( $column )_$( $row )".BackColor = $gameMaster.colors.water
        $gameMaster.grid2."2_$( $column )_$( $row )".Add_MouseClick({
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseClick -GameMaster $gameMaster -Name $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseClick -GameMaster $gameMaster -Name $this.Name -Right
            }
        })
        $gameMaster.grid2."2_$( $column )_$( $row )".Add_MouseEnter({
            New-MouseEnter -GameMaster $gameMaster -Name $this.Name
        })
        $gameMaster.grid2."2_$( $column )_$( $row )".Add_MouseLeave({
            New-MouseLeave -GameMaster $gameMaster -Name $this.Name
        })
        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $innerPanelOpponentGrid.SetCellPosition( $gameMaster.grid2."2_$( $column )_$( $row )", $cellPosition )
        $innerPanelOpponentGrid.Controls.Add( $gameMaster.grid2."2_$( $column )_$( $row )" )
    }
}
 
Set-KeyDown -GameMaster $gameMaster -Control $form
Set-AutoSize -Control $form
 
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.ShowDialog() | Out-Null