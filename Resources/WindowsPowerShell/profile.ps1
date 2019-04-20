function Prompt
{
	Write-Host "PS " -NoNewline -ForegroundColor Yellow
	Write-Host $(Get-Location) -ForegroundColor Green
	Write-Host "$" -NoNewline -ForegroundColor Cyan
	
	return " "
}