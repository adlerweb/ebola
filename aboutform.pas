unit aboutform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    Button1: TButton;
    StaticText1: TStaticText;
    procedure StaticText1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  frmAbout: TfrmAbout;

implementation

{ TfrmAbout }

procedure TfrmAbout.StaticText1Click(Sender: TObject);
begin

end;

initialization
  {$I aboutform.lrs}

end.

