Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Set-AutoSize {
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

function Clear-Images {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Clear-Images"
    }

    foreach ( $property in $Data.cards.PSObject.Properties ) {
        $Data.cards."$( $property.Name )".image.Dispose()
    }

    return
}

function Set-KeyDown {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [PSCustomObject]$Data,
        $Control
    )

    if ( $Data.debug ) {
        Write-Host "Set-KeyDown"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    # Player 1 = Key 1
    # Player 2 = Key 2
    # Player 3 = Key 3
    # Player 4 = Key 4
    # Cancel = Key 5

    $Control.Add_KeyDown({
        if ( $_.KeyCode -eq "Space" ) {
            New-KeyDown -Data $Data -Key 1
        } elseif ( $_.KeyCode -eq "Return" ) {
            New-KeyDown -Data $Data -Key 2
        } elseif ( $_.KeyCode -eq "Down" ) {
            New-KeyDown -Data $Data -Key 3
        } elseif ( $_.KeyCode -eq "Tab" ) {
            New-KeyDown -Data $Data -Key 4
        } elseif ( $_.KeyCode -eq "Escape" ) {
            New-KeyDown -Data $Data -Key 5
        } elseif ( $_.KeyCode -eq "D" ) {
            if ( $_.Shift ) {
                $Data.debug = ( -not $Data.debug )
                if ( -not $Data.debug ) {
                    $Data.selfCheck = $false
                    $Data.seedCheck = $false
                    $Data.testSeed = $false
                    $Data.toolStrip.Items.Remove( $data.dropDownDebug ) | Out-Null
                } else {
                    $Data.toolStrip.Items.Add( $data.dropDownDebug ) | Out-Null
                    $Data.emptyLabel3.Text = "          *DEBUG*            "
                }
            }
        }
    })

    return
}

function New-KeyDown {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$Data,
        [int]$Key
    )

    if ( $Data.debug ) {
        Write-Host "New-KeyDown | Key: $( $Key )"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    if ( -not $Data.start ) {
        return
    }

    if (( $Data.playerTurn -gt 0 ) -and ( $Key -ne 5 )) {
        return
    }

    if ( $Data.playerCount -gt 1 ) {
        Switch ( $Key ) {
            1 { Start-PlayerTurn -Data $Data -Player 1 }
            2 { Start-PlayerTurn -Data $Data -Player 2 }
            3 { if ( $Data.playerCount -gt 2 ) { Start-PlayerTurn -Data $Data -Player 3 }}
            4 { if ( $Data.playerCount -gt 3 ) { Start-PlayerTurn -Data $Data -Player 4 }}
            5 { Start-PlayerTurn -Data $Data -Player 0 }
        }
    }

    return
}

