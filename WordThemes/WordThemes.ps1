Clear-Host
 
function Confirm-DoubleLetter {
    param(
        [string]$Word
    )
 
    $array = $Word.ToLower().ToCharArray()
 
    foreach ( $num in 0..( $array.Count - 2 )) {
        if ( $array[$num] -eq $array[( $num + 1 )] ) {
            return $true
        }
    }
 
    return $false
}
 
function Confirm-ThreeVowels {
    param(
        [string]$Word
    )
 
    $vowels = 'a', 'e', 'i', 'o', 'u'
 
    $array = $Word.ToLower().ToCharArray()
 
    $grouped = $array | Group-Object
 
    $count = 0
    foreach ( $group in $grouped ) {
        foreach ( $vowel in $vowels ) {
            if ( $group.Name -eq $vowel ) {
                $count++
            }
            if ( $count -ge 3 ) {
                return $true
            }
        }
    }
 
    return $false
}
 
function Confirm-FirstIsLast {
    param(
        [string]$Word
    )
 
    $array = $Word.ToLower().ToCharArray()
 
    $firstLetter = $array[0]
    $lastLetter = $array[( $array.Count - 1 )]
 
    if ( $firstLetter -eq $lastLetter ) {
        return $true
    }
 
    return $false
}
 
function Confirm-Animal {
    param(
        $AnimalList,
        [string]$Word
    )
 
    foreach ( $animal in $AnimalList ) {
        if (( $Word.ToLower() -match $animal ) -and ( $Word.ToLower() -ne $animal )) {
            return $true
        }
    }
 
    return $false
}
 
function Confirm-Palindrome {
    param(
        [string]$Word
    )
 
    $array = $Word.ToLower().ToCharArray()
 
    if (( $array.Count % 2 ) -eq 0 ) {
    # Even length
       
        foreach ( $num in 0..(( $array.Count / 2 ) - 1 )) {
            if ( $array[$num] -ne $array[( $array.Count - 1 - $num )] ) {
                return $false
            }
        }
 
    } else {
    # Odd length
       
        foreach ( $num in 0..((( $array.Count - 1 ) / 2 ) - 1 )) {
            if ( $array[$num] -ne $array[( $array.Count - 1 - $num )] ) {
                return $false
            }
        }
 
    }
 
    return $true
}
 
function Confirm-AlternateType {
    param(
        [string]$Word
    )
 
    # Minimum length check (arbitrary)
    $minLength = 4
    if ( $Word.Length -lt $minLength ) {
        return $false
    }
 
    $vowels = 'a', 'e', 'i', 'o', 'u'
 
    $array = $Word.ToLower().ToCharArray()
 
    $isVowel = ( $vowels -contains $array[0] )
 
    foreach ( $letter in $array ) {
        if ( $isVowel ) {
            if ( $vowels -notcontains $letter ) {
                return $false
            }
            $isVowel = $false
        } else {
            if ( $vowels -contains $letter ) {
                return $false
            }
            $isVowel = $true
        }
    }
 
    return $true
}
 
function Confirm-SingularEndS {
    param(
        $SingularNounList,
        [string]$Word
    )
 
    if ( $SingularNounList -contains $Word.ToLower() ) {
        return $true
    }
 
    return $false
}
 
function Confirm-ThreeLetter {
    param(
        [string]$Word
    )
 
    $array = $Word.ToLower().ToCharArray()
 
    $grouped = $array | Group-Object | Where-Object { $_.Count -ge 3 }
 
    if ( $grouped.Count -gt 0 ) {
        return $true
    }
 
    return $false
}
 
function Confirm-Alphabetical {
    param(
        [string]$Word
    )
 
    $array = $Word.ToLower().ToCharArray()
 
    $value = 0
    foreach ( $letter in $array ) {
        if ( [int]$letter -ge $value ) {
            $value = [int]$letter
        } else {
            return $false
        }
    }
 
    return $true
}
 
 
function Get-RandomNumber {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        [int]$Minimum = 0,
        [int]$Maximum = 123456789
    )
 
    $randomNumber = Get-Random -Minimum $Minimum -Maximum $Maximum
 
    return $randomNumber
}
 
