unit MakPub;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, FileUtil, Process, helpers;

type
  TMakPub = class
  private
         sWorkDir : string;
         sWorkGen : string;
         //###
         sWorkOPS      : string;
         sWorkOPSimg   : string;
         sWorkOPSfont  : string;
         sWorkOPShtml  : string;
         sWorkOPSstyle : string;
         //###
         sPath   : string;
         sFile   : string;
         sTemplP : string;
         sAuthor : string;
         sTitle  : string;
         sStyle  : string;
         sZip    : string;
         iAktSrc : integer;
         slSrc   : TStringList;
         slHead  : TStringList;
         slOpf   : TStringList;
         slToc   : TStringList;
         slPic   : TStringList;
         slCap   : TStringList;
         function GetContent(sSrc:string; sLookup:string):string;
         procedure MakeDir(sDir: string; bFlag: boolean);
         procedure RemoveEmptyDir(sDir: string);
         procedure ClearDir(sDir: string);
         procedure CopyOne(sSrc, sDst: string);
         procedure Packit(sDst:string;sRes:string);
         function CheckRun(bType:boolean):boolean;
         procedure MoveOne(sSrc, sDst: string);
  public
    constructor Create(xhtmlFile:string; ExePath:string; bType:boolean);
    destructor Destroy;override;
    function DoRun(sResDir:string; sResFile:string):boolean;
    function DoRunHTML(sResDir:string; sResFile:string):boolean;
  end;


implementation
//-------------------------------------------------------------------------------------------
constructor TMakPub.Create(xhtmlFile:string; ExePath:string; bType:boolean);
begin
     inherited Create;
     sPath   := ExtractFilePath(xhtmlFile);
     sTemplP := ExePath + 'templates' + PathDelim;
     sWorkDir:= ExePath  + 'work' + PathDelim;
     sWorkGen:= sWorkDir + 'Gen' + PathDelim;
     //####
     if (bType) then begin
        sWorkOPS:= sWorkGen + 'OEBPS' + PathDelim;
        sWorkOPShtml:= sWorkOPS + 'text' + PathDelim;
        sWorkOPSstyle:= sWorkOPS + 'styles' + PathDelim;
     end else begin
        sWorkOPS:= sWorkGen;
        sWorkOPShtml:= sWorkOPS;
        sWorkOPSstyle:= sWorkOPS;
     end;
     sWorkOPSimg:= sWorkOPS + 'images' + PathDelim;
     sWorkOPSfont:= sWorkOPS + 'fonts' + PathDelim;
     //####
     slSrc   := TStringList.Create;
     MakeDir(sWorkDir, true);
     MakeDir(sWorkGen, true);
     //###
     MakeDir(sWorkOPS, true);
     MakeDir(sWorkOPSimg, true);
     MakeDir(sWorkOPSfont, true);
     MakeDir(sWorkOPShtml, true);
     MakeDir(sWorkOPSstyle, true);
     //###
     sZip    := ExePath + PathDelim + 'zip' + PathDelim + 'zip.exe';
     sFile   := xhtmlFile;
     slSrc   := TStringList.Create;
     slHead  := TStringList.Create;
     slOpf   := TStringList.Create;
     slToc   := TStringList.Create;
     slPic   := TStringList.Create;
     slCap   := TStringList.Create;
end;
//-------------------------------------------------------------------------------------------
destructor TMakPub.Destroy;
begin
     inherited Destroy;
     slHead.Free;
     slSrc.Free;
     slOpf.Free;
     slToc.Free;
     slPic.Free;
     slCap.Free;
     if (DirectoryExists(sWorkOPS)) then DeleteDirectory(sWorkOPS, false);
     if (DirectoryExists(sWorkGen)) then DeleteDirectory(sWorkGen, false);
     if (DirectoryExists(sWorkDir)) then DeleteDirectory(sWorkDir, false);
