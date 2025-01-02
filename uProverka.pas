unit uProverka;

interface

uses Classes, Clipbrd, Windows, SysUtils, Graphics, JPEG;

type
  TProverka = class(TTHread)
  public
    VstavkaTekst: Boolean;
    VstavkaIzo: Boolean;

    procedure DobroTekst(bul: Boolean);
    procedure DobroIzo(bul: Boolean);
  private
    DobroNaTekst: Boolean;  //Разрешение на сохранение текста
    DobroNaIzo: Boolean;    //Разрешение на сохранение изображений
    Tekst: Utf8String;      //Последний сохранённый в буфере текст
  protected
    procedure Execute; override;
  end;

var
  Proverka: TProverka;

implementation

uses uGlav;

//==============================================================================

procedure TProverka.DobroTekst(bul: Boolean);
begin 
  DobroNaTekst:=bul;
  If bul then
  Begin
    if Clipboard.HasFormat(CF_TEXT) then
      Tekst:=Clipboard.AsText
    else Tekst:=#0;
  End;
end;

procedure TProverka.DobroIzo(bul: Boolean);
begin
  DobroNaIzo:=bul;
end;

//==============================================================================

procedure TProverka.Execute;
const
    //Назначение символов-исключений
  Nizya = ['\', '|', ':', '*', '?', '"', '<', '>', '/', #9];
var
  PicHndl: THandle;   //Дескриптор буфера с картинкой
  aPChar: Array [0..254] of Char; //Вспомогательный массив для получения заголовка окна
  Str: String;        //Вспомогательная строка для получения Str20
  Str20: String[20];  //Строка для 20 символов в заголовке файла
  F: TextFile;        //Идентификатор файла
  fs: TFormatSettings;//Настройки даты и времени
  Pic: TPicture;      //Хранилище изображения в bmp
  jpg: TJPEGImage;    //Изображение в jpg для сохранения
  TekstData: THandle; //Дескриптор для проверки наличия текста в буфере
  wTekst: WideString; //Текст, получаемый из буфера
begin
    //Настройка даты и времени
  fs.DateSeparator:='.';
  fs.TimeSeparator:='-';
  fs.ShortDateFormat:='dd.mm.yyyy hh-mm-ss';

    //Создаю экземпляры классов изображений
  Pic:=TPicture.Create;
  jpg:=TJPEGImage.Create;
  jpg.CompressionQuality:=100;  //Качество изображения jpg

    //Сохраняю хэндл или текст, чтобы не записывать ранее сохранённое значение
  PicHndl:=Clipboard.GetAsHandle(CF_BITMAP);
  If Clipboard.HasFormat(CF_TEXT) then Tekst:=Clipboard.AsText;

//-----------------------------------------------------------

    //Стартую цикл
  WHILE not Terminated DO
  BEGIN

  Sleep(100);

    //При включении не будет сохраняться ранее попавшее в буфер изображение
  If not DobroNaIzo and Clipboard.HasFormat(CF_BITMAP) then
    PicHndl:=Clipboard.GetAsHandle(CF_BITMAP);

//----------------------

    //Проверка на текст
  If Clipboard.HasFormat(CF_TEXT) and DobroNaTekst and
  (Tekst<>'') and (Clipboard.AsText <> Tekst) then
  Begin
      //Получаю строку из буфера
      //переработанная версия "function TClipboard.GetAsText: string;"
    if Clipboard.Formats[0]=CF_UNICODETEXT then   //Если строка в формате Unicode
    begin
      Clipboard.Open;
      TekstData:=GetClipboardData(CF_UNICODETEXT);
      try
        if TekstData<>0 then
          wTekst:=PWideChar(GlobalLock(TekstData))
        else wTekst:='';
      finally
        if TekstData<>0 then GlobalUnlock(TekstData);
        Clipboard.Close;
      end;
    end
    else if Clipboard.Formats[0]=CF_TEXT then     //Если строка в формате ANSI
    begin
      Clipboard.Open;
      TekstData:=GetClipboardData(CF_TEXT);
      try
        if TekstData<>0 then
          wTekst:=PChar(GlobalLock(TekstData))
        else wTekst:='';
      finally
        if TekstData<>0 then GlobalUnlock(TekstData);
        Clipboard.Close;
      end;
    end;

    Str20:='';
      //Если разрешена вставка в имя до 20 символов
    if VstavkaTekst then
    begin
        //Беру из буфера первую строку или первые 20 символов
      Str:=wTekst;
      while (Length(Str20)<20) and (Length(Str)>0) do
      begin                         //Удаление символов-исключений
        if Str[1] in Nizya then
          Delete(Str, 1, 1)
        else if Str[1]=#13 then
          Break
        else
        begin
          Str20:=Str20+Str[1];
          Delete(Str, 1, 1);
        end;
      end;
      Str20:=Trim(Str20);           //Удаляю пробелы по бокам
    end;

      //Создаю файл
    AssignFile(F, PapkaFailov+'\'+DateTimeToStr(Now, fs)+Str20+'.txt');
    Rewrite(F);
      //Сохраняю текст дабы не делать повторных файлов
    Tekst:=Clipboard.AsText;
      //Записываю текст в файл
    Write(F, wTekst);
    Close(F);
  End
//----------------------
    //Проверка на изображение
  Else if Clipboard.HasFormat(CF_BITMAP) and DobroNaIzo and
  (Clipboard.GetAsHandle(CF_BITMAP) <> PicHndl) then
  Begin
    Str20:='';
      //Если разрешена вставка в имя до 20 символов
    if VstavkaIzo then
    begin
        //Получаю заголовок окна того, что выше всех находится
      GetWindowText(GetForegroundWindow, aPChar, Length(apchar));
      Str:=aPChar;

      while (Length(Str20)<20) and (Length(Str)>0) do
      begin                         //Удаление символов-исключений
        if Str[1] in Nizya then
          Delete(Str, 1, 1)
        else if Str[1]=#13 then
          Break
        else
        begin
          Str20:=Str20+Str[1];
          Delete(Str, 1, 1);
        end;
      end;
      Str20:=Trim(Str20);           //Удаляю пробелы по бокам
    end;

      //Сохраняю хэндл буфера дабы не делать повторных файлов
    PicHndl:=Clipboard.GetAsHandle(CF_BITMAP);
      //Сохраняю картинку в bmp
    Pic.Bitmap.LoadFromClipBoardFormat(CF_BITMAP,
      Clipboard.GetAsHandle(CF_BITMAP), 0);

      //Перевожу bmp в jpg
    jpg.Assign(Pic.Bitmap);
      //Сохраняю jpg в файл
    jpg.SaveToFile(PapkaFailov+'\'+DateTimeToStr(Now, fs)+Str20+'.jpg');
  End;

  END;//WHILE not Terminated DO

//-----------------------------------------------------------

  Pic.Free;
  jpg.Free;
end;

initialization
  Proverka:=TProverka.Create(True);
  Proverka.FreeOnTerminate:=True;
  Proverka.Priority:=tpLower;
  Proverka.DobroNaTekst:=True;
  Proverka.DobroNaIzo:=True;
  Proverka.VstavkaTekst:=True;
  Proverka.VstavkaIzo:=True;

finalization
  Proverka.Terminate;

end.
