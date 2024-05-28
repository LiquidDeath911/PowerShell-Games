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

    foreach ( $property in $GameMaster.other.PSObject.Properties ) {
        $GameMaster.other."$( $property.Name )".image.Dispose()
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
        Write-Host "New-MouseClick | $( $Cell ) | L-$( $Left ) | R-$( $Right )"
    }

    $split = $Cell.Split( '_' )
    $column = [int]$split[0]
    $row = [int]$split[1]
    $type = [int]$split[2]

    if ( $Left ) {
        if ( $Cell -eq "0_0_0" ) {
            Pop-Card -GameMaster $GameMaster
        } else {
            $GameMaster.fromCell = $Cell
            Get-FromInfo -GameMaster $GameMaster
            if ( Confirm-CanSelectCard -GameMaster $GameMaster ) {
                $GameMaster.toCell = "$( $GameMaster.cards."$( $GameMaster.from.card )".suit )_0_1"
                Get-ToInfo -GameMaster $GameMaster
                if ( Confirm-CanPlaceCard -GameMaster $GameMaster ) {
                    Move-Card -GameMaster $GameMaster
                }
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
        Write-Host "New-MouseDown | $( $Cell ) | L-$( $Left ) | R-$( $Right )"
    }

    if ( $Left ) {
        $GameMaster.fromCell = $Cell
        Get-FromInfo -GameMaster $GameMaster
        if ( Confirm-CanSelectCard -GameMaster $GameMaster ) {
            switch( $GameMaster.from.type ) {
                0 { $GameMaster.cells.deck."$( $GameMaster.from.cell )".label.DoDragDrop( "", [System.Windows.Forms.DragDropEffects]::Link ) }
                1 { $GameMaster.cells.foundation."$( $GameMaster.from.cell )".label.DoDragDrop( "", [System.Windows.Forms.DragDropEffects]::Link ) }
                2 { $GameMaster.cells.main."$( $GameMaster.from.cell )".label.DoDragDrop( "", [System.Windows.Forms.DragDropEffects]::Link ) }
            }
        }
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
        Write-Host "New-DragDrop | $( $Cell )"
    }

    $GameMaster.toCell = $Cell
    Get-ToInfo -GameMaster $GameMaster

    if ( $GameMaster.from.type -eq $GameMaster.to.type ) {
        if ( $GameMaster.from.column -eq $GameMaster.to.column ) {
            New-MouseClick -GameMaster $GameMaster -Cell $GameMaster.fromCell -Left
            return
        }
    }

    if ( $GameMaster.to.type -eq 2 ) {
        $GameMaster.toCell = Get-UnblockedCard -GameMaster $GameMaster -Cell $Cell
        Get-ToInfo -GameMaster $GameMaster
    }

    if ( Confirm-CanPlaceCard -GameMaster $GameMaster ) {
        Move-Card -GameMaster $GameMaster
    }


    return

}

function Get-FromInfo {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Get-FromInfo"
    }

    $fromSplit = $GameMaster.fromCell.Split( '_' )
    $fromColumn = [int]$fromSplit[0]
    $fromRow = [int]$fromSplit[1]
    $fromType = [int]$fromSplit[2]
    $fromCell = "$( $fromColumn )_$( $fromRow )"

    switch( $fromType ) {
        0 { $fromCard = $GameMaster.cells.deck.$fromCell.card }
        1 { $fromCard = $GameMaster.cells.foundation.$fromCell.card }
        2 { $fromCard = $GameMaster.cells.main.$fromCell.card }
    }

    $GameMaster.from.column = $fromColumn
    $GameMaster.from.row = $fromRow
    $GameMaster.from.type = $fromType
    $GameMaster.from.cell = $fromCell
    $GameMaster.from.card = $fromCard

    return
}

function Reset-FromInfo {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Reset-FromInfo"
    }

    $GameMaster.from.column = ""
    $GameMaster.from.row = ""
    $GameMaster.from.type = ""
    $GameMaster.from.cell = ""
    $GameMaster.from.card = ""

    $GameMaster.fromCell = ""

    return
}

function Get-ToInfo {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Get-FromInfo"
    }

    $toSplit = $GameMaster.toCell.Split( '_' )
    $toColumn = [int]$toSplit[0]
    $toRow = [int]$toSplit[1]
    $toType = [int]$toSplit[2]
    $toCell = "$( $toColumn )_$( $toRow )"

    switch( $toType ) {
        0 { $toCard = $GameMaster.cells.deck.$toCell.card }
        1 { $toCard = $GameMaster.cells.foundation.$toCell.card }
        2 { $toCard = $GameMaster.cells.main.$toCell.card }
    }

    $GameMaster.to.column = $toColumn
    $GameMaster.to.row = $toRow
    $GameMaster.to.type = $toType
    $GameMaster.to.cell = $toCell
    $GameMaster.to.card = $toCard

    return
}

function Reset-ToInfo {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Reset-ToInfo"
    }

    $GameMaster.to.column = ""
    $GameMaster.to.row = ""
    $GameMaster.to.type = ""
    $GameMaster.to.cell = ""
    $GameMaster.to.card = ""

    $GameMaster.toCell = ""

    return
}

function Pop-Card {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Pop-Card"
    }

    Save-GameState -GameMaster $GameMaster

    if ( $GameMaster.drawOne ) {
        if ( $GameMaster.deck.Count -gt 0 ) {
            $GameMaster.cells.deck."3_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.deck[0] )".image

            $GameMaster.cells.deck."1_0".label.Size = $GameMaster.size.deckSmall
            $GameMaster.cells.deck."2_0".label.Size = $GameMaster.size.deckSmall
            $GameMaster.cells.deck."3_0".label.Size = $GameMaster.size.normal

            $GameMaster.cells.deck."3_0".card = "$( $GameMaster.deck[0] )"

            $GameMaster.pile.Add( $GameMaster.deck[0] ) | Out-Null

            $GameMaster.cards."$( $GameMaster.deck[0] )".faceUp = $true
            $GameMaster.deck.RemoveAt( 0 )
        } else {
            Pop-Deck -GameMaster $GameMaster
            return
        }
    } else {
        if ( $GameMaster.deck.Count -ge 3 ) {
            $GameMaster.cells.deck."1_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.deck[0] )".image
            $GameMaster.cells.deck."2_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.deck[1] )".image
            $GameMaster.cells.deck."3_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.deck[2] )".image

            $GameMaster.cells.deck."1_0".label.Size = $GameMaster.size.deckSmall
            $GameMaster.cells.deck."2_0".label.Size = $GameMaster.size.deckSmall
            $GameMaster.cells.deck."3_0".label.Size = $GameMaster.size.normal

            $GameMaster.cells.deck."1_0".card = "$( $GameMaster.deck[0] )"
            $GameMaster.cells.deck."2_0".card = "$( $GameMaster.deck[1] )"
            $GameMaster.cells.deck."3_0".card = "$( $GameMaster.deck[2] )"

            $GameMaster.pile.Add( $GameMaster.deck[0] ) | Out-Null
            $GameMaster.pile.Add( $GameMaster.deck[1] ) | Out-Null
            $GameMaster.pile.Add( $GameMaster.deck[2] ) | Out-Null

            $GameMaster.cards."$( $GameMaster.deck[0] )".faceUp = $true
            $GameMaster.cards."$( $GameMaster.deck[1] )".faceUp = $true
            $GameMaster.cards."$( $GameMaster.deck[2] )".faceUp = $true
            $GameMaster.deck.RemoveAt( 2 )
            $GameMaster.deck.RemoveAt( 1 )
            $GameMaster.deck.RemoveAt( 0 )

        } elseif ( $GameMaster.deck.Count -eq 2 ) {
            $GameMaster.cells.deck."1_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.deck[0] )".image
            $GameMaster.cells.deck."2_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.deck[1] )".image
            $GameMaster.cells.deck."3_0".label.BackgroundImage = $GameMaster.other.blank.image

            $GameMaster.cells.deck."1_0".label.Size = $GameMaster.size.deckSmall
            $GameMaster.cells.deck."3_0".label.Size = $GameMaster.size.deckSmall
            $GameMaster.cells.deck."2_0".label.Size = $GameMaster.size.normal

            $GameMaster.cells.deck."1_0".card = "$( $GameMaster.deck[0] )"
            $GameMaster.cells.deck."2_0".card = "$( $GameMaster.deck[1] )"

            $GameMaster.pile.Add( $GameMaster.deck[0] ) | Out-Null
            $GameMaster.pile.Add( $GameMaster.deck[1] ) | Out-Null

            $GameMaster.cards."$( $GameMaster.deck[0] )".faceUp = $true
            $GameMaster.cards."$( $GameMaster.deck[1] )".faceUp = $true
            $GameMaster.deck.RemoveAt( 1 )
            $GameMaster.deck.RemoveAt( 0 )
        } elseif ( $GameMaster.deck.Count -eq 1 ) {
            $GameMaster.cells.deck."1_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.deck[0] )".image
            $GameMaster.cells.deck."2_0".label.BackgroundImage = $GameMaster.other.blank.image
            $GameMaster.cells.deck."3_0".label.BackgroundImage = $GameMaster.other.blank.image

            $GameMaster.cells.deck."2_0".label.Size = $GameMaster.size.deckSmall
            $GameMaster.cells.deck."3_0".label.Size = $GameMaster.size.deckSmall
            $GameMaster.cells.deck."1_0".label.Size = $GameMaster.size.normal

            $GameMaster.cells.deck."1_0".card = "$( $GameMaster.deck[0] )"

            $GameMaster.pile.Add( $GameMaster.deck[0] ) | Out-Null

            $GameMaster.cards."$( $GameMaster.deck[0] )".faceUp = $true
            $GameMaster.deck.RemoveAt( 0 )
        } else {
            Pop-Deck -GameMaster $GameMaster
            return
        }
    }

    if ( $GameMaster.deck.Count -eq 0 ) {
        $GameMaster.cells.deck."0_0".label.BackgroundImage = $GameMaster.other.blank.image
    }

    return
}

