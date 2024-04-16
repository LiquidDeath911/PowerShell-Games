Clear-Host
 
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
 
Function AutoSize {
    Param(
        $Control
    )
 
    foreach ($prop in  $Control.PSObject.Properties) {
        if ($prop.Name -eq "AutoSizeMode") {
            $Control.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
        } elseif ($prop.Name -eq "AutoSize") {
            $Control.AutoSize = $true
        }
    }
 
    Return
} # End AutoSize Function
 
Function CalculateGuessCount {
   
    $maxGuesses = 6
   
    $maxGuesses
    return
} # End CalculateGuessCount Function
 
Function ConvertFromNum {
   
    param(
        $num
    )
 
    $convert = @{
        three = 3
        four = 4
        five = 5
        six = 6
        seven = 7
        eight = 8
        nine = 9
        ten = 10
    }
 
    $keys = $convert.Keys
    foreach ($key in $keys) {
        if ($num -eq $convert.$key) {
            $text = "$key"
        }
    }
 
    $text
    return
} # End ConvertFromNum Function
 
 
Function ColorSetup {
   
    $Global:letterBlank = [System.Drawing.Color]::White
    $Global:letterCorrect = [System.Drawing.Color]::Green
    $Global:letterPartial = [System.Drawing.Color]::Yellow
    $Global:letterIncorrect = [System.Drawing.Color]::DarkGray
    $Global:letterSelected = [System.Drawing.Color]::LightGray
    $null = $Global:letterBlank
    $null = $Global:letterSelected
    $null = $Global:letterCorrect
    $null = $Global:letterPartial
    $null = $Global:letterIncorrect
 
    return
} # End ColorSetup Function
 
Function SuspendLayout {
 
    $Global:form.SuspendLayout()
    $Global:masterLayout.SuspendLayout()
    $Global:wordTableLayoutInner.SuspendLayout()
    return
} # End SuspendLayout Function
 
Function ResumeLayout {
 
    $Global:form.ResumeLayout()
    $Global:masterLayout.ResumeLayout()
    $Global:wordTableLayoutInner.ResumeLayout()
    return
} # End ResumeLayout Function
 
Function GetInput {
 
    $userInput = ""
 
    foreach ($column in 0..($Global:wordLength - 1)) {
        $userInput = "$($userInput)$($(Get-Variable -Name "var_$($column)_$($Global:guess)" -Scope Global -ValueOnly).Text.ToUpper())"
    }
   
    $userInput
    return
} # End GetInput Function
 
Function ValidateWord {
 
    # Variables
    $valid = $false
    $userInput = GetInput
 
    foreach ($item in $Global:wordListByLengthPossible) {
        if ($userInput.ToUpper() -eq $item.ToUpper()) {
            $valid = $true
        }
    }
 
    $valid
    return
} # End ValidateWord Function
 
Function ModifyWordList {
   
    $Global:wordListByLength = [System.Collections.ArrayList]::new()
    foreach ($item in $Global:wordList) {
        if ($item.Length -eq $Global:wordLength) {
            $null = $Global:wordListByLength.Add($item)
        }
    }
 
    $Global:wordListByLengthPossible = [System.Collections.ArrayList]::new()
    foreach ($item in $Global:wordListPossible) {
        if ($item.Length -eq $Global:wordLength) {
            $null = $Global:wordListByLengthPossible.Add($item)
        }
    }
 
    return
} # End ModifyWordList Function
 
Function NewWord {
 
    $Global:word = $null
    While ($null -eq $Global:word) {
        $Global:word = Get-Random -InputObject $Global:wordListByLength
        if ($Global:word.Length -ne $Global:wordLength) {
            $Global:word = $null
        }
    }
    $Global:word = $Global:word.ToUpper()
 
    return
} # End NewWord Function
 
Function KeyboardColor {
   
    param(
        $letter,
        $color
    )
 
    $letter = $letter.ToString()
 
    if ($Global:keyboardTop.Contains($letter)) {
        if (($color -eq $Global:letterCorrect) -or ($color -eq $Global:letterBlank)) {
            $(Get-Variable -Name "keyboard_top_$letter" -Scope Global -ValueOnly).BackColor = $color
        } elseif (($color -eq $Global:letterPartial) -or ($color -eq $Global:letterIncorrect)) {
            if ($(Get-Variable -Name "keyboard_top_$letter" -Scope Global -ValueOnly).BackColor -eq $Global:letterBlank) {
                $(Get-Variable -Name "keyboard_top_$letter" -Scope Global -ValueOnly).BackColor = $color
            }
        }
    } elseif ($Global:keyboardMiddle.Contains($letter)) {
        if (($color -eq $Global:letterCorrect) -or ($color -eq $Global:letterBlank)) {
            $(Get-Variable -Name "keyboard_middle_$letter" -Scope Global -ValueOnly).BackColor = $color
        } elseif (($color -eq $Global:letterPartial) -or ($color -eq $Global:letterIncorrect)) {
            if ($(Get-Variable -Name "keyboard_middle_$letter" -Scope Global -ValueOnly).BackColor -eq $Global:letterBlank) {
                $(Get-Variable -Name "keyboard_middle_$letter" -Scope Global -ValueOnly).BackColor = $color
            }
        }
    } elseif ($Global:keyboardBottom.Contains($letter)) {
        if (($color -eq $Global:letterCorrect) -or ($color -eq $Global:letterBlank)) {
            $(Get-Variable -Name "keyboard_bottom_$letter" -Scope Global -ValueOnly).BackColor = $color
        } elseif (($color -eq $Global:letterPartial) -or ($color -eq $Global:letterIncorrect)) {
            if ($(Get-Variable -Name "keyboard_bottom_$letter" -Scope Global -ValueOnly).BackColor -eq $Global:letterBlank) {
                $(Get-Variable -Name "keyboard_bottom_$letter" -Scope Global -ValueOnly).BackColor = $color
            }
        }
    }
 
    return
} # End KeyboardColor Function
 
