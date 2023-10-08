unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  ExtDlgs, LCLIntf, ComCtrls, StdCtrls, TAGraph, TASeries, Unit2, Unit3, Math, TAChartUtils;

type



  { TForm1 }

  Conv = Array[0..2,0..2] of Double;  //matriz de 3x3
  MATRGB = Array of Array of Array of Byte;  //Tri-dimensional para almacenar contenido de imagen

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    Chart1LineSeries2: TLineSeries;
    Chart1LineSeries3: TLineSeries;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    SaveDialog1: TSaveDialog;
    ScrollBox1: TScrollBox;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Chart1Click(Sender: TObject);
    procedure Chart1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
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

    // aplicar matriz de convolucion
    procedure aplicarMatriz(Convolucion:Conv);

    // LBP
    procedure LBPMAXIMO();
    procedure LBPDESVIACION();

  end;
Const
  suavisadoArit        : Conv = ((1/8,1/8,1/8),
                                 (1/8,0,1/8),
                                 (1/8,1/8,1/8));
  LBPMASK                  : Conv = ((1,2,4),
                                 (128,0,8),
                                 (64,32,16));

var
  Form1: TForm1;
  ALTO, ANCHO   :Integer; //dimensiones de la imagen
  ALTOAux, ANCHOAux   : Integer; //dimensiones de la imagen para restaurar
  existeImg     :Boolean = False; //variable que nos verifica la existencia de una imagen
  MAT           :MATRGB; //matriz principal
  MATAux        :MATRGB; // Matriz auxiliar para guardar la copia de MAT
  MATConv       :MATRGB; // matriz secundaria
  CMin          :Integer = 0; // obtenemos los valores de las cotas
  CMax          :Integer = 255; // obtenemos los valores de las cotas
  BMAP          :Tbitmap;  //objeto orientado a directivas/metodos para .BMP
  CInferior     :Boolean = False; // variables para obtener las cotas
  CSuperior     :Boolean = False;

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
    SetLength(MATConv,ALTO,ANCHO,3);
    copBM(ALTO,ANCHO,MAT,BMAP);
    Image1.Picture.Assign(BMAP);  //visulaizar imagen
    existeImg:=True;
    // copiamos la matriz a aux
    CopiarMatriz(MAT,MATAux,ALTO,ANCHO);
    ALTOAux:=ALTO;
    ANCHOAux:=ANCHO;
    generarHistograma();
    Button2.Visible:=True;
    Button3.Visible:=True;
    Label1.Visible:=True;
    Label2.Visible:=True;
    Label3.Visible:=True;
    Label4.Visible:=True;
  end;


end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin

  // escala de grises
  escalaDeGrises();

  copMB(ALTO, ANCHO, MAT, BMAP);

  Image1.Picture.Assign(BMAP);

  // habilitamos el boton
  if existeImg then
     Button1.Enabled := True;
  generarHistograma();

end;

procedure TForm1.MenuItem6Click(Sender: TObject);
var
  i, j: Integer;
  v: Double;
begin
  if existeImg then
  begin

    for i := 0 to ALTO - 1 do
    begin
      for j := 0 to ANCHO - 1 do
      begin
        v := 255 / 2 * (1 + Tanh(4.6 * (MAT[i, j, 0] - 255 / 2) / 255));
        MAT[i, j, 0] := Round(v);
        v := 255 / 2 * (1 + Tanh(4.6 * (MAT[i, j, 1] - 255 / 2) / 255));
        MAT[i, j, 1] := Round(v);
        v := 255 / 2 * (1 + Tanh(4.6 * (MAT[i, j, 2] - 255 / 2) / 255));
        MAT[i, j, 2] := Round(v);
      end;
    end;

    // Actualiza la imagen
    copMB(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);
    // habilitar boton
    Button1.Enabled := True;
    generarHistograma();

  end;
end;

procedure TForm1.MenuItem7Click(Sender: TObject);
var
  IMin, IMax: Byte;
  i, j, k: Integer;
  factor: Double;
