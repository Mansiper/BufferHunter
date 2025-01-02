unit uPapka;

interface

uses
  Forms, StdCtrls, Controls, FileCtrl, Classes;

type
  TfPapka = class(TForm)
    lTekst1: TLabel;
    dlb1: TDirectoryListBox;
    bGotovo: TButton;
    bOtmena: TButton;
    dcb1: TDriveComboBox;
    procedure FormShow(Sender: TObject);
    procedure dcb1Change(Sender: TObject);
  end;

var
  fPapka: TfPapka;

implementation

uses uGlav;

{$R *.dfm}                

procedure TfPapka.FormShow(Sender: TObject);
begin
  Top:=fGlav.Height DIV 2 - Height DIV 2 + fGlav.Top;
  Left:=fGlav.Width DIV 2 - Width DIV 2 + fGlav.Left;
  If Top>Screen.Height-Height then Top:=Screen.Height-Height;
  If Left>Screen.Width-Width then Left:=Screen.Width-Width;
  If Top<0 then Top:=0;
  If Left<0 then Left:=0;
	dlb1.SetFocus;
end;

procedure TfPapka.dcb1Change(Sender: TObject);
begin
  If dcb1.Text[Pos('[', dcb1.Text)+1]<>']' then
    dlb1.Drive:=dcb1.Drive;
end;

end.