function NewGame {
 
    $scoreObject = [PSCustomObject]@{
        Length3TotalGames = 0; Length3Wins = 0; Length3Losses = 0; Length3GuessesLeftOnWin = 0; Length3AvgGuessesLeftOnWin = 0
        Length4TotalGames = 0; Length4Wins = 0; Length4Losses = 0; Length4GuessesLeftOnWin = 0; Length4AvgGuessesLeftOnWin = 0
        Length5TotalGames = 0; Length5Wins = 0; Length5Losses = 0; Length5GuessesLeftOnWin = 0; Length5AvgGuessesLeftOnWin = 0
        Length6TotalGames = 0; Length6Wins = 0; Length6Losses = 0; Length6GuessesLeftOnWin = 0; Length6AvgGuessesLeftOnWin = 0
        Length7TotalGames = 0; Length7Wins = 0; Length7Losses = 0; Length7GuessesLeftOnWin = 0; Length7AvgGuessesLeftOnWin = 0
        Length8TotalGames = 0; Length8Wins = 0; Length8Losses = 0; Length8GuessesLeftOnWin = 0; Length8AvgGuessesLeftOnWin = 0
        Length9TotalGames = 0; Length9Wins = 0; Length9Losses = 0; Length9GuessesLeftOnWin = 0; Length9AvgGuessesLeftOnWin = 0
        Length10TotalGames = 0; Length10Wins = 0; Length10Losses = 0; Length10GuessesLeftOnWin = 0; Length10AvgGuessesLeftOnWin = 0
    }
 
    SuspendLayout
    $visibleCount = 0
    foreach ($control in $Global:wordTableLayoutInner.Controls) {
        $row = $Global:wordTableLayoutInner.GetRow($control)
        $column = $Global:wordTableLayoutInner.GetColumn($control)
        if ($(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Visible) {
            $visibleCount++
        }
    }
 
    if (([int]$Global:wordLength * [int]$Global:guessCount) -lt $visibleCount) {
        foreach ($control in $Global:wordTableLayoutInner.Controls) {
            $row = $Global:wordTableLayoutInner.GetRow($control)
            $column = $Global:wordTableLayoutInner.GetColumn($control)
            if (([int]$Global:wordLength -le [int]$column) -or ([int]$Global:guessCount -le [int]$row)) {
                if ($(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Visible) {
                    $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Visible = $false
                }
            }
        }
        $Global:wordTableLayoutInner.ColumnCount = $Global:wordLength
    } elseif (([int]$Global:wordLength * [int]$Global:guessCount) -gt $visibleCount) {
        $Global:wordTableLayoutInner.ColumnCount = $Global:wordLength
        foreach ($control in $Global:wordTableLayoutInner.Controls) {
            $row = $Global:wordTableLayoutInner.GetRow($control)
            $column = $Global:wordTableLayoutInner.GetColumn($control)
            if (([int]$Global:wordLength -gt [int]$column) -and ([int]$Global:guessCount -gt [int]$row)) {
                if (-not $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Visible) {
                    $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Visible = $true
                }
            }
        }
    }
 
    foreach ($row in 0..($Global:guessCount - 1)) {
        foreach ($column in 0..($Global:wordLength - 1)) {
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Text = ""
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).BackColor = $Global:letterBlank
        }
    }
 
    foreach ($letter in $Global:keyboardTop) {
        KeyboardColor $letter $Global:letterBlank
    }
 
    foreach ($letter in $Global:keyboardMiddle) {
        KeyboardColor $letter $Global:letterBlank
    }
 
    foreach ($letter in $Global:keyboardBottom) {
        KeyboardColor $letter $Global:letterBlank
    }
 
    ResumeLayout
 
    $Global:waitForNewGame = $false
    $null = $Global:waitForNewGame
 
    $Global:winLabel.Visible = $false
    $Global:loseLabel1.Visible = $false
    $Global:loseLabel2.Visible = $false
    $Global:guess = 0
    NewWord
    $Global:loseLabel2.Text = "The word was $Global:word"
    $Global:selectedColumn = 0
    $null = $(Get-Variable -Name "var_$($Global:selectedColumn)_$($Global:guess)" -Scope Global -ValueOnly).Focus()
   
    return
} # End NewGame Function
 
Function LengthChange {
 
    ModifyWordList
 
    $Global:converted = ConvertFromNum $Global:wordLength
    $null = $Global:converted
    NewGame
   
} # End LengthChange Function
 
Function AddLetter {
 
    param(
        $letter,
        $column = $Global:selectedColumn
    )
   
    if ($Global:waitForNewGame) {
        return
    }
 
    SuspendLayout
    if ($letter -eq "") {
        if ($(Get-Variable -Name "var_$($column)_$($Global:guess)" -Scope Global -ValueOnly).Text -eq "") {
            if ($Global:selectedColumn -gt 0) {
                $Global:selectedColumn--
                $column--
            }
            $(Get-Variable -Name "var_$($column)_$($Global:guess)" -Scope Global -ValueOnly).Text = $letter
        } else {
            $(Get-Variable -Name "var_$($column)_$($Global:guess)" -Scope Global -ValueOnly).Text = $letter
        }
        $null = $(Get-Variable -Name "var_$($column)_$($Global:guess)" -Scope Global -ValueOnly).Focus()
    } else {
        $(Get-Variable -Name "var_$($column)_$($Global:guess)" -Scope Global -ValueOnly).Text = $letter
        if ($Global:selectedColumn -lt ($Global:wordLength - 1)) {
            $Global:selectedColumn++
            $column++
        }
        $null = $(Get-Variable -Name "var_$($column)_$($Global:guess)" -Scope Global -ValueOnly).Focus()
    }
    ResumeLayout
 
    return
} # End AddLetter Function
 
Function ColorCheck {
   
    param(
        $type,
        $newColor
    )
 
    $notUsed = $true
 
    If ($type -eq "correct") {
        If ($newColor -eq $Global:letterPartial) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterIncorrect) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterSelected) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterBlank) {
            $notUsed = $false
        }
    } ElseIf ($type -eq "partial") {
        If ($newColor -eq $Global:letterCorrect) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterIncorrect) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterSelected) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterBlank) {
            $notUsed = $false
        }
    } ElseIf ($type -eq "incorrect") {
        If ($newColor -eq $Global:letterCorrect) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterPartial) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterSelected) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterBlank) {
            $notUsed = $false
        }
    } ElseIf ($type -eq "selected") {
        If ($newColor -eq $Global:letterCorrect) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterPartial) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterIncorrect) {
            $notUsed = $false
        } ElseIf ($newColor -eq $Global:letterBlank) {
            $notUsed = $false
        }
    }
 
    $notUsed
    return
} # End ColorCheck Function
 
