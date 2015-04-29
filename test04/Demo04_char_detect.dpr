program Demo04_char_detect;

uses
  Vcl.Forms,
  main04 in 'main04.pas' {Form2},
  calc_utils in '..\utils\calc_utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