end;
//-------------------------------------------------------------------------------------------
function TMakPub.CheckRun(bType:boolean):boolean;
begin
     result := false;
     if (not bType) then begin  //zeno
         if (not FileExists(sFile))then exit;
         if (not FileExists(sTemplP+'content_z.opf')) then exit;
         if (not FileExists(sTemplP+'toc_z.ncx')) then exit;
     end else begin   // gutenberg
         if (not FileExists(sFile+'1.html')) then exit;       //erste html-Datei des Buches
         if (not FileExists(sTemplP+'content.opf')) then exit;
         if (not FileExists(sTemplP+'toc.ncx')) then exit;
     end;
     result := true;
end;

//-------------------------------------------------------------------------------------------
function TMakPub.DoRun(sResDir:string; sResFile:string):boolean;
var i, j : integer;
    s1 : string;
    iHead : integer;
    slTmp: TStringList;
    iA, iE : integer;
begin
     result := false;
     if (not CheckRun(false)) then exit;
     slTmp := TStringList.Create;
     slSrc.LoadFromFile(sFile);
     //if (not FileExists(sTemplP+'content_z.opf')) then exit;
     slOpf.LoadFromFile(sTemplP+'content_z.opf');
     slToc := TStringList.Create;
     slToc.LoadFromFile(sTemplP+'toc_z.ncx');
     iAktSrc := 0;
     iHead := 0;

     sAuthor := '';
     sTitle  := '';


     for i:=0 to slSrc.Count-1 do begin
         if (iHead=0) then begin
            if (Pos('<BODY',uppercase(slSrc.Strings[i])) = 0) then slHead.Add(slSrc.Strings[i])
            else begin
                 iHead := i;
                 slHead.Add(slSrc.Strings[i]);
            end;
         end;
         s1 := slSrc.Strings[i];

         if (Pos('name="DC.author',s1)>0) then sAuthor := GetContent(s1, 'content=');
         if (Pos('name="DC.title',s1)>0) then sTitle := GetContent(s1, 'content=');
         if (Pos('<link rel="stylesheet" type="text/css"',s1)>0) then sStyle := GetContent(s1, 'href=');
         if (Pos('<img src="',s1)>0) then slPic.Add(sPath + GetContent(s1, 'img src='));
         if (Pos('<h2',s1)>0) then slCap.Add(IntToStr(i));
         if (Pos('<h3',s1)>0) then slCap.Add(IntToStr(i));
     end;
     slCap.Add(IntToStr(slSrc.Count-1));

     //### update content.opf
     for i:=0 to slOpf.Count-1 do begin
         if (Pos('$TITLE',slOpf.strings[i])>0) then slOpf.strings[i] := AnsiReplaceAll(slOpf.strings[i],'$TITLE',sTitle);
         if (Pos('$AUTOR',slOpf.strings[i])>0) then slOpf.strings[i] := AnsiReplaceAll(slOpf.strings[i],'$AUTOR',sAuthor);
         if (Pos('$UUID',slOpf.strings[i])>0) then slOpf.strings[i] := AnsiReplaceAll(slOpf.strings[i],'$UUID',AnsiReplaceAll(AnsiReplaceAll(sAuthor+'-'+sTitle,',','-'),' ','-'));
     end;

     //### update toc.ncx
     for i:=0 to slToc.Count-1 do begin
         if (Pos('$BOOK',slToc.strings[i])>0) then slToc.strings[i] := AnsiReplaceAll(slToc.strings[i],'$BOOK',sTitle);
         if (Pos('$UUID',slToc.strings[i])>0) then slToc.strings[i] := AnsiReplaceAll(slToc.strings[i],'$UUID',AnsiReplaceAll(AnsiReplaceAll(sAuthor+'-'+sTitle,',','-'),' ','-'));
     end;

     MakeDir(sResDir, false);

     //### images ???
     if (slPic.Count > 0) then begin
        for i:=0 to slPic.Count-1 do begin
        //###
            //CopyOne(slPic.Strings[i],sWorkGen+'img'+PathDelim + ExtractFileName(slPic.Strings[i]));
            CopyOne(slPic.Strings[i],sWorkOPSimg + ExtractFileName(slPic.Strings[i]));
        //###
        end;
     end;

     //### Kapitel-Struktur (Inhaltsverzeichnis?)
     for i:=0 to slCap.Count-2 do begin
         slTmp.Clear;
         for j:=0 to slHead.Count-1 do slTmp.Add(slHead.Strings[j]);
         iA := StrToInt(slCap.Strings[i]);
         iE := StrToInt(slCap.Strings[i+1]);
         for j:=iA to iE-1 do begin
             if (Pos('</BODY',uppercase(slSrc.Strings[j]))=0) then slTmp.Add(slSrc.Strings[j])
             else break;
         end;
         slTmp.Add('</body>');
         slTmp.Add('</html>');
         //slTmp.SaveToFile(sWorkDir+'ebook'+IntToStr(i)+'.xhtml');
     end;

     //###  erzeuge epub-Container
     slOpf.SaveToFile(sWorkOPS+'content.opf');
     slToc.SaveToFile(sWorkOPS+'toc.ncx');
     slSrc.SaveToFile(sWorkOPShtml+'ebook.xhtml');
     CopyOne(ExtractFilePath(sFile) + sStyle, sWorkOPSstyle + sStyle);

     //slPic.SaveToFile(sWorkDir+'piclist.txt');
     //slCap.SaveToFile(sWorkDir+'h_list.txt');
     //slHead.SaveToFile(sWorkDir+'header.txt');


     slTmp.Free;
     CopyOne(sTemplP+'templ_z.epub', sWorkDir+'templ.epub');

     RemoveEmptyDir (sWorkOPSimg);
     RemoveEmptyDir (sWorkOPSfont);
     RemoveEmptyDir (sWorkOPShtml);
     RemoveEmptyDir (sWorkOPSstyle);

     packit(sWorkGen,sWorkDir+'templ.epub');
     CopyOne(sWorkDir+'templ.epub', sResDir+PathDelim+sResFile);
     ClearDir(sWorkDir);
     result := true;
