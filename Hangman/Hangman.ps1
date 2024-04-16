Clear-Host
 
function Get-WordList {
    param(
        [int]$MinLength = 10,
        [int]$MaxLength = 12
    )
 
    $content = Get-Content -Path .\Hangman.txt
 
    $list = [System.Collections.ArrayList]::new()
    foreach ( $item in $content ) {
        if (( $item.Length -ge $MinLength ) -and ( $item.Length -le $MaxLength )) {
            $list.Add( $item ) | Out-Null
        }
    }
 
    return $list
}
 
function Get-RandomWord {
    param(
        $List
    )
 
    $word = Get-Random -InputObject $List
 
    return $word
}
 
function Confirm-PreviousLetter {
    param(
        $List,
        [string]$Letter
    )
 
    if ( $List -contains $Letter ) {
        return $true
    }
 
    return $false
}
 
$newGame = $true
$prevMode = 0
 
while ( $true ) {
 
    if ( $newGame ) {
 
        while ( $true ) {
            Write-Host "`nChoose difficulty: `n 1 = Easy mode; Word length between 4-6.`n  2 = Medium mode; Word length between 7-9.`n   3 = Hard mode; Word length between 10-12."
            $mode = Read-Host
 
            if (( $mode -notmatch '[123]' ) -or ( $mode.Length -ne 1 )) {
                Write-Warning "Must choose single number for difficulty level.`n"
                continue
            } else {
                break
            }
        }
 
        Switch ( $mode ) {
            1 { $minLength = 4; $maxLength = 6; $lives = 8 }
            2 { $minLength = 7; $maxLength = 9; $lives = 7 }
            3 { $minLength = 10; $maxLength = 12; $lives = 6 }
        }
 
        Clear-Host
 
        Write-Host "Loading..."
 
        if ( $prevMode -ne $mode ) {
            $wordList = Get-WordList -MinLength $minLength -MaxLength $maxLength
            $prevMode = $mode
        }
 
        $newGame = $false
 
        $randWord = Get-RandomWord -List $wordList
        $word = $randWord.ToUpper()
        $randWord = $randWord.ToUpper().ToCharArray()
 
        $guess = "_" * $randWord.Count
 
        $guess = $guess.ToCharArray()
 
        $prevLetters = [System.Collections.ArrayList]::new()
    }
 
    Write-Host "`nRemaining Lives = $( $lives )"
 
    Write-Host "`n$( $guess )"
 
    while ( $true ) {
        Write-Host "`nPlease guess a letter"
        $userInput = Read-Host
        $userInput = $userInput.ToUpper()
        if (( $userInput -match '[^A-Z]' ) -or ( $userInput.Length -ne 1 )) {
            Write-Warning "Input must only be one letter`n"
            continue
        }
        if ( Confirm-PreviousLetter -List $prevLetters -Letter $userInput ) {
            Write-Warning "You have already guessed that letter`n"
            continue
        }
        $prevLetters.Add( $userInput ) | Out-Null
        break
    }
 
    $correct = $false
    foreach ( $letter in 0..$randWord.Count) {
        if ( $userInput -eq $randWord[$letter] ) {
            $guess[$letter] = $userInput
            $correct = $true
        }
    }
 
    if ( -not $correct ) {
       
        Clear-Host
 
        Write-Warning "That letter was not in the word`n"
        $lives--
 
        if ( $lives -le 0 ) {
            Write-Host "`nValiant effort, but you did not succeed."
            Write-Host "`nThe word was: $( $word )"

            $newGame = $true
        }

        continue
    }


    if ( $guess -contains '_' ) {

        Clear-Host

        continue
    } else {
        Clear-Host

        Write-Host "`n$( $guess )"

        Write-Host "`nWinner! Congrats!"

        $newGame = $true
    }

}