function New-MouseClick {
    param(
        [PSCustomObject]$Data,
        [string]$Cell,
        [switch]$Left,
        [switch]$Right
    )

    if ( $Data.debug ) {
        Write-Host "New-MouseDown | Cell: $( $Cell ) | Left: $( $Left ) | Right: $( $Right )"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    if ( -not $Data.start ) {
        return
    }

    if ( $Data.playerCount -gt 1 ) {
        if ( $Data.playerTurn -eq 0 ) {
            return
        }
    }

    if ( $Left ) {
        $split = $Cell.Split( '_' )
        $column = $split[0]
        $row = $split[1]
        
        $card = Find-SetCard -Data $Data -Cell $Cell
        if ( -not $card ) {
            if ( $Data.debug ) {
                Write-Warning "No Card Found"
            }
            return
        }

        $Data.label1.Text = ""
        $Data.label2.Text = ""

        if ( $Data.selectedCards.Contains( $card )) {
            $Data.selectedCards.Remove( $card ) | Out-Null
            $Data.grid."$( $Cell )".label.BackColor = $Data.colors.background
        } else {
            if ( $Data.selectedCards.Count -lt 3 ) {
                $Data.selectedCards.Add( $card ) | Out-Null
                $Data.grid."$( $Cell )".label.BackColor = $Data.colors.selected
            }
        }

        if ( $Data.selectedCards.Count -eq 3 ) {
            Submit-Guess -Data $Data
        }
    } elseif ( $Right ) {
        if ( $Data.selectedCards.Count -gt 2 ) {
            $cell3 = $Data.cards."$( $Data.selectedCards[2] )".cell
            $Data.grid."$( $cell3 )".label.BackColor = $Data.colors.background
        } 

        if ( $Data.selectedCards.Count -gt 1 ) {
            $cell2 = $Data.cards."$( $Data.selectedCards[1] )".cell
            $Data.grid."$( $cell2 )".label.BackColor = $Data.colors.background
        }

        if ( $Data.selectedCards.Count -gt 0 ) {
            $cell1 = $Data.cards."$( $Data.selectedCards[0] )".cell
            $Data.grid."$( $cell1 )".label.BackColor = $Data.colors.background
        }
        
        $Data.selectedCards.Clear()
    }

    return

}

function Find-SetCard {
    param(
        [PSCustomObject]$Data,
        [string]$Cell
    )

    if ( $Data.debug ) {
        Write-Host "Find-SetCard | Cell $( $Cell)"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    foreach ( $prop1 in $Data.cards.PSObject.Properties ) {
        if ( $Data.cards."$( $prop1.Name )".cell -eq $Cell ) {
            return "$( $prop1.Name )"
        }
    }

    return $null
}

function Start-Shuffle {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Start-Shuffle"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    foreach ( $prop1 in $Data.grid.PSObject.Properties ) {
        $Data.grid."$( $prop1.Name )".card = ""
    }

    $cardsRemaining = [System.Collections.ArrayList]::new()
    $count = 0
    foreach ( $prop1 in $Data.cards.PSObject.Properties ) {
        $cardsRemaining.Add( $prop1.Name ) | Out-Null
        $Data.cards."$( $prop1.Name )".cell = ""
        $count++
    }

    $cardsRemaining.Remove( "blank" ) | Out-Null
    $count--

    $Data.deck.Clear()
    $Data.sets.Clear()

    if ( $Data.testSeed ) {
        $Data.seed = 0
    }

    if ( $Data.seedCheck ) {
        Write-Host "seed: $( $Data.seed )"
    }

    foreach( $num in 0..( $count - 1 )) {
        $randCard = Get-Random -InputObject $cardsRemaining -SetSeed $Data.seed
        if ( $Data.seedCheck ) {
            Write-Host "randCard: $( $randCard )"
        }
        $Data.deck.Add( $randCard ) | Out-Null
        $cardsRemaining.Remove( $randCard ) | Out-Null
        Step-Seed -Data $Data
    }

    $Data.selectedCards.Clear()
    $Data.seed = ""

    return
}

function Step-Seed {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Step-Seed"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    $tempSeed = Get-Random -Minimum ( -999999 ) -Maximum ( 999999 ) -SetSeed $Data.seed

    if ( $Data.seedCheck ) {
        Write-Host "Current seed: $( $Data.seed ); New Seed: $( $tempSeed )"
    }

    $Data.seed = $tempSeed

    if ( $Data.testSeed ) {
        $Data.seed = 0
    }

    return
}

function New-Game {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Clear-Host
        Write-Host "New-Game"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    $Data.start = $true

    if ( $Data.seed.Length -eq 0 ) {
        $Data.seed = Get-Random -Minimum ( -999999 ) -Maximum ( 999999 ) -SetSeed ( [int]( [double](( Get-Date -UFormat '%s' ).Substring( 6 )) * 10000 ))
        $Data.seedText = "Random Seed:"
    } else {
        $Data.seedText = "Set Seed:"
    }
    if ( $Data.testSeed ) {
        $Data.seedLabel.Text = "Test Seed: 0"
    } else {
        $Data.seedLabel.Text = "$( $Data.seedText ) $( $Data.seed )"
    }
    

    foreach ( $row in 0..6 ) {
        foreach ( $col in 0..2 ) {
            $Data.grid."$( $col )_$( $row )".label.BackgroundImage = $Data.cards.blank.image
            $Data.grid."$( $col )_$( $row )".label.BackColor = $Data.colors.background
            $Data.grid."$( $col )_$( $row )".card = ""
        }
    }

    Start-Shuffle -Data $Data

    foreach ( $row in 0..3 ) {
        foreach ( $col in 0..2 ) {
            $Data.grid."$( $col )_$( $row )".label.BackgroundImage = $Data.cards."$( $Data.deck[0] )".image
            $Data.grid."$( $col )_$( $row )".label.BackColor = $Data.colors.background
            $Data.grid."$( $col )_$( $row )".card = "$( $Data.deck[0] )"
            $Data.cards."$( $Data.deck[0] )".cell = "$( $col )_$( $row )"
            $Data.deck.Remove( $Data.deck[0] )
        }
    }

    $Data.deckCountLabel.Text = "$( $Data.deckCountText ) 0"
    $Data.setCountLabel.Text = "$( $Data.setCountText ) 0"
    $Data.hintsUsedLabel.Text = "$( $Data.hintsUsedText ) 0"
    $Data.label1.Text = ""
    $Data.label2.Text = ""

    if ( $Data.autoDraw ) {
        Find-PossibleSets -Data $Data
    }

    $Data.timeStart = Get-Date -UFormat '%s'
    $Data.timeStartLabel.Text = "$( $Data.timeStartText ) $( ([DateTime]( '1970-01-01 00:00:00' )).AddSeconds( $Data.timeStart ).ToString( 'hh:mm:ss' ))"
    $Data.timeEnd = 0
    $Data.timeEndLabel.Text = "$( $Data.timeEndText ) "
    $Data.timeTotal = 0
    $Data.timeTotalLabel.Text = "$( $Data.timeTotalText ) "

    $Data.turnTimer.Enabled = $false
    $Data.player1Score = 0
    $Data.player2Score = 0
    $Data.player3Score = 0
    $Data.player4Score = 0
    Update-PlayerScores -Data $Data

    return
}

function Submit-Guess {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Submit-Guess"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    if ( $Data.selectedCards.Count -ne 3 ) {
        return
    }

    $Data.hintShown = $false

    $card1 = $Data.selectedCards[0]
    $card2 = $Data.selectedCards[1]
    $card3 = $Data.selectedCards[2]

    if ( $Data.debug ) {
        Write-Host "Card1: $( $card1 ) | Card2: $( $card2 ) | Card3: $( $card3 )"
    }

    $counts = [int]($card1[0]).ToString() + [int]($card2[0]).ToString() + [int]($card3[0]).ToString()
    $fillings = [int]($card1[1]).ToString() + [int]($card2[1]).ToString() + [int]($card3[1]).ToString()
    $colors = [int]($card1[2]).ToString() + [int]($card2[2]).ToString() + [int]($card3[2]).ToString()
    $shapes = [int]($card1[3]).ToString() + [int]($card2[3]).ToString() + [int]($card3[3]).ToString()

    if ( $Data.debug ) {
        Write-Host "Card1[0]: $( [int]($card1[0]).ToString() ) | Card2[0]: $( [int]"$($card2[0])" ) | Card3[0]: $( [int]($card3[0]) )"
    }

    if ( $Data.debug ) {
        Write-Host "counts: $( $counts ) | fillings: $( $fillings ) | colors: $( $colors ) | shapes: $( $shapes )"
    }

    if ( $counts % 3 -ne 0 ) {
        Deny-Guess -Data $Data
    } elseif ( $fillings % 3 -ne 0 ) {
        Deny-Guess -Data $Data
    } elseif ( $colors % 3 -ne 0 ) {
        Deny-Guess -Data $Data
    } elseif ( $shapes % 3 -ne 0 ) {
        Deny-Guess -Data $Data
    } else {
        Approve-Guess -Data $Data
    }

    return
}

function Deny-Guess {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Deny-Guess"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    $cell1 = $Data.cards."$( $Data.selectedCards[0] )".cell
    $cell2 = $Data.cards."$( $Data.selectedCards[1] )".cell
    $cell3 = $Data.cards."$( $Data.selectedCards[2] )".cell

    $Data.grid."$( $cell1 )".label.BackColor = $Data.colors.background
    $Data.grid."$( $cell2 )".label.BackColor = $Data.colors.background
    $Data.grid."$( $cell3 )".label.BackColor = $Data.colors.background

    $Data.selectedCards.Clear()

    $Data.label1.Text = "Invalid set"
    $Data.label2.Text = ""

    if ( $Data.playerCount -gt 1 ) {
        Start-PlayerTurn -Data $Data -Player 0
    }

    return
}

