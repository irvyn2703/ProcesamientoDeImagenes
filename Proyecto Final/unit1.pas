unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  ExtDlgs, LCLIntf, ComCtrls, StdCtrls, Buttons, TAGraph, TASeries, Unit2,
  Unit3, Unit4, Unit5, Unit6, Math, TAChartUtils, Types;

type



  { TForm1 }
  TMyComplex = record
    Real: Double;
    Imag: Double;
  end;

  TComplexArray = array of array of TMyComplex;

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
    ColorDialog1: TColorDialog;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
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
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
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
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Chart1Click(Sender: TObject);
    procedure Chart1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image3Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem13Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem16Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem18Click(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem21Click(Sender: TObject);
    procedure MenuItem22Click(Sender: TObject);
    procedure MenuItem23Click(Sender: TObject);
    procedure MenuItem24Click(Sender: TObject);
    procedure MenuItem25Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure PaintBox1Click(Sender: TObject);
    procedure ScrollBox1Click(Sender: TObject);
    procedure ScrollBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBox1SizeConstraintsChange(Sender: TObject);
    procedure ScrollBox2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure ToolBar1Click(Sender: TObject);
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
    procedure RGBaHSVTodo(Rojo, Verde, Azul: Byte; var H, S, V: Double);

    // generar Histograma
    procedure generarHistograma();

    // aplicar matriz de convolucion
    procedure aplicarMatriz(Convolucion:Conv);

    // LBP
    procedure LBPMAXIMO();
    procedure LBPDESVIACION();

    // Fourier

    procedure FourierTransformada(const Input: MATRGB; var Output: TComplexArray);
    procedure MostrarEspectro(const Espectro: TComplexArray);
    procedure InverseFourier(const Input: TComplexArray);
    procedure HighPassFilter(corte: Double; espectro: TComplexArray);


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
  ALTOArit, ANCHOArit   :Integer; //dimensiones de la imagen para las aritmeticas
  ALTOAux, ANCHOAux   : Integer; //dimensiones de la imagen para restaurar
  existeImg     :Boolean = False; //variable que nos verifica la existencia de una imagen
  MAT           :MATRGB; //matriz principal
  MATArit       :MATRGB; //matriz para operaciones aritmetricas
  MATAux        :MATRGB; // Matriz auxiliar para guardar la copia de MAT
  MATConv       :MATRGB; // matriz secundaria para la convolucion
  CMin          :Integer = 0; // obtenemos los valores de las cotas
  CMax          :Integer = 255; // obtenemos los valores de las cotas
  BMAP          :Tbitmap;  //objeto orientado a directivas/metodos para .BMP
  CInferior     :Boolean = False; // variables para obtener las cotas
  CSuperior     :Boolean = False; // variables para obtener las cotas
  selecionando  :Boolean = False; // para saber si se esta seleccionando una area de la imagen
  punto1X       :Integer;  // area seleccionada
  punto1Y       :Integer;  // area seleccionada
  punto2X       :Integer;  // area seleccionada
  punto2Y       :Integer;  // area seleccionada
  MATFourier    :TComplexArray; // matriz para la transformada

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  if OpenPictureDialog1.execute  then
  begin
   Label5.Visible:=False;
    MenuItem23.Enabled:=False;
    Image1.Enabled:=True;
    BMAP.LoadFromFile(OpenPictureDialog1.FileName);
    ALTO:=BMAP.Height;
    ANCHO:=BMAP.Width;
    // asignamos los puntos de seleccion al alto y ancho de la imagen
    punto1X:=0;
    punto1Y:=0;
    punto2X:=ANCHO;
    punto2Y:=ALTO;

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
    SpeedButton1.Enabled:=True;
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
     SpeedButton3.Enabled := True;
  generarHistograma();

end;

procedure TForm1.MenuItem6Click(Sender: TObject);
var
  i, j: Integer;
  v: Double;
begin
  if existeImg then
  begin

    for i := punto1Y to punto2Y do
    begin
      for j := punto1X to punto2X do
      begin
        // Verificar límites de la matriz
        if (i >= 0) and (i < ALTO) and (j >= 0) and (j < ANCHO) then
        begin
          v := 255 / 2 * (1 + Tanh(4.6 * (MAT[i, j, 0] - 255 / 2) / 255));
          MAT[i, j, 0] := Round(v);
          v := 255 / 2 * (1 + Tanh(4.6 * (MAT[i, j, 1] - 255 / 2) / 255));
          MAT[i, j, 1] := Round(v);
          v := 255 / 2 * (1 + Tanh(4.6 * (MAT[i, j, 2] - 255 / 2) / 255));
          MAT[i, j, 2] := Round(v);
        end;
      end;
    end;

    // Actualiza la imagen
    copMB(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);
    // habilitar boton
    SpeedButton3.Enabled := True;
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
      for i := punto1Y to punto2Y do
      begin
        for j := punto1X to punto2X do
        begin
          // Verificar límites de la matriz
          if (i >= 0) and (i < ALTO) and (j >= 0) and (j < ANCHO) then
          begin
            MAT[i, j, 0] := Round(factor * (MAT[i, j, 0] - IMin) + CMin);
            MAT[i, j, 1] := Round(factor * (MAT[i, j, 1] - IMin) + CMin);
            MAT[i, j, 2] := Round(factor * (MAT[i, j, 2] - IMin) + CMin);
          end;
        end;
      end;

      // Actualiza la imagen
      copMB(ALTO, ANCHO, MAT, BMAP);
      Image1.Picture.Assign(BMAP);

      // habilitar boton
      SpeedButton3.Enabled:=True;

      generarHistograma();
  end;
end;


procedure TForm1.MenuItem8Click(Sender: TObject);
var
  i, j, k, l, newI, newJ, promedio, individuos: Integer;
begin
  newI:=0;
  newJ:=0;
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
                // Verificar límites de la matriz
                if (i >= 0) and (i < ALTO) and (j >= 0) and (j < ANCHO) then
                begin
                  promedio := 0;
                  individuos := 0;
                  for k := 0 to Form2.r - 1 do
                  begin
                    for l := 0 to Form2.r - 1 do
                    begin
                      // Verificar límites de la matriz interna
                      if ((i+k-1) < ALTO) and ((i+k-1) >= 0) and ((j+l-1) < ANCHO) and ((j+l-1) >= 0) then
                      begin
                        promedio := promedio + MAT[i+k-1, j+l-1, 0];
                        individuos := individuos + 1;
                      end;
                    end;
                  end;

                  promedio := Round(promedio / individuos);

                  // Ajustar valores de la matriz según el promedio calculado
                  if (promedio > MAT[i, j, 0]) and (i > punto1Y) and (i < punto2Y) and (j > punto1X) and (j < punto2X) then
                  begin
                    MAT[i, j, 0] := 0;
                    MAT[i, j, 1] := 0;
                    MAT[i, j, 2] := 0;
                  end;
                  if (promedio < MAT[i, j, 0]) and (i > punto1Y) and (i < punto2Y) and (j > punto1X) and (j < punto2X) then
                  begin
                    MAT[i, j, 0] := 255;
                    MAT[i, j, 1] := 255;
                    MAT[i, j, 2] := 255;
                  end;
                end;
              end;
            end;


            copMB(ALTO, ANCHO, MAT, BMAP);

            Image1.Picture.Assign(BMAP);

            // habilitamos el boton
            SpeedButton3.Enabled := True;

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

procedure TForm1.PaintBox1Click(Sender: TObject);
begin

end;

procedure TForm1.ScrollBox1Click(Sender: TObject);
begin

end;

procedure TForm1.ScrollBox1MouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TForm1.ScrollBox1SizeConstraintsChange(Sender: TObject);
begin
end;

procedure TForm1.ScrollBox2Click(Sender: TObject);
begin

end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
     selecionando := True;
     SpeedButton1.Enabled:=False;
     SpeedButton2.Enabled:=False;
     MenuItem19.Enabled:=False;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  punto1X:=0;
  punto1Y:=0;
  punto2X:=ANCHO;
  punto2Y:=ALTO;
  SpeedButton2.Enabled:=False;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
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

  SpeedButton3.Enabled:=False;
end;

procedure TForm1.ToolBar1Click(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  BMAP:=TBitmap.Create;  //crear el objeto BMAP

end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if selecionando then
  begin
    punto1X := X;
    punto1Y := Y;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i, j,conH,conS,conV: Integer;
  R, G, B: Byte;
  H,S,V:Double;
  MATTemp:MATRGB;
begin
  conH:=0;
  conS:=0;
  conV:=0;
  SetLength(MATTemp,ALTO,ANCHO,3);
  // Itera sobre cada píxel de la imagen original (MATOriginal) y convierte de RGB a HSV
  for i := 0 to ALTO-1 do
  begin
    for j := 0 to ANCHO-1 do
    begin
      // Obtén los componentes de color RGB del píxel
      R := MAT[i, j, 0];
      G := MAT[i, j, 1];
      B := MAT[i, j, 2];

      // Convierte de RGB a HSV
      RGBaHSVTodo(R, G, B, H, S, V);

      // Asigna el valor de H (tono) a la componente roja de la imagen HSV
      MATTemp[i, j, 0] := Round(H);
      // Asigna el valor de S (saturación) a la componente verde de la imagen HSV
      MATTemp[i, j, 1] := Round(S);
      // Asigna el valor de V (valor) a la componente azul de la imagen HSV
      MATTemp[i, j, 2] := Round(V);
      if V < 0.4 then
      begin
           conV:=conV+1;
      end;
      if S < 0.4 then
      begin
        conS:=conS+1;
      end;
      if (V > 0.4) and (S > 0.4) then
      begin
        conH:=conH+1;
      end;

    end;
  end;

  if (conH>conS) and (conH>conV) then
  begin
    Label5.Caption:='canal mas relevante es el H';
  end;                                          
  if (conS>conH) and (conS>conV) then
  begin
    Label5.Caption:='canal mas relevante es el S';
  end;
  if (conV>conS) and (conV>conH) then
  begin
    Label5.Caption:='canal mas relevante es el V';
  end;
  Label5.Visible:=True;
  SpeedButton3.Enabled:=True;
  // Muestra la imagen HSV en el componente TImage (Image1)
  copMB(ALTO, ANCHO, MATTemp, BMAP);
  Image1.Picture.Assign(BMAP);
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
  if (x < ANCHO) and (y < ALTO) then
  begin
    StatusBar1.Panels[4].Text:= IntToStr(MAT[y,x,0]);
    StatusBar1.Panels[5].Text:= IntToStr(MAT[y,x,1]);
    StatusBar1.Panels[6].Text:= IntToStr(MAT[y,x,2]);
    RGBaHSV(MAT[y,x,0],MAT[y,x,1],MAT[y,x,2]);
  end;

end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if selecionando then
    begin
    if punto1X > x then
    begin
      punto2X := punto1X;
      punto1X := x;
    end
    else
    begin
      punto2X := x;
    end;
    if punto1Y > y then
    begin
      punto2Y := punto1Y;
      punto1Y := y;
    end
    else
    begin
      punto2Y := y;
    end;

    selecionando := False;
    SpeedButton1.Enabled:=True;
    SpeedButton2.Enabled:=True;

  end;
end;

procedure TForm1.Image3Click(Sender: TObject);
begin

end;

procedure TForm1.Memo1Change(Sender: TObject);
begin

end;

procedure TForm1.MenuItem10Click(Sender: TObject);
begin
end;

procedure TForm1.MenuItem12Click(Sender: TObject);
begin
  if existeImg then
  begin
    CopiarMatriz(MAT,MATConv,ALTO,ANCHO);
    aplicarMatriz(suavisadoArit);
    CopiarMatriz(MATConv,MAT,ALTO,ANCHO);
    copMB(ALTO, ANCHO, MAT, BMAP);
    // habilitamos el boton
    SpeedButton3.Enabled := True;
    Image1.Picture.Assign(BMAP);
    generarHistograma();
  end;
end;

procedure TForm1.MenuItem13Click(Sender: TObject);
begin
  if existeImg then
  begin
    CopiarMatriz(MAT,MATConv,ALTO,ANCHO);
    escalaDeGrises();
    LBPMAXIMO();
    CopiarMatriz(MATConv,MAT,ALTO,ANCHO);
    copMB(ALTO, ANCHO, MAT, BMAP);
    // habilitamos el boton
    SpeedButton3.Enabled := True;
    Image1.Picture.Assign(BMAP);
    generarHistograma();
    MenuItem19.Enabled := True;
  end;
end;

procedure TForm1.MenuItem14Click(Sender: TObject);
begin
  if existeImg then
  begin
    CopiarMatriz(MAT,MATConv,ALTO,ANCHO);
    escalaDeGrises();
    LBPDESVIACION();
    CopiarMatriz(MATConv,MAT,ALTO,ANCHO);
    copMB(ALTO, ANCHO, MAT, BMAP);
    // habilitamos el boton
    SpeedButton3.Enabled := True;
    Image1.Picture.Assign(BMAP);
    generarHistograma();
    MenuItem19.Enabled := True;
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
    SpeedButton3.Enabled := True;
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
    SpeedButton3.Enabled := True;
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
        MAT[i, j + (ANCHO div 2 - 1), 0] := MATTemp[i, ANCHO div 2 -1-j, 0];
        MAT[i, j + (ANCHO div 2 - 1), 1] := MATTemp[i, ANCHO div 2 -1-j, 1];
        MAT[i, j + (ANCHO div 2 - 1), 2] := MATTemp[i, ANCHO div 2 -1-j, 2];
      end;
    end;

    // Reflejar la segunda mitad horizontalmente
    for i := 0 to ALTO - 1 do
    begin
      for j := ANCHO div 2 to ANCHO - 1 do
      begin
        MAT[i, j - (ANCHO div 2), 0] := MATTemp[i, ANCHO-(j-ANCHO div 2)-1, 0];
        MAT[i, j - (ANCHO div 2), 1] := MATTemp[i, ANCHO-(j-ANCHO div 2)-1, 1];
        MAT[i, j - (ANCHO div 2), 2] := MATTemp[i, ANCHO-(j-ANCHO div 2)-1, 2];
      end;
    end;

    // Actualizar la imagen en el control Image1
    copMB(ALTO, ANCHO, MAT, BMAP);
    Image1.Picture.Assign(BMAP);

    // Generar el histograma para la imagen reflejada
    generarHistograma();
    // habilitamos el boton
    SpeedButton3.Enabled := True;
  end;
end;

procedure TForm1.MenuItem19Click(Sender: TObject);
var
  coloresSelec: array[0..3] of TColor;
  color1: array[0..2] of Byte;
  color2: array[0..2] of Byte;
  color3: array[0..2] of Byte;
  color4: array[0..2] of Byte;
  i,j: Integer;
begin
  if ColorDialog1.Execute then
  begin
    coloresSelec[0] := ColorDialog1.Color;
    // extraer el color
    color1[0] := GetRValue(coloresSelec[0]);
    color1[1] := GetGValue(coloresSelec[0]);
    color1[2] := GetBValue(coloresSelec[0]);
  end;
  if ColorDialog1.Execute then
  begin
    coloresSelec[1] := ColorDialog1.Color;
    // extraer el color
    color2[0] := GetRValue(coloresSelec[1]);
    color2[1] := GetGValue(coloresSelec[1]);
    color2[2] := GetBValue(coloresSelec[1]);
  end;
  if ColorDialog1.Execute then
  begin
    coloresSelec[2] := ColorDialog1.Color;
    // extraer el color
    color3[0] := GetRValue(coloresSelec[2]);
    color3[1] := GetGValue(coloresSelec[2]);
    color3[2] := GetBValue(coloresSelec[2]);
  end;
  if ColorDialog1.Execute then
  begin
    coloresSelec[3] := ColorDialog1.Color;
    // extraer el color
    color4[0] := GetRValue(coloresSelec[3]);
    color4[1] := GetGValue(coloresSelec[3]);
    color4[2] := GetBValue(coloresSelec[3]);
  end;
  // color lineal
  for i := punto1Y to punto2Y do
    begin
      for j := punto1X to punto2X do
      begin
        // Verificar límites de la matriz
        if (i >= 0) and (i < ALTO) and (j >= 0) and (j < ANCHO) then
           begin
            // creamos la iterpolacion del falso color
            if MAT[i, j, 0] < (255 / 3) then
            begin
              MAT[i, j, 0] := Color1[0] + Round(MAT[i, j, 0] * (Color2[0] - Color1[0]) / 255);
              MAT[i, j, 1] := Color1[1] + Round(MAT[i, j, 0] * (Color2[1] - Color1[1]) / 255);
              MAT[i, j, 2] := Color1[2] + Round(MAT[i, j, 0] * (Color2[2] - Color1[2]) / 255);
            end
            else if MAT[i, j, 0] < (255 / 3) * 2 then
            begin
              MAT[i, j, 0] := Color2[0] + Round(MAT[i, j, 0] * (Color3[0] - Color2[0]) / 255);
              MAT[i, j, 1] := Color2[1] + Round(MAT[i, j, 0] * (Color3[1] - Color2[1]) / 255);
              MAT[i, j, 2] := color2[2] + Round(MAT[i, j, 0] * (Color3[2] - Color2[2]) / 255);
            end
            else if MAT[i, j, 0] < (255 / 3) * 3 then
            begin
              MAT[i, j, 0] := Color3[0] + Round(MAT[i, j, 0] * (Color4[0] - Color3[0]) / 255);
              MAT[i, j, 1] := Color3[1] + Round(MAT[i, j, 0] * (Color4[0] - Color3[1]) / 255);
              MAT[i, j, 2] := Color3[2] + Round(MAT[i, j, 0] * (Color4[0] - Color3[2]) / 255);
            end
            else
            begin
              MAT[i, j, 0] := color4[0];
              MAT[i, j, 1] := color4[1];
              MAT[i, j, 2] := color4[2];
            end;
           end;
         end;
       end;


  copMB(ALTO, ANCHO, MAT, BMAP);
  Image1.Picture.Assign(BMAP);

  // habilitamos el boton
  SpeedButton3.Enabled := True;

  generarHistograma();
  MenuItem19.Enabled:=False;
end;

procedure TForm1.MenuItem20Click(Sender: TObject);
begin
  form4.Showmodal;

   if form4.ModalResult = MROk then
   begin

   end;
end;

procedure TForm1.MenuItem21Click(Sender: TObject);
begin

end;

procedure TForm1.MenuItem22Click(Sender: TObject);
begin
  if existeImg then
  begin
    FourierTransformada(MAT,MATFourier);
    MostrarEspectro(MATFourier);
    InverseFourier(MATFourier);
    MenuItem23.Enabled:=True;
  end;
end;

procedure TForm1.MenuItem23Click(Sender: TObject);
begin
  form5.Showmodal;
  if form5.ModalResult = MROk then
  begin
    FourierTransformada(MAT,MATFourier);
    HighPassFilter(form5.corte,MATFourier);
    InverseFourier(MATFourier);
    MostrarEspectro(MATFourier);
  end;
end;

procedure TForm1.MenuItem24Click(Sender: TObject);
begin
  if OpenPictureDialog1.execute  then
  begin
    BMAP.LoadFromFile(OpenPictureDialog1.FileName);
    ALTOArit:=BMAP.Height;
    ANCHOArit:=BMAP.Width;

    if BMAP.PixelFormat<> pf24bit then   //garantizar 8 bits por canal
    begin
      BMAP.PixelFormat:=pf24bit;
    end;

    SetLength(MATArit,ALTOArit,ANCHOArit,3);
    copBM(ALTOArit,ANCHOArit,MATArit,BMAP);
  end;
end;

procedure TForm1.MenuItem25Click(Sender: TObject);
begin
  form6.Showmodal;
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

            for i := punto1Y to punto2Y do
            begin
              for j := punto1X to punto2X do
              begin
                // Verificar límites de la matriz
                if (i >= 0) and (i < ALTO) and (j >= 0) and (j < ANCHO) then
                begin
                  // Aplicar la corrección gamma a cada canal (R, G, B)
                  MAT[i, j, 0] := Round(Power(MAT[i, j, 0] / 255, form3.gamma) * 255);
                  MAT[i, j, 1] := Round(Power(MAT[i, j, 1] / 255, form3.gamma) * 255);
                  MAT[i, j, 2] := Round(Power(MAT[i, j, 2] / 255, form3.gamma) * 255);
                end;
              end;
            end;

            copMB(ALTO, ANCHO, MAT, BMAP);

            Image1.Picture.Assign(BMAP);

            // habilitamos el boton
            SpeedButton3.Enabled := True;

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
       M[i,j,0]:=P[k+2];
       M[i,j,1]:=P[k+1];
       M[i,j,2]:=P[k];


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

procedure TForm1.RGBaHSVTodo(Rojo, Verde, Azul: Byte; var H, S, V: Double);
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

  // Asignar los valores a las variables de salida
  H := Matiz;
  S := Saturacion;
  V := Valor;
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
  for i := punto1Y to punto2Y do
  begin
    for j := punto1X to punto2X do
    begin
      // Verificar límites de la matriz
      if (i >= 0) and (i < ALTO) and (j >= 0) and (j < ANCHO) then
         begin
           temp := (MAT[i, j, 0] + MAT[i, j, 1] + MAT[i, j, 2]) div 3;
           MAT[i, j, 0] := temp;
           MAT[i, j, 1] := temp;
           MAT[i, j, 2] := temp;
         end;
    end;
  end;
end;

procedure TForm1.aplicarMatriz(Convolucion:Conv);
var
  i,j,k,l:Integer;
  tempR,tempG,tempB:Double;
begin
  for i := punto1Y to punto2Y do
    begin
      for j := punto1X to punto2X do
      begin
        // Verificar límites de la matriz
        if (i > 0) and (i < ALTO-1) and (j > 0) and (j < ANCHO-1) then
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
  end;
end;

procedure TForm1.LBPMAXIMO();
var
  i,j,k,l: Integer;
  resultado: Double;
begin
  for i := punto1Y to punto2Y do
    begin
      for j := punto1X to punto2X do
      begin
        // Verificar límites de la matriz
        if (i > 0) and (i < ALTO-1) and (j > 0) and (j < ANCHO-1) then
           begin
            resultado := 0;
            // Comparar los valores de intensidad
            for k := 0 to 2 do
            begin
              for l := 0 to 2 do
              begin
                if (k <> 0) or (l <> 0) then // Evitar el píxel central
                begin
                  if MAT[i-1+k,j-1+l,0] > resultado then
                  begin
                    resultado := LBPMASK[k,l]; // Sumamos el valor
                  end;
                  if MAT[i-1+k,j-1+l,0] = resultado then
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
end;

procedure TForm1.LBPDESVIACION();
var
  i,j,k,l, promedio: Integer;
  desv, suma_cuadrados, resultado: Double;
begin
  for i := punto1Y to punto2Y do
    begin
      for j := punto1X to punto2X do
      begin
        // Verificar límites de la matriz
        if (i > 0) and (i < ALTO-1) and (j > 0) and (j < ANCHO-1) then
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
end;

procedure TForm1.FourierTransformada(const Input: MATRGB; var Output: TComplexArray);
var
  N, M, u, v, x, y: Integer;
  SumReal, SumImag: Double;
  CosTerm, SinTerm: Double;
begin
  N := Length(Input);
  M := Length(Input[0]);

  SetLength(Output, N, M);

  for u := 0 to N - 1 do
  begin
    for v := 0 to M - 1 do
    begin
      SumReal := 0.0;
      SumImag := 0.0;

      for x := 0 to N - 1 do
      begin
        for y := 0 to M - 1 do
        begin
          CosTerm := Cos(2 * Pi * ((u * x) / N + (v * y) / M));
          SinTerm := Sin(2 * Pi * ((u * x) / N + (v * y) / M));

          SumReal := SumReal + (Input[x, y, 0] * CosTerm - Input[x, y, 0] * SinTerm);
          SumImag := SumImag + (Input[x, y, 0] * SinTerm + Input[x, y, 0] * CosTerm);
        end;
      end;

      Output[u, v].Real := SumReal;
      Output[u, v].Imag := SumImag;
    end;
  end;
end;


procedure TForm1.MostrarEspectro(const Espectro: TComplexArray);
var
  i, j, x, y: Integer;
  MinValue, MaxValue: Double;
  BitmapTemp: TBitmap;
  MATTemp: MATRGB;
  temp :Double;
begin
  SetLength(MATTemp, Length(Espectro), Length(Espectro[0]), 3);

  // Encontrar el valor mínimo y máximo para normalizar el espectro
  MinValue := MaxDouble;
  MaxValue := -MaxDouble;
  for i := 1 to High(Espectro) do
  begin
    for j := 1 to High(Espectro[i]) do
    begin
      temp := Sqrt(Espectro[i, j].Real * Espectro[i, j].Real + Espectro[i, j].Imag * Espectro[i, j].Imag);
      if temp  < MinValue then
        MinValue := temp;
      if temp > MaxValue then
        MaxValue := temp;
    end;
  end;

  // Crear un objeto de mapa de bits para la imagen
  BitmapTemp := TBitmap.Create;
  BitmapTemp.SetSize(High(Espectro), High(Espectro[0]));

  // Normalizar y asignar colores al mapa de bits
  for i := 0 to High(Espectro) do
  begin
    for j := 0 to High(Espectro[i]) do
    begin
      x := (i + Length(Espectro) div 2) mod Length(Espectro);
      y := (j + Length(Espectro[i]) div 2) mod Length(Espectro[i]);

      temp := Sqrt(Espectro[x, y].Real * Espectro[x, y].Real + Espectro[x, y].Imag * Espectro[x, y].Imag);
      MATTemp[i, j, 0] := Round(((temp - MinValue) / (MaxValue - MinValue)) * (255 - 0) + 0);
      MATTemp[i, j, 1] := Round(((temp - MinValue) / (MaxValue - MinValue)) * (255 - 0) + 0);
      MATTemp[i, j, 2] := Round(((temp - MinValue) / (MaxValue - MinValue)) * (255 - 0) + 0);
    end;
  end;

  // Asignar el mapa de bits al componente TImage
  copMB(High(Espectro),High(Espectro[0]),MATTemp,BitmapTemp);
  Image2.Picture.Bitmap.Assign(BitmapTemp);
end;

procedure TForm1.InverseFourier(const Input: TComplexArray);
var
  N, M, u, v, x, y: Integer;
  SumReal, SumImag: Double;
  CosTerm, SinTerm: Double;
  MATTemp: MATRGB;
  BitmapTemp: TBitmap;
begin
  N := Length(Input);
  M := Length(Input[0]);

  SetLength(MATTemp, N, M, 3);
  BitmapTemp := TBitmap.Create;
  BitmapTemp.SetSize(N, M);


  for x := 0 to N - 1 do
  begin
    for y := 0 to M - 1 do
    begin
      SumReal := 0.0;
      SumImag := 0.0;

      for u := 0 to N - 1 do
      begin
        for v := 0 to M - 1 do
        begin
          CosTerm := Cos(-2 * Pi * ((u * x) / N + (v * y) / M));
          SinTerm := Sin(-2 * Pi * ((u * x) / N + (v * y) / M));

          SumReal := SumReal + (Input[u, v].Real * CosTerm - Input[u, v].Imag * SinTerm);
          SumImag := SumImag + (Input[u, v].Real * SinTerm + Input[u, v].Imag * CosTerm);
        end;
      end;
      MATTemp[x, y, 0] := Round(SumReal / (N * M));
      MATTemp[x, y, 1] := Round(SumReal / (N * M));
      MATTemp[x, y, 2] := Round(SumReal / (N * M));
    end;
  end;
  copMB(N,M,MATTemp,BitmapTemp);
  Image3.Picture.Bitmap.Assign(BitmapTemp);
end;

procedure TForm1.HighPassFilter(corte: Double; espectro: TComplexArray);
var
  N, M, u, v: Integer;
  D0, distancia: Double;
  temp: Double;
begin
  // Obtener dimensiones de la matriz espectro
  N := Length(espectro);
  M := Length(espectro[0]);

  D0 := corte;

  // Aplicar el filtro de ideal
  for u := 0 to N - 1 do
  begin
    for v := 0 to M - 1 do
    begin
      // Calcular la distancia en el dominio de la frecuencia
      distancia := Power(Power(u-N/2,2) + Power(v-M/2,2),1/2);

      // Calcular el factor de atenuación temporal usando la fórmula de Butterworth
      temp:=1;
      if distancia > corte then
      begin
       temp:=0;
      end;
      // Aplicar el factor de atenuación a la parte real e imaginaria
      espectro[u, v].Real := espectro[u, v].Real * temp;
      espectro[u, v].Imag := espectro[u, v].Imag * temp;
    end;
  end;
end;

end.

