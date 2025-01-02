program Bufer;

uses
  Forms,
  Dialogs,
  Windows,
  uGlav in 'uGlav.pas' {fGlav},
  uDopFun in 'uDopFun.pas',
  uPapka in 'uPapka.pas' {fPapka},
  uProverka in 'uProverka.pas';

{$R *.res}

var
  cn: Shortint;

function Nizya: Boolean;
var
  Hdle: THandle;
begin
    //Открытие Мьютекса (виртуального файла)
  Hdle:=OpenMutex(MUTEX_ALL_ACCESS, False, 'MutBufOhot');
    //... в памяти
  Result:=(Hdle<>0);
    //Если ещё не создан, то создаём
  If Hdle=0 then CreateMutex(nil, False, 'MutBufOhot');
end;

begin
  If Nizya then Exit; //Запрещает запуск второй копии программы

  Application.Initialize;
  Application.Title:='Охотник за буфером';
  Application.CreateForm(TfGlav, fGlav);
  Application.CreateForm(TfPapka, fPapka);

    //Настройки всплывающей подсказки
  Application.HintColor:=$00BAF3DF; //$00FF00FF;
  Application.HintHidePause:=7000;

  cn:=ChtenieNastr;
  If cn=-1 then
  Begin
    MsgDlg('Ошибка - программа будет закрыта',
    'Ошибка создания каталога хранения данных.'+#13#10+#13#10+
    'Удалите файл "Proga.ini" из папки с программой и попробуйте ещё раз '+
    'запустить программу.'+#13#10+#13#10+
    'Если не помогло, то создайте папку с коротким (<10 символов) именем на '+
    'диске "C:\" ("D:\" или др.), переместите туда программу и поробуйти ещё '+
    'раз уже оттуда запустить её.', mtError, [mbOK], ['&Ясно']);
    Exit;
  End
  Else if cn=0 then
  Begin
    MsgDlg('Ошибка - программа будет работать (возможно без ошибок)',
    'Ошибка чтения данных настроек программы.'+#13#10+#13#10+
    'Рекомендую удалить файл "Proga.ini" из папки с программой.',
    mtWarning, [mbOK], ['&Добро']);
  End;

  Proverka.Resume;

  Application.Run;
end.
