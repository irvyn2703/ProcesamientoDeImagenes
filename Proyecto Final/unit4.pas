unit Unit4;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  ExtDlgs, LCLIntf, ComCtrls, StdCtrls, Buttons, TAGraph, TASeries, Unit2,
  Unit3, Math, TAChartUtils, Types;

type

  { TForm4 }

  MATRGB = Array of Array of Array of Byte;

  TForm4 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
  private

  public
    //copiar de imagen a Matriz con Canvas
    procedure copiaIM(al,an: Integer; var M:MATRGB);

    //copiar de imagen a matriz con Scanline
    procedure copBM(al,an:Integer; var M:MATRGB; B:Tbitmap);

    //copiar de Matriz a BITmap
    procedure copMB(al,an: Integer; M:MATRGB; var B:Tbitmap);

    //copiar matriz a otra matriz
    procedure CopiarMatriz(const Orig: MATRGB; var Dest: MATRGB; Alto, Ancho: Integer);

    procedure suma(AO,LO,AM,LM :Integer;MO,MM:MATRGB);
    procedure resta(AO,LO,AM,LM :Integer;MO,MM:MATRGB);
    procedure multiplicacion(AO,LO,AM,LM :Integer;MO,MM:MATRGB);
    procedure OperacionLogica(AO, LO, AM, LM: Integer; MO, MM: MATRGB; Operacion: Integer);

  end;

var
  Form4: TForm4;
  ALTO, ANCHO, ALTOM, ANCHOM   :Integer;
  existeImg     :Boolean = False;
  existeMask     :Boolean = False;
  MATOriginal           :MATRGB; //matriz principal
  MATMascara           :MATRGB; //matriz principal
  MATResultado           :MATRGB; //matriz principal
  BMAPOrig          :Tbitmap;
  BMAPRes          :Tbitmap;


implementation

{$R *.lfm}

{ TForm4 }

procedure TForm4.MenuItem2Click(Sender: TObject);
var
  BMAPTemp :  TBitmap;
begin
  if OpenPictureDialog1.execute  then
  begin
    BMAPTemp := TBitmap.Create;
    BMAPTemp.LoadFromFile(OpenPictureDialog1.FileName);
    ALTOM:=BMAPTemp.Height;
    ANCHOM:=BMAPTemp.Width;

    if BMAPTemp.PixelFormat<> pf24bit then   //garantizar 8 bits por canal
    begin
      BMAPTemp.PixelFormat:=pf24bit;
    end;
    SetLength(MATMascara,ALTO,ANCHO,3);
    copBM(ALTO,ANCHO,MATMascara,BMAPTemp);
    existeMask:=True;
  end;
  if (existeImg) and (existeMask) then
  begin
    MenuItem3.Enabled:=True;
  end;
end;

procedure TForm4.MenuItem3Click(Sender: TObject);
begin
end;

procedure TForm4.MenuItem1Click(Sender: TObject);
begin
  if OpenPictureDialog1.execute  then
  begin
    Image1.Enabled:=True;
    Image2.Enabled:=True;
    BMAPOrig := TBitmap.Create;
    BMAPRes := TBitmap.Create;
    BMAPOrig.LoadFromFile(OpenPictureDialog1.FileName);
    BMAPRes.LoadFromFile(OpenPictureDialog1.FileName);
    ALTO:=BMAPOrig.Height;
    ANCHO:=BMAPOrig.Width;

    if BMAPOrig.PixelFormat<> pf24bit then   //garantizar 8 bits por canal
    begin
      BMAPOrig.PixelFormat:=pf24bit;
    end;
    SetLength(MATOriginal,ALTO,ANCHO,3);
    SetLength(MATResultado,ALTO,ANCHO,3);
    copBM(ALTO,ANCHO,MATOriginal,BMAPOrig);
    copBM(ALTO,ANCHO,MATResultado,BMAPOrig);
    Image1.Picture.Assign(BMAPOrig);  //visulaizar imagen
    Image2.Picture.Assign(BMAPRes);
    existeImg:=True;
  end;
  if (existeImg) and (existeMask) then
  begin
    MenuItem3.Enabled:=True;
  end;
end;

procedure TForm4.MenuItem10Click(Sender: TObject);
var
  MATTemp :MATRGB;
  MATTemp2 :MATRGB;