function Pop-Deck {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Pop-Deck"
    }

    $GameMaster.deck.Clear()

    foreach ( $card in $GameMaster.pile ) {
        $GameMaster.deck.Add( $card ) | Out-Null
        $GameMaster.cards.$card.faceUp = $false
    }

    $GameMaster.pile.Clear()

    $GameMaster.cells.deck."0_0".label.BackgroundImage = $GameMaster.other.back.image

    $GameMaster.cells.deck."1_0".label.BackgroundImage = $GameMaster.other.blank.image
    $GameMaster.cells.deck."2_0".label.BackgroundImage = $GameMaster.other.blank.image
    $GameMaster.cells.deck."3_0".label.BackgroundImage = $GameMaster.other.blank.image

    $GameMaster.cells.deck."1_0".label.Size = $GameMaster.size.deckSmall
    $GameMaster.cells.deck."2_0".label.Size = $GameMaster.size.deckSmall
    $GameMaster.cells.deck."3_0".label.Size = $GameMaster.size.normal

    return
}

function Get-UnblockedCard {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell
    )

    if ( $GameMaster.debug ) {
        Write-Host "Get-UnblockedCard"
    }

    $toSplit = $Cell.Split( '_' )
    $toColumn = [int]$toSplit[0]
    $toRow = [int]$toSplit[1]
    $toType = [int]$toSplit[2]
    $toCell = "$( $toColumn )_$( $toRow )"

    switch( $toType ) {
        0 { return $toCell }
        1 { return $toCell }
        2 {
            foreach ( $row in 0..( $GameMaster.layout.mainRows - 1 )) {
                $cell = "$( $toColumn )_$( $row )"
                if ( $GameMaster.cells.main.$cell.label.Size -eq $GameMaster.size.normal ) {
                    $cell = "$( $toColumn )_$( $row )_2"
                    return $cell
                }
            }
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

function Confirm-CanSelectCard {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Confirm-CanSelectCard"
        Write-Host ( $GameMaster.from )
        Write-Host ( $GameMaster.from.card -ne "" )
        Write-Host ( $GameMaster.cards."$( $GameMaster.from.card )".faceUp )
        Write-Host ( $GameMaster.cells.deck."$( $GameMaster.from.cell )".label.Size -eq $GameMaster.size.normal )
    }

    if ( $GameMaster.from.card -ne "" ) {
        if ( $GameMaster.cards."$( $GameMaster.from.card )".faceUp ) {
            switch( $GameMaster.from.type ) {
                0 { if ( $GameMaster.cells.deck."$( $GameMaster.from.cell )".label.Size -eq $GameMaster.size.normal ) { return $true } }
                1 { return $true }
                2 { return $true }
            }
        }
    }

    return $false
}

function Confirm-CardValueDifference {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Difference
    )

    if ( $GameMaster.debug ) {
        Write-Host "Confirm-CardValueDifference | $( $Difference )"
        Write-Host ( $GameMaster.cards."$( $GameMaster.to.card )".value )
        Write-Host ( $GameMaster.cards."$( $GameMaster.from.card )".value )
    }



    if (( [int]( $GameMaster.cards."$( $GameMaster.to.card )".value ) - [int]( $GameMaster.cards."$( $GameMaster.from.card )".value )) -eq $Difference ) {
        return $true
    }
    
    return $false
}

function Confirm-CardOppositeColor {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Confirm-CardOppositeSuit"
        Write-Host ( $GameMaster.cards."$( $GameMaster.from.card )".color -ne $GameMaster.cards."$( $GameMaster.to.card )".color )
    }

    if ( $GameMaster.cards."$( $GameMaster.from.card )".color -ne $GameMaster.cards."$( $GameMaster.to.card )".color ) {
        return $true
    }
    
    return $false
}

function Confirm-EmptyColumn {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Confirm-EmptyColumn"
        switch( $GameMaster.to.type ) {
            0 { Write-Host ( -not $GameMaster.cells.deck."$( $GameMaster.to.cell )".card ) }
            1 { Write-Host ( -not $GameMaster.cells.foundation."$( $GameMaster.to.cell )".card ) }
            2 { Write-Host ( -not $GameMaster.cells.main."$( $GameMaster.to.cell )".card ) }
        }
    }

    switch( $GameMaster.to.type ) {
        0 { if ( -not $GameMaster.cells.deck."$( $GameMaster.to.cell )".card ) { return $true } }
        1 { if ( -not $GameMaster.cells.foundation."$( $GameMaster.to.cell )".card ) { return $true } }
        2 { if ( -not $GameMaster.cells.main."$( $GameMaster.to.cell )".card ) { return $true } }
    }
    
    return $false
}