end;

//-------------------------------------------------------------------------------------------
function TMakPub.DoRunHTML(sResDir:string; sResFile:string):boolean;
var i : integer;
    s1 : string;
    iHead : integer;
    slTmp: TStringList;
    iHTMLFile : integer;
    sHTMLFile : string;
    sHTMLFileName : string;
    stmp : string;
    bmodified, bimgmodified : boolean;
begin
     result := false;
     if (not CheckRun(true)) then exit;
     slTmp := TStringList.Create;
     iAktSrc := 0;
     iHead := 0;
     sAuthor := '';
     sTitle  := '';
     slPic.Clear;


     sStyle := 'ebook.css';

     iHTMLFile := 1;                      //erste HTML-Datei des Buches
     sHTMLFile := sFile + IntToStr(iHTMLFile) +'.html';
     sHTMLFileName := AnsiReplaceAll(sHTMLFile,ExtractFilePath(sHTMLfile),'');
     repeat
        slSrc.Clear;
        slTmp.Clear;
        slSrc.LoadFromFile(sHTMLFile);
        bmodified := false;
        bimgmodified := false;
        iHead := 1;
        for i:=0 to slSrc.Count-1 do begin
         s1 := slSrc.Strings[i];

         if (Pos('name="DC.author',s1)>0) then sAuthor := GetContent(s1, 'content=');
         if (Pos('name="DC.title',s1)>0) then sTitle := GetContent(s1, 'content=');
         //if (Pos('<link rel="stylesheet" type="text/css"',s1)>0) then sStyle := GetContent(s1, 'href=');

         // eingebettete Bilder
         if (Pos('<img src="images/',s1)>0) then begin
             slPic.Add(sPath + GetContent(s1, 'img src='));
             s1:=   GetLeft (s1,'<img src="images/') + '<img src="../images/' + GetRight (s1,'<img src="images/');
             bimgmodified := true;
         end;

         // Inhaltsverzeichnis
         if (Pos('<h1',s1)>0) then begin
               slCap.Add(sHTMLfileName+'#heading_id1_' + IntToStr(iHead) + '*' +ClearHeading(s1));
               s1:=   GetLeft (s1,'<h1') + '<h1 id="heading_id1_' + IntToStr(iHead)+ '"' + GetRight (s1,'<h1');
               iHead := iHead + 1;
               bmodified := true;
         end;
         if (Pos('<h2',s1)>0) then begin
               slCap.Add(sHTMLfileName+'#heading_id2_' + IntToStr(iHead) + '*' +ClearHeading(s1));
               s1:=   GetLeft (s1,'<h2') + '<h2 id="heading_id2_' + IntToStr(iHead) + '"' + GetRight (s1,'<h2');
               iHead := iHead + 1;
               bmodified := true;
         end;
         if (Pos('<h3',s1)>0) then begin
               slCap.Add(sHTMLfileName+'#heading_id3_' + IntToStr(iHead) + '*' +ClearHeading(s1));
               s1:=   GetLeft (s1,'<h3') + '<h3 id="heading_id3_' + IntToStr(iHead) + '"' + GetRight (s1,'<h3');
               iHead := iHead + 1;
               bmodified := true;
         end;
         if (Pos('<h4',s1)>0) then begin
               slCap.Add(sHTMLfileName+'#heading_id4_' + IntToStr(iHead) + '*' +ClearHeading(s1));
               s1:=   GetLeft (s1,'<h4') + '<h4 id="heading_id4_' + IntToStr(iHead) + '"' + GetRight (s1,'<h4');
               iHead := iHead + 1;
               bmodified := true;
         end;
         if s1<>'' then slTmp.Add(s1);
        end;

        if bmodified or bimgmodified then begin
           slTmp.SaveToFile(sHTMLFile);
        end;
        if NOT bmodified then begin
           //schreibe auch Html-Datei ohne Heading in Inhaltsverzeichnis!
           slCap.Add(sHTMLfileName+ '*' + ' ');
        end;


        CopyOne(sHTMLFile, sWorkOPShtml+'ebook_' + IntToStr(iHTMLFile) +'.html');
        iHTMLFile := iHTMLFile + 1;
        sHTMLFile := sFile + IntToStr(iHTMLFile) +'.html';
        sHTMLFileName := AnsiReplaceAll(sHTMLFile,ExtractFilePath(sHTMLfile),'');
      until  (not FileExists(sHTMLFile));
      slTmp.Free;


