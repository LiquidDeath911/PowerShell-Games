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
    
    $GameMaster.colors.selected = [System.Drawing.Color]::Orange
    $GameMaster.colors.drag = [System.Drawing.Color]::Blue
    $GameMaster.colors.fill = [System.Drawing.Color]::Green
    $GameMaster.colors.valid = [System.Drawing.Color]::LawnGreen
    $GameMaster.colors.invalid = [System.Drawing.Color]::Red
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
        [int]$Grid,
        [string]$Name,
        [switch]$Left,
        [switch]$Right
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-MouseClick | $( $Grid ) | $( $Name ) | L-$( $Left ) | R-$( $Right )"
        Write-Host $GameMaster.cellList
    }
    if ( $GameMaster.win ) {
        return
    }
    switch( $Grid) {
        0 {
            if ( $Left ) {
                if ( $GameMaster.cellList.Count -lt $GameMaster.minLength ) {
                    foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                        $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                    $GameMaster.readyToPlace = $false
                    $GameMaster.canPlace = $false
                    $GameMaster.cellList.Clear()
                    $GameMaster.currentCell = ""
                    $GameMaster.hold = $false
                    $GameMaster.word = ""
                }
            } elseif ( $Right ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.word = ""
            }
        }
        1 {
            if ( $Left ) {
                if ( $GameMaster.cellList.Count -lt $GameMaster.minLength ) {
                    foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                        $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                    $GameMaster.readyToPlace = $false
                    $GameMaster.canPlace = $false
                    $GameMaster.cellList.Clear()
                    $GameMaster.currentCell = ""
                    $GameMaster.hold = $false
                    $GameMaster.word = ""
                }
            } elseif ( $Right ) {
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.word = ""
            }
        }
        2 {
            if ( $Left ) {
                if (( $GameMaster.canPlace ) -and ( $GameMaster.readyToPlace )) {
                    $GameMaster.madeMove = $true
                    foreach ( $property in $GameMaster.grid2.PSObject.Properties ) {
                        if ( $GameMaster.grid2."$( $property.Name )".BackColor -eq $GameMaster.colors.selected ) {
                            $GameMaster.grid2."$( $property.Name )".BackColor = $GameMaster.colors.fill
                        }
                    }
                    foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                        $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                    $GameMaster.previousWords.Add( $GameMaster.word ) | Out-Null
                    $GameMaster.readyToPlace = $false
                    $GameMaster.canPlace = $false
                    $GameMaster.cellList.Clear()
                    $GameMaster.currentCell = ""
                    $GameMaster.hold = $false
                    $GameMaster.word = ""
                    Confirm-GameState -GameMaster $GameMaster
                }
            } elseif ( $Right ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                foreach ( $property in $GameMaster.grid2.PSObject.Properties ) {
                    if ( $GameMaster.grid2."$( $property.Name )".BackColor -eq $GameMaster.colors.selected ) {
                        $GameMaster.grid2."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.word = ""
            }
        }
    }


    return
}

function New-MouseDown {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [string]$Name,
        [switch]$Left,
        [switch]$Right
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-MouseDown | $( $Grid ) | $( $Name ) | L-$( $Left ) | R-$( $Right )"
    }
    if ( $GameMaster.win ) {
        return
    }
    switch( $Grid) {
        0 {
            if ( $Left ) {

            } elseif ( $Right ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                foreach ( $property in $GameMaster.grid2.PSObject.Properties ) {
                    if ( $GameMaster.grid2."$( $property.Name )".BackColor -eq $GameMaster.colors.selected ) {
                        $GameMaster.grid2."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.word = ""
                $GameMaster.wordLabel.Text = ""
            }
        }
        1 {
            if ( $Left ) {
                if ( -not $GameMaster.readyToPlace ) {
                    $GameMaster.hold = $true
                    $GameMaster.currentCell = $Name
                    $GameMaster.grid1.$Name.BackColor = $GameMaster.colors.drag
                    $GameMaster.grid1.$Name.DoDragDrop( "", [System.Windows.Forms.DragDropEffects]::Link )
                }
            } elseif ( $Right ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                foreach ( $property in $GameMaster.grid2.PSObject.Properties ) {
                    if ( $GameMaster.grid2."$( $property.Name )".BackColor -eq $GameMaster.colors.selected ) {
                        $GameMaster.grid2."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.word = ""
                $GameMaster.wordLabel.Text = ""
            }
        }
        2 {
            if ( $Left ) {

            } elseif ( $Right ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                foreach ( $property in $GameMaster.grid2.PSObject.Properties ) {
                    if ( $GameMaster.grid2."$( $property.Name )".BackColor -eq $GameMaster.colors.selected ) {
                        $GameMaster.grid2."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.word = ""
                $GameMaster.wordLabel.Text = ""
            }
        }
    }

    return
}

function New-MouseUp {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [string]$Name
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-MouseUp | $( $Grid ) | $( $Name )"
    }
    if ( $GameMaster.win ) {
        return
    }
    switch( $Grid) {
        0 {
            if ( $GameMaster.cellList.Count -lt $GameMaster.minLength ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.wordLabel.Text = ""
            }
        }
        1 {
            if ( $GameMaster.cellList.Count -lt $GameMaster.minLength ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.wordLabel.Text = ""
            }
        }
        2 {
            if ( $GameMaster.cellList.Count -lt $GameMaster.minLength ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.wordLabel.Text = ""
            }
        }
    }

    return
}

function New-MouseEnter {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [string]$Name
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-MouseEnter | $( $Grid ) | $( $Name )"
    }
    if ( $GameMaster.win ) {
        return
    }
    switch( $Grid) {
        0 {}
        1 {}
        2 {
            if ( $GameMaster.readyToPlace ) {
                $GameMaster.readyToPlace = $false
                $firstCell = $GameMaster.cellList[0]
                $GameMaster.canPlace = $true
                foreach ( $cell in $GameMaster.cellList ) {
                    if ( $cell -eq $firstCell ) {
                        if ( $GameMaster.grid2."$( $Name )".BackColor -eq $GameMaster.colors.blank ) {
                            $GameMaster.grid2."$( $Name )".BackColor = $GameMaster.colors.selected
                        } else {
                            $GameMaster.canPlace = $false
                        }
                    } else {
                        $split = $Name.Split( "_" )
                        $column = $split[0]
                        $row = $split[1]

                        $firstSplit = $firstCell.Split( "_" )
                        $firstColumn = $firstSplit[0]
                        $firstRow = $firstSplit[1]

                        $newSplit = $cell.Split( "_" )
                        $newColumn = $newSplit[0]
                        $newRow = $newSplit[1]

                        $newCellColumn = ( [int]$column + ( [int]$newColumn - [int]$firstColumn ))
                        $newCellRow = ( [int]$row + ( [int]$newRow - [int]$firstRow ))
                        $newCell = "$( $newCellColumn )_$( $newCellRow )"

                        if ( $GameMaster.grid2."$( $newCell )".BackColor -eq $GameMaster.colors.blank ) {
                            $GameMaster.grid2."$( $newCell )".BackColor = $GameMaster.colors.selected
                        } else {
                            $GameMaster.canPlace = $false
                        }
                    }
                }
                $GameMaster.readyToPlace = $true
            }
        }
    }

    return
}

function New-MouseLeave {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [string]$Name
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-MouseLeave | $( $Grid ) | $( $Name )"
    }
    if ( $GameMaster.win ) {
        return
    }
    switch( $Grid) {
        0 {}
        1 {}
        2 {
            if ( $GameMaster.readyToPlace ) {
                foreach ( $property in $GameMaster.grid2.PSObject.Properties ) {
                    if ( $GameMaster.grid2."$( $property.Name )".BackColor -eq $GameMaster.colors.selected ) {
                        $GameMaster.grid2."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                }
            }
        }
    }

    return
}

function New-DragEnter {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [string]$Name
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-DragEnter | $( $Grid ) | $( $Name )"
    }
    if ( $GameMaster.win ) {
        return
    }
    switch( $Grid) {
        0 {}
        1 {
            if ( $GameMaster.hold ) {
                if ( $Name -ne $GameMaster.cellList[( $GameMaster.cellList.Count - 1 )] ) {
                    if ( $GameMaster.cellList -contains $Name ) {

                        $index = ( $GameMaster.cellList.IndexOf( $Name ) + 1 )
                        $count = ( $GameMaster.cellList.Count - $index )
                        if ( $GameMaster.debug ) {
                            Write-Host $GameMaster.cellList
                            Write-Host $GameMaster.cellList.Count
                            Write-Host "Index = $( $index )"
                            Write-Host "Count = $( $count )"
                        }
                        foreach ( $num in $index..( $GameMaster.cellList.Count - 1 )) {
                            $GameMaster.grid1."$( $GameMaster.cellList[$num] )".BackColor = $GameMaster.colors.blank
                        }
                        $GameMaster.cellList.RemoveRange( $index, $count )
                        $GameMaster.currentCell = $Name
                        if ( $GameMaster.debug ) {
                            Write-Host $GameMaster.cellList
                            Write-Host $GameMaster.cellList.Count
                        }
                    } else {
                        if ( $GameMaster.cellList.Count -eq 0 ) {
                            $GameMaster.grid1."$( $Name )".BackColor = $GameMaster.colors.drag
                            $GameMaster.currentCell = $Name
                            Get-Word -GameMaster $GameMaster
                        } elseif ( Confirm-Neighbor -GameMaster $GameMaster -Name $Name ) {
                            $GameMaster.grid1."$( $Name )".BackColor = $GameMaster.colors.drag
                            $GameMaster.currentCell = $Name
                            Get-Word -GameMaster $GameMaster
                        }
                    }
                }
            }
        }
        2 {}
    }

    return
}

function New-DragLeave {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [string]$Name
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-DragLeave | $( $Grid ) | $( $Name )"
    }
    if ( $GameMaster.win ) {
        return
    }
    switch( $Grid) {
        0 {}
        1 {
            if ( $GameMaster.hold ) {
                if ( $GameMaster.cellList -notcontains $GameMaster.currentCell ) {
                    if ( $GameMaster.cellList.Count -eq 0 ) {
                        $GameMaster.cellList.Add( $GameMaster.currentCell ) | Out-Null
                        if ( $GameMaster.debug ) {
                            Write-Host "Added $( $Name )"
                        }
                    } elseif ( Confirm-Neighbor -GameMaster $GameMaster -Name $Name ) {
                        $GameMaster.cellList.Add( $GameMaster.currentCell ) | Out-Null
                        if ( $GameMaster.debug ) {
                            Write-Host "Added $( $Name )"
                        }
                    }
                }
                $GameMaster.currentCell = ""
                Get-Word -GameMaster $GameMaster
            }
        }
        2 {}
    }

    if ( $GameMaster.debug ) {
        Write-Host $GameMaster.cellList
    }

    return
}

function New-DragDrop {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Grid,
        [string]$Name
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-DragDrop | $( $Grid ) | $( $Name )"
    }
    if ( $GameMaster.win ) {
        return
    }
    switch( $Grid) {
        0 {
            if ( $GameMaster.cellList.Count -lt $GameMaster.minLength ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.wordLabel.Text = ""
            } else {
                $GameMaster.currentCell = ""
                if ( Confirm-ValidWord -GameMaster $GameMaster ) {
                    $GameMaster.hold = $false
                    $GameMaster.readyToPlace = $true
                } else {
                    foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                        $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                    $GameMaster.readyToPlace = $false
                    $GameMaster.canPlace = $false
                    $GameMaster.cellList.Clear()
                    $GameMaster.currentCell = ""
                    $GameMaster.hold = $false
                    $GameMaster.wordLabel.Text = ""
                }
            }
        }
        1 {
            if ( $GameMaster.cellList -notcontains $Name ) {
                $GameMaster.cellList.Add( $Name ) | Out-Null
                if ( $GameMaster.debug ) {
                    Write-Host "Added $( $Name )"
                }
            }
            if ( $GameMaster.cellList.Count -lt $GameMaster.minLength ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.wordLabel.Text = ""
            } else {
                $GameMaster.currentCell = ""
                if ( Confirm-ValidWord -GameMaster $GameMaster ) {
                    $GameMaster.hold = $false
                    $GameMaster.readyToPlace = $true
                } else {
                    foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                        $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                    $GameMaster.readyToPlace = $false
                    $GameMaster.canPlace = $false
                    $GameMaster.cellList.Clear()
                    $GameMaster.currentCell = ""
                    $GameMaster.hold = $false
                    $GameMaster.wordLabel.Text = ""
                }
            }
        }
        2 {
            if ( $GameMaster.cellList.Count -lt $GameMaster.minLength ) {
                foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                    $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                }
                $GameMaster.readyToPlace = $false
                $GameMaster.canPlace = $false
                $GameMaster.cellList.Clear()
                $GameMaster.currentCell = ""
                $GameMaster.hold = $false
                $GameMaster.wordLabel.Text = ""
            } else {
                $GameMaster.currentCell = ""
                if ( Confirm-ValidWord -GameMaster $GameMaster ) {
                    $GameMaster.hold = $false
                    $GameMaster.readyToPlace = $true
                } else {
                    foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
                        $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
                    }
                    $GameMaster.readyToPlace = $false
                    $GameMaster.canPlace = $false
                    $GameMaster.cellList.Clear()
                    $GameMaster.currentCell = ""
                    $GameMaster.hold = $false
                    $GameMaster.wordLabel.Text = ""
                }
            }
        }
    }

    return
}

