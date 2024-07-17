object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Comunica'#231#227'o entre Threads'
  ClientHeight = 488
  ClientWidth = 563
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 563
    Height = 488
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    ExplicitLeft = -8
    ExplicitTop = -8
    object TabSheet1: TTabSheet
      Caption = 'Eventos'
      object Button1: TButton
        Left = 3
        Top = 16
        Width = 98
        Height = 81
        Caption = 'Eventos'
        TabOrder = 0
        OnClick = Button1Click
      end
    end
    object Mensagens: TTabSheet
      Caption = 'Mensagens'
      ImageIndex = 1
      object Button2: TButton
        Left = 3
        Top = 16
        Width = 98
        Height = 81
        Caption = 'Mensagens'
        TabOrder = 0
        OnClick = Button2Click
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Recursos Compartilhados com Sincroniza'#231#227'o'
      ImageIndex = 2
      object Label1: TLabel
        Left = 16
        Top = 18
        Width = 132
        Height = 17
        Caption = 'SharedResource value:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object Button3: TButton
        Left = 16
        Top = 49
        Width = 257
        Height = 81
        Caption = 'Recursos Compartilhados com Sincroniza'#231#227'o'
        TabOrder = 0
        OnClick = Button3Click
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Queues (Filas)'
      ImageIndex = 3
      object Memo1: TMemo
        Left = 3
        Top = 103
        Width = 534
        Height = 338
        TabOrder = 0
      end
      object Button4: TButton
        Left = 3
        Top = 16
        Width = 534
        Height = 81
        Caption = 'Queues (Filas)'
        TabOrder = 1
        OnClick = Button4Click
      end
    end
  end
end