function Confirm-CanPlaceOnFoundation {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Confirm-CanPlaceOnFoundation"
        Write-Host ( $GameMaster.cards."$( $GameMaster.from.card )".value -eq 1 )
        if ( -not ( $GameMaster.cards."$( $GameMaster.from.card )".value -eq 1 )) {
            switch( $GameMaster.cards."$( $GameMaster.from.card )".suit ) {
                0 { Write-Host ( $GameMaster.hearts -contains $cardOneLower ) }
                1 { Write-Host ( $GameMaster.diamonds -contains $cardOneLower ) }
                2 { Write-Host ( $GameMaster.spades -contains $cardOneLower ) }
                3 { Write-Host ( $GameMaster.clubs -contains $cardOneLower ) }
            }
        }
    }

    if ( $GameMaster.cards."$( $GameMaster.from.card )".value -eq 1 ) {
        return $true
    }

    $cardOneLower = "$( $GameMaster.cards."$( $GameMaster.from.card )".suit )_$( $GameMaster.cards."$( $GameMaster.from.card )".value - 1 )"

    switch( $GameMaster.cards."$( $GameMaster.from.card )".suit ) {
        0 { if ( $GameMaster.hearts -contains $cardOneLower ) { return $true } }
        1 { if ( $GameMaster.diamonds -contains $cardOneLower ) { return $true } }
        2 { if ( $GameMaster.spades -contains $cardOneLower ) { return $true } }
        3 { if ( $GameMaster.clubs -contains $cardOneLower ) { return $true } }
    }

    return $false

}

function Confirm-CanPlaceCard {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Confirm-CanPlaceCard"
    }

    if ( $GameMaster.to.type -eq 1 ) {
        # To Foundation
        return ( Confirm-CanPlaceOnFoundation -GameMaster $GameMaster )
    } else {
        if ( $GameMaster.cards."$( $GameMaster.from.card )".value -eq 13 ) {
            # King
            return ( Confirm-EmptyColumn -GameMaster $GameMaster )
        } else {
            # Not King
            if ( Confirm-CardOppositeColor -GameMaster $GameMaster ) {
                return ( Confirm-CardValueDifference -GameMaster $GameMaster -Difference 1 )
            }
        }
    }

    return $false
}

function Move-Card {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Move-Card"
        Write-Host $GameMaster.from
        Write-Host $GameMaster.to
    }

    $tempCell = $GameMaster.to.cell
    $GameMaster.to.cell = "$( $GameMaster.to.column )_$( $GameMaster.to.row + 1 )"

    switch( $GameMaster.to.type ) {
        0 {
            Reset-FromInfo -GameMaster $GameMaster
            Reset-ToInfo -GameMaster $GameMaster
            return
        }
        1 {
            Save-GameState -GameMaster $GameMaster
            switch( $GameMaster.cards."$( $GameMaster.from.card )".suit ) {
                0 { $GameMaster.hearts.Add( "$( $GameMaster.from.card )" ) | Out-Null }
                1 { $GameMaster.diamonds.Add( "$( $GameMaster.from.card )" ) | Out-Null }
                2 { $GameMaster.spades.Add( "$( $GameMaster.from.card )" ) | Out-Null }
                3 { $GameMaster.clubs.Add( "$( $GameMaster.from.card )" ) | Out-Null }
            }
            $tempCell = "$( $GameMaster.cards."$( $GameMaster.from.card )".suit )_0"
            $GameMaster.cells.foundation."$( $tempCell )".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.from.card )".image
            $GameMaster.cells.foundation."$( $tempCell )".card = "$( $GameMaster.from.card )"
            if ( $GameMaster.cards."$( $GameMaster.from.card )".value -eq 13 ) {
                if ( Confirm-Win -GameMaster $GameMaster ) {
                    Set-Win -GameMaster $GameMaster
                }
            }
        }
        2 {
            Save-GameState -GameMaster $GameMaster
            if ( $GameMaster.cards."$( $GameMaster.from.card )".value -eq 13 ) {
                $GameMaster.cells.main.$tempCell.label.BackgroundImage = $GameMaster.cards."$( $GameMaster.from.card )".image
                $GameMaster.cells.main.$tempCell.card = "$( $GameMaster.from.card )"
                if ( $GameMaster.from.type -eq 2 ) {
                    if ( $GameMaster.cells.main."$( $GameMaster.from.cell )".label.Size -ne $GameMaster.size.normal ) {
                        $GameMaster.cells.main.$tempCell.label.Size = $GameMaster.size.small
                    } else {
                        $GameMaster.cells.main.$tempCell.label.Size = $GameMaster.size.normal
                    }
                } else {
                    $GameMaster.cells.main.$tempCell.label.Size = $GameMaster.size.normal
                }
            } else {
                $GameMaster.cells.main."$( $GameMaster.to.cell )".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.from.card )".image
                $GameMaster.cells.main."$( $GameMaster.to.cell )".card = "$( $GameMaster.from.card )"

                $GameMaster.cells.main.$tempCell.label.Size = $GameMaster.size.small
                if ( $GameMaster.from.type -eq 2 ) {
                    if ( $GameMaster.cells.main."$( $GameMaster.from.cell )".label.Size -ne $GameMaster.size.normal ) {
                        $GameMaster.cells.main."$( $GameMaster.to.cell )".label.Size = $GameMaster.size.small
                    } else {
                        $GameMaster.cells.main."$( $GameMaster.to.cell )".label.Size = $GameMaster.size.normal
                    }
                } else {
                    $GameMaster.cells.main."$( $GameMaster.to.cell )".label.Size = $GameMaster.size.normal
                }
            }
        }
    }

    switch( $GameMaster.from.type ) {
        0 {
            $GameMaster.pile.Remove( "$( $GameMaster.from.card )" )
            if ( $GameMaster.drawOne ) {
                if ( $GameMaster.pile.Count -eq 0 ) {
                    $GameMaster.cells.deck."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.other.blank.image
                    $GameMaster.cells.deck."$( $GameMaster.from.cell )".card = ""
                } else {
                    $tempCard = "$( $GameMaster.pile[( $GameMaster.pile.Count - 1 )] )"
                    $GameMaster.cells.deck."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.cards.$tempCard.image
                    $GameMaster.cells.deck."$( $GameMaster.from.cell )".card = $tempCard
                }
            } else {
                switch( $GameMaster.from.column ) {
                    1 {
                        switch( $GameMaster.pile.Count ) {
                            0 {
                                $Gamemaster.cells.deck."1_0".label.Size = $GameMaster.size.deckSmall
                                $Gamemaster.cells.deck."2_0".label.Size = $GameMaster.size.deckSmall
                                $Gamemaster.cells.deck."3_0".label.Size = $GameMaster.size.normal

                                $GameMaster.cells.deck."1_0".label.BackgroundImage = $GameMaster.other.blank.image
                                $GameMaster.cells.deck."1_0".card = ""
                            }
                            1 {
                                $Gamemaster.cells.deck."2_0".label.Size = $GameMaster.size.deckSmall
                                $Gamemaster.cells.deck."3_0".label.Size = $GameMaster.size.deckSmall
                                $Gamemaster.cells.deck."1_0".label.Size = $GameMaster.size.normal

                                $GameMaster.cells.deck."1_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.pile[( $GameMaster.pile.Count - 1 )] )".image
                                $GameMaster.cells.deck."1_0".card = "$( $GameMaster.pile[( $GameMaster.pile.Count - 1 )] )"
                            }
                            2 {
                                $Gamemaster.cells.deck."1_0".label.Size = $GameMaster.size.deckSmall
                                $Gamemaster.cells.deck."3_0".label.Size = $GameMaster.size.deckSmall
                                $Gamemaster.cells.deck."2_0".label.Size = $GameMaster.size.normal

                                $GameMaster.cells.deck."1_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.pile[( $GameMaster.pile.Count - 2 )] )".image
                                $GameMaster.cells.deck."2_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.pile[( $GameMaster.pile.Count - 1 )] )".image
                                $GameMaster.cells.deck."1_0".card = "$( $GameMaster.pile[( $GameMaster.pile.Count - 2 )] )"
                                $GameMaster.cells.deck."2_0".card = "$( $GameMaster.pile[( $GameMaster.pile.Count - 1 )] )"
                            }
                            default {
                                $Gamemaster.cells.deck."1_0".label.Size = $GameMaster.size.deckSmall
                                $Gamemaster.cells.deck."2_0".label.Size = $GameMaster.size.deckSmall
                                $Gamemaster.cells.deck."3_0".label.Size = $GameMaster.size.normal

                                $GameMaster.cells.deck."1_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.pile[( $GameMaster.pile.Count - 3 )] )".image
                                $GameMaster.cells.deck."2_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.pile[( $GameMaster.pile.Count - 2 )] )".image
                                $GameMaster.cells.deck."3_0".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.pile[( $GameMaster.pile.Count - 1 )] )".image
                                $GameMaster.cells.deck."1_0".card = "$( $GameMaster.pile[( $GameMaster.pile.Count - 3 )] )"
                                $GameMaster.cells.deck."2_0".card = "$( $GameMaster.pile[( $GameMaster.pile.Count - 2 )] )"
                                $GameMaster.cells.deck."3_0".card = "$( $GameMaster.pile[( $GameMaster.pile.Count - 1 )] )"
                            }
                        }
                    }
                    2 {
                        $Gamemaster.cells.deck."2_0".label.Size = $GameMaster.size.deckSmall
                        $Gamemaster.cells.deck."3_0".label.Size = $GameMaster.size.deckSmall
                        $Gamemaster.cells.deck."1_0".label.Size = $GameMaster.size.normal

                        $GameMaster.cells.deck."2_0".label.BackgroundImage = $GameMaster.other.blank.image
                        $GameMaster.cells.deck."2_0".card = ""
                    }
                    3 {
                        $Gamemaster.cells.deck."1_0".label.Size = $GameMaster.size.deckSmall
                        $Gamemaster.cells.deck."3_0".label.Size = $GameMaster.size.deckSmall
                        $Gamemaster.cells.deck."2_0".label.Size = $GameMaster.size.normal

                        $GameMaster.cells.deck."3_0".label.BackgroundImage = $GameMaster.other.blank.image
                        $GameMaster.cells.deck."3_0".card = ""
                    }
                }
            }
        }
        1 {
            switch( $GameMaster.cards."$( $GameMaster.from.card )".suit ) {
                0 {
                    $GameMaster.hearts.Remove( "$( $GameMaster.from.card )" ) | Out-Null
                    if ( $GameMaster.hearts.Count -eq 0 ) {
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.other."0_f".image
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".card = ""
                    } else {
                        $tempCard = "$( $GameMaster.hearts[( $GameMaster.hearts.Count - 1 )] )"
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.cards.$tempCard.image
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".card = $tempCard
                    }
                }
                1 {
                    $GameMaster.diamonds.Remove( "$( $GameMaster.from.card )" ) | Out-Null
                    if ( $GameMaster.diamonds.Count -eq 0 ) {
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.other."1_f".image
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".card = ""
                    } else {
                        $tempCard = "$( $GameMaster.diamonds[( $GameMaster.diamonds.Count - 1 )] )"
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.cards.$tempCard.image
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".card = $tempCard
                    }
                }
                2 {
                    $GameMaster.spades.Remove( "$( $GameMaster.from.card )" ) | Out-Null
                    if ( $GameMaster.spades.Count -eq 0 ) {
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.other."2_f".image
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".card = ""
                    } else {
                        $tempCard = "$( $GameMaster.spades[( $GameMaster.spades.Count - 1 )] )"
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.cards.$tempCard.image
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".card = $tempCard
                    }
                }
                3 {
                    $GameMaster.clubs.Remove( "$( $GameMaster.from.card )" ) | Out-Null
                    if ( $GameMaster.clubs.Count -eq 0 ) {
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.other."3_f".image
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".card = ""
                    } else {
                        $tempCard = "$( $GameMaster.clubs[( $GameMaster.clubs.Count - 1 )] )"
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.cards.$tempCard.image
                        $GameMaster.cells.foundation."$( $GameMaster.from.cell )".card = $tempCard
                    }
                }
            }
        }
        2 {
            if ( $GameMaster.cells.main."$( $GameMaster.from.cell )".label.Size -ne $GameMaster.size.normal ) {
                Move-CardsWith -GameMaster $GameMaster
            }

            $GameMaster.cells.main."$( $GameMaster.from.cell )".label.BackgroundImage = $GameMaster.other.blank.image
            if ( $GameMaster.from.row -gt 0 ) {
                $GameMaster.cells.main."$( $GameMaster.from.cell )".label.Size = $GameMaster.size.small
            } else {
                $GameMaster.cells.main."$( $GameMaster.from.cell )".label.Size = $GameMaster.size.normal
            }
            $Gamemaster.cells.main."$( $GameMaster.from.cell )".card = ""
            
            $tempCard = $GameMaster.cells.main."$( $GameMaster.from.column )_$( $GameMaster.from.row - 1 )".card
            if (( $GameMaster.from.row -gt 0 ) -and ( -not $GameMaster.cards.$tempCard.faceUp )) {
                Set-FlipCard -GameMaster $GameMaster -Card $tempCard
                $GameMaster.cells.main."$( $GameMaster.from.column )_$( $GameMaster.from.row - 1 )".label.BackgroundImage = $GameMaster.cards.$tempCard.image
            }
            if ( $GameMaster.from.row -gt 0 ) {
                $GameMaster.cells.main."$( $GameMaster.from.column )_$( $GameMaster.from.row - 1 )".label.Size = $GameMaster.size.normal
            }
        }
    }

    Reset-FromInfo -GameMaster $GameMaster
    Reset-ToInfo -GameMaster $GameMaster

    return
}