begin
  if existeImg then
  begin

      // Encuentra el valor mínimo (IMin) y máximo (IMax) en la imagen original
      IMin := 255;
      IMax := 0;

      // obtenemos el maximo y minimo
      for i := 0 to ALTO - 1 do
      begin
        for j := 0 to ANCHO - 1 do
        begin
          for k := 0 to 2 do
          begin
            if MAT[i, j, k] < IMin then
              IMin := MAT[i, j, k];
            if MAT[i, j, k] > IMax then
              IMax := MAT[i, j, k];
          end;
        end;
      end;

      // Calcula el factor de escala
      if (IMax - IMin) <> 0 then
        factor := (CMax - CMin) / (IMax - IMin)
      else
        factor := 0;

      // Aplica la contracción de contraste a cada canal R, G y B
      for i := 0 to ALTO - 1 do
      begin
        for j := 0 to ANCHO - 1 do
        begin
          MAT[i, j, 0] := Round(factor * (MAT[i, j, 0] - IMin) + CMin);
          MAT[i, j, 1] := Round(factor * (MAT[i, j, 1] - IMin) + CMin);
          MAT[i, j, 2] := Round(factor * (MAT[i, j, 2] - IMin) + CMin);
        end;
      end;

      // Actualiza la imagen
      copMB(ALTO, ANCHO, MAT, BMAP);
      Image1.Picture.Assign(BMAP);

      // habilitar boton
      Button1.Enabled:=True;

      generarHistograma();
  end;
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

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
  if existeImg then
  begin
    if SaveDialog1.Execute then
    begin
      // Obtiene la ruta del archivo seleccionado por el usuario
      // y guarda la imagen en ese archivo
      BMAP.SaveToFile(SaveDialog1.FileName);
      ShowMessage('La imagen se ha guardado exitosamente :)');
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
  CopiarMatriz(MATAux,MAT,ALTOAux,ANCHOAux);

  // Redimensionar BMAP
  BMAP.Width := ANCHOAux;
  BMAP.Height := ALTOAux;

  // mostramos la imagen
  copMB(ALTOAux, ANCHOAux, MAT, BMAP);
  Image1.Picture.Assign(BMAP);
  ALTO:=ALTOAux;
  ANCHO:=ANCHOAux;

  generarHistograma();

  Button1.Enabled:=False;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // bloqueamos los botones
  Button3.Enabled:=False;
  Button2.Enabled:=False;
  // mandamos la señal para obtener la coordenada x
  CInferior:=True;
  // ayudas visuales
  Label1.Font.Style := Label1.Font.Style + [fsBold];
  Label1.Caption:='...';
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  // bloqueamos los botones
  Button3.Enabled:=False;
  Button2.Enabled:=False;
  // mandamos la señal para obtener la coordenada x
  CSuperior:=True;
  // ayudas visuales
  Label2.Font.Style := Label2.Font.Style + [fsBold];
  Label2.Caption:='...';
end;

procedure TForm1.Chart1Click(Sender: TObject);
var
  X, Valor: Integer;
begin
  // Obtener la posición X del clic en relación con el TChart
  X := Chart1.ScreenToClient(Mouse.CursorPos).X;

  if (X >= 5) and (X <= Chart1.Width - 5) then
  begin
    // Excluir los primeros 5 píxeles y los últimos 5 píxeles
    // y convertir X a un valor entre 0 y 255 mediante una regla de tres
    Valor := Round((X - 5) / (Chart1.Width - 10) * 255);

    // Asegurarse de que el valor esté dentro del rango [0, 255]
    if Valor < 0 then
      Valor := 0
    else if Valor > 255 then
      Valor := 255;

    // Dependiendo de si está en la parte superior o inferior, puedes
    // almacenar el valor en la variable correspondiente o realizar
    // cualquier otra acción que desees.
    if CInferior then
    begin
      // Restaurar
      Button3.Enabled:=True;
      Button2.Enabled:=True;
      CSuperior:=False;
      CInferior:=False;
      if Valor < CMax then
      begin
        CMin:=Valor;
        Label1.Caption := IntToStr(CMin);
      end
      else
      begin
        Label1.Caption := IntToStr(CMin);
        ShowMessage('Valor invalido');
      end;
    end;

    if CSuperior then
    begin
      // Restaurar
      Button3.Enabled:=True;
      Button2.Enabled:=True;
      CSuperior:=False;
      CInferior:=False;
      if Valor > CMin then
      begin
        CMax:=Valor;
        Label2.Caption := IntToStr(CMax);
      end
      else
      begin
        Label2.Caption := IntToStr(CMax);
        ShowMessage('Valor invalido');
      end;
    end;
  end;
