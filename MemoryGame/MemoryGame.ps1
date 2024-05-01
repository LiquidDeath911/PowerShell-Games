Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    
    $GameMaster.colors.hover = [System.Drawing.Color]::Orange
    $GameMaster.colors.pattern = [System.Drawing.Color]::Blue
    $GameMaster.colors.click = [System.Drawing.Color]::LawnGreen
    $GameMaster.colors.incorrect = [System.Drawing.Color]::Red
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

function New-MouseClick {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name
    )


    if (( $GameMaster.showingPattern ) -or ( -not $GameMaster.start )) {
        return
    }

    $GameMaster.infoLabel.Text = "Clicked: $( $GameMaster.index + 1 )"

    if ( -not ( Confirm-Pattern -GameMaster $GameMaster -Name $Name )) {
        $GameMaster.lives--
        $GameMaster.livesLabel.Text = "Lives: $( $GameMaster.lives )"

        if ( $GameMaster.lives -le 0 ) {
            $GameMaster.start = $false
            Set-Lose -GameMaster $GameMaster
        }

        $GameMaster.index = 0

        $GameMaster.infoLabel.Text = "Showing Pattern"
        Start-Sleep -Milliseconds 1555
        Show-Pattern -GameMaster $GameMaster

    } else {

        $GameMaster.index++

        if ( $GameMaster.index -ge $GameMaster.pattern.Count ) {
            $GameMaster.score++
            $GameMaster.scoreLabel.Text = "Score: $( $GameMaster.score )"

            Get-NextPattern -GameMaster $GameMaster

            $GameMaster.index = 0

            $GameMaster.infoLabel.Text = "Showing Pattern"
            Start-Sleep -Milliseconds 1555
            Show-Pattern -GameMaster $GameMaster

        }

    }

    return
}

function New-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.start = $true
    $GameMaster.index = 0
    $GameMaster.lives = 3
    $GameMaster.score = 0
    $GameMaster.pattern.Clear()

    $GameMaster.livesLabel.Text = "Lives: $( $GameMaster.lives )"
    $GameMaster.scoreLabel.Text = "Score: $( $GameMaster.score )"


    Set-VisibleCells -GameMaster $GameMaster

    Get-NextPattern -GameMaster $GameMaster

    $GameMaster.infoLabel.Text = "Showing Pattern"
    Start-Sleep -Milliseconds 1555
    Show-Pattern -GameMaster $GameMaster

    return
}

function Close-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.patternTimer1.Dispose()
    $GameMaster.patternTimer2.Dispose()

    if ( $GameMaster.start ) {
        Set-Lose -GameMaster $GameMaster
    }

    return
}

function Show-Pattern {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )


    if ( $GameMaster.index -eq 0 ) {
        $GameMaster.showingPattern = $true
    } elseif ( $GameMaster.index -eq $GameMaster.pattern.Count ) {
        $GameMaster.grid."$( $GameMaster.pattern[( $GameMaster.index - 1 )] )".BackColor = $GameMaster.colors.blank
        $GameMaster.index = 0
        $GameMaster.showingPattern = $false
        $GameMaster.infoLabel.Text = "Ready"
        return
    } else {
        $GameMaster.grid."$( $GameMaster.pattern[( $GameMaster.index - 1 )] )".BackColor = $GameMaster.colors.blank
    }

    $GameMaster.grid."$( $GameMaster.pattern[$GameMaster.index] )".BackColor = $GameMaster.colors.pattern
    $GameMaster.patternTimer1.Enabled = $true
    $GameMaster.patternTimer2.Enabled = $true

    return
}


function Confirm-Pattern {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name
    )

    if ( $GameMaster.pattern[$GameMaster.index] -eq $Name ) {
        return $true
    }

    return $false
}

