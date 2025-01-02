unit uGlav;

interface

uses
  Forms, Messages, ShellAPI, SysUtils, Types, Windows, Classes, Menus, Dialogs,
  Controls, ShlObj, ActiveX, ComObj;

type
  TfGlav = class(TForm)
    PopupMenu1: TPopupMenu;
    pmVyhod: TMenuItem;
    pmL3: TMenuItem;
    pmSohrIzo: TMenuItem;
    pmSohrTekst: TMenuItem;
    pmL2: TMenuItem;
    pmPapka: TMenuItem;
    pmL1: TMenuItem;
    pmOtkryt: TMenuItem;
    pmOtkrPapka: TMenuItem;
    pm20Tekst: TMenuItem;
    pm20Izo: TMenuItem;
    pmNastroiki: TMenuItem;
    pmL5: TMenuItem;
    pmStartSistemy: TMenuItem;
    pmL6: TMenuItem;
    pmL4: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pmVyhodClick(Sender: TObject);
    procedure pmOtkrytClick(Sender: TObject);
    procedure pmSohrIzoClick(Sender: TObject);
    procedure pmSohrTekstClick(Sender: TObject);
    procedure pmPapkaClick(Sender: TObject);
    procedure pmOtkrPapkaClick(Sender: TObject);
    procedure pm20TekstClick(Sender: TObject);
    procedure pm20IzoClick(Sender: TObject);
    procedure pmStartSistemyClick(Sender: TObject);
  private
    FIconData: TNotifyIconData; //Иконка для трея
  protected
    Procedure WndProc(Var Msg: TMessage); override;
  end;

var
  fGlav: TfGlav;

  PapkaFailov: String;  //Путь к папке с файлами 

implementation

uses uDopFun, uPapka, uProverka;

{$R *.dfm}

//___________________________________Форма______________________________________
//==============================================================================

procedure TfGlav.FormCreate(Sender: TObject);
begin
  Inherited;
  Application.ShowMainForm:=False;    //Прячу главную форму
  Left:=Screen.Width-Width;           //Назначаю положение окна
  Top:=Screen.Height-Height;

    //Настройки иконки
  With FIconData do
  Begin
    cbSize:=SizeOf(FIconData);
    Wnd:=Handle;
    uID:=100;
    uFlags:=NIF_MESSAGE+NIF_ICON+NIF_TIP;
      //Сообщение для отлова нажатия мыши на иконке
    uCallbackMessage:=WM_USER+1;
    hIcon:=Application.Icon.Handle;
    StrPCopy(szTip, Application.Title)
  End;

    //Добавляю иконку в трей
  Shell_NotifyIcon(NIM_ADD, @FIconData);
end;

procedure TfGlav.FormDestroy(Sender: TObject);
begin
    //Убираю иконку из трея
  Shell_NotifyIcon(NIM_DELETE, @FIconData);
end;

procedure TfGlav.WndProc(Var Msg: TMessage);
var
  P: TPoint;
begin
    //Отлов нажатия мышью на иконке в трее
  If Msg.Msg=WM_USER+1 then
    case Msg.lParam of
      WM_LBUTTONDOWN:   //Левая кнопка (открытие окна с сохранёнными файлами)
          pmOtkrPapka.Click;
      WM_RBUTTONDOWN:   //Правая кнопка (показ контекстного меню)
        begin
          SetForegroundWindow(Handle);
          GetCursorPos(P);
          PopupMenu1.Popup(P.X, P.Y);
          PostMessage(Handle, WM_NULL, 0, 0)
        end;
    end;//case

  Inherited;
end;

procedure TfGlav.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  If PopupMenu1.Tag=1 then    //Приложение завершаю только по нажатию на
    CanClose:=True          //"Выход" в контекстном меню
  Else
  Begin
    CanClose:=False;
    Hide;
  End;
end;

//__________________________________Менюха______________________________________
//==============================================================================

procedure TfGlav.pmOtkrytClick(Sender: TObject);
begin
  (* Показывает главную форму *)
  Show;
end;

