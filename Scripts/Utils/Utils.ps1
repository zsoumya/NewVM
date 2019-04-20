function Invoke-Pause {
	$key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").VirtualKeyCode
	$Host.UI.RawUI.Flushinputbuffer()
	
	return $key
}

function Invoke-PauseWithEscape {
    $key = Invoke-Pause

    $flag = if ($key -eq 27) { $false } else { $true }
    return $flag
}

function Test-ContainsLike {
	[OutputType([bool])]
	param (
		[string[]]$array,
		[string]$item
	)
	
	foreach ($arrayItem in $array) {
		if ($arrayItem -like $item) {
			return $true
		}
	}
	
	return $false
}