begin
  //NOT a la mascara
  OperacionLogica(ANCHO,ALTO,ANCHOM,ALTOM,MATMascara,MATMascara,3);
  CopiarMatriz(MATResultado,MATTemp2,ALTO,ANCHO);
  //suma entre la mascara NOT y la imagen original
  suma(ANCHO,ALTO,ANCHOM,ALTOM,MATOriginal,MATTemp2);
  // guardamos la suma (imagen con las areas oscuras de la mascara mas clara)
  CopiarMatriz(MATResultado,MATTemp,ALTO,ANCHO);
  // multiplicamos el resultado por la mascara
  multiplicacion(ANCHO,ALTO,ANCHOM,ALTOM,MATResultado,MATMascara);
  // restamos el resultado de la suma con el resultado de la multiplicacion
  resta(ANCHO,ALTO,ANCHOM,ALTOM,MATResultado,MATTemp);
end;

procedure TForm4.MenuItem11Click(Sender: TObject);
begin
  OperacionLogica(ANCHO,ALTO,ANCHOM,ALTOM,MATOriginal,MATMascara,3);
end;

procedure TForm4.MenuItem4Click(Sender: TObject);
begin
  suma(ANCHO,ALTO,ANCHOM,ALTOM,MATOriginal,MATMascara);

end;

procedure TForm4.MenuItem5Click(Sender: TObject);
begin
  resta(ANCHO,ALTO,ANCHOM,ALTOM,MATOriginal,MATMascara);
end;

procedure TForm4.MenuItem6Click(Sender: TObject);
begin
  multiplicacion(ANCHO,ALTO,ANCHOM,ALTOM,MATOriginal,MATMascara);
end;

procedure TForm4.MenuItem7Click(Sender: TObject);
begin
  OperacionLogica(ANCHO,ALTO,ANCHOM,ALTOM,MATOriginal,MATMascara,0);
end;

procedure TForm4.MenuItem8Click(Sender: TObject);
begin
  OperacionLogica(ANCHO,ALTO,ANCHOM,ALTOM,MATOriginal,MATMascara,1);
end;

procedure TForm4.MenuItem9Click(Sender: TObject);
begin
  OperacionLogica(ANCHO,ALTO,ANCHOM,ALTOM,MATOriginal,MATMascara,2);
end;

procedure Tform4.copiaIM(al,an: Integer; var M:MATRGB);
//copiar el contenido de la imagen a una MAtriz
var
  i,j  : Integer;
  cl   : Tcolor;

begin

  for i :=0 to al-1 do
  begin
    for j:=0 to an-1 do
    begin
      cl:=Image1.Canvas.Pixels[j,i]; //leer valor total de color del pixel j,i
      M[i,j,0]:=GetRValue(cl);
      M[i,j,1]:=GetGValue(cl);
      M[i,j,2]:=GetBValue(cl);


    end; //j
  end;//i


end;


//copiar de Bitmap a Matriz

procedure Tform4.copBM(al,an:Integer; var M:MATRGB; B:Tbitmap);
var
  i,j,k : Integer;
  P     :Pbyte;
begin
  for i:=0 to al-1 do
  begin
    B.BeginUpdate;
    P:=B.ScanLine[i];  //ller RGB de todo el renglon-i
    B.EndUpdate;

    for j:=0 to an-1 do
    begin
       k:=3*j;
       M[i,j,0]:=P[k+2];
       M[i,j,1]:=P[k+1];
       M[i,j,2]:=P[k];


    end; //j
  end; //i


end;

//procedimiento para copiar de MAtriz a bitmap

procedure tform4.copMB(al,an: Integer; M:MATRGB; var B:Tbitmap);
var
  i,j,k : Integer;
  P     :Pbyte;
begin
  for i:=0 to al-1 do
  begin
    B.BeginUpdate;
    P:=B.ScanLine[i];  //Invocar método para tener listo en memoria la localidad a modificar--> toda la fila
    B.EndUpdate;

    for j:=0 to an-1 do
    begin             //asignando valores de matriz al apuntador scanline--> Bitmap
       k:=3*j;
       P[k+2]:=M[i,j,0];
       P[k+1]:=M[i,j,1];
       P[k]:=M[i,j,2];
    end; //j
  end; //i
end;

// guaradar en la matriz
procedure tform4.CopiarMatriz(const Orig: MATRGB; var Dest: MATRGB; Alto, Ancho: Integer);
var
  i, j: Integer;
begin
    SetLength(Dest, Length(Orig), Length(Orig[0]), 3);
    for i := 0 to Length(Orig) - 1 do
    begin
      for j := 0 to Length(Orig[0]) - 1 do
      begin
        Dest[i, j, 0] := Orig[i, j, 0];
        Dest[i, j, 1] := Orig[i, j, 1];
        Dest[i, j, 2] := Orig[i, j, 2];
      end;
    end;
end;

procedure TForm4.suma(AO,LO,AM,LM :Integer;MO,MM:MATRGB);
var
  Aminimo:Integer;
  Lminimo:Integer;
  i,j,k:Integer;
