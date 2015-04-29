object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Char classification'
  ClientHeight = 268
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    635
    268)
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 0
    Width = 105
    Height = 105
    Stretch = True
  end
  object Label1: TLabel
    Left = 112
    Top = 16
    Width = 50
    Height = 13
    Caption = 'Enter char'
  end
  object edInputText: TEdit
    Left = 111
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 0
    OnChange = edInputTextChange
  end
  object sgResults: TStringGrid
    Left = 256
    Top = 0
    Width = 377
    Height = 265
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 2
    DefaultColWidth = 128
    TabOrder = 1
  end
end
