		if FileExist(dopusrt)
		{
			clipboard =
			sleep 30
			Run, %dopusrt% /CMD Clipboard COPY FILE "%A_ThisMenuItem%", , UseErrorLevel
			ToolTip, %A_ThisMenuItem% ...`n... copied to your Clipboard with Directory Opus!`nPaste it anywhere you would normally would paste a File.
			SetTimer, RemoveToolTip, -2500
			return
		}
		else
		{
			tooltip, Directory Opus not found!`nDO is required for this action. 
			SetTimer, RemoveToolTip, -2000
		}
		return