function Move-CardsWith {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.debug ) {
        Write-Host "Move-CardsWith"
    }

    $fromRow = $GameMaster.from.row
    $toRow = ( $GameMaster.to.row + 1 )
    if ( $GameMaster.cards."$( $GameMaster.from.card )".value -eq 13 ) {
        $toRow --
    }

    while ( $true ) {
        $fromRow++
        $toRow++

        $GameMaster.cells.main."$( $GameMaster.to.column )_$( $toRow )".label.BackgroundImage = $GameMaster.cells.main."$( $GameMaster.from.column )_$( $fromRow )".label.BackgroundImage
        $GameMaster.cells.main."$( $GameMaster.from.column )_$( $fromRow )".label.BackgroundImage = $GameMaster.other.blank.image
        $GameMaster.cells.main."$( $GameMaster.to.column )_$( $toRow )".label.Size = $GameMaster.cells.main."$( $GameMaster.from.column )_$( $fromRow )".label.Size
        $GameMaster.cells.main."$( $GameMaster.to.column )_$( $toRow )".card = $GameMaster.cells.main."$( $GameMaster.from.column )_$( $fromRow )".card
        $GameMaster.cells.main."$( $GameMaster.from.column )_$( $fromRow )".card = ""

        if ( $GameMaster.cells.main."$( $GameMaster.from.column )_$( $fromRow )".label.Size -eq $GameMaster.size.normal ) {
            $GameMaster.cells.main."$( $GameMaster.from.column )_$( $fromRow )".label.Size = $GameMaster.size.small
            break
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
        $name = "$( $property.Name )"
        $GameMaster.cards.$name.faceUp = $false
    }

    return
}

