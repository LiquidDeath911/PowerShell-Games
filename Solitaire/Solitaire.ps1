Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Set-AutoSize {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        $Control
    )

    if ( $Control.Name -eq "AutoSize" ) {
        foreach ($prop in $control.PSObject.Properties) {
            if ($prop.Name -eq "AutoSizeMode") {
                $Control.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
            } elseif ($prop.Name -eq "AutoSize") {
                $Control.AutoSize = $true
            }
        }
    }
    if ( $Control.Controls.Count -gt 0 ) {
        foreach ( $subControl in $Control.Controls ) {
            Set-AutoSize $subControl
        }
    }

    return
}

function Clear-Images {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Clear-Images"
    }

    foreach ( $property in $GameMaster.cards.PSObject.Properties ) {
        $GameMaster.cards."$( $property.Name )".image.Dispose()
    }

    return
}

function New-MouseClick {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell,
        [switch]$Left,
        [switch]$Right
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-MouseClick | $( $Cell ) | $( $Name ) | L-$( $Left ) | R-$( $Right )"
    }

    $split = $Cell.Split( '_' )
    $column = $split[0]
    $row = $split[1]

    if ( $Left ) {
        if ( $row -eq "f" ) {
            if ( [int]$column -eq 0 ) {
                Pop-Card -GameMaster $GameMaster
            }
        }
    }

    return

}

function New-MouseDown {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell,
        [switch]$Left,
        [switch]$Right
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-MouseDown | $( $Cell ) | $( $Name ) | L-$( $Left ) | R-$( $Right )"
    }

    $split = $Cell.Split( '_' )
    $column = $split[0]
    $row = $split[1]

    if ( $Left ) {

        $GameMaster.selectedCard = Find-Card -GameMaster $GameMaster -Cell $Cell
        if ( $GameMaster.debug ) {
            Write-Host "SelectedCard = $( $GameMaster.selectedCard )"
        }

        if ( $GameMaster.selectedCard ) {
            if ( $row -eq "f" ) {
                $GameMaster.foundation."col$( $column )"."$( $row )".DoDragDrop( "", [System.Windows.Forms.DragDropEffects]::Link )
            } else  {
                $GameMaster."col$( $column )"."$( $row )".DoDragDrop( "", [System.Windows.Forms.DragDropEffects]::Link )
            }
        }
    }

    return

}

function New-MouseUp {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-MouseUp | $( $Cell ) | $( $Name )"
    }

    return

}

function New-MouseEnter {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-MouseEnter | $( $Cell ) | $( $Name )"
    }

    return

}

function New-MouseLeave {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-MouseLeave | $( $Cell ) | $( $Name )"
    }

    return

}

function New-DragOver {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-DragOver | $( $Cell ) | $( $Name )"
    }

    return

}

function New-DragEnter {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-DragEnter | $( $Cell ) | $( $Name )"
    }

    return

}

function New-DragLeave {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-DragLeave | $( $Cell ) | $( $Name )"
    }

    return

}

function New-DragDrop {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "New-DragDrop | $( $Cell ) | $( $Name )"
    }

    Move-Card -GameMaster $GameMaster -Cell $Cell -Card $GameMaster.selectedCard

    return

}

function Pop-Card {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Pop-Card | $( $Cell )"
    }

    if ( $GameMaster.deck.Count -eq 0 ) {
        Pop-Deck -GameMaster $GameMaster
    } else {
        $GameMaster.pile.Add( $GameMaster.deck[0] ) |Out-Null

        $GameMaster.foundation.col1."1".BackgroundImage = $GameMaster.cards."$( $GameMaster.deck[0] )".image
        $GameMaster.cards."$( $GameMaster.deck[0] )".cell = "1_f"
        $GameMaster.deck.RemoveAt( 0 ) | Out-Null

        if ( $GameMaster.deck.Count -eq 0 ) {
            $GameMaster.foundation.col0."0".BackgroundImage = $GameMaster.cards.blank.image
        }
    }

    return
}

