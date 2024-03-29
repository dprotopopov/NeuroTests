
program _test;
uses Sysutils, testkmeansunit;

var
    MySeed: Cardinal;
begin
    if StrToIntDef(ParamStr(1),0)=0 then
    begin
        Randomize();
        MySeed:=RandSeed;
    end
    else
        MySeed:=StrToIntDef(ParamStr(1),0);
    RandSeed:=MySeed;
    try 
        if not testkmeansunit_test_silent() then
            raise Exception.Create('');
    except on E: Exception do 
        begin
            WriteLn('kmeans                           FAILED(seed=',MySeed,')');
            Halt(1);
        end;
    end;
    WriteLn('kmeans                           OK');
    Halt(0);
end.