begin
  if AO > AM then
  begin
    Aminimo:=AM;
  end
  else
  begin
    Aminimo:=AO;
  end;
  if LO > LM then
  begin
    Lminimo:=LM;
  end
  else
  begin
    Lminimo:=LO;
  end;

  //redimensionamos la matriz del resultado
  SetLength(MATResultado, Lminimo, Aminimo, 3);
  // Redimensionar BMAP
  BMAPRes.Width := Aminimo;
  BMAPRes.Height := Lminimo;

  for i := 0 to Lminimo - 1 do
  begin
    for j := 0 to Aminimo - 1 do
    begin
      for k := 0 to 2 do
      begin
        MATResultado[i,j,k] := Round((MO[i,j,k] + MM[i,j,k])/2);
      end;
    end;
  end;

  // Actualizar la imagen
  copMB(Lminimo, Aminimo, MATResultado, BMAPRes);
  Image2.Picture.Assign(BMAPRes);
end;

procedure TForm4.resta(AO,LO,AM,LM :Integer;MO,MM:MATRGB);
var
  Aminimo:Integer;
  Lminimo:Integer;
  i,j,k:Integer;
begin
  if AO > AM then
  begin
    Aminimo:=AM;
  end
  else
  begin
    Aminimo:=AO;
  end;
  if LO > LM then
  begin
    Lminimo:=LM;
  end
  else
  begin
    Lminimo:=LO;
  end;

  //redimensionamos la matriz del resultado
  SetLength(MATResultado, Lminimo, Aminimo, 3);
  // Redimensionar BMAP
  BMAPRes.Width := Aminimo;
  BMAPRes.Height := Lminimo;

  for i := 0 to Lminimo - 1 do
  begin
    for j := 0 to Aminimo - 1 do
    begin
      for k := 0 to 2 do
      begin
        MATResultado[i,j,k] := Abs(Round(MO[i,j,k] - MM[i,j,k]));
      end;
    end;
  end;

  // Actualizar la imagen
  copMB(Lminimo, Aminimo, MATResultado, BMAPRes);
  Image2.Picture.Assign(BMAPRes);
end;

procedure TForm4.multiplicacion(AO,LO,AM,LM :Integer;MO,MM:MATRGB);
var
  Aminimo:Integer;
  Lminimo:Integer;
  i,j,k:Integer;
begin
  if AO > AM then
  begin
    Aminimo:=AM;
  end
  else
  begin
    Aminimo:=AO;
  end;
  if LO > LM then
  begin
    Lminimo:=LM;
  end
  else
  begin
    Lminimo:=LO;
  end;

  //redimensionamos la matriz del resultado
  SetLength(MATResultado, Lminimo, Aminimo, 3);
  // Redimensionar BMAP
  BMAPRes.Width := Aminimo;
  BMAPRes.Height := Lminimo;

  for i := 0 to Lminimo - 1 do
  begin
    for j := 0 to Aminimo - 1 do
    begin
      for k := 0 to 2 do
      begin
        MATResultado[i,j,k] := Round((MO[i,j,k] * MM[i,j,k])/255);
      end;
    end;
  end;

  // Actualizar la imagen
  copMB(Lminimo, Aminimo, MATResultado, BMAPRes);
  Image2.Picture.Assign(BMAPRes);
end;

procedure TForm4.OperacionLogica(AO, LO, AM, LM: Integer; MO, MM: MATRGB; Operacion: Integer);
var
  Aminimo, Lminimo: Integer;
  i, j, k: Integer;
begin
  if AO > AM then
    Aminimo := AM
  else
    Aminimo := AO;

  if LO > LM then
    Lminimo := LM
  else
    Lminimo := LO;

  // Redimensionar la matriz del resultado
  SetLength(MATResultado, Lminimo, Aminimo, 3);
  // Redimensionar BMAP
  BMAPRes.Width := Aminimo;
  BMAPRes.Height := Lminimo;

  for i := 0 to Lminimo - 1 do
  begin
    for j := 0 to Aminimo - 1 do
    begin
      for k := 0 to 2 do
      begin
        case Operacion of
          0: // AND
            MATResultado[i, j, k] := Round((MO[i, j, k] * MM[i, j, k]) / 255);
          1: // OR
            MATResultado[i, j, k] := Round(((MO[i, j, k] + MM[i, j, k]) - (MO[i, j, k] * MM[i, j, k])) / 255);
          2: // XOR
            MATResultado[i, j, k] := Round(Abs(MO[i, j, k] - MM[i, j, k]));
          3: // NOT
            MATResultado[i, j, k] := 255 - MO[i, j, k];
        end;
      end;
    end;
  end;

  // Actualizar la imagen
  copMB(Lminimo, Aminimo, MATResultado, BMAPRes);
  Image2.Picture.Assign(BMAPRes);
end;


end.

