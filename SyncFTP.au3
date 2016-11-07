#Include <FTPEx.au3>
#Include <File.au3>
Dim $Feed

While 1
	If InetRead ( "http://bennet-pc:8085/subscriptions?id=pyrohiroshi&format=22&host=localhost&port=8083&size=25&orderby=published&removeDescription=true&removeTitle=false", 1) <> $Feed Then
		$server = 'mysite.mweb.co.za'
		$username = 'm0195130'
		$pass = ''

		$Open = _FTP_Open('MyMweb')
		$Conn = _FTP_Connect($Open, $server, $username, $pass)

		$Feed = InetRead ( "http://bennet-pc:8085/subscriptions?id=pyrohiroshi&format=22&host=localhost&port=8083&size=25&orderby=published&removeDescription=true&removeTitle=false", 1)
		$File = FileOpen ( "feed.xml", 2)
		FileWrite ($File, $Feed)
		FileClose($File)
		$sLocalFile = "feed.xml"
		$sRemoteFile = "feed.xml"
		$Result = _FTP_FilePut($Conn, $sLocalFile, $sRemoteFile)
		ConsoleWrite($Result)
		$Ftpc = _FTP_Close($Open)
	EndIf
	Sleep(1800000) ;Check for new videos every 30 minutes
WEnd