function Confirm-ValidWord {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    Get-Word -GameMaster $GameMaster

    if ( $GameMaster.previousWords -contains $GameMaster.word ) {
        return $false
    }

    if ( $GameMaster.wordList -notcontains $GameMaster.word ) {
        return $false
    }

    return $true
}

function Get-Word {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $word = ""

    foreach ( $cell in $GameMaster.cellList ) {
        $word += $GameMaster.grid1.$cell.Text
    }

    $GameMaster.word = $word

    if ( $GameMaster.currentCell.Length -gt 0 ) {
        $GameMaster.wordLabel.Text = $word + $GameMaster.grid1."$( $GameMaster.currentCell )".Text
    } else {
        $GameMaster.wordLabel.Text = $word
    }

    return
}

function Set-GridLetters {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $weightedLetterList = ("A" * 6),
                          ("B" * 2),
                          ("C" * 2),
                          ("D" * 3),
                          ("E" * 11),
                          ("F" * 2),
                          ("G" * 2),
                          ("H" * 5),
                          ("I" * 6),
                          ("J" * 1),
                          ("K" * 1),
                          ("L" * 4),
                          ("M" * 2),
                          ("N" * 6),
                          ("O" * 7),
                          ("P" * 2),
                          ("Q" * 1),
                          ("R" * 5),
                          ("S" * 6),
                          ("T" * 9),
                          ("U" * 3),
                          ("V" * 2),
                          ("W" * 3),
                          ("X" * 1),
                          ("Y" * 3),
                          ("Z" * 1)

    $letterList = ""
    foreach ( $letter in $weightedLetterList ) {
        $letterList += $letter
    }

    $letterArray = $letterList.ToCharArray()

    foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
        $seed = [int](Get-Date -Format "ssffff")
        $randLetter = Get-Random -InputObject $letterArray -SetSeed $seed
        if ( $randLetter -eq "Q" ) {
            $randLetter = "QU"
        }
        $GameMaster.grid1."$( $property.Name )".Text = $randLetter
    }

    return
}