//### Erzeuge content.opf  -------------------------------------------------
        slOpf.LoadFromFile(sTemplP+'content.opf');

       //### update content.opf
       for i:=0 to slOpf.Count-1 do begin
           if (Pos('$TITLE',slOpf.strings[i])>0) then slOpf.strings[i] := AnsiReplaceAll(slOpf.strings[i],'$TITLE',sTitle);
           if (Pos('$AUTOR',slOpf.strings[i])>0) then slOpf.strings[i] := AnsiReplaceAll(slOpf.strings[i],'$AUTOR',sAuthor);
           ///if (Pos('$UUID',slOpf.strings[i])>0) then slOpf.strings[i] := AnsiReplaceAll(slOpf.strings[i],'$UUID',AnsiReplaceAll(AnsiReplaceAll(sAuthor+'-'+sTitle,',','-'),' ','-'));
           if (Pos('$UUID',slOpf.strings[i])>0) then slOpf.strings[i] := AnsiReplaceAll(slOpf.strings[i],'$UUID',sAuthor+' - '+sTitle);
       end;
       slOpf.Add (' <manifest>');
       slOpf.Add ('   <item id="ebook.css" href="styles/ebook.css"  media-type="text/css"/>');
       slOpf.Add ('   <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>');
       for i:= 1 to iHTMLFile - 1 do begin
           //z.B. slOpf.Add ('   <item id="ebook_1.html" href="text/ebook_1.html" media-type="application/xhtml+xml"/>');
           slOpf.Add ('   <item id="ebook_'+IntToStr(i)+'.html" href="text/ebook_'+IntToStr(i)+'.html" media-type="application/xhtml+xml"/>');
       end;

       // images
       for i:= 0 to slPic.Count - 1 do begin
           stmp:= ExtractFileName(slPic.Strings[i]);
           if Pos('.gif', stmp)>0 then slOpf.Add ('   <item id="image'+IntToStr(i)+'" href="images/'+ stmp +'" media-type="image/gif"/>');
           if Pos('.jpg', stmp)>0 then slOpf.Add ('   <item id="image'+IntToStr(i)+'" href="images/'+ stmp +'" media-type="image/jpeg"/>');
           if Pos('.svg', stmp)>0 then slOpf.Add ('   <item id="image'+IntToStr(i)+'" href="images/'+ stmp +'" media-type="image/svg"/>');
       end;
       slOpf.Add (' </manifest>');

       slOpf.Add (' <spine toc="ncx">');
       for i:= 1 to iHTMLFile - 1 do begin
           slOpf.Add ('   <itemref idref="ebook_'+IntToStr(i)+'.html"/>');
       end;
       slOpf.Add (' </spine>');

       slOpf.Add (' <guide>');
       slOpf.Add ('    <reference type="cover" title="Cover Page" href="text/ebook_1.html"/>');
       slOpf.Add (' </guide>');

       slOpf.Add ('</package>');