function Pop-Deck {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Pop-Deck | $( $Cell )"
    }

    foreach ( $card in $GameMaster.pile ) {
        $GameMaster.deck.Add( $card ) | Out-Null
        $GameMaster.cards.$card.cell = "0_f"
    }

    $GameMaster.pile.Clear()

    return
}

function Find-Card {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "Find-Card | $( $Cell )"
    }

    $ignoreList = "blank", "unused"
    $foundationList = "0_f", "1_f", "2_f", "3_f"

    foreach ( $property in $GameMaster.cards.PSObject.Properties ) {

        if ( $GameMaster.debug ) {
            #Write-Host "Card | $( $property.Name )"
        }

        if ( $foundationList -contains $property.Name ) {
            
        } else {
            if ( $ignoreList -notcontains $property.Name ) {
                if ( $GameMaster.cards."$( $property.Name )".cell -eq $Cell ) {
                    return $property.Name
                }
            }
        }
    }

    return $null
}

function Get-TopCardCell {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "Get-TopCardCell | $( $Cell )"
    }

    if ( $Cell -match "f" ) {
        return $Cell
    }

    $split = $Cell.Split( '_' )
    $column = [int]$split[0]
    $row = [int]$split[1]

    foreach ( $property in $GameMaster."col$( $column )".PSObject.Properties ) {
        if ( $GameMaster."col$( $column )"."$( $property.Name )".Size -eq $GameMaster.normalSize ) {
            return "$( $column )_$( $property.Name )"
        }
    }

    return $null
}

function Set-FlipCard {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Card
    )

    if ( $GameMaster.debug ) {
        Write-Host "Set-FlipCard | $( $Card )"
    }

    $GameMaster.cards.$Card.faceUp = ( -not $GameMaster.cards.$Card.faceUp )

    return
}

function Confirm-OneUpOppositeSuit {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell,
        [string]$Card
    )

    if ( $GameMaster.debug ) {
        Write-Host "Confirm-OneUpOppositeSuit | $( $Cell ) | $( $Card )"
    }

    $split = $Cell.Split( '_' )
    $column = [int]$split[0]
    $row = [int]$split[1]

    $split2 = $Card.Split( '_' )
    $suit = [int]$split2[0]
    $value = [int]$split2[1]

    $oppositeSuits = 0, 0

    switch( $suit ) {
        0 { $oppositeSuits = 2, 3 }
        1 { $oppositeSuits = 2, 3 }
        2 { $oppositeSuits = 0, 1 }
        3 { $oppositeSuits = 0, 1 }
    }

    $higherValue = ( $value + 1 )

    foreach ( $oppositeSuit in $oppositeSuits ) {
        if ( $GameMaster.cards."$( $oppositeSuit )_$( $higherValue )".cell -eq $Cell ) {
            $GameMaster."col$( $column )"."$( $row )".Size = $GameMaster.smallSize
            return $true
        }
    }
    
    return $false
}

function Confirm-EmptyColumn {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "Confirm-EmptyColumn | $( $Cell )"
    }

    $split = $Cell.Split( '_' )
    $column = [int]$split[0]
    $row = [int]$split[1]

    if ( -not ( Find-Card -GameMaster $GameMaster -Cell "$( $column )_0" )) {
        return $true
    }
    
    return $false
}