function Confirm-Neighbor {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Name
    )

    $neighbors = [System.Collections.ArrayList]::new()
    $neighbors = Get-Neighors -GameMaster $GameMaster -Cell $GameMaster.cellList[( $GameMaster.cellList.Count - 1 )]
    if ( $neighbors -contains $Name ) {
        return $true
    }

    return $false
}

function Get-Neighors {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    $output = [System.Collections.ArrayList]::new()

    $split = $Cell.Split( "_" )
    $column = $split[0]
    $row = $split[1]

    if (( $column -gt 0 ) -and ( $row -gt 0 )) {
        $output.Add( "$( [int]$column - 1 )_$( [int]$row - 1 )" ) | Out-Null
        $output.Add( "$( [int]$column - 1 )_$( $row )" ) | Out-Null
        $output.Add( "$( $column )_$( [int]$row - 1 )" ) | Out-Null
    } elseif (( $column -gt 0 ) -or ( $row -gt 0 )) {
        if ( $column -gt 0 ) {
            $output.Add( "$( [int]$column - 1 )_$( $row )" ) | Out-Null
        } elseif ( $row -gt 0 ) {
            $output.Add( "$( $column )_$( [int]$row - 1 )" ) | Out-Null
        }
    }

    if (( $column -lt ( $GameMaster.grid1Width - 1 )) -and ( $row -lt ( $GameMaster.grid1Height - 1 ))) {
        $output.Add( "$( [int]$column + 1 )_$( [int]$row + 1 )" ) | Out-Null
        $output.Add( "$( [int]$column + 1 )_$( $row )" ) | Out-Null
        $output.Add( "$( $column )_$( [int]$row + 1 )" ) | Out-Null
    } elseif (( $column -lt ( $GameMaster.grid1Width - 1 )) -or ( $row -lt ( $GameMaster.grid1Height - 1 ))) {
        if ( $column -lt ( $GameMaster.grid1Width - 1 )) {
            $output.Add( "$( [int]$column + 1 )_$( $row )" ) | Out-Null
        } elseif ( $row -lt ( $GameMaster.grid1Height - 1 )) {
            $output.Add( "$( $column )_$( [int]$row + 1 )" ) | Out-Null
        }
    }

    if (( $column -gt 0 ) -and ( $row -lt ( $GameMaster.grid1Height - 1 ))) {
        $output.Add( "$( [int]$column - 1 )_$( [int]$row + 1 )" ) | Out-Null
    }

    if (( $column -lt ( $GameMaster.grid1Width - 1 )) -and ( $row -gt 0 )) {
        $output.Add( "$( [int]$column + 1 )_$( [int]$row - 1 )" ) | Out-Null
    }

    return $output
}