Function ColorChange {
 
    param(
        $oldColor,
        $newColor,
        $control = $Global:form
    )
   
    $currentColor = $control.BackColor
    if ($currentColor -eq $oldColor) {
        $control.BackColor = $newColor
    }
    if ($control.Controls.Count -ge 1) {
        foreach ($subControl in $control.Controls) {
            ColorChange $oldColor $newColor $subControl
        }
    }
 
    return
} # End ColorChange Function
 
Function VariableSetup {
 
    $maxWordLength = 10
    $maxGuessCount = 6
    $Global:dropDownItems = [System.Windows.Forms.ToolStripDropDown]::new()
    $Global:colorDropDownItems = [System.Windows.Forms.ToolStripDropDown]::new()
    foreach ($row in 0..($maxGuessCount - 1)) {
        foreach ($column in 0..($maxWordLength - 1)) {
            Try {
                New-Variable -Name "var_$($column)_$($row)" -Value $([System.Windows.Forms.Label]::new()) -Scope Global -ErrorAction Stop
            } Catch {
                Remove-Variable -Name "var_$($column)_$($row)" -Scope Global -Force
                New-Variable -Name "var_$($column)_$($row)" -Value $([System.Windows.Forms.Label]::new()) -Scope Global
            }
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Font = [System.Drawing.Font]::new("Verdana",14)
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Size = [System.Drawing.Size]::new(50,50)
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Padding = [System.Windows.Forms.Padding]::new(0)
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Margin = [System.Windows.Forms.Padding]::new(0)
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Dock = [System.Windows.Forms.DockStyle]::Fill
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Text = ""
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).BackColor = $Global:letterBlank
            $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new($column,$row)
            $Global:wordTableLayoutInner.SetCellPosition($(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly), $cellPosition)
            $Global:wordTableLayoutInner.Controls.Add($(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly))
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Add_Click({
                $thisRow = $Global:wordTableLayoutInner.GetRow($this)
                $thisColumn = $Global:wordTableLayoutInner.GetColumn($this)
                if ($thisRow -eq $Global:guess) {
                    $(Get-Variable -Name "var_$($thisColumn)_$($thisRow)" -Scope Global -ValueOnly).BackColor = $Global:letterSelected
                    $Global:selectedColumn = $thisColumn
                    $null = $Global:selectedColumn
                    $this.Focus()
                }
            })
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Add_GotFocus({
                $thisRow = $Global:wordTableLayoutInner.GetRow($this)
                $thisColumn = $Global:wordTableLayoutInner.GetColumn($this)
                if ($thisRow -eq $Global:guess) {
                    $(Get-Variable -Name "var_$($thisColumn)_$($thisRow)" -Scope Global -ValueOnly).BackColor = $Global:letterSelected
                }
            })
            $(Get-Variable -Name "var_$($column)_$($row)" -Scope Global -ValueOnly).Add_LostFocus({
                $thisRow = $Global:wordTableLayoutInner.GetRow($this)
                $thisColumn = $Global:wordTableLayoutInner.GetColumn($this)
                if ($thisRow -eq $Global:guess) {
                    $(Get-Variable -Name "var_$($thisColumn)_$($thisRow)" -Scope Global -ValueOnly).BackColor = $Global:letterBlank
                }
            })
        }
    }
 
    foreach ($num in 0..9) {
        Try {
            New-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Value $([System.Windows.Forms.Label]::new()) -Scope Global -ErrorAction Stop
        } Catch {
            Remove-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -Force
            New-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Value $([System.Windows.Forms.Label]::new()) -Scope Global
        }
        $(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly).Text = $Global:keyboardTop[$num]
        $(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly).BackColor = $Global:letterBlank
        $(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly).Font = [System.Drawing.Font]::new("Verdana",8)
        $(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly).Size = [System.Drawing.Size]::new(25,25)
        $(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly).Padding = [System.Windows.Forms.Padding]::new(0)
        $(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly).Margin = [System.Windows.Forms.Padding]::new(0)
        $(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly).Dock = [System.Windows.Forms.DockStyle]::Fill
        $(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly).TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly).Add_Click({
            AddLetter $this.Text
        })
        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new($num,0)
        $Global:keyboardTopTableLayout.SetCellPosition($(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly), $cellPosition)
        $Global:keyboardTopTableLayout.Controls.Add($(Get-Variable -Name "keyboard_top_$($Global:keyboardTop[$num])" -Scope Global -ValueOnly))
    }
 
    foreach ($num in 0..8) {
        Try {
            New-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Value $([System.Windows.Forms.Label]::new()) -Scope Global -ErrorAction Stop
        } Catch {
            Remove-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -Force
            New-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Value $([System.Windows.Forms.Label]::new()) -Scope Global
        }
        $(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly).Text = $Global:keyboardMiddle[$num]
        $(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly).BackColor = $Global:letterBlank
        $(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly).Font = [System.Drawing.Font]::new("Verdana",8)
        $(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly).Size = [System.Drawing.Size]::new(25,25)
        $(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly).Padding = [System.Windows.Forms.Padding]::new(0)
        $(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly).Margin = [System.Windows.Forms.Padding]::new(0)
        $(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly).Dock = [System.Windows.Forms.DockStyle]::Fill
        $(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly).TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly).Add_Click({
            AddLetter $this.Text
        })
        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new($num,0)
        $Global:keyboardMiddleTableLayout.SetCellPosition($(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly), $cellPosition)
        $Global:keyboardMiddleTableLayout.Controls.Add($(Get-Variable -Name "keyboard_middle_$($Global:keyboardMiddle[$num])" -Scope Global -ValueOnly))
    }
 
    foreach ($num in 0..6) {
        Try {
            New-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Value $([System.Windows.Forms.Label]::new()) -Scope Global -ErrorAction Stop
        } Catch {
            Remove-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -Force
            New-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Value $([System.Windows.Forms.Label]::new()) -Scope Global
        }
        $(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly).Text = $Global:keyboardBottom[$num]
        $(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly).BackColor = $Global:letterBlank
        $(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly).Font = [System.Drawing.Font]::new("Verdana",8)
        $(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly).Size = [System.Drawing.Size]::new(25,25)
        $(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly).Padding = [System.Windows.Forms.Padding]::new(0)
        $(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly).Margin = [System.Windows.Forms.Padding]::new(0)
        $(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly).Dock = [System.Windows.Forms.DockStyle]::Fill
        $(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly).TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly).Add_Click({
            AddLetter $this.Text
        })
        $cellPosition = [System.Windows.Forms.TableLayoutPanelCellPosition]::new($num,0)
        $Global:keyboardBottomTableLayout.SetCellPosition($(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly), $cellPosition)
        $Global:keyboardBottomTableLayout.Controls.Add($(Get-Variable -Name "keyboard_bottom_$($Global:keyboardBottom[$num])" -Scope Global -ValueOnly))
    }
 
    foreach ($num in 3..10) {
        Try {
            New-Variable -Name "dropdown_$($num)" -Value $([System.Windows.Forms.ToolStripButton]::new()) -Scope Global -ErrorAction Stop
        } Catch {
            Remove-Variable -Name "dropdown_$($num)" -Scope Global -Force
            New-Variable -Name "dropdown_$($num)" -Value $([System.Windows.Forms.ToolStripButton]::new()) -Scope Global
        }
        $(Get-Variable -Name "dropdown_$($num)" -Scope Global -ValueOnly).Text = $num
        $(Get-Variable -Name "dropdown_$($num)" -Scope Global -ValueOnly).Add_Click({
            $Global:wordLength = $this.Text
            $null = $Global:wordLength
            LengthChange
        })
        $null = $Global:dropDownItems.Items.Add($(Get-Variable -Name "dropdown_$($num)" -Scope Global -ValueOnly))
    }
 
    return
} # End VariableSetup Function
 