end;

procedure TForm1.Chart1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
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

procedure TForm1.MenuItem10Click(Sender: TObject);
begin
end;

procedure TForm1.MenuItem12Click(Sender: TObject);
begin
  if existeImg then
  begin
    aplicarMatriz(suavisadoArit);
    CopiarMatriz(MATConv,MAT,ALTO,ANCHO);
    copMB(ALTO, ANCHO, MAT, BMAP);
    // habilitamos el boton
    Button1.Enabled := True;
    Image1.Picture.Assign(BMAP);
    generarHistograma();
  end;
end;

procedure TForm1.MenuItem13Click(Sender: TObject);
begin
  if existeImg then
  begin
    escalaDeGrises();
    LBPMAXIMO();
    CopiarMatriz(MATConv,MAT,ALTO,ANCHO);
    copMB(ALTO, ANCHO, MAT, BMAP);
    // habilitamos el boton
    Button1.Enabled := True;
    Image1.Picture.Assign(BMAP);
    generarHistograma();
  end;
end;

procedure TForm1.MenuItem14Click(Sender: TObject);
begin
  if existeImg then
  begin
    escalaDeGrises();
    LBPDESVIACION();
    CopiarMatriz(MATConv,MAT,ALTO,ANCHO);
    copMB(ALTO, ANCHO, MAT, BMAP);
    // habilitamos el boton
    Button1.Enabled := True;
    Image1.Picture.Assign(BMAP);
    generarHistograma();
  end;
end;

procedure TForm1.MenuItem16Click(Sender: TObject);
var
  MATTemp: MATRGB;
  i, j: Integer;
begin
  if existeImg then
  begin
    // Duplicar las dimensiones
    ALTO := ALTO * 2;
    ANCHO := ANCHO * 2;

    // Redimensionar MATTemp
    SetLength(MATTemp, ALTO, ANCHO, 3);
    SetLength(MATConv, ALTO, ANCHO, 3);

    // Redimensionar BMAP
    BMAP.Width := ANCHO;
    BMAP.Height := ALTO;

    // Copiar los valores de MAT a MATTemp
    for i := 0 to ALTO div 2 - 1 do
    begin
      for j := 0 to ANCHO div 2 - 1 do
      begin
        // Copiar el valor de MAT a MATTemp en la nueva posición
        MATTemp[i * 2, j * 2] := MAT[i,j];
        MATTemp[i * 2 + 1, j * 2] := MAT[i,j];
        MATTemp[i * 2, j * 2 + 1] := MAT[i,j];
        MATTemp[i * 2 + 1, j * 2 + 1] := MAT[i,j];
      end;
    end;

    CopiarMatriz(MATTemp, MAT, ALTO, ANCHO);
    copMB(ALTO, ANCHO, MAT, BMAP);

    // habilitamos el boton
    Button1.Enabled := True;
    Image1.Picture.Assign(BMAP);
    StatusBar1.Panels[8].Text:= IntToStr(ALTO) + 'x' + IntToStr(ANCHO);
    generarHistograma();
  end;
end;



procedure TForm1.MenuItem17Click(Sender: TObject);
var
  MATTemp: MATRGB;
  i, j: Integer;