function Confirm-CanPlaceCard {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell,
        [string]$Card
    )

    if ( $GameMaster.debug ) {
        Write-Host "Confirm-CanPlaceCard | $( $Cell ) | $( $Card )"
    }

    $split = $Cell.Split( '_' )
    $column = $split[0]
    $row = $split[1]

    $split2 = $Card.Split( '_' )
    $suit = $split2[0]
    $value = $split2[1]

    if ( $row -eq "f" ) {
        if ( [int]$column -ge 3 ) {
            if ( [int]$suit -eq ( [int]$column - 3 )) {
                if ( [int]$value -eq 1 ) {
                    return $true
                } elseif ( $GameMaster.cards."$( $suit )_$( [int]$value - 1 )".cell -eq $Cell ) {
                    return $true
                }
            }
        }
    } else  {
        if ( [int]$value -lt 13 ) {
            return ( Confirm-OneUpOppositeSuit -GameMaster $GameMaster -Cell $Cell -Card $Card )
        } else {
            return ( Confirm-EmptyColumn -GameMaster $GameMaster -Cell $Cell )
        }
    }
    
    return $false
}

function Set-Card {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell,
        [string]$Card
    )

    if ( $GameMaster.debug ) {
        Write-Host "Set-Card | $( $Cell ) | $( $Card )"
    }

    $split = $Cell.Split( '_' )
    $column = $split[0]
    $row = $split[1]

    if ( $GameMaster.cards.$Card.faceUp ) {
        $GameMaster."col$( $column )"."$( $row )".BackgroundImage = $GameMaster.cards.$Card.image
    } else {
        $GameMaster."col$( $column )"."$( $row )".BackgroundImage = $GameMaster.cards.back.image
    }

    if ( [int]$row -gt 0 ) {
        $GameMaster."col$( $column )"."$( [int]$row - 1 )".Size = $GameMaster.smallSize
    }

    $GameMaster."col$( $column )"."$( $row )".Size = $GameMaster.normalSize
    $GameMaster.cards.$Card.cell = $Cell

    return
}

