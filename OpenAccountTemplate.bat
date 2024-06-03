REM us.actual.battle.net
REM eu.actual.battle.net
REM kr.actual.battle.net

start "" ".\Diablo II Resurrected\D2R.exe" -username username@gmail.com -password myPassword -address us.actual.battle.net

TIMEOUT /T 5 /nobreak >NUL

".\Handle\CloseHandle.bat"