function Reset-Cells {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
    
    foreach ( $property in $GameMaster.cells.deck.PSObject.Properties ) {
        $name = "$( $property.Name )"
        $GameMaster.cells.deck.$name.label.BackgroundImage = $GameMaster.other.blank.image
    }

    foreach ( $property in $GameMaster.cells.foundation.PSObject.Properties ) {
        $name = "$( $property.Name )"
        $GameMaster.cells.foundation.$name.label.BackgroundImage = $GameMaster.other.blank.image
    }

    foreach ( $property in $GameMaster.cells.main.PSObject.Properties ) {
        $name = "$( $property.Name )"
        $GameMaster.cells.main.$name.label.Size = $GameMaster.size.small
        $GameMaster.cells.main.$name.label.BackgroundImage = $GameMaster.other.blank.image
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
                    $GameMaster.cells.main."$( $column )_$( $row )".label.BackgroundImage = $GameMaster.cards."$( $GameMaster.deck[0] )".image
                    $GameMaster.cells.main."$( $column )_$( $row )".label.Size = $GameMaster.size.normal
                    $GameMaster.cells.main."$( $column )_$( $row )".card = "$( $GameMaster.deck[0] )"
                } else {
                    $GameMaster.cells.main."$( $column )_$( $row )".label.BackgroundImage = $GameMaster.other.back.image
                    $GameMaster.cells.main."$( $column )_$( $row )".card = "$( $GameMaster.deck[0] )"
                }
                $GameMaster.deck.RemoveAt(0)
            }
        }
    }

    return
}

function Set-DeckCell {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell,
        [string]$Card
    )

    $GameMaster.cells.deck.$Cell.label.BackgroundImage = $GameMaster.cards.$Card.image

    return
}

function Set-FoundationCell {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell,
        [string]$Card
    )

    $GameMaster.cells.foundation.$Cell.label.BackgroundImage = $GameMaster.cards.$Card.image

    return
}

function Set-MainCell {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [string]$Cell,
        [string]$Card
    )

    $GameMaster.cells.main.$Cell.label.BackgroundImage = $GameMaster.cards.$Card.image

    return
}

function Confirm-Win {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    if ( $GameMaster.hearts -notcontains "0_13" ) { return $false }
    if ( $GameMaster.diamonds -notcontains "1_13" ) { return $false }
    if ( $GameMaster.spades -notcontains "2_13" ) { return $false }
    if ( $GameMaster.clubs -notcontains "3_13" ) { return $false }

    return $true
}

function Set-Win {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.start = $false
    Write-Host "You Won!"

    return
}

function Set-Foundation {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.cells.deck."0_0".label.BackgroundImage = $GameMaster.other.back.image

    $GameMaster.cells.foundation."0_0".label.BackgroundImage = $GameMaster.other."0_f".image
    $GameMaster.cells.foundation."1_0".label.BackgroundImage = $GameMaster.other."1_f".image
    $GameMaster.cells.foundation."2_0".label.BackgroundImage = $GameMaster.other."2_f".image
    $GameMaster.cells.foundation."3_0".label.BackgroundImage = $GameMaster.other."3_f".image

    return
}

function Save-GameState {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $deckData = ""
    if ( $GameMaster.deck.Count -gt 0 ) {
        foreach ( $card in $GameMaster.deck ) {
            $deckData += ","
            $deckData += $card
        }
        $deckData = $deckData.Substring( 1 )
    }

    $pileData = ""
    if ( $GameMaster.pile.Count -gt 0 ) {
        foreach ( $card in $GameMaster.pile ) {
            $pileData += ","
            $pileData += $card
        }
        $pileData = $pileData.Substring( 1 )
    }

    $cardData = ""
    foreach ( $property in $GameMaster.cards.PSObject.Properties ) {
        $result = "false"
        if ( $GameMaster.cards."$( $property.Name )".faceUp ) { $result = "true" }
        $cardData += ","
        $cardData += "$( $property.Name );"
        $cardData += "$( $result )"
    }
    $cardData = $cardData.Substring( 1 )

    $cellDeckData = ""
    foreach ( $property in $GameMaster.cells.deck.PSObject.Properties ) {
        $result = "false"
        if ( $GameMaster.cells.deck."$( $property.Name )".label.Size -eq $GameMaster.size.normal ) { $result = "true" }
        $cellDeckData += ","
        $cellDeckData += "$( $property.Name );"
        $cellDeckData += "$( $GameMaster.cells.deck."$( $property.Name )".card );"
        $cellDeckData += "$( $result )"
    }
    $cellDeckData = $cellDeckData.Substring( 1 )

    $cellFoundationData = ""
    foreach ( $property in $GameMaster.cells.foundation.PSObject.Properties ) {
        if ( $GameMaster.cells.foundation."$( $property.Name )".card.Length -gt 0 ) {
            $card = $GameMaster.cells.foundation."$( $property.Name )".card
        } else {
            $split = $property.Name.Split( '_' )
            $card = "$( $split[0] )_f"
        }
        $cellFoundationData += ","
        $cellFoundationData += "$( $property.Name );"
        $cellFoundationData += $card
    }
    $cellFoundationData = $cellFoundationData.Substring( 1 )

    $cellMainData = ""
    foreach ( $property in $GameMaster.cells.main.PSObject.Properties ) {
        $result = "false"
        if ( $GameMaster.cells.main."$( $property.Name )".label.Size -eq $GameMaster.size.normal ) { $result = "true" }
        $cellMainData += ","
        $cellMainData += "$( $property.Name );"
        $cellMainData += "$( $GameMaster.cells.main."$( $property.Name )".card );"
        $cellMainData += "$( $result )"
    }
    $cellMainData = $cellMainData.Substring( 1 )

    $saveData = $deckData + "~" + $pileData + "~" + $cardData + "~" + $cellDeckData + "~" + $cellFoundationData + "~" + $cellMainData

    $GameMaster.gameStates.Add( $saveData ) | Out-Null

    return
}

function Restore-GameState {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $saveData = $GameMaster.gameStates[( $GameMaster.gameStates.Count - 1 )]
    if ( $GameMaster.gameStates.Count -gt 1 ) {
        $GameMaster.gameStates.RemoveAt( $GameMaster.gameStates.Count - 1 )
    }

    $split = $saveData.Split( '~' )
    $deckData = $split[0]
    $pileData = $split[1]
    $cardData = $split[2]
    $cellDeckData = $split[3]
    $cellFoundationData = $split[4]
    $cellMainData = $split[5]

    $GameMaster.deck.Clear()
    if ( $deckData.Length -gt 0 ) {
        $splitDeckData = $deckData.Split( ',' )
        foreach ( $data in $splitDeckData ) {
            $GameMaster.deck.Add( $data ) | Out-Null
        }
    }

    $GameMaster.pile.Clear()
    if ( $pileData.Length -gt 0 ) {
        $splitPileData = $pileData.Split( ',' )
        foreach ( $data in $splitPileData ) {
            $GameMaster.pile.Add( $data ) | Out-Null
        }
    }

    $splitCardData = $cardData.Split( ',' )
    foreach ( $data in $splitCardData ) {
        $dataSplit = $data.Split( ';' )
        if ( $datasplit[1] -eq "true" ) {
            $GameMaster.cards."$( $dataSplit[0] )".faceUp = $true
        } else {
            $GameMaster.cards."$( $dataSplit[0] )".faceUp = $false
        }
    }

    $splitCellDeckData = $cellDeckData.Split( ',' )
    foreach ( $data in $splitCellDeckData ) {
        $dataSplit = $data.Split( ';' )
        $GameMaster.cells.deck."$( $dataSplit[0] )".card = $dataSplit[1]
        if ( $dataSplit[2] -eq "true" ) {
            $GameMaster.cells.deck."$( $dataSplit[0] )".label.Size = $GameMaster.size.normal
        } else {
            $GameMaster.cells.deck."$( $dataSplit[0] )".label.Size = $GameMaster.size.deckSmall
        }
        $GameMaster.cells.deck."$( $dataSplit[0] )".label.BackgroundImage = $GameMaster.cards."$( $dataSplit[1] )".image
    }
    if ( $GameMaster.deck.Count -gt 0 ) {
        $GameMaster.cells.deck."0_0".label.BackgroundImage = $GameMaster.other.back.image
    } else {
        $GameMaster.cells.deck."0_0".label.BackgroundImage = $GameMaster.other.blank.image
    }

    $splitCellFoundationData = $cellFoundationData.Split( ',' )
    foreach ( $data in $splitCellFoundationData ) {
        $dataSplit = $data.Split( ';' )
        $GameMaster.cells.foundation."$( $dataSplit[0] )".card = $dataSplit[1]
        if ( $dataSplit[1] -match "f" ) {
            $GameMaster.cells.foundation."$( $dataSplit[0] )".label.BackgroundImage = $GameMaster.other."$( $dataSplit[1] )".image
        } else {
            $GameMaster.cells.foundation."$( $dataSplit[0] )".label.BackgroundImage = $GameMaster.cards."$( $dataSplit[1] )".image
        }
    }

    $splitCellMainData = $cellMainData.Split( ',' )
    foreach ( $data in $splitCellMainData ) {
        $dataSplit = $data.Split( ';' )
        $GameMaster.cells.main."$( $dataSplit[0] )".card = $dataSplit[1]
        if ( $dataSplit[2] -eq "true" ) {
            $GameMaster.cells.main."$( $dataSplit[0] )".label.Size = $GameMaster.size.normal
        } else {
            $GameMaster.cells.main."$( $dataSplit[0] )".label.Size = $GameMaster.size.small
        }
        if ( $dataSplit[1].Length -gt 0 ) {
            if ( $GameMaster.cards."$( $dataSplit[1] )".faceUp ) {
                $GameMaster.cells.main."$( $dataSplit[0] )".label.BackgroundImage = $GameMaster.cards."$( $dataSplit[1] )".image
            } else {
                $GameMaster.cells.main."$( $dataSplit[0] )".label.BackgroundImage = $GameMaster.other.back.image
            }
        } else {
            $GameMaster.cells.main."$( $dataSplit[0] )".label.BackgroundImage = $GameMaster.other.blank.image
        }
        
    }

    return
}