function Move-Card {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell,
        [string]$Card
    )

    if ( $GameMaster.debug ) {
        Write-Host "Move-Card | $( $Cell ) | $( $Card )"
    }

    $GameMaster.tempCell = Get-TopCardCell -GameMaster $GameMaster -Cell $Cell

    if ( -not $GameMaster.tempCell ) {
        $split = $Cell.Split( '_' )
    } else {
        $split = $GameMaster.tempCell.Split( '_' )
    }
    $column = $split[0]
    $row = $split[1]

    if ( $GameMaster.cards.$Card.cell -eq $Cell ) {
        return
    }

    if ( Confirm-CanPlaceCard -GameMaster $GameMaster -Cell $GameMaster.tempCell -Card $Card ) {
        if ( $row -eq "f" ) {
            $GameMaster.foundation."col$( $column )"."$( $column )".BackgroundImage = $GameMaster.cards.$Card.image

            $prevSplit = $GameMaster.cards.$Card.cell.Split( '_' )
            $prevColumn = $prevSplit[0]
            $prevRow = $prevSplit[1]
            $GameMaster."col$( $prevColumn )"."$( $prevRow )".BackgroundImage = $GameMaster.cards.blank.image
            if ( [int]$prevRow -gt 0 ) {
                $GameMaster."col$( $prevColumn )"."$( $prevRow )".Size = $GameMaster.smallSize
                $GameMaster."col$( $prevColumn )"."$( [int]$prevRow - 1 )".Size = $GameMaster.normalSize
                $GameMaster.tempCard = Find-Card -GameMaster $GameMaster -Cell "$( $prevColumn )_$( [int]$prevRow - 1 )"
                if ( -not $GameMaster.cards."$( $GameMaster.tempCard )".faceUp ) {
                    Set-FlipCard -GameMaster $GameMaster -Card "$( $GameMaster.tempCard )"
                    $GameMaster."col$( $prevColumn )"."$( [int]$prevRow - 1 )".BackgroundImage = $GameMaster.cards."$( $GameMaster.tempCard )".image
                }
            }

            $GameMaster.cards.$Card.cell = $Cell

        } else {
            $prevSplit = $GameMaster.cards.$Card.cell.Split( '_' )
            $prevColumn = $prevSplit[0]
            $prevRow = $prevSplit[1]

            if ( [int]$GameMaster.cards.$Card.value -eq 13 ) {
                $GameMaster."col$( $column )"."$( $row )".Size = $GameMaster.normalSize
                $GameMaster."col$( $column )"."$( $row )".BackgroundImage = $GameMaster.cards.$Card.image

                $GameMaster."col$( $prevColumn )"."$( $prevRow )".BackgroundImage = $GameMaster.cards.blank.image
                if ( $GameMaster."col$( $prevColumn )"."$( $prevRow )".Size -eq $GameMaster.smallSize ) {
                    $GameMaster.tempCard = Find-Card -GameMaster $GameMaster -Cell "$( $prevColumn )_$( [int]$prevRow + 1 )"
                    Move-Card -GameMaster $GameMaster -Cell "$( $column )_$( [int]$row + 1 )" -Card "$( $GameMaster.tempCard )"
                }
                if ( [int]$prevRow -eq "f" ) {
                    $GameMaster.pile.RemoveAt(( $GameMaster.pile.Count - 1 ))
                    $GameMaster.foundation.col1."1".BackgroundImage = $GameMaster.cards."$( $GameMaster.pile[( $GameMaster.pile.Count - 1 )] )"
                } elseif ( [int]$prevRow -gt 0 ) {
                    $GameMaster."col$( $prevColumn )"."$( $prevRow )".Size = $GameMaster.smallSize
                    $GameMaster."col$( $prevColumn )"."$( [int]$prevRow - 1 )".Size = $GameMaster.normalSize
                    $GameMaster.tempCard = Find-Card -GameMaster $GameMaster -Cell "$( $prevColumn )_$( [int]$prevRow - 1 )"
                    if ( -not $GameMaster.cards."$( $GameMaster.tempCard )".faceUp ) {
                        Set-FlipCard -GameMaster $GameMaster -Card "$( $GameMaster.tempCard )"
                        $GameMaster."col$( $prevColumn )"."$( [int]$prevRow - 1 )".BackgroundImage = $GameMaster.cards."$( $GameMaster.tempCard )".image
                    }
                }

                $GameMaster.cards.$Card.cell = "$( $column )_$( $row )"
            } else {
                $GameMaster."col$( $column )"."$( $row )".Size = $GameMaster.smallSize
                $GameMaster."col$( $column )"."$( [int]$row + 1 )".Size = $GameMaster."col$( $prevColumn )"."$( $prevRow )".Size
                $GameMaster."col$( $column )"."$( [int]$row + 1 )".BackgroundImage = $GameMaster.cards.$Card.image

                $GameMaster."col$( $prevColumn )"."$( $prevRow )".BackgroundImage = $GameMaster.cards.blank.image
                if ( $GameMaster."col$( $prevColumn )"."$( $prevRow )".Size -eq $GameMaster.smallSize ) {
                    $GameMaster.tempCard = Find-Card -GameMaster $GameMaster -Cell "$( $prevColumn )_$( [int]$prevRow + 1 )"
                    Move-Card -GameMaster $GameMaster -Cell "$( $column )_$( [int]$row + 1 )" -Card "$( $GameMaster.tempCard )"
                }
                if ( [int]$prevRow -gt 0 ) {
                    $GameMaster."col$( $prevColumn )"."$( $prevRow )".Size = $GameMaster.smallSize
                    $GameMaster."col$( $prevColumn )"."$( [int]$prevRow - 1 )".Size = $GameMaster.normalSize
                    $GameMaster.tempCard = Find-Card -GameMaster $GameMaster -Cell "$( $prevColumn )_$( [int]$prevRow - 1 )"
                    if ( -not $GameMaster.cards."$( $GameMaster.tempCard )".faceUp ) {
                        Set-FlipCard -GameMaster $GameMaster -Card "$( $GameMaster.tempCard )"
                        $GameMaster."col$( $prevColumn )"."$( [int]$prevRow - 1 )".BackgroundImage = $GameMaster.cards."$( $GameMaster.tempCard )".image
                    }
                }

                $GameMaster.cards.$Card.cell = "$( $column )_$( [int]$row + 1 )"
            }
        }
    }

    return
}