function Approve-Guess {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Approve-Guess"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    $count = 0
    foreach ( $prop1 in $Data.grid.PSObject.Properties ) {
        if ( $Data.grid."$( $prop1.Name )".card.Length -gt 0 ) {
            $count++
        }
    }

    $cell1 = $Data.cards."$( $Data.selectedCards[0] )".cell
    $cell2 = $Data.cards."$( $Data.selectedCards[1] )".cell
    $cell3 = $Data.cards."$( $Data.selectedCards[2] )".cell

    $Data.cards."$( $Data.selectedCards[0] )".cell = ""
    $Data.cards."$( $Data.selectedCards[1] )".cell = ""
    $Data.cards."$( $Data.selectedCards[2] )".cell = ""

    $tempSets = [System.Collections.ArrayList]::new()
    foreach ( $set in $Data.sets ) {
        $tempSets.Add( $set ) | Out-Null
    }

    foreach ( $set in $tempSets ) {
        if ( $set -match $Data.grid."$( $cell1 )".card ) {
            $Data.sets.Remove( $set )
        } elseif ( $set -match $Data.grid."$( $cell2 )".card ) {
            $Data.sets.Remove( $set )
        } elseif ( $set -match $Data.grid."$( $cell3 )".card ) {
            $Data.sets.Remove( $set )
        }
    }

    $tempSets.Clear()

    $Data.grid."$( $cell1 )".card = ""
    $Data.grid."$( $cell2 )".card = ""
    $Data.grid."$( $cell3 )".card = ""

    $Data.grid."$( $cell1 )".label.BackColor = $Data.colors.background
    $Data.grid."$( $cell2 )".label.BackColor = $Data.colors.background
    $Data.grid."$( $cell3 )".label.BackColor = $Data.colors.background

    $Data.selectedCards.Clear()

    if (( $count -gt 12 ) -or ( $Data.deck.Count -eq 0 )) {
        $Data.grid."$( $cell1 )".label.BackgroundImage = $Data.cards.blank.image
        $Data.grid."$( $cell2 )".label.BackgroundImage = $Data.cards.blank.image
        $Data.grid."$( $cell3 )".label.BackgroundImage = $Data.cards.blank.image

        if ( $Data.playerCount -gt 1 ) {
            switch ( $Data.playerTurn ) {
                1 { $Data.player1Score++ }
                2 { $Data.player2Score++ }
                3 { $Data.player3Score++ }
                4 { $Data.player4Score++ }
            }

            Update-PlayerScores -Data $Data

            Start-PlayerTurn -Data $Data -Player 0
        }

        Group-Remaining -Data $Data

        if ( $Data.autoDraw ) {
            Find-PossibleSets -Data $Data
        }

        return 
    }

    $Data.grid."$( $cell1 )".label.BackgroundImage = $Data.cards."$( $Data.deck[0] )".image
    $Data.grid."$( $cell2 )".label.BackgroundImage = $Data.cards."$( $Data.deck[1] )".image
    $Data.grid."$( $cell3 )".label.BackgroundImage = $Data.cards."$( $Data.deck[2] )".image

    $Data.cards."$( $Data.deck[0] )".cell = "$( $cell1 )"
    $Data.cards."$( $Data.deck[1] )".cell = "$( $cell2 )"
    $Data.cards."$( $Data.deck[2] )".cell = "$( $cell3 )"

    $Data.grid."$( $cell1 )".card = "$( $Data.deck[0] )"
    $Data.grid."$( $cell2 )".card = "$( $Data.deck[1] )"
    $Data.grid."$( $cell3 )".card = "$( $Data.deck[2] )"

    $Data.deck.Remove( $Data.deck[2] )
    $Data.deck.Remove( $Data.deck[1] )
    $Data.deck.Remove( $Data.deck[0] )

    if ( $Data.playerCount -gt 1 ) {
        switch ( $Data.playerTurn ) {
            1 { $Data.player1Score++ }
            2 { $Data.player2Score++ }
            3 { $Data.player3Score++ }
            4 { $Data.player4Score++ }
        }

        Update-PlayerScores -Data $Data

        Start-PlayerTurn -Data $Data -Player 0
    }

    if ( $Data.autoDraw ) {
        Find-PossibleSets -Data $Data
    }

    return
}

function Group-Remaining {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Group-Remaining"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    $remaining = [System.Collections.ArrayList]::new()

    foreach ( $prop1 in $Data.grid.PSObject.Properties ) {
        if ( $Data.grid."$( $prop1.Name )".card.Length -gt 0 ) {
            $remaining.Add( $Data.grid."$( $prop1.Name )".card ) | Out-Null
            if ( $Data.debug ) {
                Write-Host "Remaining Card Added: $( $Data.grid."$( $prop1.Name )".card )"
            }
            $Data.cards."$( $Data.grid."$( $prop1.Name )".card )".cell = ""
            $Data.grid."$( $prop1.Name )".label.BackgroundImage = $Data.cards.blank.image
            $Data.grid."$( $prop1.Name )".label.BackColor = $Data.colors.background
            $Data.grid."$( $prop1.Name )".card = ""
        }
    }

    if ( $remaining.Count -eq 0 ) {
        return
    }

    $rowCount = ( $remaining.Count / 3 )
    if ( $Data.debug ) {
        Write-Host "RowCount: $rowCount"
    }

    foreach ( $row in 0..( $rowCount - 1 )) {
        foreach ( $col in 0..2 ) {
            $Data.grid."$( $col )_$( $row )".label.BackgroundImage = $Data.cards."$( $remaining[ 0 ] )".image
            $Data.grid."$( $col )_$( $row )".label.BackColor = $Data.colors.background
            $Data.grid."$( $col )_$( $row )".card = "$( $remaining[ 0 ] )"
            $Data.cards."$( $remaining[ 0 ] )".cell = "$( $col )_$( $row )"
            $remaining.Remove( $remaining[ 0 ] )
        }
    }

    return
}

function Find-PossibleSets {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Find-PossibleSets"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    $setFound = $false

    $cardList = [System.Collections.ArrayList]::new()
    foreach ( $prop1 in $Data.cards.PSObject.Properties ) {
        if ( $Data.cards."$( $prop1.Name )".cell.Length -gt 0 ) {
            $cardList.Add( $prop1.Name ) | Out-Null
        }
    }

    if ( $cardList.Count -gt 0 ) {
        $counts = [System.Collections.ArrayList]::new()
        $fillings = [System.Collections.ArrayList]::new()
        $colors = [System.Collections.ArrayList]::new()
        $shapes = [System.Collections.ArrayList]::new()
        foreach ( $num1 in 0..( $cardList.Count - 3 )) {
            foreach ( $num2 in ( $num1 + 1 )..( $cardList.Count - 2 )) {
                foreach ( $num3 in ( $num2 + 1 )..( $cardList.Count - 1 )) {
                    $card1 = "$( $cardList[$num1] )"
                    $card2 = "$( $cardList[$num2] )"
                    $card3 = "$( $cardList[$num3] )"

                    if ( $Data.sets -contains "$( $card1 ),$( $card2 ),$( $card3 )" ) {
                        if (( -not $setFound ) -and ( $Data.debug )) {
                            $Data.grid."$( $Data.cards."$( $card1 )".cell )".label.BackColor = $Data.colors.hint
                            $Data.grid."$( $Data.cards."$( $card2 )".cell )".label.BackColor = $Data.colors.hint
                            $Data.grid."$( $Data.cards."$( $card3 )".cell )".label.BackColor = $Data.colors.hint
                        }

                        $setFound = $true
                        continue
                    }

                    $counts = [int]($card1[0]).ToString() + [int]($card2[0]).ToString() + [int]($card3[0]).ToString()
                    $fillings = [int]($card1[1]).ToString() + [int]($card2[1]).ToString() + [int]($card3[1]).ToString()
                    $colors = [int]($card1[2]).ToString() + [int]($card2[2]).ToString() + [int]($card3[2]).ToString()
                    $shapes = [int]($card1[3]).ToString() + [int]($card2[3]).ToString() + [int]($card3[3]).ToString()

                    if (( $counts % 3 ) -ne 0 ) {
                        continue
                    } elseif (( $fillings % 3 ) -ne 0 ) {
                        continue
                    } elseif (( $colors % 3 ) -ne 0 ) {
                        continue
                    } elseif (( $shapes % 3 ) -ne 0 ) {
                        continue
                    } else {
                        if (( -not $setFound ) -and ( $Data.debug )) {
                            $Data.grid."$( $Data.cards."$( $card1 )".cell )".label.BackColor = $Data.colors.hint
                            $Data.grid."$( $Data.cards."$( $card2 )".cell )".label.BackColor = $Data.colors.hint
                            $Data.grid."$( $Data.cards."$( $card3 )".cell )".label.BackColor = $Data.colors.hint
                        }

                        $setFound = $true
                        $Data.sets.Add( "$( $card1 ),$( $card2 ),$( $card3 )" ) | Out-Null

                        if ( $Data.debug ) {
                            Write-Host "Set found"
                        }
                    }
                }
            }
        }
    }

    if ( -not $setFound ) {
        Add-Cards -Data $Data
    }

    $Data.setCountLabel.Text = "$( $Data.setCountText ) $( $Data.sets.Count )"
    $Data.deckCountLabel.Text = "$( $Data.deckCountText ) $( $Data.deck.Count )"

    return
}