function New-Undo {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    Restore-GameState -GameMaster $GameMaster

    return
}

function Set-DrawCount {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [switch]$One,
        [switch]$Three
    )

    if ( $One ) {
        $GameMaster.drawOne = $true
    } elseif ( $Three ) {
        $GameMaster.drawOne = $false
    } else {
        return
    }

    New-Game -GameMaster $GameMaster

    return
}

function New-Game {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )

    $GameMaster.deck.Clear()
    $GameMaster.pile.Clear()
    $GameMaster.gameStates.Clear()
    $GameMaster.start = $true

    Reset-Cards -GameMaster $GameMaster

    Reset-Cells -GameMaster $GameMaster

    Set-Foundation -GameMaster $GameMaster

    Set-ShuffleDeck -GameMaster $GameMaster

    Set-DealDeck -GameMaster $GameMaster

    Save-GameState -GameMaster $GameMaster

    return
}

$gameMaster = [PSCustomObject]@{
    debug = $false
    start = $false
    drawOne = $true
    form = [System.Windows.Forms.Form]::new()
    cards = [PSCustomObject]@{}
    other = [PSCustomObject]@{}
    cells = [PSCustomObject]@{
        deck = [PSCustomObject]@{}
        foundation = [PSCustomObject]@{}
        main = [PSCustomObject]@{}
    }
    grids = [PSCustomObject]@{
        deck = [PSCustomObject]@{}
        foundation = [PSCustomObject]@{}
        main = [PSCustomObject]@{}
    }
    deck = [System.Collections.ArrayList]::new()
    pile = [System.Collections.ArrayList]::new()
    hearts = [System.Collections.ArrayList]::new()
    diamonds = [System.Collections.ArrayList]::new()
    spades = [System.Collections.ArrayList]::new()
    clubs = [System.Collections.ArrayList]::new()
    gameStates = [System.Collections.ArrayList]::new()
    size = [PSCustomObject]@{
        normal = [System.Drawing.Size]::new( 98, 142 )
        small = [System.Drawing.Size]::new( 98, ( 142 / 6 ))
        deckSmall = [System.Drawing.Size]::new(( 98 / 3.6 ), 142 )
    }
    layout = [PSCustomObject]@{
        deckHorizontal = $true
        foundationHorizontal = $true
        deckColumns = 4
        deckRows = 1
        foundationColumns = 4
        foundationRows = 1
        mainColumns = 7
        mainRows = 20
    }
    fromCell = ""
    toCell = ""
    from = [PSCustomObject]@{ column = 0; row = 0; type = 0; cell = ""; card = "" }
    to = [PSCustomObject]@{ column = 0; row = 0; type = 0; cell = ""; card = "" }
}

##### Card Setup #####
$cardPath = ".\Cards"
$cards = Get-ChildItem -Path $cardPath -File
foreach ( $card in $cards ) {
    $name = $card.Name.Replace( '.png', '' )
    $split = $name.Split( "_" )

    try {
        $gameMaster.cards | Add-Member -MemberType NoteProperty -Name "$( $name )" -Value $( [PSCustomObject]@{} ) -ErrorAction Stop
    } catch {
        $gameMaster.cards.PSObject.Properties.remove( "$( $name )" )
        $gameMaster.cards | Add-Member -MemberType NoteProperty -Name "$( $name )" -Value $( [PSCustomObject]@{} )
    }
    $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "image" -Value $( [System.Drawing.Image]::FromFile( ".\Cards\$( $card.Name )" ))
    if ( [int]$split[0] -gt 1 ) {
        $gamemaster.cards.$name | Add-Member -MemberType NoteProperty -Name "color" -Value "black"
    } else {
        $gamemaster.cards.$name | Add-Member -MemberType NoteProperty -Name "color" -Value "red"
    }
    $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "suit" -Value $( [int]$split[0] )
    $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "value" -Value $( [int]$split[1] )
    $gameMaster.cards.$name | Add-Member -MemberType NoteProperty -Name "faceUp" -Value $false
}
#####

##### Other Setup #####
$otherPath = ".\Cards\Other"
$others = Get-ChildItem -Path $otherPath
foreach ( $other in $others ) {
    $name = $other.Name.Replace( '.png', '' )
    $split = $name.Split( "_" )

    try {
        $gameMaster.other | Add-Member -MemberType NoteProperty -Name "$( $name )" -Value $( [PSCustomObject]@{} ) -ErrorAction Stop
    } catch {
        $gameMaster.other.PSObject.Properties.remove( "$( $name )" )
        $gameMaster.other | Add-Member -MemberType NoteProperty -Name "$( $name )" -Value $( [PSCustomObject]@{} )
    }
    $gameMaster.other.$name | Add-Member -MemberType NoteProperty -Name "image" -Value $( [System.Drawing.Image]::FromFile( ".\Cards\Other\$( $other.Name )" ))
}
#####

##### Form #####
$gameMaster.form.Text = "Solitaire"
$gameMaster.form.Add_Closed({ Clear-Images -GameMaster $gameMaster })
$gameMaster.form.Name = "AutoSize"
#####

##### Tool Strip #####
$toolStrip = [System.Windows.Forms.ToolStrip]::new()
$toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
$toolStrip.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden
$gameMaster.form.Controls.Add( $toolStrip ) | Out-Null

$dropDownButtonNewGame = [System.Windows.Forms.ToolStripDropDownButton]::new()
$dropDownButtonNewGame.Text = "New Game"
$dropDownButtonNewGame.ShowDropDownArrow = $true
$dropDownButtonNewGame.Padding = [System.Windows.Forms.Padding]::new(5,0,0,0)

