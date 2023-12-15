unit Unit6;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  ExtDlgs, LCLIntf, ComCtrls, Buttons, StdCtrls, TAGraph, TASeries, Unit7,
  TAChartUtils, Types;

type

  { TForm6 }


  MATRGB = Array of Array of Array of Byte;

  TForm6 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    ScrollBox1: TScrollBox;
    ScrollBox2: TScrollBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    ToolBar1: TToolBar;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
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

  end;

var
  Form6: TForm6;
  ALTO, ANCHO   :Integer;
  existeImg     :Boolean = False;
  existeEstruc     :Boolean = False;
  MATOriginal           :MATRGB; //matriz principal
  MATEstruc           :MATRGB; //matriz principal
  MATResultado           :MATRGB; //matriz principal
  BMAPOrig          :Tbitmap;
  BMAPRes          :Tbitmap;


implementation

{$R *.lfm}

{ TForm6 }

procedure TForm6.SpeedButton1Click(Sender: TObject);
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
  if (existeImg) and (existeEstruc) then
  begin
    SpeedButton3.Enabled:=true;
    SpeedButton4.Enabled:=true;
  end;
end;

procedure TForm6.SpeedButton2Click(Sender: TObject);
begin
  form7.Showmodal;

   if form7.ModalResult = MROk then
   begin
     existeEstruc:=True;
     if (existeImg) and (existeEstruc) then
      begin
        SpeedButton3.Enabled:=true;
        SpeedButton4.Enabled:=true;
      end;
   end;
end;

procedure TForm6.SpeedButton3Click(Sender: TObject);
var
  estrucX, estrucY, x, y, i, j :Integer;
  iguales:Boolean;
begin
  // mostramos la matriz sin modificaciones
  copMB(ALTO, ANCHO, MATOriginal, BMAPOrig);

  Image1.Picture.Assign(BMAPOrig);

  estrucX:=High(Form7.estructura);
  estrucY:=High(Form7.estructura[0]);
  // recorremos la imagen dejando el margen de la matriz estructura
  for i := 0 + Round(estrucX/2) to High(MATOriginal) - Round(estrucX/2) - 1 do
  begin
    for j := 0 + Round(estrucY/2) to High(MATOriginal[0]) - Round(estrucY/2) -1 do
    begin
      // iniciamos asumiendo que el area a comparar y la estructura es igual
      iguales:=True;
      //comparamos el area con la estructura
      for x:=0 to estrucX do
      begin
        for y:=0 to estrucY do
        begin
          // si son diferentes cambiamos iguales:=False
          if Form7.estructura[x,y]*255 <> MATOriginal[i+x-(Round(estrucX/2)),j+y-(Round(estrucy/2)),0] then
           begin
             iguales:=False;
           end;
        end;
      end;
      // si el area es igual a la estructura pintamos el pixel de 255 de lo contrario lo pintamos de 0
      if iguales then
      begin
        // Asignar blanco si todos son iguales
        MATResultado[i, j, 0] := 255;
        MATResultado[i, j, 1] := 255;
        MATResultado[i, j, 2] := 255;
      end
      else
      begin
        // Asignar negro si hay alguna diferencia
        MATResultado[i, j, 0] := 0;
        MATResultado[i, j, 1] := 0;
        MATResultado[i, j, 2] := 0;
      end;
    end;
  end;

  //mostramos el resultado
  copMB(ALTO, ANCHO, MATResultado, BMAPRes);

  Image2.Picture.Assign(BMAPRes);

  //guardar el resultado
  CopiarMatriz(MATResultado,MATOriginal,ALTO,ANCHO);

end;

procedure TForm6.SpeedButton4Click(Sender: TObject);
var
  estrucX, estrucY, x, y, i, j :Integer;
  iguales:Boolean;
begin
  // mostramos la matriz sin modificaciones
  copMB(ALTO, ANCHO, MATOriginal, BMAPOrig);

  Image1.Picture.Assign(BMAPOrig);

  estrucX:=High(Form7.estructura);
  estrucY:=High(Form7.estructura[0]);
  // recorremos la imagen dejando el margen de la matriz estructura
  for i := 0 + Round(estrucX/2) to High(MATOriginal) - Round(estrucX/2) - 1 do
  begin
    for j := 0 + Round(estrucY/2) to High(MATOriginal[0]) - Round(estrucY/2) -1 do
    begin
      // iniciamos asumiendo que el area a comparar y la estructura es diferente
      iguales:=False;
      //comparamos el area con la estructura
      for x:=0 to estrucX do
      begin
        for y:=0 to estrucY do
        begin
          // si son iguales cambiamos iguales:=False
          if Form7.estructura[x,y]*255 = MATOriginal[i+x-(Round(estrucX/2)),j+y-(Round(estrucy/2)),0] then
           begin
             iguales:=True;
           end;
        end;
      end;
      // si el area es igual a la estructura pintamos el pixel de 255 de lo contrario lo pintamos de 0
      if iguales then
      begin
        // Asignar blanco si todos son iguales
        MATResultado[i, j, 0] := 255;
        MATResultado[i, j, 1] := 255;
        MATResultado[i, j, 2] := 255;
      end
      else
      begin
        // Asignar negro si hay alguna diferencia
        MATResultado[i, j, 0] := 0;
        MATResultado[i, j, 1] := 0;
        MATResultado[i, j, 2] := 0;
      end;
    end;
  end;

  //mostramos el resultado
  copMB(ALTO, ANCHO, MATResultado, BMAPRes);

  Image2.Picture.Assign(BMAPRes);

  //guardar el resultado
  CopiarMatriz(MATResultado,MATOriginal,ALTO,ANCHO);
end;


procedure Tform6.copiaIM(al,an: Integer; var M:MATRGB);
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

procedure Tform6.copBM(al,an:Integer; var M:MATRGB; B:Tbitmap);
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

procedure tform6.copMB(al,an: Integer; M:MATRGB; var B:Tbitmap);
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
procedure tform6.CopiarMatriz(const Orig: MATRGB; var Dest: MATRGB; Alto, Ancho: Integer);
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

end.

