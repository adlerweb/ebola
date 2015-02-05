unit helpform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, inifiles;

type

  { TfrmHelp }

  TfrmHelp = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmHelp: TfrmHelp;

implementation

{ TfrmHelp }

procedure TfrmHelp.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TfrmHelp.FormCreate(Sender: TObject);
var     fIni  : TIniFile;
        sHelp : string;
begin
     fIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
     if (fIni <> nil) then begin
         frmHelp.Width := fIni.ReadInteger('HlpFrm','width',frmHelp.Width);
         frmHelp.Top := fIni.ReadInteger('HlpFrm','top',frmHelp.Top);
         frmHelp.Height := fIni.ReadInteger('HlpFrm','heigth',frmHelp.Height);
         frmHelp.Left := fIni.ReadInteger('HlpFrm','left',frmHelp.Left);
         fIni.Free;
     end;
     sHelp := ExtractFilePath(Application.ExeName)+'hilfe';
     if (FileExists(sHelp)) then Memo1.Lines.LoadFromFile(sHelp);
     Memo1.Font.Size:=10;
end;

procedure TfrmHelp.Memo1Change(Sender: TObject);
begin

end;

initialization
  {$I helpform.lrs}

end.