function Confirm-ValidGuess {
    [ CmdletBinding( SupportsShouldProcess )]
    param(
        $List,
        [string]$Word
    )
 
    if ( $Word -match '[^A-Za-z]' ) {
        return $false
    }
 
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
 
<#
 
Number and its Theme:
 
1 = Double letters | Battle, Noon, Called
2 = At least 3 different vowels | Firetruck, Audio, Humanity
3 = First matches last | Aqua, Demand, Kick
4 = Word with animal/insect | Howl (Owl), Beet (Bee), Foxtrot (Fox)
5 = Palindrome | Level, Rotor, Kayak
6 = Alternating vowel/consonant (Minimum 4 letters) | Tower, Halo, Banana
7 = Non plural and ends with 's' | Serious, Boss, Miss
8 = A letter appears at least 3 times | Tattle, Banana, Intimidate, Leveled
9 = Letters are alphabetical order | Ace, Bet, Fry, Chip
 
#>
$minThemes = 1
$maxThemes = 9
 
Write-Host "Loading..."
 
$wordList = Get-Content .\WordThemes.txt
$animalList = Get-Content .\AnimalList.txt
$singularNounList = Get-Content .\SingularNounList.txt
 
Clear-Host
 
$score = 0
$lives = 3
$previousWords = [System.Collections.ArrayList]::new()
while ( $true ) {
 
    $randomTheme = Get-RandomNumber -Minimum $minThemes -Maximum $maxThemes
 
    Switch( $randomTheme ) {
        1 { Write-Host "`nEnter a word that contains two of the same letter, one right after the other; Example: Battle" }
        2 { Write-Host "`nEnter a word that contains at least 3 unique vowels; Example: Audio" }
        3 { Write-Host "`nEnter a word where the first letter matches the last letting in the word: Example: Aqua" }
        4 { Write-Host "`nEnter a word that contains an animal as part of the word, but is not equal to the word; Example: Howl (contains Owl)" }
        5 { Write-Host "`nEnter a word that is a palindrome; Example: Level" }
        6 { Write-Host "`nEnter a word, at least 4 letters long, where the letters alternate between consonents and vowels; Examples: Tower, Axed" }
        7 { Write-Host "`nEnter a word that end in the letter 's' but is NOT a plural; Example: Serious" }
        8 { Write-Host "`nEnter a word where a letter appears at least 3 times in the word; Example: Banana" }
        9 { Write-Host "`nEnter a word where the letters are in alphatical order; Examples: Bet, Chip" }
    }
 
    $userInput = Read-Host
 
    while($true) {
        if ( -not ( Confirm-ValidGuess -List $wordList -Word $userInput )) {
                Write-Warning "Invalid word, try another one.`n"
                $userInput = Read-Host
        } else {
            break
        }
    }
 
    $result = $false
    Switch( $randomTheme ) {
        1 { $result = Confirm-DoubleLetter -Word $userInput }
        2 { $result = Confirm-ThreeVowels -Word $userInput }
        3 { $result = Confirm-FirstIsLast -Word $userInput }
        4 { $result = Confirm-Animal -AnimalList $animalList -Word $userInput }
        5 { $result = Confirm-Palindrome -Word $userInput }
        6 { $result = Confirm-AlternateType -Word $userInput }
        7 { $result = Confirm-SingularEndS -SingularNounList $singularNounList -Word $userInput }
        8 { $result = Confirm-ThreeLetter -Word $userInput }
        9 { $result = Confirm-Alphabetical -Word $userInput }
    }
 
    if ( $result ) {
 
        Clear-Host
 
        if ( Confirm-PreviousWord -List $previousWords -Word $userInput ) {
            $lives--
            Write-Warning "You have already used that word."
            Write-Warning "Lives remaining = $( $lives )`n"
 
            if ( $lives -le 0 ) {
                Write-Host "`nFinal Score = $( $score )"
 
                $complete = $true
 
                break
            }
 
            continue
        }
 
        $score++
        Write-Host "`nGreat job! Score = $( $score )"
 
        $previousWords.Add( $userInput ) | Out-Null
    } else {
       
        Clear-Host
 
        $lives--
        Write-Warning "Your word did not meet the theme."
        Write-Warning "Lives remaining = $( $lives )`n"
 
        if ( $lives -le 0 ) {
            Write-Host "`nFinal Score = $( $score )"
 
            $complete = $true
 
            break
 
        }
    }
 
}
 
Read-Host -Prompt "Press Enter to exit"