function Add-Cards {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Add-Cards"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    if ( $Data.deck.Count -eq 0 ) {
        $Data.label1.Text = "No sets found"
        $Data.label2.Text = "Deck is empty"
        $Data.timeEnd = Get-Date -UFormat '%s'
        $Data.timeEndLabel.Text = "$( $Data.timeEndText ) $( ([DateTime]( '1970-01-01 00:00:00' )).AddSeconds( $Data.timeEnd ).ToString( 'hh:mm:ss' ))"
        $Data.timeTotal = ( [int]$data.timeEnd - [int]$data.timeStart )
        $Data.timeTotalLabel.Text = "$( $Data.timeTotalText ) $( $Data.timeTotal )"
        Set-AutoSize -Control $Data.form

        $Data.start = $false

        return
    }

    $count = 0
    foreach ( $prop1 in $Data.grid.PSObject.Properties ) {
        if ( $Data.grid."$( $prop1.Name )".card.Length -gt 0 ) {
            $count++
        }
    }

    if ( $count -lt 12 ) {
        return
    }

    switch ( $count ) {
        12 {
            $cell1 = "0_4"
            $cell2 = "1_4"
            $cell3 = "2_4"
        }
        15 {
            $cell1 = "0_5"
            $cell2 = "1_5"
            $cell3 = "2_5"
        }
        18 {
            $cell1 = "0_6"
            $cell2 = "1_6"
            $cell3 = "2_6"
        }
    }

    $Data.grid."$( $cell1 )".label.BackgroundImage = $Data.cards."$( $Data.deck[0] )".image
    $Data.grid."$( $cell2 )".label.BackgroundImage = $Data.cards."$( $Data.deck[1] )".image
    $Data.grid."$( $cell3 )".label.BackgroundImage = $Data.cards."$( $Data.deck[2] )".image

    $Data.cards."$( $Data.deck[0] )".cell = "$( $cell1 )"
    $Data.cards."$( $Data.deck[1] )".cell = "$( $cell2 )"
    $Data.cards."$( $Data.deck[2] )".cell = "$( $cell3 )"

    $Data.grid."$( $cell1 )".card = "$( $Data.deck[0] )"
    $Data.grid."$( $cell2 )".card = "$( $Data.deck[1] )"
    $Data.grid."$( $cell3 )".card = "$( $Data.deck[2] )"
    
    $Data.grid."$( $cell1 )".label.BackColor = $Data.colors.background
    $Data.grid."$( $cell2 )".label.BackColor = $Data.colors.background
    $Data.grid."$( $cell3 )".label.BackColor = $Data.colors.background

    $Data.deck.Remove( $Data.deck[2] )
    $Data.deck.Remove( $Data.deck[1] )
    $Data.deck.Remove( $Data.deck[0] )

    $Data.selectedCards.Clear()

    $Data.label1.Text = "No sets found"
    $Data.label2.Text = "3 cards added"

    if ( $Data.autoDraw ) {
        Find-PossibleSets -Data $Data
    }

    return
}

function Enter-Seed {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Enter-Seed"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    $userInput = Get-UserInput -Message "Enter a seed; Numbers only;"

    if ( $userInput -eq "cancel" ) {
        return
    } elseif ( $userInput -match '[^0-9]' ) {
        Write-Warning "Invalid seed"
        Enter-Seed -Data $Data
    } else {
        $Data.seed = [int]$userInput
        New-Game -Data $Data
    }

    return
}