//### Erzeuge toc.ncx  -------------------------------------------------
      slToc.LoadFromFile(sTemplP+'toc.ncx');

     //### update toc.ncx
     for i:=0 to slToc.Count-1 do begin
         if (Pos('$BOOK',slToc.strings[i])>0) then slToc.strings[i] := AnsiReplaceAll(slToc.strings[i],'$BOOK',sTitle);
         //if (Pos('$UUID',slToc.strings[i])>0) then slToc.strings[i] := AnsiReplaceAll(slToc.strings[i],'$UUID',AnsiReplaceAll(AnsiReplaceAll(sAuthor+'-'+sTitle,',','-'),' ','-'));
         if (Pos('$UUID',slToc.strings[i])>0) then slToc.strings[i] := AnsiReplaceAll(slToc.strings[i],'$UUID',sAuthor+' - '+sTitle);
     end;

     slToc.Add ('   <navMap>');
     for i:= 0 to slCap.Count-1 do begin
         slToc.Add ('     <navPoint id="navPoint-'+IntToStr(i+1)+'" playOrder="'+IntToStr(i+1)+'">');
         slToc.Add ('        <navLabel>');

         stmp:= DelTags(GetRight(slCap.strings[i],'*'));
         stmp:= HTML4ToChar(stmp);
         slToc.Add ('           <text>'+ stmp + '</text>');
         slToc.Add ('        </navLabel>');

         stmp := DelTags(GetLeft(slCap.strings[i],'*'));
         slToc.Add ('        <content src="text/'+stmp+'"/>');
         slToc.Add ('     </navPoint>');
     end;

     slToc.Add ('   </navMap> ');
     slToc.Add ('</ncx>');


//###-----------------------------------------------

     //###  erzeuge epub-Container
     // Übetrage images in epub-Struktur
     if (slPic.Count > 0) then begin
        for i:=0 to slPic.Count-1 do begin
            CopyOne(slPic.Strings[i],sWorkOPSimg + ExtractFileName(slPic.Strings[i]));
        end;
     end;
     slOpf.SaveToFile(sWorkOPS+'content.opf');
     slToc.SaveToFile(sWorkOPS+'toc.ncx');
     CopyOne(ExtractFilePath(sFile) + sStyle, sWorkOPSstyle + sStyle);

     //slPic.SaveToFile(sWorkDir+'piclist.txt');
     //slCap.SaveToFile(sWorkDir+'h_list.txt');

     CopyOne(sTemplP+'templ.epub', sWorkDir+'templ.epub');

     RemoveEmptyDir (sWorkOPSimg);
     RemoveEmptyDir (sWorkOPSfont);
     RemoveEmptyDir (sWorkOPShtml);
     RemoveEmptyDir (sWorkOPSstyle);

     packit(sWorkGen,sWorkDir+'templ.epub');

     MakeDir(sResDir, false);
     CopyOne(sWorkDir+'templ.epub', sResDir+PathDelim+sResFile);
     ClearDir(sWorkDir);
     result := true;
