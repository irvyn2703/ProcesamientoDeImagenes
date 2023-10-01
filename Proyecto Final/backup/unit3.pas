unit Unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    TrackBar1: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private

  public
    gamma: Double;

  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.TrackBar1Change(Sender: TObject);
begin
     gamma := StrToFloat(FormatFloat('0.00', TrackBar1.Position / 100));
     Label2.Caption := FloatToStr(gamma); // Convierte gamma de nuevo a una cadena si es necesario mostrarlo en Label2
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
     gamma := StrToFloat(FormatFloat('0.00', TrackBar1.Position / 100));
     Label2.Caption := FloatToStr(gamma); // Convierte gamma de nuevo a una cadena si es necesario mostrarlo en Label2
end;

end.