Function MarkLetters {
 
    param(
        $tempWord = $Global:word,
        $tempInput = (GetInput)
    )
   
    $tempWord = $tempWord.ToUpper().ToCharArray()
    $tempInput = $tempInput.ToCharArray()
 
    foreach ($column in 0..($Global:wordLength - 1)) {
        if ($tempWord[$column] -eq $tempInput[$column]) {
            $(Get-Variable -Name "var_$($column)_$($Global:guess)" -Scope Global -ValueOnly).BackColor = $Global:letterCorrect
            KeyboardColor $tempInput[$column] $Global:letterCorrect
            $tempInput[$column] = "-"
            $tempWord[$column] = "-"
        }
    }
    foreach ($column in 0..($Global:wordLength - 1)) {
        if (($tempWord -match $tempInput[$column]) -and ($tempInput[$column] -ne "-")) {
            $(Get-Variable -Name "var_$($column)_$($Global:guess)" -Scope Global -ValueOnly).BackColor = $Global:letterPartial
            KeyboardColor $tempInput[$column] $Global:letterPartial
            $tempWord[$tempWord.IndexOf($tempInput[$column])] = "-"
            $tempInput[$column] = "-"
        }
    }
    foreach ($column in 0..($Global:wordLength - 1)) {
        if ($tempInput[$column] -ne "-") {
            $(Get-Variable -Name "var_$($column)_$($Global:guess)" -Scope Global -ValueOnly).BackColor = $Global:letterIncorrect
            KeyboardColor $tempInput[$column] $Global:letterIncorrect
            $tempInput[$column] = "-"
        }
    }
    ResumeLayout
 
    return
} # End MarkLetters Function
 