function New-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    Set-GridLetters -GameMaster $GameMaster

    $GameMaster.infoLabel1.Text = "Click and drag to create words on the left grid."
    $GameMaster.infoLabel2.Text = "After a valid word is found, place the shape in the right grid by clicking."
    $GameMaster.infoLabel3.Text = "Right click to clear the selected word without placing it."
    $GameMaster.infoLabel4.Text = "Win by completely filling in the right grid."

    foreach ( $property in $GameMaster.grid1.PSObject.Properties ) {
        $GameMaster.grid1."$( $property.Name )".BackColor = $GameMaster.colors.blank
    }
    foreach ( $property in $GameMaster.grid2.PSObject.Properties ) {
        $GameMaster.grid2."$( $property.Name )".BackColor = $GameMaster.colors.blank
    }

    $GameMaster.readyToPlace = $false
    $GameMaster.canPlace = $false
    $GameMaster.cellList.Clear()
    $GameMaster.currentCell = ""
    $GameMaster.hold = $false
    $GameMaster.wordLabel.Text = ""

    $GameMaster.start = $true
    $GameMaster.win = $false
    $GameMaster.madeMove = $false

    return
}

function Confirm-GameState {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.win = $true

    foreach ( $property in $GameMaster.grid2.PSObject.Properties ) {
        if ( $GameMaster.grid2."$( $property.Name )".BackColor -ne $GameMaster.colors.fill ) {
            $GameMaster.win = $false
        }
    }

    if ( $GameMaster.win ) {
        Set-Win -GameMaster $GameMaster
    }

    return
}

