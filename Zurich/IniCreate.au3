#cs
Author: Bennet van der Gryp
Description: Create settings file for program
#ce
IniWrite("C:\Temp\qtof_I90_1.ini", "Settings", "MQServer", "BRAQSAPM1.SCC/TCP/10.60.8.97(11440)")
IniWrite("C:\Temp\qtof_I90_1.ini", "Settings", "QueueManager", "ZAESAPQQM1")
IniWrite("C:\Temp\qtof_I90_1.ini", "Settings", "Queue", "ZAE.SAP.AQ002")
IniWrite("C:\Temp\qtof_I90_1.ini", "Settings", "Directory", "D:\MQQ\Inbound\I90\AQ002\In")
IniWrite("C:\Temp\qtof_I90_1.ini", "Settings", "Username", "RFCUSER")
IniWrite("C:\Temp\qtof_I90_1.ini", "Settings", "Password", "saeagle")