function Reset-Cards {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    foreach ( $property in $GameMaster.cards.PSObject.Properties ) {
        $GameMaster.cards."$( $property.Name )".faceUp = $false
        $GameMaster.cards."$( $property.Name )".cell = ""
    }

    return
}

function Reset-Cells {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    foreach ( $row in 0..( $GameMaster.tableRowCount - 1 )) {
        foreach ( $column in 0..6 ) {
            $GameMaster."col$( $column )"."$( $row )".BackgroundImage = $GameMaster.cards.blank.image
            $GameMaster."col$( $column )"."$( $row )".Size = $GameMaster.smallSize
        }
    }
    return
}

function Set-ShuffleDeck {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $cardsRemaining = [System.Collections.ArrayList]::new()
    foreach( $suit in 0..3 ) {
        foreach( $value in 1..13 ) {
            $cardsRemaining.Add( "$( $suit )_$( $value )" ) | Out-Null
        }
    }

    foreach( $num in 0..51 ) {
        $seed = [int](Get-Date -Format "ssffff")
        $randCard = Get-Random -InputObject $cardsRemaining -SetSeed $seed
        $GameMaster.deck.Add( $randCard ) | Out-Null
        $cardsRemaining.Remove( $randCard ) | Out-Null
    }

    return
}

function Set-DealDeck {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    foreach( $row in 0..6 ) {
        foreach( $column in 0..6 ) {
            if ( [int]$column -ge ( [int]$row )) {
                if ( $column -lt ( [int]$row + 1 )) {
                    Set-FlipCard -GameMaster $GameMaster -Card "$( $GameMaster.deck[0] )"
                    Set-Card -GameMaster $GameMaster -Cell "$( $column )_$( $row )" -Card "$( $GameMaster.deck[0] )"
                } else {
                    Set-Card -GameMaster $GameMaster -Cell "$( $column )_$( $row )" -Card "$( $GameMaster.deck[0] )"
                }
                $GameMaster.deck.RemoveAt(0)
            }
        }
    }

    return
}

function New-Foundation {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.foundation.col0."0".BackgroundImage = $GameMaster.cards."back".image
    $GameMaster.foundation.col2."2".BackgroundImage = $GameMaster.cards."unused".image
    $GameMaster.foundation.col3."3".BackgroundImage = $GameMaster.cards."0_f".image
    $GameMaster.foundation.col4."4".BackgroundImage = $GameMaster.cards."1_f".image
    $GameMaster.foundation.col5."5".BackgroundImage = $GameMaster.cards."2_f".image
    $GameMaster.foundation.col6."6".BackgroundImage = $GameMaster.cards."3_f".image

    return
}

function New-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.deck.Clear()
    $GameMaster.start = $true

    New-Foundation -GameMaster $GameMaster

    Reset-Cards -GameMaster $GameMaster

    Reset-Cells -GameMaster $GameMaster

    Set-ShuffleDeck -GameMaster $GameMaster

    Set-DealDeck -GameMaster $GameMaster

    return
}

$gameMaster = [PSCustomObject]@{
    debug = $false
    start = $false
    cards = [PSCustomObject]@{}
    deck = [System.Collections.ArrayList]::new()
    pile = [System.Collections.ArrayList]::new()
    normalSize = [System.Drawing.Size]::new( 98, 142 )
    smallSize = [System.Drawing.Size]::new( 98, ( 142 / 6 ))
    foundation = [PSCustomObject]@{}
    selectedCard = ""
    tempCard = ""
    tempCell = ""
    tableRowCount = 20
}