function Set-Win {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.infoLabel1.Text = "Congrats! You won!"
    $GameMaster.infoLabel2.Text = ""
    $GameMaster.infoLabel3.Text = ""
    $GameMaster.infoLabel4.Text = ""
    $GameMaster.start = $false
    $GameMaster.madeMove = $false

}

function Set-Lose {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )


    return
}

$gameMaster = [PSCustomObject]@{
    debug = $false
    start = $false
    madeMove = $false
    infoLabel1 = [System.Windows.Forms.Label]::new()
    infoLabel2 = [System.Windows.Forms.Label]::new()
    infoLabel3 = [System.Windows.Forms.Label]::new()
    infoLabel4 = [System.Windows.Forms.Label]::new()
    colors = [PSCustomObject]@{
        selected = $null
        drag = $null
        fill = $null
        valid = $null
        invalid = $null
        blank = $null
    }
    grid1 = [PSCustomObject]@{}
    grid2 = [PSCustomObject]@{}
    grid1Width = 5
    grid1Height = 5
    hold = $false
    readyToPlace = $false
    canPlace = $false
    cellList = [System.Collections.ArrayList]::new()
    currentCell = ""
    wordList = [System.Collections.ArrayList]::new()
    word = ""
    wordLabel = [System.Windows.Forms.Label]::new()
    minLength = 3
    previousWords = [System.Collections.ArrayList]::new()
    win = $false
}