function Get-Hint {
    param(
        [PSCustomObject]$Data,
        [switch]$One,
        [switch]$Two,
        [switch]$Three
    )

    if ( $Data.debug ) {
        Write-Host "Get-Hint | One: $( $One ) | Two: $( $Two ) | Three: $( $Three )"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    if ( -not $Data.start ) {
        return
    }

    if ( $Data.hintShown ) {
        return
    }

    $cards = $Data.sets[0]
    $split = $cards.Split( ',' )
    $card1 = $split[0]
    $card2 = $split[1]
    $card3 = $split[2]

    if ( $One ) {
        $Data.grid."$( $Data.cards."$( $card1 )".cell )".label.BackColor = $Data.colors.hint

        $Data.hintsUsed += 1
    } elseif ( $Two ) {
        $Data.grid."$( $Data.cards."$( $card1 )".cell )".label.BackColor = $Data.colors.hint
        $Data.grid."$( $Data.cards."$( $card2 )".cell )".label.BackColor = $Data.colors.hint

        $Data.hintsUsed += 2
    } elseif ( $Three ) {
        $Data.grid."$( $Data.cards."$( $card1 )".cell )".label.BackColor = $Data.colors.hint
        $Data.grid."$( $Data.cards."$( $card2 )".cell )".label.BackColor = $Data.colors.hint
        $Data.grid."$( $Data.cards."$( $card3 )".cell )".label.BackColor = $Data.colors.hint

        $Data.hintsUsed += 3
    }

    $Data.hintsUsedLabel.Text = "$( $Data.hintsUsedText ) $( $Data.hintsUsed )"
    $Data.hintShown = $true

    return
}

function Set-Colors {
    param(
        [PSCustomObject]$Data,
        [switch]$Background,
        [switch]$Selected,
        [switch]$Hint
    )

    if ( $Data.debug ) {
         Write-Host "Set-Colors | Background: $( $Background ) | Selected: $( $Selected ) | Hint: $( $Hint )"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    $colorPicker = [System.Windows.Forms.ColorDialog]::new()
    $colorPicker.ShowDialog() | Out-Null

    if ( $Background ) {
        $Data.colors.background = $colorPicker.Color
    } elseif ( $Selected ) {
        $Data.colors.selected = $colorPicker.Color
    } elseif ( $Hint ) {
        $Data.colors.hint = $colorPicker.Color
    }

    Update-Grid -Data $Data

    return
}

function Update-Grid {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
         Write-Host "Update-Grid"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    foreach ( $prop1 in $Data.grid.PSObject.Properties ) {
        if ( $Data.selectedCards.Contains( $Data.grid."$( $prop1.Name )".card )) {
            $Data.grid."$( $prop1.Name )".label.BackColor = $Data.colors.selected
        } else {
            $Data.grid."$( $prop1.Name )".label.BackColor = $Data.colors.background
        }
    }

    return
}

function Set-Players {
    param(
        [PSCustomObject]$Data,
        [int]$PlayerCount
    )

    if ( $Data.debug ) {
        Write-Host "Set-Players | PlayerCount: $( $PlayerCount )"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    $Data.playerCount = $PlayerCount

    Update-PlayerScores -Data $Data

    if ( $Data.start ) {
        New-Game -Data $Data
    }

    return
}

function Start-PlayerTurn {
    param(
        [PSCustomObject]$Data,
        [int]$Player
    )

    if ( $Data.debug ) {
        Write-Host "Start-PlayerTurn | Player: $( $Player )"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    $Data.playerTurn = $Player

    if ( $Player -eq 0 ) {
        $Data.playerTurnLabel.Text = ""
        $Data.turnTimer.Enabled = $false
        if ( $Data.selectedCards.Count -gt 0 ) {
            $Data.selectedCards.Clear()
            Update-Grid -Data $Data
        }
    } else {
        $Data.playerTurnLabel.Text = "Player $( $Player ) selecting"
        $Data.turnTimer.Enabled = $true
    }

    return
}

function Update-PlayerScores {
    param(
        [PSCustomObject]$Data
    )

    if ( $Data.debug ) {
        Write-Host "Update-PlayerScores"
    }

    if ( $Data.selfCheck ) { Write-Host "$( $Data )" }

    switch ( $Data.playerCount ) {
        1 {
            $Data.playerTurnLabel.Text = ""
            $Data.player1Label.Text = ""
            $Data.player2Label.Text = ""
            $Data.player3Label.Text = ""
            $Data.player4Label.Text = ""
        }
        2 {
            $Data.playerTurnLabel.Text = ""
            $Data.player1Label.Text = "Player 1: $( $Data.player1Score )"
            $Data.player2Label.Text = "Player 2: $( $Data.player2Score )"
            $Data.player3Label.Text = ""
            $Data.player4Label.Text = ""
        }
        3 {
            $Data.playerTurnLabel.Text = ""
            $Data.player1Label.Text = "Player 1: $( $Data.player1Score )"
            $Data.player2Label.Text = "Player 2: $( $Data.player2Score )"
            $Data.player3Label.Text = "Player 3: $( $Data.player3Score )"
            $Data.player4Label.Text = ""
        }
        4 {
            $Data.playerTurnLabel.Text = ""
            $Data.player1Label.Text = "Player 1: $( $Data.player1Score )"
            $Data.player2Label.Text = "Player 2: $( $Data.player2Score )"
            $Data.player3Label.Text = "Player 3: $( $Data.player3Score )"
            $Data.player4Label.Text = "Player 4: $( $Data.player4Score )"
        }
    }

    Set-AutoSize -Control $Data.form

    return
}

function Get-Help {
    param(
        [PSCustomObject]$Data,
        [switch]$How,
        [switch]$Players
    )

    if ( $Data.debug ) {
        Write-Host "Get-Help"
    }

    if ( $How ) {
        
    } elseif ( $Players ) {
        $text = "Whichever player presses their button first gets a turn."
        $text += "`nIf they choose correctly then they get a point."
        $text += "`nIf they choose incorrectly then their turn ends."
        $text += "`nThe turn will end in 5 seconds."
        $text += "`nPlayer 1 = Space"
        $text += "`nPlayer 2 = Return"
        $text += "`nPlayer 3 = Down"
        $text += "`nPlayer 4 = Tab"
        $text += "`nPress escape to end a player's turn early."
        [System.Windows.MessageBox]::Show( $text )
    }

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

$data = [PSCustomObject]@{
    debug = $false
    selfCheck = $false
    seedCheck = $false
    testSeed = $false
    start = $false
    autoDraw = $true
    hintShown = $false
    playerCount = 1
    playerTurn = 0
    player1Score = 0
    player2Score = 0
    player3Score = 0
    player4Score = 0
    seed = ""
    seedText = "Seed:"
    setCountText = "Sets Available:"
    deckCountText = "Deck Remaining:"
    hintsUsed = 0
    hintsUsedText = "Hints Used:"
    timeStart = 0
    timeStartText = "Time Started:"
    timeEnd = 0
    timeEndText = "Time Ended:"
    timeTotal = 0
    timeTotalText = "Total Time (s):"
    form = [System.Windows.Forms.Form]::new()
    toolStrip = [System.Windows.Forms.ToolStrip]::new()
    dropDownDebug = [System.Windows.Forms.ToolStripDropDownButton]::new()
    grid = [PSCustomObject]@{}
    cards = [PSCustomObject]@{}
    cardSize = [System.Drawing.Size]::new( 130, 90 )
    selectedCards = [System.Collections.ArrayList]::new()
    sets = [System.Collections.ArrayList]::new()
    deck = [System.Collections.ArrayList]::new()
    colors = [PSCustomObject]@{
        selected = [System.Drawing.Color]::Gray
        background = [System.Drawing.Color]::DimGray
        hint = [System.Drawing.Color]::SteelBlue
    }
    imagePath = "$( $PSScriptRoot )\SetCards"
    label1 = [System.Windows.Forms.Label]::new()
    label2 = [System.Windows.Forms.Label]::new()
    emptyLabel1 = [System.Windows.Forms.Label]::new()
    emptyLabel2 = [System.Windows.Forms.Label]::new()
    emptyLabel3 = [System.Windows.Forms.Label]::new()
    seedLabel = [System.Windows.Forms.Label]::new()
    setCountLabel = [System.Windows.Forms.Label]::new()
    deckCountLabel = [System.Windows.Forms.Label]::new()
    hintsUsedLabel = [System.Windows.Forms.Label]::new()
    timeStartLabel = [System.Windows.Forms.Label]::new()
    timeEndLabel = [System.Windows.Forms.Label]::new()
    timeTotalLabel = [System.Windows.Forms.Label]::new()
    playerTurnLabel = [System.Windows.Forms.Label]::new()
    player1Label = [System.Windows.Forms.Label]::new()
    player2Label = [System.Windows.Forms.Label]::new()
    player3Label = [System.Windows.Forms.Label]::new()
    player4Label = [System.Windows.Forms.Label]::new()
    turnTimer = [System.Timers.Timer]::new()
}

$data.turnTimer.AutoReset = $false
$data.turnTimer.Enabled = $false
$data.turnTimer.Interval = 5000
$data.turnTimer.SynchronizingObject = $data.form
$data.turnTimer.Add_Elapsed({ Start-PlayerTurn -Data $data -Player 0 })

$data.form.Text = "Set Game"
$data.form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$data.form.Add_Closed({ Clear-Images -Data $data })

###
# Tool Strip
###
$data.toolStrip = [System.Windows.Forms.ToolStrip]::new()
$data.toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
$data.toolStrip.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden
$data.form.Controls.Add( $data.toolStrip ) | Out-Null

###
# Buttons
###
$buttonNewGame = [System.Windows.Forms.ToolStripButton]::new()
$buttonNewGame.Text = "New Game"
$buttonNewGame.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonNewGame.Add_Click({ New-Game -Data $data })
$data.toolStrip.Items.Add( $buttonNewGame ) | Out-Null

$buttonSetSeed = [System.Windows.Forms.ToolStripButton]::new()
$buttonSetSeed.Text = "Enter Seed"
$buttonSetSeed.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonSetSeed.Add_Click({ Enter-Seed -Data $data })
$data.toolStrip.Items.Add( $buttonSetSeed ) | Out-Null

$buttonAddCards = [System.Windows.Forms.ToolStripButton]::new()
$buttonAddCards.Text = "Add Cards"
$buttonAddCards.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonAddCards.Add_Click({ Add-Cards -Data $data })
if ( $data.debug ) {
    $data.toolStrip.Items.Add( $buttonAddCards ) | Out-Null
}

$dropDownHint = [System.Windows.Forms.ToolStripDropDownButton]::new()
$dropDownHint.Text = "Hint"
$dropDownHint.ShowDropDownArrow = $true
$dropDownHint.Padding = [System.Windows.Forms.Padding]::new(5,0,0,0)

$dropDownHintItems = [System.Windows.Forms.ToolStripDropDown]::new()

$buttonHint1 = [System.Windows.Forms.ToolStripButton]::new()
$buttonHint1.Text = "One Card"
$buttonHint1.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonHint1.Add_Click({ Get-Hint -Data $data -One })
$dropDownHintItems.Items.Add( $buttonHint1 ) | Out-Null

$buttonHint2 = [System.Windows.Forms.ToolStripButton]::new()
$buttonHint2.Text = "Two Cards"
$buttonHint2.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonHint2.Add_Click({ Get-Hint -Data $data -Two })
$dropDownHintItems.Items.Add( $buttonHint2 ) | Out-Null

$buttonHint3 = [System.Windows.Forms.ToolStripButton]::new()
$buttonHint3.Text = "Three Cards"
$buttonHint3.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonHint3.Add_Click({ Get-Hint -Data $data -Three })
$dropDownHintItems.Items.Add( $buttonHint3 ) | Out-Null

$dropDownHint.DropDown = $dropDownHintItems
$data.toolStrip.Items.Add( $dropDownHint ) | Out-Null

$dropDownColors = [System.Windows.Forms.ToolStripDropDownButton]::new()
$dropDownColors.Text = "Colors"
$dropDownColors.ShowDropDownArrow = $true
$dropDownColors.Padding = [System.Windows.Forms.Padding]::new(5,0,0,0)

$dropDownColorItems = [System.Windows.Forms.ToolStripDropDown]::new()

$buttonBackColor = [System.Windows.Forms.ToolStripButton]::new()
$buttonBackColor.Text = "Background"
$buttonBackColor.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonBackColor.Add_Click({ Set-Colors -Data $data -Background })
$dropDownColorItems.Items.Add( $buttonBackColor ) | Out-Null

$buttonSelectedColor = [System.Windows.Forms.ToolStripButton]::new()
$buttonSelectedColor.Text = "Selected"
$buttonSelectedColor.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonSelectedColor.Add_Click({ Set-Colors -Data $data -Selected })
$dropDownColorItems.Items.Add( $buttonSelectedColor ) | Out-Null

$buttonHintColor = [System.Windows.Forms.ToolStripButton]::new()
$buttonHintColor.Text = "Hint"
$buttonHintColor.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonHintColor.Add_Click({ Set-Colors -Data $data -Hint })
$dropDownColorItems.Items.Add( $buttonHintColor ) | Out-Null

$dropDownColors.DropDown = $dropDownColorItems
$data.toolStrip.Items.Add( $dropDownColors ) | Out-Null

$dropDownPlayers = [System.Windows.Forms.ToolStripDropDownButton]::new()
$dropDownPlayers.Text = "Players"
$dropDownPlayers.ShowDropDownArrow = $true
$dropDownPlayers.Padding = [System.Windows.Forms.Padding]::new(5,0,0,0)

$dropDownPlayerItems = [System.Windows.Forms.ToolStripDropDown]::new()

$buttonOnePlayer = [System.Windows.Forms.ToolStripButton]::new()
$buttonOnePlayer.Text = "One Player"
$buttonOnePlayer.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonOnePlayer.Add_Click({ Set-Players -Data $data -PlayerCount 1 })
$dropDownPlayerItems.Items.Add( $buttonOnePlayer ) | Out-Null

$buttonTwoPlayers = [System.Windows.Forms.ToolStripButton]::new()
$buttonTwoPlayers.Text = "Two Players"
$buttonTwoPlayers.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonTwoPlayers.Add_Click({ Set-Players -Data $data -PlayerCount 2 })
$dropDownPlayerItems.Items.Add( $buttonTwoPlayers ) | Out-Null

$buttonThreePlayers = [System.Windows.Forms.ToolStripButton]::new()
$buttonThreePlayers.Text = "Three Players"
$buttonThreePlayers.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonThreePlayers.Add_Click({ Set-Players -Data $data -PlayerCount 3 })
$dropDownPlayerItems.Items.Add( $buttonThreePlayers ) | Out-Null

$buttonFourPlayers = [System.Windows.Forms.ToolStripButton]::new()
$buttonFourPlayers.Text = "Four Players"
$buttonFourPlayers.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonFourPlayers.Add_Click({ Set-Players -Data $data -PlayerCount 4 })
$dropDownPlayerItems.Items.Add( $buttonFourPlayers ) | Out-Null

$dropDownPlayers.DropDown = $dropDownPlayerItems
$data.toolStrip.Items.Add( $dropDownPlayers ) | Out-Null

$dropDownHelp = [System.Windows.Forms.ToolStripDropDownButton]::new()
$dropDownHelp.Text = "Help"
$dropDownHelp.ShowDropDownArrow = $true
$dropDownHelp.Padding = [System.Windows.Forms.Padding]::new(5,0,0,0)

$dropDownHelpItems = [System.Windows.Forms.ToolStripDropDown]::new()

$buttonHelpHow = [System.Windows.Forms.ToolStripButton]::new()
$buttonHelpHow.Text = "How To Play"
$buttonHelpHow.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonHelpHow.Add_Click({ Get-Help -Data $data -How })
$dropDownHelpItems.Items.Add( $buttonHelpHow ) | Out-Null

$buttonHelpPlayers = [System.Windows.Forms.ToolStripButton]::new()
$buttonHelpPlayers.Text = "Multiplayer"
$buttonHelpPlayers.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonHelpPlayers.Add_Click({ Get-Help -Data $data -Players })
$dropDownHelpItems.Items.Add( $buttonHelpPlayers ) | Out-Null

$dropDownHelp.DropDown = $dropDownHelpItems
$data.toolStrip.Items.Add( $dropDownHelp ) | Out-Null

$data.dropDownDebug.Text = "Debug"
$data.dropDownDebug.ShowDropDownArrow = $true
$data.dropDownDebug.Padding = [System.Windows.Forms.Padding]::new(5,0,0,0)

$dropDownDebugItems = [System.Windows.Forms.ToolStripDropDown]::new()

$buttonSelfCheck = [System.Windows.Forms.ToolStripButton]::new()
$buttonSelfCheck.Text = "Self Check"
$buttonSelfCheck.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonSelfCheck.Add_Click({ $data.selfCheck = ( -not $data.selfCheck ) })
$dropDownDebugItems.Items.Add( $buttonSelfCheck ) | Out-Null

$buttonSeedCheck = [System.Windows.Forms.ToolStripButton]::new()
$buttonSeedCheck.Text = "Seed Check"
$buttonSeedCheck.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonSeedCheck.Add_Click({ $data.seedCheck = ( -not $data.seedCheck ) })
$dropDownDebugItems.Items.Add( $buttonSeedCheck ) | Out-Null

$buttonTestSeed = [System.Windows.Forms.ToolStripButton]::new()
$buttonTestSeed.Text = "Test Seed"
$buttonTestSeed.Dock = [System.Windows.Forms.DockStyle]::Top
$buttonTestSeed.Add_Click({ $data.testSeed = ( -not $data.testSeed ) })
$dropDownDebugItems.Items.Add( $buttonTestSeed ) | Out-Null

$data.dropDownDebug.DropDown = $dropDownDebugItems
if ( $data.Debug ) {
    $data.toolStrip.Items.Add( $data.dropDownDebug ) | Out-Null
    $data.emptyLabel3.Text = "          *DEBUG*            "
}

###
# Main Panel
###
$mainPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$mainPanel.Padding = [System.Windows.Forms.Padding]::new( 5, $data.toolStrip.Height, 5, 5 )
$mainPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
$data.form.Controls.Add( $mainPanel ) | Out-Null

###
# Main Grid
###
$mainGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$mainGrid.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainGrid.Anchor = [System.Windows.Forms.AnchorStyles]::Top
$mainGrid.RowCount = 3
$mainGrid.ColumnCount = 3
#$mainGrid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$mainPanel.Controls.Add( $mainGrid ) | Out-Null

###
# Text Labels
###
$textPanelNW = [System.Windows.Forms.TableLayoutPanel]::new()
$textPanelNW = [System.Windows.Forms.FlowLayoutPanel]::new()
$textPanelNW.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 0, 0 )
$mainGrid.SetCellPosition( $textPanelNW, $cellPosition )
$mainGrid.Controls.Add( $textPanelNW ) | Out-Null

$textPanelN = [System.Windows.Forms.TableLayoutPanel]::new()
$textPanelN = [System.Windows.Forms.FlowLayoutPanel]::new()
$textPanelN.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 1, 0 )
$mainGrid.SetCellPosition( $textPanelN, $cellPosition )
$mainGrid.Controls.Add( $textPanelN ) | Out-Null

$textPanelNE = [System.Windows.Forms.TableLayoutPanel]::new()
$textPanelNE = [System.Windows.Forms.FlowLayoutPanel]::new()
$textPanelNE.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 2, 0 )
$mainGrid.SetCellPosition( $textPanelNE, $cellPosition )
$mainGrid.Controls.Add( $textPanelNE ) | Out-Null

$textPanelW = [System.Windows.Forms.TableLayoutPanel]::new()
$textPanelW = [System.Windows.Forms.FlowLayoutPanel]::new()
$textPanelW.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 0, 1 )
$mainGrid.SetCellPosition( $textPanelW, $cellPosition )
$mainGrid.Controls.Add( $textPanelW ) | Out-Null

$textPanelE = [System.Windows.Forms.TableLayoutPanel]::new()
$textPanelE = [System.Windows.Forms.FlowLayoutPanel]::new()
$textPanelE.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 2, 1 )
$mainGrid.SetCellPosition( $textPanelE, $cellPosition )
$mainGrid.Controls.Add( $textPanelE ) | Out-Null