$dropDownItemsDrawCount = [System.Windows.Forms.ToolStripDropDown]::new()
$drawOne = [System.Windows.Forms.ToolStripButton]::new()
$drawOne.Text = "Draw One"
$drawOne.Name = "Draw One"
$drawOne.Add_Click({ Set-DrawCount -GameMaster $gameMaster -One })
$drawThree = [System.Windows.Forms.ToolStripButton]::new()
$drawThree.Text = "Draw Three"
$drawThree.Name = "Draw Three"
$drawThree.Add_Click({ Set-DrawCount -GameMaster $gameMaster -Three })
$dropDownItemsDrawCount.Items.Add( $drawOne ) | Out-Null
$dropDownItemsDrawCount.Items.Add( $drawThree ) | Out-Null

$dropDownButtonNewGame.DropDown = $dropDownItemsDrawCount
$toolStrip.Items.Add($dropDownButtonNewGame) | Out-Null

$undoButton = [System.Windows.Forms.ToolStripButton]::new()
$undoButton.Text = "Undo"
$undoButton.Padding = [System.Windows.Forms.Padding]::new( 0, 0, 5, 0 )
$undoButton.Add_Click({ New-Undo -GameMaster $gameMaster })
$toolStrip.Items.Add( $undoButton ) | Out-Null
#####

##### Main Panel #####
$mainPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$mainPanel.Padding = [System.Windows.Forms.Padding]::new( 5, $toolStrip.Height, 5, 5 )
$mainPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$mainPanel.Name = "AutoSize"
$gameMaster.form.Controls.Add( $mainPanel ) | Out-Null
#####

##### Deck Grid/Cells #####
$deckGridO = [System.Windows.Forms.TableLayoutPanel]::new()
$deckGridO.Dock = [System.Windows.Forms.DockStyle]::Fill
$deckGridO.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
$deckGridO.Name = "AutoSize"
$deckGridM = [System.Windows.Forms.FlowLayoutPanel]::new()
if ( $gameMaster.layout.deckHorizontal ) {
    $deckGridM.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
} else {
    $deckGridM.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
}
$deckGridM.Name = "AutoSize"
$mainPanel.Controls.Add( $deckGridO ) | Out-Null
$deckGridO.Controls.Add( $deckGridM ) | Out-Null

foreach( $column in 0..( $gameMaster.layout.deckColumns - 1 )) {
    $row = 0
    try {
        $gameMaster.cells.deck | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [PSCustomObject]@{}) -ErrorAction Stop
    } catch {
        $gameMaster.cells.deck.PSObject.Properties.Remove( "$( $column )_$( $row )" )
        $gameMaster.cells.deck | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [PSCustomObject]@{})
    }

    try {
        $gameMaster.grids.deck | Add-Member -MemberType NoteProperty -Name $column -Value $( [System.Windows.Forms.TableLayoutPanel]::new()) -ErrorAction Stop
    } catch {
        $gameMaster.grids.deck.PSObject.Properties.Remove( $column )
        $gameMaster.grids.deck | Add-Member -MemberType NoteProperty -Name $column -Value $( [System.Windows.Forms.TableLayoutPanel]::new())
    }
    
    $gameMaster.cells.deck."$( $column )_$( $row )" | Add-Member -MemberType NoteProperty -Name "card" -Value ""
    $gameMaster.cells.deck."$( $column )_$( $row )" | Add-Member -MemberType NoteProperty -Name "label" -Value $( [System.Windows.Forms.Label]::new())

    ###### Label Setup #####
    $gameMaster.cells.deck."$( $column )_$( $row )".label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $gameMaster.cells.deck."$( $column )_$( $row )".label.Font = [System.Drawing.Font]::new( "Verdana", 14 )
    if (( $column -eq 1 ) -or ( $column -eq 2 )) {
        $gameMaster.cells.deck."$( $column )_$( $row )".label.Size = $gameMaster.size.deckSmall
    } else {
        $gameMaster.cells.deck."$( $column )_$( $row )".label.Size = $gameMaster.size.normal
    }
    $gameMaster.cells.deck."$( $column )_$( $row )".label.Padding = [System.Windows.Forms.Padding]::new( 0 )
    $gameMaster.cells.deck."$( $column )_$( $row )".label.Margin = [System.Windows.Forms.Padding]::new( 0 )
    $gameMaster.cells.deck."$( $column )_$( $row )".label.Dock = [System.Windows.Forms.DockStyle]::Fill
    $gameMaster.cells.deck."$( $column )_$( $row )".label.Name = "$( $column )_$( $row )_0"
    $gameMaster.cells.deck."$( $column )_$( $row )".label.Text = ""
    $gameMaster.cells.deck."$( $column )_$( $row )".label.BackgroundImage = $gameMaster.other.blank.image
    $gameMaster.cells.deck."$( $column )_$( $row )".label.AllowDrop = $true
    $gameMaster.cells.deck."$( $column )_$( $row )".label.Add_MouseClick({ 
        param($sender, $event)
        if ( $event.button -eq "Left" ) {
            New-MouseClick -GameMaster $gameMaster -Cell $this.Name -Left
        } elseif ( $event.button -eq "Right" ) {
            New-MouseClick -GameMaster $gameMaster -Cell $this.Name -Right
        }
    })
    $gameMaster.cells.deck."$( $column )_$( $row )".label.Add_MouseDown({ 
        param($sender, $event)
        if ( $event.button -eq "Left" ) {
            New-MouseDown -GameMaster $gameMaster -Cell $this.Name -Left
        } elseif ( $event.button -eq "Right" ) {
            New-MouseDown -GameMaster $gameMaster -Cell $this.Name -Right
        }
    })
    $gameMaster.cells.deck."$( $column )_$( $row )".label.Add_DragEnter({ 
        param($sender, $event)
        $event.Effect = [System.Windows.Forms.DragDropEffects]::Link
    })
    $gameMaster.cells.deck."$( $column )_$( $row )".label.Add_DragDrop({ New-DragDrop -GameMaster $gameMaster -Cell $this.Name })

    $gameMaster.grids.deck.$column.RowCount = 1
    $gameMaster.grids.deck.$column.ColumnCount = 1
    $gameMaster.grids.deck.$column.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
    $gameMaster.grids.deck.$column.Name = "AutoSize"

    $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
    $gameMaster.grids.deck.$column.SetCellPosition( $gameMaster.cells.deck."$( $column )_$( $row )".label, $cellPosition )
    $gameMaster.grids.deck.$column.Controls.Add( $gameMaster.cells.deck."$( $column )_$( $row )".label )
    $deckGridM.Controls.Add( $gameMaster.grids.deck.$column ) | Out-Null
    #####
}
#####

##### Foundation Grid/Cells #####
$foundationGridO = [System.Windows.Forms.TableLayoutPanel]::new()
$foundationGridO.Dock = [System.Windows.Forms.DockStyle]::Fill
$foundationGridO.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
$foundationGridO.Name = "AutoSize"
$foundationGridM = [System.Windows.Forms.FlowLayoutPanel]::new()
if ( $gameMaster.layout.foundationHorizontal ) {
    $foundationGridM.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
} else {
    $foundationGridM.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
}
$foundationGridM.Name = "AutoSize"
$mainPanel.Controls.Add( $foundationGridO ) | Out-Null
$foundationGridO.Controls.Add( $foundationGridM ) | Out-Null
$mainPanel.SetFlowBreak( $foundationGridO, $true)