$gameMaster.wordList = Get-Content -Path .\WordFill.txt

$form = [System.Windows.Forms.Form]::new()
$form.Text = "Word Fill"
$form.AllowDrop = $true
$form.Add_MouseClick({ 
    param($sender, $event)
    if ( $event.button -eq "Left" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Left
    } elseif ( $event.button -eq "Right" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Right
    }
})
$form.Add_DragEnter({ 
    param($sender, $event)
    $event.Effect = [System.Windows.Forms.DragDropEffects]::Link
    New-DragEnter -GameMaster $gameMaster -Grid 0 -Name $this.Name 
})
$form.Add_DragLeave({ New-DragLeave -GameMaster $gameMaster -Grid 0 -Name $this.Name })
$form.Add_DragDrop({ New-DragDrop -GameMaster $gameMaster -Grid 0 -Name $this.Name })

$toolStrip = [System.Windows.Forms.ToolStrip]::new()
$toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
$toolStrip.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden
$mainPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$mainPanel.Padding = [System.Windows.Forms.Padding]::new( 5, $toolStrip.Height, 5, 5 )
$mainPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$mainPanel.Add_MouseClick({ 
    param($sender, $event)
    if ( $event.button -eq "Left" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Left
    } elseif ( $event.button -eq "Right" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Right
    }
})
$form.Controls.Add( $toolStrip ) | Out-Null
$form.Controls.Add( $mainPanel ) | Out-Null

$newGameButton = [System.Windows.Forms.ToolStripButton]::new()
$newGameButton.Text = "New Game"
$newGameButton.Padding = [System.Windows.Forms.Padding]::new( 0, 0, 5, 0 )
$newGameButton.Add_Click({
    New-Game -GameMaster $gameMaster
})
$toolStrip.Items.Add( $newGameButton ) | Out-Null

$upperOutGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$upperOutGrid.Dock = [System.Windows.Forms.DockStyle]::Fill
$upperOutGrid.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
$upperOutGrid.Add_MouseClick({ 
    param($sender, $event)
    if ( $event.button -eq "Left" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Left
    } elseif ( $event.button -eq "Right" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Right
    }
})
$upperMidGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$upperMidGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$upperMidGrid.Add_MouseClick({ 
    param($sender, $event)
    if ( $event.button -eq "Left" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Left
    } elseif ( $event.button -eq "Right" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Right
    }
})
$upperInGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$upperInGrid.RowCount = $gameMaster.grid1Height
$upperInGrid.ColumnCount = $gameMaster.grid1Width
$upperInGrid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$upperInGrid.Add_MouseClick({ 
    param($sender, $event)
    if ( $event.button -eq "Left" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Left
    } elseif ( $event.button -eq "Right" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Right
    }
})
$upperOutGrid.Controls.Add( $upperMidGrid ) | Out-Null
$upperMidGrid.Controls.Add( $upperInGrid ) | Out-Null
$mainPanel.Controls.Add( $upperOutGrid ) | Out-Null

$lowerOutGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$lowerOutGrid.Dock = [System.Windows.Forms.DockStyle]::Fill
$lowerOutGrid.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
$lowerOutGrid.Add_MouseClick({ 
    param($sender, $event)
    if ( $event.button -eq "Left" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Left
    } elseif ( $event.button -eq "Right" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Right
    }
})
$lowerMidGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$lowerMidGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$lowerMidGrid.Add_MouseClick({ 
    param($sender, $event)
    if ( $event.button -eq "Left" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Left
    } elseif ( $event.button -eq "Right" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Right
    }
})
$lowerInGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$lowerInGrid.RowCount = 6
$lowerInGrid.ColumnCount = 6
$lowerInGrid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$lowerInGrid.Add_MouseClick({ 
    param($sender, $event)
    if ( $event.button -eq "Left" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Left
    } elseif ( $event.button -eq "Right" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Right
    }
})
$lowerOutGrid.Controls.Add( $lowerMidGrid ) | Out-Null
$lowerMidGrid.Controls.Add( $lowerInGrid ) | Out-Null
$mainPanel.Controls.Add( $lowerOutGrid ) | Out-Null
$mainPanel.SetFlowBreak( $lowerOutGrid, $true )

$outerInfoGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$outerInfoGrid.Dock = [System.Windows.Forms.DockStyle]::Fill
$outerInfoGrid.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
$outerInfoGrid.Add_MouseClick({ 
    param($sender, $event)
    if ( $event.button -eq "Left" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Left
    } elseif ( $event.button -eq "Right" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Right
    }
})
$middleInfoGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$middleInfoGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$middleInfoGrid.Add_MouseClick({ 
    param($sender, $event)
    if ( $event.button -eq "Left" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Left
    } elseif ( $event.button -eq "Right" ) {
        New-MouseClick -GameMaster $gameMaster -Grid 0 -Name $this.Name -Right
    }
})
$outerInfoGrid.Controls.Add( $middleInfoGrid ) | Out-Null
$mainPanel.Controls.Add( $outerInfoGrid ) | Out-Null

$gameMaster.wordLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.wordLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.wordLabel.Text = ""
$middleInfoGrid.Controls.Add( $gameMaster.wordLabel ) | Out-Null

$gameMaster.infoLabel1.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel1.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel1.Text = "Click and drag to create words on the left grid."
$middleInfoGrid.Controls.Add( $gameMaster.infoLabel1 ) | Out-Null

$gameMaster.infoLabel2.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel2.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel2.Text = "After a valid word is found, place the shape in the right grid by clicking."
$middleInfoGrid.Controls.Add( $gameMaster.infoLabel2 ) | Out-Null

$gameMaster.infoLabel3.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel3.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel3.Text = "Right click to clear the selected word without placing it."
$middleInfoGrid.Controls.Add( $gameMaster.infoLabel3 ) | Out-Null

$gameMaster.infoLabel4.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel4.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel4.Text = "Win by completely filling in the right grid."
$middleInfoGrid.Controls.Add( $gameMaster.infoLabel4 ) | Out-Null

$margin = 8

Set-Colors -GameMaster $gameMaster

foreach ( $row in 0..( $upperInGrid.RowCount - 1 )) {
    foreach ( $column in 0..( $upperInGrid.ColumnCount - 1 )) {
        try {
            $gameMaster.grid1 | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [System.Windows.Forms.Label]::new()) -ErrorAction Stop
        } catch {
            $gameMaster.grid1.psobject.properties.remove( "$( $column )_$( $row )" )
            $gameMaster.grid1 | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [System.Windows.Forms.Label]::new())
        }

        $gameMaster.grid1."$( $column )_$( $row )".TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $gameMaster.grid1."$( $column )_$( $row )".Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $gameMaster.grid1."$( $column )_$( $row )".Size = [System.Drawing.Size]::new( 50, 50 )
        $gameMaster.grid1."$( $column )_$( $row )".Padding = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid1."$( $column )_$( $row )".Margin = [System.Windows.Forms.Padding]::new( $margin, $margin, $margin, $margin )
        $gameMaster.grid1."$( $column )_$( $row )".Dock = [System.Windows.Forms.DockStyle]::Fill
        $gameMaster.grid1."$( $column )_$( $row )".Name = "$( $column )_$( $row )"
        $gameMaster.grid1."$( $column )_$( $row )".Text = ""
        $gameMaster.grid1."$( $column )_$( $row )".BackColor = $gameMaster.colors.blank
        $gameMaster.grid1."$( $column )_$( $row )".AllowDrop = $true
        $gameMaster.grid1."$( $column )_$( $row )".Add_MouseClick({ 
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseClick -GameMaster $gameMaster -Grid 1 -Name $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseClick -GameMaster $gameMaster -Grid 1 -Name $this.Name -Right
            }
        })
        $gameMaster.grid1."$( $column )_$( $row )".Add_MouseDown({ 
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseDown -GameMaster $gameMaster -Grid 1 -Name $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseDown -GameMaster $gameMaster -Grid 1 -Name $this.Name -Right
            }
        })
        $gameMaster.grid1."$( $column )_$( $row )".Add_MouseUp({ New-MouseUp -GameMaster $gameMaster -Grid 1 -Name $this.Name })
        $gameMaster.grid1."$( $column )_$( $row )".Add_DragEnter({ 
            param($sender, $event)
            $event.Effect = [System.Windows.Forms.DragDropEffects]::Link
            New-DragEnter -GameMaster $gameMaster -Grid 1 -Name $this.Name 
        })
        $gameMaster.grid1."$( $column )_$( $row )".Add_DragLeave({ New-DragLeave -GameMaster $gameMaster -Grid 1 -Name $this.Name })
        $gameMaster.grid1."$( $column )_$( $row )".Add_DragDrop({ New-DragDrop -GameMaster $gameMaster -Grid 1 -Name $this.Name })

        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $upperInGrid.SetCellPosition( $gameMaster.grid1."$( $column )_$( $row )", $cellPosition )
        $upperInGrid.Controls.Add( $gameMaster.grid1."$( $column )_$( $row )")
    }
}