function Get-NextPattern {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $column = 0
    $row = 0

    switch( $GameMaster.mode ) {
        0 {
            $seed = [int](Get-Date -Format "ssffff")
            $column = Get-Random -Minimum 0 -Maximum 3 -SetSeed $seed
            $seed = [int](Get-Date -Format "ssffff")
            $row = Get-Random -Minimum 0 -Maximum 3 -SetSeed $seed
        }
        1 {
            $seed = [int](Get-Date -Format "ssffff")
            $column = Get-Random -Minimum 0 -Maximum 4 -SetSeed $seed
            $seed = [int](Get-Date -Format "ssffff")
            $row = Get-Random -Minimum 0 -Maximum 4 -SetSeed $seed
        }
        2 {
            $seed = [int](Get-Date -Format "ssffff")
            $column = Get-Random -Minimum 0 -Maximum 5 -SetSeed $seed
            $seed = [int](Get-Date -Format "ssffff")
            $row = Get-Random -Minimum 0 -Maximum 5 -SetSeed $seed
        }
    }

    $GameMaster.pattern.Add( "$( $column )_$( $row )" )

    return
}

function Set-VisibleCells {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $form.SuspendLayout()

    switch( $GameMaster.mode ) {
        0 { 
            foreach ( $property in $GameMaster.grid.PSObject.Properties ) {
                $split = $property.Name.Split( "_" )
                $column = [int]$split[0]
                $row = [int]$split[1]

                if (( $column -ge 3 ) -or ( $row -ge 3 )) {
                    $GameMaster.grid."$( $property.Name )".Visible = $false
                } else {
                    $GameMaster.grid."$( $property.Name )".Visible = $true
                }
            }
        }
        1 { 
            foreach ( $property in $GameMaster.grid.PSObject.Properties ) {
                $split = $property.Name.Split( "_" )
                $column = [int]$split[0]
                $row = [int]$split[1]

                if (( $column -ge 4 ) -or ( $row -ge 4 )) {
                    $GameMaster.grid."$( $property.Name )".Visible = $false
                } else {
                    $GameMaster.grid."$( $property.Name )".Visible = $true
                }
            }
        }
        2 { 
            foreach ( $property in $GameMaster.grid.PSObject.Properties ) {
                $GameMaster.grid."$( $property.Name )".Visible = $true
            }
        }
    }

    $form.ResumeLayout()

    return
}

function Set-Difficulty {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name
    )

    $GameMaster.mode = $Name

    Set-VisibleCells -GameMaster $GameMaster

    New-Game -GameMaster $GameMaster

    return
}

function Set-Blank {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Index
    )

    foreach ( $property in $GameMaster.grid.PSObject.Properties ) {
        $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.blank
    }

    return
}

function Set-Lose {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.start = false;

    return
}

$gameMaster = [PSCustomObject]@{
    infoLabel = [System.Windows.Forms.Label]::new()
    livesLabel = [System.Windows.Forms.Label]::new()
    scoreLabel = [System.Windows.Forms.Label]::new()
    bestScore = [System.Windows.Forms.Label]::new()
    colors = [PSCustomObject]@{
        hover = $null
        pattern = $null
        click = $null
        incorrect = $null
        blank = $null
    }
    start = $false
    mode = 2
    lives = 3
    score = 0
    index = 0
    grid = [PSCustomObject]@{}
    timers = [PSCustomObject]@{}
    pattern = [System.Collections.ArrayList]::new()
    showingPattern = $false
    patternDelay1 = 1000
    patternDelay2 = 750
    patternTimer1 = [System.Windows.Forms.Timer]::new()
    patternTimer2 = [System.Windows.Forms.Timer]::new()
}

$form = [System.Windows.Forms.Form]::new()
$form.Text = "Memory Game"
$form.Add_FormClosing({ Close-Game -GameMaster $gameMaster })
$toolStrip = [System.Windows.Forms.ToolStrip]::new()
$toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
$toolStrip.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden
$mainPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$mainPanel.Padding = [System.Windows.Forms.Padding]::new( 5, $toolStrip.Height, 5, 5 )
$mainPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$form.Controls.Add( $toolStrip ) | Out-Null
$form.Controls.Add( $mainPanel ) | Out-Null

$dropDownButtonDifficulty = [System.Windows.Forms.ToolStripDropDownButton]::new()
$dropDownButtonDifficulty.Text = "Difficulty"
$dropDownButtonDifficulty.ShowDropDownArrow = $true
$dropDownButtonDifficulty.Padding = [System.Windows.Forms.Padding]::new(5,0,0,0)

