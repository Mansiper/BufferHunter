object fPapka: TfPapka
  Left = 238
  Top = 563
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1042#1099#1073#1086#1088' '#1087#1072#1087#1082#1080
  ClientHeight = 240
  ClientWidth = 216
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object lTekst1: TLabel
    Left = 2
    Top = 0
    Width = 211
    Height = 28
    Alignment = taCenter
    AutoSize = False
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1085#1086#1074#1091#1102' '#1087#1072#1087#1082#1091' '#1076#1083#1103' '#1089#1086#1093#1088#1072#1085#1077#1085#1080#1103' '#1092#1072#1081#1083#1086#1074
    WordWrap = True
  end
  object dlb1: TDirectoryListBox
    Left = 2
    Top = 30
    Width = 209
    Height = 155
    Cursor = crHandPoint
    ItemHeight = 16
    TabOrder = 0
  end
  object bGotovo: TButton
    Left = 2
    Top = 216
    Width = 103
    Height = 21
    Cursor = crHandPoint
    Hint = #1042#1099#1073#1088#1072#1090#1100' '#1086#1090#1084#1077#1095#1077#1085#1091#1102' '#1087#1072#1087#1082#1091
    Caption = '&'#1043#1086#1090#1086#1074#1086
    Default = True
    ModalResult = 1
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  object bOtmena: TButton
    Left = 110
    Top = 216
    Width = 103
    Height = 21
    Cursor = crHandPoint
    Hint = #1054#1090#1084#1077#1085#1072
    Cancel = True
    Caption = '&'#1054#1090#1084#1077#1085#1072
    ModalResult = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object dcb1: TDriveComboBox
    Left = 2
    Top = 190
    Width = 209
    Height = 20
    Cursor = crHandPoint
    TabOrder = 1
    OnChange = dcb1Change
  end
end