begin
  if existeImg then
  begin
    // Reducir a la mitad las dimensiones
    ALTO := ALTO div 2;
    ANCHO := ANCHO div 2;

    // Redimensionar MATTemp
    SetLength(MATTemp, ALTO, ANCHO, 3);
    SetLength(MATConv, ALTO, ANCHO, 3);

    // Redimensionar BMAP
    BMAP.Width := ANCHO;
    BMAP.Height := ALTO;

    // Copiar los valores de MAT a MATTemp calculando el promedio de 4 píxeles
    for i := 0 to ALTO - 1 do
    begin
      for j := 0 to ANCHO - 1 do
      begin
        // Calcular el promedio de los 4 píxeles originales
        MATTemp[i, j, 0] := (MAT[i * 2, j * 2, 0] + MAT[i * 2, j * 2 + 1, 0] +
                            MAT[i * 2 + 1, j * 2, 0] + MAT[i * 2 + 1, j * 2 + 1, 0]) div 4;

        MATTemp[i, j, 1] := (MAT[i * 2, j * 2, 1] + MAT[i * 2, j * 2 + 1, 1] +
                            MAT[i * 2 + 1, j * 2, 1] + MAT[i * 2 + 1, j * 2 + 1, 1]) div 4;

        MATTemp[i, j, 2] := (MAT[i * 2, j * 2, 2] + MAT[i * 2, j * 2 + 1, 2] +
                            MAT[i * 2 + 1, j * 2, 2] + MAT[i * 2 + 1, j * 2 + 1, 2]) div 4;
      end;
    end;

    CopiarMatriz(MATTemp, MAT, ALTO, ANCHO);
    copMB(ALTO, ANCHO, MAT, BMAP);

    // habilitar el botón
    Button1.Enabled := True;
    Image1.Picture.Assign(BMAP);
    StatusBar1.Panels[8].Text := IntToStr(ALTO) + 'x' + IntToStr(ANCHO);
    generarHistograma();
  end;
end;

procedure TForm1.MenuItem18Click(Sender: TObject);
var
  MATTemp: MATRGB;
  i, j: Integer;
begin
  if existeImg then
  begin
    // Crear una copia temporal de la matriz
    SetLength(MATTemp, ALTO, ANCHO, 3);
    CopiarMatriz(MAT, MATTemp, ALTO, ANCHO);

    // Reflejar la primera mitad horizontalmente
    for i := 0 to ALTO - 1 do
    begin
      for j := 0 to ANCHO div 2 - 1 do
      begin
        MAT[i, j, 0] := MATTemp[i, ANCHO div 2 -1-j, 0];
        MAT[i, j, 1] := MATTemp[i, ANCHO div 2 -1-j, 1];
        MAT[i, j, 2] := MATTemp[i, ANCHO div 2 -1-j, 2];
      end;
    end;

    // Reflejar la segunda mitad horizontalmente
    for i := 0 to ALTO - 1 do
    begin
      for j := ANCHO div 2 to ANCHO - 1 do
      begin
        MAT[i, j, 0] := MATTemp[i, ANCHO-(j-ANCHO div 2)-1, 0];
        MAT[i, j, 1] := MATTemp[i, ANCHO-(j-ANCHO div 2)-1, 1];
        MAT[i, j, 2] := MATTemp[i, ANCHO-(j-ANCHO div 2)-1, 2];
      end;
    end;

    // Actualizar la imagen en el control Image1
    copMB(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);

    // Generar el histograma para la imagen reflejada
    generarHistograma();
    // habilitamos el boton
    Button1.Enabled := True;
  end;
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

            copMB(ALTO, ANCHO, MAT, BMAP);

            Image1.Picture.Assign(BMAP);

            // habilitamos el boton
            Button1.Enabled := True;

            generarHistograma();
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
       P[k+2]:=M[i,j,0];
       P[k+1]:=M[i,j,1];
       P[k]:=M[i,j,2];
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
procedure TForm1.generarHistograma();
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

procedure TForm1.escalaDeGrises();
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

procedure TForm1.aplicarMatriz(Convolucion:Conv);
var
  i,j,k,l:Integer;
  tempR,tempG,tempB:Double;