foreach ( $row in 0..( $lowerInGrid.RowCount - 1 )) {
    foreach ( $column in 0..( $lowerInGrid.ColumnCount - 1 )) {
        try {
            $gameMaster.grid2 | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [System.Windows.Forms.Label]::new()) -ErrorAction Stop
        } catch {
            $gameMaster.grid2.psobject.properties.remove( "$( $column )_$( $row )" )
            $gameMaster.grid2 | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [System.Windows.Forms.Label]::new())
        }

        $gameMaster.grid2."$( $column )_$( $row )".TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $gameMaster.grid2."$( $column )_$( $row )".Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $gameMaster.grid2."$( $column )_$( $row )".Size = [System.Drawing.Size]::new(( 50 + $margin ), ( 50 + $margin ))
        $gameMaster.grid2."$( $column )_$( $row )".Padding = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid2."$( $column )_$( $row )".Margin = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid2."$( $column )_$( $row )".Dock = [System.Windows.Forms.DockStyle]::Fill
        $gameMaster.grid2."$( $column )_$( $row )".Name = "$( $column )_$( $row )"
        $gameMaster.grid2."$( $column )_$( $row )".Text = ""
        $gameMaster.grid2."$( $column )_$( $row )".BackColor = $gameMaster.colors.blank
        $gameMaster.grid2."$( $column )_$( $row )".Add_MouseClick({ 
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseClick -GameMaster $gameMaster -Grid 2 -Name $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseClick -GameMaster $gameMaster -Grid 2 -Name $this.Name -Right
            }
        })
        $gameMaster.grid2."$( $column )_$( $row )".Add_MouseDown({ 
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseDown -GameMaster $gameMaster -Grid 2 -Name $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseDown -GameMaster $gameMaster -Grid 2 -Name $this.Name -Right
            }
        })
        $gameMaster.grid2."$( $column )_$( $row )".Add_MouseUp({ New-MouseUp -GameMaster $gameMaster -Grid 2 -Name $this.Name })
        $gameMaster.grid2."$( $column )_$( $row )".Add_MouseEnter({ New-MouseEnter -GameMaster $gameMaster -Grid 2 -Name $this.Name })
        $gameMaster.grid2."$( $column )_$( $row )".Add_MouseLeave({ New-MouseLeave -GameMaster $gameMaster -Grid 2 -Name $this.Name })
        $gameMaster.grid2."$( $column )_$( $row )".Add_DragEnter({ 
            param($sender, $event)
            $event.Effect = [System.Windows.Forms.DragDropEffects]::Link
            New-DragEnter -GameMaster $gameMaster -Grid 2 -Name $this.Name 
        })
        $gameMaster.grid2."$( $column )_$( $row )".Add_DragLeave({ New-DragLeave -GameMaster $gameMaster -Grid 2 -Name $this.Name })
        $gameMaster.grid2."$( $column )_$( $row )".Add_DragDrop({ New-DragDrop -GameMaster $gameMaster -Grid 2 -Name $this.Name })

        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $lowerInGrid.SetCellPosition( $gameMaster.grid2."$( $column )_$( $row )", $cellPosition )
        $lowerInGrid.Controls.Add( $gameMaster.grid2."$( $column )_$( $row )")
    }
}

Set-AutoSize -Control $form

New-Game -GameMaster $gameMaster

$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.ShowDialog() | Out-Null
