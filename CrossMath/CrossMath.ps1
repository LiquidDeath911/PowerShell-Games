Clear-Host
 
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
 
function Set-AutoSize {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        $Control
    )
 
    foreach ($property in $control.PSObject.Properties) {
        if ($property.Name -eq "AutoSizeMode") {
            $Control.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
        } elseif ($property.Name -eq "AutoSize") {
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
 
function Set-Colors {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
   
    $GameMaster.colors.number = [System.Drawing.Color]::White
    $GameMaster.colors.operand = [System.Drawing.Color]::DimGray
    $GameMaster.colors.equal = [System.Drawing.Color]::DimGray
    $GameMaster.colors.result = [System.Drawing.Color]::SlateGray
    $GameMaster.colors.hover = [System.Drawing.Color]::Orange
    $GameMaster.colors.input = [System.Drawing.Color]::CadetBlue
    $GameMaster.colors.note = [System.Drawing.Color]::DeepPink
    $GameMaster.colors.noteFont = [System.Drawing.Color]::Blue
    $GameMaster.colors.blank = [System.Drawing.Color]::Black
    $GameMaster.colors.correct = [System.Drawing.Color]::Green
    $GameMaster.colors.incorrect = [System.Drawing.Color]::Red
 
    return
}
 
function Set-KeyDown {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [PSCustomObject]$GameMaster,
        $Control
    )
 
    $Control.Add_KeyDown({
        if (( $_.KeyCode -eq "Back" ) -or ( $_.KeyCode -eq "D0" ) -or ( $_.KeyCode -eq "NumPad0" )) {
            New-KeyDown -GameMaster $GameMaster -Key 0
        } elseif (( $_.KeyCode -eq "D1" ) -or ( $_.KeyCode -eq "NumPad1" )) {
            New-KeyDown -GameMaster $GameMaster -Key 1
        } elseif (( $_.KeyCode -eq "D2" ) -or ( $_.KeyCode -eq "NumPad2" )) {
            New-KeyDown -GameMaster $GameMaster -Key 2
        } elseif (( $_.KeyCode -eq "D3" ) -or ( $_.KeyCode -eq "NumPad3" )) {
            New-KeyDown -GameMaster $GameMaster -Key 3
        } elseif (( $_.KeyCode -eq "D4" ) -or ( $_.KeyCode -eq "NumPad4" )) {
            New-KeyDown -GameMaster $GameMaster -Key 4
        } elseif (( $_.KeyCode -eq "D5" ) -or ( $_.KeyCode -eq "NumPad5" )) {
            New-KeyDown -GameMaster $GameMaster -Key 5
        } elseif (( $_.KeyCode -eq "D6" ) -or ( $_.KeyCode -eq "NumPad6" )) {
            New-KeyDown -GameMaster $GameMaster -Key 6
        } elseif (( $_.KeyCode -eq "D7" ) -or ( $_.KeyCode -eq "NumPad7" )) {
            New-KeyDown -GameMaster $GameMaster -Key 7
        } elseif (( $_.KeyCode -eq "D8" ) -or ( $_.KeyCode -eq "NumPad8" )) {
            New-KeyDown -GameMaster $GameMaster -Key 8
        } elseif (( $_.KeyCode -eq "D9" ) -or ( $_.KeyCode -eq "NumPad9" )) {
            New-KeyDown -GameMaster $GameMaster -Key 9
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
 
    if ( -not $GameMaster.start ) {
        return
    }
 
    Set-Number -GameMaster $GameMaster -Number $Key
 
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
    }
 
    $split = $Name.Split( "_" )
    $type = $split[0]
    $column = $split[1]
    $row = $split[2]
 
    if ( $type -eq "n" ) {
        if (  $GameMaster.grid."$( $column )_$( $row )".BackColor -eq $GameMaster.colors.number ) {
            $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.hover
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
    }
 
    $split = $Name.Split( "_" )
    $type = $split[0]
    $column = $split[1]
    $row = $split[2]
 
    if ( $type -eq "n" ) {
        if (  $GameMaster.grid."$( $column )_$( $row )".BackColor -eq $GameMaster.colors.hover ) {
            $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.number
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
 
    $split = $Name.Split( "_" )
    $type = $split[0]
    $column = $split[1]
    $row = $split[2]
 
    if ( $Left ) {
        if ( $type -eq "n" ) {
            $GameMaster.click = "Left"
            foreach ( $property in $GameMaster.grid.PSObject.Properties ) {
                if (( $property.Name -ne "$( $column )_$( $row )" ) -and ( $GameMaster.grid."$( $property.Name )".BackColor -eq $GameMaster.colors.input )) {
                    $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.number
                }
                if (( $property.Name -ne "$( $column )_$( $row )" ) -and ( $GameMaster.grid."$( $property.Name )".BackColor -eq $GameMaster.colors.note )) {
                    $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.number
                }
            }
 
            if ( $GameMaster.grid."$( $column )_$( $row )".BackColor -eq $GameMaster.colors.input ) {
                $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.number
                $GameMaster.click = ""
            } else {
                $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.input
            }
        }
    } elseif ( $Right ) {
        if ( $type -eq "n" ) {
            $GameMaster.click = "Right"
            foreach ( $property in $GameMaster.grid.PSObject.Properties ) {
                if (( $property.Name -ne "$( $column )_$( $row )" ) -and ( $GameMaster.grid."$( $property.Name )".BackColor -eq $GameMaster.colors.input )) {
                    $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.number
                }
                if (( $property.Name -ne "$( $column )_$( $row )" ) -and ( $GameMaster.grid."$( $property.Name )".BackColor -eq $GameMaster.colors.note )) {
                    $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.number
                }
            }
 
            if ( $GameMaster.grid."$( $column )_$( $row )".BackColor -eq $GameMaster.colors.note ) {
                $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.number
                $GameMaster.click = ""
            } else {
                $GameMaster.grid."$( $column )_$( $row )".BackColor = $GameMaster.colors.note
            }
        }
    }
 
 
    return
}
 
function Get-NumbersSorted {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [string]$Text
    )
 
    $array = "$( $Text )".ToCharArray()
 
    $sorted = $array | Sort-Object
 
    $output = $sorted -join ""
 
    return $output
}
 
function Set-Number {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster,
        [int]$Number
    )
 
    if ( $GameMaster.click -eq "Left" ) {
        if ( $Number -ne 0 ) {
            foreach ( $property in $GameMaster.userNumbers.PSObject.Properties ) {
                if (  $GameMaster.userNumbers."$( $property.Name )" -eq $Number ) {
                    $GameMaster.userNumbers."$( $property.Name )" = 0
                    $GameMaster.grid."$( $property.Name )".Text = ""
                }
            }
        }
 
        foreach ( $property in $GameMaster.grid.PSObject.Properties ) {
            if ( $GameMaster.grid."$( $property.Name )".BackColor -eq $GameMaster.colors.input ) {
                if ( $Number -eq 0 ) {
                    $GameMaster.userNumbers."$( $property.Name )" = 0
                    if ( $GameMaster.userNotes."$( $property.Name )".Length -eq 0 ) {
                        $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.number
                        $GameMaster.grid."$( $property.Name )".ForeColor = [System.Drawing.Color]::Black
                        $GameMaster.grid."$( $property.Name )".Text = ""
                    } else {
                        $GameMaster.grid."$( $property.Name )".ForeColor = $GameMaster.colors.noteFont
                        $GameMaster.grid."$( $property.Name )".Text = $GameMaster.userNotes."$( $property.Name )"
                    }
                } else {
                    $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.number
                    $GameMaster.grid."$( $property.Name )".ForeColor = [System.Drawing.Color]::Black
                    $GameMaster.userNumbers."$( $property.Name )" = $Number
                    $GameMaster.grid."$( $property.Name )".Text = $Number
                }
            }
        }
    } elseif ( $GameMaster.click -eq "Right" ) {
        foreach ( $property in $GameMaster.grid.PSObject.Properties ) {
            if ( $GameMaster.grid."$( $property.Name )".BackColor -eq $GameMaster.colors.note ) {
                if ( $Number -eq 0 ) {
                    $GameMaster.userNotes."$( $property.Name )" = ""
                    $GameMaster.grid."$( $property.Name )".ForeColor = [System.Drawing.Color]::Black
                    $GameMaster.grid."$( $property.Name )".Text = ""
                    $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.number
                } else {
                    if ( $GameMaster.userNumbers."$( $property.Name )" -eq 0 ) {
                        if ( $GameMaster.userNotes."$( $property.Name )" -notmatch "$( $Number )" ) {
                            $GameMaster.userNotes."$( $property.Name )" += "$( $Number )"
                            if ( $GameMaster.userNotes."$( $property.Name )".Length -gt 1 ) {
                                $GameMaster.userNotes."$( $property.Name )" = ( Get-NumbersSorted -Text $GameMaster.userNotes."$( $property.Name )" )
                            }
                            $GameMaster.grid."$( $property.Name )".ForeColor = $GameMaster.colors.noteFont
                            $GameMaster.grid."$( $property.Name )".Text = $GameMaster.userNotes."$( $property.Name )"
                        } else {
                            $GameMaster.userNotes."$( $property.Name )" = $GameMaster.userNotes."$( $property.Name )".Replace( "$( $Number )", "" )
                            $GameMaster.grid."$( $property.Name )".ForeColor = $GameMaster.colors.noteFont
                            $GameMaster.grid."$( $property.Name )".Text = $GameMaster.userNotes."$( $property.Name )"
                        }
                    }
                }
            }
        }
    }
 
    Confirm-Equations -GameMaster $GameMaster
 
    return
}
 
function Confirm-Equations {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    $correctCount = 0
    foreach ( $property in $GameMaster.results.PSObject.Properties ) {
        $equation = $GameMaster.equations."$( $property.Name )"
        $equationSplit = $equation.Split( "," )
        if ( $GameMaster.userNumbers."$( $equationSplit[0] )" -eq 0 ) {
            $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.result
            continue
        } elseif ( $GameMaster.userNumbers."$( $equationSplit[2] )" -eq 0 ) {
            $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.result
            continue
        } elseif ( $GameMaster.userNumbers."$( $equationSplit[4] )" -eq 0 ) {
            $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.result
            continue
        }
        $userResult = Get-Result -Equation "$( $GameMaster.userNumbers."$( $equationSplit[0] )" ) $( $GameMaster.operands."$( $equationSplit[1] )" ) $( $GameMaster.userNumbers."$( $equationSplit[2] )" ) $( $GameMaster.operands."$( $equationSplit[3] )" ) $( $GameMaster.userNumbers."$( $equationSplit[4] )" )"
        if ( $GameMaster.results."$( $property.Name )" -eq $userResult ) {
            $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.correct
            $correctCount++
        } else {
            $GameMaster.grid."$( $property.Name )".BackColor = $GameMaster.colors.incorrect
        }
    }
 
    if ( $correctCount -eq 6 ) {
        Set-Win -GameMaster $GameMaster
    }
 
    return
}
 
function Get-Result {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [string]$Equation
    )
 
    $split = $Equation.Split( " " )
    $number1 = $split[0]
    $operand1 = $split[1]
    $number2 = $split[2]
    $operand2 = $split[3]
    $number3 = $split[4]
 
    $runningResult = 0
    $finalResult = 0
 
    switch( $operand1 ) {
        "+" { $runningResult = [int]$number1 + [int]$number2 }
        "-" { $runningResult = [int]$number1 - [int]$number2 }
        "*" { $runningResult = [int]$number1 * [int]$number2 }
        "/" { $runningResult = [int]$number1 / [int]$number2 }
    }
 
    switch( $operand2 ) {
        "+" { $finalResult = [int]$runningResult + [int]$number3 }
        "-" { $finalResult = [int]$runningResult - [int]$number3 }
        "*" { $finalResult = [int]$runningResult * [int]$number3 }
        "/" { $finalResult = [int]$runningResult / [int]$number3 }
    }
 
    return $finalResult
}
 
function Confirm-Divide {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
 
    $operands = "+", "-", "*"
 
    foreach ( $property in $GameMaster.operands.PSObject.Properties ) {
        if ( $GameMaster.operands."$( $property.Name )" -eq "/" ) {
            $split = $property.Name.Split( "_" )
            $column = $split[0]
            $row = $split[1]
 
            if ( $column -eq 1 ) {
                $firstNumber = $GameMaster.numbers."$( [int]$column - 1 )_$( $row )"
                $secondNumber = $GameMaster.numbers."$( [int]$column + 1 )_$( $row )"
 
                if ( $secondNumber -gt $firstNumber ) {
                    $randOperand = Get-Random -Minimum 0 -Maximum $operands.Count
                    $GameMaster.operands."$( $property.Name )" = $operands[$randOperand]
                } elseif (( $firstNumber % $secondNumber ) -ne 0 ) {
                    $randOperand = Get-Random -Minimum 0 -Maximum $operands.Count
                    $GameMaster.operands."$( $property.Name )" = $operands[$randOperand]
                }
 
            } elseif ( $column -eq 3 ) {
                $firstNumber = $GameMaster.numbers."$( [int]$column - 3 )_$( $row )"
                $secondNumber = $GameMaster.numbers."$( [int]$column - 1 )_$( $row )"
                $thirdNumber = $GameMaster.numbers."$( [int]$column + 1 )_$( $row )"
 
                $runningResult = 0
                switch( $GameMaster.operands."$( [int]$column - 2 )_$( $row )" ) {
                    "+" { $runningResult = [int]$firstNumber + [int]$secondNumber }
                    "-" { $runningResult = [int]$firstNumber - [int]$secondNumber }
                    "*" { $runningResult = [int]$firstNumber * [int]$secondNumber }
                    "/" { $runningResult = [int]$firstNumber / [int]$secondNumber }
                }
 
                if ( $thirdNumber -gt $runningResult ) {
                    $randOperand = Get-Random -Minimum 0 -Maximum $operands.Count
                    $GameMaster.operands."$( $property.Name )" = $operands[$randOperand]
                } elseif (( $runningResult % $thirdNumber ) -ne 0 ) {
                    $randOperand = Get-Random -Minimum 0 -Maximum $operands.Count
                    $GameMaster.operands."$( $property.Name )" = $operands[$randOperand]
                }
 
            } elseif ( $row -eq 1 ) {
                $firstNumber = $GameMaster.numbers."$( $column )_$( [int]$row - 1 )"
                $secondNumber = $GameMaster.numbers."$( $column )_$( [int]$row + 1 )"
 
                if ( $secondNumber -gt $firstNumber ) {
                    $randOperand = Get-Random -Minimum 0 -Maximum $operands.Count
                    $GameMaster.operands."$( $property.Name )" = $operands[$randOperand]
                } elseif (( $firstNumber % $secondNumber ) -ne 0 ) {
                    $randOperand = Get-Random -Minimum 0 -Maximum $operands.Count
                    $GameMaster.operands."$( $property.Name )" = $operands[$randOperand]
                }
 
            } elseif ( $row -eq 3 ) {
                $firstNumber = $GameMaster.numbers."$( $column )_$( [int]$row - 3 )"
                $secondNumber = $GameMaster.numbers."$( $column )_$( [int]$row - 1 )"
                $thirdNumber = $GameMaster.numbers."$( $column )_$( [int]$row + 1 )"
 
                $runningResult = 0
                switch( $GameMaster.operands."$( $column )_$( [int]$row - 2 )" ) {
                    "+" { $runningResult = [int]$firstNumber + [int]$secondNumber }
                    "-" { $runningResult = [int]$firstNumber - [int]$secondNumber }
                    "*" { $runningResult = [int]$firstNumber * [int]$secondNumber }
                    "/" { $runningResult = [int]$firstNumber / [int]$secondNumber }
                }
 
                if ( $thirdNumber -gt $runningResult ) {
                    $randOperand = Get-Random -Minimum 0 -Maximum $operands.Count
                    $GameMaster.operands."$( $property.Name )" = $operands[$randOperand]
                } elseif (( $runningResult % $thirdNumber ) -ne 0 ) {
                    $randOperand = Get-Random -Minimum 0 -Maximum $operands.Count
                    $GameMaster.operands."$( $property.Name )" = $operands[$randOperand]
                }
            }
        }
    }
 
    return
}
 
function New-CrossMath {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
   
    if ( $GameMaster.mode -eq 1 ) {
        $operands = "+", "-"
    } elseif ( $GameMaster.mode -eq 2 ) {
        $operands = "+", "-", "*"
    } elseif ( $GameMaster.mode -eq 3 ) {
        $operands = "+", "-", "*", "/"
    } else {
        $GameMaster.mode = 3
        $operands = "+", "-", "*", "/"
    }
 
    $numbers = [System.Collections.ArrayList]::new()
    $numbers.AddRange(1..9)
 
    foreach ( $property in $GameMaster.operands.PSObject.Properties ) {
        $randOperand = Get-Random -Minimum 0 -Maximum $operands.Count
        $GameMaster.operands."$( $property.Name )" = $operands[$randOperand]
    }
 
    foreach ( $property in $GameMaster.numbers.PSObject.Properties ) {
        $randNumber = Get-Random -Minimum 0 -Maximum $numbers.Count
        $GameMaster.numbers."$( $property.Name )" = $numbers[$randNumber]
        $numbers.Remove($numbers[$randNumber])
    }
 
    if ( $GameMaster.mode -eq 3 ) {
        Confirm-Divide -GameMaster $GameMaster
    }
 
    foreach ( $property in $GameMaster.results.PSObject.Properties ) {
        $equation = $GameMaster.equations."$( $property.Name )"
        $equationSplit = $equation.Split( "," )
        $result = Get-Result -Equation "$( $GameMaster.numbers."$( $equationSplit[0] )" ) $( $GameMaster.operands."$( $equationSplit[1] )" ) $( $GameMaster.numbers."$( $equationSplit[2] )" ) $( $GameMaster.operands."$( $equationSplit[3] )" ) $( $GameMaster.numbers."$( $equationSplit[4] )" )"
        $GameMaster.results."$( $property.Name )" = [int]$result
    }
 
    return
}
 
function Set-Win {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [PSCustomObject]$GameMaster
    )
   
    $GameMaster.start = $false
    $GameMaster.infoLabel1.Text = "Congrats! You solved it!"
    $GameMaster.infoLabel2.Text = ""
    $GameMaster.infoLabel3.Text = ""
    
    return
}
 
$gameMaster = [PSCustomObject]@{
    start = $false
    grid = [PSCustomObject]@{}
    mode = 0
    click = ""
    userNumbers = [PSCustomObject]@{ "0_0" = 0; "2_0" = 0; "4_0" = 0; "0_2" = 0; "2_2" = 0; "4_2" = 0; "0_4" = 0; "2_4" = 0; "4_4" = 0 }
    userNotes = [PSCustomObject]@{ "0_0" = ""; "2_0" = ""; "4_0" = ""; "0_2" = ""; "2_2" = ""; "4_2" = ""; "0_4" = ""; "2_4" = ""; "4_4" = "" }
    numbers = [PSCustomObject]@{ "0_0" = 0; "2_0" = 0; "4_0" = 0; "0_2" = 0; "2_2" = 0; "4_2" = 0; "0_4" = 0; "2_4" = 0; "4_4" = 0 }
    operands = [PSCustomObject]@{ "1_0" = ""; "3_0" = ""; "0_1" = ""; "2_1" = ""; "4_1" = ""; "1_2" = ""
                                  "3_2" = ""; "0_3" = ""; "2_3" = ""; "4_3" = ""; "1_4" = ""; "3_4" = "" }
    results = [PSCustomObject]@{ "6_0" = 0; "6_2" = 0; "6_4" = 0; "0_6" = 0; "2_6" = 0; "4_6" = 0 }
    equations = [PSCustomObject]@{ "6_0" = "0_0,1_0,2_0,3_0,4_0"; "6_2" = "0_2,1_2,2_2,3_2,4_2"; "6_4" = "0_4,1_4,2_4,3_4,4_4"
                                   "0_6" = "0_0,0_1,0_2,0_3,0_4"; "2_6" = "2_0,2_1,2_2,2_3,2_4"; "4_6" = "4_0,4_1,4_2,4_3,4_4" }
    colors = [PSCustomObject]@{ number = $null; operand = $null; equal = $null; result = $null; hover = $null; input = $null
                                note = $null; noteFont = $null; blank = $null; correct = $null; incorrect = $null }
    infoLabel1 = [System.Windows.Forms.Label]::new()
    infoLabel2 = [System.Windows.Forms.Label]::new()
    infoLabel3 = [System.Windows.Forms.Label]::new()
}
 
$form = [System.Windows.Forms.Form]::new()
$form.Text = "CrossMath"
 
$mainPanel = [System.Windows.Forms.FlowLayoutPanel]::new()
$mainPanel.Padding = [System.Windows.Forms.Padding]::new( 5, 5, 5, 5 )
$mainPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$mainPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$form.Controls.Add( $mainPanel ) | Out-Null
 
$outerPanelGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$middlePanelGrid = [System.Windows.Forms.FlowLayoutPanel]::new()
$middlePanelGrid.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$innerPanelGrid = [System.Windows.Forms.TableLayoutPanel]::new()
$innerPanelGrid.RowCount = 7
$innerPanelGrid.ColumnCount = 7
$gameMaster.infoLabel1.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel1.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel1.Padding = [System.Windows.Forms.Padding]::new( 0 )
$gameMaster.infoLabel1.Margin = [System.Windows.Forms.Padding]::new( 0 )
$gameMaster.infoLabel1.Dock = [System.Windows.Forms.DockStyle]::Fill
$gameMaster.infoLabel1.Text = "Equations are calculated left to right and top to bottom."
$gameMaster.infoLabel2.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel2.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel2.Padding = [System.Windows.Forms.Padding]::new( 0 )
$gameMaster.infoLabel2.Margin = [System.Windows.Forms.Padding]::new( 0 )
$gameMaster.infoLabel2.Dock = [System.Windows.Forms.DockStyle]::Fill
$gameMaster.infoLabel2.Text = "Using the numbers 1-9, place each number once"
$gameMaster.infoLabel3.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$gameMaster.infoLabel3.Font = [System.Drawing.Font]::new( "Verdana", 14 )
$gameMaster.infoLabel3.Padding = [System.Windows.Forms.Padding]::new( 0 )
$gameMaster.infoLabel3.Margin = [System.Windows.Forms.Padding]::new( 0 )
$gameMaster.infoLabel3.Dock = [System.Windows.Forms.DockStyle]::Fill
$gameMaster.infoLabel3.Text = "so that all 6 equations will be correct"
$outerPanelGrid.Controls.Add( $middlePanelGrid ) | Out-Null
$middlePanelGrid.Controls.Add( $innerPanelGrid ) | Out-Null
$mainPanel.Controls.Add( $outerPanelGrid ) | Out-Null
$mainPanel.Controls.Add( $gameMaster.infoLabel1 ) | Out-Null
$mainPanel.Controls.Add( $gameMaster.infoLabel2 ) | Out-Null
$mainPanel.Controls.Add( $gameMaster.infoLabel3 ) | Out-Null
 
while ( $gameMaster.mode -eq 0 ) {
    $gameMaster.mode = Get-UserInput -Message "Choose difficulty; 1 = Easy; 2 = Medium; 3 = Hard;"
    if ( $gameMaster.mode -eq "cancel" ) {
        return
    }
    if ( $gameMaster.mode -notmatch '[123]' ) {
        $gameMaster.mode = 0
    }
}
 
$gameMaster.start = $true
 
Set-Colors -GameMaster $gameMaster
 
New-CrossMath -GameMaster $gameMaster
 
foreach ( $row in 0..6 ) {
    foreach ( $column in 0..6 ) {
        Try {
            $gameMaster.grid | Add-Member -MemberType NoteProperty -Name "$( $column )_$($row )" -Value $([System.Windows.Forms.Label]::new()) -ErrorAction Stop
        } Catch {
            $gameMaster.grid.psobject.properties.remove( "$( $column )_$( $row )" )
            $gameMaster.grid | Add-Member -MemberType NoteProperty -Name "$( $column )_$( $row )" -Value $([System.Windows.Forms.Label]::new())
        }
        $gameMaster.grid."$( $column )_$( $row )".TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $gameMaster.grid."$( $column )_$( $row )".Font = [System.Drawing.Font]::new( "Verdana", 14 )
        $gameMaster.grid."$( $column )_$( $row )".Size = [System.Drawing.Size]::new( 75, 75 )
        $gameMaster.grid."$( $column )_$( $row )".Padding = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid."$( $column )_$( $row )".Margin = [System.Windows.Forms.Padding]::new( 0 )
        $gameMaster.grid."$( $column )_$( $row )".Dock = [System.Windows.Forms.DockStyle]::Fill
        $gameMaster.grid."$( $column )_$( $row )".MaximumSize = [System.Drawing.Size]::new( 75, 75 )
 
        if (( $column -eq 6 ) -or ( $row -eq 6 )) {
            # Results
            if (( $column -eq 6 ) -and (( $row -eq 0 ) -or ( $row -eq 2) -or ( $row -eq 4))) {
                $gameMaster.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.result
                $gameMaster.grid."$( $column )_$( $row )".Text = $gameMaster.results."$( $column )_$( $row )"
                $gameMaster.grid."$( $column )_$( $row )".Name = "r_$( $column )_$( $row )"
            } elseif (( $row -eq 6 ) -and (( $column -eq 0 ) -or ( $column -eq 2) -or ( $column -eq 4))) {
                $gameMaster.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.result
                $gameMaster.grid."$( $column )_$( $row )".Text = $gameMaster.results."$( $column )_$( $row )"
                $gameMaster.grid."$( $column )_$( $row )".Name = "r_$( $column )_$( $row )"
            } else {
                $gameMaster.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.blank
                $gameMaster.grid."$( $column )_$( $row )".Name = "b_$( $column )_$( $row )"
            }
        } elseif (( $column -eq 5 ) -or ( $row -eq 5 )) {
            # Equals
            if (( $column -eq 5 ) -and (( $row -eq 0 ) -or ( $row -eq 2) -or ( $row -eq 4))) {
                $gameMaster.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.equal
                $gameMaster.grid."$( $column )_$( $row )".Text = "="
                $gameMaster.grid."$( $column )_$( $row )".Name = "e_$( $column )_$( $row )"
            } elseif (( $row -eq 5 ) -and (( $column -eq 0 ) -or ( $column -eq 2) -or ( $column -eq 4))) {
                $gameMaster.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.equal
                $gameMaster.grid."$( $column )_$( $row )".Text = "="
                $gameMaster.grid."$( $column )_$( $row )".Name = "e_$( $column )_$( $row )"
            } else {
                $gameMaster.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.blank
                $gameMaster.grid."$( $column )_$( $row )".Name = "b_$( $column )_$( $row )"
            }
        } elseif ((( $column % 2 ) -ne 0 ) -or (( $row % 2 ) -ne 0 )) {
            # Operands
            if ((( $column % 2 ) -ne 0 ) -and (( $row % 2 ) -ne 0 )) {
                $gameMaster.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.blank
                $gameMaster.grid."$( $column )_$( $row )".Name = "b_$( $column )_$( $row )"
            } else {
                $gameMaster.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.operand
                $gameMaster.grid."$( $column )_$( $row )".Text = $gameMaster.operands."$( $column )_$( $row )"
                $gameMaster.grid."$( $column )_$( $row )".Name = "o_$( $column )_$( $row )"
            }
        } else {
            # Numbers
            $gameMaster.grid."$( $column )_$( $row )".BackColor = $gameMaster.colors.number
            $gameMaster.grid."$( $column )_$( $row )".Text = ""
            $gameMaster.grid."$( $column )_$( $row )".Name = "n_$( $column )_$( $row )"
        }
 
        $gameMaster.grid."$( $column )_$( $row )".Add_MouseClick({
            param($sender, $event)
            if ( $event.button -eq "Left" ) {
                New-MouseClick -GameMaster $gameMaster -Name $this.Name -Left
            } elseif ( $event.button -eq "Right" ) {
                New-MouseClick -GameMaster $gameMaster -Name $this.Name -Right
            }
        })
        $gameMaster.grid."$( $column )_$( $row )".Add_MouseEnter({
            New-MouseEnter -GameMaster $gameMaster -Name $this.Name
        })
        $gameMaster.grid."$( $column )_$( $row )".Add_MouseLeave({
            New-MouseLeave -GameMaster $gameMaster -Name $this.Name
        })
 
        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new( $column, $row )
        $innerPanelGrid.SetCellPosition( $gameMaster.grid."$( $column )_$( $row )", $cellPosition )
        $innerPanelGrid.Controls.Add( $gameMaster.grid."$( $column )_$( $row )" )
    }
}
 
Set-KeyDown -GameMaster $gameMaster -Control $form
Set-AutoSize -Control $form
 
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.ShowDialog() | Out-Null