begin
  for i := 1 to ALTO - 2 do
  begin
    for j := 1 to ANCHO - 2 do
    begin
       // reiniciamos las temporales
       tempR := 0;
       tempG := 0;
       tempB := 0;
       // recorremos la mascara
       for k := 0 to 2 do
       begin
          for l := 0 to 2 do
          begin
             tempR := tempR + Convolucion[k,l]*MAT[i-1+k,j-1+l,0];
             tempG := tempG + Convolucion[k,l]*MAT[i-1+k,j-1+l,1];
             tempB := tempB + Convolucion[k,l]*MAT[i-1+k,j-1+l,2];
          end;
       end;
       MATConv[i,j,0]:=Round(tempR);
       MATConv[i,j,1]:=Round(tempG);
       MATConv[i,j,2]:=Round(tempB);
    end;
  end;
  // Copiar los bordes de la imagen original a la matriz convolucionada
  for i := 0 to ALTO - 1 do
  begin
    for j := 0 to ANCHO - 1 do
    begin
      if (i = 0) or (i = ALTO - 1) or (j = 0) or (j = ANCHO - 1) then
      begin
        MATConv[i, j, 0] := MAT[i, j, 0];
        MATConv[i, j, 1] := MAT[i, j, 1];
        MATConv[i, j, 2] := MAT[i, j, 2];
      end;
    end;
  end;
end;

procedure TForm1.LBPMAXIMO();
var
  i,j,k,l: Integer;
  resultado: Double;
begin
  for i := 1 to ALTO - 2 do
  begin
    for j := 1 to ANCHO - 2 do
    begin
      resultado := 0;
      // Comparar los valores de intensidad
      for k := 0 to 2 do
      begin
        for l := 0 to 2 do
        begin
          if (k <> 0) or (l <> 0) then // Evitar el píxel central
          begin
            if MAT[i-1+k,j-1+l,0] >= MAT[i,j,0] then
            begin
              resultado := resultado + LBPMASK[k,l]; // Sumamos el valor
            end;
          end;
        end;
      end;

      // Asignar el resultado a la matriz de salida (puedes ajustar los canales G y B según sea necesario)
      MATConv[i, j, 0] := Round(resultado);
      MATConv[i, j, 1] := Round(resultado);
      MATConv[i, j, 2] := Round(resultado);
    end;
  end;
end;

procedure TForm1.LBPDESVIACION();
var
  i,j,k,l, promedio: Integer;
  desv, suma_cuadrados, resultado: Double;
begin
  for i := 1 to ALTO - 2 do
  begin
    for j := 1 to ANCHO - 2 do
    begin
      // Calcular el promedio de los píxeles en la región 3x3
      promedio := 0;
      for k := -1 to 1 do
      begin
        for l := -1 to 1 do
        begin
          promedio := promedio + MAT[i + k, j + l, 0]; // Sumar los valores
        end;
      end;
      promedio := Round(promedio / 9.0);

      // Calcular la desviación estándar de los píxeles en la región 3x3
      suma_cuadrados := 0;
      for k := -1 to 1 do
      begin
        for l := -1 to 1 do
        begin
          suma_cuadrados := suma_cuadrados + Sqr(MAT[i + k, j + l, 0] - promedio); // Calcular la suma de los cuadrados de las diferencias
        end;
      end;
      desv := Sqrt(suma_cuadrados / 9.0); // Calcular la desviación estándar

      resultado := 0;

      // Comparar los valores de intensidad
      for k := 0 to 2 do
      begin
        for l := 0 to 2 do
        begin
          if (k <> 0) or (l <> 0) then // Evitar el píxel central
          begin
            if (MAT[i-1+k, j-1+l, 0] - promedio) >= desv then
            begin
              resultado := resultado + LBPMASK[k,l]; // Sumamos el valor
            end;
          end;
        end;
      end;

      // Asignar el resultado a la matriz de salida (puedes ajustar los canales G y B según sea necesario)
      MATConv[i, j, 0] := Round(resultado);
      MATConv[i, j, 1] := Round(resultado);
      MATConv[i, j, 2] := Round(resultado);
    end;
  end;
end;

end.

