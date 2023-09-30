unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  ExtDlgs, LCLIntf, ComCtrls;

type



  { TForm1 }

  MATRGB = Array of Array of Array of Byte;  //Tri-dimensional para almacenar contenido de imagen

  TForm1 = class(TForm)
    Image1: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    OpenPictureDialog1: TOpenPictureDialog;
    ScrollBox1: TScrollBox;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
  private

  public

    //copiar de imagen a Matriz con Canvas
    procedure copiaIM(al,an: Integer; var M:MATRGB);

    //copiar de imagen a matriz con Scanline
    procedure copBM(al,an:Integer; var M:MATRGB; B:Tbitmap);

    //copiar de Matriz a BITmap
    procedure copMB(al,an: Integer; M:MATRGB; var B:Tbitmap);


  end;

var
  Form1: TForm1;
  ALTO, ANCHO   : Integer; //dimensiones de la imagen
  MAT           :MATRGB;

  BMAP          :Tbitmap;  //objeto orientado a directivas/metodos para .BMP

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem2Click(Sender: TObject);
begin

  if (OpenPictureDialog1.execute) then        //si seleccionan un archivo BMP
  begin

    Image1.Enabled:=True;
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
    ALTO:=Image1.Height; //dimensiones de la imagen
    ANCHO:=Image1.Width;

    //mostrar dimensiones en status bar
    StatusBar1.Panels[8].Text:= IntToStr(ALTO) + 'x' + IntToStr(ANCHO);

    SetLength(MAT,ALTO,ANCHO,3);     //especificar dimensiones de la matriz RGB
    copiaIM(ALTO,ANCHO,MAT); //copiar valores RGB a la MAtriz




  end;


end;

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
    Image1.Picture.Assign(BMAP);  //visulaizar imagen




  end;


end;

procedure TForm1.MenuItem5Click(Sender: TObject);
var
  i,j     :  Integer;
  k       :  Byte;
begin
  //filtro negativo

  for i:=0 to ALTO-1 do
  begin
    for j:=0 to ANCHO-1 do
    begin
      for k:=0 to 2 do
      begin
        MAT[i,j,k]:=255-MAT[i,j,k];

      end;  //k
    end;    //j
  end; //i

  copMB(ALTO,ANCHO,MAT,BMAP);

  //visualizar resultado
  Image1.Picture.Assign(BMAP);

end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  BMAP:=TBitmap.Create;  //crear el objeto BMAP



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

end.

