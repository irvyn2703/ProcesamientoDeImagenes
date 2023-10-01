unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  ExtDlgs, LCLIntf, ComCtrls, StdCtrls, TAGraph, TASeries, Unit2, Unit3, Math;

type



  { TForm1 }

  MATRGB = Array of Array of Array of Byte;  //Tri-dimensional para almacenar contenido de imagen

  TForm1 = class(TForm)
    Button1: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    Chart1LineSeries2: TLineSeries;
    Chart1LineSeries3: TLineSeries;
    Image1: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem8: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    ScrollBox1: TScrollBox;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure ScrollBox1Click(Sender: TObject);
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

    // escala de grises
    procedure escalaDeGrises();

    //convertir de RGB a HSV
    procedure RGBaHSV(Rojo, Verde, Azul: Byte);

    // generar Histograma
    procedure generarHistograma();

  end;

var
  Form1: TForm1;
  ALTO, ANCHO   : Integer; //dimensiones de la imagen
  existeImg     :Boolean = False; //variable que nos verifica la existencia de una imagen
  MAT           :MATRGB; //matriz principal
  MATAux        :MATRGB; // Matriz auxiliar para guardar la copia de MAT
  MAT2          :MATRGB; //matriz secundaria

  BMAP          :Tbitmap;  //objeto orientado a directivas/metodos para .BMP

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  if OpenPictureDialog1.execute  then
  begin
    Image1.Enabled:=True;
    BMAP.LoadFromFile(OpenPictureDialog1.FileName);
    ALTO:=BMAP.Height;
    ANCHO:=BMAP.Width;

    if BMAP.PixelFormat<> pf24bit then   //garantizar 8 bits por canal
    begin
      BMAP.PixelFormat:=pf24bit;
    end;

    StatusBar1.Panels[8].Text:= IntToStr(ALTO) + 'x' + IntToStr(ANCHO);
    SetLength(MAT,ALTO,ANCHO,3);
    copBM(ALTO,ANCHO,MAT,BMAP);
    SetLength(MAT2,ALTO,ANCHO,3);
    Image1.Picture.Assign(BMAP);  //visulaizar imagen
    existeImg:=True;
    generarHistograma();

  end;


end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
  // copiamos la matriz a aux
  CopiarMatriz(MAT,MATAux,ALTO,ANCHO);

  // escala de grises
  escalaDeGrises();

  copMB(ALTO, ANCHO, MAT, BMAP);

  Image1.Picture.Assign(BMAP);

  // habilitamos el boton
  if existeImg then
     Button1.Enabled := True;
  generarHistograma();

end;


procedure TForm1.MenuItem8Click(Sender: TObject);
var
  i, j: Integer;
begin
  if existeImg then
  begin
       form2.Showmodal;

       if form2.ModalResult = MROk then
       begin
            // copiamos la matriz a aux
            CopiarMatriz(MAT,MATAux,ALTO,ANCHO);

            escalaDeGrises();

            for i := 0 to ALTO - 1 do
            begin
                 for j := 0 to ANCHO - 1 do
                 begin
                 if MAT[i,j,0] < form2.r then
                 begin
                   MAT[i,j,0] := 0;
                   MAT[i,j,1] := 0;
                   MAT[i,j,2] := 0;
                 end
                 else
                 begin
                   MAT[i,j,0] := 255;
                   MAT[i,j,1] := 255;
                   MAT[i,j,2] := 255;
                 end;
            end;
          end;

            copMB(ALTO, ANCHO, MAT, BMAP);

            Image1.Picture.Assign(BMAP);

            // habilitamos el boton
            Button1.Enabled := True;

            generarHistograma();
       end;
  end;

end;


procedure TForm1.ScrollBox1Click(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  BMAP:=TBitmap.Create;  //crear el objeto BMAP

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // copiar matriz auxiliar a la original
  CopiarMatriz(MATAux,MAT,ALTO,ANCHO);

  // mostramos la imagen
  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);

  generarHistograma();

  Button1.Enabled:=False;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   //al mover el mouse, indica las coordenadas X Y

  StatusBar1.Panels[1].Text:= IntToStr(X);
  StatusBar1.Panels[2].Text:= IntToStr(Y);
  StatusBar1.Panels[4].Text:= IntToStr(MAT[y,x,0]);
  StatusBar1.Panels[5].Text:= IntToStr(MAT[y,x,1]);
  StatusBar1.Panels[6].Text:= IntToStr(MAT[y,x,2]);
  RGBaHSV(MAT[y,x,0],MAT[y,x,1],MAT[y,x,2]);

end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var
  i, j: Integer;
begin
  if existeImg then
  begin
       form3.Showmodal;

       if form3.ModalResult = MROk then
       begin
            for i := 0 to ALTO - 1 do
            begin
              for j := 0 to ANCHO - 1 do
              begin
                // Aplicar la corrección gamma a cada canal (R, G, B)
                MAT[i, j, 0] := Round(Power(MAT[i, j, 0] / 255, form3.gamma) * 255);
                MAT[i, j, 1] := Round(Power(MAT[i, j, 1] / 255, form3.gamma) * 255);
                MAT[i, j, 2] := Round(Power(MAT[i, j, 2] / 255, form3.gamma) * 255);
              end;
            end;
       end;

  end;
end;

procedure Tform1.copiaIM(al,an: Integer; var M:MATRGB);
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
      MAT[i,j,0]:=GetRValue(cl);
      MAT[i,j,1]:=GetGValue(cl);
      MAT[i,j,2]:=GetBValue(cl);


    end; //j
  end;//i


