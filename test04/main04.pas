unit main04;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  Generics.Collections, Ap, mlpbase;

type
  TForm2 = class(TForm)
    Image1: TImage;
    edInputText: TEdit;
    Label1: TLabel;
    sgResults: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure edInputTextChange(Sender: TObject);
  private
    { Private declarations }
    FBitmap: TBitmap;
    FCharList: TList<char>;
    lXY: TReal2DArray;
    lNetwork: MultiLayerPerceptron;
    procedure PrintChar(aCanvas: TCanvas; const aStr: string);
    procedure SetBitmapDefaultProps(aBitmap: TBitmap);
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation
uses calc_utils;

{$R *.dfm}

const 
  ImageSizeW = 20;
  ImageSizeH = 25;
  ImagePixelCount = ImageSizeW*ImageSizeH;
  
procedure TForm2.edInputTextChange(Sender: TObject);
var
  i: Integer;
  lX, lY:TReal1DArray;
begin
  if Length(edInputText.Text) > 1 then
    edInputText.Text := copy(edInputText.Text, 0, 1);
  PrintChar(Image1.Picture.Bitmap.Canvas, edInputText.Text);

  SetLength(lX, ImagePixelCount);
  SetLength(lY, FCharList.Count);
  Get1DArrayFromImage(Image1.Picture.Bitmap.Canvas, ImageSizeW, ImageSizeH, lX);
  MLPProcess(lNetwork, lX, lY);

  sgResults.RowCount := FCharList.Count + 1;
  for I := 0 to FCharList.Count - 1 do
  begin
    sgResults.Cells[0, I + 1] := FCharList[i];
    sgResults.Cells[1, I + 1] := FloatToStr(lY[i]);
  end;
    
  SetLength(lX, 0);
  SetLength(lY, 0);
end;

procedure TForm2.FormShow(Sender: TObject);
var
  i: Integer;
  ch: char;
begin
  SetBitmapDefaultProps(Image1.Picture.Bitmap);

  FBitmap := TBitmap.Create;
  SetBitmapDefaultProps(FBitmap);

  // добавим все используемые символы
  FCharList := TList<char>.Create;
  for ch := 'A' to 'Z' do
    FCharList.Add(ch);
  for ch := 'А' to 'Я' do
    FCharList.Add(ch);
  // формируем нейросеть
  NewEmptyMatrix(ImagePixelCount + FCharList.Count, FCharList.Count, lXY);
  for I := 0 to FCharList.Count - 1 do
  begin
    PrintChar(FBitmap.Canvas, FCharList[I]);
    PutImageToArrayLine(I, I, FBitmap.Canvas, ImageSizeW, ImageSizeH, lXY);
  end;
  // обучение нейросети
  CalcNeuroMatrix(False, 1, ImagePixelCount, FCharList.Count, lXY, lNetwork);

  // отобразим букву
  edInputText.Text := 'W';
end;

procedure TForm2.PrintChar(aCanvas: TCanvas; const aStr: string);
begin
  aCanvas.Lock;
  aCanvas.Rectangle(0,0,ImageSizeW, ImageSizeH);
  aCanvas.TextOut(0,0, aStr);
  aCanvas.Unlock;
end;

procedure TForm2.SetBitmapDefaultProps(aBitmap: TBitmap);
begin
  // set image params
  aBitmap.SetSize(ImageSizeW, ImageSizeH);
  aBitmap.Canvas.Brush.Color := clWhite;
  aBitmap.Canvas.Brush.Style := bsSolid;
  aBitmap.Canvas.Pen.Color := clWhite;
  aBitmap.Canvas.Font.Size := 14;
end;

end.
