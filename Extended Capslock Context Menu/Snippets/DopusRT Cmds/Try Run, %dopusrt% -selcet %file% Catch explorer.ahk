try Run, %dopusrt% /cmd Go "%Clipboard%" NEWTAB TOFRONT
catch
Run explorer.exe /select`,"%clipboard%"