Function Submit {
   
    $userInput = GetInput
 
    if (($userInput.Length -ne $Global:wordLength) -or (-not (ValidateWord))) {
        $Global:invalidWordLabel.Visible = $true
        return
    }
 
    MarkLetters
    $Global:guess++
 
    if ($Global:word -eq $userInput) {
        $Global:winLabel.Visible = $true
        $Global:waitForNewGame = $true
        $null = $Global:waitForNewGame
 
        $length = [int]$Global:wordLength
 
        $Global:guess = -1
 
    } elseif ($Global:guess -eq $Global:guessCount) {
        $Global:loseLabel1.Visible = $true
        $Global:loseLabel2.Visible = $true
        $Global:waitForNewGame = $true
        $null = $Global:waitForNewGame
 
        $Global:guess = 0
 
    } else {
        $Global:selectedColumn = 0
        $null = $(Get-Variable -Name "var_$($Global:selectedColumn)_$($Global:guess)" -Scope Global -ValueOnly).Focus()
    }
   
    return
} # End Submit Function
 
Function AddKeyDown {
   
    param(
        $control
    )
 
    $control.Add_KeyDown({
        if ((("$($_.KeyCode)").Length -eq 1) -and ($_.KeyCode -match '[A-Z]')) {
            AddLetter $_.KeyCode
        } elseif ($_.KeyCode -eq "Return") {
            if ($Global:waitForNewGame) {
                NewGame
            } else {
                Submit
            }
        } elseif ($_.KeyCode -eq "Back") {
            AddLetter ""
        } elseif ($_.KeyCode -eq "Space") {
            if ($Global:selectedColumn -lt ($Global:wordLength - 1)) {
                $Global:selectedColumn++
            }
            $null = $(Get-Variable -Name "var_$($Global:selectedColumn)_$($Global:guess)" -Scope Global -ValueOnly).Focus()
        } elseif ($_.KeyCode -eq "Right") {
            if ($Global:selectedColumn -lt ($Global:wordLength - 1)) {
                $Global:selectedColumn++
            }
            $null = $(Get-Variable -Name "var_$($Global:selectedColumn)_$($Global:guess)" -Scope Global -ValueOnly).Focus()
        } elseif ($_.KeyCode -eq "Up") {
            if ($Global:selectedColumn -lt ($Global:wordLength - 1)) {
                $Global:selectedColumn++
            }
            $null = $(Get-Variable -Name "var_$($Global:selectedColumn)_$($Global:guess)" -Scope Global -ValueOnly).Focus()
        } elseif ($_.KeyCode -eq "Left") {
            if ($Global:selectedColumn -gt 0) {
                $Global:selectedColumn--
            }
            $null = $(Get-Variable -Name "var_$($Global:selectedColumn)_$($Global:guess)" -Scope Global -ValueOnly).Focus()
        } elseif ($_.KeyCode -eq "Down") {
            if ($Global:selectedColumn -gt 0) {
                $Global:selectedColumn--
            }
            $null = $(Get-Variable -Name "var_$($Global:selectedColumn)_$($Global:guess)" -Scope Global -ValueOnly).Focus()
        }
    })
    if ($control.Controls.Count -ge 1) {
        foreach ($subControl in $control.Controls) {
            AddKeyDown $subControl
        }
    }
 
    return
} # End AddKeyDown Function
 
Function Setup {
   
    $Global:wordLength = 5
    $Global:wordList = Get-Content -Path .\PossibleWords.txt
    $Global:wordListPossible = Get-Content -Path .\PossibleGuesses.txt
    $Global:wordTableLayoutInner = [System.Windows.Forms.TableLayoutPanel]::new()
    $Global:guessCount = CalculateGuessCount
    $Global:guess = 0
    $Global:form = [System.Windows.Forms.Form]::new()
    $Global:waitForNewGame = $false
    $Global:winLabel = [System.Windows.Forms.Label]::new()
    $Global:loseLabel1 = [System.Windows.Forms.Label]::new()
    $Global:loseLabel2 = [System.Windows.Forms.Label]::new()
    $Global:invalidWordLabel = [System.Windows.Forms.Label]::new()
    $Global:masterLayout = [System.Windows.Forms.FlowLayoutPanel]::new()
    $Global:keyboardTopTableLayout = [System.Windows.Forms.TableLayoutPanel]::new()
    $Global:keyboardMiddleTableLayout = [System.Windows.Forms.TableLayoutPanel]::new()
    $Global:keyboardBottomTableLayout = [System.Windows.Forms.TableLayoutPanel]::new()
    $Global:selectedColumn = 0
    $Global:scoreForm = [System.Windows.Forms.Form]::new()
    $Global:scoreTableLayout = [System.Windows.Forms.TableLayoutPanel]::new()
    $Global:keyboardTop = "Q","W","E","R","T","Y","U","I","O","P"
    $Global:keyboardMiddle = "A","S","D","F","G","H","J","K","L"
    $Global:keyboardBottom = "Z","X","C","V","B","N","M"
    $Global:converted = ConvertFromNum $Global:wordLength
    $Global:colorPicker = [System.Windows.Forms.ColorDialog]::new()
 
    ColorSetup
    VariableSetup
    ModifyWordList
    NewGame
   
 
    return
} # End Setup Function
 
Setup
 
AutoSize $Global:form
$Global:form.Text = "Jacobo's Wordle"
$toolStrip = [System.Windows.Forms.ToolStrip]::new()
AutoSize $toolStrip
$toolStrip.Dock = [System.Windows.Forms.DockStyle]::Top
$toolStrip.GripStyle = [System.Windows.Forms.ToolStripGripStyle]::Hidden
 
