unit Unit1; 
//-------------------------------------------------------------------------------------------
{$mode objfpc}{$H+}
//-------------------------------------------------------------------------------------------
interface

uses
  Classes, SysUtils,  LResources, Forms, Controls, Graphics, Dialogs, LCLType,        //### LCLType definiert MessageBox-Konstante
  StdCtrls, Menus, ExtCtrls, Buttons, ComCtrls, EditBtn, ActnList, Grids,
  Process, Inifiles, aboutform, MakPub, helpers, helpform,newbooks;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnCancel: TButton;
    btnDelOneInList: TSpeedButton;
    btnDelAllInList: TSpeedButton;
    btnDownloadEpub: TButton;
    btnSave2Eintrag: TButton;
    btnMaskeLeeren: TButton;
    btnSaveList: TSpeedButton;
    chkGutenberg: TCheckBox;
    chkZeno: TCheckBox;
    chkEpub: TCheckBox;
    chkXHTML: TCheckBox;
    cmbAutor: TComboBox;
    edtSuchfeld: TEdit;
    edtTitle: TEdit;
    edtUrl: TEdit;
    grpBooklist: TGroupBox;
    grpNeueingabe: TGroupBox;
    grpDownload: TGroupBox;
    Label1: TLabel;
    lblFortschritt: TLabel;
    Label3: TLabel;
    lblTitle: TLabel;
    lstProgress: TListBox;
    lstDownloads: TListBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    miSaveList: TMenuItem;
    miDoXHTML: TMenuItem;
    miDoEpub: TMenuItem;
    miStartDownload: TMenuItem;
    miDelMask: TMenuItem;
    miDelAktEntry: TMenuItem;
    MenuItem6: TMenuItem;
    miLog: TMenuItem;
    miDelList: TMenuItem;
    miAbout: TMenuItem;
    miHelp: TMenuItem;
    miInfo: TMenuItem;
    miOutput: TMenuItem;
    miCextra: TMenuItem;
    miOptions: TMenuItem;
    miSaveEintrag: TMenuItem;
    miDelAuswahl: TMenuItem;
    miBooklistdownload: TMenuItem;
    miBearbeiten: TMenuItem;
    MenuItem2: TMenuItem;
    miExit: TMenuItem;
    miLoad: TMenuItem;
    miSave: TMenuItem;
    miDatei: TMenuItem;
    dlgSelDir: TSelectDirectoryDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    pnlFortschritt: TPanel;
    pnlSuch: TPanel;
    btnSaveTree: TSpeedButton;
    btnReloadTree: TSpeedButton;
    btnDelTreeEntry: TSpeedButton;
    spltVer: TSplitter;
    stbStatus: TStatusBar;
    trvSavedBooks: TTreeView;
    procedure btnCancelClick(Sender: TObject);
    procedure btnDelAuswahlClick(Sender: TObject);
    procedure btnDelTreeEntryClick(Sender: TObject);
    procedure btnDownloadEpubClick(Sender: TObject);
    procedure btnMaskeLeerenClick(Sender: TObject);
    procedure btnSaveTreeClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnNewEintragClick(Sender: TObject);
    procedure btnDelListClick(Sender: TObject);
    procedure chkEpubChange(Sender: TObject);
    procedure edtSuchfeldChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lstDownloadsClick(Sender: TObject);
    procedure lstDownloadsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lstDownloadsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure MenuItem11Click(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miCextraClick(Sender: TObject);
    procedure miDelListClick(Sender: TObject);
    procedure miDoEpubClick(Sender: TObject);
    procedure miDoXHTMLClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure btnSaveEintragClick(Sender: TObject);
    procedure miHelpClick(Sender: TObject);
    procedure miLogClick(Sender: TObject);
    procedure miOutputClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure btnCopyBooklist(Sender: TObject);
    procedure btnCopyBooklistZeno(Sender: TObject);
    procedure Panel5Click(Sender: TObject);
    procedure pnlFortschrittClick(Sender: TObject);
    procedure pnlSuchResize(Sender: TObject);
    procedure trvSavedBooksDblClick(Sender: TObject);
    function  BookCounter():integer;

  private
         sCextraPath : string;
         sWgetPath   : string;
         bAbbruch    : boolean;
         bUpdateBookList     : boolean;                     //TRUE ... Änderungen in der Buchliste erfolgt
         bDlgFromDL          : boolean;
         function CheckEntry(pN:pBook):boolean;
         function CheckEntry(sAutor, sTitel:string):boolean;
         function CleanList(s:string):string;
         procedure Load;
         procedure Save;
         procedure UpdateCmb(cmbT:TComboBox);
         procedure SwitchGUI(b:boolean);
         procedure Download(sSrc:string);
         function AddToBooklist(pN:pBook) : boolean;        //true ... neues Buch hinzugefügt
         procedure AddEntry(Autor, Titel, URL : string);
         procedure DownloadAuthorList(sAutorfile, sSource : String);           //'Gutenberg' oder 'Zeno'
         procedure DownloadBookList(sAutorfile, sBookfile, sSource : String);  //'Gutenberg' oder 'Zeno'
         procedure CreateXHTMLFromSingleFiles(iKapCount: integer; iIndex: integer);
         procedure CreateHTMLFilesFromSingleFiles(iKapCount: integer; iIndex: integer);
         procedure CreateBookList(sSource : String);
         procedure ConvertTo(sSrc:string; pN:pBook; sType:string;var log:TStringList);
         procedure SwitchProgress(bFlag:boolean;bType:boolean);
         procedure AddFolderBook(pN : pBook);
  public

  end;

var
  frmMain: TfrmMain;

const
   READ_BYTES = 2048;

//-------------------------------------------------------------------------------------------
implementation


//-------------------------------------------------------------------------------------------
procedure TfrmMain.CreateXHTMLFromSingleFiles(iKapCount: integer; iIndex: integer);
var slIn, slOut : TStringList;
    i,j         : integer;
    sPath,sAkt  : string;
    pN          : pBook;
    bCopy       : boolean;
begin
     sPath := sOutputDir + 'temp'+PathDelim+IntToStr(iIndex)+PathDelim;
     slOut := TStringList.Create();
     slIn := TStringList.Create();
     pN := pBook(lstDownloads.Items.Objects[iIndex]);
     slOut.Add('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
     slOut.Add('<html xmlns="http://www.w3.org/1999/xhtml">');
     slOut.Add('   <head>');
     slOut.Add('        <title>'+pN^.sTitel+'</title>');
     slOut.Add('        <meta name="author" content="'+ pN^.sAutor +'" />');
     slOut.Add('        <meta name="publisher" content="$publisher" />');
     slOut.Add('        <meta name="description" content="'+pN^.sTitel+'" />');
     slOut.Add('        <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/" />');
     slOut.Add('        <meta content="text/html; charset=UTF-8" http-equiv="content-type" />');
     slOut.Add('        <meta name="DC.author" content="'+pN^.sAutor+'" />');
     slOut.Add('        <meta name="DC.title" content="'+pN^.sTitel+'" />');
     slOut.Add('        <meta name="DC.publisher" content="$publisher" />');
     slOut.Add('        <link rel="stylesheet" type="text/css" href="ebook.css" /><style type="text/css">');
     slOut.Add('        /*<![CDATA[*/');
     slOut.Add('        body.null2 {direction: ltr;}');
     slOut.Add('        p.null1 {font-style: italic}');
     slOut.Add('        /*]]>*/');
     slOut.Add('        </style>');
     slOut.Add('    </head>');
     slOut.Add('    <body class="null2">');
     slOut.Add('        <h1 class="author">'+pN^.sAutor+'</h1>');
     slOut.Add('        <h1 class="title">'+pN^.sTitel+'</h1>');

     for i:=1 to iKapCount do begin
         sAkt := sPath + IntToStr(i);
         if (FileExists(sAkt)) then begin
            slIn.Clear;
            slIn.LoadFromFile(sAkt);
            bCopy := false;
            for j:=0 to slIn.Count-1 do begin
                if ((bCopy) and(Pos('<script',slIn.Strings[j])>0)) then begin
                   bCopy := false;
                   slOut.Add('<p>&nbsp;</p>');
                end;
                if (Pos('<div id="gutenb">',slIn.Strings[j])>0) then bCopy:=true;
                if (bCopy) then begin
                  //#### erzeuge valide epub-Struktur (http://code.google.com/p/epubcheck/)
                  if (Pos('<div id="gutenb">',slIn.Strings[j])>0) then begin
                    //erzeuge eindeutige IDs, z.B. "gutenb_1", "gutenb_2"
                    slIn.Strings[j] := AnsiReplaceAll(slIn.Strings[j],'<div id="gutenb">','<div id="gutenb_'+ IntToStr(i) +'">');
                  end;
                  //####
                  slOut.Add(RepairTags(slIn.Strings[j]))
                end;

                //if (Pos('<option value="1"',slIn.Strings[j])>0) then begin
                //  bCopy := true;
                //end;
            end;
         end;
     end;
     slOut.Add('         <p class="end">- Ende -</p>');
     slOut.Add('    </body>');
     slOut.Add('</html>');
     slOut.SaveToFile(sPath + 'ebook.xhtml');
     slOut.Free;
     slIn.Free;
end;
//-------------------------------------------------------------------------------------------


//-------------------------------------------------------------------------------------------
procedure TfrmMain.CreateHTMLFilesFromSingleFiles(iKapCount: integer; iIndex: integer);
var slIn, slOut : TStringList;
    i,j, ia,ie  : integer;
    sPath,sAkt  : string;
    pN          : pBook;
    bCopy       : boolean;
    stmp        : string;
begin
     sPath := sOutputDir + 'temp'+PathDelim+IntToStr(iIndex)+PathDelim;
     slOut := TStringList.Create();
     slIn := TStringList.Create();
     pN := pBook(lstDownloads.Items.Objects[iIndex]);

     for i:=1 to iKapCount do begin
         sAkt := sPath + IntToStr(i);
         if (FileExists(sAkt)) then begin
            slOut.Clear;
            slOut.Add('<?xml version="1.0" encoding="UTF-8"?>');
            slOut.Add('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">');
            slOut.Add('<html xmlns="http://www.w3.org/1999/xhtml">');
            slOut.Add('   <head>');
            slOut.Add('        <title>'+pN^.sTitel+'</title>');
           if i = 1 then begin
              slOut.Add('        <meta name="description" content="'+pN^.sTitel+'" />');
              slOut.Add('        <meta name="DC.author" content="'+pN^.sAutor+'" />');
              slOut.Add('        <meta name="DC.title" content="'+pN^.sTitel+'" />');
              //slOut.Add('        <meta name="DC.publisher" content="$publisher" />');
            end;
            slOut.Add('        <meta name="generator" content="ebola ePub generator" />');
            slOut.Add('        <meta content="text/css" http-equiv="content-style-type" />');
            slOut.Add('        <link rel="stylesheet" type="text/css" href="../styles/ebook.css" />');
            slOut.Add('    </head>');
            slOut.Add('    <body>');

            slIn.Clear;
            slIn.LoadFromFile(sAkt);
            bCopy := false;
            for j:=0 to slIn.Count-1 do begin
                if ((bCopy) and(Pos('<script',slIn.Strings[j])>0)) then begin
                   bCopy := false;
                   slOut.Add('    </body>');
                   slOut.Add('</html>');
                end;
                if (bCopy) then begin

                  //entferne html-seitenzähler
                  if ((Pos('<a class="',slIn.Strings[j])>0) or (Pos('<a name="',slIn.Strings[j])>0)) then  begin
                    repeat
                      ia:= Pos ('<a', slIn.Strings[j]);
                      ie:= Pos ('</a>', slIn.Strings[j]);
                      if ie > ia then begin
                        stmp:= Copy(slIn.Strings[j], ia, ie-ia+4);
                        slIn.Strings[j] := AnsiReplaceAll(slIn.Strings[j],stmp,'');
                      end;
                    until (ie < ia) or ((Pos('<a class="',slIn.Strings[j])=0) and (Pos('<a name="',slIn.Strings[j])=0));
                  end;
                  slIn.Strings[j] := AnsiReplaceAll(slIn.Strings[j],' class="author"','');
                  slIn.Strings[j] := AnsiReplaceAll(slIn.Strings[j],' class="title"','');
                  slIn.Strings[j] := AnsiReplaceAll(slIn.Strings[j],' class="subtitle"','');
                  slIn.Strings[j] := AnsiReplaceAll(slIn.Strings[j],' align="right"','');
                  slIn.Strings[j] := AnsiReplaceAll(slIn.Strings[j],' align="left"','');
                  slIn.Strings[j] := AnsiReplaceAll(slIn.Strings[j],' align="center"','');

                  slOut.Add(RepairTags(slIn.Strings[j]))
                end;
                if (Pos('<div id="gutenb">',slIn.Strings[j])>0) then bCopy:=true;

                //if (Pos('<option value="1"',slIn.Strings[j])>0) then begin
                //  bCopy := true;
                //end;
            end;
            slOut.SaveToFile(sPath + 'ebook_' + IntToStr(i) + '.html');
         end;
     end;
     slOut.Free;
     slIn.Free;
end;

//-------------------------------------------------------------------------------------------

procedure TfrmMain.btnDownloadEpubClick(Sender: TObject);
var i, iCount,iMaxKap  : integer;
    pN : pBook;
    sCmd : string;
    sPics: string;
    sSrc : string;
    sUrl : string;
    log: TStringList;
    sTemplP : string;
    bXML    : boolean;
    bDLOk : boolean;
    iAktLine : integer;
begin
   if (lstDownloads.Count<=0) then exit;
   sTemplP := ExtractFilePath(Application.ExeName) + 'templates' + PathDelim;
   SwitchGUI(false);
   SwitchProgress(true,false);

   try
     log := TStringList.Create();
     MakeDir(sOutputDir + 'temp');
     log.Add('############### herunterladen ##################');
     for i:=0 to lstDownloads.Count-1 do begin
         if (bAbbruch) then break;
         bDLOk := true;
         pN := pBook(lstDownloads.Items.Objects[i]);
         bXML := (Pos('.xml',pN^.sUrl) <> 0);
         stbStatus.Panels[0].Text:='Download... ' + lstDownloads.Items[i];
         MakeDir(sOutputDir + 'temp'+PathDelim+IntToStr(i));
         iAktLine := lstProgress.Items.Add('Download: ' + lstDownloads.Items[i]);
         lstProgress.Selected[iAktLine] := true;
         Application.ProcessMessages;
         iMaxKap := 1;

         if (Pos('www.zeno.org',pN^.sUrl) > 0) then begin
            if (not FileExists(sCextraPath + 'cextra.jar')) then begin
                 lstProgress.Items.Strings[iAktLine] := 'Fehler, Cextra nicht gefunden: ' + lstDownloads.Items[i];
                 bDLOk := false;
            end else begin
              sCmd := 'java -jar "' + sCextraPath + 'cextra.jar" -f ' + pN^.sType + ' -a "' + pN^.sAutor + '" -t "' + pN^.sTitel + '" -u "' + pN^.sUrl + '" -o "' + sOutputDir + 'temp'+PathDelim+IntToStr(i)+'"';
              log.Add(sCmd);
              log.Add(DateTimeToStr(now));
              try
                 Download(sCmd);
              except
                 lstProgress.Items.Strings[iAktLine] := 'Fehler: ' + lstDownloads.Items[i];
                 bDLOk := false;
              end;
            end;
         end else begin
             iCount := 1;
             if (bXML) then sUrl := pN^.sUrl
             else sUrl := Copy(pN^.sUrl,1,Length(pN^.sUrl)-1);
             try
               repeat
                  if (bAbbruch) then break;
                  stbStatus.Panels[0].Text:='Download... ' + lstDownloads.Items[i] + ', Seite ' + IntToStr(iCount);
                  if (iCount > 1) then stbStatus.Panels[0].Text := stbStatus.Panels[0].Text + '/' +IntToStr(iMaxKap);
                  Application.ProcessMessages;

                  if ((iCount = 1) and (bXML)) then begin
                     sCmd := '"' + sWgetPath  + '" --user-agent="Mozilla/5.0 (X11; U; Linux i686; de; rv:1.9b5) Gecko/2008050509 Firefox/3.0b5" '  + sUrl  + ' -P "' +  sOutputDir + 'temp'+PathDelim+IntToStr(i) + '"';
                  end else begin       //verwende nun korrekte Adresse
                     sCmd := '"' + sWgetPath  + '" --user-agent="Mozilla/5.0 (X11; U; Linux i686; de; rv:1.9b5) Gecko/2008050509 Firefox/3.0b5" '  + sUrl + IntToStr(iCount) + ' -P "' +  sOutputDir + 'temp'+PathDelim+IntToStr(i) + '"';
                     sPics := '"' + sWgetPath + '" -nd -p --user-agent="Mozilla/5.0 (X11; U; Linux i686; de; rv:1.9b5) Gecko/2008050509 Firefox/3.0b5" -A jpg,jpeg,gif,png '  + sUrl + IntToStr(iCount) + ' -P ' + '"' + sOutputDir + 'temp'+PathDelim+IntToStr(i)+PathDelim+'images"';
                  end;
                  log.Add(DateTimeToStr(now));
                  log.Add(sCmd);
                  Download(sCmd);
                  Application.ProcessMessages;
                  if ((FileExists(sOutputDir + 'temp'+PathDelim+IntToStr(i)+PathDelim+IntToStr(iCount)))) then begin
                     if (iCount = 1) then begin
                         iMaxKap := GetKapCount(sOutputDir + 'temp'+PathDelim+IntToStr(i)+PathDelim+IntToStr(iCount));
                         if (bXML) then begin
                            sUrl := GetAdresse(sOutputDir + 'temp'+PathDelim+IntToStr(i)+PathDelim+IntToStr(iCount));
                            sPics := '"' + sWgetPath + '" -nd -p --user-agent="Mozilla/5.0 (X11; U; Linux i686; de; rv:1.9b5) Gecko/2008050509 Firefox/3.0b5" -A jpg,jpeg,gif,png '  + sUrl + IntToStr(iCount) + ' -P ' + '"' + sOutputDir + 'temp'+PathDelim+IntToStr(i)+PathDelim+'images"';
                         end;
                     end;
                  end else begin
                       log.Add('Fehler beim Download, ungültige URL');
                       lstProgress.Items.Strings[iAktLine] := 'Fehler: ' + lstDownloads.Items[i];
                       iMaxKap := iCount;
                       bDLOk := false;
                  end;
                  log.Add(sPics);
                  Download(sPics);
                  inc(iCount);
              until iCount > iMaxKap;
            except
                  lstProgress.Items.Strings[iAktLine] := 'Fehler: ' + lstDownloads.Items[i];
                  bDLOk := false;
            end;
         end;
         sSrc := sOutputDir + 'temp'+PathDelim+IntToStr(i)+PathDelim;
         if ((bDLOk) and (not bAbbruch)) then begin
               try
                  lstProgress.Items.Strings[iAktLine] := 'Konvertierung: ' + lstDownloads.Items[i];
                  stbStatus.Panels[0].Text:='Konvertierung...';
                  Application.ProcessMessages;
                  if (Pos('gutenberg',pN^.sUrl) > 0) then begin
                     CreateXHTMLFromSingleFiles(iMaxKap,i);
                     CreateHTMLFilesFromSingleFiles(iMaxKap,i);
                  end;
                  CopyOne(sTemplP + 'ebook.css',sOutputDir + 'temp'+PathDelim+IntToStr(i)+PathDelim+'ebook.css');
                  if (DirectoryExists(sSrc)) then begin
                     if (chkXHTML.Checked) then ConvertTo(sSrc,pN, 'XHTML', log);
                     if (chkEpub.Checked) then ConvertTo(sSrc,pN, 'Epub', log);
                     lstProgress.Items.Strings[iAktLine] := 'Fertig: ' + lstDownloads.Items[i];
                  end else begin
                      lstProgress.Items.Strings[iAktLine] := 'Fehler: ' + lstDownloads.Items[i];
                  end;
               except
                  lstProgress.Items.Strings[iAktLine] := 'Fehler: ' + lstDownloads.Items[i];
               end;
         end;
         ClearDir(sSrc);
     end;

     log.Add('############### fertig ##################');
     log.Add(DateTimeToStr(now));
     stbStatus.Panels[0].Text:='';
     if (miLog.Checked) then log.SaveToFile(ExtractFilePath(Application.ExeName)+'download.log');
     log.Clear;
     log.Free;
   finally
          ClearDir(sOutputDir + 'temp');
          SwitchGUI(true);
          SwitchProgress(false,false);
          Screen.Cursor:=crDefault;
   end;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.ConvertTo(sSrc:string;pN:pBook;sType:string;var log:TStringList);
var sDst:string;
    oMPub: TMakPub;
    sDir:string;
begin
     sDir :=  sOutputDir + sType + PathDelim;
     MakeDir(sDir);
     sDst := sDir + pN^.sDir;
     log.Add('Konvertierung ('+sType+'): ' + pN^.sTitel);
     MakeDir(sDst);
     if (sType = 'XHTML') then begin
          CopyOne(sSrc + 'ebook.xhtml',sDst + PathDelim + pN^.sTitel + '.xhtml');
          if (not FileExists(sDst + PathDelim + 'ebook.css')) and (FileExists(sSrc + 'ebook.css')) then CopyOne(sSrc + 'ebook.css', sDst + PathDelim + 'ebook.css');
          if (DirectoryExists(sSrc + PathDelim + 'images')) then CopyAll(sSrc + PathDelim + 'images',sDst + PathDelim + 'images');
     end else begin
           try begin
               if (Pos('www.zeno.org',pN^.sUrl) > 0) then begin
                  oMPub := TMakPub.Create(sSrc + 'ebook.xhtml', ExtractFilePath(Application.ExeName), false);
                  oMPub.DoRun(sDst,pN^.sTitel+'.epub');
               end else begin
                  oMPub := TMakPub.Create(sSrc + 'ebook_', ExtractFilePath(Application.ExeName), true);
                  oMPub.DoRunHTML(sDst,pN^.sTitel+'.epub');
               end;
           end finally
               oMPub.Destroy;
           end;
     end;
end;

//-------------------------------------------------------------------------------------------
procedure TfrmMain.btnMaskeLeerenClick(Sender: TObject);
begin
  btnNewEintragClick(Sender);
end;

//-------------------------------------------------------------------------------------------
procedure TfrmMain.btnSaveTreeClick(Sender: TObject);
begin
  Save;
end;


//-------------------------------------------------------------------------------------------
// Download der Buchliste auf Basis der Autorenliste von gutenberg.spiegel.de oder zeno.org
//
procedure TfrmMain.DownloadBookList(sAutorfile, sBookfile, sSource: String);
var
    slIn, slIn2, slOut : TStringList;
    sItem,sItem2       : string;
    i, j               : integer;
    sAkt, sAktName     : string;
    sAutor, sTitel, sUrl, sBookUrl: string;
    sListDir           : string;
    bCopy       : boolean;
    bBreak      : boolean;
    sCmd        : string;
    log         : TStringList;

begin
 try begin
   log := TStringList.Create();
   log.Add('############### '+ sSource +'-Buchliste je Autor erstellen ##################');
   slOut := TStringList.Create();
   slIn  := TStringList.Create();
   slIn2 := TStringList.Create();

   sBookUrl := '';
   sAkt     := sOutputDir + 'temp' + PathDelim + sAutorfile;

   if (FileExists(sAkt)) then begin
     slIn.Clear;
     slIn.LoadFromFile(sAkt);
     for i:=0 to slIn.Count-1 do begin
         if (bAbbruch) then break;
         sItem := slIn.Strings[i] ;
         if sItem <>'' then begin
            sUrl := GetLeft (sItem, '*');

            //###zeno-Url besitzt UTF8-Zeichen: wget klappt; FileExists klappt nicht!
            //###  --> Lösungsversuch: konvertiere utf8 nach char
            sUrl := UTF8ToChar(sUrl);            //zeno-Url besitzt UTF8-Zeichen:

            sAutor := GetRight (sItem, '*');
            stbStatus.Panels[0].Text:='Download... ' + AnsiToUTF8(sAutor);
            lblFortschritt.Caption:='Download... ' + AnsiToUTF8(sAutor);
            Application.ProcessMessages;
            sListDir:= sOutputDir + 'temp' +PathDelim+IntToStr(i);
            sCmd := '"' + sWgetPath  + '" --user-agent="Mozilla/5.0 (X11; U; Linux i686; de; rv:1.9b5) Gecko/2008050509 Firefox/3.0b5" '  + sUrl + ' -P "' +  sListDir + '"';
            log.Add(DateTimeToStr(now));
            log.Add(sCmd);
            Download(sCmd);
            Application.ProcessMessages;
            //----------    Seite der verfügbaren Bücher auswerten
            if sSource = 'Gutenberg' then sAktName := Copy(sUrl, Pos('/autor/',sUrl)+7, length(sUrl));
            if sSource = 'Zeno'      then sAktName := Copy(sUrl, Pos('/Literatur/M/',sUrl)+13, length(sUrl));

            sAktName := sListDir + PathDelim + sAktName;
            if (FileExists(sAktName)) then begin
               slIn2.Clear;
               slIn2.LoadFromFile(sAktName);
               bCopy := false;
               bBreak := false;
               for j:=0 to slIn2.Count-1 do begin
                   sItem2 := slIn2.Strings[j] ;
                   //------------------------------------------------------
                   if sSource = 'Gutenberg' then begin
                       //--- Spezialfall
                       if bBreak then begin
                         bBreak := false;
                         sItem2 := slIn2.Strings[j];
                         sItem2 := ClearTags(sItem2);
                         sTitel := GetRight (sItem2, '*');

                         slOut.Add (sAutor);
                         slOut.Add (ClearTitel(sTitel));
                         slOut.Add (ClearUrl(sBookUrl));
                       end;
                       if ((bCopy) and ((Pos('</div>',sItem2)>0) or (Pos('aufgegriffen',sItem2)>0))) then begin
                          bCopy := false;
                       end;
                       // Url für Druckexemplare NICHT berücksichtigen
                       if (bCopy and isValidItem(sItem2)) then begin
                          //Ein Url*Buchtitel im String!!!
                          sItem2:= ClearTags(sItem2);
                          sItem2:= ClearUrl(sItem2);
                          sBookUrl := ChangeOldLink(GetLeft (sItem2, '*'));
                          sTitel   := GetRight (sItem2, '*');
                          if sTitel = '' then begin
                             bBreak:= true;   //----------- Spezialfall:
                          end else begin
                             slOut.Add (sAutor);
                             slOut.Add (ClearTitel(sTitel));
                             slOut.Add (ClearUrl(sBookUrl));
                          end;
                       end;
                       if (Pos('<div class="archived">',sItem2)>0) then begin
                         bCopy := true;
                       end;
                   end; //'Gutenberg'
                   //------------------------------------------------------
                   if sSource = 'Zeno' then begin
                       if (Pos('<li><a href="/Literatur/M/',sItem2)>0) then begin
                          sItem2:= ClearTags(sItem2);
                          sItem2:= ClearUrl(sItem2);
                          // nicht erforderlich: sBookUrl := ChangeOldLink(GetLeft (sItem2, '*'));
                          sBookUrl := GetLeft (sItem2, '*');
                          sTitel   := GetRight (sItem2, '*');

                          //slOut.Add (sAutor+' (zeno.org)');
                          //slOut.Add (ClearTitel(sTitel));
                          slOut.Add (sAutor);
                          slOut.Add (ClearTitel(sTitel)+' (Zeno)');
                          slOut.Add (ClearUrl(sBookUrl));
                       end;
                   end; //'Zeno'
                   //------------------------------------------------------
               end;
            end;
         end;
     ClearDir(sListdir);
     end;
   end;

   //save Log-file
   //log.SaveToFile(sOutputDir + PathDelim + 'DownloadBookList.log');

   if (not bAbbruch) then begin
     //slOut.SaveToFile(sOutputDir + 'temp' + PathDelim + sBookfile);
     slOut.SaveToFile(sOutputDir + sBookfile);
   end;
 end finally
   log.Free;
   slOut.Free;
   slIn.Free;
   slIn2.Free;
   stbStatus.Panels[0].Text:='';
   lblFortschritt.Caption:='';
   Application.ProcessMessages;
 end;
end;

//-------------------------------------------------------------------------------------------
// Download der Autorenliste von 'Gutenberg' oder 'Zeno'
// fstueck; Juni 2012
procedure TfrmMain.DownloadAuthorList(sAutorfile, sSource : String);
var
    sCmd : string;
    sUrl : string;
    log  : TStringList;

begin
 try begin
   log := TStringList.Create();
   MakeDir(sOutputDir + 'temp');
   log.Add('############### ' + sSource + '-Autoren herunterladen ##################');

   if sSource = 'Zeno'      then sUrl:= 'http://www.zeno.org/Literatur/W/Inhaltsverzeichnis';
   if sSource = 'Gutenberg' then sUrl:= 'http://gutenberg.spiegel.de/autor';

   stbStatus.Panels[0].Text:='Download... ' + surl;
   lblFortschritt.Caption:='Download... ' + surl;
   Application.ProcessMessages;
   sCmd := '"' + sWgetPath  + '" --user-agent="Mozilla/5.0 (X11; U; Linux i686; de; rv:1.9b5) Gecko/2008050509 Firefox/3.0b5" '  + sUrl + ' -P "' +  sOutputDir + 'temp' + '"';
   log.Add(DateTimeToStr(now));
   log.Add(sCmd);
   Download(sCmd);
   Application.ProcessMessages;
   if (not bAbbruch) then begin
      CreateAuthorList(sOutputDir, sAutorfile, sSource);
      log.Add('############### fertig ##################');
      log.Add(DateTimeToStr(now));
   end;
 end finally
   stbStatus.Panels[0].Text:='';
   lblFortschritt.Caption:='';
   Application.ProcessMessages;
 end;
end;


//-------------------------------------------------------------------------------------------
procedure TfrmMain.SwitchGUI(b:boolean);
begin
     miDatei.Enabled:=b;
     miBearbeiten.Enabled:=b;
     miOptions.Enabled:=b;
     grpBooklist.Enabled:=b;
     grpDownload.Enabled:=b;
     grpNeueingabe.Enabled:=b;
     btnSaveTree.Enabled:=b;
     btnReloadTree.Enabled:=b;
     btnDelTreeEntry.Enabled:=b;
     btnSaveList.Enabled:=b;
     btnSaveList.Enabled:=b;
     btnDelOneInList.Enabled:=b;
     btnDelAllInList.Enabled:=b;
     chkEpub.Enabled:=b;
     chkXHTML.Enabled:=b;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.btnLoadClick(Sender: TObject);
begin
     if bUpdateBookList then begin
        //Änderungen in Buchliste verwerfen?
        if (Application.MessageBox('Änderungen in der Buchliste verwerfen?','Ebola: Frage',MB_YESNO + MB_ICONQUESTION) = ID_YES) then begin
          Load;
          edtSuchfeldChange(Sender);
        end;
     end else begin
        Load;
        edtSuchfeldChange(Sender);
     end;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.Download(sSrc:string);
var
   AProcess: TProcess;
begin
   SetCurrentDir(ExtractFilePath(Application.ExeName));
   AProcess := TProcess.Create(nil);
   AProcess.CommandLine := sSrc;
   AProcess.Options := AProcess.Options + [poWaitOnExit,poNoConsole];
   AProcess.Execute;
   Sleep(500);
   AProcess.Free;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.btnNewClick(Sender: TObject);
var pN : pBook;
    i  : integer;
begin
     with lstDownloads do begin
          for i:=0 to Count-1 do begin
             pN := pBook(Items.Objects[0]);
             if (pN <> nil) then dispose(pN);
             Items.Delete(0);
          end;
     end;
     btnNewEintragClick(Sender);
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.btnNewEintragClick(Sender: TObject);
begin
     cmbAutor.Text:='';
     edtTitle.Text:='';
     edtUrl.Text:='';
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.btnDelListClick(Sender: TObject);
var  i  : integer;
begin
     with lstDownloads do begin
          for i:= Count-1 downto 0 do begin
             ItemIndex := i;
             btnDelAuswahlClick(Sender);
          end;
     end;
end;

//-------------------------------------------------------------------------------------------
// Autorliste und Buchliste erzeugen sowie in SavedBooks laden
procedure TfrmMain.btnCopyBooklist(Sender: TObject);
begin
   CreateBookList('Gutenberg');
end;

//-------------------------------------------------------------------------------------------
//         ##### zeno.org #####
// Autorliste und Buchliste erzeugen sowie in SavedBooks laden
//        CreateBookList
procedure TfrmMain.btnCopyBooklistZeno(Sender: TObject);
begin
   CreateBookList('Zeno');
end;

procedure TfrmMain.Panel5Click(Sender: TObject);
begin

end;

procedure TfrmMain.pnlFortschrittClick(Sender: TObject);
begin

end;


//-------------------------------------------------------------------------------------------
// Nur neue Bücher werden in die Buchliste integriert
//-------------------------------------------------------------------------------------------
function TfrmMain.AddToBooklist(pN:pBook) :boolean;
var j:integer;
    bSub : boolean;
    trnA : TTreeNode;
begin
  result := False;    //default: kein neues Buch
  if (not CheckEntry(pN)) then begin
     bSub := false;
     for j:=0 to trvSavedBooks.Items.Count-1 do begin
         if (trvSavedBooks.Items.Item[j].Text = pN^.sAutor) then begin
            if (not bSub) then begin
               bSub := true;
               trnA := trvSavedBooks.Items.Item[j];
               break;
            end;
         end;
     end;
     if (not bSub) then trnA := trvSavedBooks.Items.Add(nil,pN^.sAutor);
     // ein neues Buch wird integriert
     trvSavedBooks.Items.AddChildObject(trnA, pN^.sTitel, pN);
     result := True;
     bUpdateBookList := True;   //###  Erweiterung der Buchliste erfolgt
  end;
end;
//-------------------------------------------------------------------------------------------

procedure TfrmMain.pnlSuchResize(Sender: TObject);
begin
  edtSuchfeld.Width:= pnlSuch.ClientWidth - 10 - btnDelTreeEntry.left - btnDelTreeEntry.width;
end;

//-------------------------------------------------------------------------------------------
procedure TfrmMain.chkEpubChange(Sender: TObject);
begin
     btnDownloadEpub.Enabled:=chkEpub.Checked or chkXHTML.Checked;
     miDoEpub.Checked:=chkEpub.Checked;
     miDoXHTML.Checked:=chkXHTML.Checked;
end;

procedure TfrmMain.edtSuchfeldChange(Sender: TObject);
var i:integer;
    t:TTreeNode;
    s,a:string;
    b:boolean;
begin
   s := uppercase(edtSuchfeld.Text);
   if (length(s)>0) then begin
     b:=false;
     for i:=0 to trvSavedBooks.Items.Count-1 do begin
         t := trvSavedBooks.Items.Item[i];
         if (t.parent = nil) then begin
            a:=uppercase(t.Text);
            if (Pos(s,a)=1) then begin
               t.Selected:=true;
               b:=true;
               break;
            end;
         end;
     end;
     if (not b) then begin
        edtSuchfeld.SelStart:= length(edtSuchfeld.Text)-1;
        edtSuchfeld.SelLength:=1;
     end;
   end else begin
       if  trvSavedBooks.Items.Count > 0 then trvSavedBooks.Items.Item[0].Selected:=true;
   end;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var fIni : TIniFile;
begin
     fIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
     if (fIni <> nil) then begin
         fIni.WriteString('Pfade','cextra',sCextraPath);
         fIni.WriteInteger('AppFrm','width',frmMain.Width);
         fIni.WriteInteger('AppFrm','top',frmMain.Top);
         fIni.WriteInteger('AppFrm','heigth',frmMain.Height);
         fIni.WriteInteger('AppFrm','left',frmMain.Left);
         fIni.WriteBool('AppFrm','state',frmMain.WindowState=wsMaximized);
         fIni.WriteInteger('NewFrm','width',frmNewbooks.Width);
         fIni.WriteInteger('NewFrm','top',frmNewbooks.Top);
         fIni.WriteInteger('NewFrm','heigth',frmNewbooks.Height);
         fIni.WriteInteger('NewFrm','left',frmNewbooks.Left);
         fIni.WriteBool('NewFrm','state',frmNewbooks.WindowState=wsMaximized);
         fIni.WriteBool('HlpFrm','state',frmHelp.WindowState=wsMaximized);
         fIni.WriteInteger('AppFrm','vsplit',grpBooklist.width);
         fIni.WriteInteger('HlpFrm','width',frmHelp.Width);
         fIni.WriteInteger('HlpFrm','top',frmHelp.Top);
         fIni.WriteInteger('HlpFrm','heigth',frmHelp.Height);
         fIni.WriteInteger('HlpFrm','left',frmHelp.Left);
         fIni.WriteBool('Optionen','xhtml',chkXHTML.Checked);
         fIni.WriteBool('Optionen','epub',chkEPub.Checked);
         fIni.WriteBool('Optionen','Log',miLog.Checked);
         fIni.WriteBool('Optionen','Gutenberg',chkGutenberg.Checked);
         fIni.WriteBool('Optionen','Zeno',chkZeno.Checked);
     end;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.btnDelAuswahlClick(Sender: TObject);
var pN : pBook;
begin
     with lstDownloads do begin
          if (ItemIndex > -1) then begin
             pN := pBook(Items.Objects[ItemIndex]);
             dispose(pN);
             Items.Delete(ItemIndex);
          end;
     end;
     btnNewEintragClick(Sender);
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.SwitchProgress(bFlag:boolean;bType:boolean);
begin
     lblFortschritt.Caption:='';
     lstProgress.Clear;
     pnlFortschritt.Visible:=bFlag;
     btnCancel.Enabled:=bFlag;
     lblFortschritt.Visible:=bType;
     lstProgress.Visible:=not bType;
     bDlgFromDL := not bType;
     Application.ProcessMessages;
     bAbbruch := false;
     FormResize(self);
end;

//-------------------------------------------------------------------------------------------
procedure TfrmMain.btnCancelClick(Sender: TObject);
begin
  bAbbruch := true;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.btnDelTreeEntryClick(Sender: TObject);
var oP:TTreeNode;
begin
     If (trvSavedBooks.Selected <> nil) then begin
        oP := trvSavedBooks.Selected.Parent;
        trvSavedBooks.Selected.Delete;
        if ((oP<>nil) and (not oP.HasChildren)) then oP.Delete;
        bUpdateBookList := True;
        grpBooklist.Caption := 'Buchliste ('+IntToStr(BookCounter())+')';
     end;
end;

//-------------------------------------------------------------------------------------------
procedure TfrmMain.FormCreate(Sender: TObject);
var fIni  : TIniFile;
begin
     Screen.Cursor:=crHourglass;
     cmbAutor.Items.LoadFromFile(ExtractFilePath(Application.ExeName)+'autoren');
     sCextraPath := ExtractFilePath(Application.ExeName)+PathDelim+'cextra';
     sOutputDir := ExtractFilePath(Application.ExeName) + 'output'+PathDelim;
     sWgetPath := 'wget';
     {$IfDef Win32}
     sWgetPath := ExtractFilePath(Application.ExeName) + 'wget'+PathDelim + 'wget.exe';
     {$EndIf}
     fIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
     if (fIni <> nil) then begin
         sCextraPath := fIni.ReadString('Pfade','cextra',sCextraPath);
         sWgetPath := fIni.ReadString('Pfade','wget',sWgetPath);
         frmMain.Width := fIni.ReadInteger('AppFrm','width',frmMain.Width);
         frmMain.Top := fIni.ReadInteger('AppFrm','top',frmMain.Top);
         frmMain.Height := fIni.ReadInteger('AppFrm','heigth',frmMain.Height);
         frmMain.Left := fIni.ReadInteger('AppFrm','left',frmMain.Left);
         grpBooklist.width := fIni.ReadInteger('AppFrm','vsplit',220);
         chkXHTML.Checked := fIni.ReadBool('Optionen','xhtml',false);
         chkEPub.Checked := fIni.ReadBool('Optionen','epub',true);
         miLog.Checked := fIni.ReadBool('Optionen','Log',true);
         chkGutenberg.Checked := fIni.ReadBool('Optionen','Gutenberg',true);
         chkZeno.Checked := fIni.ReadBool('Optionen','Zeno',true);
         chkEpubChange(Sender);
     end;
     Application.ProcessMessages;
     Load;
     Screen.Cursor:=crDefault;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.FormResize(Sender: TObject);
begin
     edtTitle.Width:=grpNeueingabe.ClientWidth-edtTitle.Left-10;
     edtUrl.Width:=grpNeueingabe.ClientWidth-edtUrl.Left-10;
     pnlFortschritt.Width:=(5*frmMain.ClientWidth) div 6;
     pnlFortschritt.left:=frmMain.ClientWidth div 12;
     if (bDlgFromDL) then begin
        pnlFortschritt.height:=frmMain.Clientheight div 2;
        pnlFortschritt.top:=frmMain.Clientheight div 6;
     end else begin
        pnlFortschritt.height:=frmMain.Clientheight div 6;
        pnlFortschritt.top:=frmMain.Clientheight div 3;
     end;
     btnCancel.Width:=pnlFortschritt.ClientWidth div 4;
     btnCancel.left:=(3 * pnlFortschritt.ClientWidth) div 8;
end;

//-------------------------------------------------------------------------------------------
procedure TfrmMain.lstDownloadsClick(Sender: TObject);
var pN : pBook;
begin
     with lstDownloads do begin
          if ((Count > 0) and (ItemIndex>=0)) then begin
             pN := pBook(Items.Objects[ItemIndex]);
             if (pN <> nil) then begin
                edtTitle.Text:=pN^.sTitel;
                edtUrl.Text:=pN^.sUrl;
                cmbAutor.Text:=pN^.sAutor;
             end;
          end;
     end;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.lstDownloadsDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
   trvSavedBooksDblClick(Sender);
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.lstDownloadsDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := True;
end;

procedure TfrmMain.MenuItem11Click(Sender: TObject);
begin
  frmNewbooks.Show;
end;

//-------------------------------------------------------------------------------------------
procedure TfrmMain.miAboutClick(Sender: TObject);
begin
  frmAbout.ShowModal;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.miCextraClick(Sender: TObject);
begin
  dlgSelDir.FileName := sCextraPath;
  if (dlgSelDir.Execute) then begin
     sCextraPath := dlgSelDir.FileName+PathDelim;
  end;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.miDelListClick(Sender: TObject);
var pN : pBook;
    i  : integer;
begin
     with lstDownloads do begin
          for i:=0 to Count-1 do begin
             pN := pBook(Items.Objects[0]);
             dispose(pN);
             Items.Delete(0);
          end;
     end;
     btnNewEintragClick(Sender);
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.miDoEpubClick(Sender: TObject);
begin
     chkEpub.Checked := not chkEpub.Checked;
end;

procedure TfrmMain.miDoXHTMLClick(Sender: TObject);
begin
     chkXHTML.Checked := not chkXHTML.Checked;
end;

//-------------------------------------------------------------------------------------------
procedure TfrmMain.miExitClick(Sender: TObject);
begin
  if bUpdateBookList then begin
  //MessageBox "Speichern Ja/Nein?";
     if (Application.MessageBox('Änderungen in der Buchliste verwerfen?','Ebola: Frage',MB_YESNO + MB_ICONQUESTION) = ID_YES) then begin
       frmMain.Close;
     end;
  end else begin
       frmMain.Close;
  end;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.UpdateCmb(cmbT:TComboBox);
var i : integer;
    bCmbEx : boolean;
begin
     bCmbEx:=true;
	  for i := 0 to cmbT.Items.Count-1 do begin
		if (cmbT.Items.Strings[i] = cmbT.Text) then begin
			bCmbEx := false;
			break;
		end;
	  end;
	  if (bCmbEx) then cmbT.Items.Add(cmbT.Text);
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.AddEntry(Autor,Titel, URL : string);
var pN : pBook;
    sCap : String;
    iInd : integer;
begin
  if ((Autor <> '') and (Titel <>'') and (URL <>'')) then begin
     Screen.Cursor:=crHourglass;
     sCap := Autor + ' - ' + Titel;
     iInd := lstDownloads.Items.IndexOf(sCap);
     if (iInd >= 0) then pN := pBook(lstDownloads.Items.Objects[iInd])
     else new(pN);
     if (pN = nil) then new(pN);
     with pN^ do begin
       sAutor := Autor;
       sTitel := Titel;
       sUrl   := URL;
       sType  := 'default';
       if (Pos('gutenberg',sUrl)>0) then sType := 'gb_de'
       else if (Pos('zeno',sUrl)>0) then sType := 'zeno';
       sDir := AnsiReplaceAll(AnsiReplaceAll(sAutor,',',''),'  ',' ');
     end;
     if (iInd < 0) then lstDownloads.Items.AddObject(sCap,TObject(pN));
     UpdateCmb(cmbAutor);
     Screen.Cursor:=crDefault;
  end;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.btnSaveEintragClick(Sender: TObject);
begin
     AddEntry(cmbAutor.Text,edtTitle.Text,edtUrl.Text);
     btnNewEintragClick(Sender);
end;

procedure TfrmMain.miHelpClick(Sender: TObject);
begin
  frmHelp.Show;
end;

procedure TfrmMain.miLogClick(Sender: TObject);
begin
     miLog.checked := not miLog.checked;
end;

//-------------------------------------------------------------------------------------------
procedure TfrmMain.miOutputClick(Sender: TObject);
begin
  dlgSelDir.FileName := sOutputDir;
  if (dlgSelDir.Execute) then begin
     sOutputDir := dlgSelDir.FileName+PathDelim;
  end;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.miSaveClick(Sender: TObject);
var i:integer;
    pN : pBook;
    pT : pBook;
    icount : integer;
begin
  Screen.Cursor:=crHourglass;
  icount := 0;
  if (lstDownloads.Count > 0) then begin
        for i:=0 to lstDownloads.Count-1 do begin
            //nur neues Buch wird in Buchliste integriert
            pT := pBook(lstDownloads.Items.Objects[i]);
            new(pN);
            pN^.sAutor := pT^.sAutor;
	    pN^.sTitel := pT^.sTitel;
	    pN^.sUrl   := pT^.sUrl;
            if (AddToBookList(pN)) then  icount := icount + 1;
        end;
  end;
  if icount > 0 then grpBooklist.Caption := 'Buchliste ('+IntToStr(BookCounter())+' - davon neu: '+ IntToStr(icount) +')';

  trvSavedBooks.AlphaSort;
  Screen.Cursor:=crDefault;
  Screen.Cursor:=crDefault;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.trvSavedBooksDblClick(Sender: TObject);
var trnA, trnCh : TTreeNode;
    pN : pBook;

begin
   trnA := trvSavedBooks.Selected;
   if (trnA <> nil) then begin
     pN := pBook(trnA.Data);
     if (pN <> nil) then begin
        frmMain.AddEntry(pN^.sAutor,pN^.sTitel,pN^.sUrl);
     end else begin
         trnCh := trnA.GetFirstChild;
         if (trnCh <> nil) then begin
            pN := pBook(trnCh.Data);
            if (pN <> nil) then AddFolderBook(pN);
            repeat
                  trnCh := trnA.GetNextChild(trnCh);
                  if (trnCh <> nil) then begin
                     pN := pBook(trnCh.Data);
                     if (pN <> nil) then AddFolderBook(pN);
                  end;
            until (trnCh = nil);
         end;
     end;
   end;
end;

//-------------------------------------------------------------------------------------------
procedure TfrmMain.AddFolderBook(pN : pBook);
begin
     if ((pos('zeno',pN^.sUrl)>0) and (chkZeno.Checked)) then frmMain.AddEntry(pN^.sAutor,pN^.sTitel,pN^.sUrl);
     if ((pos('gutenberg',pN^.sUrl)>0) and (chkGutenberg.Checked)) then frmMain.AddEntry(pN^.sAutor,pN^.sTitel,pN^.sUrl);
end;
//-------------------------------------------------------------------------------------------
// Zähle nur die Bücher; die Autoren werden nicht berücksichtigt
//
function TfrmMain.BookCounter():integer;
var      i,icount : integer;
         pN : pBook;
begin
 iCount := 0;
 for i:=0 to trvSavedBooks.Items.Count-1 do begin
     pN :=  pBook(trvSavedBooks.Items.Item[i].Data);
     if (pN <> nil) then begin
        if ((pN^.sUrl <> '') and (pN^.sTitel <> '')) then begin
           iCount := iCount + 1;
        end;
     end;
 end;
 result := iCount;
end;


//-------------------------------------------------------------------------------------------
function TfrmMain.CleanList(s:string):string;
var slT1, slT2:TStringList;
    i :integer;
begin
     slT1 := TStringList.Create;
     slT2 := TStringList.Create;
     slT2.Sorted:=true;
     slT2.Duplicates:=dupIgnore;
     slT1.Text:=s;
     i:=0;
     while (i<slT1.Count-1) do begin
           slT2.Add(slT1.Strings[i] + '###' + slT1.Strings[i+1] + '###' + slT1.Strings[i+2]);
           inc(i,3);
     end;
     slT1.Text := AnsiReplaceAll(slT2.Text,'###',#13);
     Result := slT1.Text;
     slT1.Free;
     slT2.Free;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.Save;
var i    : integer;
    slTmp:TStringList;
    pN    : pBook;
begin
  bUpdateBookList := False;
  slTmp := TStringList.Create;
  for i:=0 to trvSavedBooks.Items.Count-1 do begin
      if (trvSavedBooks.Items.Item[i].HasChildren = false) then begin
         pN := trvSavedBooks.Items.Item[i].Data;
         slTmp.Add(pN^.sAutor);
         slTmp.Add(pN^.sTitel);
         slTmp.Add(pN^.sUrl);
      end;
  end;
  grpBooklist.Caption := 'Buchliste ('+IntToStr(BookCounter())+')';
  slTmp.SaveToFile(ExtractFilePath(Application.ExeName) + 'SavedBooks');
  slTmp.Clear;
  slTmp.Free;
end;
//-------------------------------------------------------------------------------------------
procedure TfrmMain.Load;
var i,j : integer;
    sFile : string;
    pN : pBook;
    sAutor, sTitel, sUrl : String;
    bSub : boolean;
    trnA : TTreeNode;
    slTmp:TStringList;
begin
     bUpdateBookList := False;
     Screen.Cursor := crHourGlass;
     trvSavedBooks.Items.Clear;
     trvSavedBooks.SortType:=stNone;
     trvSavedBooks.Visible:=false;
     slTmp := TStringList.Create;
     sFile := ExtractFilePath(Application.ExeName) + 'SavedBooks';
     if (FileExists(sFile)) then slTmp.LoadFromFile(sFile);
     i:=0;
     while (i<slTmp.Count-2) do begin
              sAutor := slTmp.Strings[i];
              sTitel := slTmp.Strings[i+1];
              sUrl := slTmp.Strings[i+2];
              if ((sAutor <> '') and (sTitel<>'') and (sUrl<>'')) then begin
                 new(pN);
                 pN^.sAutor:=sAutor;
                 pN^.sTitel:=sTitel;
                 pN^.sUrl:=sUrl;
                 bSub := false;
                 for j:=0 to trvSavedBooks.Items.Count-1 do begin
                     if (trvSavedBooks.Items.Item[j].Text = pN^.sAutor) then begin
                        bSub := true;
                        trnA := trvSavedBooks.Items.Item[j];
                        break;
                     end;
                 end;
                 if (not bSub) then begin
                     trnA := trvSavedBooks.Items.Add(nil,pN^.sAutor);
                 end;
                 trvSavedBooks.Items.AddChildObject(trnA, pN^.sTitel, pN);
              end;
              inc(i,3);
     end;
     trvSavedBooks.SortType := stText;
     trvSavedBooks.AlphaSort;
     trvSavedBooks.Visible:=true;
     slTmp.Clear;
     slTmp.Free;
     Screen.Cursor:= crDefault;
     grpBooklist.Caption := 'Buchliste ('+IntToStr(BookCounter())+')';
end;
//-------------------------------------------------------------------------------------------
function TfrmMain.CheckEntry(pN:pBook):boolean;
var i : integer;
    pX : pBook;
begin
     Result := false;
     for i:=0 to trvSavedBooks.Items.Count-1 do begin
         pX :=  pBook(trvSavedBooks.Items.Item[i].Data);
         if (pX <> nil) and (pN <> nil) then begin
            if ((pX^.sUrl = pN^.sUrl) and (pX^.sAutor = pN^.sAutor) and (pX^.sTitel = pN^.sTitel)) then begin
               Result := true;
               break;
            end;
         end;
     end;
end;
//-------------------------------------------------------------------------------------------
function TfrmMain.CheckEntry(sAutor, sTitel:string):boolean;
var i : integer;
    pX : pBook;
begin
     Result := false;
     for i:=0 to trvSavedBooks.Items.Count-1 do begin
         pX :=  pBook(trvSavedBooks.Items.Item[i].Data);
         if (pX <> nil) then begin
            if ((pX^.sAutor = sAutor) and (pX^.sTitel = sTitel)) then begin
               Result := true;
               break;
            end;
         end;
     end;
end;
//-------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
// Update Buchliste mit Büchern von 'Gutenberg' oder 'Zeno'
// Input: sSource = ['Zeno', 'Gutenberg']

procedure TfrmMain.CreateBookList(sSource : String);
var i:integer;
    slIn : TStringList;
    sAutor, sTitel, sUrl : String;
    pN : pBook;
    sAutorfile, sBookfile : String;
    icount : integer;

begin
      if (Application.MessageBox('Die Liste aller Bücher sämtlicher Autoren herunterzuladen, kann schon mal ein halbes Stündchen dauern.'+sLineBreak+'>>Willst Du das jetzt wirklich machen?','Ebola: Hinweis',MB_YESNO + MB_ICONWARNING) = ID_YES) then begin
        bAbbruch := false;
	SwitchGUI(false);
        SwitchProgress(true,true);

        sAutorfile := '';
        sBookfile := '';
        if sSource = 'Gutenberg' then begin sAutorfile := 'Autorliste.txt';     sBookfile := 'Buchliste.txt'; end;
        if sSource = 'Zeno'      then begin sAutorfile := 'AutorlisteZeno.txt'; sBookfile := 'BuchlisteZeno.txt'; end;


        //erzeuge Autorliste
        DownloadAuthorList(sAutorfile, sSource);

        // erzeuge Buchliste auf Basis der Autorliste
        if (not bAbbruch) then  DownloadBookList(sAutorfile, sBookfile, sSource);
        frmNewbooks.btnClearClick(frmMain);
        // übertrage neue Bücher in den "Buchbaum"
        if ((not bAbbruch) and (FileExists(sOutputDir + sBookfile))) then begin
	   trvSavedBooks.Visible:=false;
	   trvSavedBooks.SortType := stNone;
	   stbStatus.Panels[0].Text:='neue Einträge in die Buchliste übernehmen...';
           lblFortschritt.Caption:='neue Einträge in die Buchliste übernehmen...';
	   Application.ProcessMessages;
	   i:=0;
           icount:=0;    //Anzahl neue Bücher in Buchliste;
	   slIn := TStringList.Create;
	   slIn.LoadFromFile(sOutputDir+sBookfile);
	   while (i<slIn.Count-2) do begin
	            sAutor := DoFilenamecomp(AnsiToUTF8(slIn.Strings[i]));
	            sTitel := DoFilenamecomp(AnsiToUTF8(slIn.Strings[i+1]));
	            sUrl := AnsiToUTF8(slIn.Strings[i+2]);
	            if ((sAutor <> '') and (sTitel<>'') and (sUrl<>'')) then begin
	               new(pN);
	               pN^.sAutor := sAutor;
	               pN^.sTitel := sTitel;
	               pN^.sUrl   := sUrl;
	               if AddToBooklist(pN) then begin
                          icount := icount + 1;
                          frmNewbooks.lstNewbooks.Items.Add(sAutor + ' - ' + sTitel);
                       end;
	            end;
	            inc(i,3);
                     if (i mod 100 = 0) then begin
                        Application.ProcessMessages;
                        if (bAbbruch) then break;
                     end;
	   end;
           if icount > 0 then grpBooklist.Caption := 'Buchliste ('+IntToStr(BookCounter())+' - davon neu: '+ IntToStr(icount) +')';
	   trvSavedBooks.SortType := stText;
	   trvSavedBooks.Visible:=true;
           if (iCount>0) then begin
              frmNewbooks.Save;
              frmNewbooks.Show;
           end;
	end;

        ClearDir(sOutputDir + 'temp');
	trvSavedBooks.AlphaSort;
        DeleteFile(sOutputDir + sBookfile);
        btnSaveTreeClick(self);
	SwitchGUI(true);
	Screen.Cursor:=crDefault;
	stbStatus.Panels[0].Text:='';
        SwitchProgress(false,true);
        bAbbruch := false;
     end;
end;




//-------------------------------------------------------------------------------------------
initialization
  {$I unit1.lrs}
//-------------------------------------------------------------------------------------------
end.