end;



//-------------------------------------------------------------------------------------------
procedure TMakPub.CopyOne(sSrc, sDst: string);
begin
     ForceDirectory(ExtractFilePath(sDst));
     if ((not FileExists(sDst)) and FileExists(sSrc)) then CopyFile(pchar(sSrc),pchar(sDst));
end;
//-------------------------------------------------------------------------------------------
procedure TMakPub.MoveOne(sSrc, sDst: string);
begin
     ForceDirectory(ExtractFilePath(sDst));
     if ((not FileExists(sDst)) and FileExists(sSrc)) then begin
        CopyFile(pchar(sSrc),pchar(sDst));
        DeleteFile(pchar(sSrc));
     end;
end;
//-------------------------------------------------------------------------------------------
function TMakPub.GetContent(sSrc:string; sLookup:string):string;
var i,j:integer;
    bFlag:boolean;
begin
     Result := '';
     bFlag:=false;
     i := Pos(sLookup,sSrc);
     if (i>0) then begin
        for j:=i+Length(sLookup) to Length(sSrc) do begin
            if (bFlag) then begin
               if (sSrc[j]='"') then break
               else Result := Result + sSrc[j];
            end else bFlag := sSrc[j]='"';
        end;
     end;
end;
//-------------------------------------------------------------------------------------------
procedure TMakPub.MakeDir(sDir: string; bFlag: boolean);
begin
//###
// UTF8 konforme Verzeichnisanlage verwenden
// Ansonsten werde Verzeichnisse von Autoren mit Sonderzeichen unlesbar angelegt.
     if (not DirectoryExists(sDir)) then ForceDirectory(sDir)
     else if (bFlag) then ClearDir(sDir);
//     if (not DirectoryExists(sDir)) then CreateDir(sDir)
//     else if (bFlag) then ClearDir(sDir);
//###
end;
//-------------------------------------------------------------------------------------------
procedure TMakPub.ClearDir(sDir: string);
var sr : TSearchRec;
    iAttributes : integer;
begin
     if (DirectoryExists(sDir)) then begin
        iAttributes := faAnyFile;
        if (FindFirst(sDir+PathDelim+'*.*', iAttributes, sr) = 0) then begin
           repeat
	      if ((sr.Attr and iAttributes) = sr.Attr) then begin
                 DeleteFile(sDir + PathDelim + sr.Name);
              end;
	   until (FindNext(sr) <> 0);
	   FindClose(sr);
        end;
      end;
end;
//-------------------------------------------------------------------------------------------
procedure TMakPub.RemoveEmptyDir(sDir: string);
var sr : TSearchRec;
    iAttributes : integer;
    bIsEmpty : boolean;
begin
     bIsEmpty := true;
     if (DirectoryExists(sDir)) then begin
        iAttributes := faAnyFile;
        if (FindFirst(sDir+PathDelim+'*.*', iAttributes, sr) = 0) then begin
           repeat
              if (sr.Name<>'.') and (sr.Name<>'..') then bIsEmpty:=false;
	   until ((FindNext(sr) <> 0) or (Not bIsEmpty));
	   FindClose(sr);
           if bIsEmpty then DeleteDirectory(sDir, false);
        end;
      end;
end;

//-------------------------------------------------------------------------------------------
procedure TMakPub.Packit(sDst:string;sRes:string);
var
   AProcess: TProcess;
begin
   SetCurrentDir(sDst);
   AProcess := TProcess.Create(nil);
   {$IfDef Unix}
   AProcess.CommandLine := 'zip -r -u "' +  sRes + '" . -i *.*';
   {$EndIf}
   {$IfDef Win32}
   AProcess.CommandLine := '"' + sZip + '" -r -u ' + '"' + sRes + '" . -i *.*';
   {$EndIf}
   AProcess.Options := AProcess.Options + [poWaitOnExit,poNoConsole];
   AProcess.Execute;
   Sleep(500);
   AProcess.Free;
end;
//-------------------------------------------------------------------------------------------
end.

