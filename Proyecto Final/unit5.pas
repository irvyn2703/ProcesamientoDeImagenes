unit Unit5;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type

  { TForm5 }

  TForm5 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    TrackBar1: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private

  public
    corte: Double;

  end;

var
  Form5: TForm5;

implementation

{$R *.lfm}

{ TForm5 }

procedure TForm5.TrackBar1Change(Sender: TObject);
begin
  corte := TrackBar1.Position;
end;

procedure TForm5.Button1Click(Sender: TObject);
begin
  corte := TrackBar1.Position;
end;

end.