$textPanelSW = [System.Windows.Forms.TableLayoutPanel]::new()
$textPanelSW = [System.Windows.Forms.FlowLayoutPanel]::new()
$textPanelSW.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 0, 2 )
$mainGrid.SetCellPosition( $textPanelSW, $cellPosition )
$mainGrid.Controls.Add( $textPanelSW ) | Out-Null

$textPanelS = [System.Windows.Forms.TableLayoutPanel]::new()
$textPanelS = [System.Windows.Forms.FlowLayoutPanel]::new()
$textPanelS.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 1, 2 )
$mainGrid.SetCellPosition( $textPanelS, $cellPosition )
$mainGrid.Controls.Add( $textPanelS ) | Out-Null

$textPanelSE = [System.Windows.Forms.TableLayoutPanel]::new()
$textPanelSE = [System.Windows.Forms.FlowLayoutPanel]::new()
$textPanelSE.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 2, 2 )
$mainGrid.SetCellPosition( $textPanelSE, $cellPosition )
$mainGrid.Controls.Add( $textPanelSE ) | Out-Null

$data.label1.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.label1.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.label1.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.label1.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.label1.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.label1.Text = ""
$textPanelNE.Controls.Add( $data.label1 ) | Out-Null

$data.label2.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.label2.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.label2.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.label2.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.label2.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.label2.Text = ""
$textPanelNE.Controls.Add( $data.label2 ) | Out-Null