$Global:wordLengthDropDownButton = [System.Windows.Forms.ToolStripDropDownButton]::new()
$Global:wordLengthDropDownButton.Text = "Length"
AutoSize $Global:wordLengthDropDownButton
$Global:wordLengthDropDownButton.ShowDropDownArrow = $true
$Global:wordLengthDropDownButton.Padding = [System.Windows.Forms.Padding]::new(5,0,0,0)
 
$Global:wordLengthDropDownButton.DropDown = $Global:dropDownItems
$null = $toolStrip.Items.Add($Global:wordLengthDropDownButton)
$null = $toolStrip.Items.Add([System.Windows.Forms.ToolStripSeparator]::new())
 
AutoSize $Global:masterLayout
$Global:masterLayout.Padding = [System.Windows.Forms.Padding]::new(5,$toolStrip.Height,5,5)
$Global:masterLayout.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$Global:masterLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
 
$Global:wordTableLayoutOuter = [System.Windows.Forms.TableLayoutPanel]::new()
AutoSize $Global:wordTableLayoutOuter
$Global:wordTableLayoutOuter.Dock = [System.Windows.Forms.DockStyle]::Bottom
$Global:wordTableLayoutOuter.ColumnCount = 1
$Global:wordTableLayoutOuter.RowCount = 1
 
$wordFlowLayout = [System.Windows.Forms.FlowLayoutPanel]::new()
AutoSize $wordFlowLayout
$wordFlowLayout.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
 
AutoSize $Global:wordTableLayoutInner
$Global:wordTableLayoutInner.ColumnCount = $Global:wordLength
$Global:wordTableLayoutInner.RowCount = $Global:guessCount
$Global:wordTableLayoutInner.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
 
$null = $Global:wordTableLayoutOuter.Controls.Add($wordFlowLayout)
$null = $wordFlowLayout.Controls.Add($Global:wordTableLayoutInner)
 
$colorLayoutOuter = [System.Windows.Forms.TableLayoutPanel]::new()
AutoSize $colorLayoutOuter
$colorLayoutOuter.Dock = [System.Windows.Forms.DockStyle]::Bottom
$colorLayoutOuter.ColumnCount = 1
$colorLayoutOuter.RowCount = 1
$colorLayoutOuter.Padding = [System.Windows.Forms.Padding]::new(0)
$colorLayoutOuter.Margin = [System.Windows.Forms.Padding]::new(0)
 
$colorLayoutMiddle = [System.Windows.Forms.FlowLayoutPanel]::new()
AutoSize $colorLayoutMiddle
$colorLayoutMiddle.Padding = [System.Windows.Forms.Padding]::new(0)
$colorLayoutMiddle.Margin = [System.Windows.Forms.Padding]::new(0)
$colorLayoutMiddle.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
 
$colorLayoutInner = [System.Windows.Forms.TableLayoutPanel]::new()
AutoSize $colorLayoutInner
$colorLayoutInner.ColumnCount = 4
$colorLayoutInner.RowCount = 1
$colorLayoutInner.Padding = [System.Windows.Forms.Padding]::new(0)
$colorLayoutInner.Margin = [System.Windows.Forms.Padding]::new(0)
$colorLayoutInner.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
 
$null = $colorLayoutOuter.Controls.Add($colorLayoutMiddle)
$null = $colorLayoutMiddle.Controls.Add($colorLayoutInner)
 
$colorFontSize = 8
$colorWidth = 60
$colorHeight = 15
 
$Global:colorCorrect = [System.Windows.Forms.Label]::new()
$Global:colorCorrect.Size = [System.Drawing.Size]::new($colorWidth,$colorHeight)
$Global:colorCorrect.Text = "Correct"
$Global:colorCorrect.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$Global:colorCorrect.BackColor = $Global:letterCorrect
$Global:colorCorrect.Font = [System.Drawing.Font]::new("Verdana",$colorFontSize)
$Global:colorCorrect.Padding = [System.Windows.Forms.Padding]::new(0)
$Global:colorCorrect.Margin = [System.Windows.Forms.Padding]::new(0)
$Global:colorCorrect.Dock = [System.Windows.Forms.DockStyle]::Fill
$null = $colorLayoutInner.Controls.Add($Global:colorCorrect)
$Global:colorCorrect.Add_Click({
    $Global:colorPicker.ShowDialog()
    $check = ColorCheck "correct" $Global:colorPicker.Color
    If ($check) {
        ColorChange $letterCorrect $Global:colorPicker.Color
        $Global:letterCorrect = $Global:colorPicker.Color
    } Else {
        [System.Windows.Forms.MessageBox]::Show("Color already in use.")
    }
})
 
$Global:colorPartial = [System.Windows.Forms.Label]::new()
$Global:colorPartial.Size = [System.Drawing.Size]::new($colorWidth,$colorHeight)
$Global:colorPartial.Text = "Partial"
$Global:colorPartial.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$Global:colorPartial.BackColor = $Global:letterPartial
$Global:colorPartial.Font = [System.Drawing.Font]::new("Verdana",$colorFontSize)
$Global:colorPartial.Padding = [System.Windows.Forms.Padding]::new(0)
$Global:colorPartial.Margin = [System.Windows.Forms.Padding]::new(0)
$Global:colorPartial.Dock = [System.Windows.Forms.DockStyle]::Fill
$null = $colorLayoutInner.Controls.Add($Global:colorPartial)
$Global:colorPartial.Add_Click({
    $Global:colorPicker.ShowDialog()
    $check = ColorCheck "partial" $Global:colorPicker.Color
    If ($check) {
        ColorChange $letterPartial $Global:colorPicker.Color
        $Global:letterPartial = $Global:colorPicker.Color
    } Else {
        [System.Windows.Forms.MessageBox]::Show("Color already in use.")
    }
})
 