foreach( $column in 0..( $gameMaster.layout.foundationColumns - 1 )) {
    $row = 0
    try {
        $gameMaster.cells.foundation | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [PSCustomObject]@{}) -ErrorAction Stop
    } catch {
        $gameMaster.cells.foundation.PSObject.Properties.Remove( "$( $column )_$( $row )" )
        $gameMaster.cells.foundation | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [PSCustomObject]@{})
    }

    try {
        $gameMaster.grids.foundation | Add-Member -MemberType NoteProperty -Name $column -Value $( [System.Windows.Forms.TableLayoutPanel]::new()) -ErrorAction Stop
    } catch {
        $gameMaster.grids.foundation.PSObject.Properties.Remove( $column )
        $gameMaster.grids.foundation | Add-Member -MemberType NoteProperty -Name $column -Value $( [System.Windows.Forms.TableLayoutPanel]::new())
    }
    
    $gameMaster.cells.foundation."$( $column )_$( $row )" | Add-Member -MemberType NoteProperty -Name "card" -Value ""
    $gameMaster.cells.foundation."$( $column )_$( $row )" | Add-Member -MemberType NoteProperty -Name "label" -Value $( [System.Windows.Forms.Label]::new())

    ###### Label Setup #####
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Font = [System.Drawing.Font]::new( "Verdana", 14 )
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Size = $gameMaster.size.normal
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Padding = [System.Windows.Forms.Padding]::new( 0 )
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Margin = [System.Windows.Forms.Padding]::new( 0 )
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Dock = [System.Windows.Forms.DockStyle]::Fill
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Name = "$( $column )_$( $row )_1"
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Text = ""
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.BackgroundImage = $gameMaster.other.blank.image
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.AllowDrop = $true
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Add_MouseClick({ 
        param($sender, $event)
        if ( $event.button -eq "Left" ) {
            New-MouseClick -GameMaster $gameMaster -Cell $this.Name -Left
        } elseif ( $event.button -eq "Right" ) {
            New-MouseClick -GameMaster $gameMaster -Cell $this.Name -Right
        }
    })
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Add_MouseDown({ 
        param($sender, $event)
        if ( $event.button -eq "Left" ) {
            New-MouseDown -GameMaster $gameMaster -Cell $this.Name -Left
        } elseif ( $event.button -eq "Right" ) {
            New-MouseDown -GameMaster $gameMaster -Cell $this.Name -Right
        }
    })
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Add_DragEnter({ 
        param($sender, $event)
        $event.Effect = [System.Windows.Forms.DragDropEffects]::Link
    })
    $gameMaster.cells.foundation."$( $column )_$( $row )".label.Add_DragDrop({ New-DragDrop -GameMaster $gameMaster -Cell $this.Name })

    $gameMaster.grids.foundation.$column.RowCount = 1
    $gameMaster.grids.foundation.$column.ColumnCount = 1
    $gameMaster.grids.foundation.$column.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
    $gameMaster.grids.foundation.$column.Name = "AutoSize"

    $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
    $gameMaster.grids.foundation.$column.SetCellPosition( $gameMaster.cells.foundation."$( $column )_$( $row )".label, $cellPosition )
    $gameMaster.grids.foundation.$column.Controls.Add( $gameMaster.cells.foundation."$( $column )_$( $row )".label )
    $foundationGridM.Controls.Add( $gameMaster.grids.foundation.$column ) | Out-Null
    #####
}
#####

##### Main Grid/Cells #####
$mainGridO = [System.Windows.Forms.TableLayoutPanel]::new()
$mainGridO.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainGridO.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
$mainGridO.Name = "AutoSize"
$mainGridM = [System.Windows.Forms.FlowLayoutPanel]::new()
$mainGridM.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$mainGridM.Name = "AutoSize"
$mainPanel.Controls.Add( $mainGridO ) | Out-Null
$mainGridO.Controls.Add( $mainGridM ) | Out-Null


foreach( $column in 0..( $gameMaster.layout.mainColumns - 1 )) {

    try {
        $gameMaster.grids.main | Add-Member -MemberType NoteProperty -Name $column -Value $( [System.Windows.Forms.TableLayoutPanel]::new()) -ErrorAction Stop
    } catch {
        $gameMaster.grids.main.PSObject.Properties.Remove( $column )
        $gameMaster.grids.main | Add-Member -MemberType NoteProperty -Name $column -Value $( [System.Windows.Forms.TableLayoutPanel]::new())
    }

    $gameMaster.grids.main.$column.RowCount = $gameMaster.layout.mainRows
    $gameMaster.grids.main.$column.ColumnCount = 1
    $gameMaster.grids.main.$column.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
    $gameMaster.grids.main.$column.Name = "AutoSize"

    $mainGridM.Controls.Add( $gameMaster.grids.main.$column ) | Out-Null

    foreach( $row in 0..( $gameMaster.layout.mainRows - 1 )) {
        try {
            $gameMaster.cells.main | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [PSCustomObject]@{}) -ErrorAction Stop
        } catch {
            $gameMaster.cells.main.PSObject.Properties.Remove( "$( $column )_$( $row )" )
            $gameMaster.cells.main | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $( [PSCustomObject]@{})
        }

        $gameMaster.cells.main."$( $column )_$( $row )" | Add-Member -MemberType NoteProperty -Name "card" -Value ""
        $gameMaster.cells.main."$( $column )_$( $row )" | Add-Member -MemberType NoteProperty -Name "label" -Value $( [System.Windows.Forms.Label]::new())
        $gameMaster.cells.main."$( $column )_$( $row )" | Add-Member -MemberType NoteProperty -Name "column" -Value $column
        $gameMaster.cells.main."$( $column )_$( $row )" | Add-Member -MemberType NoteProperty -Name "row" -Value $row

        ###### Label Setup #####
        $gameMaster.cells.main."$( $column )_$( $row )".label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $gameMaster.cells.main."$( $column )_$( $row )".label.Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $gameMaster.cells.main."$( $column )_$( $row )".label.Size = $gameMaster.size.small
        $gameMaster.cells.main."$( $column )_$( $row )".label.Padding = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.cells.main."$( $column )_$( $row )".label.Margin = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.cells.main."$( $column )_$( $row )".label.Dock = [System.Windows.Forms.DockStyle]::Fill
        $gameMaster.cells.main."$( $column )_$( $row )".label.Name = "$( $column )_$( $row )_2"
        $gameMaster.cells.main."$( $column )_$( $row )".label.Text = ""
        $gameMaster.cells.main."$( $column )_$( $row )".label.BackgroundImage = $gameMaster.other.blank.image
        $gameMaster.cells.main."$( $column )_$( $row )".label.AllowDrop = $true
        $gameMaster.cells.main."$( $column )_$( $row )".label.Add_MouseClick({ 
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseClick -GameMaster $gameMaster -Cell $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseClick -GameMaster $gameMaster -Cell $this.Name -Right
            }
        })
        $gameMaster.cells.main."$( $column )_$( $row )".label.Add_MouseDown({ 
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseDown -GameMaster $gameMaster -Cell $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseDown -GameMaster $gameMaster -Cell $this.Name -Right
            }
        })
        $gameMaster.cells.main."$( $column )_$( $row )".label.Add_DragEnter({ 
            param($sender, $event)
            $event.Effect = [System.Windows.Forms.DragDropEffects]::Link
        })
        $gameMaster.cells.main."$( $column )_$( $row )".label.Add_DragDrop({ New-DragDrop -GameMaster $gameMaster -Cell $this.Name })

        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $gameMaster.grids.main.$column.SetCellPosition( $gameMaster.cells.main."$( $column )_$( $row )".label, $cellPosition )
        $gameMaster.grids.main.$column.Controls.Add( $gameMaster.cells.main."$( $column )_$( $row )".label )

        #####
    }
}
#####

Set-AutoSize -Control $gameMaster.form

$gameMaster.form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$gameMaster.form.ShowDialog() | Out-Null
