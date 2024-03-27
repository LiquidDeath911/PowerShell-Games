Clear-Host
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
<#
    Baby Mode = Use 1 out of 3 letters
    Easy Mode = Use 2 out of 3 letters
    Medium Mode = Use 3 out of 5 letters
    Hard Mode = Use 4 out of 5 letters
    Expert Mode = Use 5 out of 5 letters
#>
function Get-RandomLetter {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
    )
    $randomLetter = [char](Get-Random -Minimum 65 -Maximum 90)
    return $randomLetter
}
function Confirm-ValidGuess {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        $List,
        [string]$Word
    )
    if ( $List -contains $Word ) {
        return $true
    } else {
        return $false
    }
}
function Confirm-PreviousWord {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        $List,
        $Word
    )
    if ( $List -contains $Word ) {
        return $true
    }
    return $false
}
function Get-PossibleWordCount {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        $List,
        $Letters,
        $PreviousWords,
        $MinimumNeeded
    )
    $wordCount = 0
    foreach ( $word in $List ) {
        $temp = "$( $word )"
        $count = 0
        if ( $temp.Length -lt $MinimumNeeded ) {
            continue
        }
        foreach ( $letter in $Letters ) {
            $letter = $letter.ToString().ToLower()
            if ( $temp -match $letter ) {
                $count++
                $temp = $temp.Remove( $temp.IndexOf( $letter ), 1 )
            }
        }
        if ( $count -ge $MinimumNeeded ) {
            if ( $PreviousWords -notcontains $word ) {
                $wordCount++
            }
        }
    }
    return $wordCount
}
function Get-PossibleWords {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        $List,
        $Letters,
        $MinimumNeeded
    )
    foreach ( $word in $List ) {
        $temp = "$( $word )"
        $count = 0
        if ( $temp.Length -lt $MinimumNeeded ) {
            continue
        }
        foreach ( $letter in $Letters ) {
            $letter = $letter.ToString().ToLower()
            if ( $temp -match $letter ) {
                $count++
                $temp = $temp.Remove( $temp.IndexOf( $letter ), 1 )
            }
        }
        if ( $count -ge $MinimumNeeded ) {
            Write-Host -NoNewLine "$( $word ) | "
        }
    }
    return
}
Write-Host "Loading..."
$minWords = 5
$wordList = Get-Content .\WordGuess.txt
while ( $true ) {
    Write-Host "`nChoose difficulty: `n 1 = Baby mode; Minimum 1 out of 3 letters.`n  2 = Easy mode; Minimum 2 out of 3 letters.`n   3 = Medium mode; Minimum 3 out of 5 letters.`n    4 = Hard mode; Minimum 4 out of 5 letters.`n     5 = Expert mode; Minimum 5 out of 5 letters."
    $mode = Read-Host
    if ( $mode -notmatch '[0-9]' ) {
        Write-Warning "Must choose number for difficulty level.`n"
        continue
    } else {
        break
    }
}
Switch ( $mode ) {
    1 { $minLetters = 1; $maxLetters = 3 }
    2 { $minLetters = 2; $maxLetters = 3 }
    3 { $minLetters = 3; $maxLetters = 5 }
    4 { $minLetters = 4; $maxLetters = 5 }
    5 { $minLetters = 5; $maxLetters = 5 }
}
Clear-Host
$score = 0
$lives = 3
$try = $false
$previous = $false
$win = $false
$previousWords = [System.Collections.ArrayList]::new()
while ( $true ) {
    if ( $wordList.Count -eq 0 ) {
        Write-Host "`nUm... this wasn't supposed to be possible. I guess you win?"
        Write-Host "`nFinal score: $( $score )"
        break
    }

    $notMin = $false
    $previous = $false

    $timeout = 0
    while ( $true ) {
        $letters = ""
        foreach ( $num in 1..$maxLetters ) {
            $letters += Get-RandomLetter
        }
        $letters = $letters.ToCharArray()
        if (( Get-PossibleWordCount -List $wordList -Letters $letters -PreviousWords $previousWords -MinimumNeeded $minLetters ) -ge $minWords ) {
            break
        }
        $timeout++
        if ( $timeout -gt 10000 ) {
            Write-Host "`nUm... this wasn't supposed to be possible. I guess you win?"
            $win = $true
            break
        }
    }
    if ( $win ) {
        Write-Host "`nFinal score: $( $score )"
        break
    }
    Write-Host "`nYour letters are:"
    foreach ( $letter in $letters ) {
        Write-Host -NoNewLine "`t$( $letter )"
    }    
    
    $tries = 0
    while ( $true ) {
        Write-Host "`nPlease enter a word containing $( $minLetters ) of the randomly chosen letters."
        $userInput = Read-Host
        if ( $userInput -eq "7588" ) {
            Get-PossibleWords -List $wordList -Letters $letters -MinimumNeeded $minLetters
            continue
        }
        if ( $userInput -match '[^a-zA-Z]' ) {
            Write-Warning "Only letters are allowed.`n"
            continue
        } else {
            if ( Confirm-PreviousWord -List $previousWords -Word $userInput ) {
                $previous = $true
                break
            } else {
                if ( Confirm-ValidGuess -List $wordList -Word $userInput ) {
                    if ( $userInput.Length -ge $minLetters ) {
                    } else {
                       Write-Warning "Word must be at least $( $minLetters ) long.`n"
                       continue
                    }                
                } else {
                    Write-Warning "Word not in list. Sorry.`n"
                    continue
                }
            }
        }
        $userInput = $userInput.ToLower()
        $count = 0
        $temp = $userInput
        foreach ( $letter in $letters ) {
            $letter = $letter.ToString().ToLower()
            if ( $temp -match $letter ) {
                $count++
                $temp = $temp.Remove( $temp.IndexOf( $letter ), 1 )
            }
        }
        if ( $count -ge $minLetters ) {
            $score++
            $previousWords.Add( $userInput ) | Out-Null
            Clear-Host
            Write-Host "`nNice!`nScore = $( $score )"
            break
        } else {
            $notMin = $true
        }
    }

    if ( $notMin ) {
        $tries++
        Write-Warning "You have to use at least $( $minLetters ) of the randomly chosen letters."
        Write-Warning "Lives remaining = $( $lives - $tries )`n"
        continue
    }

    if ( $previous ) {
        $tries++
        Write-Warning "You used that word already.`n"
        Write-Warning "Lives remaining = $( $lives - $tries )`n"
        continue
    }

    if ( $tries -gt $lives ) {
        Write-Warning "You ran out of lives.`n"
        Write-Host "`nFinal score: $( $score )"
        break
    }
}