$imagePath = ".\Cards"
$cards = Get-ChildItem -Path $imagePath
foreach ( $card in $cards ) {
    $name = $card.Name.Replace( '.png', '' )
    $split = $name.Split( "_" )
    $count = $split.Count
    try {
        $gameMaster.cards | Add-Member -MemberType NoteProperty -Name "$( $name )" -Value $( [PSCustomObject]@{} ) -ErrorAction Stop
    } catch {
        $gameMaster.cards.PSObject.Properties.remove( "$( $name )" )
        $gameMaster.cards | Add-Member -MemberType NoteProperty -Name "$( $name )" -Value $( [PSCustomObject]@{} )
    }

    $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "image" -Value $( [System.Drawing.Image]::FromFile( $card.FullName ) )
    $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "cell" -Value $( "" )
    $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "suit" -Value $( $split[0] )
    if ( $count -le 1 ) {
        $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "value" -Value $( "0" )
        $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "faceUp" -Value $( $false )
    } elseif ( $split[1] -eq "f" ) {
        $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "value" -Value $( "f" )
        $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "faceUp" -Value $( $true )
    } else {
        $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "value" -Value $( [int]$split[1] )
        $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "faceUp" -Value $( $false )
    }
}

$form = [System.Windows.Forms.Form]::new()
$form.Text = "Card Game"
$form.Add_Closed({ Clear-Images -GameMaster $gameMaster })
$form.Name = "AutoSize"

$toolStrip = [System.Windows.Forms.ToolStrip]::new()
$toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
$toolStrip.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden
$mainPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$mainPanel.Padding = [System.Windows.Forms.Padding]::new( 5, $toolStrip.Height, 5, 5 )
$mainPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$mainPanel.Name = "AutoSize"
$form.Controls.Add( $toolStrip ) | Out-Null
$form.Controls.Add( $mainPanel ) | Out-Null

$newGameButton = [System.Windows.Forms.ToolStripButton]::new()
$newGameButton.Text = "New Game"
$newGameButton.Padding = [System.Windows.Forms.Padding]::new( 0, 0, 5, 0 )
$newGameButton.Add_Click({ New-Game -GameMaster $gameMaster })
$toolStrip.Items.Add( $newGameButton ) | Out-Null

$gridOuter = [System.Windows.Forms.TableLayoutPanel]::new()
$gridOuter.Dock = [System.Windows.Forms.DockStyle]::Fill
$gridOuter.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
$gridOuter.Name = "AutoSize"
$gridMid = [System.Windows.Forms.FlowLayoutPanel]::new()
$gridMid.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$gridMid.Name = "AutoSize"
$tableRowCount = 20
$tableColumnCount = 7