$Global:colorIncorrect = [System.Windows.Forms.Label]::new()
$Global:colorIncorrect.Size = [System.Drawing.Size]::new($colorWidth,$colorHeight)
$Global:colorIncorrect.Text = "Incorrect"
$Global:colorIncorrect.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$Global:colorIncorrect.BackColor = $Global:letterIncorrect
$Global:colorIncorrect.Font = [System.Drawing.Font]::new("Verdana",$colorFontSize)
$Global:colorIncorrect.Padding = [System.Windows.Forms.Padding]::new(0)
$Global:colorIncorrect.Margin = [System.Windows.Forms.Padding]::new(0)
$Global:colorIncorrect.Dock = [System.Windows.Forms.DockStyle]::Fill
$null = $colorLayoutInner.Controls.Add($colorIncorrect)
$Global:colorIncorrect.Add_Click({
    $Global:colorPicker.ShowDialog()
    $check = ColorCheck "incorrect" $Global:colorPicker.Color
    If ($check) {
        ColorChange $letterIncorrect $Global:colorPicker.Color
        $Global:letterIncorrect = $Global:colorPicker.Color
    } Else {
        [System.Windows.Forms.MessageBox]::Show("Color already in use.")
    }
})
 
$Global:colorSelected = [System.Windows.Forms.Label]::new()
$Global:colorSelected.Size = [System.Drawing.Size]::new($colorWidth,$colorHeight)
$Global:colorSelected.Text = "Selected"
$Global:colorSelected.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$Global:colorSelected.BackColor = $Global:letterSelected
$Global:colorSelected.Font = [System.Drawing.Font]::new("Verdana",$colorFontSize)
$Global:colorSelected.Padding = [System.Windows.Forms.Padding]::new(0)
$Global:colorSelected.Margin = [System.Windows.Forms.Padding]::new(0)
$Global:colorSelected.Dock = [System.Windows.Forms.DockStyle]::Fill
$null = $colorLayoutInner.Controls.Add($colorSelected)
$Global:colorSelected.Add_Click({
    $Global:colorPicker.ShowDialog()
    $check = ColorCheck "selected" $Global:colorPicker.Color
    If ($check) {
        ColorChange $letterSelected $Global:colorPicker.Color
        $Global:letterSelected = $Global:colorPicker.Color
    } Else {
        [System.Windows.Forms.MessageBox]::Show("Color already in use.")
    }
})
 
$Global:keyboardTopTableLayout2 = [System.Windows.Forms.TableLayoutPanel]::new()
AutoSize $Global:keyboardTopTableLayout2
$Global:keyboardTopTableLayout2.Dock = [System.Windows.Forms.DockStyle]::Bottom
$Global:keyboardTopTableLayout2.ColumnCount = 1
$Global:keyboardTopTableLayout2.RowCount = 1
 
$Global:keyboardTopFlowLayout = [System.Windows.Forms.FlowLayoutPanel]::new()
AutoSize $Global:keyboardTopFlowLayout
$Global:keyboardTopFlowLayout.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
 
AutoSize $Global:keyboardTopTableLayout
$Global:keyboardTopTableLayout.ColumnCount = 10
$Global:keyboardTopTableLayout.RowCount = 1
$Global:keyboardTopTableLayout.Dock = [System.Windows.Forms.DockStyle]::Bottom
$Global:keyboardTopTableLayout.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
 
$null = $Global:keyboardTopTableLayout2.Controls.Add($Global:keyboardTopFlowLayout)
$null = $Global:keyboardTopFlowLayout.Controls.Add($Global:keyboardTopTableLayout)
 
$Global:keyboardMiddleTableLayout2 = [System.Windows.Forms.TableLayoutPanel]::new()
AutoSize $Global:keyboardMiddleTableLayout2
$Global:keyboardMiddleTableLayout2.Dock = [System.Windows.Forms.DockStyle]::Bottom
$Global:keyboardMiddleTableLayout2.ColumnCount = 1
$Global:keyboardMiddleTableLayout2.RowCount = 1
 
$Global:keyboardMiddleFlowLayout = [System.Windows.Forms.FlowLayoutPanel]::new()
AutoSize $Global:keyboardMiddleFlowLayout
$Global:keyboardMiddleFlowLayout.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
 
AutoSize $Global:keyboardMiddleTableLayout
$Global:keyboardMiddleTableLayout.ColumnCount = 9
$Global:keyboardMiddleTableLayout.RowCount = 1
$Global:keyboardMiddleTableLayout.Dock = [System.Windows.Forms.DockStyle]::Bottom
$Global:keyboardMiddleTableLayout.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
 
$null = $Global:keyboardMiddleTableLayout2.Controls.Add($Global:keyboardMiddleFlowLayout)
$null = $Global:keyboardMiddleFlowLayout.Controls.Add($Global:keyboardMiddleTableLayout)
 
$Global:keyboardBottomTableLayout2 = [System.Windows.Forms.TableLayoutPanel]::new()
AutoSize $Global:keyboardBottomTableLayout2
$Global:keyboardBottomTableLayout2.Dock = [System.Windows.Forms.DockStyle]::Bottom
$Global:keyboardBottomTableLayout2.ColumnCount = 1
$Global:keyboardBottomTableLayout2.RowCount = 1
 
$Global:keyboardBottomFlowLayout = [System.Windows.Forms.FlowLayoutPanel]::new()
AutoSize $Global:keyboardBottomFlowLayout
$Global:keyboardBottomFlowLayout.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
 