$dropDownItemsDifficulty = [System.Windows.Forms.ToolStripDropDown]::new()
$dropDownEasy = [System.Windows.Forms.ToolStripButton]::new()
$dropDownEasy.Text = "Easy"
$dropDownEasy.Name = "0"
$dropDownEasy.Add_Click({ Set-Difficulty -GameMaster $gameMaster -Name $this.Name })
$dropDownMedium = [System.Windows.Forms.ToolStripButton]::new()
$dropDownMedium.Text = "Medium"
$dropDownMedium.Name = "1"
$dropDownMedium.Add_Click({ Set-Difficulty -GameMaster $gameMaster -Name $this.Name })
$dropDownHard = [System.Windows.Forms.ToolStripButton]::new()
$dropDownHard.Text = "Hard"
$dropDownHard.Name = "2"
$dropDownHard.Add_Click({ Set-Difficulty -GameMaster $gameMaster -Name $this.Name })
$dropDownItemsDifficulty.Items.Add( $dropDownEasy ) | Out-Null
$dropDownItemsDifficulty.Items.Add( $dropDownMedium ) | Out-Null
$dropDownItemsDifficulty.Items.Add( $dropDownHard ) | Out-Null

$dropDownButtonDifficulty.DropDown = $dropDownItemsDifficulty
$toolStrip.Items.Add( $dropDownButtonDifficulty ) | Out-Null

$outerPanelGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$outerPanelGrid.Dock = [System.Windows.Forms.DockStyle]::Fill
$outerPanelGrid.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
$middlePanelGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$middlePanelGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$innerPanelGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelGrid.RowCount = 5
$innerPanelGrid.ColumnCount = 5
$innerPanelGrid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$outerPanelGrid.Controls.Add( $middlePanelGrid ) | Out-Null
$middlePanelGrid.Controls.Add( $innerPanelGrid ) | Out-Null
$mainPanel.Controls.Add( $outerPanelGrid ) | Out-Null

$gameMaster.infoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel.Text = " "
$mainPanel.Controls.Add( $gameMaster.infoLabel ) | Out-Null

$gameMaster.livesLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.livesLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.livesLabel.Text = "Lives: $( $gameMaster.lives )"
$mainPanel.Controls.Add( $gameMaster.livesLabel ) | Out-Null

$gameMaster.scoreLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.scoreLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.scoreLabel.Text = "Score: $( $gameMaster.score )"
$mainPanel.Controls.Add( $gameMaster.scoreLabel ) | Out-Null

$gameMaster.patternTimer1.Enabled = $false
$gameMaster.patternTimer1.Interval = $gameMaster.patternDelay1
$gameMaster.patternTimer1.Add_Tick({
    $gameMaster.patternTimer1.Enabled = $false
    $gameMaster.index++
    Show-Pattern -GameMaster $gameMaster
})

$gameMaster.patternTimer2.Enabled = $false
$gameMaster.patternTimer2.Interval = $gameMaster.patternDelay2
$gameMaster.patternTimer2.Add_Tick({
    $gameMaster.patternTimer2.Enabled = $false
    Set-Blank -GameMaster $gameMaster
})

Set-Colors -GameMaster $gameMaster

foreach ( $row in 0..4 ) {
    foreach ( $column in 0..4 ) {
        Try {
            $gameMaster.grid | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [System.Windows.Forms.Label]::new()) -ErrorAction Stop
        } Catch {
            $gameMaster.grid.psobject.properties.remove( "$( $column )_$( $row )" )
            $gameMaster.grid | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [System.Windows.Forms.Label]::new())
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
        $gameMaster.grid."$( $column )_$( $row )".Add_Click({ New-MouseClick -GameMaster $gameMaster -Name $this.Name })

        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $innerPanelGrid.SetCellPosition( $gameMaster.grid."$( $column )_$( $row )", $cellPosition )
        $innerPanelGrid.Controls.Add( $gameMaster.grid."$( $column )_$( $row )")
    }
}

Set-VisibleCells -GameMaster $gameMaster

Set-AutoSize -Control $form

$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.ShowDialog() | Out-Null
