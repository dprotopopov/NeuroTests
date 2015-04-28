object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Neuro visual test'
  ClientHeight = 549
  ClientWidth = 916
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GridPanel1: TGridPanel
    Left = 0
    Top = 0
    Width = 916
    Height = 549
    Align = alClient
    Caption = 'GridPanel1'
    ColumnCollection = <
      item
        Value = 100.000000000000000000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = Chart1
        Row = 0
      end
      item
        Column = 0
        Control = Chart2
        Row = 1
      end>
    RowCollection = <
      item
        Value = 50.000000000000000000
      end
      item
        Value = 50.000000000000000000
      end>
    TabOrder = 0
    ExplicitLeft = 496
    ExplicitTop = 200
    ExplicitWidth = 329
    ExplicitHeight = 209
    object Chart1: TChart
      Left = 1
      Top = 1
      Width = 914
      Height = 273
      Legend.Visible = False
      Title.Text.Strings = (
        'TChart')
      View3D = False
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 327
      ExplicitHeight = 103
      DefaultCanvas = 'TGDIPlusCanvas'
      ColorPaletteIndex = 13
      object SeriesSrc: TLineSeries
        Brush.BackColor = clDefault
        Pointer.InflateMargins = True
        Pointer.Style = psRectangle
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
    end
    object Chart2: TChart
      Left = 1
      Top = 274
      Width = 914
      Height = 274
      Legend.Visible = False
      Title.Text.Strings = (
        'TChart')
      View3D = False
      Align = alClient
      TabOrder = 1
      ExplicitLeft = 258
      ExplicitTop = 286
      ExplicitWidth = 327
      ExplicitHeight = 103
      DefaultCanvas = 'TGDIPlusCanvas'
      ColorPaletteIndex = 13
      object SeriesFiltered: TLineSeries
        Brush.BackColor = clDefault
        Pointer.InflateMargins = True
        Pointer.Style = psRectangle
        XValues.Name = 'X'
        XValues.Order = loAscending
        YValues.Name = 'Y'
        YValues.Order = loNone
      end
    end
  end
end