AutoSize $Global:keyboardBottomTableLayout
$Global:keyboardBottomTableLayout.ColumnCount = 7
$Global:keyboardBottomTableLayout.RowCount = 1
$Global:keyboardBottomTableLayout.Dock = [System.Windows.Forms.DockStyle]::Bottom
$Global:keyboardBottomTableLayout.CellBorderStyle = [System.Windows.Forms.TableLayoutPanelCellBorderStyle]::Single
 
$submitButton = [System.Windows.Forms.Button]::new()
$submitButton.Text = "->"
$submitButton.Size = [System.Drawing.Size]::new(25,25)
$submitButton.Add_Click({
    if ($Global:waitForNewGame) {
        NewGame
    } else {
        Submit
    }
})
 
$null = $Global:keyboardBottomTableLayout2.Controls.Add($Global:keyboardBottomFlowLayout)
$null = $Global:keyboardBottomFlowLayout.Controls.Add($Global:keyboardBottomTableLayout)
$null = $Global:keyboardBottomFlowLayout.Controls.Add($submitButton)
 
$newGameButton = [System.Windows.Forms.ToolStripButton]::new()
AutoSize $newGameButton
$newGameButton.Text = "New Game"
$newGameButton.Padding = [System.Windows.Forms.Padding]::new(0,0,5,0)
$newGameButton.Add_Click({
    NewGame
})
$null = $toolStrip.Items.Add($newGameButton)
 
$outcomeTableLayout = [System.Windows.Forms.TableLayoutPanel]::new()
AutoSize $outcomeTableLayout
$outcomeTableLayout.Dock = [System.Windows.Forms.DockStyle]::Bottom
$outcomeTableLayout.ColumnCount = 1
$outcomeTableLayout.RowCount = 1
 
$outcomeFlowLayout = [System.Windows.Forms.FlowLayoutPanel]::new()
AutoSize $outcomeFlowLayout
$outcomeFlowLayout.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
 
AutoSize $Global:winLabel
$Global:winLabel.Text = "Congrats! You won!"
$Global:winLabel.Visible = $false
$Global:winLabel.BackColor = "white"
$Global:winLabel.ForeColor = "green"
$Global:winLabel.Font = [System.Drawing.Font]::new("Verdana",14)
 
AutoSize $Global:loseLabel1
$Global:loseLabel1.Text = "Haha, you suck! Loser!"
$Global:loseLabel1.Visible = $false
$Global:loseLabel1.BackColor = "white"
$Global:loseLabel1.ForeColor = "red"
$Global:loseLabel1.Font = [System.Drawing.Font]::new("Verdana",14)
 
AutoSize $Global:loseLabel2
$Global:loseLabel2.Text = "The word was $Global:word"
$Global:loseLabel2.Visible = $false
$Global:loseLabel2.BackColor = "white"
$Global:loseLabel2.ForeColor = "red"
$Global:loseLabel2.Font = [System.Drawing.Font]::new("Verdana",14)
 
$invalidWordTimer = [System.Timers.Timer]::new()
$invalidWordTimer.AutoReset = $false
$invalidWordTimer.Enabled = $false
$invalidWordTimer.Interval = 1500
$invalidWordTimer.SynchronizingObject = $Global:form
$invalidWordTimer.Add_Elapsed({
    $invalidWordTimer.Enabled = $false
    $Global:invalidWordLabel.Visible = $false
})
 
AutoSize $Global:invalidWordLabel
$Global:invalidWordLabel.Text = "Invalid Word."
$Global:invalidWordLabel.Visible = $false
$Global:invalidWordLabel.BackColor = "white"
$Global:invalidWordLabel.ForeColor = [System.Drawing.Color]::DarkRed
$Global:invalidWordLabel.Font = [System.Drawing.Font]::new("Verdana",14)
$Global:invalidWordLabel.Add_VisibleChanged({
    $invalidWordTimer.Enabled = $true
})
 
$inputTableLayout = [System.Windows.Forms.TableLayoutPanel]::new()
AutoSize $inputTableLayout
$inputTableLayout.Dock = [System.Windows.Forms.DockStyle]::Bottom
$inputTableLayout.ColumnCount = 1
$inputTableLayout.RowCount = 1
 
$null = $outcomeTableLayout.Controls.Add($outcomeFlowLayout)
$outcomeFlowLayout.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$null = $outcomeFlowLayout.Controls.Add($Global:winLabel)
$null = $outcomeFlowLayout.Controls.Add($Global:loseLabel1)
$null = $outcomeFlowLayout.Controls.Add($Global:loseLabel2)
$null = $outcomeFlowLayout.Controls.Add($Global:invalidWordLabel)
 
$null = $Global:form.Controls.Add($toolStrip)
$null = $Global:form.Controls.Add($Global:masterLayout)
$null = $Global:masterLayout.Controls.Add($Global:wordTableLayoutOuter)
$null = $Global:masterLayout.Controls.Add($colorLayoutOuter)
$null = $Global:masterLayout.Controls.Add($Global:keyboardTopTableLayout2)
$null = $Global:masterLayout.Controls.Add($Global:keyboardMiddleTableLayout2)
$null = $Global:masterLayout.Controls.Add($Global:keyboardBottomTableLayout2)
$null = $Global:masterLayout.Controls.Add($outcomeTableLayout)
$null = $Global:masterLayout.Controls.Add($inputTableLayout)
 
$Global:form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$Global:form.Add_Shown({
    $null = $(Get-Variable -Name "var_$($Global:selectedColumn)_$($Global:guess)" -Scope Global -ValueOnly).Focus()
})
AddKeyDown $Global:form
 
$null = $Global:form.ShowDialog()