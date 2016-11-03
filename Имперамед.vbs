Option explicit
On Error Resume Next
Dim FSO,Sep,FDir,FLD,ArrayInp,FF,FL,St,CenaSNds
Dim DeviceInp,DeviceOut,Seria,Arr
Dim TableName,dbfPrice,dbfSum,dbfConn,ZV,ErrC, WSHShell, NewName

ReDim ConvTable(1)
Const TF="128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255"
Const TT="192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,63,63,63,166,63,63,63,63,63,63,63,63,63,63,63,172,63,63,63,63,63,134,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,135,63,63,63,63,63,63,63,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,168,184,170,186,175,191,161,162,176,149,183,63,185,164,152,160"
Const InExt="dbf"
Const OutExt="sii"
Const OutPath="X:\Programs\In\"

Set FSO = CreateObject("Scripting.FileSystemObject")
FDir="C:\Mail\Invoice\"&Mid(WScript.ScriptName,1,InStr(LCase(WScript.ScriptName),".vbs")-1)&"\"
ArrayInp=Split(FDir,";")
FDir=ArrayInp(0)
Set FLD = FSO.GetFolder(FDir)
Set FL = FLD.Files

For Each FF in FL
 
 if InStr(LCase(FF.Name),"."&InExt) then

  TableName=Mid(LCase(FF.Name),1,InStr(LCase(FF.Name),"."&InExt)-1)
  Set DeviceOut = FSO.CreateTextFile(FDir&"\"&TableName&"."&OutExt, True)
  Set dbfConn = CreateObject("ADODB.Connection")
  With dbfConn
    .Provider = "Microsoft.Jet.OLEDB.4.0"
    .Properties("Extended Properties") = "dBase IV"
    .Properties("Data Source") = FDir
    .Open
  End With

  Set dbfPrice = CreateObject("ADODB.Recordset")
  Set dbfPrice.ActiveConnection = dbfConn
  Set dbfSum = CreateObject("ADODB.Recordset")
  Set dbfSum.ActiveConnection = dbfConn


  DeviceOut.WriteLine "[Header]"
  
  Sep = ";"

  NewName="�-" & TableName

  dbfPrice.Open "SELECT * FROM ["&TableName&"]"
  dbfSum.Open "SELECT Sum(VSEGO) AS Summ FROM ["&TableName&"]" '������ �� ������ ����� �� ���������
  St=NewName & Sep & Date & Sep & dbfSum.Fields("Summ")
  'St=Convert866to1251(St)
  DeviceOut.WriteLine St
  DeviceOut.WriteLine "[Body]"
  
    Do While Not dbfPrice.Eof
          St=dbfPrice.Fields("CODETOV")&Sep & dbfPrice.Fields("TOVNAME") & Sep & dbfPrice.Fields("PRNAME") & Sep & dbfPrice.Fields("PRSTRANA") & Sep &_
  	        dbfPrice.Fields("KOL") & Sep & dbfPrice.Fields("VSEGO")/dbfPrice.Fields("KOL") & Sep & dbfPrice.Fields("CPWONDS") & Sep & dbfPrice.Fields("CWONDS") & Sep &_
		Sep & Sep & Sep & dbfPrice.Fields("GTD") & Sep &_
		dbfPrice.Fields("SERTNOM")& "^" & dbfPrice.Fields("REGNOM") & "^" & dbfPrice.Fields("SERTORG") & "^" & dbfPrice.Fields("SERTDATA") & "^" & dbfPrice.Fields("REGVYDAN") & Sep &_
		dbfPrice.Fields("SERIYA") & Sep & Sep & dbfPrice.Fields("SROKGODN") & Sep & dbfPrice.Fields("EAN13") & Sep & Sep &_
		dbfPrice.Fields("REESTR") & Sep & Sep & dbfPrice.Fields("VSEGO") & Sep
	  dbfPrice.MoveNext
          if Err.Number then Exit Do 
          'St=Convert866to1251(St)
          DeviceOut.WriteLine(St) 
  Loop
  DeviceOut.close
  '���� �������� ������ �� ������ ��������� ����
   if Err.Number then
    FSO.DeleteFile (FDir&"\"&TableName&"."&OutExt)
    Dim FOut
    if not FSO.FileExists("error.log") then 
     Set FOut=FSO.CreateTextFile("error.log")
    else          
     Set Fout=FSO.OpenTextFile("error.log",8,true)
    end if
    FOut.WriteLine("["&Now()&"]	"&Err.Description&" ->"&WScript.ScriptName)
    FOut.Close() : FOut=nothing
   end if
   Err.clear()
 end if
next
   
dbfPrice = null
dbfSum = null
dbfConn = null
DeviceOut = null
CopyFiles()
fso = null

Function GetParm()
  Set DeviceInp = FSO.OpenTextFile("mail.tmp")
  GetParm=DeviceInp.ReadLine()
  DeviceInp.Close: Set DeviceInp = nothing
End Function

'------������������� �� Dos � Windows
Sub MakeConvTable()
  Dim ArrT,ArrF,i
  ReDim ConvTable(256)
  ArrF=Split(TF,",")
  ArrT=Split(TT,",")
  For i=0 to UBound(ArrF)
    ConvTable(ArrF(i))=Chr(ArrT(i))
  Next
End Sub

Function Convert866to1251(St)
  Dim A,i,Ch, StOut
  StOut=""
  if UBound(ConvTable)=1 then MakeConvTable()
  For i=1 to Len(St)
    Ch=Mid(St,i,1)   
    A=ConvTable(Asc(Ch))
    if A="" then A=Ch
    StOut=StOut&A
  Next 
  Convert866to1251=StOut
End Function

Function DelZero(St)
Dim i,Stmp
For i=1 to Len(St) 
 Stmp=Mid(St,i,1)
 if Stmp<>"0" then exit for
next 
DelZero=Mid(St,i,Len(St))
End Function

Function CopyFiles()
Set FL = FLD.Files
For Each FF in FL
  if InStr(LCase(FF.Name),"."&OutExt) then
    FSO.CopyFile FDir&FF.Name, OutPath&FF.Name
    FSO.DeleteFile FDir&FF.Name
  else
    FSO.DeleteFile FDir&FF.Name
  end if
Next
End Function
