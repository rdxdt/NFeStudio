unit udmdnfe;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ZDataset, ZSqlStrings;

type

  { TdmdNFe }

  TdmdNFe = class(TDataModule)
    qryNFeCab: TZQuery;
    qryNFeDet: TZQuery;
    qryNFePgt: TZQuery;
    qryNFeVol: TZQuery;
    qryNFeDup: TZQuery;
    qryNFeFat: TZQuery;
    cmdCreateTables: TZQuery;
  private

  public
    procedure CriarTabelas;
  end;

var
  dmdNFe: TdmdNFe;

implementation

{$R *.lfm}

{ TdmdNFe }

procedure TdmdNFe.CriarTabelas;
var
  SQLStrings: TZSQLStrings;
  I: integer;
begin
  // O ExecSQL do Zeos executa somente o primeiro comando do texto no SQLite,
  // por isso cada comando do script é executado individualmente.
  SQLStrings := cmdCreateTables.SQL as TZSQLStrings;
  for I := 0 to SQLStrings.StatementCount - 1 do
    cmdCreateTables.Connection.ExecuteDirect(SQLStrings.Statements[I].SQL);
end;

end.