$data.emptyLabel3.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$data.emptyLabel3.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.emptyLabel3.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.emptyLabel3.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.emptyLabel3.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.emptyLabel3.Text = "                                    "
$textPanelNE.Controls.Add( $data.emptyLabel3 ) | Out-Null

$data.seedLabel.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.seedLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.seedLabel.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.seedLabel.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.seedLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.seedLabel.Text = $data.seedText
$textPanelN.Controls.Add( $data.seedLabel ) | Out-Null

$data.deckCountLabel.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.deckCountLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.deckCountLabel.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.deckCountLabel.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.deckCountLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.deckCountLabel.Text = $data.deckCountText
$textPanelN.Controls.Add( $data.deckCountLabel ) | Out-Null

$data.setCountLabel.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.setCountLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.setCountLabel.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.setCountLabel.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.setCountLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.setCountLabel.Text = $data.setCountText
$textPanelN.Controls.Add( $data.setCountLabel ) | Out-Null

$data.emptyLabel1.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.emptyLabel1.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.emptyLabel1.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.emptyLabel1.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.emptyLabel1.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.emptyLabel1.Text = ""
$textPanelE.Controls.Add( $data.emptyLabel1 ) | Out-Null

$data.hintsUsedLabel.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.hintsUsedLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.hintsUsedLabel.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.hintsUsedLabel.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.hintsUsedLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.hintsUsedLabel.Text = $data.hintsUsedText
$textPanelE.Controls.Add( $data.hintsUsedLabel ) | Out-Null

