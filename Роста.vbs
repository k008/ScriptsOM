Option explicit
'On Error Resume Next
Dim FSO,Sep,FDir,FLD,ArrayInp,FF,FL,St
Dim DeviceInp,DeviceOut
Dim TableName,dbfPrice,dbfSum,dbfConn,ZV,ErrC, WSHShell, NewName
Dim Pb1, Pb2, Pb3, Pb4, Pb5, Pb6, Pb7, Pb8, Pb9, Pb10, Pb11, Pb12, Pb13, Pb14, Pb15, Pb16, Pb17, Pb18, Pb19, Pb20, Pb21, Pb22

ReDim ConvTable(1)
Const TF="128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255"
Const TT="192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,63,63,63,166,63,63,63,63,63,63,63,63,63,63,63,172,63,63,63,63,63,134,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,63,135,63,63,63,63,63,63,63,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,168,184,170,186,175,191,161,162,176,149,183,63,185,164,152,160"
Const InExt="dbf"
Const OutExt="sst"
Const OutPath= "X:\Programs\In\"

Set FSO = CreateObject("Scripting.FileSystemObject")
'FDir=GetParm()
FDir="C:\Mail\Invoice\"&Mid(WScript.ScriptName,1,InStr(LCase(WScript.ScriptName),".vbs")-1)&"\"
ArrayInp=Split(FDir,";")
FDir=ArrayInp(0)
Set FLD = FSO.GetFolder(FDir)
Set FL = FLD.Files
CheckLenTableName

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

  TableName=Mid(LCase(FF.Name),1,InStr(LCase(FF.Name),"."&InExt)-1)
  
  ZV = 0
  dbfPrice.Open "SELECT * FROM ["&TableName&"]"  '���� � ���������
  dbfSum.Open "SELECT Sum(SUMPAY) AS Summ FROM "&TableName '������ �� ������ ����� �� ���������
  St=dbfPrice.Fields("NDOC") & Sep & dbfPrice.Fields("DATEDOC") & Sep & dbfSum.Fields("Summ")
    St=Convert866to1251(St)
    DeviceOut.WriteLine St
    DeviceOut.WriteLine "[Body]"
    
    Do While Not dbfPrice.Eof
    Pb1=dbfPrice.Fields("CODEPST")
    Pb2=dbfPrice.Fields("NAME")
    Pb3=dbfPrice.Fields("FIRM")
    Pb4=dbfPrice.Fields("CNTR")
    Pb5=dbfPrice.Fields("QNT")
    Pb6=dbfPrice.Fields("PRICE2")
    Pb7=dbfPrice.Fields("PRICE1N")
    Pb8=dbfPrice.Fields("PRICE2N")
    Pb9=""
    Pb10=dbfPrice.Fields("PRCOPT")
    Pb11=""
    Pb12=dbfPrice.Fields("NUMGTD")
    Pb13=dbfPrice.Fields("SERTIF") & "^" & dbfPrice.Fields("SERTORG") & " " & dbfPrice.Fields("SERTDATE")
    Pb14=dbfPrice.Fields("SER")
    Pb15=""
    Pb16=dbfPrice.Fields("GDATE")
    Pb17=dbfPrice.Fields("EAN13")
    Pb18=dbfPrice.Fields("DATEPRC")
    Pb19=dbfPrice.Fields("REGPRC")
    Pb20=""
    Pb21=dbfPrice.Fields("SUMPAY")
    Pb22=dbfPrice.Fields("GNVLS")
    'msgbox(pb2 & " t=" & TableName)
    If Pb2 <> TableName Then
      St=Pb1 & Sep & Pb2 & Sep & Pb3 & Sep & Pb4 & Sep &_
  	        Pb5 & Sep & Pb6 & Sep & Pb7 & Sep & Pb8 & Sep &_
		Pb9 & Sep & Pb10 & Sep & Pb11 & Sep & Pb12 & Sep & Pb13 & Sep & Pb14 & Sep & Pb15 & Sep & Pb16 & Sep & Pb17 & Sep & Pb18 & Sep & Pb19 & Sep & Pb20 & Sep & Pb21 & Sep & Pb22
    else
      St=""
    End If
	  dbfPrice.MoveNext
      If Err.Number Then Exit Do 
      St=Convert866to1251(St)
      If St<>"" Then
        DeviceOut.WriteLine(St)
      End If
    Loop

  dbfConn.Close
  DeviceOut.close
  '���� �������� ������ �� ������ ��������� ����
   if Err.Number then
    FSO.DeleteFile (FDir&"\"&TableName&"."&InExt)
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

'------������������ �� Dos � Windows
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

Function DelBigName(TN1)
  Dim TN 
  TN=Mid(TN1, 6, Len(TN1))
  'msgbox("tn="&tn)
  DelBigName=TN
End Function

Function CheckLenTableName()
  Dim DBN, TableName1
  For Each FF in FL
    If InStr(LCase(FF.Name),"."&InExt) Then
      TableName1=Mid(LCase(FF.Name),1,InStr(LCase(FF.Name),"."&InExt)-1)
      'msgbox(TableName1)
      If Len(TableName1)>8 Then 
        DBN=DelBigName(TableName1)
        FSO.CopyFile FDir&FF.Name, FDir&DBN & "." & InExt
        'msgbox(FDir&DBN & "." & InExt)
        FSO.DeleteFile FDir&FF.Name
        If Len(DBN)>8 Then
          'msgbox ("���������� ��������� ��� ��������� �� 8-�� �������� ����� '.dbg'. ���������� ��������=" & Len(DBN) & Chr(13)&Chr(10) & "����� ����, ������� 911 � �������������� ��������")
        End If
      End If
    End If
  Next
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