procedure TfGlav.pmOtkrPapkaClick(Sender: TObject);
begin
  (* Открывает текущую папку с сохранёнными файлами *)

  If ShellExecute(Handle, 'open', PChar(PapkaFailov), nil, nil,
    SW_SHOWNORMAL)<=32 then
      ShowMessage('Не могу открыть папку. Возможно, она не существует.');
end;

procedure TfGlav.pmVyhodClick(Sender: TObject);
begin
  (* Выход из программы *)

  PopupMenu1.Tag:=1;
  Close;
end;

//-------------------------Подменю "Настройки"

procedure TfGlav.pmSohrTekstClick(Sender: TObject);
begin
  (* Настройки сохранения буфера (текст) *)

    //Изменение разрешения потоку сохранять текст
  Proverka.DobroTekst(pmSohrTekst.Checked);
  SohrNastr;  //Сохраняю изменения
end;

procedure TfGlav.pmSohrIzoClick(Sender: TObject);
begin
  (* Настройки сохранения буфера (изображения) *)

    //Изменение разрешения потоку сохранять изображения
  Proverka.DobroIzo(pmSohrIzo.Checked);
  SohrNastr;  //Сохраняю изменения
end;

procedure TfGlav.pm20TekstClick(Sender: TObject);
begin
  (* Настройки вставки в название файла части текста *)

  Proverka.VstavkaTekst:=pm20Tekst.Checked;
  SohrNastr;  //Сохраняю изменения
end;

procedure TfGlav.pm20IzoClick(Sender: TObject);
begin
  (* Настройки вставки в название файла части названия окна *)

  Proverka.VstavkaIzo:=pm20Izo.Checked;
  SohrNastr;  //Сохраняю изменения
end;

procedure TfGlav.pmPapkaClick(Sender: TObject);
begin
  (* Выбор нового пути сохранения *)

  fPapka.dlb1.Directory:=PapkaFailov;

  fPapka.ShowModal;
  If fPapka.ModalResult=mrOk then
  Begin
    PapkaFailov:=fPapka.dlb1.Directory;
    SohrNastr;
  End;
end;

procedure TfGlav.pmStartSistemyClick(Sender: TObject);
var
  IObject: IUnknown;
  ISLink: IShellLink;
  IPFile: IPersistFile;
  PIDL: PItemIDList;
  InFolder: Array [0..MAX_PATH] of Char;
  TargetName: String;
  LinkName: WideString;
  Rez: HRESULT;
begin
  (* Создание ссылки на программу в папке "Автозагрузка" *)

    //Включить автозапуск
  If pmStartSistemy.Checked then
  Begin
      //Получаю путь к моей программе
    TargetName:=ParamStr(0);

      //Создаю ссылку
    IObject:=CreateComObject(CLSID_ShellLink);
    ISLink:=IObject as IShellLink;
    IPFile:=IObject as IPersistFile;

      //Параметры ссылки
    With ISLink do
    Begin
      SetPath(PChar(TargetName));
      SetWorkingDirectory(PChar(ExtractFilePath(TargetName)));
    End;

      //Получаю путь к папке "Автозагрузка"
    SHGetSpecialFolderLocation(0, CSIDL_STARTUP, PIDL);
    SHGetPathFromIDList(PIDL, InFolder);

      //Помещаю ссылку в папку
    LinkName:=InFolder+'\Охотник за буфером.lnk';
    Rez:=IPFile.Save(PWChar(LinkName), False);
      //Если положительный результат, то ставлю галочку, иначе нет
    pmStartSistemy.Checked:=( (Rez=S_OK) or (Rez=S_FALSE) );
  End

    //Выключить автозапуск
  Else //if not pmStartSistemy.Checked then
  Begin
      //Получаю путь к папке "Автозагрузка"
    SHGetSpecialFolderLocation(0, CSIDL_STARTUP, PIDL);
    SHGetPathFromIDList(PIDL, InFolder);

      //Удаляю ссылку (если успешно, то галочка исчезнет)
    pmStartSistemy.Checked:=
      not DeleteFile(PAnsiChar(InFolder+'\Охотник за буфером.lnk'));
  End;
  
  //SohrNastr;  //Сохраняю настройки
end;

end.
