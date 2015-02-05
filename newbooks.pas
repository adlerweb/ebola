unit newbooks;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,ComCtrls, helpers, inifiles;

type

  { TfrmNewbooks }

  TfrmNewbooks = class(TForm)
    Button1: TButton;
    btnClear: TButton;
    lstNewbooks: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure btnClearClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstNewbooksDblClick(Sender: TObject);
  private
    sFile : string;
  public
    procedure Save;
  end; 

var
  frmNewbooks: TfrmNewbooks;

implementation

uses unit1;
{ TfrmNewbooks }

procedure TfrmNewbooks.Button1Click(Sender: TObject);
begin
     frmNewbooks.Close;
end;

procedure TfrmNewbooks.FormCreate(Sender: TObject);
var     fIni  : TIniFile;
        sHelp : string;
begin
     lstNewbooks.Clear;
     sFile := ExtractFilePath(Application.ExeName) + 'newbooks';
     if (FileExists(sFile)) then lstNewbooks.Items.LoadFromFile(sFile);
     fIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
     if (fIni <> nil) then begin
         frmNewbooks.Width := fIni.ReadInteger('NewFrm','width',frmNewbooks.Width);
         frmNewbooks.Top := fIni.ReadInteger('NewFrm','top',frmNewbooks.Top);
         frmNewbooks.Height := fIni.ReadInteger('NewFrm','heigth',frmNewbooks.Height);
         frmNewbooks.Left := fIni.ReadInteger('NewFrm','left',frmNewbooks.Left);
         fIni.Free;
     end;

end;

procedure TfrmNewbooks.lstNewbooksDblClick(Sender: TObject);
var i, iSel:integer;
sT, sAutor, sTitel: string;
t, tChild:TTreeNode;
begin
     iSel:=-1;
     for i:=0 to lstNewbooks.Count-1 do if lstNewbooks.Selected[i] then begin
         iSel:=i;
         break;
     end;
     if (iSel >= 0) then begin
        sT := lstNewbooks.Items.Strings[iSel];
        i := pos(' - ',sT);
        sAutor := trim(copy(sT,1,i));
        sTitel := trim(copy(sT,i+3,65000));
        with frmMain do begin
               for i:=0 to trvSavedBooks.Items.Count-1 do begin
                   t := trvSavedBooks.Items.Item[i];
                     if (t.parent = nil) then begin
                        if (t.Text=sAutor) then begin
                           tChild:=t.GetFirstChild;
                           while ((tChild <> nil) and (tChild.Text<>sTitel)) do tChild:=t.GetNextChild(tChild);
                           if (tChild <> nil) then begin
                              tChild.Selected:=true;
                              trvSavedBooksDblClick(lstNewbooks);
                           end;
                        end;
                     end;
                   end;
               end;
     end;
end;

procedure TfrmNewbooks.Save;
begin
     lstNewbooks.Items.SaveToFile (sFile);
end;

procedure TfrmNewbooks.btnClearClick(Sender: TObject);
begin
     lstNewbooks.Clear;
     if (FileExists(sFile)) then Deletefile(sFile);
end;

initialization
  {$I newbooks.lrs}

end.