foreach( $column in 0..( $tableColumnCount - 1 )) {
    $tableName = "table$( $column )"
    $colName = "col$( $column )"
    try {
        $gameMaster.foundation | Add-Member -MemberType NoteProperty -Name $tableName -Value $( [System.Windows.Forms.TableLayoutPanel]::new()) -ErrorAction Stop
    } catch {
        $gameMaster.foundation.PSObject.Properties.Remove( $tableName )
        $gameMaster.foundation | Add-Member -MemberType NoteProperty -Name $tableName -Value $( [System.Windows.Forms.TableLayoutPanel]::new())
    }

    try {
        $gameMaster.foundation | Add-Member -MemberType NoteProperty -Name $colName -Value $( [PSCustomObject]@{}) -ErrorAction Stop
    } catch {
        $gameMaster.foundation.PSObject.Properties.Remove( $colName )
        $gameMaster.foundation | Add-Member -MemberType NoteProperty -Name $colName -Value $( [PSCustomObject]@{})
    }

    $gameMaster.foundation.$tableName.RowCount = 1
    $gameMaster.foundation.$tableName.ColumnCount = 1
    $gameMaster.foundation.$tableName.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
    $gameMaster.foundation.$tableName.Name = "AutoSize"
    $gridMid.Controls.Add( $gameMaster.foundation.$tableName ) | Out-Null
}
foreach ( $column in 0..6 ) {
    $name = "$( $column )"
    $tableName = "table$( $column )"
    $colName = "col$( $column )"
    try {
        $gameMaster.foundation.$colName | Add-Member -MemberType NoteProperty -Name $name -Value $( [System.Windows.Forms.Label]::new()) -ErrorAction Stop
    } catch {
        $gameMaster.foundation.$colName.PSObject.Properties.remove( $name )
        $gameMaster.foundation.$colName | Add-Member -MemberType NoteProperty -Name $name -Value $( [System.Windows.Forms.Label]::new())
    }

    $gameMaster.foundation.$colName.$name.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $gameMaster.foundation.$colName.$name.Font = [System.Drawing.Font]::new( "Verdana", 14 )
    $gameMaster.foundation.$colName.$name.Size = [System.Drawing.Size]::new( 1, 1 )
    $gameMaster.foundation.$colName.$name.Size = $gameMaster.cards.blank.image.Size
    $gameMaster.foundation.$colName.$name.Padding = [System.Windows.Forms.Padding]::new( 0 )
    $gameMaster.foundation.$colName.$name.Margin = [System.Windows.Forms.Padding]::new( 0 )
    $gameMaster.foundation.$colName.$name.Dock = [System.Windows.Forms.DockStyle]::Fill
    $gameMaster.foundation.$colName.$name.Name = "$( $column )_f"
    $gameMaster.foundation.$colName.$name.Text = ""
    $gameMaster.foundation.$colName.$name.BackgroundImage = $gameMaster.cards.blank.image
    $gameMaster.foundation.$colName.$name.AllowDrop = $true
    $gameMaster.foundation.$colName.$name.Add_MouseClick({ 
        param($sender, $event)
        if ( $event.button -eq "Left" ) {
            New-MouseClick -GameMaster $gameMaster -Cell $this.Name -Left
        } elseif ( $event.button -eq "Right" ) {
            New-MouseClick -GameMaster $gameMaster -Cell $this.Name -Right
        }
    })
    $gameMaster.foundation.$colName.$name.Add_MouseDown({ 
        param($sender, $event)
        if ( $event.button -eq "Left" ) {
            New-MouseDown -GameMaster $gameMaster -Cell $this.Name -Left
        } elseif ( $event.button -eq "Right" ) {
            New-MouseDown -GameMaster $gameMaster -Cell $this.Name -Right
        }
    })
    $gameMaster.foundation.$colName.$name.Add_MouseUp({ New-MouseUp -GameMaster $gameMaster -Cell $this.Name })
    $gameMaster.foundation.$colName.$name.Add_DragEnter({ 
        param($sender, $event)
        $event.Effect = [System.Windows.Forms.DragDropEffects]::Link
        New-DragEnter -GameMaster $gameMaster -Cell $this.Name 
    })
    $gameMaster.foundation.$colName.$name.Add_DragLeave({ New-DragLeave -GameMaster $gameMaster -Cell $this.Name })
    $gameMaster.foundation.$colName.$name.Add_DragDrop({ New-DragDrop -GameMaster $gameMaster -Cell $this.Name })

    $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, 0 )
    $gameMaster.foundation.$tableName.SetCellPosition( $gameMaster.foundation.$colName.$name, $cellPosition )
    $gameMaster.foundation.$tableName.Controls.Add( $gameMaster.foundation.$colName.$name )
}
$gridMid.Controls.Add( $gameMaster.foundation.table ) | Out-Null
$gridMid.SetFlowBreak( $gameMaster.foundation.table6, $true )