end;


//copiar de Bitmap a Matriz

procedure Tform1.copBM(al,an:Integer; var M:MATRGB; B:Tbitmap);
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
       MAT[i,j,0]:=P[k+2];
       MAT[i,j,1]:=P[k+1];
       MAT[i,j,2]:=P[k];


    end; //j
  end; //i


end;

//procedimiento para copiar de MAtriz a bitmap

procedure tform1.copMB(al,an: Integer; M:MATRGB; var B:Tbitmap);
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
       P[k+2]:=MAT[i,j,0];
       P[k+1]:=MAT[i,j,1];
       P[k]:=MAT[i,j,2];


    end; //j
  end; //i
end;

// guaradar en la matriz
procedure tform1.CopiarMatriz(const Orig: MATRGB; var Dest: MATRGB; Alto, Ancho: Integer);
var
  i, j: Integer;
begin
    SetLength(Dest, Alto, Ancho, 3);
    for i := 0 to Alto - 1 do
    begin
      for j := 0 to Ancho - 1 do
      begin
        Dest[i, j, 0] := Orig[i, j, 0];
        Dest[i, j, 1] := Orig[i, j, 1];
        Dest[i, j, 2] := Orig[i, j, 2];
      end;
    end;
end;

procedure TForm1.RGBaHSV(Rojo, Verde, Azul: Byte);
var
  MinRGB, MaxRGB, Delta: Double;
  Matiz, Saturacion, Valor: Double; // Variables temporales
begin
  // Encontrar el valor mínimo y máximo entre los componentes Rojo, Verde y Azul.
  MinRGB := Rojo;
  if Verde < MinRGB then MinRGB := Verde;
  if Azul < MinRGB then MinRGB := Azul;

  MaxRGB := Rojo;
  if Verde > MaxRGB then MaxRGB := Verde;
  if Azul > MaxRGB then MaxRGB := Azul;

  // Calcular el Valor (Brightness) en el modelo HSV.
  Valor := MaxRGB / 255.0;

  // Calcular la diferencia entre el valor máximo y mínimo.
  Delta := MaxRGB - MinRGB;

  // Calcular la Saturación (Saturation) en el modelo HSV.
  if MaxRGB = 0 then
    Saturacion := 0
  else
    Saturacion := (Delta / MaxRGB);

  // Calcular el Matiz (Hue) en el modelo HSV.
  if Saturacion = 0 then
    Matiz := 0
  else
  begin
    if Rojo = MaxRGB then
      Matiz := (Verde - Azul) / Delta
    else if Verde = MaxRGB then
      Matiz := 2 + (Azul - Rojo) / Delta
    else
      Matiz := 4 + (Rojo - Verde) / Delta;
    Matiz := Matiz * 60;
    if Matiz < 0 then
      Matiz := Matiz + 360;
  end;

  // Asignar los valores a los TStatusPanel correspondientes
  StatusBar1.Panels[11].Text := FormatFloat('0.000', Matiz);
  StatusBar1.Panels[12].Text := FormatFloat('0.000', Saturacion);
  StatusBar1.Panels[13].Text := FormatFloat('0.000', Valor);
  // Determinar el canal más relevante basado en la saturación
  // Determinar el canal más relevante basado en las condiciones dadas
  if Valor < 0.4 then
    StatusBar1.Panels[15].Text := 'V' // Valores bajos en Valor nos darán colores oscuros sin importar los otros canales
  else if Saturacion < 0.4 then
    StatusBar1.Panels[15].Text := 'S' // Valores bajos en Saturación nos darán colores claros
  else
    StatusBar1.Panels[15].Text := 'H'; // Si los otros valores son altos, el Matiz nos definirá el color

end;

// generar histograma
procedure tform1.generarHistograma();
var
  i, j:Integer;
  FrecuenciaR, FrecuenciaG, FrecuenciaB: array[0..255] of Integer;
begin
  // Inicializar los arreglos de frecuencia
  for i := 0 to 255 do
  begin
    FrecuenciaR[i] := 0;
    FrecuenciaG[i] := 0;
    FrecuenciaB[i] := 0;
  end;

  // Recorrer la matriz MAT y contar la frecuencia de cada canal
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
    begin
      Inc(FrecuenciaR[MAT[i, j, 0]]);
      Inc(FrecuenciaG[MAT[i, j, 1]]);
      Inc(FrecuenciaB[MAT[i, j, 2]]);
    end;
  end;

  //graficar
  Chart1.Visible:=True;

  //Limpiar serie
  Chart1LineSeries1.Clear;
  Chart1LineSeries2.Clear;
  Chart1LineSeries3.Clear;
  for i:=0 to 255 do
  begin
       //definir función a graficar y llevarlo a cabo
     Chart1LineSeries1.LinePen.Color:= ClRed;
     Chart1LineSeries2.LinePen.Color:= clGreen;
     Chart1LineSeries3.LinePen.Color:= ClBlue;
     Chart1LineSeries1.AddXY(i,FrecuenciaR[i]);
     Chart1LineSeries2.AddXY(i,FrecuenciaG[i]);
     Chart1LineSeries3.AddXY(i,FrecuenciaB[i]);
  end;
end;

procedure tform1.escalaDeGrises();
var
  i, j, temp: Integer;
begin
  // Filtro grises
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
    begin
         temp := (MAT[i, j, 0] + MAT[i, j, 1] + MAT[i, j, 2]) div 3;
         MAT[i, j, 0] := temp;
         MAT[i, j, 1] := temp;
         MAT[i, j, 2] := temp;
    end;
  end;
end;

end.

