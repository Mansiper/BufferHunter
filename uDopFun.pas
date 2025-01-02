unit uDopFun;

interface

uses IniFiles, SysUtils, Forms, Dialogs, StdCtrls, ShlObj;

procedure SohrNastr;    //Сохраняет настройки в файл ini
function ChtenieNastr: Shortint;  //Читает настройки из файла ini
function MsgDlg(Verh, Tekst: String; Tip: TMsgDlgType; Knopki: TMsgDlgButtons;
  KnTekst: Array of String): Byte; //Вывод сообщения на экран

implementation

uses uGlav, uProverka;

procedure SohrNastr;
var
  iFail: TIniFile;
begin
  (* Сохранение настроек в файл ini *)

  TRY

  iFail:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'Proga.ini');

  iFail.WriteBool('Настройки', 'Текст', fGlav.pmSohrTekst.Checked);
  iFail.WriteBool('Настройки', 'Изображения', fGlav.pmSohrIzo.Checked);
  iFail.WriteBool('Настройки', 'Текст20', fGlav.pm20Tekst.Checked);
  iFail.WriteBool('Настройки', 'Изображения20', fGlav.pm20Izo.Checked);
  //iFail.WriteBool('Настройки', 'Запуск', fGlav.pmStartSistemy.Checked);
  iFail.WriteString('Настройки', 'Путь', PapkaFailov);

  iFail.Free;

  EXCEPT
    iFail.Free;
  END;
end;

function ChtenieNastr: Shortint;
const
  MAX_PATH = 260;
var
  iFail: TIniFile;
  Papka: Array [0..MAX_PATH] of Char;
  PIDL: PItemIDList;
begin
  (* Загрузка настроек из файла ini *)

  Result:=0;
  TRY

  iFail:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'Proga.ini');

  fGlav.pmSohrTekst.Checked:=iFail.ReadBool('Настройки', 'Текст', True);
  fGlav.pmSohrIzo.Checked:=iFail.ReadBool('Настройки', 'Изображения', True);

  fGlav.pm20Tekst.Checked:=iFail.ReadBool('Настройки', 'Текст20', True);
  fGlav.pm20Izo.Checked:=iFail.ReadBool('Настройки', 'Изображения20', True);

    //Установка флажка по наличию ссылки на приложение в папке "Автозагрузка"
    //(чисто по имени, без проверки параметров ссылки)
  SHGetSpecialFolderLocation(0, CSIDL_STARTUP, PIDL);
  SHGetPathFromIDList(PIDL, Papka);
  fGlav.pmStartSistemy.Checked:=
    FileExists(PAnsiChar(Papka+'\Охотник за буфером.lnk'));

  PapkaFailov:=iFail.ReadString('Настройки', 'Путь',
    ExtractFilePath(Application.ExeName)+'Файлы\');

  iFail.Free;

    //Путь не должен быть пустым
  If PapkaFailov='' then
    PapkaFailov:=ExtractFilePath(Application.ExeName)+'Файлы\';

    //Настройки потока
  Proverka.DobroTekst(fGlav.pmSohrTekst.Checked);
  Proverka.DobroIzo(fGlav.pmSohrIzo.Checked);
  Proverka.VstavkaTekst:=fGlav.pm20Tekst.Checked;
  Proverka.VstavkaIzo:=fGlav.pm20Izo.Checked;

    //Создание папки, если она не существует
  If not DirectoryExists(PapkaFailov) then
  Begin
    try
      if not ForceDirectories(PapkaFailov) then
      begin
        Result:=-1;
        Exit;
      end;
    except
      Result:=-1;
      Exit;
    end;
  End;

  Result:=1;

  EXCEPT
    iFail.Free;
  END;
end;

function MsgDlg(Verh, Tekst: String; Tip: TMsgDlgType; Knopki: TMsgDlgButtons;
  KnTekst: Array of String): Byte; 
const
  crHandPoint	= -21;  //Курсор в виде руки с вытянутым пальцем
var
  i, k: Byte;
  MD: TForm;
begin
  (* Функция вывода сообщений *)

    //Создаю окно диалога
  MD:=CreateMessageDialog(Tekst, Tip, Knopki);
    //Задаю ему свой заголовок
  MD.Caption:=Verh;

    //Размещение по центру экрана
  MD.Top:=Screen.Height DIV 2 - MD.Height DIV 2;
  MD.Left:=Screen.Width DIV 2 - MD.Width DIV 2;

    //Меняю текст кнопок
  k:=0;
  For i:=0 to MD.ControlCount-1 do
  Begin
    if MD.Controls[i] is TButton then
    begin
      (MD.Controls[i] as TButton).Cursor:=crHandPoint;
      (MD.Controls[i] as TButton).Caption:=KnTekst[k];
      Inc(k);
    end;
  End;//For

    //Показываю окно
  MD.ShowModal;
    //Возвращаю результат просмотра
  Result:=MD.ModalResult;
end;

end.
