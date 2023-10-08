unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    TrackBar1: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private

  public
    r: Integer;

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.Label1Click(Sender: TObject);
begin

end;

procedure TForm2.Button1Click(Sender: TObject);
begin
     r:= TrackBar1.Position;
end;

procedure TForm2.TrackBar1Change(Sender: TObject);
begin
     r:= TrackBar1.Position;
end;

end.