foreach( $column in 0..( $tableColumnCount - 1 )) {
    $tableName = "table$( $column )"
    $colName = "col$( $column )"
    try {
        $gameMaster | Add-Member -MemberType NoteProperty -Name $tableName -Value $( [System.Windows.Forms.TableLayoutPanel]::new()) -ErrorAction Stop
    } catch {
        $gameMaster.PSObject.Properties.Remove( $tableName )
        $gameMaster | Add-Member -MemberType NoteProperty -Name $tableName -Value $( [System.Windows.Forms.TableLayoutPanel]::new())
    }

    try {
        $gameMaster | Add-Member -MemberType NoteProperty -Name $colName -Value $( [PSCustomObject]@{}) -ErrorAction Stop
    } catch {
        $gameMaster.PSObject.Properties.Remove( $colName )
        $gameMaster | Add-Member -MemberType NoteProperty -Name $colName -Value $( [PSCustomObject]@{})
    }

    $gameMaster.$tableName.RowCount = $tableRowCount
    $gameMaster.$tableName.ColumnCount = 1
    $gameMaster.$tableName.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
    $gameMaster.$tableName.Name = "AutoSize"
    $gridMid.Controls.Add( $gameMaster.$tableName ) | Out-Null
}
$gridOuter.Controls.Add( $gridMid ) | Out-Null
$mainPanel.Controls.Add( $gridOuter ) | Out-Null

foreach ( $row in 0..( $tableRowCount - 1 )) {
    foreach ( $column in 0..6 ) {
        $name = "$( $row )"
        $tableName = "table$( $column )"
        $colName = "col$( $column )"
        try {
            $gameMaster.$colName | Add-Member -MemberType NoteProperty -Name $name -Value $( [System.Windows.Forms.Label]::new()) -ErrorAction Stop
        } catch {
            $gameMaster.$colName.PSObject.Properties.remove( $name )
            $gameMaster.$colName | Add-Member -MemberType NoteProperty -Name $name -Value $( [System.Windows.Forms.Label]::new())
        }

        $gameMaster.$colName.$name.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $gameMaster.$colName.$name.Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $gameMaster.$colName.$name.Size = [System.Drawing.Size]::new( 1, 1 )
        if ( $row -eq 0 ) {
            $gameMaster.$colName.$name.Size = $gameMaster.cards.blank.image.Size
        } else {
            $gameMaster.$colName.$name.Size = $gameMaster.smallSize
        }
        $gameMaster.$colName.$name.Padding = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.$colName.$name.Margin = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.$colName.$name.Dock = [System.Windows.Forms.DockStyle]::Fill
        $gameMaster.$colName.$name.Name = "$( $column )_$( $row )"
        $gameMaster.$colName.$name.Text = ""
        $gameMaster.$colName.$name.BackgroundImage = $gameMaster.cards.blank.image
        $gameMaster.$colName.$name.AllowDrop = $true
        $gameMaster.$colName.$name.Add_MouseClick({ 
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseClick -GameMaster $gameMaster -Cell $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseClick -GameMaster $gameMaster -Cell $this.Name -Right
            }
        })
        $gameMaster.$colName.$name.Add_MouseDown({ 
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseDown -GameMaster $gameMaster -Cell $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseDown -GameMaster $gameMaster -Cell $this.Name -Right
            }
        })
        $gameMaster.$colName.$name.Add_MouseUp({ New-MouseUp -GameMaster $gameMaster -Cell $this.Name })
        $gameMaster.$colName.$name.Add_DragEnter({ 
            param($sender, $event)
            $event.Effect = [System.Windows.Forms.DragDropEffects]::Link
            New-DragEnter -GameMaster $gameMaster -Cell $this.Name 
        })
        $gameMaster.$colName.$name.Add_DragLeave({ New-DragLeave -GameMaster $gameMaster -Cell $this.Name })
        $gameMaster.$colName.$name.Add_DragDrop({ New-DragDrop -GameMaster $gameMaster -Cell $this.Name })

        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $gameMaster.$tableName.SetCellPosition( $gameMaster.$colName.$name, $cellPosition )
        $gameMaster.$tableName.Controls.Add( $gameMaster.$colName.$name )
    }
}

Set-AutoSize -Control $form

$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.ShowDialog() | Out-Null