$data.emptyLabel2.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.emptyLabel2.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.emptyLabel2.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.emptyLabel2.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.emptyLabel2.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.emptyLabel2.Text = ""
$textPanelE.Controls.Add( $data.emptyLabel2 ) | Out-Null

$data.timeStartLabel.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.timeStartLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.timeStartLabel.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.timeStartLabel.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.timeStartLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.timeStartLabel.Text = $data.timeStartText
$textPanelE.Controls.Add( $data.timeStartLabel ) | Out-Null

$data.timeEndLabel.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.timeEndLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.timeEndLabel.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.timeEndLabel.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.timeEndLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.timeEndLabel.Text = $data.timeEndText
$textPanelE.Controls.Add( $data.timeEndLabel ) | Out-Null

$data.timeTotalLabel.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.timeTotalLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.timeTotalLabel.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.timeTotalLabel.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.timeTotalLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.timeTotalLabel.Text = $data.timeTotalText
$textPanelE.Controls.Add( $data.timeTotalLabel ) | Out-Null

$data.player1Label.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.player1Label.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.player1Label.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.player1Label.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.player1Label.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.player1Label.Text = ""
$textPanelS.Controls.Add( $data.player1Label ) | Out-Null

$data.player2Label.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.player2Label.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.player2Label.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.player2Label.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.player2Label.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.player2Label.Text = ""
$textPanelS.Controls.Add( $data.player2Label ) | Out-Null

$data.player3Label.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.player3Label.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.player3Label.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.player3Label.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.player3Label.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.player3Label.Text = ""
$textPanelS.Controls.Add( $data.player3Label ) | Out-Null

$data.player4Label.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.player4Label.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.player4Label.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.player4Label.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.player4Label.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.player4Label.Text = ""
$textPanelS.Controls.Add( $data.player4Label ) | Out-Null

$data.playerTurnLabel.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$data.playerTurnLabel.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$data.playerTurnLabel.Padding = [System.Windows.Forms.Padding]::new( 0 )
$data.playerTurnLabel.Margin = [System.Windows.Forms.Padding]::new( 0 )
$data.playerTurnLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
$data.playerTurnLabel.Text = ""
$textPanelSE.Controls.Add( $data.playerTurnLabel ) | Out-Null

###
# Grid Area
###
$outerPanelGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$outerPanelGrid.Dock = [System.Windows.Forms.DockStyle]::Fill
$outerPanelGrid.Anchor = [System.Windows.Forms.AnchorStyles]::Top
$middlePanelGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$middlePanelGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$innerPanelGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelGrid.RowCount = 7
$innerPanelGrid.ColumnCount = 3
$innerPanelGrid.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
$outerPanelGrid.Controls.Add( $middlePanelGrid ) | Out-Null
$middlePanelGrid.Controls.Add( $innerPanelGrid ) | Out-Null
$cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( 1, 1 )
$mainGrid.SetCellPosition( $outerPanelGrid, $cellPosition )
$mainGrid.Controls.Add( $outerPanelGrid ) | Out-Null

$cards = Get-ChildItem -Path $data.imagePath
foreach ( $card in $cards ) {
    $name = $card.Name.Replace( '.png', '' )
    try {
        $data.cards | Add-Member -MemberType NoteProperty -Name "$( $name )" -Value $( [PSCustomObject]@{} ) -ErrorAction Stop
    } catch {
        $data.cards.PSObject.Properties.remove( "$( $name )" )
        $data.cards | Add-Member -MemberType NoteProperty -Name "$( $name )" -Value $( [PSCustomObject]@{} )
    }

    $data.cards.$name | Add-Member -MemberType NoteProperty -Name "image" -Value $( [System.Drawing.Image]::FromFile( "$( $data.imagePath )\$( $card.Name )" ))
    $data.cards.$name | Add-Member -MemberType NoteProperty -Name "cell" -Value ""
}

foreach ( $row in 0..( $innerPanelGrid.RowCount - 1 )) {
    foreach ( $col in 0..( $innerPanelGrid.ColumnCount - 1 )) {
        try {
            $data.grid | Add-Member -MemberType NoteProperty -Name "$( $col )_$( $row )" -Value $( [PSCustomObject]@{} ) -ErrorAction Stop
        } catch {
            $data.grid.PSObject.Properties.Remove( "$( $col )_$( $row )" )
            $data.grid | Add-Member -MemberType NoteProperty -Name "$( $col )_$( $row )" -Value $( [PSCustomObject]@{})
        }

        try {
            $data.grid."$( $col )_$( $row )" | Add-Member -MemberType NoteProperty -Name "card" -Value "" -ErrorAction Stop
        } catch {
            $data.grid."$( $col )_$( $row )".PSObject.Properties.Remove( "card" )
            $data.grid."$( $col )_$( $row )" | Add-Member -MemberType NoteProperty -Name "card" -Value ""
        }

        try {
            $data.grid."$( $col )_$( $row )" | Add-Member -MemberType NoteProperty -Name "label" -Value $( [System.Windows.Forms.Label]::new() ) -ErrorAction Stop
        } catch {
            $data.grid."$( $col )_$( $row )".PSObject.Properties.Remove( "label" )
            $innerPanelGrid.Controls.Remove( $data.grid."$( $col )_$( $row )".label )
            $data.grid."$( $col )_$( $row )" | Add-Member -MemberType NoteProperty -Name "label" -Value $( [System.Windows.Forms.Label]::new())
        }
        $data.grid."$( $col )_$( $row )".label.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
        $data.grid."$( $col )_$( $row )".label.Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $data.grid."$( $col )_$( $row )".label.Size = $data.cardSize
        $data.grid."$( $col )_$( $row )".label.Padding = [System.Windows.Forms.Padding]::new( 0 )
        $data.grid."$( $col )_$( $row )".label.Margin = [System.Windows.Forms.Padding]::new( 0 )
        $data.grid."$( $col )_$( $row )".label.Dock = [System.Windows.Forms.DockStyle]::Fill
        $data.grid."$( $col )_$( $row )".label.BackColor = $data.colors.background
        $data.grid."$( $col )_$( $row )".label.Name = "$( $col )_$( $row )"
        $data.grid."$( $col )_$( $row )".label.Text = ""
        $data.grid."$( $col )_$( $row )".label.BackgroundImage = $data.cards.blank.image
        $data.grid."$( $col )_$( $row )".label.Add_MouseClick({
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseClick -Data $data -Cell $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseClick -Data $data -Cell $this.Name -Right
            }
        })
        
        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $col, $row )
        $innerPanelGrid.SetCellPosition( $data.grid."$( $col )_$( $row )".label, $cellPosition )
        $innerPanelGrid.Controls.Add( $data.grid."$( $col )_$( $row )".label )
    }
}

Set-AutoSize -Control $data.form

Set-KeyDown -Data $data -Control $data.form

$null = $data.form.ShowDialog()
