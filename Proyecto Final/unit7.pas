unit Unit7;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls;

type

  { TForm7 }

  TForm7 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label1: TLabel;
    Label2: TLabel;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private

  public
    estructura :array of array of Integer

  end;

var
  Form7: TForm7;

implementation

{$R *.lfm}

{ TForm7 }

procedure TForm7.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if StringGrid1.Cells[aCol,aRow] = '0' then
    StringGrid1.Cells[aCol,aRow] := '1'
  else
  begin
    StringGrid1.Cells[aCol,aRow] := '0';
  end;
end;

procedure TForm7.FormCreate(Sender: TObject);
var
  i, j: Integer;
begin
  // Establecer el tamaño de la matriz
  StringGrid1.ColCount := 3;
  StringGrid1.RowCount := 3;

  // Llenar la matriz con puros 0
  for i := 0 to StringGrid1.ColCount - 1 do
    begin
      for j := 0 to StringGrid1.RowCount - 1 do
        begin
          StringGrid1.Cells[i, j] := '0';
        end;
    end;
end;

procedure TForm7.Button2Click(Sender: TObject);
var
  i, j: Integer;
begin
  // Establecer el tamaño de la matriz
  StringGrid1.ColCount := StringGrid1.ColCount + 2;
  StringGrid1.RowCount := StringGrid1.RowCount;

  // Llenar la matriz con puros 0
  for i := 0 to StringGrid1.ColCount - 1 do
    begin
      for j := 0 to StringGrid1.RowCount - 1 do
        begin
          StringGrid1.Cells[i, j] := '0';
        end;
    end;
end;

procedure TForm7.Button3Click(Sender: TObject);
var
  i, j: Integer;
begin
  // Establecer el tamaño de la matriz
  if StringGrid1.RowCount <> 1 then
    begin                                          
      StringGrid1.RowCount := StringGrid1.RowCount - 2;
    end;

  // Llenar la matriz con puros 0
  for i := 0 to StringGrid1.ColCount - 1 do
    begin
      for j := 0 to StringGrid1.RowCount - 1 do
        begin
          StringGrid1.Cells[i, j] := '0';
        end;
    end;
end;


procedure TForm7.Button4Click(Sender: TObject);
var
  i, j: Integer;
begin
  // Establecer el tamaño de la matriz
  StringGrid1.ColCount := StringGrid1.ColCount;
  StringGrid1.RowCount := StringGrid1.RowCount + 2;

  // Llenar la matriz con puros 0
  for i := 0 to StringGrid1.ColCount - 1 do
    begin
      for j := 0 to StringGrid1.RowCount - 1 do
        begin
          StringGrid1.Cells[i, j] := '0';
        end;
    end;
end;

procedure TForm7.Button5Click(Sender: TObject);
var
  i, j:Integer;
begin
  SetLength(estructura, StringGrid1.ColCount, StringGrid1.RowCount);

  for i := 0 to StringGrid1.ColCount - 1 do
    for j := 0 to StringGrid1.RowCount - 1 do
      estructura[i, j] := StrToIntDef(StringGrid1.Cells[i, j], 0);
end;


procedure TForm7.Button1Click(Sender: TObject);
var
  i, j: Integer;
begin
  // Establecer el tamaño de la matriz
  if  StringGrid1.ColCount <> 1 then
    begin
         StringGrid1.ColCount := StringGrid1.ColCount - 2;
    end;

  // Llenar la matriz con puros 0
  for i := 0 to StringGrid1.ColCount - 1 do
    begin
      for j := 0 to StringGrid1.RowCount - 1 do
        begin
          StringGrid1.Cells[i, j] := '0';
        end;
    end;
end;



end.

