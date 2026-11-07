program nfestudiotests;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  clocale,
  {$ENDIF}
  Interfaces, Classes, Math, consoletestrunner, tstprocessadornfe;

type

  { TExecutorTestes }

  TExecutorTestes = class(TTestRunner)
  end;

var
  App: TExecutorTestes;

begin
  // a libxml2 usada pelo ACBr dispara EInvalidOp com as exceções de FPU do FPC habilitadas;
  // no programa o widgetset do LCL já aplica esta máscara, mas o executor de testes não o inicializa
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
  DefaultFormat := fPlain;
  DefaultRunAllTests := True;
  App := TExecutorTestes.Create(nil);
  App.Initialize;
  App.Title := 'NFeStudio - testes';
  App.Run;
  App.Free;
end.
