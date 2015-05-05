program Demo03_visual;

uses
  //FastMM4,
  Vcl.Forms,
  mainform03 in 'mainform03.pas' {Form1},
  calc_utils in '..\utils\calc_utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
